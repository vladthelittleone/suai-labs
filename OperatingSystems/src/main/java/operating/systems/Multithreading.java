package operating.systems;

import java.util.concurrent.*;

import static java.lang.String.format;

/**
 * package: operating.systems
 * date: 18.03.15
 *
 * Операционные системы и сети. СПБ ГУАП.
 * Лабороторная № 2.
 * Вариант №15.
 * Выбрать граф запуска потоков соответственно варианту задания.
 * Реализовать последовательно-параллельный запуск потоков в ОС Windows с
 * использованием средств синхронизации. Вершины графа – точки
 * запуска/завершения потоков, дуги – потоки. В графе необходимо
 * самостоятельно выделить три группы потоков. Первая группа не
 * синхронизирована, вторая – синхронизирована мьютексом (захватывает
 * мьютекс на время выполнения), третья – синхронизирована семафорами
 * (передает управление другому потоку после каждой итерации).
 *
 * @author Skurishin Vladislav
 */
public class Multithreading
{
    private static final int MAX_AVAILABLE = 3;

    private static ExecutorService executorService = Executors.newCachedThreadPool();

    // Fair семафор
    private static final Semaphore semaphore = new Semaphore(MAX_AVAILABLE, true);

    public static void main(String[] args)cd
    {
        Future<?> a = executorService.submit(new SimpleRunnableTask("A"));
        Future<?> d = executorService.submit(new SimpleRunnableTask("D"));

        // Блокировка
        try
        {
            a.get();

            // Запуск второй волны потоков.
            Future<?> h = executorService.submit(new SimpleRunnableTask("H"));
            Future<?> g = executorService.submit(new SimpleRunnableTask("G"));
            Future<?> b = executorService.submit(new SimpleRunnableTask("B"));
            Future<?> c = executorService.submit(new SimpleRunnableTask("C"));

            getOrWait(d);

            Future<?> n = executorService.submit(new SimpleRunnableTask("N"));

            getOrWait(g, b, c);

            // Запуск третьей волны.
            Future<?> k = executorService.submit(new SemaphoreRunnableTask("K", semaphore));
            Future<?> i = executorService.submit(new SemaphoreRunnableTask("I", semaphore));
            Future<?> f = executorService.submit(new SemaphoreRunnableTask("F", semaphore));
            Future<?> e = executorService.submit(new SimpleRunnableTask("E"));

            getOrWait(h);

            // Запуск потока M.
            Future<?> m = executorService.submit(new SemaphoreRunnableTask("M", semaphore));

            getOrWait(m, e);

            Future<?> p = executorService.submit(new SimpleRunnableTask("P"));
        }
        catch (InterruptedException | ExecutionException e)
        {
            System.err.println("Error in main thread.");
        }
        finally
        {
            // Выключение сервиса запуска.
            executorService.shutdown();
        }
    }

    // Util метод
    private static void getOrWait(Future<?>... futures) throws ExecutionException, InterruptedException
    {
        for (Future f : futures)
        {
            f.get();
        }
    }

    private static class SimpleRunnableTask implements Runnable
    {
        private String name;

        public SimpleRunnableTask(String name)
        {
            this.name = name;
        }

        @Override
        public void run()
        {
            System.out.println(format("Execute thread: %s", name));
            try
            {
                Thread.sleep(1000L);
            }
            catch (InterruptedException e)
            {
                System.err.println("Some problems with executing.");
            }
        }
    }

    private static class SemaphoreRunnableTask implements Runnable
    {
        private Semaphore semaphore;
        private String name;

        public SemaphoreRunnableTask(String name, Semaphore semaphore)
        {
            this.name = name;
            this.semaphore = semaphore;
        }

        @Override
        public void run()
        {
            System.out.println(format("Execute thread: %s", name));
            try
            {
                // Берем семафор
                semaphore.acquire();

                Thread.sleep(1000L);

            }
            catch (InterruptedException e)
            {
                System.err.println("Some problems with executing.");
            }
            finally
            {
                // Освобождаем семафор
                semaphore.release();
            }
        }
    }
}
