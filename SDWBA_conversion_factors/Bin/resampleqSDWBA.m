function resampleqSDWBA(file2save,dirname,ActualLength,fileshape,fatness,frequency,theta,stdphase0,freq0,N0,g0,h0,c,noise_realisations)

		%disp(['mlength:', num2str(mlength_it)]);
		load(fileshape);
		a=a*fatness;
		scaling=(38.35*1e-3)/ActualLength;
		r=r/scaling;
		a=a/scaling;
		h=h0*ones(size(h));
		g=g0*ones(size(g));
		phi=90+theta;

		kL=2*pi*frequency/c*ActualLength;

		if ~exist(dirname,'dir')
            mkdir(dirname);
        end
        if ~exist(strcat(dirname,'/dataSDWBA'),'dir')
            mkdir(strcat(dirname,'/dataSDWBA'))
        end

%		w = waitbar(0,sprintf('SDWBA calculations, Iteration %d', iter));

        for irealisation=92:noise_realisations
%			waitbar(0,w,sprintf('SDWBA calculations Iteration %d, %d of %d',iter, irealisation, noise_realisations));

			disp(['Realisation:', num2str(irealisation)]);
            [BSTS,BSsigma,form_function]=resqBSTS_SDWBA(frequency,r,a,h,g,phi,[stdphase0 freq0 N0],c,0);

            save(strcat(dirname,'/dataSDWBA/',sprintf('%s%d_%d',file2save,irealisation)),'N0','stdphase0','freq0','BSTS','BSsigma','frequency','phi','form_function','ActualLength','c')
        end
%		close(w);

        BSsigmatot=zeros(size(BSsigma,1),size(BSsigma,2),noise_realisations);
	 	clear BSTS BSsigma

        for irealisation=1:noise_realisations
            load(strcat(dirname,'/dataSDWBA/',sprintf('%s%d_%d',file2save,irealisation)))
            BSsigmatot(:,:,irealisation)=BSsigma;
        end
        StandardDeviation=std(BSsigmatot,[],3);
        BSsigma=mean(BSsigmatot,3);
        BSTS=10*log10(BSsigma);
        save(strcat(dirname,'/',sprintf('%s%d',file2save)),'N0','stdphase0','freq0','frequency','BSTS','BSsigma','phi','StandardDeviation','ActualLength','c');
        clear BSsigmatot StandardDeviation BSTS
        BSsigmatot=BSsigma;
end
