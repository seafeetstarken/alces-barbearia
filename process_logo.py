import sys
import os

try:
    from PIL import Image
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
    from PIL import Image

def remove_background(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    datas = img.getdata()
    
    newData = []
    # Make black background transparent
    for item in datas:
        # Dark pixels with some tolerance
        if item[0] < 25 and item[1] < 25 and item[2] < 25:
            # Change alpha to 0
            newData.append((0, 0, 0, 0))
        else:
            newData.append(item)
            
    img.putdata(newData)
    img.save(output_path, "PNG")
    print(f"Saved transparent logo to {output_path}")

input_img = r"c:\Users\Juan\Documents\Projetos Starken\alces-barbearia\mobile\logo\logo.png"
output_img = r"c:\Users\Juan\Documents\Projetos Starken\alces-barbearia\mobile\assets\images\logo_transparent.png"

remove_background(input_img, output_img)
