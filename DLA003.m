function z = DLA003(filename, dim , N)
% Diffusion Limited Aggregation (DLA) version 0.03
% by Jonathan Leto <jonathan@leto.net>
% Tested in Matlab 6.0 and 7.1
% Sat Jan 06 00:27:21 EST 2007 
% Arguments: 
%	filename - a string for where to save the file Ex: 'pic10.jpg'
%	dim	 - create a (dim x dim) space
%	N	 - number of particles
% New in version 0.03: 
%    Reseed speedups
% New in version 0.02:
% Faster, implemented:
%    Introduce points at a radius a little bigger than structure ( moderate speedup )
%    Reseed points if they wander out of radius ( huge speedup! )

% TODO:  Implement stickiness
started=datestr(now);
step = 3;
randtheta = rand*2*pi;
middle = round(dim/2);
pic = 127*ones(dim,dim);
pic(middle,middle) = 0;
c = 0;
dist = 0;
min_radius = 5;
reseed=0;
num_reseeds=0;
stat_total_sum = 0;
stat_total_avg = 0;

% Let's simulate a drunken sailor
for n=1:N, 
	% TODO: make this an adjustable parameter
	% this makes the initial radius %1 of dim, and linearly increases it until r=dim/2 at n=N 
	% TODO: if dim is >=1000, than the initial radius should be less than %1
	radius = round(dim*(1 + 49*(n-1)/N)/100);

	if( radius < min_radius )
		radius = min_radius;
	end

	randtheta = rand*2*pi;
    randx = round( middle +  (radius-2) * cos(randtheta) );
    randy = round( middle +  (radius-2) * sin(randtheta) );

	dist = sqrt((randx-middle)^2 + (randy-middle)^2);
	disp( sprintf('%d: init=(%d,%d) dist=%f radius=%d', n,randx,randy,dist,radius) );

	% repeat until we hit something
	% if outside radius after 20 steps, RESEED
	% TODO: make # of steps adjustable, or find a better default
	while ( 1 > 0 ),
		c=c+1;
			
		newx = randx + (-1)^round(4*rand) * mod( round( rand*(step*2) ), step ) ;
		newy = randy + (-1)^round(4*rand) * mod( round( rand*(step*2) ), step ) ;

		if( mod(c,20) == 0 )
			if( abs( newx - middle ) > radius |  abs( newy - middle) > radius )
				disp('RESEED');
				reseed=1;
		                num_reseeds=num_reseeds+1;
				n=n-1;
				break;
			end
		end

		if( newx > 1 & newx < (dim-1) )
			randx = newx;
		end
		if( newy > 1 & newy < (dim-1) )
			randy = newy;
		end

		% Did we walk into something?
		found = 0;
		for j=-1:1,
			for k=-1:1,
				if( randx+j < 1 | randy+k < 1)
					break;
				end	
				p = pic(randx+j,randy+k);
				% Hit something!
				if ( p == 0 )
					disp(sprintf('%d: hit at (%d,%d)',  n, randx+j, randy+k) );
					found = 1;
					break;
				end
			end
			if ( found )
				break;
			end
		end
		if( found )
			break;
		end
	end
	% we have hit something if reseed=0 
	if( reseed == 1 )
		% reset seed state
		reseed=0;
	else
		% count total number of iterations
		stat_total_sum = stat_total_sum + c;

		disp(sprintf('%d: took %d attempts to hit',n,c));
		c=0;
		% aggregate
		pic(randx,randy) = 0;	
	end
end
finished=datestr(now);
imwrite(pic,filename);
image(pic);
colormap gray;
disp(sprintf('Started  %s', started) );
disp(sprintf('Finished %s', finished) );
disp(sprintf('Avg   # attempts: %d', round(stat_total_sum/N )) );
disp(sprintf('# of Reseeds    : %d', num_reseeds ) );

