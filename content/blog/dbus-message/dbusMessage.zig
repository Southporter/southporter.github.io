const dbus = @cImport({
    @cInclude("dbus/dbus.h");
});

pub fn main() void {
    const conn = dbus.dbus_bus_get(dbus.DBUS_BUS_SESSION, null);
    if (conn == null) {
        std.debug.print("Could not open a connection\n", .{});
        return;
    }
    defer dbus.dbus_connection_unref(conn);

    const message = dbus.dbus_message_new_method_call(
        // The service name
        "org.freedesktop.Notifications",
        // The object path
        "/org/freedesktop/Notifications",
        // The interface
        "org.freedesktop.Notifications",
        // and the method
        "Notify",
    );

    var root_raw: dbus.DBusMessageIter = undefined;
    const root = &root_raw;
    dbus.dbus_message_iter_init_append(message, root);

    const app_name: [:0]const u8 = "App Name";
    var success = dbus.dbus_message_iter_append_basic(root, dbus.DBUS_TYPE_STRING, @ptrCast(&app_name));
    var no_replace: u32 = 0;
    success = dbus.dbus_message_iter_append_basic(root, dbus.DBUS_TYPE_UINT32, &no_replace);
    const icon: [:0]const u8 = "";
    success = dbus.dbus_message_iter_append_basic(root, dbus.DBUS_TYPE_STRING, @ptrCast(&icon.ptr));
    // You can also pass the string constants in directly
    success = dbus.dbus_message_iter_append_basic(root, dbus.DBUS_TYPE_STRING, @ptrCast(&"Summary"));
    success = dbus.dbus_message_iter_append_basic(root, dbus.DBUS_TYPE_STRING, @ptrCast(&"Description"));

    {
        var action_iter: dbus.DBusMessageIter = undefined;
        success = dbus.dbus_message_iter_open_container(root, dbus.DBUS_TYPE_ARRAY, "s", &action_iter);
        defer _ = dbus.dbus_message_iter_close_container(root, &action_iter);

        const actions = [_][*]const u8{
            "action",
            "Some Action",
        };

        for (actions) |action| {
            success = dbus.dbus_message_iter_append_basic(&action_iter, dbus.DBUS_TYPE_STRING, @ptrCast(&action));
        }
    }

    {
        // Open the container for all hints.
        var hints_iter: dbus.DBusMessageIter = undefined;
        success = dbus.dbus_message_iter_open_container(root, dbus.DBUS_TYPE_ARRAY, "{sv}", &hints_iter);
        defer _ = dbus.dbus_message_iter_close_container(root, &hints_iter);

        {
            // This container holds one hint entry. If you were adding many hints this would probably
            // be inside a loop
            var hint_iter: dbus.DBusMessageIter = undefined;
            success = dbus.dbus_message_iter_open_container(&hints_iter, dbus.DBUS_TYPE_DICT_ENTRY, null, &hint_iter);
            defer _ = dbus.dbus_message_iter_close_container(&hints_iter, &hint_iter);

            success = dbus.dbus_message_iter_append_basic(&hint_iter, dbus.DBUS_TYPE_STRING, @ptrCast(&"urgency"));

            {
                // A variant is apparently a container 🤷
                // Notice that we specify the contents with the type string "y" indicating a byte.
                var variant_iter: dbus.DBusMessageIter = undefined;
                success = dbus.dbus_message_iter_open_container(&hint_iter, dbus.DBUS_TYPE_VARIANT, "y", &variant_iter);
                defer _ = dbus.dbus_message_iter_close_container(&hint_iter, &variant_iter);

                var val = dbus.DBusBasicValue{
                    .byt = 1, // Normal urgency
                };
                _ = dbus.dbus_message_iter_append_basic(&variant_iter, dbus.DBUS_TYPE_BYTE, @ptrCast(&val));
            }
        }
    }
    var expire_timeout: i32 = -1; // Default timeout
    success = dbus.dbus_message_iter_append_basic(root, dbus.DBUS_TYPE_INT32, &expire_timeout);

    var err: Error = undefined;
    dbus.dbus_error_init(@ptrCast(&err));

    if (dbus.dbus_error_is_set(@ptrCast(&err)) == dbus.TRUE) {
        std.debug.print("Error connecting: {s}\n==\n{s}\n", .{ std.mem.span(err.name), std.mem.span(err.message) });
    }

    const reply = dbus.dbus_connection_send_with_reply_and_block(conn, message, dbus.DBUS_TIMEOUT_USE_DEFAULT, @ptrCast(&err));
    // Null check and value capture
    if (reply) |msg| {
        var id: dbus.DBusBasicValue = undefined;
        success = dbus.dbus_message_get_args(msg, null, dbus.DBUS_TYPE_UINT32, &id, dbus.DBUS_TYPE_INVALID);
        std.debug.print("Notification ID: {}\n", .{id.u32});
    } else {
        std.debug.print("Error sending: {s}\n==\n{s}\n", .{ std.mem.span(err.name), std.mem.span(err.message) });
    }
}

const Error = extern struct {
    name: [*c]const u8,
    message: [*c]const u8,
    dummy1: c_uint,
    padding1: *opaque {},
};

const std = @import("std");
