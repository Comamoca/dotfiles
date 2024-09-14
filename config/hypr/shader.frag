precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float temperature;
uniform float temperatureStrength;

// convert color temperature to RGB
vec3 temperatureToRGB(float temperature) {
    temperature /= 100.0;

    float red, green, blue;

    if (temperature <= 66.0) {
        red = 255.0;
        green = temperature;
        green = 99.4708025861 * log(green) - 161.1195681661;

        if (temperature <= 19.0) {
            blue = 0.0;
        } else {
            blue = temperature - 10.0;
            blue = 138.5177312231 * log(blue) - 305.0447927307;
        }
    } else {
        red = temperature - 60.0;
        red = 329.698727446 * pow(red, -0.1332047592);
        green = temperature - 60.0;
        green = 288.1221695283 * pow(green, -0.0755148492);
        blue = 255.0;
    }

    return vec3(clamp(red / 255.0, 0.0, 1.0), clamp(green / 255.0, 0.0, 1.0), clamp(blue / 255.0, 0.0, 1.0));
}

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);

    // color temperature
    float temperature = 1800.0; 

    // Strength of color temperature correction
    float temperatureStrength = 0.38; 

    // Get RGB correction value corresponding to color temperature
    vec3 temperatureRGB = temperatureToRGB(temperature);

    // Interpolate between the original color and color temperature correction value
    pixColor.rgb = mix(pixColor.rgb, pixColor.rgb * temperatureRGB, temperatureStrength);

    // Clamp the color (keep it in the range 0.0 - 1.0)
    pixColor = clamp(pixColor, 0.0, 1.0);

    gl_FragColor = pixColor;
}
