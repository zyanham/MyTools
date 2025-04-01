#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/drivers/sensor.h>

int main(void)
{
    const struct device *mag_sensor = DEVICE_DT_GET_ONE(honeywell_hmc5883l);

    if (!device_is_ready(mag_sensor)) {
        printk("HMC5883L sensor not found!\n");
        return -1;
    }

    printk("HMC5883L sensor initialized successfully\n");

    while (1) {
        struct sensor_value magn_x, magn_y, magn_z;

        if (sensor_sample_fetch(mag_sensor)) {
            printk("Sensor sample fetch failed\n");
            continue;
        }

        sensor_channel_get(mag_sensor, SENSOR_CHAN_MAGN_X, &magn_x);
        sensor_channel_get(mag_sensor, SENSOR_CHAN_MAGN_Y, &magn_y);
        sensor_channel_get(mag_sensor, SENSOR_CHAN_MAGN_Z, &magn_z);

        printk("Magnetic Field [Gauss]: X=%f Y=%f Z=%f\n",
                sensor_value_to_double(&magn_x),
                sensor_value_to_double(&magn_y),
                sensor_value_to_double(&magn_z));

        k_sleep(K_MSEC(1000));
    }
    return 0;
}

