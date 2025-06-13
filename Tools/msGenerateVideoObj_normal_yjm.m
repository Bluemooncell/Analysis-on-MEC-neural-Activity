%function ms = msGenerateVideoObj_normal(dirName, filePrefix, suffix)
function ms = msGenerateVideoObj_normal_yjm(suffix)
    videoFiles = dir([ '*' suffix]);
    
    ms.numFiles = 0;
    ms.numFrames = 0;
    ms.vidNum = [];
    ms.frameNum = [];
    ms.maxFramesPerFile = 0;
    
    ms.numFiles = length(videoFiles);
    
    for i = 1:ms.numFiles
        ms.vidObj{i} = VideoReader([videoFiles(i).name]);
        ms.vidNum = [ms.vidNum i*ones(1,ms.vidObj{i}.NumberOfFrames)];
        ms.frameNum = [ms.frameNum 1:ms.vidObj{i}.NumberOfFrames];
        
%         % time;
%         for j = 1:ms.vidObj{i}.NumberOfFrames
%             frame = ms.vidObj{i}.read(j);
%             ms.time(ms.numFrames + j,1) = ms.vidObj{i}.CurrentTime;
%         end
        
        ms.numFrames = ms.numFrames + ms.vidObj{i}.NumberOfFrames;
        ms.maxFramesPerFile = max(ms.maxFramesPerFile, ms.vidObj{i}.NumberOfFrames);
    end
    ms.height = ms.vidObj{1}.Height;
    ms.width = ms.vidObj{1}.Width;
    
    
end


