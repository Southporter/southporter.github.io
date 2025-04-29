const dbus = @cImport({
    @cInclude("dbus/dbus.h");
});

pub fn main() void {
    const conn = dbus.dbus_bus_get(dbus.DBUS_BUS_SESSION, null);
    defer dbus.dbus_connection_unref(conn);

    const message = dbus.dbus_message_new_method_call(
        // The service name
        "org.freedesktop.Notifications",
        // The object path
        "/org/freedesktop/Notification",
        // The interface
        "org.freedesktop.Notifications",
        // and the method
        "Notify",
    );

    const root = dbus.dbus_message_iter_init_append(message, null);

    var success = dbus.dbus_message_iter_append_basic(root, dbus.DBUS_TYPE_STRING, "App Name");
    success = dbus.dbus_message_iter_append_basic(root, dbus.DBUS_TYPE_UINT32, &0);
    success = dbus.dbus_message_iter_append_basic(root, dbus.DBUS_TYPE_STRING, "");
    success = dbus.dbus_message_iter_append_basic(root, dbus.DBUS_TYPE_STRING, "Summary");
    success = dbus.dbus_message_iter_append_basic(root, dbus.DBUS_TYPE_STRING, "Description");

    const actions: [][*:0]const u8 = &.{
        "action",
        "Some Action",
    };
    success = dbus.dbus_message_iter_append_fixed_array(root, dbus.DBUS_TYPE_STRING, actions.ptr, actions.len);

    {}

    const reply = dbus.dbus_connection_send_with_reply_and_block(conn, message, 500, null);
    _ = reply;
}
