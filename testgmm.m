im=imread('F:\Workplace\matlab\Datasets\dataset-tb100\Basketball\img\0001.jpg');
im1=rgb2gray(im);
imshow(im1)
varargout = gmm(im1, 2);