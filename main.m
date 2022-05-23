clc
close all
I=imread('car5.jpg');
figure,subplot(2,2,1);imshow(I), title('ԭʼͼ��');
I_gray=rgb2gray(I);
subplot(2,2,2),imshow(I_gray),title('�Ҷ�ͼ��');
%======================   ��̬ѧԤ���� ======================
I_edge=edge(I_gray,'sobel');
subplot(2,2,3),imshow(I_edge),title('��Ե����ͼ��');
se=[1;1;1]; 
I_erode=imerode(I_edge,se);   
subplot(2,2,4),imshow(I_erode),title('��ʴ���Եͼ��');
se=strel('rectangle',[25,25]);  
I_close=imclose(I_erode,se);            %ͼ��պϡ����ͼ��
figure,subplot(1,2,1),imshow(I_close),title('����ͼ��');
I_final=bwareaopen(I_close,2000);       %ȥ�����ŻҶ�ֵС��2000�Ĳ���
subplot(1,2,2),imshow(I_final),title('��̬�˲���ͼ��');               %�õ������˲���ͼ��I_final
%==========================   ���Ʒָ�    =============================

I_new=zeros(size(I_final,1),size(I_final,2));                         %����I_final��*I_fianl�е�0����I_new
location_of_1=[];
for i=1:size(I_final,1)                 %Ѱ�Ҷ�ֵͼ���а׵ĵ��λ��,��ֵͼ������ص�ĻҶ�ֵΪ0����255��ֻ�к�ɫ0��ɫ255
    for j=1:size(I_final,2)
           if I_final(i,j)==1;                                           %���Ϊ��ɫ
            newlocation=[i,j];
            location_of_1=[location_of_1;newlocation];                %���׵�������
        end
    end
end
mini=inf;maxi=0;                                                      
for i=1:size(location_of_1,1)       %Ѱ�����а׵��У�x������y����ĺ������С���������λ��
    temp=location_of_1(i,1)+location_of_1(i,2);                        %�м���
    if temp<mini
        mini=temp;
        a=i;
    end
    if temp>maxi
        maxi=temp;
        b=i;
    end
end
first_point=location_of_1(a,:);        %����С�ĵ�Ϊ���Ƶ����Ͻ�
last_point=location_of_1(b,:);         %�����ĵ�Ϊ���Ƶ����½�
x1=first_point(1)+4;                   %����ֵ����
x2=last_point(1)-4;
y1=first_point(2)+4;                                               
y2=last_point(2)-4;
I_plate=I(x1+5:x2-5,y1+5:y2-6);                                    %IΪԭʼͼ��
I_plate=OTSU(I_plate);                 %��OTSU�㷨�Էָ���ĳ��ƽ�������Ӧ��ֵ������,����OTSU����
I_plate=bwareaopen(I_plate,50);                                    %ɾ����ֵͼ�������С��50�Ķ���
figure,imshow(I_plate),title('������ȡ')%�������ճ���
%=========================   �ַ��ָ�   ============================

X=[];                               %�������ˮƽ�ָ��ߵĺ�����
flag=0;
for j=1:size(I_plate,2)                                            
    sum_y=sum(I_plate(:,j));
    if logical(sum_y)~=flag         %�к��б仯ʱ����¼�´��У�       �ж϶�ֵͼ���в�Ϊ0
        X=[X j];                                                   %����Ϊ0�洢��X������
        flag=logical(sum_y);                                       %logical()��������0Ԫ�صı�Ϊ1��ֻ����0��1��Ԫ������
    end
end
figure;                                                            
for n=1:7                                                           %������7λ��
    char=I_plate(:,X(2*n-1):X(2*n)-1);  %���дַָ�
    for i=1:size(char,1)                %������forѭ���Էָ��ַ������½��вü�
        if sum(char(i,:))~=0                                        %�������жϳ���Ϊ0�����λ�ã���ɫ��λ��top             
            top=i;
            break
        end
    end
    
    for i=1:size(char,1)
        if sum(char(size(char,1)-i,:))~=0                           %�������жϳ���Ϊ0��ʼλ�ã���ɫ��λ��buttom
            bottom=size(char,1)-i;
            break
        end
    end
    char=char(top:bottom,:);                                            
    subplot(2,7,n);imshow(char),title(n);                           %��ʾ2��7���Ϸָ���·ָ�Ľ��
    char=imresize(char,[32,16],'nearest');      %��һ��Ϊ32*16�Ĵ�С���Ա�ģ��ƥ�䣬��ͼ��Ŵ�32*16��С���
    eval(strcat('Char_',num2str(n),'=char;'));  %���ָ���ַ�����Char_i�У�eval()�������ַ���ת��Ϊ��ִ�е����
end
%==========================  �ַ�ʶ��   =============================
char=[];
store1=strcat('�����弽���ɼ�������������³ԥ�������������¸���ع���������³��'); %����ģ��
 for j=1:34
        Im=Char_1;
        Template=imread(strcat('chinese\',num2str(j),'.bmp')); %����ʶ��num2str����ֵת��Ϊ�ַ���
        Template=im2bw(Template);                              %im2bw()��ͼ��ת��Ϊ��ֵͼ��
        Differ=Im-Template;                                    %�������е�ÿ���ַ���34���ַ����бȽ�,����
        Compare(j)=sum(sum(abs(Differ)));
 end
 index=find(Compare==(min(Compare)));                          %Ѱ�ҵ���ֵ��С��
 char=[char store1(index)];                                    %Ѱ�ҳ��Ƶ�ʡ��λ��
store2=strcat('A':'H','J':'N','P':'Z','0':'9');
for i=2:7                                                     %��ĸ����ʶ��
    for j=1:34
        Im=eval(strcat('Char_',num2str(i)));
        Template=imread(strcat('char&num\',num2str(j),'.bmp')); 
        Template=im2bw(Template);
        Differ=Im-Template;
        Compare(j)=sum(sum(abs(Differ)));
    end
    index=find(Compare==(min(Compare)));
    char=[char store2(index)];                                 %Ѱ�ҳ��Ƶĵڶ�λ��
end
figure,imshow(I),title(strcat('����Ϊ:',char))

