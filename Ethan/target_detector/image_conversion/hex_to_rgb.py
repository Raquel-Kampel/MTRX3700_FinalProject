from PIL import Image

def hex_to_rgb(hex_value):
    """
    Convert a 12-bit hex pixel value (RGB 4-4-4) to 24-bit RGB (8-8-8)
    """
    r = (hex_value >> 8) & 0xF   # Red is the highest 4 bits
    g = (hex_value >> 4) & 0xF   # Green is the middle 4 bits
    b = hex_value & 0xF          # Blue is the lowest 4 bits

    # Convert from 4-bit to 8-bit
    r = r * 17
    g = g * 17
    b = b * 17

    return (r, g, b)

def hex_file_to_png(input_file, output_file, width, height, upscale_factor=2):
    """
    Convert a hex file (with 12-bit RGB values) into a PNG image and upscale it.

    Parameters:
        input_file (str): The path to the input hex file
        output_file (str): The path to save the output PNG image
        width (int): The width of the original image
        height (int): The height of the original image
        upscale_factor (int): The factor by which to upscale the image
    """
    img = Image.new("RGB", (width, height))
    pixels = img.load()

    with open(input_file, "r") as f:
        for y in range(height):
            for x in range(width):
                line = f.readline().strip()
                hex_value = int(line, 16)
                rgb = hex_to_rgb(hex_value)
                pixels[x, y] = rgb

    new_width = width * upscale_factor
    new_height = height * upscale_factor
    upscaled_img = img.resize((new_width, new_height), Image.NEAREST)
    upscaled_img.save(output_file)

# Convert the brightness-adjusted hex file to PNG
input_file = "hex_output/orange_image.hex"
output_file = "images/orange_image.png"
width = 320
height = 240
hex_file_to_png(input_file, output_file, width, height)

