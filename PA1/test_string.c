#include<stdio.h>

int main(int argc, char *argv[])
{
    char stra[100]="Hello";
    char* str1=stra;
    char* str2 = "World";
    while(*str2) {
        *str1++=*str2++;
    }
    str1-=5;
    printf("String: %s\n", str1);
    str2-=5;
    printf("String: %s\n", str2);
    printf("String: %s\n", stra);

    return 0;
}
