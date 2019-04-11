#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int  main (int argc, char *argv[]){
	FILE * in;
	char *top;
	char * ch,*ch2,*ch3;
	int hw;
	
	int i;
	char line [2000];
	printf("start reading file %s\n",argv[1]);
	in= fopen(argv[1],"r");
	top= argv[3];
	
	//printf ("argv[1]=%s\n",argv[1]);
	//printf ("argv[2]=%s\n",argv[2]);
	//printf ("argv[3]=%s\n",argv[3]);
	//in= fopen("router.fit.rpt","r");
	
	if(in==NULL) {printf("cant open %s file\n",argv[1]); return -1; }
	do{
		ch=fgets(line,sizeof(line),in);
		if(ch==NULL){printf("%s did not find in %s",top, argv[1]); return 1;}
		if(
			strstr(line ,top) 
		) ch=NULL;
		
	}while (ch!=NULL);
	fclose(in);
	printf ("%s\n",line);
	ch = strtok(line,";");
	for(i=0;i<17;i++) ch = strtok(NULL,";");
	ch2 = strtok(NULL,";");
	ch3 = strtok(NULL,";");
	
	
	
	
	ch = strtok(ch,"(");
	ch2 = strtok(ch2,"(");
	ch3 = strtok(ch3,"(");
	printf("\n\ncc=%s\n",ch);
	printf("\n\ncc=%s\n",ch2);
	printf("\n\ncc=%s\n",ch3);
	
	hw=atoi(ch)+atof(ch2)+atof(ch3);
	printf("hw =%d\n",hw);
	in= fopen("hw","w");
	fprintf(in,"%d",hw);
	fclose(in);
	
	in= fopen(argv[2],"r");
	printf("start reading file %s\n",argv[2]);
	if(in==NULL) {printf("cant open %s file\n",argv[2]); return 0; }
	do{
		ch=fgets(line,sizeof(line),in);
		if(
			strstr(line ,"MHz") 
		) ch=NULL;
		
	}while (ch!=NULL);
	do{
		ch=fgets(line,sizeof(line),in);
		if(
			strstr(line ,"MHz") 
		) ch=NULL;
		
	}while (ch!=NULL);
	ch = line;
	ch+=2;
	ch = strtok(ch,"MHz");
	printf ("Fmax=%s\n",ch);
	in= fopen("fr","w");
	fprintf(in,"%s",ch);
	fclose(in);
	return 0;
	
	
}
