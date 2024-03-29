function y=fDataROIset(targetpath,savepath,name_sub,name_epi,TR,TE,FA)
%% Set CSF ROI on target slices (4th ventricle)
for cnt=1:length(name_sub)    
    cd(targetpath);
    cd(name_sub(cnt).name);
    epitemp = dir(['*' name_epi '*.nii*']);
    func = niftiread(epitemp(1).name);
    if length(epitemp)>2 && size(func,4)==1 
        for niil=1:length(epitemp)
            func(:,:,:,niil) = niftiread(epitemp(niil).name);
        end
    end    
    niiinfo = niftiinfo(epitemp(1).name);
    epi_img = cast(func,'double');
    [img_row,img_col,slicen,time_phase]=size(epi_img);
    csf_roiset2=zeros(img_row,img_col,slicen);
    %% Check whole images
    multi_imshow(mean(epi_img,4));
    %% Select target slices in 4th ventricle
    prompt = 'Do you want to check the whole images again? y/n ';
    str = input(prompt,'s');
    if str ~='y' && str~='n'
        disp('Wrong input!! y or n ONLY');
        prompt = 'Do you want to check images again? y/n ';
        str = input(prompt,'s');
    end
    while str=='y'
        multi_imshow(mean(epi_img,4));
        prompt = 'Do you want to check images again? y/n ';
        str = input(prompt,'s');
        if str ~='y' && str~='n'
            disp('Wrong input!! y or n ONLY');
            prompt = 'Do you want to check images again? y/n ';
            str = input(prompt,'s');
        end
    end
    close all;
    prompt = 'Enter 4th ventricle slices number (should be continuous numbers) [array form] (ex. [10,11,12,13]) : ';
    csfslice = input(prompt);
    slicelist = csfslice;
    %% Manually set CSF ROI of each target slices
    for nn=1:length(slicelist)
        temp_img = mean(epi_img(:,:,slicelist(nn),:),4)/max(max(mean(epi_img(:,:,slicelist(nn),:),4)));
        figure; imshow(temp_img); title(['Slice number ' num2str(slicelist(nn))]);
        set(gcf, 'Position', get(0,'Screensize'));
        disp('@@@@  Draw(Click and Drag) Wide ROI  @@@@');
        hh=imfreehand; %#ok<IMFREEH>
        wideroi = hh.createMask();
        tt=temp_img.*wideroi;
        [counts,x] = imhist(tt,100);
        stem(x,counts); ylim([0 10]);
        T = 0.5;
        BW = imbinarize(tt,T);
        figure; imshowpair(tt, BW, 'montage'); title(['T value:' num2str(T)]);
        prompt = 'Mask looks OK? [y/n] : ';
        mask_again = input(prompt,'s');
        if mask_again ~='y' && mask_again~='n'
            disp('Wrong input!! y or n ONLY');
            prompt = 'Do you want to check images again? y/n ';
            mask_again = input(prompt,'s');
        end
        while mask_again=='n'
            prompt = ['Current T: ' num2str(T) ', New T value will be? [0~1] : '];
            T = input(prompt);
            BW = imbinarize(tt,T);
            figure; imshowpair(tt, BW, 'montage'); title(['T value:' num2str(T)]);
            prompt = 'Mask looks OK? [y/n] : ';
            mask_again = input(prompt,'s');
            if mask_again ~='y' && mask_again~='n'
                disp('Wrong input!! y or n ONLY');
                prompt = 'Do you want to check images again? y/n ';
                mask_again = input(prompt,'s');
            end
        end
        csf_roiset2(:,:,slicelist(nn)) = BW;
        
        close all
    end
    clear func
    save([savepath '\' name_sub(cnt).name '_prepare_save.mat']);
%     save([savepath '\' epitemp(1).name '_prepare_save.mat']);
end
end
