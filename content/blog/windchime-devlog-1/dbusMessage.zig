const dbus = @cImport({
    @cInclude("dbus/dbus.h");
});

pub fn main() void {
    const conn = dbus.dbus_bus_get(dbus.DBUS_BUS_SESSION, null);

    const rule: [*:0]const u8 = "type='signal',interface='org.freedesktop.Notifications'";
    dbus.dbus_bus_add_match(conn, rule, null);

    const message = dbus.dbus_message_new_method_call("com.freedesktop.Notifications", "/com/freedesktop/Notification", "com.freedesktop.Notifications", "Notify");

    const reply = dbus.dbus_connection_send_with_reply_and_block(conn, message, 500, null);
    _ = reply;
}
