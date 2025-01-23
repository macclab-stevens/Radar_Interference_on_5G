
getReTx('/Users/ericforbes/Documents/GitHub/NRTPIS/Results/MCSwalk_0918/240918-064045/240918-064045_simulationMetrics.mat')
getReTx('/Users/ericforbes/Documents/GitHub/NRTPIS/Results/MCSwalk_0918/240918-064045/240918-064045_simulationMetrics.mat')

getParamFileNames()




function getParamFileNames()
    results = ["mcs","numReTxDL","numReTxUL"]
    results = {}
    mcs = 1;
    MCSwalkFolder = dir('./Results/MCSwalk_0918/')
    for subfolder = MCSwalkFolder';
        if contains(subfolder.name,'.')
            continue
        end
        subFolder = strcat(subfolder.folder,'/',subfolder.name);
        for file = dir(subFolder)
            contents = struct2cell(file);
            [rownum,colnum]=size(contents);
            for i=1:colnum
                
                if contains(contents(1,i),'Metrics')
                    file_folder = contents(2,i);
                    file_name = contents(1,i);
                    para_file = strcat(file_folder{1},'/',file_name{1});
                    
                    [dl,ul] = getReTx(para_file) 
                    a = {mcs}
                    results(end+1,1) = a
                    results(end,2) = dl
                    results(end,3) = ul
                    mcs = mcs + 1
                    
                end
            end
    
        end
end

    % Do some stuff
end

function [numReTxDL,numReTxUL] = getReTx(metFileName)
    disp(metFileName);
    metrics = matfile(metFileName);
    metrics.simulationLogs;
    numReTxDL = metrics.simulationLogs(2,2);
    numReTxUL = metrics.simulationLogs(3,2);
end