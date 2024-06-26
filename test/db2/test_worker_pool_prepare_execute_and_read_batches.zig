const std = @import("std");
const testing = std.testing;
const allocator = testing.allocator;

const zodbc = @import("zodbc");
const odbc = zodbc.odbc;

test "can execute a prepared statement and fetch a cursor" {
    const env = try zodbc.testing.environment();
    defer env.deinit();

    var pool = try zodbc.WorkerPool.init(
        allocator,
        env,
        .{ .n_workers = 2 },
    );
    defer pool.deinit();
    const db2_driver = try std.process.getEnvVarOwned(allocator, "DB2_DRIVER");
    defer allocator.free(db2_driver);
    const con_str = try std.fmt.allocPrint(
        allocator,
        "Driver={s};Hostname={s};Database={s};Port={d};Uid={s};Pwd={s};",
        .{
            db2_driver,
            "localhost",
            "testdb",
            50_000,
            "db2inst1",
            "password",
        },
    );
    defer allocator.free(con_str);
    try pool.connectWithString(con_str);

    try pool.prepare("SELECT * FROM SYSIBM.SYSTABLES");
    try pool.execute();

    // const reader = pool.batchReader();
    // var n_rows: usize = 0;
    // while (reader.next()) |rowset| {
    //     for (rowset.items()) |row| {
    //         n_rows += 1;
    //         try testing.expectEqualStrings("", row[0].name);
    //     }
    // }
    // try testing.expect(n_rows > 0);
}
