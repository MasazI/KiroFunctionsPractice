/**
 * 月次処理の所要時間を机上で試算する（ADR-0001 の技術検証の前に使う）。
 *
 * 使い方：java tools/MonthlyEstimate.java <総件数> <1チャンクの件数> <1チャンクの処理秒数> <同時に動かす数>
 * 例：    java tools/MonthlyEstimate.java 1000000 1000 120 20
 *
 * キューでの待ち、起動、再実行の時間は含まない。実際の時間は技術検証で測る。
 */
public class MonthlyEstimate {

    /** 要件：4時間以内に処理する */
    private static final long DEADLINE_SECONDS = 4L * 60 * 60;

    /** 標準の AWS Lambda 関数のタイムアウトの上限（900秒） */
    private static final long LAMBDA_MAX_SECONDS = 15L * 60;

    private static final String USAGE =
            "使い方：java tools/MonthlyEstimate.java <総件数> <1チャンクの件数> <1チャンクの処理秒数> <同時に動かす数>";

    public static void main(String[] args) {
        if (args.length != 4) {
            System.err.println(USAGE);
            System.exit(2);
        }

        long totalRecords = parsePositive(args[0], "総件数");
        long recordsPerChunk = parsePositive(args[1], "1チャンクの件数");
        long secondsPerChunk = parsePositive(args[2], "1チャンクの処理秒数");
        long concurrency = parsePositive(args[3], "同時に動かす数");

        long chunks = ceilDiv(totalRecords, recordsPerChunk);
        long rounds = ceilDiv(chunks, concurrency);
        long totalSeconds = rounds * secondsPerChunk;

        System.out.printf("チャンクの数：%d%n", chunks);
        System.out.printf("全体の処理時間：%s（期限 4時間）→ %s%n",
                format(totalSeconds), totalSeconds <= DEADLINE_SECONDS ? "収まる" : "収まらない");
        System.out.printf("1チャンクの処理時間：%s（標準の Lambda の上限 15分）→ %s%n",
                format(secondsPerChunk), secondsPerChunk <= LAMBDA_MAX_SECONDS ? "収まる" : "収まらない");
        System.out.println("注意：キューでの待ち、起動、再実行の時間は含みません。");
    }

    private static long parsePositive(String value, String name) {
        try {
            long parsed = Long.parseLong(value);
            if (parsed <= 0) {
                throw new NumberFormatException();
            }
            return parsed;
        } catch (NumberFormatException e) {
            System.err.printf("%sには1以上の整数を指定してください：%s%n", name, value);
            System.err.println(USAGE);
            System.exit(2);
            return 0;
        }
    }

    private static long ceilDiv(long numerator, long denominator) {
        return (numerator + denominator - 1) / denominator;
    }

    private static String format(long seconds) {
        long hours = seconds / 3600;
        long minutes = (seconds % 3600) / 60;
        long rest = seconds % 60;
        return String.format("%d時間%02d分%02d秒", hours, minutes, rest);
    }
}
