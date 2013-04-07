
_RRsanity:     file format elf32-i386


Disassembly of section .text:

00000000 <foo>:
}
*/

void
foo()
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int i;
  int pid = getpid();
   6:	e8 e5 05 00 00       	call   5f0 <getpid>
   b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for (i=0;i<1000;i++)
   e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  15:	eb 29                	jmp    40 <foo+0x40>
     printf(2, "child %d prints for the %d time\n",pid,i+1);
  17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1a:	83 c0 01             	add    $0x1,%eax
  1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  24:	89 44 24 08          	mov    %eax,0x8(%esp)
  28:	c7 44 24 04 ac 0a 00 	movl   $0xaac,0x4(%esp)
  2f:	00 
  30:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  37:	e8 ab 06 00 00       	call   6e7 <printf>
void
foo()
{
  int i;
  int pid = getpid();
  for (i=0;i<1000;i++)
  3c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  40:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
  47:	7e ce                	jle    17 <foo+0x17>
     printf(2, "child %d prints for the %d time\n",pid,i+1);
}
  49:	c9                   	leave  
  4a:	c3                   	ret    

0000004b <RRsanity>:

void
RRsanity(void)
{
  4b:	55                   	push   %ebp
  4c:	89 e5                	mov    %esp,%ebp
  4e:	53                   	push   %ebx
  4f:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  int wTime [10];
  int rTime [10];
  int pid [10];
  printf(1, "RRsanity test\n");
  55:	c7 44 24 04 cd 0a 00 	movl   $0xacd,0x4(%esp)
  5c:	00 
  5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  64:	e8 7e 06 00 00       	call   6e7 <printf>

  int i=0;
  69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  for(;i<10;i++)
  70:	eb 2b                	jmp    9d <RRsanity+0x52>
  {  
    pid[i] = fork();
  72:	e8 e1 04 00 00       	call   558 <fork>
  77:	8b 55 f4             	mov    -0xc(%ebp),%edx
  7a:	89 84 95 7c ff ff ff 	mov    %eax,-0x84(%ebp,%edx,4)
    if(pid[i] == 0)
  81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  84:	8b 84 85 7c ff ff ff 	mov    -0x84(%ebp,%eax,4),%eax
  8b:	85 c0                	test   %eax,%eax
  8d:	75 0a                	jne    99 <RRsanity+0x4e>
    {
      foo();
  8f:	e8 6c ff ff ff       	call   0 <foo>
      exit();      
  94:	e8 c7 04 00 00       	call   560 <exit>
  int rTime [10];
  int pid [10];
  printf(1, "RRsanity test\n");

  int i=0;
  for(;i<10;i++)
  99:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  9d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  a1:	7e cf                	jle    72 <RRsanity+0x27>
      foo();
      exit();      
    }
  }
  
  for(i=0;i<10;i++)
  a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  aa:	eb 38                	jmp    e4 <RRsanity+0x99>
    pid[i] = wait2(&(wTime[i]),&(rTime[i]));
  ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  b6:	8d 45 a4             	lea    -0x5c(%ebp),%eax
  b9:	01 c2                	add    %eax,%edx
  bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  be:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  c5:	8d 45 cc             	lea    -0x34(%ebp),%eax
  c8:	01 c8                	add    %ecx,%eax
  ca:	89 54 24 04          	mov    %edx,0x4(%esp)
  ce:	89 04 24             	mov    %eax,(%esp)
  d1:	e8 9a 04 00 00       	call   570 <wait2>
  d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  d9:	89 84 95 7c ff ff ff 	mov    %eax,-0x84(%ebp,%edx,4)
      foo();
      exit();      
    }
  }
  
  for(i=0;i<10;i++)
  e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  e4:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  e8:	7e c2                	jle    ac <RRsanity+0x61>
    pid[i] = wait2(&(wTime[i]),&(rTime[i]));
  
  for(i=0;i<10;i++)
  ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  f1:	eb 51                	jmp    144 <RRsanity+0xf9>
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",pid[i],wTime[i],rTime[i],wTime[i]+rTime[i]);
  f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  f6:	8b 54 85 cc          	mov    -0x34(%ebp,%eax,4),%edx
  fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fd:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
 101:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
 104:	8b 45 f4             	mov    -0xc(%ebp),%eax
 107:	8b 4c 85 a4          	mov    -0x5c(%ebp,%eax,4),%ecx
 10b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 10e:	8b 54 85 cc          	mov    -0x34(%ebp,%eax,4),%edx
 112:	8b 45 f4             	mov    -0xc(%ebp),%eax
 115:	8b 84 85 7c ff ff ff 	mov    -0x84(%ebp,%eax,4),%eax
 11c:	89 5c 24 14          	mov    %ebx,0x14(%esp)
 120:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 124:	89 54 24 0c          	mov    %edx,0xc(%esp)
 128:	89 44 24 08          	mov    %eax,0x8(%esp)
 12c:	c7 44 24 04 dc 0a 00 	movl   $0xadc,0x4(%esp)
 133:	00 
 134:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 13b:	e8 a7 05 00 00       	call   6e7 <printf>
  }
  
  for(i=0;i<10;i++)
    pid[i] = wait2(&(wTime[i]),&(rTime[i]));
  
  for(i=0;i<10;i++)
 140:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 144:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 148:	7e a9                	jle    f3 <RRsanity+0xa8>
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",pid[i],wTime[i],rTime[i],wTime[i]+rTime[i]);

}
 14a:	81 c4 a4 00 00 00    	add    $0xa4,%esp
 150:	5b                   	pop    %ebx
 151:	5d                   	pop    %ebp
 152:	c3                   	ret    

00000153 <main>:
int
main(void)
{
 153:	55                   	push   %ebp
 154:	89 e5                	mov    %esp,%ebp
 156:	83 e4 f0             	and    $0xfffffff0,%esp
  RRsanity();
 159:	e8 ed fe ff ff       	call   4b <RRsanity>
  exit();
 15e:	e8 fd 03 00 00       	call   560 <exit>
 163:	90                   	nop

00000164 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 164:	55                   	push   %ebp
 165:	89 e5                	mov    %esp,%ebp
 167:	57                   	push   %edi
 168:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 169:	8b 4d 08             	mov    0x8(%ebp),%ecx
 16c:	8b 55 10             	mov    0x10(%ebp),%edx
 16f:	8b 45 0c             	mov    0xc(%ebp),%eax
 172:	89 cb                	mov    %ecx,%ebx
 174:	89 df                	mov    %ebx,%edi
 176:	89 d1                	mov    %edx,%ecx
 178:	fc                   	cld    
 179:	f3 aa                	rep stos %al,%es:(%edi)
 17b:	89 ca                	mov    %ecx,%edx
 17d:	89 fb                	mov    %edi,%ebx
 17f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 182:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 185:	5b                   	pop    %ebx
 186:	5f                   	pop    %edi
 187:	5d                   	pop    %ebp
 188:	c3                   	ret    

00000189 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 189:	55                   	push   %ebp
 18a:	89 e5                	mov    %esp,%ebp
 18c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 18f:	8b 45 08             	mov    0x8(%ebp),%eax
 192:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 195:	90                   	nop
 196:	8b 45 0c             	mov    0xc(%ebp),%eax
 199:	0f b6 10             	movzbl (%eax),%edx
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	88 10                	mov    %dl,(%eax)
 1a1:	8b 45 08             	mov    0x8(%ebp),%eax
 1a4:	0f b6 00             	movzbl (%eax),%eax
 1a7:	84 c0                	test   %al,%al
 1a9:	0f 95 c0             	setne  %al
 1ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1b0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 1b4:	84 c0                	test   %al,%al
 1b6:	75 de                	jne    196 <strcpy+0xd>
    ;
  return os;
 1b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1bb:	c9                   	leave  
 1bc:	c3                   	ret    

000001bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1bd:	55                   	push   %ebp
 1be:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1c0:	eb 08                	jmp    1ca <strcmp+0xd>
    p++, q++;
 1c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1c6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
 1cd:	0f b6 00             	movzbl (%eax),%eax
 1d0:	84 c0                	test   %al,%al
 1d2:	74 10                	je     1e4 <strcmp+0x27>
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
 1d7:	0f b6 10             	movzbl (%eax),%edx
 1da:	8b 45 0c             	mov    0xc(%ebp),%eax
 1dd:	0f b6 00             	movzbl (%eax),%eax
 1e0:	38 c2                	cmp    %al,%dl
 1e2:	74 de                	je     1c2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
 1e7:	0f b6 00             	movzbl (%eax),%eax
 1ea:	0f b6 d0             	movzbl %al,%edx
 1ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f0:	0f b6 00             	movzbl (%eax),%eax
 1f3:	0f b6 c0             	movzbl %al,%eax
 1f6:	89 d1                	mov    %edx,%ecx
 1f8:	29 c1                	sub    %eax,%ecx
 1fa:	89 c8                	mov    %ecx,%eax
}
 1fc:	5d                   	pop    %ebp
 1fd:	c3                   	ret    

000001fe <strlen>:

uint
strlen(char *s)
{
 1fe:	55                   	push   %ebp
 1ff:	89 e5                	mov    %esp,%ebp
 201:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 204:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 20b:	eb 04                	jmp    211 <strlen+0x13>
 20d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 211:	8b 45 fc             	mov    -0x4(%ebp),%eax
 214:	03 45 08             	add    0x8(%ebp),%eax
 217:	0f b6 00             	movzbl (%eax),%eax
 21a:	84 c0                	test   %al,%al
 21c:	75 ef                	jne    20d <strlen+0xf>
  return n;
 21e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 221:	c9                   	leave  
 222:	c3                   	ret    

00000223 <memset>:

void*
memset(void *dst, int c, uint n)
{
 223:	55                   	push   %ebp
 224:	89 e5                	mov    %esp,%ebp
 226:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 229:	8b 45 10             	mov    0x10(%ebp),%eax
 22c:	89 44 24 08          	mov    %eax,0x8(%esp)
 230:	8b 45 0c             	mov    0xc(%ebp),%eax
 233:	89 44 24 04          	mov    %eax,0x4(%esp)
 237:	8b 45 08             	mov    0x8(%ebp),%eax
 23a:	89 04 24             	mov    %eax,(%esp)
 23d:	e8 22 ff ff ff       	call   164 <stosb>
  return dst;
 242:	8b 45 08             	mov    0x8(%ebp),%eax
}
 245:	c9                   	leave  
 246:	c3                   	ret    

00000247 <strchr>:

char*
strchr(const char *s, char c)
{
 247:	55                   	push   %ebp
 248:	89 e5                	mov    %esp,%ebp
 24a:	83 ec 04             	sub    $0x4,%esp
 24d:	8b 45 0c             	mov    0xc(%ebp),%eax
 250:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 253:	eb 14                	jmp    269 <strchr+0x22>
    if(*s == c)
 255:	8b 45 08             	mov    0x8(%ebp),%eax
 258:	0f b6 00             	movzbl (%eax),%eax
 25b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 25e:	75 05                	jne    265 <strchr+0x1e>
      return (char*)s;
 260:	8b 45 08             	mov    0x8(%ebp),%eax
 263:	eb 13                	jmp    278 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 265:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 269:	8b 45 08             	mov    0x8(%ebp),%eax
 26c:	0f b6 00             	movzbl (%eax),%eax
 26f:	84 c0                	test   %al,%al
 271:	75 e2                	jne    255 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 273:	b8 00 00 00 00       	mov    $0x0,%eax
}
 278:	c9                   	leave  
 279:	c3                   	ret    

0000027a <gets>:

char*
gets(char *buf, int max)
{
 27a:	55                   	push   %ebp
 27b:	89 e5                	mov    %esp,%ebp
 27d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 280:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 287:	eb 44                	jmp    2cd <gets+0x53>
    cc = read(0, &c, 1);
 289:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 290:	00 
 291:	8d 45 ef             	lea    -0x11(%ebp),%eax
 294:	89 44 24 04          	mov    %eax,0x4(%esp)
 298:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 29f:	e8 e4 02 00 00       	call   588 <read>
 2a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2ab:	7e 2d                	jle    2da <gets+0x60>
      break;
    buf[i++] = c;
 2ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b0:	03 45 08             	add    0x8(%ebp),%eax
 2b3:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 2b7:	88 10                	mov    %dl,(%eax)
 2b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 2bd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2c1:	3c 0a                	cmp    $0xa,%al
 2c3:	74 16                	je     2db <gets+0x61>
 2c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2c9:	3c 0d                	cmp    $0xd,%al
 2cb:	74 0e                	je     2db <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2d0:	83 c0 01             	add    $0x1,%eax
 2d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2d6:	7c b1                	jl     289 <gets+0xf>
 2d8:	eb 01                	jmp    2db <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 2da:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2de:	03 45 08             	add    0x8(%ebp),%eax
 2e1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2e7:	c9                   	leave  
 2e8:	c3                   	ret    

000002e9 <stat>:

int
stat(char *n, struct stat *st)
{
 2e9:	55                   	push   %ebp
 2ea:	89 e5                	mov    %esp,%ebp
 2ec:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2f6:	00 
 2f7:	8b 45 08             	mov    0x8(%ebp),%eax
 2fa:	89 04 24             	mov    %eax,(%esp)
 2fd:	e8 ae 02 00 00       	call   5b0 <open>
 302:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 305:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 309:	79 07                	jns    312 <stat+0x29>
    return -1;
 30b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 310:	eb 23                	jmp    335 <stat+0x4c>
  r = fstat(fd, st);
 312:	8b 45 0c             	mov    0xc(%ebp),%eax
 315:	89 44 24 04          	mov    %eax,0x4(%esp)
 319:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31c:	89 04 24             	mov    %eax,(%esp)
 31f:	e8 a4 02 00 00       	call   5c8 <fstat>
 324:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 327:	8b 45 f4             	mov    -0xc(%ebp),%eax
 32a:	89 04 24             	mov    %eax,(%esp)
 32d:	e8 66 02 00 00       	call   598 <close>
  return r;
 332:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 335:	c9                   	leave  
 336:	c3                   	ret    

00000337 <atoi>:

int
atoi(const char *s)
{
 337:	55                   	push   %ebp
 338:	89 e5                	mov    %esp,%ebp
 33a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 33d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 344:	eb 23                	jmp    369 <atoi+0x32>
    n = n*10 + *s++ - '0';
 346:	8b 55 fc             	mov    -0x4(%ebp),%edx
 349:	89 d0                	mov    %edx,%eax
 34b:	c1 e0 02             	shl    $0x2,%eax
 34e:	01 d0                	add    %edx,%eax
 350:	01 c0                	add    %eax,%eax
 352:	89 c2                	mov    %eax,%edx
 354:	8b 45 08             	mov    0x8(%ebp),%eax
 357:	0f b6 00             	movzbl (%eax),%eax
 35a:	0f be c0             	movsbl %al,%eax
 35d:	01 d0                	add    %edx,%eax
 35f:	83 e8 30             	sub    $0x30,%eax
 362:	89 45 fc             	mov    %eax,-0x4(%ebp)
 365:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 369:	8b 45 08             	mov    0x8(%ebp),%eax
 36c:	0f b6 00             	movzbl (%eax),%eax
 36f:	3c 2f                	cmp    $0x2f,%al
 371:	7e 0a                	jle    37d <atoi+0x46>
 373:	8b 45 08             	mov    0x8(%ebp),%eax
 376:	0f b6 00             	movzbl (%eax),%eax
 379:	3c 39                	cmp    $0x39,%al
 37b:	7e c9                	jle    346 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 37d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 380:	c9                   	leave  
 381:	c3                   	ret    

00000382 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 382:	55                   	push   %ebp
 383:	89 e5                	mov    %esp,%ebp
 385:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 388:	8b 45 08             	mov    0x8(%ebp),%eax
 38b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 38e:	8b 45 0c             	mov    0xc(%ebp),%eax
 391:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 394:	eb 13                	jmp    3a9 <memmove+0x27>
    *dst++ = *src++;
 396:	8b 45 f8             	mov    -0x8(%ebp),%eax
 399:	0f b6 10             	movzbl (%eax),%edx
 39c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 39f:	88 10                	mov    %dl,(%eax)
 3a1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3a5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 3ad:	0f 9f c0             	setg   %al
 3b0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 3b4:	84 c0                	test   %al,%al
 3b6:	75 de                	jne    396 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3bb:	c9                   	leave  
 3bc:	c3                   	ret    

000003bd <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 3bd:	55                   	push   %ebp
 3be:	89 e5                	mov    %esp,%ebp
 3c0:	83 ec 38             	sub    $0x38,%esp
 3c3:	8b 45 10             	mov    0x10(%ebp),%eax
 3c6:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 3c9:	8b 45 14             	mov    0x14(%ebp),%eax
 3cc:	8b 00                	mov    (%eax),%eax
 3ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 3d8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3dc:	74 06                	je     3e4 <strtok+0x27>
 3de:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 3e2:	75 54                	jne    438 <strtok+0x7b>
    return match;
 3e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 3e7:	eb 6e                	jmp    457 <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 3e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ec:	03 45 0c             	add    0xc(%ebp),%eax
 3ef:	0f b6 00             	movzbl (%eax),%eax
 3f2:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 3f5:	74 06                	je     3fd <strtok+0x40>
      {
	index++;
 3f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3fb:	eb 3c                	jmp    439 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 3fd:	8b 45 14             	mov    0x14(%ebp),%eax
 400:	8b 00                	mov    (%eax),%eax
 402:	8b 55 f4             	mov    -0xc(%ebp),%edx
 405:	29 c2                	sub    %eax,%edx
 407:	8b 45 14             	mov    0x14(%ebp),%eax
 40a:	8b 00                	mov    (%eax),%eax
 40c:	03 45 0c             	add    0xc(%ebp),%eax
 40f:	89 54 24 08          	mov    %edx,0x8(%esp)
 413:	89 44 24 04          	mov    %eax,0x4(%esp)
 417:	8b 45 08             	mov    0x8(%ebp),%eax
 41a:	89 04 24             	mov    %eax,(%esp)
 41d:	e8 37 00 00 00       	call   459 <strncpy>
 422:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 425:	8b 45 08             	mov    0x8(%ebp),%eax
 428:	0f b6 00             	movzbl (%eax),%eax
 42b:	84 c0                	test   %al,%al
 42d:	74 19                	je     448 <strtok+0x8b>
	  match = 1;
 42f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 436:	eb 10                	jmp    448 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 438:	90                   	nop
 439:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43c:	03 45 0c             	add    0xc(%ebp),%eax
 43f:	0f b6 00             	movzbl (%eax),%eax
 442:	84 c0                	test   %al,%al
 444:	75 a3                	jne    3e9 <strtok+0x2c>
 446:	eb 01                	jmp    449 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 448:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 449:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44c:	8d 50 01             	lea    0x1(%eax),%edx
 44f:	8b 45 14             	mov    0x14(%ebp),%eax
 452:	89 10                	mov    %edx,(%eax)
  return match;
 454:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 457:	c9                   	leave  
 458:	c3                   	ret    

00000459 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 459:	55                   	push   %ebp
 45a:	89 e5                	mov    %esp,%ebp
 45c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 45f:	8b 45 08             	mov    0x8(%ebp),%eax
 462:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 465:	90                   	nop
 466:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 46a:	0f 9f c0             	setg   %al
 46d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 471:	84 c0                	test   %al,%al
 473:	74 30                	je     4a5 <strncpy+0x4c>
 475:	8b 45 0c             	mov    0xc(%ebp),%eax
 478:	0f b6 10             	movzbl (%eax),%edx
 47b:	8b 45 08             	mov    0x8(%ebp),%eax
 47e:	88 10                	mov    %dl,(%eax)
 480:	8b 45 08             	mov    0x8(%ebp),%eax
 483:	0f b6 00             	movzbl (%eax),%eax
 486:	84 c0                	test   %al,%al
 488:	0f 95 c0             	setne  %al
 48b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 48f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 493:	84 c0                	test   %al,%al
 495:	75 cf                	jne    466 <strncpy+0xd>
    ;
  while(n-- > 0)
 497:	eb 0c                	jmp    4a5 <strncpy+0x4c>
    *s++ = 0;
 499:	8b 45 08             	mov    0x8(%ebp),%eax
 49c:	c6 00 00             	movb   $0x0,(%eax)
 49f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4a3:	eb 01                	jmp    4a6 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 4a5:	90                   	nop
 4a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4aa:	0f 9f c0             	setg   %al
 4ad:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 4b1:	84 c0                	test   %al,%al
 4b3:	75 e4                	jne    499 <strncpy+0x40>
    *s++ = 0;
  return os;
 4b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4b8:	c9                   	leave  
 4b9:	c3                   	ret    

000004ba <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 4ba:	55                   	push   %ebp
 4bb:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 4bd:	eb 0c                	jmp    4cb <strncmp+0x11>
    n--, p++, q++;
 4bf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 4c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4c7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 4cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4cf:	74 1a                	je     4eb <strncmp+0x31>
 4d1:	8b 45 08             	mov    0x8(%ebp),%eax
 4d4:	0f b6 00             	movzbl (%eax),%eax
 4d7:	84 c0                	test   %al,%al
 4d9:	74 10                	je     4eb <strncmp+0x31>
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
 4de:	0f b6 10             	movzbl (%eax),%edx
 4e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e4:	0f b6 00             	movzbl (%eax),%eax
 4e7:	38 c2                	cmp    %al,%dl
 4e9:	74 d4                	je     4bf <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 4eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 4ef:	75 07                	jne    4f8 <strncmp+0x3e>
    return 0;
 4f1:	b8 00 00 00 00       	mov    $0x0,%eax
 4f6:	eb 18                	jmp    510 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 4f8:	8b 45 08             	mov    0x8(%ebp),%eax
 4fb:	0f b6 00             	movzbl (%eax),%eax
 4fe:	0f b6 d0             	movzbl %al,%edx
 501:	8b 45 0c             	mov    0xc(%ebp),%eax
 504:	0f b6 00             	movzbl (%eax),%eax
 507:	0f b6 c0             	movzbl %al,%eax
 50a:	89 d1                	mov    %edx,%ecx
 50c:	29 c1                	sub    %eax,%ecx
 50e:	89 c8                	mov    %ecx,%eax
}
 510:	5d                   	pop    %ebp
 511:	c3                   	ret    

00000512 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 512:	55                   	push   %ebp
 513:	89 e5                	mov    %esp,%ebp
  while(*p){
 515:	eb 13                	jmp    52a <strcat+0x18>
    *dest++ = *p++;
 517:	8b 45 0c             	mov    0xc(%ebp),%eax
 51a:	0f b6 10             	movzbl (%eax),%edx
 51d:	8b 45 08             	mov    0x8(%ebp),%eax
 520:	88 10                	mov    %dl,(%eax)
 522:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 526:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 52a:	8b 45 0c             	mov    0xc(%ebp),%eax
 52d:	0f b6 00             	movzbl (%eax),%eax
 530:	84 c0                	test   %al,%al
 532:	75 e3                	jne    517 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 534:	eb 13                	jmp    549 <strcat+0x37>
    *dest++ = *q++;
 536:	8b 45 10             	mov    0x10(%ebp),%eax
 539:	0f b6 10             	movzbl (%eax),%edx
 53c:	8b 45 08             	mov    0x8(%ebp),%eax
 53f:	88 10                	mov    %dl,(%eax)
 541:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 545:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 549:	8b 45 10             	mov    0x10(%ebp),%eax
 54c:	0f b6 00             	movzbl (%eax),%eax
 54f:	84 c0                	test   %al,%al
 551:	75 e3                	jne    536 <strcat+0x24>
    *dest++ = *q++;
  }  
 553:	5d                   	pop    %ebp
 554:	c3                   	ret    
 555:	90                   	nop
 556:	90                   	nop
 557:	90                   	nop

00000558 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 558:	b8 01 00 00 00       	mov    $0x1,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <exit>:
SYSCALL(exit)
 560:	b8 02 00 00 00       	mov    $0x2,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <wait>:
SYSCALL(wait)
 568:	b8 03 00 00 00       	mov    $0x3,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <wait2>:
SYSCALL(wait2)
 570:	b8 16 00 00 00       	mov    $0x16,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <nice>:
SYSCALL(nice)
 578:	b8 17 00 00 00       	mov    $0x17,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <pipe>:
SYSCALL(pipe)
 580:	b8 04 00 00 00       	mov    $0x4,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <read>:
SYSCALL(read)
 588:	b8 05 00 00 00       	mov    $0x5,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <write>:
SYSCALL(write)
 590:	b8 10 00 00 00       	mov    $0x10,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <close>:
SYSCALL(close)
 598:	b8 15 00 00 00       	mov    $0x15,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <kill>:
SYSCALL(kill)
 5a0:	b8 06 00 00 00       	mov    $0x6,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <exec>:
SYSCALL(exec)
 5a8:	b8 07 00 00 00       	mov    $0x7,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <open>:
SYSCALL(open)
 5b0:	b8 0f 00 00 00       	mov    $0xf,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <mknod>:
SYSCALL(mknod)
 5b8:	b8 11 00 00 00       	mov    $0x11,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <unlink>:
SYSCALL(unlink)
 5c0:	b8 12 00 00 00       	mov    $0x12,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <fstat>:
SYSCALL(fstat)
 5c8:	b8 08 00 00 00       	mov    $0x8,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <link>:
SYSCALL(link)
 5d0:	b8 13 00 00 00       	mov    $0x13,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <mkdir>:
SYSCALL(mkdir)
 5d8:	b8 14 00 00 00       	mov    $0x14,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <chdir>:
SYSCALL(chdir)
 5e0:	b8 09 00 00 00       	mov    $0x9,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <dup>:
SYSCALL(dup)
 5e8:	b8 0a 00 00 00       	mov    $0xa,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <getpid>:
SYSCALL(getpid)
 5f0:	b8 0b 00 00 00       	mov    $0xb,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <sbrk>:
SYSCALL(sbrk)
 5f8:	b8 0c 00 00 00       	mov    $0xc,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <sleep>:
SYSCALL(sleep)
 600:	b8 0d 00 00 00       	mov    $0xd,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <uptime>:
SYSCALL(uptime)
 608:	b8 0e 00 00 00       	mov    $0xe,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 610:	55                   	push   %ebp
 611:	89 e5                	mov    %esp,%ebp
 613:	83 ec 28             	sub    $0x28,%esp
 616:	8b 45 0c             	mov    0xc(%ebp),%eax
 619:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 61c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 623:	00 
 624:	8d 45 f4             	lea    -0xc(%ebp),%eax
 627:	89 44 24 04          	mov    %eax,0x4(%esp)
 62b:	8b 45 08             	mov    0x8(%ebp),%eax
 62e:	89 04 24             	mov    %eax,(%esp)
 631:	e8 5a ff ff ff       	call   590 <write>
}
 636:	c9                   	leave  
 637:	c3                   	ret    

00000638 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 638:	55                   	push   %ebp
 639:	89 e5                	mov    %esp,%ebp
 63b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 63e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 645:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 649:	74 17                	je     662 <printint+0x2a>
 64b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 64f:	79 11                	jns    662 <printint+0x2a>
    neg = 1;
 651:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 658:	8b 45 0c             	mov    0xc(%ebp),%eax
 65b:	f7 d8                	neg    %eax
 65d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 660:	eb 06                	jmp    668 <printint+0x30>
  } else {
    x = xx;
 662:	8b 45 0c             	mov    0xc(%ebp),%eax
 665:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 668:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 66f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 672:	8b 45 ec             	mov    -0x14(%ebp),%eax
 675:	ba 00 00 00 00       	mov    $0x0,%edx
 67a:	f7 f1                	div    %ecx
 67c:	89 d0                	mov    %edx,%eax
 67e:	0f b6 90 24 0e 00 00 	movzbl 0xe24(%eax),%edx
 685:	8d 45 dc             	lea    -0x24(%ebp),%eax
 688:	03 45 f4             	add    -0xc(%ebp),%eax
 68b:	88 10                	mov    %dl,(%eax)
 68d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 691:	8b 55 10             	mov    0x10(%ebp),%edx
 694:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 697:	8b 45 ec             	mov    -0x14(%ebp),%eax
 69a:	ba 00 00 00 00       	mov    $0x0,%edx
 69f:	f7 75 d4             	divl   -0x2c(%ebp)
 6a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6a9:	75 c4                	jne    66f <printint+0x37>
  if(neg)
 6ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6af:	74 2a                	je     6db <printint+0xa3>
    buf[i++] = '-';
 6b1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6b4:	03 45 f4             	add    -0xc(%ebp),%eax
 6b7:	c6 00 2d             	movb   $0x2d,(%eax)
 6ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 6be:	eb 1b                	jmp    6db <printint+0xa3>
    putc(fd, buf[i]);
 6c0:	8d 45 dc             	lea    -0x24(%ebp),%eax
 6c3:	03 45 f4             	add    -0xc(%ebp),%eax
 6c6:	0f b6 00             	movzbl (%eax),%eax
 6c9:	0f be c0             	movsbl %al,%eax
 6cc:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d0:	8b 45 08             	mov    0x8(%ebp),%eax
 6d3:	89 04 24             	mov    %eax,(%esp)
 6d6:	e8 35 ff ff ff       	call   610 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 6db:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 6df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6e3:	79 db                	jns    6c0 <printint+0x88>
    putc(fd, buf[i]);
}
 6e5:	c9                   	leave  
 6e6:	c3                   	ret    

000006e7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6e7:	55                   	push   %ebp
 6e8:	89 e5                	mov    %esp,%ebp
 6ea:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6ed:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6f4:	8d 45 0c             	lea    0xc(%ebp),%eax
 6f7:	83 c0 04             	add    $0x4,%eax
 6fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 704:	e9 7d 01 00 00       	jmp    886 <printf+0x19f>
    c = fmt[i] & 0xff;
 709:	8b 55 0c             	mov    0xc(%ebp),%edx
 70c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 70f:	01 d0                	add    %edx,%eax
 711:	0f b6 00             	movzbl (%eax),%eax
 714:	0f be c0             	movsbl %al,%eax
 717:	25 ff 00 00 00       	and    $0xff,%eax
 71c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 71f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 723:	75 2c                	jne    751 <printf+0x6a>
      if(c == '%'){
 725:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 729:	75 0c                	jne    737 <printf+0x50>
        state = '%';
 72b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 732:	e9 4b 01 00 00       	jmp    882 <printf+0x19b>
      } else {
        putc(fd, c);
 737:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 73a:	0f be c0             	movsbl %al,%eax
 73d:	89 44 24 04          	mov    %eax,0x4(%esp)
 741:	8b 45 08             	mov    0x8(%ebp),%eax
 744:	89 04 24             	mov    %eax,(%esp)
 747:	e8 c4 fe ff ff       	call   610 <putc>
 74c:	e9 31 01 00 00       	jmp    882 <printf+0x19b>
      }
    } else if(state == '%'){
 751:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 755:	0f 85 27 01 00 00    	jne    882 <printf+0x19b>
      if(c == 'd'){
 75b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 75f:	75 2d                	jne    78e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 761:	8b 45 e8             	mov    -0x18(%ebp),%eax
 764:	8b 00                	mov    (%eax),%eax
 766:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 76d:	00 
 76e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 775:	00 
 776:	89 44 24 04          	mov    %eax,0x4(%esp)
 77a:	8b 45 08             	mov    0x8(%ebp),%eax
 77d:	89 04 24             	mov    %eax,(%esp)
 780:	e8 b3 fe ff ff       	call   638 <printint>
        ap++;
 785:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 789:	e9 ed 00 00 00       	jmp    87b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 78e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 792:	74 06                	je     79a <printf+0xb3>
 794:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 798:	75 2d                	jne    7c7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 79a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 79d:	8b 00                	mov    (%eax),%eax
 79f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7a6:	00 
 7a7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7ae:	00 
 7af:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b3:	8b 45 08             	mov    0x8(%ebp),%eax
 7b6:	89 04 24             	mov    %eax,(%esp)
 7b9:	e8 7a fe ff ff       	call   638 <printint>
        ap++;
 7be:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7c2:	e9 b4 00 00 00       	jmp    87b <printf+0x194>
      } else if(c == 's'){
 7c7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7cb:	75 46                	jne    813 <printf+0x12c>
        s = (char*)*ap;
 7cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d0:	8b 00                	mov    (%eax),%eax
 7d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7d5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 7d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7dd:	75 27                	jne    806 <printf+0x11f>
          s = "(null)";
 7df:	c7 45 f4 1d 0b 00 00 	movl   $0xb1d,-0xc(%ebp)
        while(*s != 0){
 7e6:	eb 1e                	jmp    806 <printf+0x11f>
          putc(fd, *s);
 7e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7eb:	0f b6 00             	movzbl (%eax),%eax
 7ee:	0f be c0             	movsbl %al,%eax
 7f1:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f5:	8b 45 08             	mov    0x8(%ebp),%eax
 7f8:	89 04 24             	mov    %eax,(%esp)
 7fb:	e8 10 fe ff ff       	call   610 <putc>
          s++;
 800:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 804:	eb 01                	jmp    807 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 806:	90                   	nop
 807:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80a:	0f b6 00             	movzbl (%eax),%eax
 80d:	84 c0                	test   %al,%al
 80f:	75 d7                	jne    7e8 <printf+0x101>
 811:	eb 68                	jmp    87b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 813:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 817:	75 1d                	jne    836 <printf+0x14f>
        putc(fd, *ap);
 819:	8b 45 e8             	mov    -0x18(%ebp),%eax
 81c:	8b 00                	mov    (%eax),%eax
 81e:	0f be c0             	movsbl %al,%eax
 821:	89 44 24 04          	mov    %eax,0x4(%esp)
 825:	8b 45 08             	mov    0x8(%ebp),%eax
 828:	89 04 24             	mov    %eax,(%esp)
 82b:	e8 e0 fd ff ff       	call   610 <putc>
        ap++;
 830:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 834:	eb 45                	jmp    87b <printf+0x194>
      } else if(c == '%'){
 836:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 83a:	75 17                	jne    853 <printf+0x16c>
        putc(fd, c);
 83c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 83f:	0f be c0             	movsbl %al,%eax
 842:	89 44 24 04          	mov    %eax,0x4(%esp)
 846:	8b 45 08             	mov    0x8(%ebp),%eax
 849:	89 04 24             	mov    %eax,(%esp)
 84c:	e8 bf fd ff ff       	call   610 <putc>
 851:	eb 28                	jmp    87b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 853:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 85a:	00 
 85b:	8b 45 08             	mov    0x8(%ebp),%eax
 85e:	89 04 24             	mov    %eax,(%esp)
 861:	e8 aa fd ff ff       	call   610 <putc>
        putc(fd, c);
 866:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 869:	0f be c0             	movsbl %al,%eax
 86c:	89 44 24 04          	mov    %eax,0x4(%esp)
 870:	8b 45 08             	mov    0x8(%ebp),%eax
 873:	89 04 24             	mov    %eax,(%esp)
 876:	e8 95 fd ff ff       	call   610 <putc>
      }
      state = 0;
 87b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 882:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 886:	8b 55 0c             	mov    0xc(%ebp),%edx
 889:	8b 45 f0             	mov    -0x10(%ebp),%eax
 88c:	01 d0                	add    %edx,%eax
 88e:	0f b6 00             	movzbl (%eax),%eax
 891:	84 c0                	test   %al,%al
 893:	0f 85 70 fe ff ff    	jne    709 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 899:	c9                   	leave  
 89a:	c3                   	ret    
 89b:	90                   	nop

0000089c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 89c:	55                   	push   %ebp
 89d:	89 e5                	mov    %esp,%ebp
 89f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8a2:	8b 45 08             	mov    0x8(%ebp),%eax
 8a5:	83 e8 08             	sub    $0x8,%eax
 8a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ab:	a1 40 0e 00 00       	mov    0xe40,%eax
 8b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8b3:	eb 24                	jmp    8d9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b8:	8b 00                	mov    (%eax),%eax
 8ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8bd:	77 12                	ja     8d1 <free+0x35>
 8bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8c5:	77 24                	ja     8eb <free+0x4f>
 8c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ca:	8b 00                	mov    (%eax),%eax
 8cc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8cf:	77 1a                	ja     8eb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d4:	8b 00                	mov    (%eax),%eax
 8d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8dc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8df:	76 d4                	jbe    8b5 <free+0x19>
 8e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e4:	8b 00                	mov    (%eax),%eax
 8e6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8e9:	76 ca                	jbe    8b5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ee:	8b 40 04             	mov    0x4(%eax),%eax
 8f1:	c1 e0 03             	shl    $0x3,%eax
 8f4:	89 c2                	mov    %eax,%edx
 8f6:	03 55 f8             	add    -0x8(%ebp),%edx
 8f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fc:	8b 00                	mov    (%eax),%eax
 8fe:	39 c2                	cmp    %eax,%edx
 900:	75 24                	jne    926 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 902:	8b 45 f8             	mov    -0x8(%ebp),%eax
 905:	8b 50 04             	mov    0x4(%eax),%edx
 908:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90b:	8b 00                	mov    (%eax),%eax
 90d:	8b 40 04             	mov    0x4(%eax),%eax
 910:	01 c2                	add    %eax,%edx
 912:	8b 45 f8             	mov    -0x8(%ebp),%eax
 915:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 918:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91b:	8b 00                	mov    (%eax),%eax
 91d:	8b 10                	mov    (%eax),%edx
 91f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 922:	89 10                	mov    %edx,(%eax)
 924:	eb 0a                	jmp    930 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 926:	8b 45 fc             	mov    -0x4(%ebp),%eax
 929:	8b 10                	mov    (%eax),%edx
 92b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 930:	8b 45 fc             	mov    -0x4(%ebp),%eax
 933:	8b 40 04             	mov    0x4(%eax),%eax
 936:	c1 e0 03             	shl    $0x3,%eax
 939:	03 45 fc             	add    -0x4(%ebp),%eax
 93c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 93f:	75 20                	jne    961 <free+0xc5>
    p->s.size += bp->s.size;
 941:	8b 45 fc             	mov    -0x4(%ebp),%eax
 944:	8b 50 04             	mov    0x4(%eax),%edx
 947:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94a:	8b 40 04             	mov    0x4(%eax),%eax
 94d:	01 c2                	add    %eax,%edx
 94f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 952:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 955:	8b 45 f8             	mov    -0x8(%ebp),%eax
 958:	8b 10                	mov    (%eax),%edx
 95a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95d:	89 10                	mov    %edx,(%eax)
 95f:	eb 08                	jmp    969 <free+0xcd>
  } else
    p->s.ptr = bp;
 961:	8b 45 fc             	mov    -0x4(%ebp),%eax
 964:	8b 55 f8             	mov    -0x8(%ebp),%edx
 967:	89 10                	mov    %edx,(%eax)
  freep = p;
 969:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96c:	a3 40 0e 00 00       	mov    %eax,0xe40
}
 971:	c9                   	leave  
 972:	c3                   	ret    

00000973 <morecore>:

static Header*
morecore(uint nu)
{
 973:	55                   	push   %ebp
 974:	89 e5                	mov    %esp,%ebp
 976:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 979:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 980:	77 07                	ja     989 <morecore+0x16>
    nu = 4096;
 982:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 989:	8b 45 08             	mov    0x8(%ebp),%eax
 98c:	c1 e0 03             	shl    $0x3,%eax
 98f:	89 04 24             	mov    %eax,(%esp)
 992:	e8 61 fc ff ff       	call   5f8 <sbrk>
 997:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 99a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 99e:	75 07                	jne    9a7 <morecore+0x34>
    return 0;
 9a0:	b8 00 00 00 00       	mov    $0x0,%eax
 9a5:	eb 22                	jmp    9c9 <morecore+0x56>
  hp = (Header*)p;
 9a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b0:	8b 55 08             	mov    0x8(%ebp),%edx
 9b3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b9:	83 c0 08             	add    $0x8,%eax
 9bc:	89 04 24             	mov    %eax,(%esp)
 9bf:	e8 d8 fe ff ff       	call   89c <free>
  return freep;
 9c4:	a1 40 0e 00 00       	mov    0xe40,%eax
}
 9c9:	c9                   	leave  
 9ca:	c3                   	ret    

000009cb <malloc>:

void*
malloc(uint nbytes)
{
 9cb:	55                   	push   %ebp
 9cc:	89 e5                	mov    %esp,%ebp
 9ce:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9d1:	8b 45 08             	mov    0x8(%ebp),%eax
 9d4:	83 c0 07             	add    $0x7,%eax
 9d7:	c1 e8 03             	shr    $0x3,%eax
 9da:	83 c0 01             	add    $0x1,%eax
 9dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9e0:	a1 40 0e 00 00       	mov    0xe40,%eax
 9e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9ec:	75 23                	jne    a11 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9ee:	c7 45 f0 38 0e 00 00 	movl   $0xe38,-0x10(%ebp)
 9f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f8:	a3 40 0e 00 00       	mov    %eax,0xe40
 9fd:	a1 40 0e 00 00       	mov    0xe40,%eax
 a02:	a3 38 0e 00 00       	mov    %eax,0xe38
    base.s.size = 0;
 a07:	c7 05 3c 0e 00 00 00 	movl   $0x0,0xe3c
 a0e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a11:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a14:	8b 00                	mov    (%eax),%eax
 a16:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1c:	8b 40 04             	mov    0x4(%eax),%eax
 a1f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a22:	72 4d                	jb     a71 <malloc+0xa6>
      if(p->s.size == nunits)
 a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a27:	8b 40 04             	mov    0x4(%eax),%eax
 a2a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a2d:	75 0c                	jne    a3b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a32:	8b 10                	mov    (%eax),%edx
 a34:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a37:	89 10                	mov    %edx,(%eax)
 a39:	eb 26                	jmp    a61 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3e:	8b 40 04             	mov    0x4(%eax),%eax
 a41:	89 c2                	mov    %eax,%edx
 a43:	2b 55 ec             	sub    -0x14(%ebp),%edx
 a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a49:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4f:	8b 40 04             	mov    0x4(%eax),%eax
 a52:	c1 e0 03             	shl    $0x3,%eax
 a55:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a5e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a64:	a3 40 0e 00 00       	mov    %eax,0xe40
      return (void*)(p + 1);
 a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6c:	83 c0 08             	add    $0x8,%eax
 a6f:	eb 38                	jmp    aa9 <malloc+0xde>
    }
    if(p == freep)
 a71:	a1 40 0e 00 00       	mov    0xe40,%eax
 a76:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a79:	75 1b                	jne    a96 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a7e:	89 04 24             	mov    %eax,(%esp)
 a81:	e8 ed fe ff ff       	call   973 <morecore>
 a86:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a89:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a8d:	75 07                	jne    a96 <malloc+0xcb>
        return 0;
 a8f:	b8 00 00 00 00       	mov    $0x0,%eax
 a94:	eb 13                	jmp    aa9 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a99:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9f:	8b 00                	mov    (%eax),%eax
 aa1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 aa4:	e9 70 ff ff ff       	jmp    a19 <malloc+0x4e>
}
 aa9:	c9                   	leave  
 aaa:	c3                   	ret    
