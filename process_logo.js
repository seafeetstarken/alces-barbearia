const { Jimp } = require('jimp');

async function removeBackground() {
  try {
    const inputPath = 'mobile/logo/logo.png';
    const outputPath = 'mobile/assets/images/logo.png';
    
    // Ler a imagem
    const image = await Jimp.read(inputPath);
    
    // Loop pelos pixels
    image.scan(0, 0, image.bitmap.width, image.bitmap.height, function(x, y, idx) {
      const r = this.bitmap.data[idx];
      const g = this.bitmap.data[idx + 1];
      const b = this.bitmap.data[idx + 2];
      
      if (r < 25 && g < 25 && b < 25) {
        this.bitmap.data[idx + 3] = 0;
      }
    });

    image.write(outputPath);
    console.log('Fundo preto removido e imagem transparente gerada com sucesso em: ' + outputPath);
  } catch (error) {
    console.error('Erro ao processar imagem:', error);
  }
}

removeBackground();
