package com.fireflydesign.fireflydevice;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class FDTimerFactory {

    class FDTimerImpl extends FDTimer implements Runnable {

        ScheduledFuture<?> future;

        FDTimerImpl(FDTimer.Delegate invocation, double timeout, FDTimer.Type type) {
            super(invocation, timeout, type);

            Runnable command = this;
            long delay = (long) (timeout * 1000);
            if (type == Type.OneShot) {
                future = executor.schedule(command, delay, TimeUnit.MILLISECONDS);
            } else {
                future = executor.scheduleAtFixedRate(command, delay, delay, TimeUnit.MILLISECONDS);
            }
        }

        public void run() {
            if (enabled) {
                executorService.execute(new Runnable() {
                    @Override
                    public void run() {
                        invocation.timerFired();
                    }
                });
            }
        }

    }

    ScheduledThreadPoolExecutor executor;
    ExecutorService executorService;

    public FDTimerFactory(ExecutorService executorService) {
        executor = new ScheduledThreadPoolExecutor(1);
        this.executorService = executorService;
    }

    public FDTimer makeTimer(FDTimer.Delegate invocation, double timeout, FDTimer.Type type) {
        return new FDTimerImpl(invocation, timeout, type);
    }

}
