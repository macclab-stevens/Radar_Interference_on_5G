remote_user = 'eric';
remote_host = '10.1.0.4';
fileName = 't77';  % Example argument

system(sprintf('ssh m70q /home/eric/srsRAN_Project/scripts/PRFLogCollectorCTL.sh %s %s','stop', fileName))
