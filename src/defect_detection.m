clear all
close all
image = im2double(imread('../data/defect.png'));
figure,imshow(image)
result = dehaze_fast(image, 0.95, 15);
% load('final_defect.mat')
figure,imshow(result);%imwrite(bw_result,'../result/1.png');
I = rgb2gray(result); figure,imshow(I);
% I1 = imadjust(I,stretchlim(I),[0,1]); figure;imshow(I1);
[N,M] = size(I);
 
% h = [0.125,0.375,0.375,0.125];
% g = [0.5,-0.5];
h = [0.1,0.25,0.75,0.25,0.1];
g = [0.5,0,-0.5];
delta = [1,0,0];
 
J = 3;
a(1:N,1:M,1,1:J+1) = 0;
dx(1:N,1:M,1,1:J+1) = 0;
dy(1:N,1:M,1,1:J+1) = 0;
d(1:N,1:M,1,1:J+1) = 0;
 
a(:,:,1,1) = conv2(h,h,I,'same');
dx(:,:,1,1) = conv2(delta,g,I,'same');
dy(:,:,1,1) = conv2(g,delta,I,'same');
 
x = dx(:,:,1,1);
y = dy(:,:,1,1);
d(:,:,1,1) = sqrt(x.^2+y.^2);
% I1 = imadjust(d(:,:,1,1),stretchlim(d(:,:,1,1)),[0 1]);figure;imshow(I1);
 
lh = length(h);
lg = length(g);
 
for j = 1:J+1
  lhj = 2^j*(lh-1)+1;
  lgj = 2^j*(lg-1)+1;
  hj(1:lhj)=0;
  gj(1:lgj)=0;
  for n = 1:lh
    hj(2^j*(n-1)+1)=h(n);
  end
 
  for n = 1:lg
    gj(2^j*(n-1)+1)=g(n);
  end
  
  a(:,:,1,j+1) = conv2(hj,hj,a(:,:,1,j),'same');
  dx(:,:,1,j+1) = conv2(delta,gj,a(:,:,1,j),'same');
  dy(:,:,1,j+1) = conv2(gj,delta,a(:,:,1,j),'same');
 
  x = dx(:,:,1,j+1);
  y = dy(:,:,1,j+1);
  dj(:,:,1,j+1) = sqrt(x.^2+y.^2);
 
%   I1 = imadjust(dj(:,:,1,j+1),stretchlim(dj(:,:,1,j+1)),[0 1]);figure;imshow(I1);
end
t=2;
img_re=dj(:,:,1,t);
I1 = imadjust(dj(:,:,1,t),stretchlim(dj(:,:,1,t)),[0 1]);
figure;imshow(I1);
edge_result=edge(img_re,'canny',0.05);
edge_result(1:2*t+1,:)=0;edge_result(end-2*t-1:end,:)=0;edge_result(:,1:2*t+1)=0;edge_result(:,end-2*t-1:end)=0;
figure,imshow(edge_result),title('edge detection');
se = strel('disk',1);dilatedEdge=imdilate(edge_result,se,5);
%figure,imshow(dilatedEdge);
filledEdge=imfill(dilatedEdge,'holes');%figure,imshow(filledEdge);
se = strel('sphere',2);erodedEdge=imerode(filledEdge,se);%figure,imshow(erodedEdge);
L = bwlabeln(erodedEdge, 8);S = regionprops(L, 'Area');bw_result = ismember(L, find([S.Area] >= 100));
figure,imshow(bw_result),imwrite(bw_result,'../result/result.png');