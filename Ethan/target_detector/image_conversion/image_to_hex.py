from PIL import Image

# Open an image file
img = Image.open('images/basketball-buying-guide.jpg').convert('RGB')  # Ensure the image is in RGB format

# Resize to fit your BRAM size, for example, 320x240
img = img.resize((320, 240))

# Convert image to 12-bit RGB (4 bits for each channel)
def rgb_to_12bit(r, g, b):
    r_4bit = (r >> 4) & 0xF
    g_4bit = (g >> 4) & 0xF
    b_4bit = (b >> 4) & 0xF
    return (r_4bit << 8) | (g_4bit << 4) | b_4bit

# Generate .hex or .mif content
with open('image_data.hex', 'w') as f:
    for y in range(img.height):
        for x in range(img.width):
            r, g, b = img.getpixel((x, y))
            pixel_12bit = rgb_to_12bit(r, g, b)
            f.write(f'{pixel_12bit:03X}\n')  # Write pixel data in hexadecimal format
