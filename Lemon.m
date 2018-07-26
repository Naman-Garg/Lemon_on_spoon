function [lemon_on_spoon,xto] = LEMON_PROJECT(lemon_video)

    %Read Video as object
    object = VideoReader(lemon_video);

    %Read object
    video = read(object);

    xto=[];

    %Storing files as part
    [p1,fl,~]=fileparts(lemon_video);

    %Variable to store maximum of yellow
    lmaxo=0;

    %string to store number of zero's for accessing frames in reverse
    zp='';

    %concatenation of zero's in zp
    for i=1:numel(num2str(size(video,4)))
        zp=strcat(zp,'0');
    end

    %Variable to store background
    bs=0;

    %Directory to store frames of videos
    mkdir(strcat(p1,'/',fl,'_lemon/'));

    %Calculating background
    for x = 1:size(video,4)  
        bs = bs + double(video(:,:,:,x));
    end

    %Final background
    bs=bs/size(video,4);

    %Frame format for storing
    ST='.jpg';

    %Subtracting background from frames to find foreground
    for i=1:size(video,4)
        %Selecting Frame 
        I=double(video(:,:,:,i));
        
        %Foreground Calculation
        %Subtracting background from foreground
        fg=mean(abs(I-bs),3);
        
        %Converting coloured matrix to gray
        %Accessing each frames as image
        fgo=mat2gray(fg);
        fgox=fgo;
        
        %Storing data in image
        Sx=strcat(zp(1:end-numel(num2str(i))),num2str(i));        
        
        %Storing image with ST(.jpg) format
        Strc=strcat(p1,'/',fl,'_lemon/',Sx,ST);
        
        %Detecting Yellow colour (red+green = yellow)
        %converting that coloured matrix to grayscale
        yellow=mat2gray(I(:,:,1)/2+I(:,:,2)/2-I(:,:,3),[0 255]);
        
        %Detecting if yellow colour is greater than certain range or value
        %if yes set that value to 1 else zero
        fgo((yellow>=0.7*max(yellow(:))) & (fgo>0.7*max(fgo(:))))=1;
        fgo(yellow<0.7*max(yellow(:))) = 0;
        
        %Finding max value in matrix yellow
        tt=max(yellow(:));
        
        %if tt is greater than lmaxo setting lmaxo to tt
        if tt>lmaxo
            lmaxo=tt;
        end
        
        %if tt is less than certain value fat fgo matrix to zero
        %Otherwise cluster the points of frames
        if tt<0.7*max(0.1,lmaxo);
            fgo(:)=0;
        else
            %Return number of connected components
            CC=bwconncomp(logical(fgo));
        
            %Porforming function in connected components index and store in
            %performing function on each cell of nume1 at connected component
            %index
            numPixels = cellfun(@numel,CC.PixelIdxList);
            
            %Selecting maximum of numPixel frox col idx
            [~,idx] = max(numPixels);
            
            %Performing measurement on set of properties of frame image
            S = regionprops(CC,'Centroid');
            
            %Storing centroid of S at xt
            xt=S(idx).Centroid;
            xto=[xto;xt];
        end
        %Writting image(frame) ai file Strc
        imwrite([fgox,yellow,fgo],Strc);
    end 

    %Calculating Mean of all frames
    Smean=mean(xto);

    %calculating mean of all frames with certain values
    sml=mean(xto(round(0.9*size(xto,1)):end,:));
    lemon_on_spoon=1;

    %Checking if difference is greater then some value
    %Probability value
    if sml(2)-Smean(2)>50    
        lemon_on_spoon=0;
        disp('FALSE: Lemon has fallen')
    else
        disp('TRUE: Lemon has not fallen')
    end
end
