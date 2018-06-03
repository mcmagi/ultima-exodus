/* filepath.c */

#include <stdio.h>			/* printf, NULL */
#include <stdlib.h>			/* malloc, free */
#include <string.h>			/* strcpy, strlen */

#include "gendefs.h"
#include "filepath.h"
#include "stringutil.h"		/* strpos, strrpos, substring */

/* concatenates two path elements */
void concat_path(char *fullpath, const char *path1, const char *path2)
{
    int i = 0;

    if (path1 != NULL && strlen(path1) > 0)
    {
        strcpy(fullpath, path1);
        i = strlen(path1);

        /* insert directory separator if both paths are specified */
        if (path2 != NULL && strlen(path2) > 0)
        {
            if (fullpath[i] != '/' || fullpath[i] != '\\')
                fullpath[i++] = '/';
        }
    }

    if (path2 != NULL && strlen(path2) > 0)
        strcpy(&fullpath[i], path2);
}

FileParts * split_filename(const char *filename)
{
	int pathIdx, dotIdx;
	FileParts *fp;

	fp = malloc(sizeof(FileParts));
	fp->dir = NULL;
	fp->name = NULL;
	fp->ext = NULL;
	
	/* extract dirname component */
	pathIdx = strrpos(filename, '/');
	if (pathIdx < 0)
		pathIdx = strrpos(filename, '\\');
	if (pathIdx >= 0)
		fp->dir = substring(filename, 0, pathIdx);

	/* extract name and extension component */
	dotIdx = strrpos(&filename[pathIdx+1], '.');;
	if (dotIdx >= 0)
	{
		fp->ext = substring(&filename[pathIdx+dotIdx+2], 0, strlen(&filename[pathIdx+dotIdx+2]));
		fp->name = substring(&filename[pathIdx+1], 0, dotIdx);
	}
	else
		fp->name = substring(&filename[pathIdx+1], 0, strlen(&filename[pathIdx+1]));

	/*printf("filename=%s, fp->dir=%s, fp->name=%s, fp->ext=%s\n", filename, fp->dir, fp->name, fp->ext);*/

	return fp;
}

void free_fileparts(FileParts *fp)
{
	if (fp == NULL)
		return;

	free(fp->dir);
	free(fp->name);
	free(fp->ext);
	free(fp);
}
