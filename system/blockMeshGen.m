x = ...
    [          0          20 
    -20          20 
    -20         -20 
    0         -20 
    -20         -80 
    0         -80
    -20         -100
    0         -100
    -40          40
    -60          10
    -200         -100
    -200       -1000
    -20       -1000
    0       -1000
    -40          60
    -60          60];
x = x*5/4;

conn = [...
    0  1  2  3
    3  2  4  5
    5  4  6  7
    2  8  9  4
    7  6 12 13
    6 10 11 12
    8 14 15 9]+1;
clf
patch('vertices',x,'faces',conn,'faceColor','yellow','linestyle',':')
axis equal
for i = 1:length(x)
    text(x(i,1),x(i,2),num2str(i-1,' %i'));
end
for i = 1:length(conn)
    text(mean(x(conn(i,:),1)),mean(x(conn(i,:),2)),num2str(i-1,'%i'),'color','r')
end
axis([min(x(:,1)) max(x(:,1)) min(x(:,2)) max(x(:,2))])
filename = 'blockMeshDict';
if (exist(filename))
    delete(filename);
end
diary(filename)
fprintf('FoamFile\n{\n\tversion\t\t\t2.0;\n\tformat\t\t\tascii;\n\troot\t\t\t"";\n\tcase\t\t\t"";\n\tinstance\t\t"";\n\tlocal\t\t\t"";\n');
fprintf('\tclass\t\t\tdictionary;\n\tobject\t\t\tblockMeshDict;\n}\n\nconvertToMeters\t0.000001;\n\n');
% vertices
vertices = [x x(:,1)/25;x -x(:,1)/25];
fprintf('vertices\n(\n');
fprintf('\t(%f %f %f)\n',vertices')
fprintf(');\n\n');

% blocks
var = 25;
cells = [var 2*var 1
    var 3*var 1
    var var 1
    2*var 3*var 1
    var 46*var 1
    4*var 46*var 1
    1*var 3*var 1];
grad = [1 1 1;1 1 1;1 1 1;1 1 1;1 1 1;3 1 1;1 1 1];
blocks = [conn-1 max(conn(:))+conn-1];
fprintf('blocks\n(\n');
fprintf('\thex (%2i\t%2i\t%2i\t%2i\t%2i\t%2i\t%2i\t%2i)\t(%3i\t%3i\t%3i) simpleGrading (%3i\t%3i\t%3i)\n',[blocks cells grad]');

% edges
fprintf(');\n\nedges\n(');
fprintf('\tarc %i %i (%f %f %f)\n', 4, 9,vertices(10,:)-[0 .01 0])
fprintf('\tarc %i %i (%f %f %f)\n', 16+4,9+16, vertices(26,:)-[0 .01 0])
fprintf('\tarc %i %i (%f %f %f)\n', 8, 2,vertices(9,:)-[0 .01 0])
fprintf('\tarc %i %i (%f %f %f)\n', 16+8,2+16, vertices(9+16,:)-[0 .01 0])
fprintf('\n);\n');

% front
fprintf('\n\nboundary\n(\n\tfront\n\t{\n\t\ttype wedge;\n\t\tfaces\t\t\n\t\t(\n')
fprintf('\t\t\t(%2i\t%2i\t%2i\t%2i)\n',blocks(:,8:-1:5)');
fprintf('\t\t);\n\t}\n');

% back
fprintf('\n\tback\n\t{\n\t\ttype wedge;\n\t\tfaces\t\t\n\t\t(\n')
fprintf('\t\t\t(%2i\t%2i\t%2i\t%2i)\n',blocks(:,1:4)');
fprintf('\t\t);\n\t}\n');

bc = @(x) [x(1:end-1)' x(2:end)' [x(2:end)' x(1:end-1)']+max(conn(:))]';
% atmosphere
fprintf('\n\toutlet_pressure\n\t{\n\t\ttype patch;\n\t\tfaces\t\t\n\t\t(\n')
fprintf('\t\t\t(%2i\t%2i\t%2i\t%2i)\n',bc([13 12 11 10]));
fprintf('\t\t);\n\t}\n');

% walls
fprintf('\n\twall\n\t{\n\t\ttype wall;\n\t\tfaces\t\t\n\t\t(\n')
fprintf('\t\t\t(%2i\t%2i\t%2i\t%2i)\n',[bc([10 6 4 9 15]) bc([14 8 2 1])]);
fprintf('\t\t);\n\t}\n');

% inlet_helium
fprintf('\n\tinlet_helium\n\t{\n\t\ttype patch;\n\t\tfaces\t\t\n\t\t(\n')
fprintf('\t\t\t(%2i\t%2i\t%2i\t%2i)\n',bc([15 14]));
fprintf('\t\t);\n\t}\n');


% inlet
fprintf('\n\tinlet_water\n\t{\n\t\ttype patch;\n\t\tfaces\t\t\n\t\t(\n')
fprintf('\t\t\t(%2i\t%2i\t%2i\t%2i)\n',bc([1 0]));
fprintf('\t\t);\n\t}\n');


% axis
fprintf('\n\taxis\n\t{\n\t\ttype empty;\n\t\tfaces\t\t\n\t\t(\n')
fprintf('\t\t\t(%2i\t%2i\t%2i\t%2i)\n',bc([0 3 5 7 13]));
fprintf('\t\t);\n\t}\n');

fprintf(');\n\nmergePatchPairs\n(\n);\n');
diary off;