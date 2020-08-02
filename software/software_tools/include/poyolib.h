#ifndef POYOLIB_H
#define POYOLIB_H

// poyolib.c
void *memset(void *b, int c, long len);
void *memcpy(void *dst, const void *src, long len);
int memcmp(const void *b1, const void *b2, long len);
int strlen(const char *s);
char *strcpy(char *dst, const char *src);
int strcmp(const char *s1, const char *s2);
int strncmp(const char *s1, const char *s2, int len);

int putc(unsigned char c);
int puts(unsigned char *str);
int putxval(unsigned long value, int column);

unsigned char getc(void);
int gets(unsigned char *buf);


#endif
