const finding = @import("finding.zig");
const std = @import("std"); // Re-order imports if needed or just ensure std is available

pub const ConsoleReporter = struct {
    
    pub fn report(findings: []finding.Finding) !void {
        const stdout = std.io.getStdOut().writer();
        
        if (findings.len == 0) {
            try stdout.print("\n✨ All good! No unfinished vibes found.\n", .{});
            return;
        }

        // Sort findings: Path (asc), then Line (asc)
        std.sort.block(finding.Finding, findings, {}, lessThan);

        try stdout.print("\nfound {} unfinished vibes:\n", .{findings.len});

        var current_path: ?[]const u8 = null;

        for (findings) |f| {
            const is_new_file = if (current_path) |path| !std.mem.eql(u8, path, f.location.path) else true;

            if (is_new_file) {
                try stdout.print("\n{s}\n", .{f.location.path});
                current_path = f.location.path;
            }

            // Indent finding under file
            try printSeverityBadge(stdout, f.severity);
            try stdout.print(" {s}: line {}\n", .{f.message, f.location.line});
            
            if (f.location.snippet) |s| {
                 try stdout.print("    | {s}\n", .{s});
            }
        }
        try stdout.print("\n", .{});
    }

    fn printSeverityBadge(writer: anytype, severity: finding.Severity) !void {
        switch (severity) {
            .critical => try writer.print("  [ERROR]", .{}),
            .warn =>  try writer.print("  [WARN] ", .{}), 
            .info =>  try writer.print("  [INFO] ", .{}),
        }
    }

    fn lessThan(context: void, lhs: finding.Finding, rhs: finding.Finding) bool {
        _ = context;
        // Sort by Path Ascending
        const path_cmp = std.mem.order(u8, lhs.location.path, rhs.location.path);
        if (path_cmp != .eq) {
            return path_cmp == .lt;
        }
        
        // Then by Line Ascending
        return lhs.location.line < rhs.location.line;
    }
};

pub const JsonReporter = struct {
    pub fn report(findings: []finding.Finding) !void {
        const stdout = std.io.getStdOut().writer();
        // Simple JSON serialization without a heavy serializer for now.
        // Or use std.json.stringify if possible. finding.Finding is simple enough.
        
        // Construct a wrapper object
        const JsonOutput = struct {
            findings: []finding.Finding,
            total: usize,
        };
        
        const output = JsonOutput{
            .findings = findings,
            .total = findings.len,
        };
        
        try std.json.stringify(output, .{ .whitespace = .indent_2 }, stdout);
        try stdout.print("\n", .{});
    }
};

pub const GitHubReporter = struct {
    pub fn report(findings: []finding.Finding) !void {
        const stdout = std.io.getStdOut().writer();
        // Format: ::severity file={path},line={line},col={col}::{message}
        // Mapping:
        // critical -> error
        // warn     -> warning
        // info     -> notice
        
        for (findings) |f| {
            const level = switch (f.severity) {
                .critical => "error",
                .warn => "warning",
                .info => "notice",
            };
            // Note: GitHub annotations don't officially support 'col', but we can put it in the message or omit it. 
            // Actually 'col' parameter exists in some versions but 'col' property in the file= options string is supported.
            // Format: ::error file={name},line={line},endLine={endLine},title={title}::{message}
            if (f.location.snippet) |snippet| {
                try stdout.print("::{s} file={s},line={},title={s}::{s} | {s}\n", 
                    .{level, f.location.path, f.location.line, f.message, f.message, snippet});
            } else {
                try stdout.print("::{s} file={s},line={},title={s}::{s}\n", 
                    .{level, f.location.path, f.location.line, f.message, f.message});
            }
        }
    }
};
