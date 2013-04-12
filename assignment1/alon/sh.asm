
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <getcmd>:
int pathInit;	//PATH initialized flag


int
getcmd(char *buf, int nbuf)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
       6:	c7 44 24 04 80 18 00 	movl   $0x1880,0x4(%esp)
       d:	00 
       e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      15:	e8 a1 14 00 00       	call   14bb <printf>
  memset(buf, 0, nbuf);
      1a:	8b 45 0c             	mov    0xc(%ebp),%eax
      1d:	89 44 24 08          	mov    %eax,0x8(%esp)
      21:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      28:	00 
      29:	8b 45 08             	mov    0x8(%ebp),%eax
      2c:	89 04 24             	mov    %eax,(%esp)
      2f:	e8 bf 0f 00 00       	call   ff3 <memset>
  gets(buf, nbuf);
      34:	8b 45 0c             	mov    0xc(%ebp),%eax
      37:	89 44 24 04          	mov    %eax,0x4(%esp)
      3b:	8b 45 08             	mov    0x8(%ebp),%eax
      3e:	89 04 24             	mov    %eax,(%esp)
      41:	e8 04 10 00 00       	call   104a <gets>
  if(buf[0] == 0) // EOF
      46:	8b 45 08             	mov    0x8(%ebp),%eax
      49:	0f b6 00             	movzbl (%eax),%eax
      4c:	84 c0                	test   %al,%al
      4e:	75 07                	jne    57 <getcmd+0x57>
    return -1;
      50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      55:	eb 05                	jmp    5c <getcmd+0x5c>
  return 0;
      57:	b8 00 00 00 00       	mov    $0x0,%eax
}
      5c:	c9                   	leave  
      5d:	c3                   	ret    

0000005e <panic>:


void
panic(char *s)
{
      5e:	55                   	push   %ebp
      5f:	89 e5                	mov    %esp,%ebp
      61:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
      64:	8b 45 08             	mov    0x8(%ebp),%eax
      67:	89 44 24 08          	mov    %eax,0x8(%esp)
      6b:	c7 44 24 04 83 18 00 	movl   $0x1883,0x4(%esp)
      72:	00 
      73:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      7a:	e8 3c 14 00 00       	call   14bb <printf>
  exit();
      7f:	e8 b0 12 00 00       	call   1334 <exit>

00000084 <fork1>:
}

int
fork1(void)
{
      84:	55                   	push   %ebp
      85:	89 e5                	mov    %esp,%ebp
      87:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
      8a:	e8 9d 12 00 00       	call   132c <fork>
      8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
      92:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
      96:	75 0c                	jne    a4 <fork1+0x20>
    panic("fork");
      98:	c7 04 24 87 18 00 00 	movl   $0x1887,(%esp)
      9f:	e8 ba ff ff ff       	call   5e <panic>
  return pid;
      a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
      a7:	c9                   	leave  
      a8:	c3                   	ret    

000000a9 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
      a9:	55                   	push   %ebp
      aa:	89 e5                	mov    %esp,%ebp
      ac:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
      af:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
      b6:	e8 e4 16 00 00       	call   179f <malloc>
      bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
      be:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
      c5:	00 
      c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      cd:	00 
      ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
      d1:	89 04 24             	mov    %eax,(%esp)
      d4:	e8 1a 0f 00 00       	call   ff3 <memset>
  cmd->type = EXEC;
      d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
      dc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
      e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
      e5:	c9                   	leave  
      e6:	c3                   	ret    

000000e7 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
      e7:	55                   	push   %ebp
      e8:	89 e5                	mov    %esp,%ebp
      ea:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
      ed:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
      f4:	e8 a6 16 00 00       	call   179f <malloc>
      f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
      fc:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     103:	00 
     104:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     10b:	00 
     10c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     10f:	89 04 24             	mov    %eax,(%esp)
     112:	e8 dc 0e 00 00       	call   ff3 <memset>
  cmd->type = REDIR;
     117:	8b 45 f4             	mov    -0xc(%ebp),%eax
     11a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     120:	8b 45 f4             	mov    -0xc(%ebp),%eax
     123:	8b 55 08             	mov    0x8(%ebp),%edx
     126:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     129:	8b 45 f4             	mov    -0xc(%ebp),%eax
     12c:	8b 55 0c             	mov    0xc(%ebp),%edx
     12f:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     132:	8b 45 f4             	mov    -0xc(%ebp),%eax
     135:	8b 55 10             	mov    0x10(%ebp),%edx
     138:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     13b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     13e:	8b 55 14             	mov    0x14(%ebp),%edx
     141:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     144:	8b 45 f4             	mov    -0xc(%ebp),%eax
     147:	8b 55 18             	mov    0x18(%ebp),%edx
     14a:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     14d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     150:	c9                   	leave  
     151:	c3                   	ret    

00000152 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     152:	55                   	push   %ebp
     153:	89 e5                	mov    %esp,%ebp
     155:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     158:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     15f:	e8 3b 16 00 00       	call   179f <malloc>
     164:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     167:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     16e:	00 
     16f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     176:	00 
     177:	8b 45 f4             	mov    -0xc(%ebp),%eax
     17a:	89 04 24             	mov    %eax,(%esp)
     17d:	e8 71 0e 00 00       	call   ff3 <memset>
  cmd->type = PIPE;
     182:	8b 45 f4             	mov    -0xc(%ebp),%eax
     185:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     18b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     18e:	8b 55 08             	mov    0x8(%ebp),%edx
     191:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     194:	8b 45 f4             	mov    -0xc(%ebp),%eax
     197:	8b 55 0c             	mov    0xc(%ebp),%edx
     19a:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     19d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     1a0:	c9                   	leave  
     1a1:	c3                   	ret    

000001a2 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     1a2:	55                   	push   %ebp
     1a3:	89 e5                	mov    %esp,%ebp
     1a5:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     1a8:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     1af:	e8 eb 15 00 00       	call   179f <malloc>
     1b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     1b7:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     1be:	00 
     1bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     1c6:	00 
     1c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1ca:	89 04 24             	mov    %eax,(%esp)
     1cd:	e8 21 0e 00 00       	call   ff3 <memset>
  cmd->type = LIST;
     1d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1d5:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     1db:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1de:	8b 55 08             	mov    0x8(%ebp),%edx
     1e1:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     1e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
     1e7:	8b 55 0c             	mov    0xc(%ebp),%edx
     1ea:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     1ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     1f0:	c9                   	leave  
     1f1:	c3                   	ret    

000001f2 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     1f2:	55                   	push   %ebp
     1f3:	89 e5                	mov    %esp,%ebp
     1f5:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     1f8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     1ff:	e8 9b 15 00 00       	call   179f <malloc>
     204:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     207:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     20e:	00 
     20f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     216:	00 
     217:	8b 45 f4             	mov    -0xc(%ebp),%eax
     21a:	89 04 24             	mov    %eax,(%esp)
     21d:	e8 d1 0d 00 00       	call   ff3 <memset>
  cmd->type = BACK;
     222:	8b 45 f4             	mov    -0xc(%ebp),%eax
     225:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     22b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     22e:	8b 55 08             	mov    0x8(%ebp),%edx
     231:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     234:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     237:	c9                   	leave  
     238:	c3                   	ret    

00000239 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     239:	55                   	push   %ebp
     23a:	89 e5                	mov    %esp,%ebp
     23c:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     23f:	8b 45 08             	mov    0x8(%ebp),%eax
     242:	8b 00                	mov    (%eax),%eax
     244:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     247:	eb 04                	jmp    24d <gettoken+0x14>
    s++;
     249:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     24d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     250:	3b 45 0c             	cmp    0xc(%ebp),%eax
     253:	73 1d                	jae    272 <gettoken+0x39>
     255:	8b 45 f4             	mov    -0xc(%ebp),%eax
     258:	0f b6 00             	movzbl (%eax),%eax
     25b:	0f be c0             	movsbl %al,%eax
     25e:	89 44 24 04          	mov    %eax,0x4(%esp)
     262:	c7 04 24 84 1e 00 00 	movl   $0x1e84,(%esp)
     269:	e8 a9 0d 00 00       	call   1017 <strchr>
     26e:	85 c0                	test   %eax,%eax
     270:	75 d7                	jne    249 <gettoken+0x10>
    s++;
  if(q)
     272:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     276:	74 08                	je     280 <gettoken+0x47>
    *q = s;
     278:	8b 45 10             	mov    0x10(%ebp),%eax
     27b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     27e:	89 10                	mov    %edx,(%eax)
  ret = *s;
     280:	8b 45 f4             	mov    -0xc(%ebp),%eax
     283:	0f b6 00             	movzbl (%eax),%eax
     286:	0f be c0             	movsbl %al,%eax
     289:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     28c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     28f:	0f b6 00             	movzbl (%eax),%eax
     292:	0f be c0             	movsbl %al,%eax
     295:	83 f8 3c             	cmp    $0x3c,%eax
     298:	7f 1e                	jg     2b8 <gettoken+0x7f>
     29a:	83 f8 3b             	cmp    $0x3b,%eax
     29d:	7d 23                	jge    2c2 <gettoken+0x89>
     29f:	83 f8 29             	cmp    $0x29,%eax
     2a2:	7f 3f                	jg     2e3 <gettoken+0xaa>
     2a4:	83 f8 28             	cmp    $0x28,%eax
     2a7:	7d 19                	jge    2c2 <gettoken+0x89>
     2a9:	85 c0                	test   %eax,%eax
     2ab:	0f 84 83 00 00 00    	je     334 <gettoken+0xfb>
     2b1:	83 f8 26             	cmp    $0x26,%eax
     2b4:	74 0c                	je     2c2 <gettoken+0x89>
     2b6:	eb 2b                	jmp    2e3 <gettoken+0xaa>
     2b8:	83 f8 3e             	cmp    $0x3e,%eax
     2bb:	74 0b                	je     2c8 <gettoken+0x8f>
     2bd:	83 f8 7c             	cmp    $0x7c,%eax
     2c0:	75 21                	jne    2e3 <gettoken+0xaa>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     2c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
     2c6:	eb 73                	jmp    33b <gettoken+0x102>
  case '>':
    s++;
     2c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(*s == '>'){
     2cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2cf:	0f b6 00             	movzbl (%eax),%eax
     2d2:	3c 3e                	cmp    $0x3e,%al
     2d4:	75 61                	jne    337 <gettoken+0xfe>
      ret = '+';
     2d6:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     2dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    break;
     2e1:	eb 54                	jmp    337 <gettoken+0xfe>
  default:
    ret = 'a';
     2e3:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     2ea:	eb 04                	jmp    2f0 <gettoken+0xb7>
      s++;
     2ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     2f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2f3:	3b 45 0c             	cmp    0xc(%ebp),%eax
     2f6:	73 42                	jae    33a <gettoken+0x101>
     2f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
     2fb:	0f b6 00             	movzbl (%eax),%eax
     2fe:	0f be c0             	movsbl %al,%eax
     301:	89 44 24 04          	mov    %eax,0x4(%esp)
     305:	c7 04 24 84 1e 00 00 	movl   $0x1e84,(%esp)
     30c:	e8 06 0d 00 00       	call   1017 <strchr>
     311:	85 c0                	test   %eax,%eax
     313:	75 25                	jne    33a <gettoken+0x101>
     315:	8b 45 f4             	mov    -0xc(%ebp),%eax
     318:	0f b6 00             	movzbl (%eax),%eax
     31b:	0f be c0             	movsbl %al,%eax
     31e:	89 44 24 04          	mov    %eax,0x4(%esp)
     322:	c7 04 24 8a 1e 00 00 	movl   $0x1e8a,(%esp)
     329:	e8 e9 0c 00 00       	call   1017 <strchr>
     32e:	85 c0                	test   %eax,%eax
     330:	74 ba                	je     2ec <gettoken+0xb3>
      s++;
    break;
     332:	eb 06                	jmp    33a <gettoken+0x101>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     334:	90                   	nop
     335:	eb 04                	jmp    33b <gettoken+0x102>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     337:	90                   	nop
     338:	eb 01                	jmp    33b <gettoken+0x102>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     33a:	90                   	nop
  }
  if(eq)
     33b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     33f:	74 0e                	je     34f <gettoken+0x116>
    *eq = s;
     341:	8b 45 14             	mov    0x14(%ebp),%eax
     344:	8b 55 f4             	mov    -0xc(%ebp),%edx
     347:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     349:	eb 04                	jmp    34f <gettoken+0x116>
    s++;
     34b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     34f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     352:	3b 45 0c             	cmp    0xc(%ebp),%eax
     355:	73 1d                	jae    374 <gettoken+0x13b>
     357:	8b 45 f4             	mov    -0xc(%ebp),%eax
     35a:	0f b6 00             	movzbl (%eax),%eax
     35d:	0f be c0             	movsbl %al,%eax
     360:	89 44 24 04          	mov    %eax,0x4(%esp)
     364:	c7 04 24 84 1e 00 00 	movl   $0x1e84,(%esp)
     36b:	e8 a7 0c 00 00       	call   1017 <strchr>
     370:	85 c0                	test   %eax,%eax
     372:	75 d7                	jne    34b <gettoken+0x112>
    s++;
  *ps = s;
     374:	8b 45 08             	mov    0x8(%ebp),%eax
     377:	8b 55 f4             	mov    -0xc(%ebp),%edx
     37a:	89 10                	mov    %edx,(%eax)
  return ret;
     37c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     37f:	c9                   	leave  
     380:	c3                   	ret    

00000381 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     381:	55                   	push   %ebp
     382:	89 e5                	mov    %esp,%ebp
     384:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     387:	8b 45 08             	mov    0x8(%ebp),%eax
     38a:	8b 00                	mov    (%eax),%eax
     38c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     38f:	eb 04                	jmp    395 <peek+0x14>
    s++;
     391:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     395:	8b 45 f4             	mov    -0xc(%ebp),%eax
     398:	3b 45 0c             	cmp    0xc(%ebp),%eax
     39b:	73 1d                	jae    3ba <peek+0x39>
     39d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3a0:	0f b6 00             	movzbl (%eax),%eax
     3a3:	0f be c0             	movsbl %al,%eax
     3a6:	89 44 24 04          	mov    %eax,0x4(%esp)
     3aa:	c7 04 24 84 1e 00 00 	movl   $0x1e84,(%esp)
     3b1:	e8 61 0c 00 00       	call   1017 <strchr>
     3b6:	85 c0                	test   %eax,%eax
     3b8:	75 d7                	jne    391 <peek+0x10>
    s++;
  *ps = s;
     3ba:	8b 45 08             	mov    0x8(%ebp),%eax
     3bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
     3c0:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     3c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3c5:	0f b6 00             	movzbl (%eax),%eax
     3c8:	84 c0                	test   %al,%al
     3ca:	74 23                	je     3ef <peek+0x6e>
     3cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3cf:	0f b6 00             	movzbl (%eax),%eax
     3d2:	0f be c0             	movsbl %al,%eax
     3d5:	89 44 24 04          	mov    %eax,0x4(%esp)
     3d9:	8b 45 10             	mov    0x10(%ebp),%eax
     3dc:	89 04 24             	mov    %eax,(%esp)
     3df:	e8 33 0c 00 00       	call   1017 <strchr>
     3e4:	85 c0                	test   %eax,%eax
     3e6:	74 07                	je     3ef <peek+0x6e>
     3e8:	b8 01 00 00 00       	mov    $0x1,%eax
     3ed:	eb 05                	jmp    3f4 <peek+0x73>
     3ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
     3f4:	c9                   	leave  
     3f5:	c3                   	ret    

000003f6 <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     3f6:	55                   	push   %ebp
     3f7:	89 e5                	mov    %esp,%ebp
     3f9:	53                   	push   %ebx
     3fa:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     3fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
     400:	8b 45 08             	mov    0x8(%ebp),%eax
     403:	89 04 24             	mov    %eax,(%esp)
     406:	e8 c3 0b 00 00       	call   fce <strlen>
     40b:	01 d8                	add    %ebx,%eax
     40d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     410:	8b 45 f4             	mov    -0xc(%ebp),%eax
     413:	89 44 24 04          	mov    %eax,0x4(%esp)
     417:	8d 45 08             	lea    0x8(%ebp),%eax
     41a:	89 04 24             	mov    %eax,(%esp)
     41d:	e8 60 00 00 00       	call   482 <parseline>
     422:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     425:	c7 44 24 08 8c 18 00 	movl   $0x188c,0x8(%esp)
     42c:	00 
     42d:	8b 45 f4             	mov    -0xc(%ebp),%eax
     430:	89 44 24 04          	mov    %eax,0x4(%esp)
     434:	8d 45 08             	lea    0x8(%ebp),%eax
     437:	89 04 24             	mov    %eax,(%esp)
     43a:	e8 42 ff ff ff       	call   381 <peek>
  if(s != es){
     43f:	8b 45 08             	mov    0x8(%ebp),%eax
     442:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     445:	74 27                	je     46e <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     447:	8b 45 08             	mov    0x8(%ebp),%eax
     44a:	89 44 24 08          	mov    %eax,0x8(%esp)
     44e:	c7 44 24 04 8d 18 00 	movl   $0x188d,0x4(%esp)
     455:	00 
     456:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     45d:	e8 59 10 00 00       	call   14bb <printf>
    panic("syntax");
     462:	c7 04 24 9c 18 00 00 	movl   $0x189c,(%esp)
     469:	e8 f0 fb ff ff       	call   5e <panic>
  }
  nulterminate(cmd);
     46e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     471:	89 04 24             	mov    %eax,(%esp)
     474:	e8 a5 04 00 00       	call   91e <nulterminate>
  return cmd;
     479:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     47c:	83 c4 24             	add    $0x24,%esp
     47f:	5b                   	pop    %ebx
     480:	5d                   	pop    %ebp
     481:	c3                   	ret    

00000482 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     482:	55                   	push   %ebp
     483:	89 e5                	mov    %esp,%ebp
     485:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;
  
  cmd = parsepipe(ps, es);
     488:	8b 45 0c             	mov    0xc(%ebp),%eax
     48b:	89 44 24 04          	mov    %eax,0x4(%esp)
     48f:	8b 45 08             	mov    0x8(%ebp),%eax
     492:	89 04 24             	mov    %eax,(%esp)
     495:	e8 bc 00 00 00       	call   556 <parsepipe>
     49a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     49d:	eb 30                	jmp    4cf <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     49f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     4a6:	00 
     4a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     4ae:	00 
     4af:	8b 45 0c             	mov    0xc(%ebp),%eax
     4b2:	89 44 24 04          	mov    %eax,0x4(%esp)
     4b6:	8b 45 08             	mov    0x8(%ebp),%eax
     4b9:	89 04 24             	mov    %eax,(%esp)
     4bc:	e8 78 fd ff ff       	call   239 <gettoken>
    cmd = backcmd(cmd);
     4c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4c4:	89 04 24             	mov    %eax,(%esp)
     4c7:	e8 26 fd ff ff       	call   1f2 <backcmd>
     4cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;
  
  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     4cf:	c7 44 24 08 a3 18 00 	movl   $0x18a3,0x8(%esp)
     4d6:	00 
     4d7:	8b 45 0c             	mov    0xc(%ebp),%eax
     4da:	89 44 24 04          	mov    %eax,0x4(%esp)
     4de:	8b 45 08             	mov    0x8(%ebp),%eax
     4e1:	89 04 24             	mov    %eax,(%esp)
     4e4:	e8 98 fe ff ff       	call   381 <peek>
     4e9:	85 c0                	test   %eax,%eax
     4eb:	75 b2                	jne    49f <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
 
  if(peek(ps, es, ";")){
     4ed:	c7 44 24 08 a5 18 00 	movl   $0x18a5,0x8(%esp)
     4f4:	00 
     4f5:	8b 45 0c             	mov    0xc(%ebp),%eax
     4f8:	89 44 24 04          	mov    %eax,0x4(%esp)
     4fc:	8b 45 08             	mov    0x8(%ebp),%eax
     4ff:	89 04 24             	mov    %eax,(%esp)
     502:	e8 7a fe ff ff       	call   381 <peek>
     507:	85 c0                	test   %eax,%eax
     509:	74 46                	je     551 <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     50b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     512:	00 
     513:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     51a:	00 
     51b:	8b 45 0c             	mov    0xc(%ebp),%eax
     51e:	89 44 24 04          	mov    %eax,0x4(%esp)
     522:	8b 45 08             	mov    0x8(%ebp),%eax
     525:	89 04 24             	mov    %eax,(%esp)
     528:	e8 0c fd ff ff       	call   239 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     52d:	8b 45 0c             	mov    0xc(%ebp),%eax
     530:	89 44 24 04          	mov    %eax,0x4(%esp)
     534:	8b 45 08             	mov    0x8(%ebp),%eax
     537:	89 04 24             	mov    %eax,(%esp)
     53a:	e8 43 ff ff ff       	call   482 <parseline>
     53f:	89 44 24 04          	mov    %eax,0x4(%esp)
     543:	8b 45 f4             	mov    -0xc(%ebp),%eax
     546:	89 04 24             	mov    %eax,(%esp)
     549:	e8 54 fc ff ff       	call   1a2 <listcmd>
     54e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     551:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     554:	c9                   	leave  
     555:	c3                   	ret    

00000556 <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     556:	55                   	push   %ebp
     557:	89 e5                	mov    %esp,%ebp
     559:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     55c:	8b 45 0c             	mov    0xc(%ebp),%eax
     55f:	89 44 24 04          	mov    %eax,0x4(%esp)
     563:	8b 45 08             	mov    0x8(%ebp),%eax
     566:	89 04 24             	mov    %eax,(%esp)
     569:	e8 68 02 00 00       	call   7d6 <parseexec>
     56e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     571:	c7 44 24 08 a7 18 00 	movl   $0x18a7,0x8(%esp)
     578:	00 
     579:	8b 45 0c             	mov    0xc(%ebp),%eax
     57c:	89 44 24 04          	mov    %eax,0x4(%esp)
     580:	8b 45 08             	mov    0x8(%ebp),%eax
     583:	89 04 24             	mov    %eax,(%esp)
     586:	e8 f6 fd ff ff       	call   381 <peek>
     58b:	85 c0                	test   %eax,%eax
     58d:	74 46                	je     5d5 <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     58f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     596:	00 
     597:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     59e:	00 
     59f:	8b 45 0c             	mov    0xc(%ebp),%eax
     5a2:	89 44 24 04          	mov    %eax,0x4(%esp)
     5a6:	8b 45 08             	mov    0x8(%ebp),%eax
     5a9:	89 04 24             	mov    %eax,(%esp)
     5ac:	e8 88 fc ff ff       	call   239 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     5b1:	8b 45 0c             	mov    0xc(%ebp),%eax
     5b4:	89 44 24 04          	mov    %eax,0x4(%esp)
     5b8:	8b 45 08             	mov    0x8(%ebp),%eax
     5bb:	89 04 24             	mov    %eax,(%esp)
     5be:	e8 93 ff ff ff       	call   556 <parsepipe>
     5c3:	89 44 24 04          	mov    %eax,0x4(%esp)
     5c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5ca:	89 04 24             	mov    %eax,(%esp)
     5cd:	e8 80 fb ff ff       	call   152 <pipecmd>
     5d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     5d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     5d8:	c9                   	leave  
     5d9:	c3                   	ret    

000005da <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     5da:	55                   	push   %ebp
     5db:	89 e5                	mov    %esp,%ebp
     5dd:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     5e0:	e9 f6 00 00 00       	jmp    6db <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     5e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     5ec:	00 
     5ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     5f4:	00 
     5f5:	8b 45 10             	mov    0x10(%ebp),%eax
     5f8:	89 44 24 04          	mov    %eax,0x4(%esp)
     5fc:	8b 45 0c             	mov    0xc(%ebp),%eax
     5ff:	89 04 24             	mov    %eax,(%esp)
     602:	e8 32 fc ff ff       	call   239 <gettoken>
     607:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     60a:	8d 45 ec             	lea    -0x14(%ebp),%eax
     60d:	89 44 24 0c          	mov    %eax,0xc(%esp)
     611:	8d 45 f0             	lea    -0x10(%ebp),%eax
     614:	89 44 24 08          	mov    %eax,0x8(%esp)
     618:	8b 45 10             	mov    0x10(%ebp),%eax
     61b:	89 44 24 04          	mov    %eax,0x4(%esp)
     61f:	8b 45 0c             	mov    0xc(%ebp),%eax
     622:	89 04 24             	mov    %eax,(%esp)
     625:	e8 0f fc ff ff       	call   239 <gettoken>
     62a:	83 f8 61             	cmp    $0x61,%eax
     62d:	74 0c                	je     63b <parseredirs+0x61>
      panic("missing file for redirection");
     62f:	c7 04 24 a9 18 00 00 	movl   $0x18a9,(%esp)
     636:	e8 23 fa ff ff       	call   5e <panic>
    switch(tok){
     63b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     63e:	83 f8 3c             	cmp    $0x3c,%eax
     641:	74 0f                	je     652 <parseredirs+0x78>
     643:	83 f8 3e             	cmp    $0x3e,%eax
     646:	74 38                	je     680 <parseredirs+0xa6>
     648:	83 f8 2b             	cmp    $0x2b,%eax
     64b:	74 61                	je     6ae <parseredirs+0xd4>
     64d:	e9 89 00 00 00       	jmp    6db <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     652:	8b 55 ec             	mov    -0x14(%ebp),%edx
     655:	8b 45 f0             	mov    -0x10(%ebp),%eax
     658:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     65f:	00 
     660:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     667:	00 
     668:	89 54 24 08          	mov    %edx,0x8(%esp)
     66c:	89 44 24 04          	mov    %eax,0x4(%esp)
     670:	8b 45 08             	mov    0x8(%ebp),%eax
     673:	89 04 24             	mov    %eax,(%esp)
     676:	e8 6c fa ff ff       	call   e7 <redircmd>
     67b:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     67e:	eb 5b                	jmp    6db <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     680:	8b 55 ec             	mov    -0x14(%ebp),%edx
     683:	8b 45 f0             	mov    -0x10(%ebp),%eax
     686:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     68d:	00 
     68e:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     695:	00 
     696:	89 54 24 08          	mov    %edx,0x8(%esp)
     69a:	89 44 24 04          	mov    %eax,0x4(%esp)
     69e:	8b 45 08             	mov    0x8(%ebp),%eax
     6a1:	89 04 24             	mov    %eax,(%esp)
     6a4:	e8 3e fa ff ff       	call   e7 <redircmd>
     6a9:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     6ac:	eb 2d                	jmp    6db <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     6ae:	8b 55 ec             	mov    -0x14(%ebp),%edx
     6b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
     6b4:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     6bb:	00 
     6bc:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     6c3:	00 
     6c4:	89 54 24 08          	mov    %edx,0x8(%esp)
     6c8:	89 44 24 04          	mov    %eax,0x4(%esp)
     6cc:	8b 45 08             	mov    0x8(%ebp),%eax
     6cf:	89 04 24             	mov    %eax,(%esp)
     6d2:	e8 10 fa ff ff       	call   e7 <redircmd>
     6d7:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     6da:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     6db:	c7 44 24 08 c6 18 00 	movl   $0x18c6,0x8(%esp)
     6e2:	00 
     6e3:	8b 45 10             	mov    0x10(%ebp),%eax
     6e6:	89 44 24 04          	mov    %eax,0x4(%esp)
     6ea:	8b 45 0c             	mov    0xc(%ebp),%eax
     6ed:	89 04 24             	mov    %eax,(%esp)
     6f0:	e8 8c fc ff ff       	call   381 <peek>
     6f5:	85 c0                	test   %eax,%eax
     6f7:	0f 85 e8 fe ff ff    	jne    5e5 <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     6fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
     700:	c9                   	leave  
     701:	c3                   	ret    

00000702 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     702:	55                   	push   %ebp
     703:	89 e5                	mov    %esp,%ebp
     705:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     708:	c7 44 24 08 c9 18 00 	movl   $0x18c9,0x8(%esp)
     70f:	00 
     710:	8b 45 0c             	mov    0xc(%ebp),%eax
     713:	89 44 24 04          	mov    %eax,0x4(%esp)
     717:	8b 45 08             	mov    0x8(%ebp),%eax
     71a:	89 04 24             	mov    %eax,(%esp)
     71d:	e8 5f fc ff ff       	call   381 <peek>
     722:	85 c0                	test   %eax,%eax
     724:	75 0c                	jne    732 <parseblock+0x30>
    panic("parseblock");
     726:	c7 04 24 cb 18 00 00 	movl   $0x18cb,(%esp)
     72d:	e8 2c f9 ff ff       	call   5e <panic>
  gettoken(ps, es, 0, 0);
     732:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     739:	00 
     73a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     741:	00 
     742:	8b 45 0c             	mov    0xc(%ebp),%eax
     745:	89 44 24 04          	mov    %eax,0x4(%esp)
     749:	8b 45 08             	mov    0x8(%ebp),%eax
     74c:	89 04 24             	mov    %eax,(%esp)
     74f:	e8 e5 fa ff ff       	call   239 <gettoken>
  cmd = parseline(ps, es);
     754:	8b 45 0c             	mov    0xc(%ebp),%eax
     757:	89 44 24 04          	mov    %eax,0x4(%esp)
     75b:	8b 45 08             	mov    0x8(%ebp),%eax
     75e:	89 04 24             	mov    %eax,(%esp)
     761:	e8 1c fd ff ff       	call   482 <parseline>
     766:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     769:	c7 44 24 08 d6 18 00 	movl   $0x18d6,0x8(%esp)
     770:	00 
     771:	8b 45 0c             	mov    0xc(%ebp),%eax
     774:	89 44 24 04          	mov    %eax,0x4(%esp)
     778:	8b 45 08             	mov    0x8(%ebp),%eax
     77b:	89 04 24             	mov    %eax,(%esp)
     77e:	e8 fe fb ff ff       	call   381 <peek>
     783:	85 c0                	test   %eax,%eax
     785:	75 0c                	jne    793 <parseblock+0x91>
    panic("syntax - missing )");
     787:	c7 04 24 d8 18 00 00 	movl   $0x18d8,(%esp)
     78e:	e8 cb f8 ff ff       	call   5e <panic>
  gettoken(ps, es, 0, 0);
     793:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     79a:	00 
     79b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     7a2:	00 
     7a3:	8b 45 0c             	mov    0xc(%ebp),%eax
     7a6:	89 44 24 04          	mov    %eax,0x4(%esp)
     7aa:	8b 45 08             	mov    0x8(%ebp),%eax
     7ad:	89 04 24             	mov    %eax,(%esp)
     7b0:	e8 84 fa ff ff       	call   239 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     7b5:	8b 45 0c             	mov    0xc(%ebp),%eax
     7b8:	89 44 24 08          	mov    %eax,0x8(%esp)
     7bc:	8b 45 08             	mov    0x8(%ebp),%eax
     7bf:	89 44 24 04          	mov    %eax,0x4(%esp)
     7c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7c6:	89 04 24             	mov    %eax,(%esp)
     7c9:	e8 0c fe ff ff       	call   5da <parseredirs>
     7ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     7d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     7d4:	c9                   	leave  
     7d5:	c3                   	ret    

000007d6 <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     7d6:	55                   	push   %ebp
     7d7:	89 e5                	mov    %esp,%ebp
     7d9:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     7dc:	c7 44 24 08 c9 18 00 	movl   $0x18c9,0x8(%esp)
     7e3:	00 
     7e4:	8b 45 0c             	mov    0xc(%ebp),%eax
     7e7:	89 44 24 04          	mov    %eax,0x4(%esp)
     7eb:	8b 45 08             	mov    0x8(%ebp),%eax
     7ee:	89 04 24             	mov    %eax,(%esp)
     7f1:	e8 8b fb ff ff       	call   381 <peek>
     7f6:	85 c0                	test   %eax,%eax
     7f8:	74 17                	je     811 <parseexec+0x3b>
    return parseblock(ps, es);
     7fa:	8b 45 0c             	mov    0xc(%ebp),%eax
     7fd:	89 44 24 04          	mov    %eax,0x4(%esp)
     801:	8b 45 08             	mov    0x8(%ebp),%eax
     804:	89 04 24             	mov    %eax,(%esp)
     807:	e8 f6 fe ff ff       	call   702 <parseblock>
     80c:	e9 0b 01 00 00       	jmp    91c <parseexec+0x146>

  ret = execcmd();
     811:	e8 93 f8 ff ff       	call   a9 <execcmd>
     816:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     819:	8b 45 f0             	mov    -0x10(%ebp),%eax
     81c:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     81f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     826:	8b 45 0c             	mov    0xc(%ebp),%eax
     829:	89 44 24 08          	mov    %eax,0x8(%esp)
     82d:	8b 45 08             	mov    0x8(%ebp),%eax
     830:	89 44 24 04          	mov    %eax,0x4(%esp)
     834:	8b 45 f0             	mov    -0x10(%ebp),%eax
     837:	89 04 24             	mov    %eax,(%esp)
     83a:	e8 9b fd ff ff       	call   5da <parseredirs>
     83f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     842:	e9 8e 00 00 00       	jmp    8d5 <parseexec+0xff>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     847:	8d 45 e0             	lea    -0x20(%ebp),%eax
     84a:	89 44 24 0c          	mov    %eax,0xc(%esp)
     84e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     851:	89 44 24 08          	mov    %eax,0x8(%esp)
     855:	8b 45 0c             	mov    0xc(%ebp),%eax
     858:	89 44 24 04          	mov    %eax,0x4(%esp)
     85c:	8b 45 08             	mov    0x8(%ebp),%eax
     85f:	89 04 24             	mov    %eax,(%esp)
     862:	e8 d2 f9 ff ff       	call   239 <gettoken>
     867:	89 45 e8             	mov    %eax,-0x18(%ebp)
     86a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     86e:	0f 84 85 00 00 00    	je     8f9 <parseexec+0x123>
      break;
    if(tok != 'a')
     874:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     878:	74 0c                	je     886 <parseexec+0xb0>
      panic("syntax");
     87a:	c7 04 24 9c 18 00 00 	movl   $0x189c,(%esp)
     881:	e8 d8 f7 ff ff       	call   5e <panic>
    cmd->argv[argc] = q;
     886:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     889:	8b 45 ec             	mov    -0x14(%ebp),%eax
     88c:	8b 55 f4             	mov    -0xc(%ebp),%edx
     88f:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     893:	8b 55 e0             	mov    -0x20(%ebp),%edx
     896:	8b 45 ec             	mov    -0x14(%ebp),%eax
     899:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     89c:	83 c1 08             	add    $0x8,%ecx
     89f:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     8a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(argc >= MAXARGS)
     8a7:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     8ab:	7e 0c                	jle    8b9 <parseexec+0xe3>
      panic("too many args");
     8ad:	c7 04 24 eb 18 00 00 	movl   $0x18eb,(%esp)
     8b4:	e8 a5 f7 ff ff       	call   5e <panic>
    ret = parseredirs(ret, ps, es);
     8b9:	8b 45 0c             	mov    0xc(%ebp),%eax
     8bc:	89 44 24 08          	mov    %eax,0x8(%esp)
     8c0:	8b 45 08             	mov    0x8(%ebp),%eax
     8c3:	89 44 24 04          	mov    %eax,0x4(%esp)
     8c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     8ca:	89 04 24             	mov    %eax,(%esp)
     8cd:	e8 08 fd ff ff       	call   5da <parseredirs>
     8d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     8d5:	c7 44 24 08 f9 18 00 	movl   $0x18f9,0x8(%esp)
     8dc:	00 
     8dd:	8b 45 0c             	mov    0xc(%ebp),%eax
     8e0:	89 44 24 04          	mov    %eax,0x4(%esp)
     8e4:	8b 45 08             	mov    0x8(%ebp),%eax
     8e7:	89 04 24             	mov    %eax,(%esp)
     8ea:	e8 92 fa ff ff       	call   381 <peek>
     8ef:	85 c0                	test   %eax,%eax
     8f1:	0f 84 50 ff ff ff    	je     847 <parseexec+0x71>
     8f7:	eb 01                	jmp    8fa <parseexec+0x124>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     8f9:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     8fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
     8fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
     900:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     907:	00 
  cmd->eargv[argc] = 0;
     908:	8b 45 ec             	mov    -0x14(%ebp),%eax
     90b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     90e:	83 c2 08             	add    $0x8,%edx
     911:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     918:	00 
  return ret;
     919:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     91c:	c9                   	leave  
     91d:	c3                   	ret    

0000091e <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     91e:	55                   	push   %ebp
     91f:	89 e5                	mov    %esp,%ebp
     921:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;
  
  if(cmd == 0)
     924:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     928:	75 0a                	jne    934 <nulterminate+0x16>
    return 0;
     92a:	b8 00 00 00 00       	mov    $0x0,%eax
     92f:	e9 c9 00 00 00       	jmp    9fd <nulterminate+0xdf>
  
  switch(cmd->type){
     934:	8b 45 08             	mov    0x8(%ebp),%eax
     937:	8b 00                	mov    (%eax),%eax
     939:	83 f8 05             	cmp    $0x5,%eax
     93c:	0f 87 b8 00 00 00    	ja     9fa <nulterminate+0xdc>
     942:	8b 04 85 00 19 00 00 	mov    0x1900(,%eax,4),%eax
     949:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     94b:	8b 45 08             	mov    0x8(%ebp),%eax
     94e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     951:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     958:	eb 14                	jmp    96e <nulterminate+0x50>
      *ecmd->eargv[i] = 0;
     95a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     95d:	8b 55 f4             	mov    -0xc(%ebp),%edx
     960:	83 c2 08             	add    $0x8,%edx
     963:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     967:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     96a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     96e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     971:	8b 55 f4             	mov    -0xc(%ebp),%edx
     974:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     978:	85 c0                	test   %eax,%eax
     97a:	75 de                	jne    95a <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     97c:	eb 7c                	jmp    9fa <nulterminate+0xdc>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     97e:	8b 45 08             	mov    0x8(%ebp),%eax
     981:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     984:	8b 45 ec             	mov    -0x14(%ebp),%eax
     987:	8b 40 04             	mov    0x4(%eax),%eax
     98a:	89 04 24             	mov    %eax,(%esp)
     98d:	e8 8c ff ff ff       	call   91e <nulterminate>
    *rcmd->efile = 0;
     992:	8b 45 ec             	mov    -0x14(%ebp),%eax
     995:	8b 40 0c             	mov    0xc(%eax),%eax
     998:	c6 00 00             	movb   $0x0,(%eax)
    break;
     99b:	eb 5d                	jmp    9fa <nulterminate+0xdc>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     99d:	8b 45 08             	mov    0x8(%ebp),%eax
     9a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     9a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
     9a6:	8b 40 04             	mov    0x4(%eax),%eax
     9a9:	89 04 24             	mov    %eax,(%esp)
     9ac:	e8 6d ff ff ff       	call   91e <nulterminate>
    nulterminate(pcmd->right);
     9b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
     9b4:	8b 40 08             	mov    0x8(%eax),%eax
     9b7:	89 04 24             	mov    %eax,(%esp)
     9ba:	e8 5f ff ff ff       	call   91e <nulterminate>
    break;
     9bf:	eb 39                	jmp    9fa <nulterminate+0xdc>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     9c1:	8b 45 08             	mov    0x8(%ebp),%eax
     9c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     9c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     9ca:	8b 40 04             	mov    0x4(%eax),%eax
     9cd:	89 04 24             	mov    %eax,(%esp)
     9d0:	e8 49 ff ff ff       	call   91e <nulterminate>
    nulterminate(lcmd->right);
     9d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     9d8:	8b 40 08             	mov    0x8(%eax),%eax
     9db:	89 04 24             	mov    %eax,(%esp)
     9de:	e8 3b ff ff ff       	call   91e <nulterminate>
    break;
     9e3:	eb 15                	jmp    9fa <nulterminate+0xdc>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     9e5:	8b 45 08             	mov    0x8(%ebp),%eax
     9e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     9eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
     9ee:	8b 40 04             	mov    0x4(%eax),%eax
     9f1:	89 04 24             	mov    %eax,(%esp)
     9f4:	e8 25 ff ff ff       	call   91e <nulterminate>
    break;
     9f9:	90                   	nop
  }
  return cmd;
     9fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
     9fd:	c9                   	leave  
     9fe:	c3                   	ret    

000009ff <runcmd>:

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
     9ff:	55                   	push   %ebp
     a00:	89 e5                	mov    %esp,%ebp
     a02:	56                   	push   %esi
     a03:	53                   	push   %ebx
     a04:	83 ec 60             	sub    $0x60,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;
  
  if(cmd == 0)
     a07:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     a0b:	75 05                	jne    a12 <runcmd+0x13>
    exit();
     a0d:	e8 22 09 00 00       	call   1334 <exit>
  switch(cmd->type){
     a12:	8b 45 08             	mov    0x8(%ebp),%eax
     a15:	8b 00                	mov    (%eax),%eax
     a17:	83 f8 05             	cmp    $0x5,%eax
     a1a:	77 09                	ja     a25 <runcmd+0x26>
     a1c:	8b 04 85 44 19 00 00 	mov    0x1944(,%eax,4),%eax
     a23:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
     a25:	c7 04 24 18 19 00 00 	movl   $0x1918,(%esp)
     a2c:	e8 2d f6 ff ff       	call   5e <panic>
    
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     a31:	8b 45 08             	mov    0x8(%ebp),%eax
     a34:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(ecmd->argv[0] == 0)
     a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a3a:	8b 40 04             	mov    0x4(%eax),%eax
     a3d:	85 c0                	test   %eax,%eax
     a3f:	75 05                	jne    a46 <runcmd+0x47>
      exit();
     a41:	e8 ee 08 00 00       	call   1334 <exit>
    exec(ecmd->argv[0], ecmd->argv);
     a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a49:	8d 50 04             	lea    0x4(%eax),%edx
     a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a4f:	8b 40 04             	mov    0x4(%eax),%eax
     a52:	89 54 24 04          	mov    %edx,0x4(%esp)
     a56:	89 04 24             	mov    %eax,(%esp)
     a59:	e8 1e 09 00 00       	call   137c <exec>
    if(pathInit)			//if PATH was set
     a5e:	a1 34 1f 00 00       	mov    0x1f34,%eax
     a63:	85 c0                	test   %eax,%eax
     a65:	0f 84 fc 00 00 00    	je     b67 <runcmd+0x168>
    {
      char *b = ecmd->argv[0];		
     a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a6e:	8b 40 04             	mov    0x4(%eax),%eax
     a71:	89 45 ec             	mov    %eax,-0x14(%ebp)
      int i=0, x=strlen(b);
     a74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     a7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
     a7e:	89 04 24             	mov    %eax,(%esp)
     a81:	e8 48 05 00 00       	call   fce <strlen>
     a86:	89 45 e8             	mov    %eax,-0x18(%ebp)
      char** temp2 = PATH;
     a89:	a1 30 1f 00 00       	mov    0x1f30,%eax
     a8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      for(;i<10 && *(PATH[i]);i++){	//iterate over each path in PATH
     a91:	e9 b1 00 00 00       	jmp    b47 <runcmd+0x148>
     a96:	89 e0                	mov    %esp,%eax
     a98:	89 c3                	mov    %eax,%ebx
	int z = strlen(*temp2);
     a9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     a9d:	8b 00                	mov    (%eax),%eax
     a9f:	89 04 24             	mov    %eax,(%esp)
     aa2:	e8 27 05 00 00       	call   fce <strlen>
     aa7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	char *a = temp2[i];
     aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
     aad:	c1 e0 02             	shl    $0x2,%eax
     ab0:	03 45 e4             	add    -0x1c(%ebp),%eax
     ab3:	8b 00                	mov    (%eax),%eax
     ab5:	89 45 dc             	mov    %eax,-0x24(%ebp)
	char dest[x+z];
     ab8:	8b 45 e0             	mov    -0x20(%ebp),%eax
     abb:	8b 55 e8             	mov    -0x18(%ebp),%edx
     abe:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
     ac1:	8d 41 ff             	lea    -0x1(%ecx),%eax
     ac4:	89 45 d8             	mov    %eax,-0x28(%ebp)
     ac7:	89 c8                	mov    %ecx,%eax
     ac9:	8d 50 0f             	lea    0xf(%eax),%edx
     acc:	b8 10 00 00 00       	mov    $0x10,%eax
     ad1:	83 e8 01             	sub    $0x1,%eax
     ad4:	01 d0                	add    %edx,%eax
     ad6:	c7 45 b4 10 00 00 00 	movl   $0x10,-0x4c(%ebp)
     add:	ba 00 00 00 00       	mov    $0x0,%edx
     ae2:	f7 75 b4             	divl   -0x4c(%ebp)
     ae5:	6b c0 10             	imul   $0x10,%eax,%eax
     ae8:	29 c4                	sub    %eax,%esp
     aea:	8d 44 24 0c          	lea    0xc(%esp),%eax
     aee:	83 c0 0f             	add    $0xf,%eax
     af1:	c1 e8 04             	shr    $0x4,%eax
     af4:	c1 e0 04             	shl    $0x4,%eax
     af7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	memset(dest,0,sizeof(dest));
     afa:	89 ca                	mov    %ecx,%edx
     afc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     aff:	89 54 24 08          	mov    %edx,0x8(%esp)
     b03:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     b0a:	00 
     b0b:	89 04 24             	mov    %eax,(%esp)
     b0e:	e8 e0 04 00 00       	call   ff3 <memset>
	strcat(dest,a,b);		//concatenate path before the command
     b13:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     b16:	8b 55 ec             	mov    -0x14(%ebp),%edx
     b19:	89 54 24 08          	mov    %edx,0x8(%esp)
     b1d:	8b 55 dc             	mov    -0x24(%ebp),%edx
     b20:	89 54 24 04          	mov    %edx,0x4(%esp)
     b24:	89 04 24             	mov    %eax,(%esp)
     b27:	e8 b6 07 00 00       	call   12e2 <strcat>
	exec(dest,ecmd->argv);		//try to execute the command from the selected path
     b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b2f:	8d 50 04             	lea    0x4(%eax),%edx
     b32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
     b35:	89 54 24 04          	mov    %edx,0x4(%esp)
     b39:	89 04 24             	mov    %eax,(%esp)
     b3c:	e8 3b 08 00 00       	call   137c <exec>
     b41:	89 dc                	mov    %ebx,%esp
    if(pathInit)			//if PATH was set
    {
      char *b = ecmd->argv[0];		
      int i=0, x=strlen(b);
      char** temp2 = PATH;
      for(;i<10 && *(PATH[i]);i++){	//iterate over each path in PATH
     b43:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     b47:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     b4b:	7f 1a                	jg     b67 <runcmd+0x168>
     b4d:	a1 30 1f 00 00       	mov    0x1f30,%eax
     b52:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b55:	c1 e2 02             	shl    $0x2,%edx
     b58:	01 d0                	add    %edx,%eax
     b5a:	8b 00                	mov    (%eax),%eax
     b5c:	0f b6 00             	movzbl (%eax),%eax
     b5f:	84 c0                	test   %al,%al
     b61:	0f 85 2f ff ff ff    	jne    a96 <runcmd+0x97>
	memset(dest,0,sizeof(dest));
	strcat(dest,a,b);		//concatenate path before the command
	exec(dest,ecmd->argv);		//try to execute the command from the selected path
      }
    }
    printf(2, "exec %s failed\n", ecmd->argv[0]);
     b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b6a:	8b 40 04             	mov    0x4(%eax),%eax
     b6d:	89 44 24 08          	mov    %eax,0x8(%esp)
     b71:	c7 44 24 04 1f 19 00 	movl   $0x191f,0x4(%esp)
     b78:	00 
     b79:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     b80:	e8 36 09 00 00       	call   14bb <printf>
    break;
     b85:	e9 84 01 00 00       	jmp    d0e <runcmd+0x30f>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     b8a:	8b 45 08             	mov    0x8(%ebp),%eax
     b8d:	89 45 d0             	mov    %eax,-0x30(%ebp)
    close(rcmd->fd);
     b90:	8b 45 d0             	mov    -0x30(%ebp),%eax
     b93:	8b 40 14             	mov    0x14(%eax),%eax
     b96:	89 04 24             	mov    %eax,(%esp)
     b99:	e8 ce 07 00 00       	call   136c <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     b9e:	8b 45 d0             	mov    -0x30(%ebp),%eax
     ba1:	8b 50 10             	mov    0x10(%eax),%edx
     ba4:	8b 45 d0             	mov    -0x30(%ebp),%eax
     ba7:	8b 40 08             	mov    0x8(%eax),%eax
     baa:	89 54 24 04          	mov    %edx,0x4(%esp)
     bae:	89 04 24             	mov    %eax,(%esp)
     bb1:	e8 ce 07 00 00       	call   1384 <open>
     bb6:	85 c0                	test   %eax,%eax
     bb8:	79 23                	jns    bdd <runcmd+0x1de>
      printf(2, "open %s failed\n", rcmd->file);
     bba:	8b 45 d0             	mov    -0x30(%ebp),%eax
     bbd:	8b 40 08             	mov    0x8(%eax),%eax
     bc0:	89 44 24 08          	mov    %eax,0x8(%esp)
     bc4:	c7 44 24 04 2f 19 00 	movl   $0x192f,0x4(%esp)
     bcb:	00 
     bcc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     bd3:	e8 e3 08 00 00       	call   14bb <printf>
      exit();
     bd8:	e8 57 07 00 00       	call   1334 <exit>
    }
    runcmd(rcmd->cmd);
     bdd:	8b 45 d0             	mov    -0x30(%ebp),%eax
     be0:	8b 40 04             	mov    0x4(%eax),%eax
     be3:	89 04 24             	mov    %eax,(%esp)
     be6:	e8 14 fe ff ff       	call   9ff <runcmd>
    break;
     beb:	e9 1e 01 00 00       	jmp    d0e <runcmd+0x30f>

  case LIST:
    lcmd = (struct listcmd*)cmd;
     bf0:	8b 45 08             	mov    0x8(%ebp),%eax
     bf3:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(fork1() == 0)
     bf6:	e8 89 f4 ff ff       	call   84 <fork1>
     bfb:	85 c0                	test   %eax,%eax
     bfd:	75 0e                	jne    c0d <runcmd+0x20e>
      runcmd(lcmd->left);
     bff:	8b 45 cc             	mov    -0x34(%ebp),%eax
     c02:	8b 40 04             	mov    0x4(%eax),%eax
     c05:	89 04 24             	mov    %eax,(%esp)
     c08:	e8 f2 fd ff ff       	call   9ff <runcmd>
    wait();
     c0d:	e8 2a 07 00 00       	call   133c <wait>
    runcmd(lcmd->right);
     c12:	8b 45 cc             	mov    -0x34(%ebp),%eax
     c15:	8b 40 08             	mov    0x8(%eax),%eax
     c18:	89 04 24             	mov    %eax,(%esp)
     c1b:	e8 df fd ff ff       	call   9ff <runcmd>
    break;
     c20:	e9 e9 00 00 00       	jmp    d0e <runcmd+0x30f>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     c25:	8b 45 08             	mov    0x8(%ebp),%eax
     c28:	89 45 c8             	mov    %eax,-0x38(%ebp)
    if(pipe(p) < 0)
     c2b:	8d 45 bc             	lea    -0x44(%ebp),%eax
     c2e:	89 04 24             	mov    %eax,(%esp)
     c31:	e8 1e 07 00 00       	call   1354 <pipe>
     c36:	85 c0                	test   %eax,%eax
     c38:	79 0c                	jns    c46 <runcmd+0x247>
      panic("pipe");
     c3a:	c7 04 24 3f 19 00 00 	movl   $0x193f,(%esp)
     c41:	e8 18 f4 ff ff       	call   5e <panic>
    if(fork1() == 0){
     c46:	e8 39 f4 ff ff       	call   84 <fork1>
     c4b:	85 c0                	test   %eax,%eax
     c4d:	75 3b                	jne    c8a <runcmd+0x28b>
      close(1);
     c4f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c56:	e8 11 07 00 00       	call   136c <close>
      dup(p[1]);
     c5b:	8b 45 c0             	mov    -0x40(%ebp),%eax
     c5e:	89 04 24             	mov    %eax,(%esp)
     c61:	e8 56 07 00 00       	call   13bc <dup>
      close(p[0]);
     c66:	8b 45 bc             	mov    -0x44(%ebp),%eax
     c69:	89 04 24             	mov    %eax,(%esp)
     c6c:	e8 fb 06 00 00       	call   136c <close>
      close(p[1]);
     c71:	8b 45 c0             	mov    -0x40(%ebp),%eax
     c74:	89 04 24             	mov    %eax,(%esp)
     c77:	e8 f0 06 00 00       	call   136c <close>
      runcmd(pcmd->left);
     c7c:	8b 45 c8             	mov    -0x38(%ebp),%eax
     c7f:	8b 40 04             	mov    0x4(%eax),%eax
     c82:	89 04 24             	mov    %eax,(%esp)
     c85:	e8 75 fd ff ff       	call   9ff <runcmd>
    }
    if(fork1() == 0){
     c8a:	e8 f5 f3 ff ff       	call   84 <fork1>
     c8f:	85 c0                	test   %eax,%eax
     c91:	75 3b                	jne    cce <runcmd+0x2cf>
      close(0);
     c93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     c9a:	e8 cd 06 00 00       	call   136c <close>
      dup(p[0]);
     c9f:	8b 45 bc             	mov    -0x44(%ebp),%eax
     ca2:	89 04 24             	mov    %eax,(%esp)
     ca5:	e8 12 07 00 00       	call   13bc <dup>
      close(p[0]);
     caa:	8b 45 bc             	mov    -0x44(%ebp),%eax
     cad:	89 04 24             	mov    %eax,(%esp)
     cb0:	e8 b7 06 00 00       	call   136c <close>
      close(p[1]);
     cb5:	8b 45 c0             	mov    -0x40(%ebp),%eax
     cb8:	89 04 24             	mov    %eax,(%esp)
     cbb:	e8 ac 06 00 00       	call   136c <close>
      runcmd(pcmd->right);
     cc0:	8b 45 c8             	mov    -0x38(%ebp),%eax
     cc3:	8b 40 08             	mov    0x8(%eax),%eax
     cc6:	89 04 24             	mov    %eax,(%esp)
     cc9:	e8 31 fd ff ff       	call   9ff <runcmd>
    }
    close(p[0]);
     cce:	8b 45 bc             	mov    -0x44(%ebp),%eax
     cd1:	89 04 24             	mov    %eax,(%esp)
     cd4:	e8 93 06 00 00       	call   136c <close>
    close(p[1]);
     cd9:	8b 45 c0             	mov    -0x40(%ebp),%eax
     cdc:	89 04 24             	mov    %eax,(%esp)
     cdf:	e8 88 06 00 00       	call   136c <close>
    wait();
     ce4:	e8 53 06 00 00       	call   133c <wait>
    wait();
     ce9:	e8 4e 06 00 00       	call   133c <wait>
    break;
     cee:	eb 1e                	jmp    d0e <runcmd+0x30f>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     cf0:	8b 45 08             	mov    0x8(%ebp),%eax
     cf3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    if(fork1() == 0)
     cf6:	e8 89 f3 ff ff       	call   84 <fork1>
     cfb:	85 c0                	test   %eax,%eax
     cfd:	75 0e                	jne    d0d <runcmd+0x30e>
      runcmd(bcmd->cmd);
     cff:	8b 45 c4             	mov    -0x3c(%ebp),%eax
     d02:	8b 40 04             	mov    0x4(%eax),%eax
     d05:	89 04 24             	mov    %eax,(%esp)
     d08:	e8 f2 fc ff ff       	call   9ff <runcmd>
    break;
     d0d:	90                   	nop
  }
  exit();
     d0e:	e8 21 06 00 00       	call   1334 <exit>

00000d13 <main>:
}

int
main(void)
{
     d13:	55                   	push   %ebp
     d14:	89 e5                	mov    %esp,%ebp
     d16:	53                   	push   %ebx
     d17:	83 e4 f0             	and    $0xfffffff0,%esp
     d1a:	83 ec 30             	sub    $0x30,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     d1d:	eb 19                	jmp    d38 <main+0x25>
    if(fd >= 3){
     d1f:	83 7c 24 24 02       	cmpl   $0x2,0x24(%esp)
     d24:	7e 12                	jle    d38 <main+0x25>
      close(fd);
     d26:	8b 44 24 24          	mov    0x24(%esp),%eax
     d2a:	89 04 24             	mov    %eax,(%esp)
     d2d:	e8 3a 06 00 00       	call   136c <close>
      break;
     d32:	90                   	nop
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     d33:	e9 d9 01 00 00       	jmp    f11 <main+0x1fe>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     d38:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     d3f:	00 
     d40:	c7 04 24 5c 19 00 00 	movl   $0x195c,(%esp)
     d47:	e8 38 06 00 00       	call   1384 <open>
     d4c:	89 44 24 24          	mov    %eax,0x24(%esp)
     d50:	83 7c 24 24 00       	cmpl   $0x0,0x24(%esp)
     d55:	79 c8                	jns    d1f <main+0xc>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     d57:	e9 b5 01 00 00       	jmp    f11 <main+0x1fe>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     d5c:	0f b6 05 c0 1e 00 00 	movzbl 0x1ec0,%eax
     d63:	3c 63                	cmp    $0x63,%al
     d65:	75 61                	jne    dc8 <main+0xb5>
     d67:	0f b6 05 c1 1e 00 00 	movzbl 0x1ec1,%eax
     d6e:	3c 64                	cmp    $0x64,%al
     d70:	75 56                	jne    dc8 <main+0xb5>
     d72:	0f b6 05 c2 1e 00 00 	movzbl 0x1ec2,%eax
     d79:	3c 20                	cmp    $0x20,%al
     d7b:	75 4b                	jne    dc8 <main+0xb5>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     d7d:	c7 04 24 c0 1e 00 00 	movl   $0x1ec0,(%esp)
     d84:	e8 45 02 00 00       	call   fce <strlen>
     d89:	83 e8 01             	sub    $0x1,%eax
     d8c:	c6 80 c0 1e 00 00 00 	movb   $0x0,0x1ec0(%eax)
      if(chdir(buf+3) < 0)
     d93:	c7 04 24 c3 1e 00 00 	movl   $0x1ec3,(%esp)
     d9a:	e8 15 06 00 00       	call   13b4 <chdir>
     d9f:	85 c0                	test   %eax,%eax
     da1:	0f 89 69 01 00 00    	jns    f10 <main+0x1fd>
        printf(2, "cannot cd %s\n", buf+3);
     da7:	c7 44 24 08 c3 1e 00 	movl   $0x1ec3,0x8(%esp)
     dae:	00 
     daf:	c7 44 24 04 64 19 00 	movl   $0x1964,0x4(%esp)
     db6:	00 
     db7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     dbe:	e8 f8 06 00 00       	call   14bb <printf>
      continue;
     dc3:	e9 48 01 00 00       	jmp    f10 <main+0x1fd>
    }
    if(!strncmp(buf,"export PATH",11)){		//if export PATH was called
     dc8:	c7 44 24 08 0b 00 00 	movl   $0xb,0x8(%esp)
     dcf:	00 
     dd0:	c7 44 24 04 72 19 00 	movl   $0x1972,0x4(%esp)
     dd7:	00 
     dd8:	c7 04 24 c0 1e 00 00 	movl   $0x1ec0,(%esp)
     ddf:	e8 a6 04 00 00       	call   128a <strncmp>
     de4:	85 c0                	test   %eax,%eax
     de6:	0f 85 00 01 00 00    	jne    eec <main+0x1d9>
      //buf = buf+12;
      PATH = malloc(10*sizeof(char*));		//allocate memory for the PATH variable
     dec:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
     df3:	e8 a7 09 00 00       	call   179f <malloc>
     df8:	a3 30 1f 00 00       	mov    %eax,0x1f30
      memset(PATH, 0, 10*sizeof(char*));	//clean alocated memory - 10 paths max
     dfd:	a1 30 1f 00 00       	mov    0x1f30,%eax
     e02:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
     e09:	00 
     e0a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     e11:	00 
     e12:	89 04 24             	mov    %eax,(%esp)
     e15:	e8 d9 01 00 00       	call   ff3 <memset>
      int i;
      for(i=0;i<10;i++){
     e1a:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
     e21:	00 
     e22:	eb 4a                	jmp    e6e <main+0x15b>
	PATH[i] = malloc(100);			//allocate memory for each path in PATH - 100 chars max
     e24:	a1 30 1f 00 00       	mov    0x1f30,%eax
     e29:	8b 54 24 2c          	mov    0x2c(%esp),%edx
     e2d:	c1 e2 02             	shl    $0x2,%edx
     e30:	8d 1c 10             	lea    (%eax,%edx,1),%ebx
     e33:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
     e3a:	e8 60 09 00 00       	call   179f <malloc>
     e3f:	89 03                	mov    %eax,(%ebx)
	memset(PATH[i],0,100);			//clean allocated memory
     e41:	a1 30 1f 00 00       	mov    0x1f30,%eax
     e46:	8b 54 24 2c          	mov    0x2c(%esp),%edx
     e4a:	c1 e2 02             	shl    $0x2,%edx
     e4d:	01 d0                	add    %edx,%eax
     e4f:	8b 00                	mov    (%eax),%eax
     e51:	c7 44 24 08 64 00 00 	movl   $0x64,0x8(%esp)
     e58:	00 
     e59:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     e60:	00 
     e61:	89 04 24             	mov    %eax,(%esp)
     e64:	e8 8a 01 00 00       	call   ff3 <memset>
    if(!strncmp(buf,"export PATH",11)){		//if export PATH was called
      //buf = buf+12;
      PATH = malloc(10*sizeof(char*));		//allocate memory for the PATH variable
      memset(PATH, 0, 10*sizeof(char*));	//clean alocated memory - 10 paths max
      int i;
      for(i=0;i<10;i++){
     e69:	83 44 24 2c 01       	addl   $0x1,0x2c(%esp)
     e6e:	83 7c 24 2c 09       	cmpl   $0x9,0x2c(%esp)
     e73:	7e af                	jle    e24 <main+0x111>
	PATH[i] = malloc(100);			//allocate memory for each path in PATH - 100 chars max
	memset(PATH[i],0,100);			//clean allocated memory
      }
      pathInit = 1;				//set flag to 1 - initialized
     e75:	c7 05 34 1f 00 00 01 	movl   $0x1,0x1f34
     e7c:	00 00 00 
      int tempIndex = 0;
     e7f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
     e86:	00 
      int* beginIndex = &tempIndex;
     e87:	8d 44 24 18          	lea    0x18(%esp),%eax
     e8b:	89 44 24 20          	mov    %eax,0x20(%esp)
      int length = strlen(&(buf[12]));		//set the starting point to parse after "export PATH"
     e8f:	c7 04 24 cc 1e 00 00 	movl   $0x1ecc,(%esp)
     e96:	e8 33 01 00 00       	call   fce <strlen>
     e9b:	89 44 24 1c          	mov    %eax,0x1c(%esp)
      char** temp = PATH;
     e9f:	a1 30 1f 00 00       	mov    0x1f30,%eax
     ea4:	89 44 24 28          	mov    %eax,0x28(%esp)
      while(*beginIndex<length-1)		//go over the command string and tokenize by delimiter
     ea8:	eb 2f                	jmp    ed9 <main+0x1c6>
      {
	if(strtok(*temp,&(buf[12]),':',beginIndex)) //if tokenizer returned a string
     eaa:	8b 44 24 28          	mov    0x28(%esp),%eax
     eae:	8b 00                	mov    (%eax),%eax
     eb0:	8b 54 24 20          	mov    0x20(%esp),%edx
     eb4:	89 54 24 0c          	mov    %edx,0xc(%esp)
     eb8:	c7 44 24 08 3a 00 00 	movl   $0x3a,0x8(%esp)
     ebf:	00 
     ec0:	c7 44 24 04 cc 1e 00 	movl   $0x1ecc,0x4(%esp)
     ec7:	00 
     ec8:	89 04 24             	mov    %eax,(%esp)
     ecb:	e8 bd 02 00 00       	call   118d <strtok>
     ed0:	85 c0                	test   %eax,%eax
     ed2:	74 05                	je     ed9 <main+0x1c6>
	{
	(temp)++;
     ed4:	83 44 24 28 04       	addl   $0x4,0x28(%esp)
      pathInit = 1;				//set flag to 1 - initialized
      int tempIndex = 0;
      int* beginIndex = &tempIndex;
      int length = strlen(&(buf[12]));		//set the starting point to parse after "export PATH"
      char** temp = PATH;
      while(*beginIndex<length-1)		//go over the command string and tokenize by delimiter
     ed9:	8b 44 24 20          	mov    0x20(%esp),%eax
     edd:	8b 00                	mov    (%eax),%eax
     edf:	8b 54 24 1c          	mov    0x1c(%esp),%edx
     ee3:	83 ea 01             	sub    $0x1,%edx
     ee6:	39 d0                	cmp    %edx,%eax
     ee8:	7c c0                	jl     eaa <main+0x197>
	if(strtok(*temp,&(buf[12]),':',beginIndex)) //if tokenizer returned a string
	{
	(temp)++;
	}
      }
      continue;
     eea:	eb 25                	jmp    f11 <main+0x1fe>
    }
    if(fork1() == 0)
     eec:	e8 93 f1 ff ff       	call   84 <fork1>
     ef1:	85 c0                	test   %eax,%eax
     ef3:	75 14                	jne    f09 <main+0x1f6>
    {
      runcmd(parsecmd(buf));
     ef5:	c7 04 24 c0 1e 00 00 	movl   $0x1ec0,(%esp)
     efc:	e8 f5 f4 ff ff       	call   3f6 <parsecmd>
     f01:	89 04 24             	mov    %eax,(%esp)
     f04:	e8 f6 fa ff ff       	call   9ff <runcmd>
    }
    wait();
     f09:	e8 2e 04 00 00       	call   133c <wait>
     f0e:	eb 01                	jmp    f11 <main+0x1fe>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
     f10:	90                   	nop
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     f11:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     f18:	00 
     f19:	c7 04 24 c0 1e 00 00 	movl   $0x1ec0,(%esp)
     f20:	e8 db f0 ff ff       	call   0 <getcmd>
     f25:	85 c0                	test   %eax,%eax
     f27:	0f 89 2f fe ff ff    	jns    d5c <main+0x49>
    {
      runcmd(parsecmd(buf));
    }
    wait();
  }
  exit();
     f2d:	e8 02 04 00 00       	call   1334 <exit>
     f32:	90                   	nop
     f33:	90                   	nop

00000f34 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     f34:	55                   	push   %ebp
     f35:	89 e5                	mov    %esp,%ebp
     f37:	57                   	push   %edi
     f38:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     f39:	8b 4d 08             	mov    0x8(%ebp),%ecx
     f3c:	8b 55 10             	mov    0x10(%ebp),%edx
     f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
     f42:	89 cb                	mov    %ecx,%ebx
     f44:	89 df                	mov    %ebx,%edi
     f46:	89 d1                	mov    %edx,%ecx
     f48:	fc                   	cld    
     f49:	f3 aa                	rep stos %al,%es:(%edi)
     f4b:	89 ca                	mov    %ecx,%edx
     f4d:	89 fb                	mov    %edi,%ebx
     f4f:	89 5d 08             	mov    %ebx,0x8(%ebp)
     f52:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     f55:	5b                   	pop    %ebx
     f56:	5f                   	pop    %edi
     f57:	5d                   	pop    %ebp
     f58:	c3                   	ret    

00000f59 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     f59:	55                   	push   %ebp
     f5a:	89 e5                	mov    %esp,%ebp
     f5c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     f5f:	8b 45 08             	mov    0x8(%ebp),%eax
     f62:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     f65:	90                   	nop
     f66:	8b 45 0c             	mov    0xc(%ebp),%eax
     f69:	0f b6 10             	movzbl (%eax),%edx
     f6c:	8b 45 08             	mov    0x8(%ebp),%eax
     f6f:	88 10                	mov    %dl,(%eax)
     f71:	8b 45 08             	mov    0x8(%ebp),%eax
     f74:	0f b6 00             	movzbl (%eax),%eax
     f77:	84 c0                	test   %al,%al
     f79:	0f 95 c0             	setne  %al
     f7c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     f80:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
     f84:	84 c0                	test   %al,%al
     f86:	75 de                	jne    f66 <strcpy+0xd>
    ;
  return os;
     f88:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     f8b:	c9                   	leave  
     f8c:	c3                   	ret    

00000f8d <strcmp>:

int
strcmp(const char *p, const char *q)
{
     f8d:	55                   	push   %ebp
     f8e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     f90:	eb 08                	jmp    f9a <strcmp+0xd>
    p++, q++;
     f92:	83 45 08 01          	addl   $0x1,0x8(%ebp)
     f96:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     f9a:	8b 45 08             	mov    0x8(%ebp),%eax
     f9d:	0f b6 00             	movzbl (%eax),%eax
     fa0:	84 c0                	test   %al,%al
     fa2:	74 10                	je     fb4 <strcmp+0x27>
     fa4:	8b 45 08             	mov    0x8(%ebp),%eax
     fa7:	0f b6 10             	movzbl (%eax),%edx
     faa:	8b 45 0c             	mov    0xc(%ebp),%eax
     fad:	0f b6 00             	movzbl (%eax),%eax
     fb0:	38 c2                	cmp    %al,%dl
     fb2:	74 de                	je     f92 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     fb4:	8b 45 08             	mov    0x8(%ebp),%eax
     fb7:	0f b6 00             	movzbl (%eax),%eax
     fba:	0f b6 d0             	movzbl %al,%edx
     fbd:	8b 45 0c             	mov    0xc(%ebp),%eax
     fc0:	0f b6 00             	movzbl (%eax),%eax
     fc3:	0f b6 c0             	movzbl %al,%eax
     fc6:	89 d1                	mov    %edx,%ecx
     fc8:	29 c1                	sub    %eax,%ecx
     fca:	89 c8                	mov    %ecx,%eax
}
     fcc:	5d                   	pop    %ebp
     fcd:	c3                   	ret    

00000fce <strlen>:

uint
strlen(char *s)
{
     fce:	55                   	push   %ebp
     fcf:	89 e5                	mov    %esp,%ebp
     fd1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
     fd4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     fdb:	eb 04                	jmp    fe1 <strlen+0x13>
     fdd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
     fe1:	8b 45 fc             	mov    -0x4(%ebp),%eax
     fe4:	03 45 08             	add    0x8(%ebp),%eax
     fe7:	0f b6 00             	movzbl (%eax),%eax
     fea:	84 c0                	test   %al,%al
     fec:	75 ef                	jne    fdd <strlen+0xf>
  return n;
     fee:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     ff1:	c9                   	leave  
     ff2:	c3                   	ret    

00000ff3 <memset>:

void*
memset(void *dst, int c, uint n)
{
     ff3:	55                   	push   %ebp
     ff4:	89 e5                	mov    %esp,%ebp
     ff6:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     ff9:	8b 45 10             	mov    0x10(%ebp),%eax
     ffc:	89 44 24 08          	mov    %eax,0x8(%esp)
    1000:	8b 45 0c             	mov    0xc(%ebp),%eax
    1003:	89 44 24 04          	mov    %eax,0x4(%esp)
    1007:	8b 45 08             	mov    0x8(%ebp),%eax
    100a:	89 04 24             	mov    %eax,(%esp)
    100d:	e8 22 ff ff ff       	call   f34 <stosb>
  return dst;
    1012:	8b 45 08             	mov    0x8(%ebp),%eax
}
    1015:	c9                   	leave  
    1016:	c3                   	ret    

00001017 <strchr>:

char*
strchr(const char *s, char c)
{
    1017:	55                   	push   %ebp
    1018:	89 e5                	mov    %esp,%ebp
    101a:	83 ec 04             	sub    $0x4,%esp
    101d:	8b 45 0c             	mov    0xc(%ebp),%eax
    1020:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    1023:	eb 14                	jmp    1039 <strchr+0x22>
    if(*s == c)
    1025:	8b 45 08             	mov    0x8(%ebp),%eax
    1028:	0f b6 00             	movzbl (%eax),%eax
    102b:	3a 45 fc             	cmp    -0x4(%ebp),%al
    102e:	75 05                	jne    1035 <strchr+0x1e>
      return (char*)s;
    1030:	8b 45 08             	mov    0x8(%ebp),%eax
    1033:	eb 13                	jmp    1048 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    1035:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1039:	8b 45 08             	mov    0x8(%ebp),%eax
    103c:	0f b6 00             	movzbl (%eax),%eax
    103f:	84 c0                	test   %al,%al
    1041:	75 e2                	jne    1025 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    1043:	b8 00 00 00 00       	mov    $0x0,%eax
}
    1048:	c9                   	leave  
    1049:	c3                   	ret    

0000104a <gets>:

char*
gets(char *buf, int max)
{
    104a:	55                   	push   %ebp
    104b:	89 e5                	mov    %esp,%ebp
    104d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    1050:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1057:	eb 44                	jmp    109d <gets+0x53>
    cc = read(0, &c, 1);
    1059:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    1060:	00 
    1061:	8d 45 ef             	lea    -0x11(%ebp),%eax
    1064:	89 44 24 04          	mov    %eax,0x4(%esp)
    1068:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    106f:	e8 e8 02 00 00       	call   135c <read>
    1074:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    1077:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    107b:	7e 2d                	jle    10aa <gets+0x60>
      break;
    buf[i++] = c;
    107d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1080:	03 45 08             	add    0x8(%ebp),%eax
    1083:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
    1087:	88 10                	mov    %dl,(%eax)
    1089:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
    108d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1091:	3c 0a                	cmp    $0xa,%al
    1093:	74 16                	je     10ab <gets+0x61>
    1095:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    1099:	3c 0d                	cmp    $0xd,%al
    109b:	74 0e                	je     10ab <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    109d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10a0:	83 c0 01             	add    $0x1,%eax
    10a3:	3b 45 0c             	cmp    0xc(%ebp),%eax
    10a6:	7c b1                	jl     1059 <gets+0xf>
    10a8:	eb 01                	jmp    10ab <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    10aa:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    10ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10ae:	03 45 08             	add    0x8(%ebp),%eax
    10b1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    10b4:	8b 45 08             	mov    0x8(%ebp),%eax
}
    10b7:	c9                   	leave  
    10b8:	c3                   	ret    

000010b9 <stat>:

int
stat(char *n, struct stat *st)
{
    10b9:	55                   	push   %ebp
    10ba:	89 e5                	mov    %esp,%ebp
    10bc:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    10bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    10c6:	00 
    10c7:	8b 45 08             	mov    0x8(%ebp),%eax
    10ca:	89 04 24             	mov    %eax,(%esp)
    10cd:	e8 b2 02 00 00       	call   1384 <open>
    10d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    10d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    10d9:	79 07                	jns    10e2 <stat+0x29>
    return -1;
    10db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    10e0:	eb 23                	jmp    1105 <stat+0x4c>
  r = fstat(fd, st);
    10e2:	8b 45 0c             	mov    0xc(%ebp),%eax
    10e5:	89 44 24 04          	mov    %eax,0x4(%esp)
    10e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10ec:	89 04 24             	mov    %eax,(%esp)
    10ef:	e8 a8 02 00 00       	call   139c <fstat>
    10f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    10f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10fa:	89 04 24             	mov    %eax,(%esp)
    10fd:	e8 6a 02 00 00       	call   136c <close>
  return r;
    1102:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1105:	c9                   	leave  
    1106:	c3                   	ret    

00001107 <atoi>:

int
atoi(const char *s)
{
    1107:	55                   	push   %ebp
    1108:	89 e5                	mov    %esp,%ebp
    110a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    110d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    1114:	eb 23                	jmp    1139 <atoi+0x32>
    n = n*10 + *s++ - '0';
    1116:	8b 55 fc             	mov    -0x4(%ebp),%edx
    1119:	89 d0                	mov    %edx,%eax
    111b:	c1 e0 02             	shl    $0x2,%eax
    111e:	01 d0                	add    %edx,%eax
    1120:	01 c0                	add    %eax,%eax
    1122:	89 c2                	mov    %eax,%edx
    1124:	8b 45 08             	mov    0x8(%ebp),%eax
    1127:	0f b6 00             	movzbl (%eax),%eax
    112a:	0f be c0             	movsbl %al,%eax
    112d:	01 d0                	add    %edx,%eax
    112f:	83 e8 30             	sub    $0x30,%eax
    1132:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1135:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    1139:	8b 45 08             	mov    0x8(%ebp),%eax
    113c:	0f b6 00             	movzbl (%eax),%eax
    113f:	3c 2f                	cmp    $0x2f,%al
    1141:	7e 0a                	jle    114d <atoi+0x46>
    1143:	8b 45 08             	mov    0x8(%ebp),%eax
    1146:	0f b6 00             	movzbl (%eax),%eax
    1149:	3c 39                	cmp    $0x39,%al
    114b:	7e c9                	jle    1116 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    114d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1150:	c9                   	leave  
    1151:	c3                   	ret    

00001152 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    1152:	55                   	push   %ebp
    1153:	89 e5                	mov    %esp,%ebp
    1155:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    1158:	8b 45 08             	mov    0x8(%ebp),%eax
    115b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    115e:	8b 45 0c             	mov    0xc(%ebp),%eax
    1161:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    1164:	eb 13                	jmp    1179 <memmove+0x27>
    *dst++ = *src++;
    1166:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1169:	0f b6 10             	movzbl (%eax),%edx
    116c:	8b 45 fc             	mov    -0x4(%ebp),%eax
    116f:	88 10                	mov    %dl,(%eax)
    1171:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    1175:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    1179:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    117d:	0f 9f c0             	setg   %al
    1180:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    1184:	84 c0                	test   %al,%al
    1186:	75 de                	jne    1166 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    1188:	8b 45 08             	mov    0x8(%ebp),%eax
}
    118b:	c9                   	leave  
    118c:	c3                   	ret    

0000118d <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
    118d:	55                   	push   %ebp
    118e:	89 e5                	mov    %esp,%ebp
    1190:	83 ec 38             	sub    $0x38,%esp
    1193:	8b 45 10             	mov    0x10(%ebp),%eax
    1196:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
    1199:	8b 45 14             	mov    0x14(%ebp),%eax
    119c:	8b 00                	mov    (%eax),%eax
    119e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    11a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
    11a8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    11ac:	74 06                	je     11b4 <strtok+0x27>
    11ae:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
    11b2:	75 54                	jne    1208 <strtok+0x7b>
    return match;
    11b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    11b7:	eb 6e                	jmp    1227 <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
    11b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11bc:	03 45 0c             	add    0xc(%ebp),%eax
    11bf:	0f b6 00             	movzbl (%eax),%eax
    11c2:	3a 45 e4             	cmp    -0x1c(%ebp),%al
    11c5:	74 06                	je     11cd <strtok+0x40>
      {
	index++;
    11c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    11cb:	eb 3c                	jmp    1209 <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
    11cd:	8b 45 14             	mov    0x14(%ebp),%eax
    11d0:	8b 00                	mov    (%eax),%eax
    11d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
    11d5:	29 c2                	sub    %eax,%edx
    11d7:	8b 45 14             	mov    0x14(%ebp),%eax
    11da:	8b 00                	mov    (%eax),%eax
    11dc:	03 45 0c             	add    0xc(%ebp),%eax
    11df:	89 54 24 08          	mov    %edx,0x8(%esp)
    11e3:	89 44 24 04          	mov    %eax,0x4(%esp)
    11e7:	8b 45 08             	mov    0x8(%ebp),%eax
    11ea:	89 04 24             	mov    %eax,(%esp)
    11ed:	e8 37 00 00 00       	call   1229 <strncpy>
    11f2:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
    11f5:	8b 45 08             	mov    0x8(%ebp),%eax
    11f8:	0f b6 00             	movzbl (%eax),%eax
    11fb:	84 c0                	test   %al,%al
    11fd:	74 19                	je     1218 <strtok+0x8b>
	  match = 1;
    11ff:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
    1206:	eb 10                	jmp    1218 <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
    1208:	90                   	nop
    1209:	8b 45 f4             	mov    -0xc(%ebp),%eax
    120c:	03 45 0c             	add    0xc(%ebp),%eax
    120f:	0f b6 00             	movzbl (%eax),%eax
    1212:	84 c0                	test   %al,%al
    1214:	75 a3                	jne    11b9 <strtok+0x2c>
    1216:	eb 01                	jmp    1219 <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
    1218:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
    1219:	8b 45 f4             	mov    -0xc(%ebp),%eax
    121c:	8d 50 01             	lea    0x1(%eax),%edx
    121f:	8b 45 14             	mov    0x14(%ebp),%eax
    1222:	89 10                	mov    %edx,(%eax)
  return match;
    1224:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    1227:	c9                   	leave  
    1228:	c3                   	ret    

00001229 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    1229:	55                   	push   %ebp
    122a:	89 e5                	mov    %esp,%ebp
    122c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
    122f:	8b 45 08             	mov    0x8(%ebp),%eax
    1232:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
    1235:	90                   	nop
    1236:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    123a:	0f 9f c0             	setg   %al
    123d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    1241:	84 c0                	test   %al,%al
    1243:	74 30                	je     1275 <strncpy+0x4c>
    1245:	8b 45 0c             	mov    0xc(%ebp),%eax
    1248:	0f b6 10             	movzbl (%eax),%edx
    124b:	8b 45 08             	mov    0x8(%ebp),%eax
    124e:	88 10                	mov    %dl,(%eax)
    1250:	8b 45 08             	mov    0x8(%ebp),%eax
    1253:	0f b6 00             	movzbl (%eax),%eax
    1256:	84 c0                	test   %al,%al
    1258:	0f 95 c0             	setne  %al
    125b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    125f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    1263:	84 c0                	test   %al,%al
    1265:	75 cf                	jne    1236 <strncpy+0xd>
    ;
  while(n-- > 0)
    1267:	eb 0c                	jmp    1275 <strncpy+0x4c>
    *s++ = 0;
    1269:	8b 45 08             	mov    0x8(%ebp),%eax
    126c:	c6 00 00             	movb   $0x0,(%eax)
    126f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1273:	eb 01                	jmp    1276 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
    1275:	90                   	nop
    1276:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    127a:	0f 9f c0             	setg   %al
    127d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    1281:	84 c0                	test   %al,%al
    1283:	75 e4                	jne    1269 <strncpy+0x40>
    *s++ = 0;
  return os;
    1285:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    1288:	c9                   	leave  
    1289:	c3                   	ret    

0000128a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    128a:	55                   	push   %ebp
    128b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
    128d:	eb 0c                	jmp    129b <strncmp+0x11>
    n--, p++, q++;
    128f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    1293:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1297:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
    129b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    129f:	74 1a                	je     12bb <strncmp+0x31>
    12a1:	8b 45 08             	mov    0x8(%ebp),%eax
    12a4:	0f b6 00             	movzbl (%eax),%eax
    12a7:	84 c0                	test   %al,%al
    12a9:	74 10                	je     12bb <strncmp+0x31>
    12ab:	8b 45 08             	mov    0x8(%ebp),%eax
    12ae:	0f b6 10             	movzbl (%eax),%edx
    12b1:	8b 45 0c             	mov    0xc(%ebp),%eax
    12b4:	0f b6 00             	movzbl (%eax),%eax
    12b7:	38 c2                	cmp    %al,%dl
    12b9:	74 d4                	je     128f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
    12bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    12bf:	75 07                	jne    12c8 <strncmp+0x3e>
    return 0;
    12c1:	b8 00 00 00 00       	mov    $0x0,%eax
    12c6:	eb 18                	jmp    12e0 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
    12c8:	8b 45 08             	mov    0x8(%ebp),%eax
    12cb:	0f b6 00             	movzbl (%eax),%eax
    12ce:	0f b6 d0             	movzbl %al,%edx
    12d1:	8b 45 0c             	mov    0xc(%ebp),%eax
    12d4:	0f b6 00             	movzbl (%eax),%eax
    12d7:	0f b6 c0             	movzbl %al,%eax
    12da:	89 d1                	mov    %edx,%ecx
    12dc:	29 c1                	sub    %eax,%ecx
    12de:	89 c8                	mov    %ecx,%eax
}
    12e0:	5d                   	pop    %ebp
    12e1:	c3                   	ret    

000012e2 <strcat>:

void
strcat(char *dest, char *p, char *q)
{  
    12e2:	55                   	push   %ebp
    12e3:	89 e5                	mov    %esp,%ebp
  while(*p){
    12e5:	eb 13                	jmp    12fa <strcat+0x18>
    *dest++ = *p++;
    12e7:	8b 45 0c             	mov    0xc(%ebp),%eax
    12ea:	0f b6 10             	movzbl (%eax),%edx
    12ed:	8b 45 08             	mov    0x8(%ebp),%eax
    12f0:	88 10                	mov    %dl,(%eax)
    12f2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    12f6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, char *p, char *q)
{  
  while(*p){
    12fa:	8b 45 0c             	mov    0xc(%ebp),%eax
    12fd:	0f b6 00             	movzbl (%eax),%eax
    1300:	84 c0                	test   %al,%al
    1302:	75 e3                	jne    12e7 <strcat+0x5>
    *dest++ = *p++;
  }

  while(*q){
    1304:	eb 13                	jmp    1319 <strcat+0x37>
    *dest++ = *q++;
    1306:	8b 45 10             	mov    0x10(%ebp),%eax
    1309:	0f b6 10             	movzbl (%eax),%edx
    130c:	8b 45 08             	mov    0x8(%ebp),%eax
    130f:	88 10                	mov    %dl,(%eax)
    1311:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    1315:	83 45 10 01          	addl   $0x1,0x10(%ebp)
{  
  while(*p){
    *dest++ = *p++;
  }

  while(*q){
    1319:	8b 45 10             	mov    0x10(%ebp),%eax
    131c:	0f b6 00             	movzbl (%eax),%eax
    131f:	84 c0                	test   %al,%al
    1321:	75 e3                	jne    1306 <strcat+0x24>
    *dest++ = *q++;
  }
  *dest = 0;
    1323:	8b 45 08             	mov    0x8(%ebp),%eax
    1326:	c6 00 00             	movb   $0x0,(%eax)
    1329:	5d                   	pop    %ebp
    132a:	c3                   	ret    
    132b:	90                   	nop

0000132c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    132c:	b8 01 00 00 00       	mov    $0x1,%eax
    1331:	cd 40                	int    $0x40
    1333:	c3                   	ret    

00001334 <exit>:
SYSCALL(exit)
    1334:	b8 02 00 00 00       	mov    $0x2,%eax
    1339:	cd 40                	int    $0x40
    133b:	c3                   	ret    

0000133c <wait>:
SYSCALL(wait)
    133c:	b8 03 00 00 00       	mov    $0x3,%eax
    1341:	cd 40                	int    $0x40
    1343:	c3                   	ret    

00001344 <wait2>:
SYSCALL(wait2)
    1344:	b8 16 00 00 00       	mov    $0x16,%eax
    1349:	cd 40                	int    $0x40
    134b:	c3                   	ret    

0000134c <nice>:
SYSCALL(nice)
    134c:	b8 17 00 00 00       	mov    $0x17,%eax
    1351:	cd 40                	int    $0x40
    1353:	c3                   	ret    

00001354 <pipe>:
SYSCALL(pipe)
    1354:	b8 04 00 00 00       	mov    $0x4,%eax
    1359:	cd 40                	int    $0x40
    135b:	c3                   	ret    

0000135c <read>:
SYSCALL(read)
    135c:	b8 05 00 00 00       	mov    $0x5,%eax
    1361:	cd 40                	int    $0x40
    1363:	c3                   	ret    

00001364 <write>:
SYSCALL(write)
    1364:	b8 10 00 00 00       	mov    $0x10,%eax
    1369:	cd 40                	int    $0x40
    136b:	c3                   	ret    

0000136c <close>:
SYSCALL(close)
    136c:	b8 15 00 00 00       	mov    $0x15,%eax
    1371:	cd 40                	int    $0x40
    1373:	c3                   	ret    

00001374 <kill>:
SYSCALL(kill)
    1374:	b8 06 00 00 00       	mov    $0x6,%eax
    1379:	cd 40                	int    $0x40
    137b:	c3                   	ret    

0000137c <exec>:
SYSCALL(exec)
    137c:	b8 07 00 00 00       	mov    $0x7,%eax
    1381:	cd 40                	int    $0x40
    1383:	c3                   	ret    

00001384 <open>:
SYSCALL(open)
    1384:	b8 0f 00 00 00       	mov    $0xf,%eax
    1389:	cd 40                	int    $0x40
    138b:	c3                   	ret    

0000138c <mknod>:
SYSCALL(mknod)
    138c:	b8 11 00 00 00       	mov    $0x11,%eax
    1391:	cd 40                	int    $0x40
    1393:	c3                   	ret    

00001394 <unlink>:
SYSCALL(unlink)
    1394:	b8 12 00 00 00       	mov    $0x12,%eax
    1399:	cd 40                	int    $0x40
    139b:	c3                   	ret    

0000139c <fstat>:
SYSCALL(fstat)
    139c:	b8 08 00 00 00       	mov    $0x8,%eax
    13a1:	cd 40                	int    $0x40
    13a3:	c3                   	ret    

000013a4 <link>:
SYSCALL(link)
    13a4:	b8 13 00 00 00       	mov    $0x13,%eax
    13a9:	cd 40                	int    $0x40
    13ab:	c3                   	ret    

000013ac <mkdir>:
SYSCALL(mkdir)
    13ac:	b8 14 00 00 00       	mov    $0x14,%eax
    13b1:	cd 40                	int    $0x40
    13b3:	c3                   	ret    

000013b4 <chdir>:
SYSCALL(chdir)
    13b4:	b8 09 00 00 00       	mov    $0x9,%eax
    13b9:	cd 40                	int    $0x40
    13bb:	c3                   	ret    

000013bc <dup>:
SYSCALL(dup)
    13bc:	b8 0a 00 00 00       	mov    $0xa,%eax
    13c1:	cd 40                	int    $0x40
    13c3:	c3                   	ret    

000013c4 <getpid>:
SYSCALL(getpid)
    13c4:	b8 0b 00 00 00       	mov    $0xb,%eax
    13c9:	cd 40                	int    $0x40
    13cb:	c3                   	ret    

000013cc <sbrk>:
SYSCALL(sbrk)
    13cc:	b8 0c 00 00 00       	mov    $0xc,%eax
    13d1:	cd 40                	int    $0x40
    13d3:	c3                   	ret    

000013d4 <sleep>:
SYSCALL(sleep)
    13d4:	b8 0d 00 00 00       	mov    $0xd,%eax
    13d9:	cd 40                	int    $0x40
    13db:	c3                   	ret    

000013dc <uptime>:
SYSCALL(uptime)
    13dc:	b8 0e 00 00 00       	mov    $0xe,%eax
    13e1:	cd 40                	int    $0x40
    13e3:	c3                   	ret    

000013e4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    13e4:	55                   	push   %ebp
    13e5:	89 e5                	mov    %esp,%ebp
    13e7:	83 ec 28             	sub    $0x28,%esp
    13ea:	8b 45 0c             	mov    0xc(%ebp),%eax
    13ed:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    13f0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    13f7:	00 
    13f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
    13fb:	89 44 24 04          	mov    %eax,0x4(%esp)
    13ff:	8b 45 08             	mov    0x8(%ebp),%eax
    1402:	89 04 24             	mov    %eax,(%esp)
    1405:	e8 5a ff ff ff       	call   1364 <write>
}
    140a:	c9                   	leave  
    140b:	c3                   	ret    

0000140c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    140c:	55                   	push   %ebp
    140d:	89 e5                	mov    %esp,%ebp
    140f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    1412:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1419:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    141d:	74 17                	je     1436 <printint+0x2a>
    141f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    1423:	79 11                	jns    1436 <printint+0x2a>
    neg = 1;
    1425:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    142c:	8b 45 0c             	mov    0xc(%ebp),%eax
    142f:	f7 d8                	neg    %eax
    1431:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1434:	eb 06                	jmp    143c <printint+0x30>
  } else {
    x = xx;
    1436:	8b 45 0c             	mov    0xc(%ebp),%eax
    1439:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    143c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    1443:	8b 4d 10             	mov    0x10(%ebp),%ecx
    1446:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1449:	ba 00 00 00 00       	mov    $0x0,%edx
    144e:	f7 f1                	div    %ecx
    1450:	89 d0                	mov    %edx,%eax
    1452:	0f b6 90 94 1e 00 00 	movzbl 0x1e94(%eax),%edx
    1459:	8d 45 dc             	lea    -0x24(%ebp),%eax
    145c:	03 45 f4             	add    -0xc(%ebp),%eax
    145f:	88 10                	mov    %dl,(%eax)
    1461:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    1465:	8b 55 10             	mov    0x10(%ebp),%edx
    1468:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    146b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    146e:	ba 00 00 00 00       	mov    $0x0,%edx
    1473:	f7 75 d4             	divl   -0x2c(%ebp)
    1476:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1479:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    147d:	75 c4                	jne    1443 <printint+0x37>
  if(neg)
    147f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1483:	74 2a                	je     14af <printint+0xa3>
    buf[i++] = '-';
    1485:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1488:	03 45 f4             	add    -0xc(%ebp),%eax
    148b:	c6 00 2d             	movb   $0x2d,(%eax)
    148e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    1492:	eb 1b                	jmp    14af <printint+0xa3>
    putc(fd, buf[i]);
    1494:	8d 45 dc             	lea    -0x24(%ebp),%eax
    1497:	03 45 f4             	add    -0xc(%ebp),%eax
    149a:	0f b6 00             	movzbl (%eax),%eax
    149d:	0f be c0             	movsbl %al,%eax
    14a0:	89 44 24 04          	mov    %eax,0x4(%esp)
    14a4:	8b 45 08             	mov    0x8(%ebp),%eax
    14a7:	89 04 24             	mov    %eax,(%esp)
    14aa:	e8 35 ff ff ff       	call   13e4 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    14af:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    14b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    14b7:	79 db                	jns    1494 <printint+0x88>
    putc(fd, buf[i]);
}
    14b9:	c9                   	leave  
    14ba:	c3                   	ret    

000014bb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    14bb:	55                   	push   %ebp
    14bc:	89 e5                	mov    %esp,%ebp
    14be:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    14c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    14c8:	8d 45 0c             	lea    0xc(%ebp),%eax
    14cb:	83 c0 04             	add    $0x4,%eax
    14ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    14d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    14d8:	e9 7d 01 00 00       	jmp    165a <printf+0x19f>
    c = fmt[i] & 0xff;
    14dd:	8b 55 0c             	mov    0xc(%ebp),%edx
    14e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    14e3:	01 d0                	add    %edx,%eax
    14e5:	0f b6 00             	movzbl (%eax),%eax
    14e8:	0f be c0             	movsbl %al,%eax
    14eb:	25 ff 00 00 00       	and    $0xff,%eax
    14f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    14f3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    14f7:	75 2c                	jne    1525 <printf+0x6a>
      if(c == '%'){
    14f9:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    14fd:	75 0c                	jne    150b <printf+0x50>
        state = '%';
    14ff:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1506:	e9 4b 01 00 00       	jmp    1656 <printf+0x19b>
      } else {
        putc(fd, c);
    150b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    150e:	0f be c0             	movsbl %al,%eax
    1511:	89 44 24 04          	mov    %eax,0x4(%esp)
    1515:	8b 45 08             	mov    0x8(%ebp),%eax
    1518:	89 04 24             	mov    %eax,(%esp)
    151b:	e8 c4 fe ff ff       	call   13e4 <putc>
    1520:	e9 31 01 00 00       	jmp    1656 <printf+0x19b>
      }
    } else if(state == '%'){
    1525:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1529:	0f 85 27 01 00 00    	jne    1656 <printf+0x19b>
      if(c == 'd'){
    152f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    1533:	75 2d                	jne    1562 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    1535:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1538:	8b 00                	mov    (%eax),%eax
    153a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    1541:	00 
    1542:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1549:	00 
    154a:	89 44 24 04          	mov    %eax,0x4(%esp)
    154e:	8b 45 08             	mov    0x8(%ebp),%eax
    1551:	89 04 24             	mov    %eax,(%esp)
    1554:	e8 b3 fe ff ff       	call   140c <printint>
        ap++;
    1559:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    155d:	e9 ed 00 00 00       	jmp    164f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
    1562:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1566:	74 06                	je     156e <printf+0xb3>
    1568:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    156c:	75 2d                	jne    159b <printf+0xe0>
        printint(fd, *ap, 16, 0);
    156e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1571:	8b 00                	mov    (%eax),%eax
    1573:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    157a:	00 
    157b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1582:	00 
    1583:	89 44 24 04          	mov    %eax,0x4(%esp)
    1587:	8b 45 08             	mov    0x8(%ebp),%eax
    158a:	89 04 24             	mov    %eax,(%esp)
    158d:	e8 7a fe ff ff       	call   140c <printint>
        ap++;
    1592:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1596:	e9 b4 00 00 00       	jmp    164f <printf+0x194>
      } else if(c == 's'){
    159b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    159f:	75 46                	jne    15e7 <printf+0x12c>
        s = (char*)*ap;
    15a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15a4:	8b 00                	mov    (%eax),%eax
    15a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    15a9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    15ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    15b1:	75 27                	jne    15da <printf+0x11f>
          s = "(null)";
    15b3:	c7 45 f4 7e 19 00 00 	movl   $0x197e,-0xc(%ebp)
        while(*s != 0){
    15ba:	eb 1e                	jmp    15da <printf+0x11f>
          putc(fd, *s);
    15bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15bf:	0f b6 00             	movzbl (%eax),%eax
    15c2:	0f be c0             	movsbl %al,%eax
    15c5:	89 44 24 04          	mov    %eax,0x4(%esp)
    15c9:	8b 45 08             	mov    0x8(%ebp),%eax
    15cc:	89 04 24             	mov    %eax,(%esp)
    15cf:	e8 10 fe ff ff       	call   13e4 <putc>
          s++;
    15d4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    15d8:	eb 01                	jmp    15db <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    15da:	90                   	nop
    15db:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15de:	0f b6 00             	movzbl (%eax),%eax
    15e1:	84 c0                	test   %al,%al
    15e3:	75 d7                	jne    15bc <printf+0x101>
    15e5:	eb 68                	jmp    164f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    15e7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    15eb:	75 1d                	jne    160a <printf+0x14f>
        putc(fd, *ap);
    15ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
    15f0:	8b 00                	mov    (%eax),%eax
    15f2:	0f be c0             	movsbl %al,%eax
    15f5:	89 44 24 04          	mov    %eax,0x4(%esp)
    15f9:	8b 45 08             	mov    0x8(%ebp),%eax
    15fc:	89 04 24             	mov    %eax,(%esp)
    15ff:	e8 e0 fd ff ff       	call   13e4 <putc>
        ap++;
    1604:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1608:	eb 45                	jmp    164f <printf+0x194>
      } else if(c == '%'){
    160a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    160e:	75 17                	jne    1627 <printf+0x16c>
        putc(fd, c);
    1610:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1613:	0f be c0             	movsbl %al,%eax
    1616:	89 44 24 04          	mov    %eax,0x4(%esp)
    161a:	8b 45 08             	mov    0x8(%ebp),%eax
    161d:	89 04 24             	mov    %eax,(%esp)
    1620:	e8 bf fd ff ff       	call   13e4 <putc>
    1625:	eb 28                	jmp    164f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1627:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    162e:	00 
    162f:	8b 45 08             	mov    0x8(%ebp),%eax
    1632:	89 04 24             	mov    %eax,(%esp)
    1635:	e8 aa fd ff ff       	call   13e4 <putc>
        putc(fd, c);
    163a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    163d:	0f be c0             	movsbl %al,%eax
    1640:	89 44 24 04          	mov    %eax,0x4(%esp)
    1644:	8b 45 08             	mov    0x8(%ebp),%eax
    1647:	89 04 24             	mov    %eax,(%esp)
    164a:	e8 95 fd ff ff       	call   13e4 <putc>
      }
      state = 0;
    164f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    1656:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    165a:	8b 55 0c             	mov    0xc(%ebp),%edx
    165d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1660:	01 d0                	add    %edx,%eax
    1662:	0f b6 00             	movzbl (%eax),%eax
    1665:	84 c0                	test   %al,%al
    1667:	0f 85 70 fe ff ff    	jne    14dd <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    166d:	c9                   	leave  
    166e:	c3                   	ret    
    166f:	90                   	nop

00001670 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1670:	55                   	push   %ebp
    1671:	89 e5                	mov    %esp,%ebp
    1673:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1676:	8b 45 08             	mov    0x8(%ebp),%eax
    1679:	83 e8 08             	sub    $0x8,%eax
    167c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    167f:	a1 2c 1f 00 00       	mov    0x1f2c,%eax
    1684:	89 45 fc             	mov    %eax,-0x4(%ebp)
    1687:	eb 24                	jmp    16ad <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1689:	8b 45 fc             	mov    -0x4(%ebp),%eax
    168c:	8b 00                	mov    (%eax),%eax
    168e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1691:	77 12                	ja     16a5 <free+0x35>
    1693:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1696:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1699:	77 24                	ja     16bf <free+0x4f>
    169b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    169e:	8b 00                	mov    (%eax),%eax
    16a0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16a3:	77 1a                	ja     16bf <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    16a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16a8:	8b 00                	mov    (%eax),%eax
    16aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
    16ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16b0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    16b3:	76 d4                	jbe    1689 <free+0x19>
    16b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16b8:	8b 00                	mov    (%eax),%eax
    16ba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    16bd:	76 ca                	jbe    1689 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    16bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16c2:	8b 40 04             	mov    0x4(%eax),%eax
    16c5:	c1 e0 03             	shl    $0x3,%eax
    16c8:	89 c2                	mov    %eax,%edx
    16ca:	03 55 f8             	add    -0x8(%ebp),%edx
    16cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16d0:	8b 00                	mov    (%eax),%eax
    16d2:	39 c2                	cmp    %eax,%edx
    16d4:	75 24                	jne    16fa <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
    16d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16d9:	8b 50 04             	mov    0x4(%eax),%edx
    16dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16df:	8b 00                	mov    (%eax),%eax
    16e1:	8b 40 04             	mov    0x4(%eax),%eax
    16e4:	01 c2                	add    %eax,%edx
    16e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16e9:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    16ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16ef:	8b 00                	mov    (%eax),%eax
    16f1:	8b 10                	mov    (%eax),%edx
    16f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    16f6:	89 10                	mov    %edx,(%eax)
    16f8:	eb 0a                	jmp    1704 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
    16fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
    16fd:	8b 10                	mov    (%eax),%edx
    16ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1702:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1704:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1707:	8b 40 04             	mov    0x4(%eax),%eax
    170a:	c1 e0 03             	shl    $0x3,%eax
    170d:	03 45 fc             	add    -0x4(%ebp),%eax
    1710:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1713:	75 20                	jne    1735 <free+0xc5>
    p->s.size += bp->s.size;
    1715:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1718:	8b 50 04             	mov    0x4(%eax),%edx
    171b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    171e:	8b 40 04             	mov    0x4(%eax),%eax
    1721:	01 c2                	add    %eax,%edx
    1723:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1726:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    1729:	8b 45 f8             	mov    -0x8(%ebp),%eax
    172c:	8b 10                	mov    (%eax),%edx
    172e:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1731:	89 10                	mov    %edx,(%eax)
    1733:	eb 08                	jmp    173d <free+0xcd>
  } else
    p->s.ptr = bp;
    1735:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1738:	8b 55 f8             	mov    -0x8(%ebp),%edx
    173b:	89 10                	mov    %edx,(%eax)
  freep = p;
    173d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1740:	a3 2c 1f 00 00       	mov    %eax,0x1f2c
}
    1745:	c9                   	leave  
    1746:	c3                   	ret    

00001747 <morecore>:

static Header*
morecore(uint nu)
{
    1747:	55                   	push   %ebp
    1748:	89 e5                	mov    %esp,%ebp
    174a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    174d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1754:	77 07                	ja     175d <morecore+0x16>
    nu = 4096;
    1756:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    175d:	8b 45 08             	mov    0x8(%ebp),%eax
    1760:	c1 e0 03             	shl    $0x3,%eax
    1763:	89 04 24             	mov    %eax,(%esp)
    1766:	e8 61 fc ff ff       	call   13cc <sbrk>
    176b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    176e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1772:	75 07                	jne    177b <morecore+0x34>
    return 0;
    1774:	b8 00 00 00 00       	mov    $0x0,%eax
    1779:	eb 22                	jmp    179d <morecore+0x56>
  hp = (Header*)p;
    177b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    177e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1781:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1784:	8b 55 08             	mov    0x8(%ebp),%edx
    1787:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    178a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    178d:	83 c0 08             	add    $0x8,%eax
    1790:	89 04 24             	mov    %eax,(%esp)
    1793:	e8 d8 fe ff ff       	call   1670 <free>
  return freep;
    1798:	a1 2c 1f 00 00       	mov    0x1f2c,%eax
}
    179d:	c9                   	leave  
    179e:	c3                   	ret    

0000179f <malloc>:

void*
malloc(uint nbytes)
{
    179f:	55                   	push   %ebp
    17a0:	89 e5                	mov    %esp,%ebp
    17a2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    17a5:	8b 45 08             	mov    0x8(%ebp),%eax
    17a8:	83 c0 07             	add    $0x7,%eax
    17ab:	c1 e8 03             	shr    $0x3,%eax
    17ae:	83 c0 01             	add    $0x1,%eax
    17b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    17b4:	a1 2c 1f 00 00       	mov    0x1f2c,%eax
    17b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    17bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    17c0:	75 23                	jne    17e5 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    17c2:	c7 45 f0 24 1f 00 00 	movl   $0x1f24,-0x10(%ebp)
    17c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17cc:	a3 2c 1f 00 00       	mov    %eax,0x1f2c
    17d1:	a1 2c 1f 00 00       	mov    0x1f2c,%eax
    17d6:	a3 24 1f 00 00       	mov    %eax,0x1f24
    base.s.size = 0;
    17db:	c7 05 28 1f 00 00 00 	movl   $0x0,0x1f28
    17e2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    17e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    17e8:	8b 00                	mov    (%eax),%eax
    17ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    17ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17f0:	8b 40 04             	mov    0x4(%eax),%eax
    17f3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    17f6:	72 4d                	jb     1845 <malloc+0xa6>
      if(p->s.size == nunits)
    17f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    17fb:	8b 40 04             	mov    0x4(%eax),%eax
    17fe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1801:	75 0c                	jne    180f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    1803:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1806:	8b 10                	mov    (%eax),%edx
    1808:	8b 45 f0             	mov    -0x10(%ebp),%eax
    180b:	89 10                	mov    %edx,(%eax)
    180d:	eb 26                	jmp    1835 <malloc+0x96>
      else {
        p->s.size -= nunits;
    180f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1812:	8b 40 04             	mov    0x4(%eax),%eax
    1815:	89 c2                	mov    %eax,%edx
    1817:	2b 55 ec             	sub    -0x14(%ebp),%edx
    181a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    181d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1820:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1823:	8b 40 04             	mov    0x4(%eax),%eax
    1826:	c1 e0 03             	shl    $0x3,%eax
    1829:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    182f:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1832:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1835:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1838:	a3 2c 1f 00 00       	mov    %eax,0x1f2c
      return (void*)(p + 1);
    183d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1840:	83 c0 08             	add    $0x8,%eax
    1843:	eb 38                	jmp    187d <malloc+0xde>
    }
    if(p == freep)
    1845:	a1 2c 1f 00 00       	mov    0x1f2c,%eax
    184a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    184d:	75 1b                	jne    186a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    184f:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1852:	89 04 24             	mov    %eax,(%esp)
    1855:	e8 ed fe ff ff       	call   1747 <morecore>
    185a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    185d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1861:	75 07                	jne    186a <malloc+0xcb>
        return 0;
    1863:	b8 00 00 00 00       	mov    $0x0,%eax
    1868:	eb 13                	jmp    187d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    186a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    186d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1870:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1873:	8b 00                	mov    (%eax),%eax
    1875:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1878:	e9 70 ff ff ff       	jmp    17ed <malloc+0x4e>
}
    187d:	c9                   	leave  
    187e:	c3                   	ret    
