#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/drivers/pwm.h>

#define SERVO_NODE DT_NODELABEL(servo)

static const struct pwm_dt_spec servo = PWM_DT_SPEC_GET(SERVO_NODE);

int main(void)
{
    if (!device_is_ready(servo.dev)) {
        printk("PWM device not ready\n");
        return -1;
    }

    printk("Servo control started\n");

    while (1) {
        printk("Servo 0 degree\n");
        pwm_set_pulse_dt(&servo, PWM_USEC(500));   // 0°
        k_sleep(K_SECONDS(2));

        printk("Servo 90 degree\n");
        pwm_set_pulse_dt(&servo, PWM_USEC(1500));  // 90°
        k_sleep(K_SECONDS(2));

        printk("Servo 180 degree\n");
        pwm_set_pulse_dt(&servo, PWM_USEC(2500));  // 180°
        k_sleep(K_SECONDS(2));
    }
}

