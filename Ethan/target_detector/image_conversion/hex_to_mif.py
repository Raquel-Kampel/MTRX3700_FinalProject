def convert_to_mif(input_file, output_file, depth=76800, width=12):
    with open(input_file, "r") as f, open(output_file, "w") as out:
        # Write the MIF header
        out.write(f"-- Memory Initialization File (.mif)\n\n")
        out.write(f"WIDTH={width};\n")
        out.write(f"DEPTH={depth};\n\n")
        out.write(f"ADDRESS_RADIX=HEX;\n")
        out.write(f"DATA_RADIX=HEX;\n\n")
        out.write("CONTENT BEGIN\n")
        
        address = 0
        for line in f:
            data_str = line.strip()
            if len(data_str) != 3:  # Ensure it's 12-bit (3 characters)
                continue  # Invalid line length, skip it

            # Write address-data pairs to the MIF file
            out.write(f"    {address:04X} : {data_str.upper()};\n")
            address += 1

            # Stop if we exceed the maximum depth
            if address >= depth:
                break

        # End the MIF file
        out.write("END;\n")

# Convert your plain hex file to MIF format
convert_to_mif("image_data.hex", "image_data.mif")
