const std = @import("std");
const net = std.net;
const posix = std.posix;

pub const PlayerSocket = struct {
    address: net.Address,
    address_len: posix.socklen_t,
    socket: posix.socket_t,
    
    pub fn write(self: PlayerSocket, msg: []const u8) !void {
        const socket = self.socket;
        var pos: usize = 0;
        while (pos < msg.len) {
            const written = try posix.write(socket, msg[pos..]);
            if (written == 0) {
                return error.Closed;
            }
            pos += written;
        }
    }

    pub fn disconnect(self: PlayerSocket) void {
        posix.close(self.socket);
    }
};

pub const TcpServer = struct {
    ip: []const u8,
    port: u16,
    addr: net.Address,
    listener: posix.socket_t,

    /// TODO: Actual error handling.
    pub fn init(ip: []const u8, port: u16) !TcpServer {
        const address = try net.Address.parseIp4(ip, port);
        const tpe = posix.SOCK.STREAM;
        const protocol = posix.IPPROTO.TCP;
        const listener = try posix.socket(address.any.family, tpe, protocol);

        try posix.setsockopt(listener, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
        try posix.bind(listener, &address.any, address.getOsSockLen());
        try posix.listen(listener, 128);

        return TcpServer {
            .ip = ip,
            .port = port,
            .addr = address,
            .listener = listener,
        };
    }

    /// Very unlikely to return null, waits untill a connection is established.
    pub fn accept(self: *TcpServer) !?PlayerSocket {
        var client_address: net.Address = undefined;
        var client_address_len: posix.socklen_t = @sizeOf(net.Address);
        const socket = posix.accept(self.listener, &client_address.any, &client_address_len, 0) catch |err| {
            std.debug.print("error accept: {}\n", .{err});
            return null;
        };
        return PlayerSocket {
            .address = client_address,
            .socket = socket,
            .address_len = client_address_len,
        };
    }

    pub fn deinit(self: *TcpServer) void {
        posix.close(self.listener);
    }
};