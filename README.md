# OAC_2018_2_LAB_1
Uma imagem BITMAP (.bmp), é um arquivo de formato binário, onde 54bytes iniciais consitem o cabeçalho com suas propriedades a serem lidas por programas de visualização de imagens ou para operações que necessitem alterar as propriedades da imagem como tamanho do pixel, tabela de cor (caso de pixel de 24bits), recorte, entre outras. No nosso caso faremos operações morfológicas na imagem, portanto nenhuma alteração é necessária no cabeçalho da imagem. O programa desenvolvido opera com imagens de tamanho 512x512, o formato .bmp guarda as componentes de cor RGB em 3bytes, portanto o tamanho ocupado pelo vetor de cores (cada 3 correspondendo a um pixel) é dado por: 512x512x3 = 786432bytes. Somando este valor ao cabeçalho temos o tamanho total do arquivo (em bytes): 786432 + 54 = 786486bytes
A literatura acerca do assunto é bem extensa e de fácil acesso, para o desenvolvimento do software foram consultadas as teorias descritas na documentação da biblioteca OpenCV, do livro Applied pattern recognition: algorithms and implementation in C++.

Desenvolve-se então uma ferramenta em assembly MIPS para processamento de imagens

## Grayscale
![grayscale](https://i.imgur.com/3veRogh.png)

## Treshold
![Threshold](https://imgur.com/j6vCBqS.png)

## Gaussian Blur
![gaussian](https://imgur.com/NOURj44.png)
