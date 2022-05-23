clc
close all
I=imread('car5.jpg');
figure,subplot(2,2,1);imshow(I), title('原始图像');
I_gray=rgb2gray(I);
subplot(2,2,2),imshow(I_gray),title('灰度图像');
%======================   形态学预处理 ======================
I_edge=edge(I_gray,'sobel');
subplot(2,2,3),imshow(I_edge),title('边缘检测后图像');
se=[1;1;1]; 
I_erode=imerode(I_edge,se);   
subplot(2,2,4),imshow(I_erode),title('腐蚀后边缘图像');
se=strel('rectangle',[25,25]);  
I_close=imclose(I_erode,se);            %图像闭合、填充图像
figure,subplot(1,2,1),imshow(I_close),title('填充后图像');
I_final=bwareaopen(I_close,2000);       %去除聚团灰度值小于2000的部分
subplot(1,2,2),imshow(I_final),title('形态滤波后图像');               %得到最终滤波后图像I_final
%==========================   车牌分割    =============================

I_new=zeros(size(I_final,1),size(I_final,2));                         %生成I_final行*I_fianl列的0矩阵I_new
location_of_1=[];
for i=1:size(I_final,1)                 %寻找二值图像中白的点的位置,二值图像的像素点的灰度值为0或者255，只有黑色0白色255
    for j=1:size(I_final,2)
           if I_final(i,j)==1;                                           %如果为白色
            newlocation=[i,j];
            location_of_1=[location_of_1;newlocation];                %将白点加入矩阵
        end
    end
end
mini=inf;maxi=0;                                                      
for i=1:size(location_of_1,1)       %寻找所有白点中，x坐标与y坐标的和最大，最小的两个点的位置
    temp=location_of_1(i,1)+location_of_1(i,2);                        %行加列
    if temp<mini
        mini=temp;
        a=i;
    end
    if temp>maxi
        maxi=temp;
        b=i;
    end
end
first_point=location_of_1(a,:);        %和最小的点为车牌的左上角
last_point=location_of_1(b,:);         %和最大的点为车牌的右下角
x1=first_point(1)+4;                   %坐标值修正
x2=last_point(1)-4;
y1=first_point(2)+4;                                               
y2=last_point(2)-4;
I_plate=I(x1+5:x2-5,y1+5:y2-6);                                    %I为原始图像
I_plate=OTSU(I_plate);                 %以OTSU算法对分割出的车牌进行自适应二值化处理,调用OTSU函数
I_plate=bwareaopen(I_plate,50);                                    %删除二值图像中面积小于50的对象
figure,imshow(I_plate),title('车牌提取')%画出最终车牌
%=========================   字符分割   ============================

X=[];                               %用来存放水平分割线的横坐标
flag=0;
for j=1:size(I_plate,2)                                            
    sum_y=sum(I_plate(:,j));
    if logical(sum_y)~=flag         %列和有变化时，记录下此列，       判断二值图像中不为0
        X=[X j];                                                   %将不为0存储在X数组中
        flag=logical(sum_y);                                       %logical()函数将非0元素的变为1，只含有0和1的元素数组
    end
end
figure;                                                            
for n=1:7                                                           %车牌是7位数
    char=I_plate(:,X(2*n-1):X(2*n)-1);  %进行粗分割
    for i=1:size(char,1)                %这两个for循环对分割字符的上下进行裁剪
        if sum(char(i,:))~=0                                        %从上面判断出不为0的最初位置，白色的位置top             
            top=i;
            break
        end
    end
    
    for i=1:size(char,1)
        if sum(char(size(char,1)-i,:))~=0                           %从下面判断出不为0初始位置，白色的位置buttom
            bottom=size(char,1)-i;
            break
        end
    end
    char=char(top:bottom,:);                                            
    subplot(2,7,n);imshow(char),title(n);                           %显示2行7列上分割和下分割的结果
    char=imresize(char,[32,16],'nearest');      %归一化为32*16的大小，以便模板匹配，将图像放大到32*16大小最近
    eval(strcat('Char_',num2str(n),'=char;'));  %将分割的字符放入Char_i中，eval()函数将字符串转化为可执行的语句
end
%==========================  字符识别   =============================
char=[];
store1=strcat('京津沪渝冀晋辽吉黑苏浙皖闽赣鲁豫鄂湘粤琼川贵云陕甘青藏桂皖新宁港鲁蒙'); %汉字模板
 for j=1:34
        Im=Char_1;
        Template=imread(strcat('chinese\',num2str(j),'.bmp')); %汉字识别，num2str将数值转化为字符串
        Template=im2bw(Template);                              %im2bw()将图像转化为二值图像
        Differ=Im-Template;                                    %将车牌中的每个字符与34个字符进行比较,做差
        Compare(j)=sum(sum(abs(Differ)));
 end
 index=find(Compare==(min(Compare)));                          %寻找到差值最小的
 char=[char store1(index)];                                    %寻找车牌的省份位置
store2=strcat('A':'H','J':'N','P':'Z','0':'9');
for i=2:7                                                     %字母数字识别
    for j=1:34
        Im=eval(strcat('Char_',num2str(i)));
        Template=imread(strcat('char&num\',num2str(j),'.bmp')); 
        Template=im2bw(Template);
        Differ=Im-Template;
        Compare(j)=sum(sum(abs(Differ)));
    end
    index=find(Compare==(min(Compare)));
    char=[char store2(index)];                                 %寻找车牌的第二位数
end
figure,imshow(I),title(strcat('车牌为:',char))

