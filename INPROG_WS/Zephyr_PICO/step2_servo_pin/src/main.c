#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/drivers/pwm.h>
#include <zephyr/sys/printk.h>

static const struct pwm_dt_spec servo360 = PWM_DT_SPEC_GET(DT_ALIAS(servo360));
static const struct pwm_dt_spec servo180 = PWM_DT_SPEC_GET(DT_ALIAS(servo180));

#define FS90R_STOP PWM_USEC(1500)
#define FS90R_SLOW PWM_USEC(1550)
#define SG90_0DEG  PWM_USEC(500)
#define SG90_180DEG PWM_USEC(2500)

int main(void)
{
    if (!pwm_is_ready_dt(&servo360) || !pwm_is_ready_dt(&servo180)) {
        printk("PWM devices not ready\n");
        return -1;
    }

    printk("Starting dual servo control test\n");

    while (1) {
        /* FS90Rを5秒間ゆっくり回転させる */
        printk("FS90R slow rotation\n");
        pwm_set_pulse_dt(&servo360, FS90R_SLOW);
        k_sleep(K_SECONDS(5));

        /* FS90R停止 */
        printk("FS90R stop\n");
        pwm_set_pulse_dt(&servo360, FS90R_STOP);
        k_sleep(K_SECONDS(1));

        /* SG90を0度に */
        printk("SG90 moving to 0 degrees\n");
        pwm_set_pulse_dt(&servo180, SG90_0DEG);
        k_sleep(K_SECONDS(5));

        /* FS90Rを再度ゆっくり回転させる */
        printk("FS90R slow rotation\n");
        pwm_set_pulse_dt(&servo360, FS90R_SLOW);
        k_sleep(K_SECONDS(5));

        /* FS90R停止 */
        printk("FS90R stop\n");
        pwm_set_pulse_dt(&servo360, FS90R_STOP);
        k_sleep(K_SECONDS(1));

        /* SG90を180度に */
        printk("SG90 moving to 180 degrees\n");
        pwm_set_pulse_dt(&servo180, SG90_180DEG);
        k_sleep(K_SECONDS(5));
    }

    return 0;
}
