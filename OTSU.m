function J=OTSU(I)

Hi=imhist(I);           %ֱ��ͼ

sum1=sum(Hi);
for i=1:255
    w1=sum(Hi(1:i))/sum1;           %��һ�����          ǰ�����ص���ռ����ͼ��ı���Ϊw1
    w2=sum(Hi((i+1):256))/sum1;     %�ڶ������          �������ص���ռ����ͼ��ı���Ϊw2
      
    m1=(0:(i-1))*Hi(1:i)/sum(Hi(1:i));          %��һ��ƽ���Ҷ�ֵ
    m2=(i:255)*Hi((i+1):256)/sum(Hi((i+1):256));%�ڶ���ƽ���Ҷ�ֵ
    
    Jw(i)=w1*w2*(m1-m2)^2;                                 %������䷽��Jw������ֵT             
end

[maxm,thresh]=max(Jw);      %Ѱ����ֵ

figure,subplot(2,2,1);imshow(I);title('ԭͼ��');
subplot(2,2,[3,4]);imhist(I);hold on;plot(thresh,3,'+r');title((strcat('��ֵΪ',num2str(thresh))));

I(find(I<=thresh))=0;      
I(find(I>thresh))=256;       %��ֵ��
J=I;
subplot(2,2,2),imshow(I),title('��ֵ��ͼ��zk');

