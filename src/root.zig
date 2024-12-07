const std = @import("std");
pub const net = @import("net/server.zig");

pub const ZigMc = struct {

    server: net.TcpServer 

};


pub fn init(ip: []const u8, port: u16) InitError!void {
    const address = net.Address.parseIp4(ip, port)
    const tpe = posix.SOCK.STREAM;
    const protocol = posix.IPPROTO.TCP;
    const listener = posix.socket(address.any.family, tpe, protocol) catch {
        return InitError.SocketGenFail;
    };
    defer posix.close(listener);
}

pub fn start() !void {

}