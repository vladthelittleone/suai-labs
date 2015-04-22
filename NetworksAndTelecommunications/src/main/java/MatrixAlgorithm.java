import java.util.Arrays;

import static java.lang.String.format;

/**
 * @author Skurishin Vladislav
 * @since 16.04.15
 */
public class MatrixAlgorithm
{
    private static int inf = Integer.MAX_VALUE;

    private static int matrix[][] = {
            {0, inf, inf, inf, 60},
            {inf, 0, 10, inf, inf},
            {25, 10, 0, 15, 30},
            {inf, inf, inf, 0, 20},
            {60, inf, 30, 20, 0}
    };

    public static void main(String[] args)
    {
        int i = 6;
        int j = i % 7;
        int N = 5 + i % 3;
        int I = (i + 1) % N;


        System.out.println(format("i = %d", i));
        System.out.println(format("j = %d", j));
        System.out.println(format("N = %d", N));
        System.out.println(format("I = %d", I));

        System.out.println();
        System.out.println("Matrix:");
        print(matrix);

        int[][] D = compute(matrix, N);

        floyd(matrix, D, N);
    }

    private static void floyd(int[][] m, int[][] D, int N)
    {
        int s = m.length;
        int r[][] = new int[s][s];
        int G[][] = Arrays.copyOf(m, s);

        for (int i = 0; i < s; i++)
        {
            G[i][i] = inf;
        }

        for (int i = 0; i < s; i++)
        {
            for (int j = 0; j < s; j++)
            {
                r[i][j] = kMin(D, G, N, i, j);

                if (i == j)
                {
                    r[i][j] = -1;
                }
            }
        }

        System.out.println();
        System.out.println("Floyd matrix:");

        print(r);
    }

    private static int[][] compute(int[][] m, int N)
    {
        int res[][] = m;
        int rang = 1;

        while (true)
        {
            int next[][] = getNextRangeMatrix(m, res, N);

            System.out.println();
            System.out.println(format("Matrix with range %d", rang++));

            print(next);

            if (Arrays.deepEquals(res, next))
            {
                return next;
            }

            res = next;
        }
    }

    private static int[][] getNextRangeMatrix(int[][] m, int[][] mr, int N)
    {
        int r[][] = new int[m.length][m.length];

        for (int i = 0; i < m.length; i++)
        {
            for (int j = 0; j < m.length; j++)
            {
                r[i][j] = min(m, mr, N, i, j);
            }
        }

        return r;
    }

    private static int min(int[][] m1, int[][] mr, int N, int i, int j)
    {
        int min = inf;

        for (int k = 0; k < N; k++)
        {
            if (mr[i][k] == inf || m1[k][j] == inf) continue;
            min = Math.min(min, mr[i][k] + m1[k][j]);
        }

        return min;
    }

    private static int kMin(int[][] m1, int[][] mr, int N, int i, int j)
    {
        int res = -1;
        int min = inf;

        for (int k = 0; k < N; k++)
        {
            if (mr[i][k] == inf || m1[k][j] == inf) continue;

            int current = Math.min(min, mr[i][k] + m1[k][j]);

            if (min != current)
            {
                min = current;
                res = k;
            }
        }

        return res;
    }

    private static void print(int[][] m)
    {
        for (int[] aM : m)
        {
            for (Integer el : aM)
            {
                if (el == inf)
                {
                    System.out.print("inf ");
                }
                else
                {
                    System.out.print(format("%d ", el));
                }
            }

            System.out.println();
        }
    }
}
