
_grep:     file format elf32-i386


Disassembly of section .text:

00000000 <grep>:
char buf[1024];
int match(char*, char*);

void
grep(char *pattern, int fd)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
  int n, m;
  char *p, *q;
  
  m = 0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
   d:	e9 bf 00 00 00       	jmp    d1 <grep+0xd1>
    m += n;
  12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  15:	01 45 f4             	add    %eax,-0xc(%ebp)
    p = buf;
  18:	c7 45 f0 60 10 00 00 	movl   $0x1060,-0x10(%ebp)
    while((q = strchr(p, '\n')) != 0){
  1f:	eb 53                	jmp    74 <grep+0x74>
      *q = 0;
  21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  24:	c6 00 00             	movb   $0x0,(%eax)
      if(match(pattern, p)){
  27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  2e:	8b 45 08             	mov    0x8(%ebp),%eax
  31:	89 04 24             	mov    %eax,(%esp)
  34:	e8 af 01 00 00       	call   1e8 <match>
  39:	85 c0                	test   %eax,%eax
  3b:	74 2e                	je     6b <grep+0x6b>
        *q = '\n';
  3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  40:	c6 00 0a             	movb   $0xa,(%eax)
        write(1, p, q+1 - p);
  43:	8b 45 e8             	mov    -0x18(%ebp),%eax
  46:	83 c0 01             	add    $0x1,%eax
  49:	89 c2                	mov    %eax,%edx
  4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  4e:	89 d1                	mov    %edx,%ecx
  50:	29 c1                	sub    %eax,%ecx
  52:	89 c8                	mov    %ecx,%eax
  54:	89 44 24 08          	mov    %eax,0x8(%esp)
  58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  66:	e8 15 07 00 00       	call   780 <write>
      }
      p = q+1;
  6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  6e:	83 c0 01             	add    $0x1,%eax
  71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
    m += n;
    p = buf;
    while((q = strchr(p, '\n')) != 0){
  74:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  7b:	00 
  7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  7f:	89 04 24             	mov    %eax,(%esp)
  82:	e8 ac 03 00 00       	call   433 <strchr>
  87:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8e:	75 91                	jne    21 <grep+0x21>
        *q = '\n';
        write(1, p, q+1 - p);
      }
      p = q+1;
    }
    if(p == buf)
  90:	81 7d f0 60 10 00 00 	cmpl   $0x1060,-0x10(%ebp)
  97:	75 07                	jne    a0 <grep+0xa0>
      m = 0;
  99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(m > 0){
  a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  a4:	7e 2b                	jle    d1 <grep+0xd1>
      m -= p - buf;
  a6:	ba 60 10 00 00       	mov    $0x1060,%edx
  ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ae:	89 d1                	mov    %edx,%ecx
  b0:	29 c1                	sub    %eax,%ecx
  b2:	89 c8                	mov    %ecx,%eax
  b4:	01 45 f4             	add    %eax,-0xc(%ebp)
      memmove(buf, p, m);
  b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  c5:	c7 04 24 60 10 00 00 	movl   $0x1060,(%esp)
  cc:	e8 9d 04 00 00       	call   56e <memmove>
{
  int n, m;
  char *p, *q;
  
  m = 0;
  while((n = read(fd, buf+m, sizeof(buf)-m)) > 0){
  d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d4:	ba 00 04 00 00       	mov    $0x400,%edx
  d9:	89 d1                	mov    %edx,%ecx
  db:	29 c1                	sub    %eax,%ecx
  dd:	89 c8                	mov    %ecx,%eax
  df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  e2:	81 c2 60 10 00 00    	add    $0x1060,%edx
  e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	89 04 24             	mov    %eax,(%esp)
  f6:	e8 7d 06 00 00       	call   778 <read>
  fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 102:	0f 8f 0a ff ff ff    	jg     12 <grep+0x12>
    if(m > 0){
      m -= p - buf;
      memmove(buf, p, m);
    }
  }
}
 108:	c9                   	leave  
 109:	c3                   	ret    

0000010a <main>:

int
main(int argc, char *argv[])
{
 10a:	55                   	push   %ebp
 10b:	89 e5                	mov    %esp,%ebp
 10d:	83 e4 f0             	and    $0xfffffff0,%esp
 110:	83 ec 20             	sub    $0x20,%esp
  int fd, i;
  char *pattern;
  
  if(argc <= 1){
 113:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 117:	7f 19                	jg     132 <main+0x28>
    printf(2, "usage: grep pattern [file ...]\n");
 119:	c7 44 24 04 9c 0c 00 	movl   $0xc9c,0x4(%esp)
 120:	00 
 121:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 128:	e8 aa 07 00 00       	call   8d7 <printf>
    exit();
 12d:	e8 1e 06 00 00       	call   750 <exit>
  }
  pattern = argv[1];
 132:	8b 45 0c             	mov    0xc(%ebp),%eax
 135:	8b 40 04             	mov    0x4(%eax),%eax
 138:	89 44 24 18          	mov    %eax,0x18(%esp)
  
  if(argc <= 2){
 13c:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 140:	7f 19                	jg     15b <main+0x51>
    grep(pattern, 0);
 142:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 149:	00 
 14a:	8b 44 24 18          	mov    0x18(%esp),%eax
 14e:	89 04 24             	mov    %eax,(%esp)
 151:	e8 aa fe ff ff       	call   0 <grep>
    exit();
 156:	e8 f5 05 00 00       	call   750 <exit>
  }

  for(i = 2; i < argc; i++){
 15b:	c7 44 24 1c 02 00 00 	movl   $0x2,0x1c(%esp)
 162:	00 
 163:	eb 75                	jmp    1da <main+0xd0>
    if((fd = open(argv[i], 0)) < 0){
 165:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 169:	c1 e0 02             	shl    $0x2,%eax
 16c:	03 45 0c             	add    0xc(%ebp),%eax
 16f:	8b 00                	mov    (%eax),%eax
 171:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 178:	00 
 179:	89 04 24             	mov    %eax,(%esp)
 17c:	e8 1f 06 00 00       	call   7a0 <open>
 181:	89 44 24 14          	mov    %eax,0x14(%esp)
 185:	83 7c 24 14 00       	cmpl   $0x0,0x14(%esp)
 18a:	79 29                	jns    1b5 <main+0xab>
      printf(1, "grep: cannot open %s\n", argv[i]);
 18c:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 190:	c1 e0 02             	shl    $0x2,%eax
 193:	03 45 0c             	add    0xc(%ebp),%eax
 196:	8b 00                	mov    (%eax),%eax
 198:	89 44 24 08          	mov    %eax,0x8(%esp)
 19c:	c7 44 24 04 bc 0c 00 	movl   $0xcbc,0x4(%esp)
 1a3:	00 
 1a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1ab:	e8 27 07 00 00       	call   8d7 <printf>
      exit();
 1b0:	e8 9b 05 00 00       	call   750 <exit>
    }
    grep(pattern, fd);
 1b5:	8b 44 24 14          	mov    0x14(%esp),%eax
 1b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 1bd:	8b 44 24 18          	mov    0x18(%esp),%eax
 1c1:	89 04 24             	mov    %eax,(%esp)
 1c4:	e8 37 fe ff ff       	call   0 <grep>
    close(fd);
 1c9:	8b 44 24 14          	mov    0x14(%esp),%eax
 1cd:	89 04 24             	mov    %eax,(%esp)
 1d0:	e8 b3 05 00 00       	call   788 <close>
  if(argc <= 2){
    grep(pattern, 0);
    exit();
  }

  for(i = 2; i < argc; i++){
 1d5:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1da:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1de:	3b 45 08             	cmp    0x8(%ebp),%eax
 1e1:	7c 82                	jl     165 <main+0x5b>
      exit();
    }
    grep(pattern, fd);
    close(fd);
  }
  exit();
 1e3:	e8 68 05 00 00       	call   750 <exit>

000001e8 <match>:
int matchhere(char*, char*);
int matchstar(int, char*, char*);

int
match(char *re, char *text)
{
 1e8:	55                   	push   %ebp
 1e9:	89 e5                	mov    %esp,%ebp
 1eb:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '^')
 1ee:	8b 45 08             	mov    0x8(%ebp),%eax
 1f1:	0f b6 00             	movzbl (%eax),%eax
 1f4:	3c 5e                	cmp    $0x5e,%al
 1f6:	75 17                	jne    20f <match+0x27>
    return matchhere(re+1, text);
 1f8:	8b 45 08             	mov    0x8(%ebp),%eax
 1fb:	8d 50 01             	lea    0x1(%eax),%edx
 1fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 201:	89 44 24 04          	mov    %eax,0x4(%esp)
 205:	89 14 24             	mov    %edx,(%esp)
 208:	e8 39 00 00 00       	call   246 <matchhere>
 20d:	eb 35                	jmp    244 <match+0x5c>
  do{  // must look at empty string
    if(matchhere(re, text))
 20f:	8b 45 0c             	mov    0xc(%ebp),%eax
 212:	89 44 24 04          	mov    %eax,0x4(%esp)
 216:	8b 45 08             	mov    0x8(%ebp),%eax
 219:	89 04 24             	mov    %eax,(%esp)
 21c:	e8 25 00 00 00       	call   246 <matchhere>
 221:	85 c0                	test   %eax,%eax
 223:	74 07                	je     22c <match+0x44>
      return 1;
 225:	b8 01 00 00 00       	mov    $0x1,%eax
 22a:	eb 18                	jmp    244 <match+0x5c>
  }while(*text++ != '\0');
 22c:	8b 45 0c             	mov    0xc(%ebp),%eax
 22f:	0f b6 00             	movzbl (%eax),%eax
 232:	84 c0                	test   %al,%al
 234:	0f 95 c0             	setne  %al
 237:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 23b:	84 c0                	test   %al,%al
 23d:	75 d0                	jne    20f <match+0x27>
  return 0;
 23f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 244:	c9                   	leave  
 245:	c3                   	ret    

00000246 <matchhere>:

// matchhere: search for re at beginning of text
int matchhere(char *re, char *text)
{
 246:	55                   	push   %ebp
 247:	89 e5                	mov    %esp,%ebp
 249:	83 ec 18             	sub    $0x18,%esp
  if(re[0] == '\0')
 24c:	8b 45 08             	mov    0x8(%ebp),%eax
 24f:	0f b6 00             	movzbl (%eax),%eax
 252:	84 c0                	test   %al,%al
 254:	75 0a                	jne    260 <matchhere+0x1a>
    return 1;
 256:	b8 01 00 00 00       	mov    $0x1,%eax
 25b:	e9 9b 00 00 00       	jmp    2fb <matchhere+0xb5>
  if(re[1] == '*')
 260:	8b 45 08             	mov    0x8(%ebp),%eax
 263:	83 c0 01             	add    $0x1,%eax
 266:	0f b6 00             	movzbl (%eax),%eax
 269:	3c 2a                	cmp    $0x2a,%al
 26b:	75 24                	jne    291 <matchhere+0x4b>
    return matchstar(re[0], re+2, text);
 26d:	8b 45 08             	mov    0x8(%ebp),%eax
 270:	8d 48 02             	lea    0x2(%eax),%ecx
 273:	8b 45 08             	mov    0x8(%ebp),%eax
 276:	0f b6 00             	movzbl (%eax),%eax
 279:	0f be c0             	movsbl %al,%eax
 27c:	8b 55 0c             	mov    0xc(%ebp),%edx
 27f:	89 54 24 08          	mov    %edx,0x8(%esp)
 283:	89 4c 24 04          	mov    %ecx,0x4(%esp)
 287:	89 04 24             	mov    %eax,(%esp)
 28a:	e8 6e 00 00 00       	call   2fd <matchstar>
 28f:	eb 6a                	jmp    2fb <matchhere+0xb5>
  if(re[0] == '$' && re[1] == '\0')
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	0f b6 00             	movzbl (%eax),%eax
 297:	3c 24                	cmp    $0x24,%al
 299:	75 1d                	jne    2b8 <matchhere+0x72>
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	83 c0 01             	add    $0x1,%eax
 2a1:	0f b6 00             	movzbl (%eax),%eax
 2a4:	84 c0                	test   %al,%al
 2a6:	75 10                	jne    2b8 <matchhere+0x72>
    return *text == '\0';
 2a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ab:	0f b6 00             	movzbl (%eax),%eax
 2ae:	84 c0                	test   %al,%al
 2b0:	0f 94 c0             	sete   %al
 2b3:	0f b6 c0             	movzbl %al,%eax
 2b6:	eb 43                	jmp    2fb <matchhere+0xb5>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 2b8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2bb:	0f b6 00             	movzbl (%eax),%eax
 2be:	84 c0                	test   %al,%al
 2c0:	74 34                	je     2f6 <matchhere+0xb0>
 2c2:	8b 45 08             	mov    0x8(%ebp),%eax
 2c5:	0f b6 00             	movzbl (%eax),%eax
 2c8:	3c 2e                	cmp    $0x2e,%al
 2ca:	74 10                	je     2dc <matchhere+0x96>
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
 2cf:	0f b6 10             	movzbl (%eax),%edx
 2d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d5:	0f b6 00             	movzbl (%eax),%eax
 2d8:	38 c2                	cmp    %al,%dl
 2da:	75 1a                	jne    2f6 <matchhere+0xb0>
    return matchhere(re+1, text+1);
 2dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2df:	8d 50 01             	lea    0x1(%eax),%edx
 2e2:	8b 45 08             	mov    0x8(%ebp),%eax
 2e5:	83 c0 01             	add    $0x1,%eax
 2e8:	89 54 24 04          	mov    %edx,0x4(%esp)
 2ec:	89 04 24             	mov    %eax,(%esp)
 2ef:	e8 52 ff ff ff       	call   246 <matchhere>
 2f4:	eb 05                	jmp    2fb <matchhere+0xb5>
  return 0;
 2f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2fb:	c9                   	leave  
 2fc:	c3                   	ret    

000002fd <matchstar>:

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
 2fd:	55                   	push   %ebp
 2fe:	89 e5                	mov    %esp,%ebp
 300:	83 ec 18             	sub    $0x18,%esp
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
 303:	8b 45 10             	mov    0x10(%ebp),%eax
 306:	89 44 24 04          	mov    %eax,0x4(%esp)
 30a:	8b 45 0c             	mov    0xc(%ebp),%eax
 30d:	89 04 24             	mov    %eax,(%esp)
 310:	e8 31 ff ff ff       	call   246 <matchhere>
 315:	85 c0                	test   %eax,%eax
 317:	74 07                	je     320 <matchstar+0x23>
      return 1;
 319:	b8 01 00 00 00       	mov    $0x1,%eax
 31e:	eb 2c                	jmp    34c <matchstar+0x4f>
  }while(*text!='\0' && (*text++==c || c=='.'));
 320:	8b 45 10             	mov    0x10(%ebp),%eax
 323:	0f b6 00             	movzbl (%eax),%eax
 326:	84 c0                	test   %al,%al
 328:	74 1d                	je     347 <matchstar+0x4a>
 32a:	8b 45 10             	mov    0x10(%ebp),%eax
 32d:	0f b6 00             	movzbl (%eax),%eax
 330:	0f be c0             	movsbl %al,%eax
 333:	3b 45 08             	cmp    0x8(%ebp),%eax
 336:	0f 94 c0             	sete   %al
 339:	83 45 10 01          	addl   $0x1,0x10(%ebp)
 33d:	84 c0                	test   %al,%al
 33f:	75 c2                	jne    303 <matchstar+0x6>
 341:	83 7d 08 2e          	cmpl   $0x2e,0x8(%ebp)
 345:	74 bc                	je     303 <matchstar+0x6>
  return 0;
 347:	b8 00 00 00 00       	mov    $0x0,%eax
}
 34c:	c9                   	leave  
 34d:	c3                   	ret    
 34e:	90                   	nop
 34f:	90                   	nop

00000350 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 350:	55                   	push   %ebp
 351:	89 e5                	mov    %esp,%ebp
 353:	57                   	push   %edi
 354:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 355:	8b 4d 08             	mov    0x8(%ebp),%ecx
 358:	8b 55 10             	mov    0x10(%ebp),%edx
 35b:	8b 45 0c             	mov    0xc(%ebp),%eax
 35e:	89 cb                	mov    %ecx,%ebx
 360:	89 df                	mov    %ebx,%edi
 362:	89 d1                	mov    %edx,%ecx
 364:	fc                   	cld    
 365:	f3 aa                	rep stos %al,%es:(%edi)
 367:	89 ca                	mov    %ecx,%edx
 369:	89 fb                	mov    %edi,%ebx
 36b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 36e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 371:	5b                   	pop    %ebx
 372:	5f                   	pop    %edi
 373:	5d                   	pop    %ebp
 374:	c3                   	ret    

00000375 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 375:	55                   	push   %ebp
 376:	89 e5                	mov    %esp,%ebp
 378:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
 37e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 381:	90                   	nop
 382:	8b 45 0c             	mov    0xc(%ebp),%eax
 385:	0f b6 10             	movzbl (%eax),%edx
 388:	8b 45 08             	mov    0x8(%ebp),%eax
 38b:	88 10                	mov    %dl,(%eax)
 38d:	8b 45 08             	mov    0x8(%ebp),%eax
 390:	0f b6 00             	movzbl (%eax),%eax
 393:	84 c0                	test   %al,%al
 395:	0f 95 c0             	setne  %al
 398:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 39c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3a0:	84 c0                	test   %al,%al
 3a2:	75 de                	jne    382 <strcpy+0xd>
    ;
  return os;
 3a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a7:	c9                   	leave  
 3a8:	c3                   	ret    

000003a9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3a9:	55                   	push   %ebp
 3aa:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3ac:	eb 08                	jmp    3b6 <strcmp+0xd>
    p++, q++;
 3ae:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3b2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3b6:	8b 45 08             	mov    0x8(%ebp),%eax
 3b9:	0f b6 00             	movzbl (%eax),%eax
 3bc:	84 c0                	test   %al,%al
 3be:	74 10                	je     3d0 <strcmp+0x27>
 3c0:	8b 45 08             	mov    0x8(%ebp),%eax
 3c3:	0f b6 10             	movzbl (%eax),%edx
 3c6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c9:	0f b6 00             	movzbl (%eax),%eax
 3cc:	38 c2                	cmp    %al,%dl
 3ce:	74 de                	je     3ae <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3d0:	8b 45 08             	mov    0x8(%ebp),%eax
 3d3:	0f b6 00             	movzbl (%eax),%eax
 3d6:	0f b6 d0             	movzbl %al,%edx
 3d9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3dc:	0f b6 00             	movzbl (%eax),%eax
 3df:	0f b6 c0             	movzbl %al,%eax
 3e2:	89 d1                	mov    %edx,%ecx
 3e4:	29 c1                	sub    %eax,%ecx
 3e6:	89 c8                	mov    %ecx,%eax
}
 3e8:	5d                   	pop    %ebp
 3e9:	c3                   	ret    

000003ea <strlen>:

uint
strlen(char *s)
{
 3ea:	55                   	push   %ebp
 3eb:	89 e5                	mov    %esp,%ebp
 3ed:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 3f0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3f7:	eb 04                	jmp    3fd <strlen+0x13>
 3f9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 3fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 400:	03 45 08             	add    0x8(%ebp),%eax
 403:	0f b6 00             	movzbl (%eax),%eax
 406:	84 c0                	test   %al,%al
 408:	75 ef                	jne    3f9 <strlen+0xf>
  return n;
 40a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 40d:	c9                   	leave  
 40e:	c3                   	ret    

0000040f <memset>:

void*
memset(void *dst, int c, uint n)
{
 40f:	55                   	push   %ebp
 410:	89 e5                	mov    %esp,%ebp
 412:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 415:	8b 45 10             	mov    0x10(%ebp),%eax
 418:	89 44 24 08          	mov    %eax,0x8(%esp)
 41c:	8b 45 0c             	mov    0xc(%ebp),%eax
 41f:	89 44 24 04          	mov    %eax,0x4(%esp)
 423:	8b 45 08             	mov    0x8(%ebp),%eax
 426:	89 04 24             	mov    %eax,(%esp)
 429:	e8 22 ff ff ff       	call   350 <stosb>
  return dst;
 42e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 431:	c9                   	leave  
 432:	c3                   	ret    

00000433 <strchr>:

char*
strchr(const char *s, char c)
{
 433:	55                   	push   %ebp
 434:	89 e5                	mov    %esp,%ebp
 436:	83 ec 04             	sub    $0x4,%esp
 439:	8b 45 0c             	mov    0xc(%ebp),%eax
 43c:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 43f:	eb 14                	jmp    455 <strchr+0x22>
    if(*s == c)
 441:	8b 45 08             	mov    0x8(%ebp),%eax
 444:	0f b6 00             	movzbl (%eax),%eax
 447:	3a 45 fc             	cmp    -0x4(%ebp),%al
 44a:	75 05                	jne    451 <strchr+0x1e>
      return (char*)s;
 44c:	8b 45 08             	mov    0x8(%ebp),%eax
 44f:	eb 13                	jmp    464 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 451:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 455:	8b 45 08             	mov    0x8(%ebp),%eax
 458:	0f b6 00             	movzbl (%eax),%eax
 45b:	84 c0                	test   %al,%al
 45d:	75 e2                	jne    441 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 45f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 464:	c9                   	leave  
 465:	c3                   	ret    

00000466 <gets>:

char*
gets(char *buf, int max)
{
 466:	55                   	push   %ebp
 467:	89 e5                	mov    %esp,%ebp
 469:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 46c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 473:	eb 44                	jmp    4b9 <gets+0x53>
    cc = read(0, &c, 1);
 475:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 47c:	00 
 47d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 480:	89 44 24 04          	mov    %eax,0x4(%esp)
 484:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 48b:	e8 e8 02 00 00       	call   778 <read>
 490:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 493:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 497:	7e 2d                	jle    4c6 <gets+0x60>
      break;
    buf[i++] = c;
 499:	8b 45 f4             	mov    -0xc(%ebp),%eax
 49c:	03 45 08             	add    0x8(%ebp),%eax
 49f:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 4a3:	88 10                	mov    %dl,(%eax)
 4a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 4a9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4ad:	3c 0a                	cmp    $0xa,%al
 4af:	74 16                	je     4c7 <gets+0x61>
 4b1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b5:	3c 0d                	cmp    $0xd,%al
 4b7:	74 0e                	je     4c7 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4bc:	83 c0 01             	add    $0x1,%eax
 4bf:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4c2:	7c b1                	jl     475 <gets+0xf>
 4c4:	eb 01                	jmp    4c7 <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 4c6:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ca:	03 45 08             	add    0x8(%ebp),%eax
 4cd:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4d0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4d3:	c9                   	leave  
 4d4:	c3                   	ret    

000004d5 <stat>:

int
stat(char *n, struct stat *st)
{
 4d5:	55                   	push   %ebp
 4d6:	89 e5                	mov    %esp,%ebp
 4d8:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4e2:	00 
 4e3:	8b 45 08             	mov    0x8(%ebp),%eax
 4e6:	89 04 24             	mov    %eax,(%esp)
 4e9:	e8 b2 02 00 00       	call   7a0 <open>
 4ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4f5:	79 07                	jns    4fe <stat+0x29>
    return -1;
 4f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4fc:	eb 23                	jmp    521 <stat+0x4c>
  r = fstat(fd, st);
 4fe:	8b 45 0c             	mov    0xc(%ebp),%eax
 501:	89 44 24 04          	mov    %eax,0x4(%esp)
 505:	8b 45 f4             	mov    -0xc(%ebp),%eax
 508:	89 04 24             	mov    %eax,(%esp)
 50b:	e8 a8 02 00 00       	call   7b8 <fstat>
 510:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 513:	8b 45 f4             	mov    -0xc(%ebp),%eax
 516:	89 04 24             	mov    %eax,(%esp)
 519:	e8 6a 02 00 00       	call   788 <close>
  return r;
 51e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 521:	c9                   	leave  
 522:	c3                   	ret    

00000523 <atoi>:

int
atoi(const char *s)
{
 523:	55                   	push   %ebp
 524:	89 e5                	mov    %esp,%ebp
 526:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 529:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 530:	eb 23                	jmp    555 <atoi+0x32>
    n = n*10 + *s++ - '0';
 532:	8b 55 fc             	mov    -0x4(%ebp),%edx
 535:	89 d0                	mov    %edx,%eax
 537:	c1 e0 02             	shl    $0x2,%eax
 53a:	01 d0                	add    %edx,%eax
 53c:	01 c0                	add    %eax,%eax
 53e:	89 c2                	mov    %eax,%edx
 540:	8b 45 08             	mov    0x8(%ebp),%eax
 543:	0f b6 00             	movzbl (%eax),%eax
 546:	0f be c0             	movsbl %al,%eax
 549:	01 d0                	add    %edx,%eax
 54b:	83 e8 30             	sub    $0x30,%eax
 54e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 551:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 555:	8b 45 08             	mov    0x8(%ebp),%eax
 558:	0f b6 00             	movzbl (%eax),%eax
 55b:	3c 2f                	cmp    $0x2f,%al
 55d:	7e 0a                	jle    569 <atoi+0x46>
 55f:	8b 45 08             	mov    0x8(%ebp),%eax
 562:	0f b6 00             	movzbl (%eax),%eax
 565:	3c 39                	cmp    $0x39,%al
 567:	7e c9                	jle    532 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 569:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 56c:	c9                   	leave  
 56d:	c3                   	ret    

0000056e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 56e:	55                   	push   %ebp
 56f:	89 e5                	mov    %esp,%ebp
 571:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 574:	8b 45 08             	mov    0x8(%ebp),%eax
 577:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 57a:	8b 45 0c             	mov    0xc(%ebp),%eax
 57d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 580:	eb 13                	jmp    595 <memmove+0x27>
    *dst++ = *src++;
 582:	8b 45 f8             	mov    -0x8(%ebp),%eax
 585:	0f b6 10             	movzbl (%eax),%edx
 588:	8b 45 fc             	mov    -0x4(%ebp),%eax
 58b:	88 10                	mov    %dl,(%eax)
 58d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 591:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 595:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 599:	0f 9f c0             	setg   %al
 59c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 5a0:	84 c0                	test   %al,%al
 5a2:	75 de                	jne    582 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5a4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5a7:	c9                   	leave  
 5a8:	c3                   	ret    

000005a9 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 5a9:	55                   	push   %ebp
 5aa:	89 e5                	mov    %esp,%ebp
 5ac:	83 ec 38             	sub    $0x38,%esp
 5af:	8b 45 10             	mov    0x10(%ebp),%eax
 5b2:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 5b5:	8b 45 14             	mov    0x14(%ebp),%eax
 5b8:	8b 00                	mov    (%eax),%eax
 5ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5bd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 5c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5c8:	74 06                	je     5d0 <strtok+0x27>
 5ca:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 5ce:	75 54                	jne    624 <strtok+0x7b>
    return match;
 5d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5d3:	eb 6e                	jmp    643 <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 5d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d8:	03 45 0c             	add    0xc(%ebp),%eax
 5db:	0f b6 00             	movzbl (%eax),%eax
 5de:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 5e1:	74 06                	je     5e9 <strtok+0x40>
      {
	index++;
 5e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 5e7:	eb 3c                	jmp    625 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 5e9:	8b 45 14             	mov    0x14(%ebp),%eax
 5ec:	8b 00                	mov    (%eax),%eax
 5ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
 5f1:	29 c2                	sub    %eax,%edx
 5f3:	8b 45 14             	mov    0x14(%ebp),%eax
 5f6:	8b 00                	mov    (%eax),%eax
 5f8:	03 45 0c             	add    0xc(%ebp),%eax
 5fb:	89 54 24 08          	mov    %edx,0x8(%esp)
 5ff:	89 44 24 04          	mov    %eax,0x4(%esp)
 603:	8b 45 08             	mov    0x8(%ebp),%eax
 606:	89 04 24             	mov    %eax,(%esp)
 609:	e8 37 00 00 00       	call   645 <strncpy>
 60e:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 611:	8b 45 08             	mov    0x8(%ebp),%eax
 614:	0f b6 00             	movzbl (%eax),%eax
 617:	84 c0                	test   %al,%al
 619:	74 19                	je     634 <strtok+0x8b>
	  match = 1;
 61b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 622:	eb 10                	jmp    634 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 624:	90                   	nop
 625:	8b 45 f4             	mov    -0xc(%ebp),%eax
 628:	03 45 0c             	add    0xc(%ebp),%eax
 62b:	0f b6 00             	movzbl (%eax),%eax
 62e:	84 c0                	test   %al,%al
 630:	75 a3                	jne    5d5 <strtok+0x2c>
 632:	eb 01                	jmp    635 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 634:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 635:	8b 45 f4             	mov    -0xc(%ebp),%eax
 638:	8d 50 01             	lea    0x1(%eax),%edx
 63b:	8b 45 14             	mov    0x14(%ebp),%eax
 63e:	89 10                	mov    %edx,(%eax)
  return match;
 640:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 643:	c9                   	leave  
 644:	c3                   	ret    

00000645 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 645:	55                   	push   %ebp
 646:	89 e5                	mov    %esp,%ebp
 648:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 64b:	8b 45 08             	mov    0x8(%ebp),%eax
 64e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 651:	90                   	nop
 652:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 656:	0f 9f c0             	setg   %al
 659:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 65d:	84 c0                	test   %al,%al
 65f:	74 30                	je     691 <strncpy+0x4c>
 661:	8b 45 0c             	mov    0xc(%ebp),%eax
 664:	0f b6 10             	movzbl (%eax),%edx
 667:	8b 45 08             	mov    0x8(%ebp),%eax
 66a:	88 10                	mov    %dl,(%eax)
 66c:	8b 45 08             	mov    0x8(%ebp),%eax
 66f:	0f b6 00             	movzbl (%eax),%eax
 672:	84 c0                	test   %al,%al
 674:	0f 95 c0             	setne  %al
 677:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 67b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 67f:	84 c0                	test   %al,%al
 681:	75 cf                	jne    652 <strncpy+0xd>
    ;
  while(n-- > 0)
 683:	eb 0c                	jmp    691 <strncpy+0x4c>
    *s++ = 0;
 685:	8b 45 08             	mov    0x8(%ebp),%eax
 688:	c6 00 00             	movb   $0x0,(%eax)
 68b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 68f:	eb 01                	jmp    692 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 691:	90                   	nop
 692:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 696:	0f 9f c0             	setg   %al
 699:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 69d:	84 c0                	test   %al,%al
 69f:	75 e4                	jne    685 <strncpy+0x40>
    *s++ = 0;
  return os;
 6a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6a4:	c9                   	leave  
 6a5:	c3                   	ret    

000006a6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 6a6:	55                   	push   %ebp
 6a7:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 6a9:	eb 0c                	jmp    6b7 <strncmp+0x11>
    n--, p++, q++;
 6ab:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 6af:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 6b3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 6b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6bb:	74 1a                	je     6d7 <strncmp+0x31>
 6bd:	8b 45 08             	mov    0x8(%ebp),%eax
 6c0:	0f b6 00             	movzbl (%eax),%eax
 6c3:	84 c0                	test   %al,%al
 6c5:	74 10                	je     6d7 <strncmp+0x31>
 6c7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ca:	0f b6 10             	movzbl (%eax),%edx
 6cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d0:	0f b6 00             	movzbl (%eax),%eax
 6d3:	38 c2                	cmp    %al,%dl
 6d5:	74 d4                	je     6ab <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 6d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6db:	75 07                	jne    6e4 <strncmp+0x3e>
    return 0;
 6dd:	b8 00 00 00 00       	mov    $0x0,%eax
 6e2:	eb 18                	jmp    6fc <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 6e4:	8b 45 08             	mov    0x8(%ebp),%eax
 6e7:	0f b6 00             	movzbl (%eax),%eax
 6ea:	0f b6 d0             	movzbl %al,%edx
 6ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 6f0:	0f b6 00             	movzbl (%eax),%eax
 6f3:	0f b6 c0             	movzbl %al,%eax
 6f6:	89 d1                	mov    %edx,%ecx
 6f8:	29 c1                	sub    %eax,%ecx
 6fa:	89 c8                	mov    %ecx,%eax
}
 6fc:	5d                   	pop    %ebp
 6fd:	c3                   	ret    

000006fe <strcat>:

void
strcat(char *dest, char *p, char *q)
{  
 6fe:	55                   	push   %ebp
 6ff:	89 e5                	mov    %esp,%ebp
  while(*p){
 701:	eb 13                	jmp    716 <strcat+0x18>
    *dest++ = *p++;
 703:	8b 45 0c             	mov    0xc(%ebp),%eax
 706:	0f b6 10             	movzbl (%eax),%edx
 709:	8b 45 08             	mov    0x8(%ebp),%eax
 70c:	88 10                	mov    %dl,(%eax)
 70e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 712:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, char *p, char *q)
{  
  while(*p){
 716:	8b 45 0c             	mov    0xc(%ebp),%eax
 719:	0f b6 00             	movzbl (%eax),%eax
 71c:	84 c0                	test   %al,%al
 71e:	75 e3                	jne    703 <strcat+0x5>
    *dest++ = *p++;
  }

  while(*q){
 720:	eb 13                	jmp    735 <strcat+0x37>
    *dest++ = *q++;
 722:	8b 45 10             	mov    0x10(%ebp),%eax
 725:	0f b6 10             	movzbl (%eax),%edx
 728:	8b 45 08             	mov    0x8(%ebp),%eax
 72b:	88 10                	mov    %dl,(%eax)
 72d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 731:	83 45 10 01          	addl   $0x1,0x10(%ebp)
{  
  while(*p){
    *dest++ = *p++;
  }

  while(*q){
 735:	8b 45 10             	mov    0x10(%ebp),%eax
 738:	0f b6 00             	movzbl (%eax),%eax
 73b:	84 c0                	test   %al,%al
 73d:	75 e3                	jne    722 <strcat+0x24>
    *dest++ = *q++;
  }
  *dest = 0;
 73f:	8b 45 08             	mov    0x8(%ebp),%eax
 742:	c6 00 00             	movb   $0x0,(%eax)
 745:	5d                   	pop    %ebp
 746:	c3                   	ret    
 747:	90                   	nop

00000748 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 748:	b8 01 00 00 00       	mov    $0x1,%eax
 74d:	cd 40                	int    $0x40
 74f:	c3                   	ret    

00000750 <exit>:
SYSCALL(exit)
 750:	b8 02 00 00 00       	mov    $0x2,%eax
 755:	cd 40                	int    $0x40
 757:	c3                   	ret    

00000758 <wait>:
SYSCALL(wait)
 758:	b8 03 00 00 00       	mov    $0x3,%eax
 75d:	cd 40                	int    $0x40
 75f:	c3                   	ret    

00000760 <wait2>:
SYSCALL(wait2)
 760:	b8 16 00 00 00       	mov    $0x16,%eax
 765:	cd 40                	int    $0x40
 767:	c3                   	ret    

00000768 <nice>:
SYSCALL(nice)
 768:	b8 17 00 00 00       	mov    $0x17,%eax
 76d:	cd 40                	int    $0x40
 76f:	c3                   	ret    

00000770 <pipe>:
SYSCALL(pipe)
 770:	b8 04 00 00 00       	mov    $0x4,%eax
 775:	cd 40                	int    $0x40
 777:	c3                   	ret    

00000778 <read>:
SYSCALL(read)
 778:	b8 05 00 00 00       	mov    $0x5,%eax
 77d:	cd 40                	int    $0x40
 77f:	c3                   	ret    

00000780 <write>:
SYSCALL(write)
 780:	b8 10 00 00 00       	mov    $0x10,%eax
 785:	cd 40                	int    $0x40
 787:	c3                   	ret    

00000788 <close>:
SYSCALL(close)
 788:	b8 15 00 00 00       	mov    $0x15,%eax
 78d:	cd 40                	int    $0x40
 78f:	c3                   	ret    

00000790 <kill>:
SYSCALL(kill)
 790:	b8 06 00 00 00       	mov    $0x6,%eax
 795:	cd 40                	int    $0x40
 797:	c3                   	ret    

00000798 <exec>:
SYSCALL(exec)
 798:	b8 07 00 00 00       	mov    $0x7,%eax
 79d:	cd 40                	int    $0x40
 79f:	c3                   	ret    

000007a0 <open>:
SYSCALL(open)
 7a0:	b8 0f 00 00 00       	mov    $0xf,%eax
 7a5:	cd 40                	int    $0x40
 7a7:	c3                   	ret    

000007a8 <mknod>:
SYSCALL(mknod)
 7a8:	b8 11 00 00 00       	mov    $0x11,%eax
 7ad:	cd 40                	int    $0x40
 7af:	c3                   	ret    

000007b0 <unlink>:
SYSCALL(unlink)
 7b0:	b8 12 00 00 00       	mov    $0x12,%eax
 7b5:	cd 40                	int    $0x40
 7b7:	c3                   	ret    

000007b8 <fstat>:
SYSCALL(fstat)
 7b8:	b8 08 00 00 00       	mov    $0x8,%eax
 7bd:	cd 40                	int    $0x40
 7bf:	c3                   	ret    

000007c0 <link>:
SYSCALL(link)
 7c0:	b8 13 00 00 00       	mov    $0x13,%eax
 7c5:	cd 40                	int    $0x40
 7c7:	c3                   	ret    

000007c8 <mkdir>:
SYSCALL(mkdir)
 7c8:	b8 14 00 00 00       	mov    $0x14,%eax
 7cd:	cd 40                	int    $0x40
 7cf:	c3                   	ret    

000007d0 <chdir>:
SYSCALL(chdir)
 7d0:	b8 09 00 00 00       	mov    $0x9,%eax
 7d5:	cd 40                	int    $0x40
 7d7:	c3                   	ret    

000007d8 <dup>:
SYSCALL(dup)
 7d8:	b8 0a 00 00 00       	mov    $0xa,%eax
 7dd:	cd 40                	int    $0x40
 7df:	c3                   	ret    

000007e0 <getpid>:
SYSCALL(getpid)
 7e0:	b8 0b 00 00 00       	mov    $0xb,%eax
 7e5:	cd 40                	int    $0x40
 7e7:	c3                   	ret    

000007e8 <sbrk>:
SYSCALL(sbrk)
 7e8:	b8 0c 00 00 00       	mov    $0xc,%eax
 7ed:	cd 40                	int    $0x40
 7ef:	c3                   	ret    

000007f0 <sleep>:
SYSCALL(sleep)
 7f0:	b8 0d 00 00 00       	mov    $0xd,%eax
 7f5:	cd 40                	int    $0x40
 7f7:	c3                   	ret    

000007f8 <uptime>:
SYSCALL(uptime)
 7f8:	b8 0e 00 00 00       	mov    $0xe,%eax
 7fd:	cd 40                	int    $0x40
 7ff:	c3                   	ret    

00000800 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 800:	55                   	push   %ebp
 801:	89 e5                	mov    %esp,%ebp
 803:	83 ec 28             	sub    $0x28,%esp
 806:	8b 45 0c             	mov    0xc(%ebp),%eax
 809:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 80c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 813:	00 
 814:	8d 45 f4             	lea    -0xc(%ebp),%eax
 817:	89 44 24 04          	mov    %eax,0x4(%esp)
 81b:	8b 45 08             	mov    0x8(%ebp),%eax
 81e:	89 04 24             	mov    %eax,(%esp)
 821:	e8 5a ff ff ff       	call   780 <write>
}
 826:	c9                   	leave  
 827:	c3                   	ret    

00000828 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 828:	55                   	push   %ebp
 829:	89 e5                	mov    %esp,%ebp
 82b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 82e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 835:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 839:	74 17                	je     852 <printint+0x2a>
 83b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 83f:	79 11                	jns    852 <printint+0x2a>
    neg = 1;
 841:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 848:	8b 45 0c             	mov    0xc(%ebp),%eax
 84b:	f7 d8                	neg    %eax
 84d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 850:	eb 06                	jmp    858 <printint+0x30>
  } else {
    x = xx;
 852:	8b 45 0c             	mov    0xc(%ebp),%eax
 855:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 858:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 85f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 862:	8b 45 ec             	mov    -0x14(%ebp),%eax
 865:	ba 00 00 00 00       	mov    $0x0,%edx
 86a:	f7 f1                	div    %ecx
 86c:	89 d0                	mov    %edx,%eax
 86e:	0f b6 90 18 10 00 00 	movzbl 0x1018(%eax),%edx
 875:	8d 45 dc             	lea    -0x24(%ebp),%eax
 878:	03 45 f4             	add    -0xc(%ebp),%eax
 87b:	88 10                	mov    %dl,(%eax)
 87d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 881:	8b 55 10             	mov    0x10(%ebp),%edx
 884:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 887:	8b 45 ec             	mov    -0x14(%ebp),%eax
 88a:	ba 00 00 00 00       	mov    $0x0,%edx
 88f:	f7 75 d4             	divl   -0x2c(%ebp)
 892:	89 45 ec             	mov    %eax,-0x14(%ebp)
 895:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 899:	75 c4                	jne    85f <printint+0x37>
  if(neg)
 89b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 89f:	74 2a                	je     8cb <printint+0xa3>
    buf[i++] = '-';
 8a1:	8d 45 dc             	lea    -0x24(%ebp),%eax
 8a4:	03 45 f4             	add    -0xc(%ebp),%eax
 8a7:	c6 00 2d             	movb   $0x2d,(%eax)
 8aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 8ae:	eb 1b                	jmp    8cb <printint+0xa3>
    putc(fd, buf[i]);
 8b0:	8d 45 dc             	lea    -0x24(%ebp),%eax
 8b3:	03 45 f4             	add    -0xc(%ebp),%eax
 8b6:	0f b6 00             	movzbl (%eax),%eax
 8b9:	0f be c0             	movsbl %al,%eax
 8bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 8c0:	8b 45 08             	mov    0x8(%ebp),%eax
 8c3:	89 04 24             	mov    %eax,(%esp)
 8c6:	e8 35 ff ff ff       	call   800 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 8cb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 8cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8d3:	79 db                	jns    8b0 <printint+0x88>
    putc(fd, buf[i]);
}
 8d5:	c9                   	leave  
 8d6:	c3                   	ret    

000008d7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 8d7:	55                   	push   %ebp
 8d8:	89 e5                	mov    %esp,%ebp
 8da:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 8dd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 8e4:	8d 45 0c             	lea    0xc(%ebp),%eax
 8e7:	83 c0 04             	add    $0x4,%eax
 8ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 8ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 8f4:	e9 7d 01 00 00       	jmp    a76 <printf+0x19f>
    c = fmt[i] & 0xff;
 8f9:	8b 55 0c             	mov    0xc(%ebp),%edx
 8fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ff:	01 d0                	add    %edx,%eax
 901:	0f b6 00             	movzbl (%eax),%eax
 904:	0f be c0             	movsbl %al,%eax
 907:	25 ff 00 00 00       	and    $0xff,%eax
 90c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 90f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 913:	75 2c                	jne    941 <printf+0x6a>
      if(c == '%'){
 915:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 919:	75 0c                	jne    927 <printf+0x50>
        state = '%';
 91b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 922:	e9 4b 01 00 00       	jmp    a72 <printf+0x19b>
      } else {
        putc(fd, c);
 927:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 92a:	0f be c0             	movsbl %al,%eax
 92d:	89 44 24 04          	mov    %eax,0x4(%esp)
 931:	8b 45 08             	mov    0x8(%ebp),%eax
 934:	89 04 24             	mov    %eax,(%esp)
 937:	e8 c4 fe ff ff       	call   800 <putc>
 93c:	e9 31 01 00 00       	jmp    a72 <printf+0x19b>
      }
    } else if(state == '%'){
 941:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 945:	0f 85 27 01 00 00    	jne    a72 <printf+0x19b>
      if(c == 'd'){
 94b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 94f:	75 2d                	jne    97e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 951:	8b 45 e8             	mov    -0x18(%ebp),%eax
 954:	8b 00                	mov    (%eax),%eax
 956:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 95d:	00 
 95e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 965:	00 
 966:	89 44 24 04          	mov    %eax,0x4(%esp)
 96a:	8b 45 08             	mov    0x8(%ebp),%eax
 96d:	89 04 24             	mov    %eax,(%esp)
 970:	e8 b3 fe ff ff       	call   828 <printint>
        ap++;
 975:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 979:	e9 ed 00 00 00       	jmp    a6b <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 97e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 982:	74 06                	je     98a <printf+0xb3>
 984:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 988:	75 2d                	jne    9b7 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 98a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 98d:	8b 00                	mov    (%eax),%eax
 98f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 996:	00 
 997:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 99e:	00 
 99f:	89 44 24 04          	mov    %eax,0x4(%esp)
 9a3:	8b 45 08             	mov    0x8(%ebp),%eax
 9a6:	89 04 24             	mov    %eax,(%esp)
 9a9:	e8 7a fe ff ff       	call   828 <printint>
        ap++;
 9ae:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9b2:	e9 b4 00 00 00       	jmp    a6b <printf+0x194>
      } else if(c == 's'){
 9b7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9bb:	75 46                	jne    a03 <printf+0x12c>
        s = (char*)*ap;
 9bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9c0:	8b 00                	mov    (%eax),%eax
 9c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 9c5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 9c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9cd:	75 27                	jne    9f6 <printf+0x11f>
          s = "(null)";
 9cf:	c7 45 f4 d2 0c 00 00 	movl   $0xcd2,-0xc(%ebp)
        while(*s != 0){
 9d6:	eb 1e                	jmp    9f6 <printf+0x11f>
          putc(fd, *s);
 9d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9db:	0f b6 00             	movzbl (%eax),%eax
 9de:	0f be c0             	movsbl %al,%eax
 9e1:	89 44 24 04          	mov    %eax,0x4(%esp)
 9e5:	8b 45 08             	mov    0x8(%ebp),%eax
 9e8:	89 04 24             	mov    %eax,(%esp)
 9eb:	e8 10 fe ff ff       	call   800 <putc>
          s++;
 9f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 9f4:	eb 01                	jmp    9f7 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 9f6:	90                   	nop
 9f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fa:	0f b6 00             	movzbl (%eax),%eax
 9fd:	84 c0                	test   %al,%al
 9ff:	75 d7                	jne    9d8 <printf+0x101>
 a01:	eb 68                	jmp    a6b <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 a03:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a07:	75 1d                	jne    a26 <printf+0x14f>
        putc(fd, *ap);
 a09:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a0c:	8b 00                	mov    (%eax),%eax
 a0e:	0f be c0             	movsbl %al,%eax
 a11:	89 44 24 04          	mov    %eax,0x4(%esp)
 a15:	8b 45 08             	mov    0x8(%ebp),%eax
 a18:	89 04 24             	mov    %eax,(%esp)
 a1b:	e8 e0 fd ff ff       	call   800 <putc>
        ap++;
 a20:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a24:	eb 45                	jmp    a6b <printf+0x194>
      } else if(c == '%'){
 a26:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a2a:	75 17                	jne    a43 <printf+0x16c>
        putc(fd, c);
 a2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a2f:	0f be c0             	movsbl %al,%eax
 a32:	89 44 24 04          	mov    %eax,0x4(%esp)
 a36:	8b 45 08             	mov    0x8(%ebp),%eax
 a39:	89 04 24             	mov    %eax,(%esp)
 a3c:	e8 bf fd ff ff       	call   800 <putc>
 a41:	eb 28                	jmp    a6b <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a43:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 a4a:	00 
 a4b:	8b 45 08             	mov    0x8(%ebp),%eax
 a4e:	89 04 24             	mov    %eax,(%esp)
 a51:	e8 aa fd ff ff       	call   800 <putc>
        putc(fd, c);
 a56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a59:	0f be c0             	movsbl %al,%eax
 a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
 a60:	8b 45 08             	mov    0x8(%ebp),%eax
 a63:	89 04 24             	mov    %eax,(%esp)
 a66:	e8 95 fd ff ff       	call   800 <putc>
      }
      state = 0;
 a6b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 a72:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a76:	8b 55 0c             	mov    0xc(%ebp),%edx
 a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a7c:	01 d0                	add    %edx,%eax
 a7e:	0f b6 00             	movzbl (%eax),%eax
 a81:	84 c0                	test   %al,%al
 a83:	0f 85 70 fe ff ff    	jne    8f9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 a89:	c9                   	leave  
 a8a:	c3                   	ret    
 a8b:	90                   	nop

00000a8c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a8c:	55                   	push   %ebp
 a8d:	89 e5                	mov    %esp,%ebp
 a8f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a92:	8b 45 08             	mov    0x8(%ebp),%eax
 a95:	83 e8 08             	sub    $0x8,%eax
 a98:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a9b:	a1 48 10 00 00       	mov    0x1048,%eax
 aa0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 aa3:	eb 24                	jmp    ac9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aa5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aa8:	8b 00                	mov    (%eax),%eax
 aaa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 aad:	77 12                	ja     ac1 <free+0x35>
 aaf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ab2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ab5:	77 24                	ja     adb <free+0x4f>
 ab7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aba:	8b 00                	mov    (%eax),%eax
 abc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 abf:	77 1a                	ja     adb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ac1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac4:	8b 00                	mov    (%eax),%eax
 ac6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ac9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 acc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 acf:	76 d4                	jbe    aa5 <free+0x19>
 ad1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad4:	8b 00                	mov    (%eax),%eax
 ad6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 ad9:	76 ca                	jbe    aa5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 adb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ade:	8b 40 04             	mov    0x4(%eax),%eax
 ae1:	c1 e0 03             	shl    $0x3,%eax
 ae4:	89 c2                	mov    %eax,%edx
 ae6:	03 55 f8             	add    -0x8(%ebp),%edx
 ae9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 aec:	8b 00                	mov    (%eax),%eax
 aee:	39 c2                	cmp    %eax,%edx
 af0:	75 24                	jne    b16 <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 af2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 af5:	8b 50 04             	mov    0x4(%eax),%edx
 af8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 afb:	8b 00                	mov    (%eax),%eax
 afd:	8b 40 04             	mov    0x4(%eax),%eax
 b00:	01 c2                	add    %eax,%edx
 b02:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b05:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b08:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b0b:	8b 00                	mov    (%eax),%eax
 b0d:	8b 10                	mov    (%eax),%edx
 b0f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b12:	89 10                	mov    %edx,(%eax)
 b14:	eb 0a                	jmp    b20 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 b16:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b19:	8b 10                	mov    (%eax),%edx
 b1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b1e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b20:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b23:	8b 40 04             	mov    0x4(%eax),%eax
 b26:	c1 e0 03             	shl    $0x3,%eax
 b29:	03 45 fc             	add    -0x4(%ebp),%eax
 b2c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b2f:	75 20                	jne    b51 <free+0xc5>
    p->s.size += bp->s.size;
 b31:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b34:	8b 50 04             	mov    0x4(%eax),%edx
 b37:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b3a:	8b 40 04             	mov    0x4(%eax),%eax
 b3d:	01 c2                	add    %eax,%edx
 b3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b42:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b45:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b48:	8b 10                	mov    (%eax),%edx
 b4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b4d:	89 10                	mov    %edx,(%eax)
 b4f:	eb 08                	jmp    b59 <free+0xcd>
  } else
    p->s.ptr = bp;
 b51:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b54:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b57:	89 10                	mov    %edx,(%eax)
  freep = p;
 b59:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b5c:	a3 48 10 00 00       	mov    %eax,0x1048
}
 b61:	c9                   	leave  
 b62:	c3                   	ret    

00000b63 <morecore>:

static Header*
morecore(uint nu)
{
 b63:	55                   	push   %ebp
 b64:	89 e5                	mov    %esp,%ebp
 b66:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b69:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b70:	77 07                	ja     b79 <morecore+0x16>
    nu = 4096;
 b72:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b79:	8b 45 08             	mov    0x8(%ebp),%eax
 b7c:	c1 e0 03             	shl    $0x3,%eax
 b7f:	89 04 24             	mov    %eax,(%esp)
 b82:	e8 61 fc ff ff       	call   7e8 <sbrk>
 b87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 b8a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 b8e:	75 07                	jne    b97 <morecore+0x34>
    return 0;
 b90:	b8 00 00 00 00       	mov    $0x0,%eax
 b95:	eb 22                	jmp    bb9 <morecore+0x56>
  hp = (Header*)p;
 b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ba0:	8b 55 08             	mov    0x8(%ebp),%edx
 ba3:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ba9:	83 c0 08             	add    $0x8,%eax
 bac:	89 04 24             	mov    %eax,(%esp)
 baf:	e8 d8 fe ff ff       	call   a8c <free>
  return freep;
 bb4:	a1 48 10 00 00       	mov    0x1048,%eax
}
 bb9:	c9                   	leave  
 bba:	c3                   	ret    

00000bbb <malloc>:

void*
malloc(uint nbytes)
{
 bbb:	55                   	push   %ebp
 bbc:	89 e5                	mov    %esp,%ebp
 bbe:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bc1:	8b 45 08             	mov    0x8(%ebp),%eax
 bc4:	83 c0 07             	add    $0x7,%eax
 bc7:	c1 e8 03             	shr    $0x3,%eax
 bca:	83 c0 01             	add    $0x1,%eax
 bcd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 bd0:	a1 48 10 00 00       	mov    0x1048,%eax
 bd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bd8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 bdc:	75 23                	jne    c01 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 bde:	c7 45 f0 40 10 00 00 	movl   $0x1040,-0x10(%ebp)
 be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 be8:	a3 48 10 00 00       	mov    %eax,0x1048
 bed:	a1 48 10 00 00       	mov    0x1048,%eax
 bf2:	a3 40 10 00 00       	mov    %eax,0x1040
    base.s.size = 0;
 bf7:	c7 05 44 10 00 00 00 	movl   $0x0,0x1044
 bfe:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c04:	8b 00                	mov    (%eax),%eax
 c06:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c0c:	8b 40 04             	mov    0x4(%eax),%eax
 c0f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c12:	72 4d                	jb     c61 <malloc+0xa6>
      if(p->s.size == nunits)
 c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c17:	8b 40 04             	mov    0x4(%eax),%eax
 c1a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c1d:	75 0c                	jne    c2b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c22:	8b 10                	mov    (%eax),%edx
 c24:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c27:	89 10                	mov    %edx,(%eax)
 c29:	eb 26                	jmp    c51 <malloc+0x96>
      else {
        p->s.size -= nunits;
 c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c2e:	8b 40 04             	mov    0x4(%eax),%eax
 c31:	89 c2                	mov    %eax,%edx
 c33:	2b 55 ec             	sub    -0x14(%ebp),%edx
 c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c39:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c3f:	8b 40 04             	mov    0x4(%eax),%eax
 c42:	c1 e0 03             	shl    $0x3,%eax
 c45:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c4b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c4e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c54:	a3 48 10 00 00       	mov    %eax,0x1048
      return (void*)(p + 1);
 c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c5c:	83 c0 08             	add    $0x8,%eax
 c5f:	eb 38                	jmp    c99 <malloc+0xde>
    }
    if(p == freep)
 c61:	a1 48 10 00 00       	mov    0x1048,%eax
 c66:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c69:	75 1b                	jne    c86 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 c6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 c6e:	89 04 24             	mov    %eax,(%esp)
 c71:	e8 ed fe ff ff       	call   b63 <morecore>
 c76:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c7d:	75 07                	jne    c86 <malloc+0xcb>
        return 0;
 c7f:	b8 00 00 00 00       	mov    $0x0,%eax
 c84:	eb 13                	jmp    c99 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c89:	89 45 f0             	mov    %eax,-0x10(%ebp)
 c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c8f:	8b 00                	mov    (%eax),%eax
 c91:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 c94:	e9 70 ff ff ff       	jmp    c09 <malloc+0x4e>
}
 c99:	c9                   	leave  
 c9a:	c3                   	ret    
