
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 24             	sub    $0x24,%esp
  static char buf[DIRSIZ+1];
  char *p;
  
  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   7:	8b 45 08             	mov    0x8(%ebp),%eax
   a:	89 04 24             	mov    %eax,(%esp)
   d:	e8 e4 03 00 00       	call   3f6 <strlen>
  12:	8b 55 08             	mov    0x8(%ebp),%edx
  15:	01 d0                	add    %edx,%eax
  17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1a:	eb 04                	jmp    20 <fmtname+0x20>
  1c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  23:	3b 45 08             	cmp    0x8(%ebp),%eax
  26:	72 0a                	jb     32 <fmtname+0x32>
  28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  2b:	0f b6 00             	movzbl (%eax),%eax
  2e:	3c 2f                	cmp    $0x2f,%al
  30:	75 ea                	jne    1c <fmtname+0x1c>
    ;
  p++;
  32:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  39:	89 04 24             	mov    %eax,(%esp)
  3c:	e8 b5 03 00 00       	call   3f6 <strlen>
  41:	83 f8 0d             	cmp    $0xd,%eax
  44:	76 05                	jbe    4b <fmtname+0x4b>
    return p;
  46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  49:	eb 5f                	jmp    aa <fmtname+0xaa>
  memmove(buf, p, strlen(p));
  4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4e:	89 04 24             	mov    %eax,(%esp)
  51:	e8 a0 03 00 00       	call   3f6 <strlen>
  56:	89 44 24 08          	mov    %eax,0x8(%esp)
  5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  61:	c7 04 24 38 10 00 00 	movl   $0x1038,(%esp)
  68:	e8 13 05 00 00       	call   580 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  70:	89 04 24             	mov    %eax,(%esp)
  73:	e8 7e 03 00 00       	call   3f6 <strlen>
  78:	ba 0e 00 00 00       	mov    $0xe,%edx
  7d:	89 d3                	mov    %edx,%ebx
  7f:	29 c3                	sub    %eax,%ebx
  81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  84:	89 04 24             	mov    %eax,(%esp)
  87:	e8 6a 03 00 00       	call   3f6 <strlen>
  8c:	05 38 10 00 00       	add    $0x1038,%eax
  91:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  95:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  9c:	00 
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 78 03 00 00       	call   41d <memset>
  return buf;
  a5:	b8 38 10 00 00       	mov    $0x1038,%eax
}
  aa:	83 c4 24             	add    $0x24,%esp
  ad:	5b                   	pop    %ebx
  ae:	5d                   	pop    %ebp
  af:	c3                   	ret    

000000b0 <ls>:

void
ls(char *path)
{
  b0:	55                   	push   %ebp
  b1:	89 e5                	mov    %esp,%ebp
  b3:	57                   	push   %edi
  b4:	56                   	push   %esi
  b5:	53                   	push   %ebx
  b6:	81 ec 5c 02 00 00    	sub    $0x25c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;
  
  if((fd = open(path, 0)) < 0){
  bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  c3:	00 
  c4:	8b 45 08             	mov    0x8(%ebp),%eax
  c7:	89 04 24             	mov    %eax,(%esp)
  ca:	e8 e5 06 00 00       	call   7b4 <open>
  cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  d6:	79 20                	jns    f8 <ls+0x48>
    printf(2, "ls: cannot open %s\n", path);
  d8:	8b 45 08             	mov    0x8(%ebp),%eax
  db:	89 44 24 08          	mov    %eax,0x8(%esp)
  df:	c7 44 24 04 c1 0c 00 	movl   $0xcc1,0x4(%esp)
  e6:	00 
  e7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  ee:	e8 fe 07 00 00       	call   8f1 <printf>
  f3:	e9 01 02 00 00       	jmp    2f9 <ls+0x249>
    return;
  }
  
  if(fstat(fd, &st) < 0){
  f8:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
  fe:	89 44 24 04          	mov    %eax,0x4(%esp)
 102:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 105:	89 04 24             	mov    %eax,(%esp)
 108:	e8 bf 06 00 00       	call   7cc <fstat>
 10d:	85 c0                	test   %eax,%eax
 10f:	79 2b                	jns    13c <ls+0x8c>
    printf(2, "ls: cannot stat %s\n", path);
 111:	8b 45 08             	mov    0x8(%ebp),%eax
 114:	89 44 24 08          	mov    %eax,0x8(%esp)
 118:	c7 44 24 04 d5 0c 00 	movl   $0xcd5,0x4(%esp)
 11f:	00 
 120:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 127:	e8 c5 07 00 00       	call   8f1 <printf>
    close(fd);
 12c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 12f:	89 04 24             	mov    %eax,(%esp)
 132:	e8 65 06 00 00       	call   79c <close>
 137:	e9 bd 01 00 00       	jmp    2f9 <ls+0x249>
    return;
  }
  
  switch(st.type){
 13c:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 143:	98                   	cwtl   
 144:	83 f8 01             	cmp    $0x1,%eax
 147:	74 53                	je     19c <ls+0xec>
 149:	83 f8 02             	cmp    $0x2,%eax
 14c:	0f 85 9c 01 00 00    	jne    2ee <ls+0x23e>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 152:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 158:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 15e:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 165:	0f bf d8             	movswl %ax,%ebx
 168:	8b 45 08             	mov    0x8(%ebp),%eax
 16b:	89 04 24             	mov    %eax,(%esp)
 16e:	e8 8d fe ff ff       	call   0 <fmtname>
 173:	89 7c 24 14          	mov    %edi,0x14(%esp)
 177:	89 74 24 10          	mov    %esi,0x10(%esp)
 17b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 17f:	89 44 24 08          	mov    %eax,0x8(%esp)
 183:	c7 44 24 04 e9 0c 00 	movl   $0xce9,0x4(%esp)
 18a:	00 
 18b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 192:	e8 5a 07 00 00       	call   8f1 <printf>
    break;
 197:	e9 52 01 00 00       	jmp    2ee <ls+0x23e>
  
  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	89 04 24             	mov    %eax,(%esp)
 1a2:	e8 4f 02 00 00       	call   3f6 <strlen>
 1a7:	83 c0 10             	add    $0x10,%eax
 1aa:	3d 00 02 00 00       	cmp    $0x200,%eax
 1af:	76 19                	jbe    1ca <ls+0x11a>
      printf(1, "ls: path too long\n");
 1b1:	c7 44 24 04 f6 0c 00 	movl   $0xcf6,0x4(%esp)
 1b8:	00 
 1b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1c0:	e8 2c 07 00 00       	call   8f1 <printf>
      break;
 1c5:	e9 24 01 00 00       	jmp    2ee <ls+0x23e>
    }
    strcpy(buf, path);
 1ca:	8b 45 08             	mov    0x8(%ebp),%eax
 1cd:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d1:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1d7:	89 04 24             	mov    %eax,(%esp)
 1da:	e8 a2 01 00 00       	call   381 <strcpy>
    p = buf+strlen(buf);
 1df:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1e5:	89 04 24             	mov    %eax,(%esp)
 1e8:	e8 09 02 00 00       	call   3f6 <strlen>
 1ed:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
 1f3:	01 d0                	add    %edx,%eax
 1f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 1f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1fb:	c6 00 2f             	movb   $0x2f,(%eax)
 1fe:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 202:	e9 c0 00 00 00       	jmp    2c7 <ls+0x217>
      if(de.inum == 0)
 207:	0f b7 85 d0 fd ff ff 	movzwl -0x230(%ebp),%eax
 20e:	66 85 c0             	test   %ax,%ax
 211:	0f 84 af 00 00 00    	je     2c6 <ls+0x216>
        continue;
      memmove(p, de.name, DIRSIZ);
 217:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
 21e:	00 
 21f:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 225:	83 c0 02             	add    $0x2,%eax
 228:	89 44 24 04          	mov    %eax,0x4(%esp)
 22c:	8b 45 e0             	mov    -0x20(%ebp),%eax
 22f:	89 04 24             	mov    %eax,(%esp)
 232:	e8 49 03 00 00       	call   580 <memmove>
      p[DIRSIZ] = 0;
 237:	8b 45 e0             	mov    -0x20(%ebp),%eax
 23a:	83 c0 0e             	add    $0xe,%eax
 23d:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 240:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 246:	89 44 24 04          	mov    %eax,0x4(%esp)
 24a:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 250:	89 04 24             	mov    %eax,(%esp)
 253:	e8 8f 02 00 00       	call   4e7 <stat>
 258:	85 c0                	test   %eax,%eax
 25a:	79 20                	jns    27c <ls+0x1cc>
        printf(1, "ls: cannot stat %s\n", buf);
 25c:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 262:	89 44 24 08          	mov    %eax,0x8(%esp)
 266:	c7 44 24 04 d5 0c 00 	movl   $0xcd5,0x4(%esp)
 26d:	00 
 26e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 275:	e8 77 06 00 00       	call   8f1 <printf>
        continue;
 27a:	eb 4b                	jmp    2c7 <ls+0x217>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 27c:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 282:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 288:	0f b7 85 bc fd ff ff 	movzwl -0x244(%ebp),%eax
 28f:	0f bf d8             	movswl %ax,%ebx
 292:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 298:	89 04 24             	mov    %eax,(%esp)
 29b:	e8 60 fd ff ff       	call   0 <fmtname>
 2a0:	89 7c 24 14          	mov    %edi,0x14(%esp)
 2a4:	89 74 24 10          	mov    %esi,0x10(%esp)
 2a8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 2ac:	89 44 24 08          	mov    %eax,0x8(%esp)
 2b0:	c7 44 24 04 e9 0c 00 	movl   $0xce9,0x4(%esp)
 2b7:	00 
 2b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2bf:	e8 2d 06 00 00       	call   8f1 <printf>
 2c4:	eb 01                	jmp    2c7 <ls+0x217>
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
      if(de.inum == 0)
        continue;
 2c6:	90                   	nop
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2c7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 2ce:	00 
 2cf:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 2d5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2dc:	89 04 24             	mov    %eax,(%esp)
 2df:	e8 a8 04 00 00       	call   78c <read>
 2e4:	83 f8 10             	cmp    $0x10,%eax
 2e7:	0f 84 1a ff ff ff    	je     207 <ls+0x157>
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
 2ed:	90                   	nop
  }
  close(fd);
 2ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2f1:	89 04 24             	mov    %eax,(%esp)
 2f4:	e8 a3 04 00 00       	call   79c <close>
}
 2f9:	81 c4 5c 02 00 00    	add    $0x25c,%esp
 2ff:	5b                   	pop    %ebx
 300:	5e                   	pop    %esi
 301:	5f                   	pop    %edi
 302:	5d                   	pop    %ebp
 303:	c3                   	ret    

00000304 <main>:

int
main(int argc, char *argv[])
{
 304:	55                   	push   %ebp
 305:	89 e5                	mov    %esp,%ebp
 307:	83 e4 f0             	and    $0xfffffff0,%esp
 30a:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 2){
 30d:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 311:	7f 11                	jg     324 <main+0x20>
    ls(".");
 313:	c7 04 24 09 0d 00 00 	movl   $0xd09,(%esp)
 31a:	e8 91 fd ff ff       	call   b0 <ls>
    exit();
 31f:	e8 40 04 00 00       	call   764 <exit>
  }
  for(i=1; i<argc; i++)
 324:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 32b:	00 
 32c:	eb 1f                	jmp    34d <main+0x49>
    ls(argv[i]);
 32e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 332:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 339:	8b 45 0c             	mov    0xc(%ebp),%eax
 33c:	01 d0                	add    %edx,%eax
 33e:	8b 00                	mov    (%eax),%eax
 340:	89 04 24             	mov    %eax,(%esp)
 343:	e8 68 fd ff ff       	call   b0 <ls>

  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
 348:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 34d:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 351:	3b 45 08             	cmp    0x8(%ebp),%eax
 354:	7c d8                	jl     32e <main+0x2a>
    ls(argv[i]);
  exit();
 356:	e8 09 04 00 00       	call   764 <exit>
 35b:	90                   	nop

0000035c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 35c:	55                   	push   %ebp
 35d:	89 e5                	mov    %esp,%ebp
 35f:	57                   	push   %edi
 360:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 361:	8b 4d 08             	mov    0x8(%ebp),%ecx
 364:	8b 55 10             	mov    0x10(%ebp),%edx
 367:	8b 45 0c             	mov    0xc(%ebp),%eax
 36a:	89 cb                	mov    %ecx,%ebx
 36c:	89 df                	mov    %ebx,%edi
 36e:	89 d1                	mov    %edx,%ecx
 370:	fc                   	cld    
 371:	f3 aa                	rep stos %al,%es:(%edi)
 373:	89 ca                	mov    %ecx,%edx
 375:	89 fb                	mov    %edi,%ebx
 377:	89 5d 08             	mov    %ebx,0x8(%ebp)
 37a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 37d:	5b                   	pop    %ebx
 37e:	5f                   	pop    %edi
 37f:	5d                   	pop    %ebp
 380:	c3                   	ret    

00000381 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 381:	55                   	push   %ebp
 382:	89 e5                	mov    %esp,%ebp
 384:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 387:	8b 45 08             	mov    0x8(%ebp),%eax
 38a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 38d:	90                   	nop
 38e:	8b 45 0c             	mov    0xc(%ebp),%eax
 391:	0f b6 10             	movzbl (%eax),%edx
 394:	8b 45 08             	mov    0x8(%ebp),%eax
 397:	88 10                	mov    %dl,(%eax)
 399:	8b 45 08             	mov    0x8(%ebp),%eax
 39c:	0f b6 00             	movzbl (%eax),%eax
 39f:	84 c0                	test   %al,%al
 3a1:	0f 95 c0             	setne  %al
 3a4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 3ac:	84 c0                	test   %al,%al
 3ae:	75 de                	jne    38e <strcpy+0xd>
    ;
  return os;
 3b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3b3:	c9                   	leave  
 3b4:	c3                   	ret    

000003b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3b5:	55                   	push   %ebp
 3b6:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3b8:	eb 08                	jmp    3c2 <strcmp+0xd>
    p++, q++;
 3ba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3be:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3c2:	8b 45 08             	mov    0x8(%ebp),%eax
 3c5:	0f b6 00             	movzbl (%eax),%eax
 3c8:	84 c0                	test   %al,%al
 3ca:	74 10                	je     3dc <strcmp+0x27>
 3cc:	8b 45 08             	mov    0x8(%ebp),%eax
 3cf:	0f b6 10             	movzbl (%eax),%edx
 3d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d5:	0f b6 00             	movzbl (%eax),%eax
 3d8:	38 c2                	cmp    %al,%dl
 3da:	74 de                	je     3ba <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3dc:	8b 45 08             	mov    0x8(%ebp),%eax
 3df:	0f b6 00             	movzbl (%eax),%eax
 3e2:	0f b6 d0             	movzbl %al,%edx
 3e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e8:	0f b6 00             	movzbl (%eax),%eax
 3eb:	0f b6 c0             	movzbl %al,%eax
 3ee:	89 d1                	mov    %edx,%ecx
 3f0:	29 c1                	sub    %eax,%ecx
 3f2:	89 c8                	mov    %ecx,%eax
}
 3f4:	5d                   	pop    %ebp
 3f5:	c3                   	ret    

000003f6 <strlen>:

uint
strlen(char *s)
{
 3f6:	55                   	push   %ebp
 3f7:	89 e5                	mov    %esp,%ebp
 3f9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 3fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 403:	eb 04                	jmp    409 <strlen+0x13>
 405:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 409:	8b 55 fc             	mov    -0x4(%ebp),%edx
 40c:	8b 45 08             	mov    0x8(%ebp),%eax
 40f:	01 d0                	add    %edx,%eax
 411:	0f b6 00             	movzbl (%eax),%eax
 414:	84 c0                	test   %al,%al
 416:	75 ed                	jne    405 <strlen+0xf>
  return n;
 418:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 41b:	c9                   	leave  
 41c:	c3                   	ret    

0000041d <memset>:

void*
memset(void *dst, int c, uint n)
{
 41d:	55                   	push   %ebp
 41e:	89 e5                	mov    %esp,%ebp
 420:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 423:	8b 45 10             	mov    0x10(%ebp),%eax
 426:	89 44 24 08          	mov    %eax,0x8(%esp)
 42a:	8b 45 0c             	mov    0xc(%ebp),%eax
 42d:	89 44 24 04          	mov    %eax,0x4(%esp)
 431:	8b 45 08             	mov    0x8(%ebp),%eax
 434:	89 04 24             	mov    %eax,(%esp)
 437:	e8 20 ff ff ff       	call   35c <stosb>
  return dst;
 43c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 43f:	c9                   	leave  
 440:	c3                   	ret    

00000441 <strchr>:

char*
strchr(const char *s, char c)
{
 441:	55                   	push   %ebp
 442:	89 e5                	mov    %esp,%ebp
 444:	83 ec 04             	sub    $0x4,%esp
 447:	8b 45 0c             	mov    0xc(%ebp),%eax
 44a:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 44d:	eb 14                	jmp    463 <strchr+0x22>
    if(*s == c)
 44f:	8b 45 08             	mov    0x8(%ebp),%eax
 452:	0f b6 00             	movzbl (%eax),%eax
 455:	3a 45 fc             	cmp    -0x4(%ebp),%al
 458:	75 05                	jne    45f <strchr+0x1e>
      return (char*)s;
 45a:	8b 45 08             	mov    0x8(%ebp),%eax
 45d:	eb 13                	jmp    472 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 45f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 463:	8b 45 08             	mov    0x8(%ebp),%eax
 466:	0f b6 00             	movzbl (%eax),%eax
 469:	84 c0                	test   %al,%al
 46b:	75 e2                	jne    44f <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 46d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 472:	c9                   	leave  
 473:	c3                   	ret    

00000474 <gets>:

char*
gets(char *buf, int max)
{
 474:	55                   	push   %ebp
 475:	89 e5                	mov    %esp,%ebp
 477:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 47a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 481:	eb 46                	jmp    4c9 <gets+0x55>
    cc = read(0, &c, 1);
 483:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 48a:	00 
 48b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 48e:	89 44 24 04          	mov    %eax,0x4(%esp)
 492:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 499:	e8 ee 02 00 00       	call   78c <read>
 49e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 4a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4a5:	7e 2f                	jle    4d6 <gets+0x62>
      break;
    buf[i++] = c;
 4a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4aa:	8b 45 08             	mov    0x8(%ebp),%eax
 4ad:	01 c2                	add    %eax,%edx
 4af:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4b3:	88 02                	mov    %al,(%edx)
 4b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 4b9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4bd:	3c 0a                	cmp    $0xa,%al
 4bf:	74 16                	je     4d7 <gets+0x63>
 4c1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 4c5:	3c 0d                	cmp    $0xd,%al
 4c7:	74 0e                	je     4d7 <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4cc:	83 c0 01             	add    $0x1,%eax
 4cf:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4d2:	7c af                	jl     483 <gets+0xf>
 4d4:	eb 01                	jmp    4d7 <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 4d6:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4da:	8b 45 08             	mov    0x8(%ebp),%eax
 4dd:	01 d0                	add    %edx,%eax
 4df:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4e2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4e5:	c9                   	leave  
 4e6:	c3                   	ret    

000004e7 <stat>:

int
stat(char *n, struct stat *st)
{
 4e7:	55                   	push   %ebp
 4e8:	89 e5                	mov    %esp,%ebp
 4ea:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4f4:	00 
 4f5:	8b 45 08             	mov    0x8(%ebp),%eax
 4f8:	89 04 24             	mov    %eax,(%esp)
 4fb:	e8 b4 02 00 00       	call   7b4 <open>
 500:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 503:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 507:	79 07                	jns    510 <stat+0x29>
    return -1;
 509:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 50e:	eb 23                	jmp    533 <stat+0x4c>
  r = fstat(fd, st);
 510:	8b 45 0c             	mov    0xc(%ebp),%eax
 513:	89 44 24 04          	mov    %eax,0x4(%esp)
 517:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51a:	89 04 24             	mov    %eax,(%esp)
 51d:	e8 aa 02 00 00       	call   7cc <fstat>
 522:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 525:	8b 45 f4             	mov    -0xc(%ebp),%eax
 528:	89 04 24             	mov    %eax,(%esp)
 52b:	e8 6c 02 00 00       	call   79c <close>
  return r;
 530:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 533:	c9                   	leave  
 534:	c3                   	ret    

00000535 <atoi>:

int
atoi(const char *s)
{
 535:	55                   	push   %ebp
 536:	89 e5                	mov    %esp,%ebp
 538:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 53b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 542:	eb 23                	jmp    567 <atoi+0x32>
    n = n*10 + *s++ - '0';
 544:	8b 55 fc             	mov    -0x4(%ebp),%edx
 547:	89 d0                	mov    %edx,%eax
 549:	c1 e0 02             	shl    $0x2,%eax
 54c:	01 d0                	add    %edx,%eax
 54e:	01 c0                	add    %eax,%eax
 550:	89 c2                	mov    %eax,%edx
 552:	8b 45 08             	mov    0x8(%ebp),%eax
 555:	0f b6 00             	movzbl (%eax),%eax
 558:	0f be c0             	movsbl %al,%eax
 55b:	01 d0                	add    %edx,%eax
 55d:	83 e8 30             	sub    $0x30,%eax
 560:	89 45 fc             	mov    %eax,-0x4(%ebp)
 563:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 567:	8b 45 08             	mov    0x8(%ebp),%eax
 56a:	0f b6 00             	movzbl (%eax),%eax
 56d:	3c 2f                	cmp    $0x2f,%al
 56f:	7e 0a                	jle    57b <atoi+0x46>
 571:	8b 45 08             	mov    0x8(%ebp),%eax
 574:	0f b6 00             	movzbl (%eax),%eax
 577:	3c 39                	cmp    $0x39,%al
 579:	7e c9                	jle    544 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 57b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 57e:	c9                   	leave  
 57f:	c3                   	ret    

00000580 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 580:	55                   	push   %ebp
 581:	89 e5                	mov    %esp,%ebp
 583:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 586:	8b 45 08             	mov    0x8(%ebp),%eax
 589:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 58c:	8b 45 0c             	mov    0xc(%ebp),%eax
 58f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 592:	eb 13                	jmp    5a7 <memmove+0x27>
    *dst++ = *src++;
 594:	8b 45 f8             	mov    -0x8(%ebp),%eax
 597:	0f b6 10             	movzbl (%eax),%edx
 59a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 59d:	88 10                	mov    %dl,(%eax)
 59f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 5a3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 5ab:	0f 9f c0             	setg   %al
 5ae:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 5b2:	84 c0                	test   %al,%al
 5b4:	75 de                	jne    594 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5b6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5b9:	c9                   	leave  
 5ba:	c3                   	ret    

000005bb <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 5bb:	55                   	push   %ebp
 5bc:	89 e5                	mov    %esp,%ebp
 5be:	83 ec 38             	sub    $0x38,%esp
 5c1:	8b 45 10             	mov    0x10(%ebp),%eax
 5c4:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 5c7:	8b 45 14             	mov    0x14(%ebp),%eax
 5ca:	8b 00                	mov    (%eax),%eax
 5cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 5d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 5da:	74 06                	je     5e2 <strtok+0x27>
 5dc:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 5e0:	75 5a                	jne    63c <strtok+0x81>
    return match;
 5e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5e5:	eb 76                	jmp    65d <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 5e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 5ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ed:	01 d0                	add    %edx,%eax
 5ef:	0f b6 00             	movzbl (%eax),%eax
 5f2:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 5f5:	74 06                	je     5fd <strtok+0x42>
      {
	index++;
 5f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 5fb:	eb 40                	jmp    63d <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 5fd:	8b 45 14             	mov    0x14(%ebp),%eax
 600:	8b 00                	mov    (%eax),%eax
 602:	8b 55 f4             	mov    -0xc(%ebp),%edx
 605:	29 c2                	sub    %eax,%edx
 607:	8b 45 14             	mov    0x14(%ebp),%eax
 60a:	8b 00                	mov    (%eax),%eax
 60c:	89 c1                	mov    %eax,%ecx
 60e:	8b 45 0c             	mov    0xc(%ebp),%eax
 611:	01 c8                	add    %ecx,%eax
 613:	89 54 24 08          	mov    %edx,0x8(%esp)
 617:	89 44 24 04          	mov    %eax,0x4(%esp)
 61b:	8b 45 08             	mov    0x8(%ebp),%eax
 61e:	89 04 24             	mov    %eax,(%esp)
 621:	e8 39 00 00 00       	call   65f <strncpy>
 626:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 629:	8b 45 08             	mov    0x8(%ebp),%eax
 62c:	0f b6 00             	movzbl (%eax),%eax
 62f:	84 c0                	test   %al,%al
 631:	74 1b                	je     64e <strtok+0x93>
	  match = 1;
 633:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 63a:	eb 12                	jmp    64e <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 63c:	90                   	nop
 63d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 640:	8b 45 0c             	mov    0xc(%ebp),%eax
 643:	01 d0                	add    %edx,%eax
 645:	0f b6 00             	movzbl (%eax),%eax
 648:	84 c0                	test   %al,%al
 64a:	75 9b                	jne    5e7 <strtok+0x2c>
 64c:	eb 01                	jmp    64f <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 64e:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 64f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 652:	8d 50 01             	lea    0x1(%eax),%edx
 655:	8b 45 14             	mov    0x14(%ebp),%eax
 658:	89 10                	mov    %edx,(%eax)
  return match;
 65a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 65d:	c9                   	leave  
 65e:	c3                   	ret    

0000065f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 65f:	55                   	push   %ebp
 660:	89 e5                	mov    %esp,%ebp
 662:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 665:	8b 45 08             	mov    0x8(%ebp),%eax
 668:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 66b:	90                   	nop
 66c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 670:	0f 9f c0             	setg   %al
 673:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 677:	84 c0                	test   %al,%al
 679:	74 30                	je     6ab <strncpy+0x4c>
 67b:	8b 45 0c             	mov    0xc(%ebp),%eax
 67e:	0f b6 10             	movzbl (%eax),%edx
 681:	8b 45 08             	mov    0x8(%ebp),%eax
 684:	88 10                	mov    %dl,(%eax)
 686:	8b 45 08             	mov    0x8(%ebp),%eax
 689:	0f b6 00             	movzbl (%eax),%eax
 68c:	84 c0                	test   %al,%al
 68e:	0f 95 c0             	setne  %al
 691:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 695:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 699:	84 c0                	test   %al,%al
 69b:	75 cf                	jne    66c <strncpy+0xd>
    ;
  while(n-- > 0)
 69d:	eb 0c                	jmp    6ab <strncpy+0x4c>
    *s++ = 0;
 69f:	8b 45 08             	mov    0x8(%ebp),%eax
 6a2:	c6 00 00             	movb   $0x0,(%eax)
 6a5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 6a9:	eb 01                	jmp    6ac <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 6ab:	90                   	nop
 6ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6b0:	0f 9f c0             	setg   %al
 6b3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 6b7:	84 c0                	test   %al,%al
 6b9:	75 e4                	jne    69f <strncpy+0x40>
    *s++ = 0;
  return os;
 6bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6be:	c9                   	leave  
 6bf:	c3                   	ret    

000006c0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 6c0:	55                   	push   %ebp
 6c1:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 6c3:	eb 0c                	jmp    6d1 <strncmp+0x11>
    n--, p++, q++;
 6c5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 6c9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 6cd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 6d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6d5:	74 1a                	je     6f1 <strncmp+0x31>
 6d7:	8b 45 08             	mov    0x8(%ebp),%eax
 6da:	0f b6 00             	movzbl (%eax),%eax
 6dd:	84 c0                	test   %al,%al
 6df:	74 10                	je     6f1 <strncmp+0x31>
 6e1:	8b 45 08             	mov    0x8(%ebp),%eax
 6e4:	0f b6 10             	movzbl (%eax),%edx
 6e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ea:	0f b6 00             	movzbl (%eax),%eax
 6ed:	38 c2                	cmp    %al,%dl
 6ef:	74 d4                	je     6c5 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 6f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6f5:	75 07                	jne    6fe <strncmp+0x3e>
    return 0;
 6f7:	b8 00 00 00 00       	mov    $0x0,%eax
 6fc:	eb 18                	jmp    716 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 6fe:	8b 45 08             	mov    0x8(%ebp),%eax
 701:	0f b6 00             	movzbl (%eax),%eax
 704:	0f b6 d0             	movzbl %al,%edx
 707:	8b 45 0c             	mov    0xc(%ebp),%eax
 70a:	0f b6 00             	movzbl (%eax),%eax
 70d:	0f b6 c0             	movzbl %al,%eax
 710:	89 d1                	mov    %edx,%ecx
 712:	29 c1                	sub    %eax,%ecx
 714:	89 c8                	mov    %ecx,%eax
}
 716:	5d                   	pop    %ebp
 717:	c3                   	ret    

00000718 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 718:	55                   	push   %ebp
 719:	89 e5                	mov    %esp,%ebp
  while(*p){
 71b:	eb 13                	jmp    730 <strcat+0x18>
    *dest++ = *p++;
 71d:	8b 45 0c             	mov    0xc(%ebp),%eax
 720:	0f b6 10             	movzbl (%eax),%edx
 723:	8b 45 08             	mov    0x8(%ebp),%eax
 726:	88 10                	mov    %dl,(%eax)
 728:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 72c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 730:	8b 45 0c             	mov    0xc(%ebp),%eax
 733:	0f b6 00             	movzbl (%eax),%eax
 736:	84 c0                	test   %al,%al
 738:	75 e3                	jne    71d <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 73a:	eb 13                	jmp    74f <strcat+0x37>
    *dest++ = *q++;
 73c:	8b 45 10             	mov    0x10(%ebp),%eax
 73f:	0f b6 10             	movzbl (%eax),%edx
 742:	8b 45 08             	mov    0x8(%ebp),%eax
 745:	88 10                	mov    %dl,(%eax)
 747:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 74b:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 74f:	8b 45 10             	mov    0x10(%ebp),%eax
 752:	0f b6 00             	movzbl (%eax),%eax
 755:	84 c0                	test   %al,%al
 757:	75 e3                	jne    73c <strcat+0x24>
    *dest++ = *q++;
  }  
 759:	5d                   	pop    %ebp
 75a:	c3                   	ret    
 75b:	90                   	nop

0000075c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 75c:	b8 01 00 00 00       	mov    $0x1,%eax
 761:	cd 40                	int    $0x40
 763:	c3                   	ret    

00000764 <exit>:
SYSCALL(exit)
 764:	b8 02 00 00 00       	mov    $0x2,%eax
 769:	cd 40                	int    $0x40
 76b:	c3                   	ret    

0000076c <wait>:
SYSCALL(wait)
 76c:	b8 03 00 00 00       	mov    $0x3,%eax
 771:	cd 40                	int    $0x40
 773:	c3                   	ret    

00000774 <wait2>:
SYSCALL(wait2)
 774:	b8 16 00 00 00       	mov    $0x16,%eax
 779:	cd 40                	int    $0x40
 77b:	c3                   	ret    

0000077c <nice>:
SYSCALL(nice)
 77c:	b8 17 00 00 00       	mov    $0x17,%eax
 781:	cd 40                	int    $0x40
 783:	c3                   	ret    

00000784 <pipe>:
SYSCALL(pipe)
 784:	b8 04 00 00 00       	mov    $0x4,%eax
 789:	cd 40                	int    $0x40
 78b:	c3                   	ret    

0000078c <read>:
SYSCALL(read)
 78c:	b8 05 00 00 00       	mov    $0x5,%eax
 791:	cd 40                	int    $0x40
 793:	c3                   	ret    

00000794 <write>:
SYSCALL(write)
 794:	b8 10 00 00 00       	mov    $0x10,%eax
 799:	cd 40                	int    $0x40
 79b:	c3                   	ret    

0000079c <close>:
SYSCALL(close)
 79c:	b8 15 00 00 00       	mov    $0x15,%eax
 7a1:	cd 40                	int    $0x40
 7a3:	c3                   	ret    

000007a4 <kill>:
SYSCALL(kill)
 7a4:	b8 06 00 00 00       	mov    $0x6,%eax
 7a9:	cd 40                	int    $0x40
 7ab:	c3                   	ret    

000007ac <exec>:
SYSCALL(exec)
 7ac:	b8 07 00 00 00       	mov    $0x7,%eax
 7b1:	cd 40                	int    $0x40
 7b3:	c3                   	ret    

000007b4 <open>:
SYSCALL(open)
 7b4:	b8 0f 00 00 00       	mov    $0xf,%eax
 7b9:	cd 40                	int    $0x40
 7bb:	c3                   	ret    

000007bc <mknod>:
SYSCALL(mknod)
 7bc:	b8 11 00 00 00       	mov    $0x11,%eax
 7c1:	cd 40                	int    $0x40
 7c3:	c3                   	ret    

000007c4 <unlink>:
SYSCALL(unlink)
 7c4:	b8 12 00 00 00       	mov    $0x12,%eax
 7c9:	cd 40                	int    $0x40
 7cb:	c3                   	ret    

000007cc <fstat>:
SYSCALL(fstat)
 7cc:	b8 08 00 00 00       	mov    $0x8,%eax
 7d1:	cd 40                	int    $0x40
 7d3:	c3                   	ret    

000007d4 <link>:
SYSCALL(link)
 7d4:	b8 13 00 00 00       	mov    $0x13,%eax
 7d9:	cd 40                	int    $0x40
 7db:	c3                   	ret    

000007dc <mkdir>:
SYSCALL(mkdir)
 7dc:	b8 14 00 00 00       	mov    $0x14,%eax
 7e1:	cd 40                	int    $0x40
 7e3:	c3                   	ret    

000007e4 <chdir>:
SYSCALL(chdir)
 7e4:	b8 09 00 00 00       	mov    $0x9,%eax
 7e9:	cd 40                	int    $0x40
 7eb:	c3                   	ret    

000007ec <dup>:
SYSCALL(dup)
 7ec:	b8 0a 00 00 00       	mov    $0xa,%eax
 7f1:	cd 40                	int    $0x40
 7f3:	c3                   	ret    

000007f4 <getpid>:
SYSCALL(getpid)
 7f4:	b8 0b 00 00 00       	mov    $0xb,%eax
 7f9:	cd 40                	int    $0x40
 7fb:	c3                   	ret    

000007fc <sbrk>:
SYSCALL(sbrk)
 7fc:	b8 0c 00 00 00       	mov    $0xc,%eax
 801:	cd 40                	int    $0x40
 803:	c3                   	ret    

00000804 <sleep>:
SYSCALL(sleep)
 804:	b8 0d 00 00 00       	mov    $0xd,%eax
 809:	cd 40                	int    $0x40
 80b:	c3                   	ret    

0000080c <uptime>:
SYSCALL(uptime)
 80c:	b8 0e 00 00 00       	mov    $0xe,%eax
 811:	cd 40                	int    $0x40
 813:	c3                   	ret    

00000814 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 814:	55                   	push   %ebp
 815:	89 e5                	mov    %esp,%ebp
 817:	83 ec 28             	sub    $0x28,%esp
 81a:	8b 45 0c             	mov    0xc(%ebp),%eax
 81d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 820:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 827:	00 
 828:	8d 45 f4             	lea    -0xc(%ebp),%eax
 82b:	89 44 24 04          	mov    %eax,0x4(%esp)
 82f:	8b 45 08             	mov    0x8(%ebp),%eax
 832:	89 04 24             	mov    %eax,(%esp)
 835:	e8 5a ff ff ff       	call   794 <write>
}
 83a:	c9                   	leave  
 83b:	c3                   	ret    

0000083c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 83c:	55                   	push   %ebp
 83d:	89 e5                	mov    %esp,%ebp
 83f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 842:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 849:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 84d:	74 17                	je     866 <printint+0x2a>
 84f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 853:	79 11                	jns    866 <printint+0x2a>
    neg = 1;
 855:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 85c:	8b 45 0c             	mov    0xc(%ebp),%eax
 85f:	f7 d8                	neg    %eax
 861:	89 45 ec             	mov    %eax,-0x14(%ebp)
 864:	eb 06                	jmp    86c <printint+0x30>
  } else {
    x = xx;
 866:	8b 45 0c             	mov    0xc(%ebp),%eax
 869:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 86c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 873:	8b 4d 10             	mov    0x10(%ebp),%ecx
 876:	8b 45 ec             	mov    -0x14(%ebp),%eax
 879:	ba 00 00 00 00       	mov    $0x0,%edx
 87e:	f7 f1                	div    %ecx
 880:	89 d0                	mov    %edx,%eax
 882:	0f b6 80 24 10 00 00 	movzbl 0x1024(%eax),%eax
 889:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 88c:	8b 55 f4             	mov    -0xc(%ebp),%edx
 88f:	01 ca                	add    %ecx,%edx
 891:	88 02                	mov    %al,(%edx)
 893:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 897:	8b 55 10             	mov    0x10(%ebp),%edx
 89a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 89d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 8a0:	ba 00 00 00 00       	mov    $0x0,%edx
 8a5:	f7 75 d4             	divl   -0x2c(%ebp)
 8a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 8ab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 8af:	75 c2                	jne    873 <printint+0x37>
  if(neg)
 8b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8b5:	74 2e                	je     8e5 <printint+0xa9>
    buf[i++] = '-';
 8b7:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bd:	01 d0                	add    %edx,%eax
 8bf:	c6 00 2d             	movb   $0x2d,(%eax)
 8c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 8c6:	eb 1d                	jmp    8e5 <printint+0xa9>
    putc(fd, buf[i]);
 8c8:	8d 55 dc             	lea    -0x24(%ebp),%edx
 8cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ce:	01 d0                	add    %edx,%eax
 8d0:	0f b6 00             	movzbl (%eax),%eax
 8d3:	0f be c0             	movsbl %al,%eax
 8d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 8da:	8b 45 08             	mov    0x8(%ebp),%eax
 8dd:	89 04 24             	mov    %eax,(%esp)
 8e0:	e8 2f ff ff ff       	call   814 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 8e5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 8e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8ed:	79 d9                	jns    8c8 <printint+0x8c>
    putc(fd, buf[i]);
}
 8ef:	c9                   	leave  
 8f0:	c3                   	ret    

000008f1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 8f1:	55                   	push   %ebp
 8f2:	89 e5                	mov    %esp,%ebp
 8f4:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 8f7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 8fe:	8d 45 0c             	lea    0xc(%ebp),%eax
 901:	83 c0 04             	add    $0x4,%eax
 904:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 907:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 90e:	e9 7d 01 00 00       	jmp    a90 <printf+0x19f>
    c = fmt[i] & 0xff;
 913:	8b 55 0c             	mov    0xc(%ebp),%edx
 916:	8b 45 f0             	mov    -0x10(%ebp),%eax
 919:	01 d0                	add    %edx,%eax
 91b:	0f b6 00             	movzbl (%eax),%eax
 91e:	0f be c0             	movsbl %al,%eax
 921:	25 ff 00 00 00       	and    $0xff,%eax
 926:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 929:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 92d:	75 2c                	jne    95b <printf+0x6a>
      if(c == '%'){
 92f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 933:	75 0c                	jne    941 <printf+0x50>
        state = '%';
 935:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 93c:	e9 4b 01 00 00       	jmp    a8c <printf+0x19b>
      } else {
        putc(fd, c);
 941:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 944:	0f be c0             	movsbl %al,%eax
 947:	89 44 24 04          	mov    %eax,0x4(%esp)
 94b:	8b 45 08             	mov    0x8(%ebp),%eax
 94e:	89 04 24             	mov    %eax,(%esp)
 951:	e8 be fe ff ff       	call   814 <putc>
 956:	e9 31 01 00 00       	jmp    a8c <printf+0x19b>
      }
    } else if(state == '%'){
 95b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 95f:	0f 85 27 01 00 00    	jne    a8c <printf+0x19b>
      if(c == 'd'){
 965:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 969:	75 2d                	jne    998 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 96b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 96e:	8b 00                	mov    (%eax),%eax
 970:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 977:	00 
 978:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 97f:	00 
 980:	89 44 24 04          	mov    %eax,0x4(%esp)
 984:	8b 45 08             	mov    0x8(%ebp),%eax
 987:	89 04 24             	mov    %eax,(%esp)
 98a:	e8 ad fe ff ff       	call   83c <printint>
        ap++;
 98f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 993:	e9 ed 00 00 00       	jmp    a85 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 998:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 99c:	74 06                	je     9a4 <printf+0xb3>
 99e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 9a2:	75 2d                	jne    9d1 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 9a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9a7:	8b 00                	mov    (%eax),%eax
 9a9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 9b0:	00 
 9b1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 9b8:	00 
 9b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 9bd:	8b 45 08             	mov    0x8(%ebp),%eax
 9c0:	89 04 24             	mov    %eax,(%esp)
 9c3:	e8 74 fe ff ff       	call   83c <printint>
        ap++;
 9c8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 9cc:	e9 b4 00 00 00       	jmp    a85 <printf+0x194>
      } else if(c == 's'){
 9d1:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 9d5:	75 46                	jne    a1d <printf+0x12c>
        s = (char*)*ap;
 9d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 9da:	8b 00                	mov    (%eax),%eax
 9dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 9df:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 9e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9e7:	75 27                	jne    a10 <printf+0x11f>
          s = "(null)";
 9e9:	c7 45 f4 0b 0d 00 00 	movl   $0xd0b,-0xc(%ebp)
        while(*s != 0){
 9f0:	eb 1e                	jmp    a10 <printf+0x11f>
          putc(fd, *s);
 9f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f5:	0f b6 00             	movzbl (%eax),%eax
 9f8:	0f be c0             	movsbl %al,%eax
 9fb:	89 44 24 04          	mov    %eax,0x4(%esp)
 9ff:	8b 45 08             	mov    0x8(%ebp),%eax
 a02:	89 04 24             	mov    %eax,(%esp)
 a05:	e8 0a fe ff ff       	call   814 <putc>
          s++;
 a0a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 a0e:	eb 01                	jmp    a11 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 a10:	90                   	nop
 a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a14:	0f b6 00             	movzbl (%eax),%eax
 a17:	84 c0                	test   %al,%al
 a19:	75 d7                	jne    9f2 <printf+0x101>
 a1b:	eb 68                	jmp    a85 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 a1d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 a21:	75 1d                	jne    a40 <printf+0x14f>
        putc(fd, *ap);
 a23:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a26:	8b 00                	mov    (%eax),%eax
 a28:	0f be c0             	movsbl %al,%eax
 a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
 a2f:	8b 45 08             	mov    0x8(%ebp),%eax
 a32:	89 04 24             	mov    %eax,(%esp)
 a35:	e8 da fd ff ff       	call   814 <putc>
        ap++;
 a3a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a3e:	eb 45                	jmp    a85 <printf+0x194>
      } else if(c == '%'){
 a40:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a44:	75 17                	jne    a5d <printf+0x16c>
        putc(fd, c);
 a46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a49:	0f be c0             	movsbl %al,%eax
 a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
 a50:	8b 45 08             	mov    0x8(%ebp),%eax
 a53:	89 04 24             	mov    %eax,(%esp)
 a56:	e8 b9 fd ff ff       	call   814 <putc>
 a5b:	eb 28                	jmp    a85 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 a5d:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 a64:	00 
 a65:	8b 45 08             	mov    0x8(%ebp),%eax
 a68:	89 04 24             	mov    %eax,(%esp)
 a6b:	e8 a4 fd ff ff       	call   814 <putc>
        putc(fd, c);
 a70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a73:	0f be c0             	movsbl %al,%eax
 a76:	89 44 24 04          	mov    %eax,0x4(%esp)
 a7a:	8b 45 08             	mov    0x8(%ebp),%eax
 a7d:	89 04 24             	mov    %eax,(%esp)
 a80:	e8 8f fd ff ff       	call   814 <putc>
      }
      state = 0;
 a85:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 a8c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 a90:	8b 55 0c             	mov    0xc(%ebp),%edx
 a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a96:	01 d0                	add    %edx,%eax
 a98:	0f b6 00             	movzbl (%eax),%eax
 a9b:	84 c0                	test   %al,%al
 a9d:	0f 85 70 fe ff ff    	jne    913 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 aa3:	c9                   	leave  
 aa4:	c3                   	ret    
 aa5:	66 90                	xchg   %ax,%ax
 aa7:	90                   	nop

00000aa8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 aa8:	55                   	push   %ebp
 aa9:	89 e5                	mov    %esp,%ebp
 aab:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 aae:	8b 45 08             	mov    0x8(%ebp),%eax
 ab1:	83 e8 08             	sub    $0x8,%eax
 ab4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ab7:	a1 50 10 00 00       	mov    0x1050,%eax
 abc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 abf:	eb 24                	jmp    ae5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ac1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ac4:	8b 00                	mov    (%eax),%eax
 ac6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ac9:	77 12                	ja     add <free+0x35>
 acb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ace:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 ad1:	77 24                	ja     af7 <free+0x4f>
 ad3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ad6:	8b 00                	mov    (%eax),%eax
 ad8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 adb:	77 1a                	ja     af7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 add:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ae0:	8b 00                	mov    (%eax),%eax
 ae2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ae5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ae8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 aeb:	76 d4                	jbe    ac1 <free+0x19>
 aed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 af0:	8b 00                	mov    (%eax),%eax
 af2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 af5:	76 ca                	jbe    ac1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 af7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 afa:	8b 40 04             	mov    0x4(%eax),%eax
 afd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b04:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b07:	01 c2                	add    %eax,%edx
 b09:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b0c:	8b 00                	mov    (%eax),%eax
 b0e:	39 c2                	cmp    %eax,%edx
 b10:	75 24                	jne    b36 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 b12:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b15:	8b 50 04             	mov    0x4(%eax),%edx
 b18:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b1b:	8b 00                	mov    (%eax),%eax
 b1d:	8b 40 04             	mov    0x4(%eax),%eax
 b20:	01 c2                	add    %eax,%edx
 b22:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b25:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 b28:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b2b:	8b 00                	mov    (%eax),%eax
 b2d:	8b 10                	mov    (%eax),%edx
 b2f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b32:	89 10                	mov    %edx,(%eax)
 b34:	eb 0a                	jmp    b40 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 b36:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b39:	8b 10                	mov    (%eax),%edx
 b3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b3e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 b40:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b43:	8b 40 04             	mov    0x4(%eax),%eax
 b46:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 b4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b50:	01 d0                	add    %edx,%eax
 b52:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 b55:	75 20                	jne    b77 <free+0xcf>
    p->s.size += bp->s.size;
 b57:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b5a:	8b 50 04             	mov    0x4(%eax),%edx
 b5d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b60:	8b 40 04             	mov    0x4(%eax),%eax
 b63:	01 c2                	add    %eax,%edx
 b65:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b68:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 b6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 b6e:	8b 10                	mov    (%eax),%edx
 b70:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b73:	89 10                	mov    %edx,(%eax)
 b75:	eb 08                	jmp    b7f <free+0xd7>
  } else
    p->s.ptr = bp;
 b77:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b7a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 b7d:	89 10                	mov    %edx,(%eax)
  freep = p;
 b7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 b82:	a3 50 10 00 00       	mov    %eax,0x1050
}
 b87:	c9                   	leave  
 b88:	c3                   	ret    

00000b89 <morecore>:

static Header*
morecore(uint nu)
{
 b89:	55                   	push   %ebp
 b8a:	89 e5                	mov    %esp,%ebp
 b8c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 b8f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 b96:	77 07                	ja     b9f <morecore+0x16>
    nu = 4096;
 b98:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 b9f:	8b 45 08             	mov    0x8(%ebp),%eax
 ba2:	c1 e0 03             	shl    $0x3,%eax
 ba5:	89 04 24             	mov    %eax,(%esp)
 ba8:	e8 4f fc ff ff       	call   7fc <sbrk>
 bad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 bb0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 bb4:	75 07                	jne    bbd <morecore+0x34>
    return 0;
 bb6:	b8 00 00 00 00       	mov    $0x0,%eax
 bbb:	eb 22                	jmp    bdf <morecore+0x56>
  hp = (Header*)p;
 bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 bc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bc6:	8b 55 08             	mov    0x8(%ebp),%edx
 bc9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bcf:	83 c0 08             	add    $0x8,%eax
 bd2:	89 04 24             	mov    %eax,(%esp)
 bd5:	e8 ce fe ff ff       	call   aa8 <free>
  return freep;
 bda:	a1 50 10 00 00       	mov    0x1050,%eax
}
 bdf:	c9                   	leave  
 be0:	c3                   	ret    

00000be1 <malloc>:

void*
malloc(uint nbytes)
{
 be1:	55                   	push   %ebp
 be2:	89 e5                	mov    %esp,%ebp
 be4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 be7:	8b 45 08             	mov    0x8(%ebp),%eax
 bea:	83 c0 07             	add    $0x7,%eax
 bed:	c1 e8 03             	shr    $0x3,%eax
 bf0:	83 c0 01             	add    $0x1,%eax
 bf3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 bf6:	a1 50 10 00 00       	mov    0x1050,%eax
 bfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bfe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 c02:	75 23                	jne    c27 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 c04:	c7 45 f0 48 10 00 00 	movl   $0x1048,-0x10(%ebp)
 c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c0e:	a3 50 10 00 00       	mov    %eax,0x1050
 c13:	a1 50 10 00 00       	mov    0x1050,%eax
 c18:	a3 48 10 00 00       	mov    %eax,0x1048
    base.s.size = 0;
 c1d:	c7 05 4c 10 00 00 00 	movl   $0x0,0x104c
 c24:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c2a:	8b 00                	mov    (%eax),%eax
 c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c32:	8b 40 04             	mov    0x4(%eax),%eax
 c35:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c38:	72 4d                	jb     c87 <malloc+0xa6>
      if(p->s.size == nunits)
 c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c3d:	8b 40 04             	mov    0x4(%eax),%eax
 c40:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 c43:	75 0c                	jne    c51 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c48:	8b 10                	mov    (%eax),%edx
 c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c4d:	89 10                	mov    %edx,(%eax)
 c4f:	eb 26                	jmp    c77 <malloc+0x96>
      else {
        p->s.size -= nunits;
 c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c54:	8b 40 04             	mov    0x4(%eax),%eax
 c57:	89 c2                	mov    %eax,%edx
 c59:	2b 55 ec             	sub    -0x14(%ebp),%edx
 c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c5f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c65:	8b 40 04             	mov    0x4(%eax),%eax
 c68:	c1 e0 03             	shl    $0x3,%eax
 c6b:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c71:	8b 55 ec             	mov    -0x14(%ebp),%edx
 c74:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c7a:	a3 50 10 00 00       	mov    %eax,0x1050
      return (void*)(p + 1);
 c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c82:	83 c0 08             	add    $0x8,%eax
 c85:	eb 38                	jmp    cbf <malloc+0xde>
    }
    if(p == freep)
 c87:	a1 50 10 00 00       	mov    0x1050,%eax
 c8c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 c8f:	75 1b                	jne    cac <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 c91:	8b 45 ec             	mov    -0x14(%ebp),%eax
 c94:	89 04 24             	mov    %eax,(%esp)
 c97:	e8 ed fe ff ff       	call   b89 <morecore>
 c9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 c9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ca3:	75 07                	jne    cac <malloc+0xcb>
        return 0;
 ca5:	b8 00 00 00 00       	mov    $0x0,%eax
 caa:	eb 13                	jmp    cbf <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 caf:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cb5:	8b 00                	mov    (%eax),%eax
 cb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 cba:	e9 70 ff ff ff       	jmp    c2f <malloc+0x4e>
}
 cbf:	c9                   	leave  
 cc0:	c3                   	ret    
