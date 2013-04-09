
_usertests:     file format elf32-i386


Disassembly of section .text:

00000000 <opentest>:

// simple file system tests

void
opentest(void)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(stdout, "open test\n");
       6:	a1 10 61 00 00       	mov    0x6110,%eax
       b:	c7 44 24 04 52 43 00 	movl   $0x4352,0x4(%esp)
      12:	00 
      13:	89 04 24             	mov    %eax,(%esp)
      16:	e8 4e 3f 00 00       	call   3f69 <printf>
  fd = open("echo", 0);
      1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      22:	00 
      23:	c7 04 24 3c 43 00 00 	movl   $0x433c,(%esp)
      2a:	e8 fd 3d 00 00       	call   3e2c <open>
      2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
      32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
      36:	79 1a                	jns    52 <opentest+0x52>
    printf(stdout, "open echo failed!\n");
      38:	a1 10 61 00 00       	mov    0x6110,%eax
      3d:	c7 44 24 04 5d 43 00 	movl   $0x435d,0x4(%esp)
      44:	00 
      45:	89 04 24             	mov    %eax,(%esp)
      48:	e8 1c 3f 00 00       	call   3f69 <printf>
    exit();
      4d:	e8 8a 3d 00 00       	call   3ddc <exit>
  }
  close(fd);
      52:	8b 45 f4             	mov    -0xc(%ebp),%eax
      55:	89 04 24             	mov    %eax,(%esp)
      58:	e8 b7 3d 00 00       	call   3e14 <close>
  fd = open("doesnotexist", 0);
      5d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
      64:	00 
      65:	c7 04 24 70 43 00 00 	movl   $0x4370,(%esp)
      6c:	e8 bb 3d 00 00       	call   3e2c <open>
      71:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
      74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
      78:	78 1a                	js     94 <opentest+0x94>
    printf(stdout, "open doesnotexist succeeded!\n");
      7a:	a1 10 61 00 00       	mov    0x6110,%eax
      7f:	c7 44 24 04 7d 43 00 	movl   $0x437d,0x4(%esp)
      86:	00 
      87:	89 04 24             	mov    %eax,(%esp)
      8a:	e8 da 3e 00 00       	call   3f69 <printf>
    exit();
      8f:	e8 48 3d 00 00       	call   3ddc <exit>
  }
  printf(stdout, "open test ok\n");
      94:	a1 10 61 00 00       	mov    0x6110,%eax
      99:	c7 44 24 04 9b 43 00 	movl   $0x439b,0x4(%esp)
      a0:	00 
      a1:	89 04 24             	mov    %eax,(%esp)
      a4:	e8 c0 3e 00 00       	call   3f69 <printf>
}
      a9:	c9                   	leave  
      aa:	c3                   	ret    

000000ab <writetest>:

void
writetest(void)
{
      ab:	55                   	push   %ebp
      ac:	89 e5                	mov    %esp,%ebp
      ae:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int i;

  printf(stdout, "small file test\n");
      b1:	a1 10 61 00 00       	mov    0x6110,%eax
      b6:	c7 44 24 04 a9 43 00 	movl   $0x43a9,0x4(%esp)
      bd:	00 
      be:	89 04 24             	mov    %eax,(%esp)
      c1:	e8 a3 3e 00 00       	call   3f69 <printf>
  fd = open("small", O_CREATE|O_RDWR);
      c6:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
      cd:	00 
      ce:	c7 04 24 ba 43 00 00 	movl   $0x43ba,(%esp)
      d5:	e8 52 3d 00 00       	call   3e2c <open>
      da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
      dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
      e1:	78 21                	js     104 <writetest+0x59>
    printf(stdout, "creat small succeeded; ok\n");
      e3:	a1 10 61 00 00       	mov    0x6110,%eax
      e8:	c7 44 24 04 c0 43 00 	movl   $0x43c0,0x4(%esp)
      ef:	00 
      f0:	89 04 24             	mov    %eax,(%esp)
      f3:	e8 71 3e 00 00       	call   3f69 <printf>
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
      f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
      ff:	e9 a0 00 00 00       	jmp    1a4 <writetest+0xf9>
  printf(stdout, "small file test\n");
  fd = open("small", O_CREATE|O_RDWR);
  if(fd >= 0){
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
     104:	a1 10 61 00 00       	mov    0x6110,%eax
     109:	c7 44 24 04 db 43 00 	movl   $0x43db,0x4(%esp)
     110:	00 
     111:	89 04 24             	mov    %eax,(%esp)
     114:	e8 50 3e 00 00       	call   3f69 <printf>
    exit();
     119:	e8 be 3c 00 00       	call   3ddc <exit>
  }
  for(i = 0; i < 100; i++){
    if(write(fd, "aaaaaaaaaa", 10) != 10){
     11e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     125:	00 
     126:	c7 44 24 04 f7 43 00 	movl   $0x43f7,0x4(%esp)
     12d:	00 
     12e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     131:	89 04 24             	mov    %eax,(%esp)
     134:	e8 d3 3c 00 00       	call   3e0c <write>
     139:	83 f8 0a             	cmp    $0xa,%eax
     13c:	74 21                	je     15f <writetest+0xb4>
      printf(stdout, "error: write aa %d new file failed\n", i);
     13e:	a1 10 61 00 00       	mov    0x6110,%eax
     143:	8b 55 f4             	mov    -0xc(%ebp),%edx
     146:	89 54 24 08          	mov    %edx,0x8(%esp)
     14a:	c7 44 24 04 04 44 00 	movl   $0x4404,0x4(%esp)
     151:	00 
     152:	89 04 24             	mov    %eax,(%esp)
     155:	e8 0f 3e 00 00       	call   3f69 <printf>
      exit();
     15a:	e8 7d 3c 00 00       	call   3ddc <exit>
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
     15f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     166:	00 
     167:	c7 44 24 04 28 44 00 	movl   $0x4428,0x4(%esp)
     16e:	00 
     16f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     172:	89 04 24             	mov    %eax,(%esp)
     175:	e8 92 3c 00 00       	call   3e0c <write>
     17a:	83 f8 0a             	cmp    $0xa,%eax
     17d:	74 21                	je     1a0 <writetest+0xf5>
      printf(stdout, "error: write bb %d new file failed\n", i);
     17f:	a1 10 61 00 00       	mov    0x6110,%eax
     184:	8b 55 f4             	mov    -0xc(%ebp),%edx
     187:	89 54 24 08          	mov    %edx,0x8(%esp)
     18b:	c7 44 24 04 34 44 00 	movl   $0x4434,0x4(%esp)
     192:	00 
     193:	89 04 24             	mov    %eax,(%esp)
     196:	e8 ce 3d 00 00       	call   3f69 <printf>
      exit();
     19b:	e8 3c 3c 00 00       	call   3ddc <exit>
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     1a0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     1a4:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     1a8:	0f 8e 70 ff ff ff    	jle    11e <writetest+0x73>
    if(write(fd, "bbbbbbbbbb", 10) != 10){
      printf(stdout, "error: write bb %d new file failed\n", i);
      exit();
    }
  }
  printf(stdout, "writes ok\n");
     1ae:	a1 10 61 00 00       	mov    0x6110,%eax
     1b3:	c7 44 24 04 58 44 00 	movl   $0x4458,0x4(%esp)
     1ba:	00 
     1bb:	89 04 24             	mov    %eax,(%esp)
     1be:	e8 a6 3d 00 00       	call   3f69 <printf>
  close(fd);
     1c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
     1c6:	89 04 24             	mov    %eax,(%esp)
     1c9:	e8 46 3c 00 00       	call   3e14 <close>
  fd = open("small", O_RDONLY);
     1ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     1d5:	00 
     1d6:	c7 04 24 ba 43 00 00 	movl   $0x43ba,(%esp)
     1dd:	e8 4a 3c 00 00       	call   3e2c <open>
     1e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
     1e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     1e9:	78 3e                	js     229 <writetest+0x17e>
    printf(stdout, "open small succeeded ok\n");
     1eb:	a1 10 61 00 00       	mov    0x6110,%eax
     1f0:	c7 44 24 04 63 44 00 	movl   $0x4463,0x4(%esp)
     1f7:	00 
     1f8:	89 04 24             	mov    %eax,(%esp)
     1fb:	e8 69 3d 00 00       	call   3f69 <printf>
  } else {
    printf(stdout, "error: open small failed!\n");
    exit();
  }
  i = read(fd, buf, 2000);
     200:	c7 44 24 08 d0 07 00 	movl   $0x7d0,0x8(%esp)
     207:	00 
     208:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
     20f:	00 
     210:	8b 45 f0             	mov    -0x10(%ebp),%eax
     213:	89 04 24             	mov    %eax,(%esp)
     216:	e8 e9 3b 00 00       	call   3e04 <read>
     21b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(i == 2000){
     21e:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
     225:	74 1c                	je     243 <writetest+0x198>
     227:	eb 4c                	jmp    275 <writetest+0x1ca>
  close(fd);
  fd = open("small", O_RDONLY);
  if(fd >= 0){
    printf(stdout, "open small succeeded ok\n");
  } else {
    printf(stdout, "error: open small failed!\n");
     229:	a1 10 61 00 00       	mov    0x6110,%eax
     22e:	c7 44 24 04 7c 44 00 	movl   $0x447c,0x4(%esp)
     235:	00 
     236:	89 04 24             	mov    %eax,(%esp)
     239:	e8 2b 3d 00 00       	call   3f69 <printf>
    exit();
     23e:	e8 99 3b 00 00       	call   3ddc <exit>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
     243:	a1 10 61 00 00       	mov    0x6110,%eax
     248:	c7 44 24 04 97 44 00 	movl   $0x4497,0x4(%esp)
     24f:	00 
     250:	89 04 24             	mov    %eax,(%esp)
     253:	e8 11 3d 00 00       	call   3f69 <printf>
  } else {
    printf(stdout, "read failed\n");
    exit();
  }
  close(fd);
     258:	8b 45 f0             	mov    -0x10(%ebp),%eax
     25b:	89 04 24             	mov    %eax,(%esp)
     25e:	e8 b1 3b 00 00       	call   3e14 <close>

  if(unlink("small") < 0){
     263:	c7 04 24 ba 43 00 00 	movl   $0x43ba,(%esp)
     26a:	e8 cd 3b 00 00       	call   3e3c <unlink>
     26f:	85 c0                	test   %eax,%eax
     271:	78 1c                	js     28f <writetest+0x1e4>
     273:	eb 34                	jmp    2a9 <writetest+0x1fe>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
  } else {
    printf(stdout, "read failed\n");
     275:	a1 10 61 00 00       	mov    0x6110,%eax
     27a:	c7 44 24 04 aa 44 00 	movl   $0x44aa,0x4(%esp)
     281:	00 
     282:	89 04 24             	mov    %eax,(%esp)
     285:	e8 df 3c 00 00       	call   3f69 <printf>
    exit();
     28a:	e8 4d 3b 00 00       	call   3ddc <exit>
  }
  close(fd);

  if(unlink("small") < 0){
    printf(stdout, "unlink small failed\n");
     28f:	a1 10 61 00 00       	mov    0x6110,%eax
     294:	c7 44 24 04 b7 44 00 	movl   $0x44b7,0x4(%esp)
     29b:	00 
     29c:	89 04 24             	mov    %eax,(%esp)
     29f:	e8 c5 3c 00 00       	call   3f69 <printf>
    exit();
     2a4:	e8 33 3b 00 00       	call   3ddc <exit>
  }
  printf(stdout, "small file test ok\n");
     2a9:	a1 10 61 00 00       	mov    0x6110,%eax
     2ae:	c7 44 24 04 cc 44 00 	movl   $0x44cc,0x4(%esp)
     2b5:	00 
     2b6:	89 04 24             	mov    %eax,(%esp)
     2b9:	e8 ab 3c 00 00       	call   3f69 <printf>
}
     2be:	c9                   	leave  
     2bf:	c3                   	ret    

000002c0 <writetest1>:

void
writetest1(void)
{
     2c0:	55                   	push   %ebp
     2c1:	89 e5                	mov    %esp,%ebp
     2c3:	83 ec 28             	sub    $0x28,%esp
  int i, fd, n;

  printf(stdout, "big files test\n");
     2c6:	a1 10 61 00 00       	mov    0x6110,%eax
     2cb:	c7 44 24 04 e0 44 00 	movl   $0x44e0,0x4(%esp)
     2d2:	00 
     2d3:	89 04 24             	mov    %eax,(%esp)
     2d6:	e8 8e 3c 00 00       	call   3f69 <printf>

  fd = open("big", O_CREATE|O_RDWR);
     2db:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     2e2:	00 
     2e3:	c7 04 24 f0 44 00 00 	movl   $0x44f0,(%esp)
     2ea:	e8 3d 3b 00 00       	call   3e2c <open>
     2ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     2f2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     2f6:	79 1a                	jns    312 <writetest1+0x52>
    printf(stdout, "error: creat big failed!\n");
     2f8:	a1 10 61 00 00       	mov    0x6110,%eax
     2fd:	c7 44 24 04 f4 44 00 	movl   $0x44f4,0x4(%esp)
     304:	00 
     305:	89 04 24             	mov    %eax,(%esp)
     308:	e8 5c 3c 00 00       	call   3f69 <printf>
    exit();
     30d:	e8 ca 3a 00 00       	call   3ddc <exit>
  }

  for(i = 0; i < MAXFILE; i++){
     312:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     319:	eb 51                	jmp    36c <writetest1+0xac>
    ((int*)buf)[0] = i;
     31b:	b8 00 89 00 00       	mov    $0x8900,%eax
     320:	8b 55 f4             	mov    -0xc(%ebp),%edx
     323:	89 10                	mov    %edx,(%eax)
    if(write(fd, buf, 512) != 512){
     325:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     32c:	00 
     32d:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
     334:	00 
     335:	8b 45 ec             	mov    -0x14(%ebp),%eax
     338:	89 04 24             	mov    %eax,(%esp)
     33b:	e8 cc 3a 00 00       	call   3e0c <write>
     340:	3d 00 02 00 00       	cmp    $0x200,%eax
     345:	74 21                	je     368 <writetest1+0xa8>
      printf(stdout, "error: write big file failed\n", i);
     347:	a1 10 61 00 00       	mov    0x6110,%eax
     34c:	8b 55 f4             	mov    -0xc(%ebp),%edx
     34f:	89 54 24 08          	mov    %edx,0x8(%esp)
     353:	c7 44 24 04 0e 45 00 	movl   $0x450e,0x4(%esp)
     35a:	00 
     35b:	89 04 24             	mov    %eax,(%esp)
     35e:	e8 06 3c 00 00       	call   3f69 <printf>
      exit();
     363:	e8 74 3a 00 00       	call   3ddc <exit>
  if(fd < 0){
    printf(stdout, "error: creat big failed!\n");
    exit();
  }

  for(i = 0; i < MAXFILE; i++){
     368:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     36c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     36f:	3d 8b 00 00 00       	cmp    $0x8b,%eax
     374:	76 a5                	jbe    31b <writetest1+0x5b>
      printf(stdout, "error: write big file failed\n", i);
      exit();
    }
  }

  close(fd);
     376:	8b 45 ec             	mov    -0x14(%ebp),%eax
     379:	89 04 24             	mov    %eax,(%esp)
     37c:	e8 93 3a 00 00       	call   3e14 <close>

  fd = open("big", O_RDONLY);
     381:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     388:	00 
     389:	c7 04 24 f0 44 00 00 	movl   $0x44f0,(%esp)
     390:	e8 97 3a 00 00       	call   3e2c <open>
     395:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     398:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     39c:	79 1a                	jns    3b8 <writetest1+0xf8>
    printf(stdout, "error: open big failed!\n");
     39e:	a1 10 61 00 00       	mov    0x6110,%eax
     3a3:	c7 44 24 04 2c 45 00 	movl   $0x452c,0x4(%esp)
     3aa:	00 
     3ab:	89 04 24             	mov    %eax,(%esp)
     3ae:	e8 b6 3b 00 00       	call   3f69 <printf>
    exit();
     3b3:	e8 24 3a 00 00       	call   3ddc <exit>
  }

  n = 0;
     3b8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(;;){
    i = read(fd, buf, 512);
     3bf:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     3c6:	00 
     3c7:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
     3ce:	00 
     3cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
     3d2:	89 04 24             	mov    %eax,(%esp)
     3d5:	e8 2a 3a 00 00       	call   3e04 <read>
     3da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i == 0){
     3dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     3e1:	75 2e                	jne    411 <writetest1+0x151>
      if(n == MAXFILE - 1){
     3e3:	81 7d f0 8b 00 00 00 	cmpl   $0x8b,-0x10(%ebp)
     3ea:	0f 85 8c 00 00 00    	jne    47c <writetest1+0x1bc>
        printf(stdout, "read only %d blocks from big", n);
     3f0:	a1 10 61 00 00       	mov    0x6110,%eax
     3f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
     3f8:	89 54 24 08          	mov    %edx,0x8(%esp)
     3fc:	c7 44 24 04 45 45 00 	movl   $0x4545,0x4(%esp)
     403:	00 
     404:	89 04 24             	mov    %eax,(%esp)
     407:	e8 5d 3b 00 00       	call   3f69 <printf>
        exit();
     40c:	e8 cb 39 00 00       	call   3ddc <exit>
      }
      break;
    } else if(i != 512){
     411:	81 7d f4 00 02 00 00 	cmpl   $0x200,-0xc(%ebp)
     418:	74 21                	je     43b <writetest1+0x17b>
      printf(stdout, "read failed %d\n", i);
     41a:	a1 10 61 00 00       	mov    0x6110,%eax
     41f:	8b 55 f4             	mov    -0xc(%ebp),%edx
     422:	89 54 24 08          	mov    %edx,0x8(%esp)
     426:	c7 44 24 04 62 45 00 	movl   $0x4562,0x4(%esp)
     42d:	00 
     42e:	89 04 24             	mov    %eax,(%esp)
     431:	e8 33 3b 00 00       	call   3f69 <printf>
      exit();
     436:	e8 a1 39 00 00       	call   3ddc <exit>
    }
    if(((int*)buf)[0] != n){
     43b:	b8 00 89 00 00       	mov    $0x8900,%eax
     440:	8b 00                	mov    (%eax),%eax
     442:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     445:	74 2c                	je     473 <writetest1+0x1b3>
      printf(stdout, "read content of block %d is %d\n",
             n, ((int*)buf)[0]);
     447:	b8 00 89 00 00       	mov    $0x8900,%eax
    } else if(i != 512){
      printf(stdout, "read failed %d\n", i);
      exit();
    }
    if(((int*)buf)[0] != n){
      printf(stdout, "read content of block %d is %d\n",
     44c:	8b 10                	mov    (%eax),%edx
     44e:	a1 10 61 00 00       	mov    0x6110,%eax
     453:	89 54 24 0c          	mov    %edx,0xc(%esp)
     457:	8b 55 f0             	mov    -0x10(%ebp),%edx
     45a:	89 54 24 08          	mov    %edx,0x8(%esp)
     45e:	c7 44 24 04 74 45 00 	movl   $0x4574,0x4(%esp)
     465:	00 
     466:	89 04 24             	mov    %eax,(%esp)
     469:	e8 fb 3a 00 00       	call   3f69 <printf>
             n, ((int*)buf)[0]);
      exit();
     46e:	e8 69 39 00 00       	call   3ddc <exit>
    }
    n++;
     473:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  }
     477:	e9 43 ff ff ff       	jmp    3bf <writetest1+0xff>
    if(i == 0){
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
        exit();
      }
      break;
     47c:	90                   	nop
             n, ((int*)buf)[0]);
      exit();
    }
    n++;
  }
  close(fd);
     47d:	8b 45 ec             	mov    -0x14(%ebp),%eax
     480:	89 04 24             	mov    %eax,(%esp)
     483:	e8 8c 39 00 00       	call   3e14 <close>
  if(unlink("big") < 0){
     488:	c7 04 24 f0 44 00 00 	movl   $0x44f0,(%esp)
     48f:	e8 a8 39 00 00       	call   3e3c <unlink>
     494:	85 c0                	test   %eax,%eax
     496:	79 1a                	jns    4b2 <writetest1+0x1f2>
    printf(stdout, "unlink big failed\n");
     498:	a1 10 61 00 00       	mov    0x6110,%eax
     49d:	c7 44 24 04 94 45 00 	movl   $0x4594,0x4(%esp)
     4a4:	00 
     4a5:	89 04 24             	mov    %eax,(%esp)
     4a8:	e8 bc 3a 00 00       	call   3f69 <printf>
    exit();
     4ad:	e8 2a 39 00 00       	call   3ddc <exit>
  }
  printf(stdout, "big files ok\n");
     4b2:	a1 10 61 00 00       	mov    0x6110,%eax
     4b7:	c7 44 24 04 a7 45 00 	movl   $0x45a7,0x4(%esp)
     4be:	00 
     4bf:	89 04 24             	mov    %eax,(%esp)
     4c2:	e8 a2 3a 00 00       	call   3f69 <printf>
}
     4c7:	c9                   	leave  
     4c8:	c3                   	ret    

000004c9 <createtest>:

void
createtest(void)
{
     4c9:	55                   	push   %ebp
     4ca:	89 e5                	mov    %esp,%ebp
     4cc:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
     4cf:	a1 10 61 00 00       	mov    0x6110,%eax
     4d4:	c7 44 24 04 b8 45 00 	movl   $0x45b8,0x4(%esp)
     4db:	00 
     4dc:	89 04 24             	mov    %eax,(%esp)
     4df:	e8 85 3a 00 00       	call   3f69 <printf>

  name[0] = 'a';
     4e4:	c6 05 00 a9 00 00 61 	movb   $0x61,0xa900
  name[2] = '\0';
     4eb:	c6 05 02 a9 00 00 00 	movb   $0x0,0xa902
  for(i = 0; i < 52; i++){
     4f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     4f9:	eb 31                	jmp    52c <createtest+0x63>
    name[1] = '0' + i;
     4fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4fe:	83 c0 30             	add    $0x30,%eax
     501:	a2 01 a9 00 00       	mov    %al,0xa901
    fd = open(name, O_CREATE|O_RDWR);
     506:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     50d:	00 
     50e:	c7 04 24 00 a9 00 00 	movl   $0xa900,(%esp)
     515:	e8 12 39 00 00       	call   3e2c <open>
     51a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(fd);
     51d:	8b 45 f0             	mov    -0x10(%ebp),%eax
     520:	89 04 24             	mov    %eax,(%esp)
     523:	e8 ec 38 00 00       	call   3e14 <close>

  printf(stdout, "many creates, followed by unlink test\n");

  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     528:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     52c:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     530:	7e c9                	jle    4fb <createtest+0x32>
    name[1] = '0' + i;
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
     532:	c6 05 00 a9 00 00 61 	movb   $0x61,0xa900
  name[2] = '\0';
     539:	c6 05 02 a9 00 00 00 	movb   $0x0,0xa902
  for(i = 0; i < 52; i++){
     540:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     547:	eb 1b                	jmp    564 <createtest+0x9b>
    name[1] = '0' + i;
     549:	8b 45 f4             	mov    -0xc(%ebp),%eax
     54c:	83 c0 30             	add    $0x30,%eax
     54f:	a2 01 a9 00 00       	mov    %al,0xa901
    unlink(name);
     554:	c7 04 24 00 a9 00 00 	movl   $0xa900,(%esp)
     55b:	e8 dc 38 00 00       	call   3e3c <unlink>
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     560:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     564:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     568:	7e df                	jle    549 <createtest+0x80>
    name[1] = '0' + i;
    unlink(name);
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
     56a:	a1 10 61 00 00       	mov    0x6110,%eax
     56f:	c7 44 24 04 e0 45 00 	movl   $0x45e0,0x4(%esp)
     576:	00 
     577:	89 04 24             	mov    %eax,(%esp)
     57a:	e8 ea 39 00 00       	call   3f69 <printf>
}
     57f:	c9                   	leave  
     580:	c3                   	ret    

00000581 <dirtest>:

void dirtest(void)
{
     581:	55                   	push   %ebp
     582:	89 e5                	mov    %esp,%ebp
     584:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "mkdir test\n");
     587:	a1 10 61 00 00       	mov    0x6110,%eax
     58c:	c7 44 24 04 06 46 00 	movl   $0x4606,0x4(%esp)
     593:	00 
     594:	89 04 24             	mov    %eax,(%esp)
     597:	e8 cd 39 00 00       	call   3f69 <printf>

  if(mkdir("dir0") < 0){
     59c:	c7 04 24 12 46 00 00 	movl   $0x4612,(%esp)
     5a3:	e8 ac 38 00 00       	call   3e54 <mkdir>
     5a8:	85 c0                	test   %eax,%eax
     5aa:	79 1a                	jns    5c6 <dirtest+0x45>
    printf(stdout, "mkdir failed\n");
     5ac:	a1 10 61 00 00       	mov    0x6110,%eax
     5b1:	c7 44 24 04 17 46 00 	movl   $0x4617,0x4(%esp)
     5b8:	00 
     5b9:	89 04 24             	mov    %eax,(%esp)
     5bc:	e8 a8 39 00 00       	call   3f69 <printf>
    exit();
     5c1:	e8 16 38 00 00       	call   3ddc <exit>
  }

  if(chdir("dir0") < 0){
     5c6:	c7 04 24 12 46 00 00 	movl   $0x4612,(%esp)
     5cd:	e8 8a 38 00 00       	call   3e5c <chdir>
     5d2:	85 c0                	test   %eax,%eax
     5d4:	79 1a                	jns    5f0 <dirtest+0x6f>
    printf(stdout, "chdir dir0 failed\n");
     5d6:	a1 10 61 00 00       	mov    0x6110,%eax
     5db:	c7 44 24 04 25 46 00 	movl   $0x4625,0x4(%esp)
     5e2:	00 
     5e3:	89 04 24             	mov    %eax,(%esp)
     5e6:	e8 7e 39 00 00       	call   3f69 <printf>
    exit();
     5eb:	e8 ec 37 00 00       	call   3ddc <exit>
  }

  if(chdir("..") < 0){
     5f0:	c7 04 24 38 46 00 00 	movl   $0x4638,(%esp)
     5f7:	e8 60 38 00 00       	call   3e5c <chdir>
     5fc:	85 c0                	test   %eax,%eax
     5fe:	79 1a                	jns    61a <dirtest+0x99>
    printf(stdout, "chdir .. failed\n");
     600:	a1 10 61 00 00       	mov    0x6110,%eax
     605:	c7 44 24 04 3b 46 00 	movl   $0x463b,0x4(%esp)
     60c:	00 
     60d:	89 04 24             	mov    %eax,(%esp)
     610:	e8 54 39 00 00       	call   3f69 <printf>
    exit();
     615:	e8 c2 37 00 00       	call   3ddc <exit>
  }

  if(unlink("dir0") < 0){
     61a:	c7 04 24 12 46 00 00 	movl   $0x4612,(%esp)
     621:	e8 16 38 00 00       	call   3e3c <unlink>
     626:	85 c0                	test   %eax,%eax
     628:	79 1a                	jns    644 <dirtest+0xc3>
    printf(stdout, "unlink dir0 failed\n");
     62a:	a1 10 61 00 00       	mov    0x6110,%eax
     62f:	c7 44 24 04 4c 46 00 	movl   $0x464c,0x4(%esp)
     636:	00 
     637:	89 04 24             	mov    %eax,(%esp)
     63a:	e8 2a 39 00 00       	call   3f69 <printf>
    exit();
     63f:	e8 98 37 00 00       	call   3ddc <exit>
  }
  printf(stdout, "mkdir test\n");
     644:	a1 10 61 00 00       	mov    0x6110,%eax
     649:	c7 44 24 04 06 46 00 	movl   $0x4606,0x4(%esp)
     650:	00 
     651:	89 04 24             	mov    %eax,(%esp)
     654:	e8 10 39 00 00       	call   3f69 <printf>
}
     659:	c9                   	leave  
     65a:	c3                   	ret    

0000065b <exectest>:

void
exectest(void)
{
     65b:	55                   	push   %ebp
     65c:	89 e5                	mov    %esp,%ebp
     65e:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "exec test\n");
     661:	a1 10 61 00 00       	mov    0x6110,%eax
     666:	c7 44 24 04 60 46 00 	movl   $0x4660,0x4(%esp)
     66d:	00 
     66e:	89 04 24             	mov    %eax,(%esp)
     671:	e8 f3 38 00 00       	call   3f69 <printf>
  if(exec("echo", echoargv) < 0){
     676:	c7 44 24 04 fc 60 00 	movl   $0x60fc,0x4(%esp)
     67d:	00 
     67e:	c7 04 24 3c 43 00 00 	movl   $0x433c,(%esp)
     685:	e8 9a 37 00 00       	call   3e24 <exec>
     68a:	85 c0                	test   %eax,%eax
     68c:	79 1a                	jns    6a8 <exectest+0x4d>
    printf(stdout, "exec echo failed\n");
     68e:	a1 10 61 00 00       	mov    0x6110,%eax
     693:	c7 44 24 04 6b 46 00 	movl   $0x466b,0x4(%esp)
     69a:	00 
     69b:	89 04 24             	mov    %eax,(%esp)
     69e:	e8 c6 38 00 00       	call   3f69 <printf>
    exit();
     6a3:	e8 34 37 00 00       	call   3ddc <exit>
  }
}
     6a8:	c9                   	leave  
     6a9:	c3                   	ret    

000006aa <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
     6aa:	55                   	push   %ebp
     6ab:	89 e5                	mov    %esp,%ebp
     6ad:	83 ec 38             	sub    $0x38,%esp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
     6b0:	8d 45 d8             	lea    -0x28(%ebp),%eax
     6b3:	89 04 24             	mov    %eax,(%esp)
     6b6:	e8 41 37 00 00       	call   3dfc <pipe>
     6bb:	85 c0                	test   %eax,%eax
     6bd:	74 19                	je     6d8 <pipe1+0x2e>
    printf(1, "pipe() failed\n");
     6bf:	c7 44 24 04 7d 46 00 	movl   $0x467d,0x4(%esp)
     6c6:	00 
     6c7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     6ce:	e8 96 38 00 00       	call   3f69 <printf>
    exit();
     6d3:	e8 04 37 00 00       	call   3ddc <exit>
  }
  pid = fork();
     6d8:	e8 f7 36 00 00       	call   3dd4 <fork>
     6dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  seq = 0;
     6e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(pid == 0){
     6e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     6eb:	0f 85 86 00 00 00    	jne    777 <pipe1+0xcd>
    close(fds[0]);
     6f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
     6f4:	89 04 24             	mov    %eax,(%esp)
     6f7:	e8 18 37 00 00       	call   3e14 <close>
    for(n = 0; n < 5; n++){
     6fc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     703:	eb 67                	jmp    76c <pipe1+0xc2>
      for(i = 0; i < 1033; i++)
     705:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     70c:	eb 16                	jmp    724 <pipe1+0x7a>
        buf[i] = seq++;
     70e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     711:	8b 55 f0             	mov    -0x10(%ebp),%edx
     714:	81 c2 00 89 00 00    	add    $0x8900,%edx
     71a:	88 02                	mov    %al,(%edx)
     71c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
     720:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     724:	81 7d f0 08 04 00 00 	cmpl   $0x408,-0x10(%ebp)
     72b:	7e e1                	jle    70e <pipe1+0x64>
        buf[i] = seq++;
      if(write(fds[1], buf, 1033) != 1033){
     72d:	8b 45 dc             	mov    -0x24(%ebp),%eax
     730:	c7 44 24 08 09 04 00 	movl   $0x409,0x8(%esp)
     737:	00 
     738:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
     73f:	00 
     740:	89 04 24             	mov    %eax,(%esp)
     743:	e8 c4 36 00 00       	call   3e0c <write>
     748:	3d 09 04 00 00       	cmp    $0x409,%eax
     74d:	74 19                	je     768 <pipe1+0xbe>
        printf(1, "pipe1 oops 1\n");
     74f:	c7 44 24 04 8c 46 00 	movl   $0x468c,0x4(%esp)
     756:	00 
     757:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     75e:	e8 06 38 00 00       	call   3f69 <printf>
        exit();
     763:	e8 74 36 00 00       	call   3ddc <exit>
  }
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
     768:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
     76c:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
     770:	7e 93                	jle    705 <pipe1+0x5b>
      if(write(fds[1], buf, 1033) != 1033){
        printf(1, "pipe1 oops 1\n");
        exit();
      }
    }
    exit();
     772:	e8 65 36 00 00       	call   3ddc <exit>
  } else if(pid > 0){
     777:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     77b:	0f 8e fc 00 00 00    	jle    87d <pipe1+0x1d3>
    close(fds[1]);
     781:	8b 45 dc             	mov    -0x24(%ebp),%eax
     784:	89 04 24             	mov    %eax,(%esp)
     787:	e8 88 36 00 00       	call   3e14 <close>
    total = 0;
     78c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    cc = 1;
     793:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
    while((n = read(fds[0], buf, cc)) > 0){
     79a:	eb 6b                	jmp    807 <pipe1+0x15d>
      for(i = 0; i < n; i++){
     79c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     7a3:	eb 40                	jmp    7e5 <pipe1+0x13b>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     7a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
     7a8:	05 00 89 00 00       	add    $0x8900,%eax
     7ad:	0f b6 00             	movzbl (%eax),%eax
     7b0:	0f be c0             	movsbl %al,%eax
     7b3:	33 45 f4             	xor    -0xc(%ebp),%eax
     7b6:	25 ff 00 00 00       	and    $0xff,%eax
     7bb:	85 c0                	test   %eax,%eax
     7bd:	0f 95 c0             	setne  %al
     7c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     7c4:	84 c0                	test   %al,%al
     7c6:	74 19                	je     7e1 <pipe1+0x137>
          printf(1, "pipe1 oops 2\n");
     7c8:	c7 44 24 04 9a 46 00 	movl   $0x469a,0x4(%esp)
     7cf:	00 
     7d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     7d7:	e8 8d 37 00 00       	call   3f69 <printf>
     7dc:	e9 b5 00 00 00       	jmp    896 <pipe1+0x1ec>
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
     7e1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     7e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
     7e8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     7eb:	7c b8                	jl     7a5 <pipe1+0xfb>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
          printf(1, "pipe1 oops 2\n");
          return;
        }
      }
      total += n;
     7ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
     7f0:	01 45 e4             	add    %eax,-0x1c(%ebp)
      cc = cc * 2;
     7f3:	d1 65 e8             	shll   -0x18(%ebp)
      if(cc > sizeof(buf))
     7f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     7f9:	3d 00 20 00 00       	cmp    $0x2000,%eax
     7fe:	76 07                	jbe    807 <pipe1+0x15d>
        cc = sizeof(buf);
     800:	c7 45 e8 00 20 00 00 	movl   $0x2000,-0x18(%ebp)
    exit();
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
     807:	8b 45 d8             	mov    -0x28(%ebp),%eax
     80a:	8b 55 e8             	mov    -0x18(%ebp),%edx
     80d:	89 54 24 08          	mov    %edx,0x8(%esp)
     811:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
     818:	00 
     819:	89 04 24             	mov    %eax,(%esp)
     81c:	e8 e3 35 00 00       	call   3e04 <read>
     821:	89 45 ec             	mov    %eax,-0x14(%ebp)
     824:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     828:	0f 8f 6e ff ff ff    	jg     79c <pipe1+0xf2>
      total += n;
      cc = cc * 2;
      if(cc > sizeof(buf))
        cc = sizeof(buf);
    }
    if(total != 5 * 1033){
     82e:	81 7d e4 2d 14 00 00 	cmpl   $0x142d,-0x1c(%ebp)
     835:	74 20                	je     857 <pipe1+0x1ad>
      printf(1, "pipe1 oops 3 total %d\n", total);
     837:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     83a:	89 44 24 08          	mov    %eax,0x8(%esp)
     83e:	c7 44 24 04 a8 46 00 	movl   $0x46a8,0x4(%esp)
     845:	00 
     846:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     84d:	e8 17 37 00 00       	call   3f69 <printf>
      exit();
     852:	e8 85 35 00 00       	call   3ddc <exit>
    }
    close(fds[0]);
     857:	8b 45 d8             	mov    -0x28(%ebp),%eax
     85a:	89 04 24             	mov    %eax,(%esp)
     85d:	e8 b2 35 00 00       	call   3e14 <close>
    wait();
     862:	e8 7d 35 00 00       	call   3de4 <wait>
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
     867:	c7 44 24 04 bf 46 00 	movl   $0x46bf,0x4(%esp)
     86e:	00 
     86f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     876:	e8 ee 36 00 00       	call   3f69 <printf>
     87b:	eb 19                	jmp    896 <pipe1+0x1ec>
      exit();
    }
    close(fds[0]);
    wait();
  } else {
    printf(1, "fork() failed\n");
     87d:	c7 44 24 04 c9 46 00 	movl   $0x46c9,0x4(%esp)
     884:	00 
     885:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     88c:	e8 d8 36 00 00       	call   3f69 <printf>
    exit();
     891:	e8 46 35 00 00       	call   3ddc <exit>
  }
  printf(1, "pipe1 ok\n");
}
     896:	c9                   	leave  
     897:	c3                   	ret    

00000898 <preempt>:

// meant to be run w/ at most two CPUs
void
preempt(void)
{
     898:	55                   	push   %ebp
     899:	89 e5                	mov    %esp,%ebp
     89b:	83 ec 38             	sub    $0x38,%esp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
     89e:	c7 44 24 04 d8 46 00 	movl   $0x46d8,0x4(%esp)
     8a5:	00 
     8a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     8ad:	e8 b7 36 00 00       	call   3f69 <printf>
  pid1 = fork();
     8b2:	e8 1d 35 00 00       	call   3dd4 <fork>
     8b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid1 == 0)
     8ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     8be:	75 02                	jne    8c2 <preempt+0x2a>
    for(;;)
      ;
     8c0:	eb fe                	jmp    8c0 <preempt+0x28>

  pid2 = fork();
     8c2:	e8 0d 35 00 00       	call   3dd4 <fork>
     8c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid2 == 0)
     8ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     8ce:	75 02                	jne    8d2 <preempt+0x3a>
    for(;;)
      ;
     8d0:	eb fe                	jmp    8d0 <preempt+0x38>

  pipe(pfds);
     8d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     8d5:	89 04 24             	mov    %eax,(%esp)
     8d8:	e8 1f 35 00 00       	call   3dfc <pipe>
  pid3 = fork();
     8dd:	e8 f2 34 00 00       	call   3dd4 <fork>
     8e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid3 == 0){
     8e5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     8e9:	75 4c                	jne    937 <preempt+0x9f>
    close(pfds[0]);
     8eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     8ee:	89 04 24             	mov    %eax,(%esp)
     8f1:	e8 1e 35 00 00       	call   3e14 <close>
    if(write(pfds[1], "x", 1) != 1)
     8f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     8f9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     900:	00 
     901:	c7 44 24 04 e2 46 00 	movl   $0x46e2,0x4(%esp)
     908:	00 
     909:	89 04 24             	mov    %eax,(%esp)
     90c:	e8 fb 34 00 00       	call   3e0c <write>
     911:	83 f8 01             	cmp    $0x1,%eax
     914:	74 14                	je     92a <preempt+0x92>
      printf(1, "preempt write error");
     916:	c7 44 24 04 e4 46 00 	movl   $0x46e4,0x4(%esp)
     91d:	00 
     91e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     925:	e8 3f 36 00 00       	call   3f69 <printf>
    close(pfds[1]);
     92a:	8b 45 e8             	mov    -0x18(%ebp),%eax
     92d:	89 04 24             	mov    %eax,(%esp)
     930:	e8 df 34 00 00       	call   3e14 <close>
    for(;;)
      ;
     935:	eb fe                	jmp    935 <preempt+0x9d>
  }

  close(pfds[1]);
     937:	8b 45 e8             	mov    -0x18(%ebp),%eax
     93a:	89 04 24             	mov    %eax,(%esp)
     93d:	e8 d2 34 00 00       	call   3e14 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     942:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     945:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
     94c:	00 
     94d:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
     954:	00 
     955:	89 04 24             	mov    %eax,(%esp)
     958:	e8 a7 34 00 00       	call   3e04 <read>
     95d:	83 f8 01             	cmp    $0x1,%eax
     960:	74 16                	je     978 <preempt+0xe0>
    printf(1, "preempt read error");
     962:	c7 44 24 04 f8 46 00 	movl   $0x46f8,0x4(%esp)
     969:	00 
     96a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     971:	e8 f3 35 00 00       	call   3f69 <printf>
     976:	eb 77                	jmp    9ef <preempt+0x157>
    return;
  }
  close(pfds[0]);
     978:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     97b:	89 04 24             	mov    %eax,(%esp)
     97e:	e8 91 34 00 00       	call   3e14 <close>
  printf(1, "kill... ");
     983:	c7 44 24 04 0b 47 00 	movl   $0x470b,0x4(%esp)
     98a:	00 
     98b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     992:	e8 d2 35 00 00       	call   3f69 <printf>
  kill(pid1);
     997:	8b 45 f4             	mov    -0xc(%ebp),%eax
     99a:	89 04 24             	mov    %eax,(%esp)
     99d:	e8 7a 34 00 00       	call   3e1c <kill>
  kill(pid2);
     9a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
     9a5:	89 04 24             	mov    %eax,(%esp)
     9a8:	e8 6f 34 00 00       	call   3e1c <kill>
  kill(pid3);
     9ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
     9b0:	89 04 24             	mov    %eax,(%esp)
     9b3:	e8 64 34 00 00       	call   3e1c <kill>
  printf(1, "wait... ");
     9b8:	c7 44 24 04 14 47 00 	movl   $0x4714,0x4(%esp)
     9bf:	00 
     9c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     9c7:	e8 9d 35 00 00       	call   3f69 <printf>
  wait();
     9cc:	e8 13 34 00 00       	call   3de4 <wait>
  wait();
     9d1:	e8 0e 34 00 00       	call   3de4 <wait>
  wait();
     9d6:	e8 09 34 00 00       	call   3de4 <wait>
  printf(1, "preempt ok\n");
     9db:	c7 44 24 04 1d 47 00 	movl   $0x471d,0x4(%esp)
     9e2:	00 
     9e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     9ea:	e8 7a 35 00 00       	call   3f69 <printf>
}
     9ef:	c9                   	leave  
     9f0:	c3                   	ret    

000009f1 <exitwait>:

// try to find any races between exit and wait
void
exitwait(void)
{
     9f1:	55                   	push   %ebp
     9f2:	89 e5                	mov    %esp,%ebp
     9f4:	83 ec 28             	sub    $0x28,%esp
  int i, pid;

  for(i = 0; i < 100; i++){
     9f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     9fe:	eb 53                	jmp    a53 <exitwait+0x62>
    pid = fork();
     a00:	e8 cf 33 00 00       	call   3dd4 <fork>
     a05:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0){
     a08:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     a0c:	79 16                	jns    a24 <exitwait+0x33>
      printf(1, "fork failed\n");
     a0e:	c7 44 24 04 29 47 00 	movl   $0x4729,0x4(%esp)
     a15:	00 
     a16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a1d:	e8 47 35 00 00       	call   3f69 <printf>
      return;
     a22:	eb 49                	jmp    a6d <exitwait+0x7c>
    }
    if(pid){
     a24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     a28:	74 20                	je     a4a <exitwait+0x59>
      if(wait() != pid){
     a2a:	e8 b5 33 00 00       	call   3de4 <wait>
     a2f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     a32:	74 1b                	je     a4f <exitwait+0x5e>
        printf(1, "wait wrong pid\n");
     a34:	c7 44 24 04 36 47 00 	movl   $0x4736,0x4(%esp)
     a3b:	00 
     a3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a43:	e8 21 35 00 00       	call   3f69 <printf>
        return;
     a48:	eb 23                	jmp    a6d <exitwait+0x7c>
      }
    } else {
      exit();
     a4a:	e8 8d 33 00 00       	call   3ddc <exit>
void
exitwait(void)
{
  int i, pid;

  for(i = 0; i < 100; i++){
     a4f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     a53:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     a57:	7e a7                	jle    a00 <exitwait+0xf>
      }
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
     a59:	c7 44 24 04 46 47 00 	movl   $0x4746,0x4(%esp)
     a60:	00 
     a61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a68:	e8 fc 34 00 00       	call   3f69 <printf>
}
     a6d:	c9                   	leave  
     a6e:	c3                   	ret    

00000a6f <mem>:

void
mem(void)
{
     a6f:	55                   	push   %ebp
     a70:	89 e5                	mov    %esp,%ebp
     a72:	83 ec 28             	sub    $0x28,%esp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
     a75:	c7 44 24 04 53 47 00 	movl   $0x4753,0x4(%esp)
     a7c:	00 
     a7d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a84:	e8 e0 34 00 00       	call   3f69 <printf>
  ppid = getpid();
     a89:	e8 de 33 00 00       	call   3e6c <getpid>
     a8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if((pid = fork()) == 0){
     a91:	e8 3e 33 00 00       	call   3dd4 <fork>
     a96:	89 45 ec             	mov    %eax,-0x14(%ebp)
     a99:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     a9d:	0f 85 aa 00 00 00    	jne    b4d <mem+0xde>
    m1 = 0;
     aa3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while((m2 = malloc(10001)) != 0){
     aaa:	eb 0e                	jmp    aba <mem+0x4b>
      *(char**)m2 = m1;
     aac:	8b 45 e8             	mov    -0x18(%ebp),%eax
     aaf:	8b 55 f4             	mov    -0xc(%ebp),%edx
     ab2:	89 10                	mov    %edx,(%eax)
      m1 = m2;
     ab4:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  printf(1, "mem test\n");
  ppid = getpid();
  if((pid = fork()) == 0){
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
     aba:	c7 04 24 11 27 00 00 	movl   $0x2711,(%esp)
     ac1:	e8 93 37 00 00       	call   4259 <malloc>
     ac6:	89 45 e8             	mov    %eax,-0x18(%ebp)
     ac9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     acd:	75 dd                	jne    aac <mem+0x3d>
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     acf:	eb 19                	jmp    aea <mem+0x7b>
      m2 = *(char**)m1;
     ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     ad4:	8b 00                	mov    (%eax),%eax
     ad6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      free(m1);
     ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
     adc:	89 04 24             	mov    %eax,(%esp)
     adf:	e8 3c 36 00 00       	call   4120 <free>
      m1 = m2;
     ae4:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ae7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     aea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     aee:	75 e1                	jne    ad1 <mem+0x62>
      m2 = *(char**)m1;
      free(m1);
      m1 = m2;
    }
    m1 = malloc(1024*20);
     af0:	c7 04 24 00 50 00 00 	movl   $0x5000,(%esp)
     af7:	e8 5d 37 00 00       	call   4259 <malloc>
     afc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(m1 == 0){
     aff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     b03:	75 24                	jne    b29 <mem+0xba>
      printf(1, "couldn't allocate mem?!!\n");
     b05:	c7 44 24 04 5d 47 00 	movl   $0x475d,0x4(%esp)
     b0c:	00 
     b0d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b14:	e8 50 34 00 00       	call   3f69 <printf>
      kill(ppid);
     b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b1c:	89 04 24             	mov    %eax,(%esp)
     b1f:	e8 f8 32 00 00       	call   3e1c <kill>
      exit();
     b24:	e8 b3 32 00 00       	call   3ddc <exit>
    }
    free(m1);
     b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
     b2c:	89 04 24             	mov    %eax,(%esp)
     b2f:	e8 ec 35 00 00       	call   4120 <free>
    printf(1, "mem ok\n");
     b34:	c7 44 24 04 77 47 00 	movl   $0x4777,0x4(%esp)
     b3b:	00 
     b3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b43:	e8 21 34 00 00       	call   3f69 <printf>
    exit();
     b48:	e8 8f 32 00 00       	call   3ddc <exit>
  } else {
    wait();
     b4d:	e8 92 32 00 00       	call   3de4 <wait>
  }
}
     b52:	c9                   	leave  
     b53:	c3                   	ret    

00000b54 <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
     b54:	55                   	push   %ebp
     b55:	89 e5                	mov    %esp,%ebp
     b57:	83 ec 48             	sub    $0x48,%esp
  int fd, pid, i, n, nc, np;
  char buf[10];

  printf(1, "sharedfd test\n");
     b5a:	c7 44 24 04 7f 47 00 	movl   $0x477f,0x4(%esp)
     b61:	00 
     b62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b69:	e8 fb 33 00 00       	call   3f69 <printf>

  unlink("sharedfd");
     b6e:	c7 04 24 8e 47 00 00 	movl   $0x478e,(%esp)
     b75:	e8 c2 32 00 00       	call   3e3c <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
     b7a:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     b81:	00 
     b82:	c7 04 24 8e 47 00 00 	movl   $0x478e,(%esp)
     b89:	e8 9e 32 00 00       	call   3e2c <open>
     b8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
     b91:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     b95:	79 19                	jns    bb0 <sharedfd+0x5c>
    printf(1, "fstests: cannot open sharedfd for writing");
     b97:	c7 44 24 04 98 47 00 	movl   $0x4798,0x4(%esp)
     b9e:	00 
     b9f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ba6:	e8 be 33 00 00       	call   3f69 <printf>
     bab:	e9 a0 01 00 00       	jmp    d50 <sharedfd+0x1fc>
    return;
  }
  pid = fork();
     bb0:	e8 1f 32 00 00       	call   3dd4 <fork>
     bb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  memset(buf, pid==0?'c':'p', sizeof(buf));
     bb8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     bbc:	75 07                	jne    bc5 <sharedfd+0x71>
     bbe:	b8 63 00 00 00       	mov    $0x63,%eax
     bc3:	eb 05                	jmp    bca <sharedfd+0x76>
     bc5:	b8 70 00 00 00       	mov    $0x70,%eax
     bca:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     bd1:	00 
     bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
     bd6:	8d 45 d6             	lea    -0x2a(%ebp),%eax
     bd9:	89 04 24             	mov    %eax,(%esp)
     bdc:	e8 b4 2e 00 00       	call   3a95 <memset>
  for(i = 0; i < 1000; i++){
     be1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     be8:	eb 39                	jmp    c23 <sharedfd+0xcf>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
     bea:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     bf1:	00 
     bf2:	8d 45 d6             	lea    -0x2a(%ebp),%eax
     bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
     bf9:	8b 45 e8             	mov    -0x18(%ebp),%eax
     bfc:	89 04 24             	mov    %eax,(%esp)
     bff:	e8 08 32 00 00       	call   3e0c <write>
     c04:	83 f8 0a             	cmp    $0xa,%eax
     c07:	74 16                	je     c1f <sharedfd+0xcb>
      printf(1, "fstests: write sharedfd failed\n");
     c09:	c7 44 24 04 c4 47 00 	movl   $0x47c4,0x4(%esp)
     c10:	00 
     c11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c18:	e8 4c 33 00 00       	call   3f69 <printf>
      break;
     c1d:	eb 0d                	jmp    c2c <sharedfd+0xd8>
    printf(1, "fstests: cannot open sharedfd for writing");
    return;
  }
  pid = fork();
  memset(buf, pid==0?'c':'p', sizeof(buf));
  for(i = 0; i < 1000; i++){
     c1f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     c23:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
     c2a:	7e be                	jle    bea <sharedfd+0x96>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
      printf(1, "fstests: write sharedfd failed\n");
      break;
    }
  }
  if(pid == 0)
     c2c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     c30:	75 05                	jne    c37 <sharedfd+0xe3>
    exit();
     c32:	e8 a5 31 00 00       	call   3ddc <exit>
  else
    wait();
     c37:	e8 a8 31 00 00       	call   3de4 <wait>
  close(fd);
     c3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c3f:	89 04 24             	mov    %eax,(%esp)
     c42:	e8 cd 31 00 00       	call   3e14 <close>
  fd = open("sharedfd", 0);
     c47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     c4e:	00 
     c4f:	c7 04 24 8e 47 00 00 	movl   $0x478e,(%esp)
     c56:	e8 d1 31 00 00       	call   3e2c <open>
     c5b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
     c5e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     c62:	79 19                	jns    c7d <sharedfd+0x129>
    printf(1, "fstests: cannot open sharedfd for reading\n");
     c64:	c7 44 24 04 e4 47 00 	movl   $0x47e4,0x4(%esp)
     c6b:	00 
     c6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c73:	e8 f1 32 00 00       	call   3f69 <printf>
     c78:	e9 d3 00 00 00       	jmp    d50 <sharedfd+0x1fc>
    return;
  }
  nc = np = 0;
     c7d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     c84:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c87:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
     c8a:	eb 3b                	jmp    cc7 <sharedfd+0x173>
    for(i = 0; i < sizeof(buf); i++){
     c8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     c93:	eb 2a                	jmp    cbf <sharedfd+0x16b>
      if(buf[i] == 'c')
     c95:	8d 55 d6             	lea    -0x2a(%ebp),%edx
     c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c9b:	01 d0                	add    %edx,%eax
     c9d:	0f b6 00             	movzbl (%eax),%eax
     ca0:	3c 63                	cmp    $0x63,%al
     ca2:	75 04                	jne    ca8 <sharedfd+0x154>
        nc++;
     ca4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(buf[i] == 'p')
     ca8:	8d 55 d6             	lea    -0x2a(%ebp),%edx
     cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
     cae:	01 d0                	add    %edx,%eax
     cb0:	0f b6 00             	movzbl (%eax),%eax
     cb3:	3c 70                	cmp    $0x70,%al
     cb5:	75 04                	jne    cbb <sharedfd+0x167>
        np++;
     cb7:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i = 0; i < sizeof(buf); i++){
     cbb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
     cc2:	83 f8 09             	cmp    $0x9,%eax
     cc5:	76 ce                	jbe    c95 <sharedfd+0x141>
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
     cc7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     cce:	00 
     ccf:	8d 45 d6             	lea    -0x2a(%ebp),%eax
     cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
     cd6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     cd9:	89 04 24             	mov    %eax,(%esp)
     cdc:	e8 23 31 00 00       	call   3e04 <read>
     ce1:	89 45 e0             	mov    %eax,-0x20(%ebp)
     ce4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     ce8:	7f a2                	jg     c8c <sharedfd+0x138>
        nc++;
      if(buf[i] == 'p')
        np++;
    }
  }
  close(fd);
     cea:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ced:	89 04 24             	mov    %eax,(%esp)
     cf0:	e8 1f 31 00 00       	call   3e14 <close>
  unlink("sharedfd");
     cf5:	c7 04 24 8e 47 00 00 	movl   $0x478e,(%esp)
     cfc:	e8 3b 31 00 00       	call   3e3c <unlink>
  if(nc == 10000 && np == 10000){
     d01:	81 7d f0 10 27 00 00 	cmpl   $0x2710,-0x10(%ebp)
     d08:	75 1f                	jne    d29 <sharedfd+0x1d5>
     d0a:	81 7d ec 10 27 00 00 	cmpl   $0x2710,-0x14(%ebp)
     d11:	75 16                	jne    d29 <sharedfd+0x1d5>
    printf(1, "sharedfd ok\n");
     d13:	c7 44 24 04 0f 48 00 	movl   $0x480f,0x4(%esp)
     d1a:	00 
     d1b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d22:	e8 42 32 00 00       	call   3f69 <printf>
     d27:	eb 27                	jmp    d50 <sharedfd+0x1fc>
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
     d29:	8b 45 ec             	mov    -0x14(%ebp),%eax
     d2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
     d30:	8b 45 f0             	mov    -0x10(%ebp),%eax
     d33:	89 44 24 08          	mov    %eax,0x8(%esp)
     d37:	c7 44 24 04 1c 48 00 	movl   $0x481c,0x4(%esp)
     d3e:	00 
     d3f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d46:	e8 1e 32 00 00       	call   3f69 <printf>
    exit();
     d4b:	e8 8c 30 00 00       	call   3ddc <exit>
  }
}
     d50:	c9                   	leave  
     d51:	c3                   	ret    

00000d52 <twofiles>:

// two processes write two different files at the same
// time, to test block allocation.
void
twofiles(void)
{
     d52:	55                   	push   %ebp
     d53:	89 e5                	mov    %esp,%ebp
     d55:	83 ec 38             	sub    $0x38,%esp
  int fd, pid, i, j, n, total;
  char *fname;

  printf(1, "twofiles test\n");
     d58:	c7 44 24 04 31 48 00 	movl   $0x4831,0x4(%esp)
     d5f:	00 
     d60:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d67:	e8 fd 31 00 00       	call   3f69 <printf>

  unlink("f1");
     d6c:	c7 04 24 40 48 00 00 	movl   $0x4840,(%esp)
     d73:	e8 c4 30 00 00       	call   3e3c <unlink>
  unlink("f2");
     d78:	c7 04 24 43 48 00 00 	movl   $0x4843,(%esp)
     d7f:	e8 b8 30 00 00       	call   3e3c <unlink>

  pid = fork();
     d84:	e8 4b 30 00 00       	call   3dd4 <fork>
     d89:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(pid < 0){
     d8c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     d90:	79 19                	jns    dab <twofiles+0x59>
    printf(1, "fork failed\n");
     d92:	c7 44 24 04 29 47 00 	movl   $0x4729,0x4(%esp)
     d99:	00 
     d9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     da1:	e8 c3 31 00 00       	call   3f69 <printf>
    exit();
     da6:	e8 31 30 00 00       	call   3ddc <exit>
  }

  fname = pid ? "f1" : "f2";
     dab:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     daf:	74 07                	je     db8 <twofiles+0x66>
     db1:	b8 40 48 00 00       	mov    $0x4840,%eax
     db6:	eb 05                	jmp    dbd <twofiles+0x6b>
     db8:	b8 43 48 00 00       	mov    $0x4843,%eax
     dbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  fd = open(fname, O_CREATE | O_RDWR);
     dc0:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     dc7:	00 
     dc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     dcb:	89 04 24             	mov    %eax,(%esp)
     dce:	e8 59 30 00 00       	call   3e2c <open>
     dd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(fd < 0){
     dd6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     dda:	79 19                	jns    df5 <twofiles+0xa3>
    printf(1, "create failed\n");
     ddc:	c7 44 24 04 46 48 00 	movl   $0x4846,0x4(%esp)
     de3:	00 
     de4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     deb:	e8 79 31 00 00       	call   3f69 <printf>
    exit();
     df0:	e8 e7 2f 00 00       	call   3ddc <exit>
  }

  memset(buf, pid?'p':'c', 512);
     df5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     df9:	74 07                	je     e02 <twofiles+0xb0>
     dfb:	b8 70 00 00 00       	mov    $0x70,%eax
     e00:	eb 05                	jmp    e07 <twofiles+0xb5>
     e02:	b8 63 00 00 00       	mov    $0x63,%eax
     e07:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     e0e:	00 
     e0f:	89 44 24 04          	mov    %eax,0x4(%esp)
     e13:	c7 04 24 00 89 00 00 	movl   $0x8900,(%esp)
     e1a:	e8 76 2c 00 00       	call   3a95 <memset>
  for(i = 0; i < 12; i++){
     e1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     e26:	eb 4b                	jmp    e73 <twofiles+0x121>
    if((n = write(fd, buf, 500)) != 500){
     e28:	c7 44 24 08 f4 01 00 	movl   $0x1f4,0x8(%esp)
     e2f:	00 
     e30:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
     e37:	00 
     e38:	8b 45 e0             	mov    -0x20(%ebp),%eax
     e3b:	89 04 24             	mov    %eax,(%esp)
     e3e:	e8 c9 2f 00 00       	call   3e0c <write>
     e43:	89 45 dc             	mov    %eax,-0x24(%ebp)
     e46:	81 7d dc f4 01 00 00 	cmpl   $0x1f4,-0x24(%ebp)
     e4d:	74 20                	je     e6f <twofiles+0x11d>
      printf(1, "write failed %d\n", n);
     e4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
     e52:	89 44 24 08          	mov    %eax,0x8(%esp)
     e56:	c7 44 24 04 55 48 00 	movl   $0x4855,0x4(%esp)
     e5d:	00 
     e5e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e65:	e8 ff 30 00 00       	call   3f69 <printf>
      exit();
     e6a:	e8 6d 2f 00 00       	call   3ddc <exit>
    printf(1, "create failed\n");
    exit();
  }

  memset(buf, pid?'p':'c', 512);
  for(i = 0; i < 12; i++){
     e6f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     e73:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
     e77:	7e af                	jle    e28 <twofiles+0xd6>
    if((n = write(fd, buf, 500)) != 500){
      printf(1, "write failed %d\n", n);
      exit();
    }
  }
  close(fd);
     e79:	8b 45 e0             	mov    -0x20(%ebp),%eax
     e7c:	89 04 24             	mov    %eax,(%esp)
     e7f:	e8 90 2f 00 00       	call   3e14 <close>
  if(pid)
     e84:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     e88:	74 11                	je     e9b <twofiles+0x149>
    wait();
     e8a:	e8 55 2f 00 00       	call   3de4 <wait>
  else
    exit();

  for(i = 0; i < 2; i++){
     e8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     e96:	e9 e7 00 00 00       	jmp    f82 <twofiles+0x230>
  }
  close(fd);
  if(pid)
    wait();
  else
    exit();
     e9b:	e8 3c 2f 00 00       	call   3ddc <exit>

  for(i = 0; i < 2; i++){
    fd = open(i?"f1":"f2", 0);
     ea0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ea4:	74 07                	je     ead <twofiles+0x15b>
     ea6:	b8 40 48 00 00       	mov    $0x4840,%eax
     eab:	eb 05                	jmp    eb2 <twofiles+0x160>
     ead:	b8 43 48 00 00       	mov    $0x4843,%eax
     eb2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     eb9:	00 
     eba:	89 04 24             	mov    %eax,(%esp)
     ebd:	e8 6a 2f 00 00       	call   3e2c <open>
     ec2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    total = 0;
     ec5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while((n = read(fd, buf, sizeof(buf))) > 0){
     ecc:	eb 58                	jmp    f26 <twofiles+0x1d4>
      for(j = 0; j < n; j++){
     ece:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     ed5:	eb 41                	jmp    f18 <twofiles+0x1c6>
        if(buf[j] != (i?'p':'c')){
     ed7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     eda:	05 00 89 00 00       	add    $0x8900,%eax
     edf:	0f b6 00             	movzbl (%eax),%eax
     ee2:	0f be d0             	movsbl %al,%edx
     ee5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     ee9:	74 07                	je     ef2 <twofiles+0x1a0>
     eeb:	b8 70 00 00 00       	mov    $0x70,%eax
     ef0:	eb 05                	jmp    ef7 <twofiles+0x1a5>
     ef2:	b8 63 00 00 00       	mov    $0x63,%eax
     ef7:	39 c2                	cmp    %eax,%edx
     ef9:	74 19                	je     f14 <twofiles+0x1c2>
          printf(1, "wrong char\n");
     efb:	c7 44 24 04 66 48 00 	movl   $0x4866,0x4(%esp)
     f02:	00 
     f03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f0a:	e8 5a 30 00 00       	call   3f69 <printf>
          exit();
     f0f:	e8 c8 2e 00 00       	call   3ddc <exit>

  for(i = 0; i < 2; i++){
    fd = open(i?"f1":"f2", 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
     f14:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
     f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
     f1b:	3b 45 dc             	cmp    -0x24(%ebp),%eax
     f1e:	7c b7                	jl     ed7 <twofiles+0x185>
        if(buf[j] != (i?'p':'c')){
          printf(1, "wrong char\n");
          exit();
        }
      }
      total += n;
     f20:	8b 45 dc             	mov    -0x24(%ebp),%eax
     f23:	01 45 ec             	add    %eax,-0x14(%ebp)
    exit();

  for(i = 0; i < 2; i++){
    fd = open(i?"f1":"f2", 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
     f26:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
     f2d:	00 
     f2e:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
     f35:	00 
     f36:	8b 45 e0             	mov    -0x20(%ebp),%eax
     f39:	89 04 24             	mov    %eax,(%esp)
     f3c:	e8 c3 2e 00 00       	call   3e04 <read>
     f41:	89 45 dc             	mov    %eax,-0x24(%ebp)
     f44:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
     f48:	7f 84                	jg     ece <twofiles+0x17c>
          exit();
        }
      }
      total += n;
    }
    close(fd);
     f4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
     f4d:	89 04 24             	mov    %eax,(%esp)
     f50:	e8 bf 2e 00 00       	call   3e14 <close>
    if(total != 12*500){
     f55:	81 7d ec 70 17 00 00 	cmpl   $0x1770,-0x14(%ebp)
     f5c:	74 20                	je     f7e <twofiles+0x22c>
      printf(1, "wrong length %d\n", total);
     f5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     f61:	89 44 24 08          	mov    %eax,0x8(%esp)
     f65:	c7 44 24 04 72 48 00 	movl   $0x4872,0x4(%esp)
     f6c:	00 
     f6d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f74:	e8 f0 2f 00 00       	call   3f69 <printf>
      exit();
     f79:	e8 5e 2e 00 00       	call   3ddc <exit>
  if(pid)
    wait();
  else
    exit();

  for(i = 0; i < 2; i++){
     f7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
     f82:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
     f86:	0f 8e 14 ff ff ff    	jle    ea0 <twofiles+0x14e>
      printf(1, "wrong length %d\n", total);
      exit();
    }
  }

  unlink("f1");
     f8c:	c7 04 24 40 48 00 00 	movl   $0x4840,(%esp)
     f93:	e8 a4 2e 00 00       	call   3e3c <unlink>
  unlink("f2");
     f98:	c7 04 24 43 48 00 00 	movl   $0x4843,(%esp)
     f9f:	e8 98 2e 00 00       	call   3e3c <unlink>

  printf(1, "twofiles ok\n");
     fa4:	c7 44 24 04 83 48 00 	movl   $0x4883,0x4(%esp)
     fab:	00 
     fac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     fb3:	e8 b1 2f 00 00       	call   3f69 <printf>
}
     fb8:	c9                   	leave  
     fb9:	c3                   	ret    

00000fba <createdelete>:

// two processes create and delete different files in same directory
void
createdelete(void)
{
     fba:	55                   	push   %ebp
     fbb:	89 e5                	mov    %esp,%ebp
     fbd:	83 ec 48             	sub    $0x48,%esp
  enum { N = 20 };
  int pid, i, fd;
  char name[32];

  printf(1, "createdelete test\n");
     fc0:	c7 44 24 04 90 48 00 	movl   $0x4890,0x4(%esp)
     fc7:	00 
     fc8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     fcf:	e8 95 2f 00 00       	call   3f69 <printf>
  pid = fork();
     fd4:	e8 fb 2d 00 00       	call   3dd4 <fork>
     fd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid < 0){
     fdc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     fe0:	79 19                	jns    ffb <createdelete+0x41>
    printf(1, "fork failed\n");
     fe2:	c7 44 24 04 29 47 00 	movl   $0x4729,0x4(%esp)
     fe9:	00 
     fea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ff1:	e8 73 2f 00 00       	call   3f69 <printf>
    exit();
     ff6:	e8 e1 2d 00 00       	call   3ddc <exit>
  }

  name[0] = pid ? 'p' : 'c';
     ffb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     fff:	74 07                	je     1008 <createdelete+0x4e>
    1001:	b8 70 00 00 00       	mov    $0x70,%eax
    1006:	eb 05                	jmp    100d <createdelete+0x53>
    1008:	b8 63 00 00 00       	mov    $0x63,%eax
    100d:	88 45 cc             	mov    %al,-0x34(%ebp)
  name[2] = '\0';
    1010:	c6 45 ce 00          	movb   $0x0,-0x32(%ebp)
  for(i = 0; i < N; i++){
    1014:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    101b:	e9 97 00 00 00       	jmp    10b7 <createdelete+0xfd>
    name[1] = '0' + i;
    1020:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1023:	83 c0 30             	add    $0x30,%eax
    1026:	88 45 cd             	mov    %al,-0x33(%ebp)
    fd = open(name, O_CREATE | O_RDWR);
    1029:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1030:	00 
    1031:	8d 45 cc             	lea    -0x34(%ebp),%eax
    1034:	89 04 24             	mov    %eax,(%esp)
    1037:	e8 f0 2d 00 00       	call   3e2c <open>
    103c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fd < 0){
    103f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1043:	79 19                	jns    105e <createdelete+0xa4>
      printf(1, "create failed\n");
    1045:	c7 44 24 04 46 48 00 	movl   $0x4846,0x4(%esp)
    104c:	00 
    104d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1054:	e8 10 2f 00 00       	call   3f69 <printf>
      exit();
    1059:	e8 7e 2d 00 00       	call   3ddc <exit>
    }
    close(fd);
    105e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1061:	89 04 24             	mov    %eax,(%esp)
    1064:	e8 ab 2d 00 00       	call   3e14 <close>
    if(i > 0 && (i % 2 ) == 0){
    1069:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    106d:	7e 44                	jle    10b3 <createdelete+0xf9>
    106f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1072:	83 e0 01             	and    $0x1,%eax
    1075:	85 c0                	test   %eax,%eax
    1077:	75 3a                	jne    10b3 <createdelete+0xf9>
      name[1] = '0' + (i / 2);
    1079:	8b 45 f4             	mov    -0xc(%ebp),%eax
    107c:	89 c2                	mov    %eax,%edx
    107e:	c1 ea 1f             	shr    $0x1f,%edx
    1081:	01 d0                	add    %edx,%eax
    1083:	d1 f8                	sar    %eax
    1085:	83 c0 30             	add    $0x30,%eax
    1088:	88 45 cd             	mov    %al,-0x33(%ebp)
      if(unlink(name) < 0){
    108b:	8d 45 cc             	lea    -0x34(%ebp),%eax
    108e:	89 04 24             	mov    %eax,(%esp)
    1091:	e8 a6 2d 00 00       	call   3e3c <unlink>
    1096:	85 c0                	test   %eax,%eax
    1098:	79 19                	jns    10b3 <createdelete+0xf9>
        printf(1, "unlink failed\n");
    109a:	c7 44 24 04 a3 48 00 	movl   $0x48a3,0x4(%esp)
    10a1:	00 
    10a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10a9:	e8 bb 2e 00 00       	call   3f69 <printf>
        exit();
    10ae:	e8 29 2d 00 00       	call   3ddc <exit>
    exit();
  }

  name[0] = pid ? 'p' : 'c';
  name[2] = '\0';
  for(i = 0; i < N; i++){
    10b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    10b7:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    10bb:	0f 8e 5f ff ff ff    	jle    1020 <createdelete+0x66>
        exit();
      }
    }
  }

  if(pid==0)
    10c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    10c5:	75 05                	jne    10cc <createdelete+0x112>
    exit();
    10c7:	e8 10 2d 00 00       	call   3ddc <exit>
  else
    wait();
    10cc:	e8 13 2d 00 00       	call   3de4 <wait>

  for(i = 0; i < N; i++){
    10d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    10d8:	e9 34 01 00 00       	jmp    1211 <createdelete+0x257>
    name[0] = 'p';
    10dd:	c6 45 cc 70          	movb   $0x70,-0x34(%ebp)
    name[1] = '0' + i;
    10e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    10e4:	83 c0 30             	add    $0x30,%eax
    10e7:	88 45 cd             	mov    %al,-0x33(%ebp)
    fd = open(name, 0);
    10ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    10f1:	00 
    10f2:	8d 45 cc             	lea    -0x34(%ebp),%eax
    10f5:	89 04 24             	mov    %eax,(%esp)
    10f8:	e8 2f 2d 00 00       	call   3e2c <open>
    10fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((i == 0 || i >= N/2) && fd < 0){
    1100:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1104:	74 06                	je     110c <createdelete+0x152>
    1106:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    110a:	7e 26                	jle    1132 <createdelete+0x178>
    110c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1110:	79 20                	jns    1132 <createdelete+0x178>
      printf(1, "oops createdelete %s didn't exist\n", name);
    1112:	8d 45 cc             	lea    -0x34(%ebp),%eax
    1115:	89 44 24 08          	mov    %eax,0x8(%esp)
    1119:	c7 44 24 04 b4 48 00 	movl   $0x48b4,0x4(%esp)
    1120:	00 
    1121:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1128:	e8 3c 2e 00 00       	call   3f69 <printf>
      exit();
    112d:	e8 aa 2c 00 00       	call   3ddc <exit>
    } else if((i >= 1 && i < N/2) && fd >= 0){
    1132:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1136:	7e 2c                	jle    1164 <createdelete+0x1aa>
    1138:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    113c:	7f 26                	jg     1164 <createdelete+0x1aa>
    113e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1142:	78 20                	js     1164 <createdelete+0x1aa>
      printf(1, "oops createdelete %s did exist\n", name);
    1144:	8d 45 cc             	lea    -0x34(%ebp),%eax
    1147:	89 44 24 08          	mov    %eax,0x8(%esp)
    114b:	c7 44 24 04 d8 48 00 	movl   $0x48d8,0x4(%esp)
    1152:	00 
    1153:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    115a:	e8 0a 2e 00 00       	call   3f69 <printf>
      exit();
    115f:	e8 78 2c 00 00       	call   3ddc <exit>
    }
    if(fd >= 0)
    1164:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1168:	78 0b                	js     1175 <createdelete+0x1bb>
      close(fd);
    116a:	8b 45 ec             	mov    -0x14(%ebp),%eax
    116d:	89 04 24             	mov    %eax,(%esp)
    1170:	e8 9f 2c 00 00       	call   3e14 <close>

    name[0] = 'c';
    1175:	c6 45 cc 63          	movb   $0x63,-0x34(%ebp)
    name[1] = '0' + i;
    1179:	8b 45 f4             	mov    -0xc(%ebp),%eax
    117c:	83 c0 30             	add    $0x30,%eax
    117f:	88 45 cd             	mov    %al,-0x33(%ebp)
    fd = open(name, 0);
    1182:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1189:	00 
    118a:	8d 45 cc             	lea    -0x34(%ebp),%eax
    118d:	89 04 24             	mov    %eax,(%esp)
    1190:	e8 97 2c 00 00       	call   3e2c <open>
    1195:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((i == 0 || i >= N/2) && fd < 0){
    1198:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    119c:	74 06                	je     11a4 <createdelete+0x1ea>
    119e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    11a2:	7e 26                	jle    11ca <createdelete+0x210>
    11a4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    11a8:	79 20                	jns    11ca <createdelete+0x210>
      printf(1, "oops createdelete %s didn't exist\n", name);
    11aa:	8d 45 cc             	lea    -0x34(%ebp),%eax
    11ad:	89 44 24 08          	mov    %eax,0x8(%esp)
    11b1:	c7 44 24 04 b4 48 00 	movl   $0x48b4,0x4(%esp)
    11b8:	00 
    11b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11c0:	e8 a4 2d 00 00       	call   3f69 <printf>
      exit();
    11c5:	e8 12 2c 00 00       	call   3ddc <exit>
    } else if((i >= 1 && i < N/2) && fd >= 0){
    11ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11ce:	7e 2c                	jle    11fc <createdelete+0x242>
    11d0:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    11d4:	7f 26                	jg     11fc <createdelete+0x242>
    11d6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    11da:	78 20                	js     11fc <createdelete+0x242>
      printf(1, "oops createdelete %s did exist\n", name);
    11dc:	8d 45 cc             	lea    -0x34(%ebp),%eax
    11df:	89 44 24 08          	mov    %eax,0x8(%esp)
    11e3:	c7 44 24 04 d8 48 00 	movl   $0x48d8,0x4(%esp)
    11ea:	00 
    11eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11f2:	e8 72 2d 00 00       	call   3f69 <printf>
      exit();
    11f7:	e8 e0 2b 00 00       	call   3ddc <exit>
    }
    if(fd >= 0)
    11fc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1200:	78 0b                	js     120d <createdelete+0x253>
      close(fd);
    1202:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1205:	89 04 24             	mov    %eax,(%esp)
    1208:	e8 07 2c 00 00       	call   3e14 <close>
  if(pid==0)
    exit();
  else
    wait();

  for(i = 0; i < N; i++){
    120d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1211:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    1215:	0f 8e c2 fe ff ff    	jle    10dd <createdelete+0x123>
    }
    if(fd >= 0)
      close(fd);
  }

  for(i = 0; i < N; i++){
    121b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1222:	eb 2b                	jmp    124f <createdelete+0x295>
    name[0] = 'p';
    1224:	c6 45 cc 70          	movb   $0x70,-0x34(%ebp)
    name[1] = '0' + i;
    1228:	8b 45 f4             	mov    -0xc(%ebp),%eax
    122b:	83 c0 30             	add    $0x30,%eax
    122e:	88 45 cd             	mov    %al,-0x33(%ebp)
    unlink(name);
    1231:	8d 45 cc             	lea    -0x34(%ebp),%eax
    1234:	89 04 24             	mov    %eax,(%esp)
    1237:	e8 00 2c 00 00       	call   3e3c <unlink>
    name[0] = 'c';
    123c:	c6 45 cc 63          	movb   $0x63,-0x34(%ebp)
    unlink(name);
    1240:	8d 45 cc             	lea    -0x34(%ebp),%eax
    1243:	89 04 24             	mov    %eax,(%esp)
    1246:	e8 f1 2b 00 00       	call   3e3c <unlink>
    }
    if(fd >= 0)
      close(fd);
  }

  for(i = 0; i < N; i++){
    124b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    124f:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    1253:	7e cf                	jle    1224 <createdelete+0x26a>
    unlink(name);
    name[0] = 'c';
    unlink(name);
  }

  printf(1, "createdelete ok\n");
    1255:	c7 44 24 04 f8 48 00 	movl   $0x48f8,0x4(%esp)
    125c:	00 
    125d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1264:	e8 00 2d 00 00       	call   3f69 <printf>
}
    1269:	c9                   	leave  
    126a:	c3                   	ret    

0000126b <unlinkread>:

// can I unlink a file and still read it?
void
unlinkread(void)
{
    126b:	55                   	push   %ebp
    126c:	89 e5                	mov    %esp,%ebp
    126e:	83 ec 28             	sub    $0x28,%esp
  int fd, fd1;

  printf(1, "unlinkread test\n");
    1271:	c7 44 24 04 09 49 00 	movl   $0x4909,0x4(%esp)
    1278:	00 
    1279:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1280:	e8 e4 2c 00 00       	call   3f69 <printf>
  fd = open("unlinkread", O_CREATE | O_RDWR);
    1285:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    128c:	00 
    128d:	c7 04 24 1a 49 00 00 	movl   $0x491a,(%esp)
    1294:	e8 93 2b 00 00       	call   3e2c <open>
    1299:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    129c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    12a0:	79 19                	jns    12bb <unlinkread+0x50>
    printf(1, "create unlinkread failed\n");
    12a2:	c7 44 24 04 25 49 00 	movl   $0x4925,0x4(%esp)
    12a9:	00 
    12aa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    12b1:	e8 b3 2c 00 00       	call   3f69 <printf>
    exit();
    12b6:	e8 21 2b 00 00       	call   3ddc <exit>
  }
  write(fd, "hello", 5);
    12bb:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    12c2:	00 
    12c3:	c7 44 24 04 3f 49 00 	movl   $0x493f,0x4(%esp)
    12ca:	00 
    12cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12ce:	89 04 24             	mov    %eax,(%esp)
    12d1:	e8 36 2b 00 00       	call   3e0c <write>
  close(fd);
    12d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12d9:	89 04 24             	mov    %eax,(%esp)
    12dc:	e8 33 2b 00 00       	call   3e14 <close>

  fd = open("unlinkread", O_RDWR);
    12e1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    12e8:	00 
    12e9:	c7 04 24 1a 49 00 00 	movl   $0x491a,(%esp)
    12f0:	e8 37 2b 00 00       	call   3e2c <open>
    12f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    12f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    12fc:	79 19                	jns    1317 <unlinkread+0xac>
    printf(1, "open unlinkread failed\n");
    12fe:	c7 44 24 04 45 49 00 	movl   $0x4945,0x4(%esp)
    1305:	00 
    1306:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    130d:	e8 57 2c 00 00       	call   3f69 <printf>
    exit();
    1312:	e8 c5 2a 00 00       	call   3ddc <exit>
  }
  if(unlink("unlinkread") != 0){
    1317:	c7 04 24 1a 49 00 00 	movl   $0x491a,(%esp)
    131e:	e8 19 2b 00 00       	call   3e3c <unlink>
    1323:	85 c0                	test   %eax,%eax
    1325:	74 19                	je     1340 <unlinkread+0xd5>
    printf(1, "unlink unlinkread failed\n");
    1327:	c7 44 24 04 5d 49 00 	movl   $0x495d,0x4(%esp)
    132e:	00 
    132f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1336:	e8 2e 2c 00 00       	call   3f69 <printf>
    exit();
    133b:	e8 9c 2a 00 00       	call   3ddc <exit>
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    1340:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1347:	00 
    1348:	c7 04 24 1a 49 00 00 	movl   $0x491a,(%esp)
    134f:	e8 d8 2a 00 00       	call   3e2c <open>
    1354:	89 45 f0             	mov    %eax,-0x10(%ebp)
  write(fd1, "yyy", 3);
    1357:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
    135e:	00 
    135f:	c7 44 24 04 77 49 00 	movl   $0x4977,0x4(%esp)
    1366:	00 
    1367:	8b 45 f0             	mov    -0x10(%ebp),%eax
    136a:	89 04 24             	mov    %eax,(%esp)
    136d:	e8 9a 2a 00 00       	call   3e0c <write>
  close(fd1);
    1372:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1375:	89 04 24             	mov    %eax,(%esp)
    1378:	e8 97 2a 00 00       	call   3e14 <close>

  if(read(fd, buf, sizeof(buf)) != 5){
    137d:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1384:	00 
    1385:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
    138c:	00 
    138d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1390:	89 04 24             	mov    %eax,(%esp)
    1393:	e8 6c 2a 00 00       	call   3e04 <read>
    1398:	83 f8 05             	cmp    $0x5,%eax
    139b:	74 19                	je     13b6 <unlinkread+0x14b>
    printf(1, "unlinkread read failed");
    139d:	c7 44 24 04 7b 49 00 	movl   $0x497b,0x4(%esp)
    13a4:	00 
    13a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    13ac:	e8 b8 2b 00 00       	call   3f69 <printf>
    exit();
    13b1:	e8 26 2a 00 00       	call   3ddc <exit>
  }
  if(buf[0] != 'h'){
    13b6:	0f b6 05 00 89 00 00 	movzbl 0x8900,%eax
    13bd:	3c 68                	cmp    $0x68,%al
    13bf:	74 19                	je     13da <unlinkread+0x16f>
    printf(1, "unlinkread wrong data\n");
    13c1:	c7 44 24 04 92 49 00 	movl   $0x4992,0x4(%esp)
    13c8:	00 
    13c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    13d0:	e8 94 2b 00 00       	call   3f69 <printf>
    exit();
    13d5:	e8 02 2a 00 00       	call   3ddc <exit>
  }
  if(write(fd, buf, 10) != 10){
    13da:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    13e1:	00 
    13e2:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
    13e9:	00 
    13ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13ed:	89 04 24             	mov    %eax,(%esp)
    13f0:	e8 17 2a 00 00       	call   3e0c <write>
    13f5:	83 f8 0a             	cmp    $0xa,%eax
    13f8:	74 19                	je     1413 <unlinkread+0x1a8>
    printf(1, "unlinkread write failed\n");
    13fa:	c7 44 24 04 a9 49 00 	movl   $0x49a9,0x4(%esp)
    1401:	00 
    1402:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1409:	e8 5b 2b 00 00       	call   3f69 <printf>
    exit();
    140e:	e8 c9 29 00 00       	call   3ddc <exit>
  }
  close(fd);
    1413:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1416:	89 04 24             	mov    %eax,(%esp)
    1419:	e8 f6 29 00 00       	call   3e14 <close>
  unlink("unlinkread");
    141e:	c7 04 24 1a 49 00 00 	movl   $0x491a,(%esp)
    1425:	e8 12 2a 00 00       	call   3e3c <unlink>
  printf(1, "unlinkread ok\n");
    142a:	c7 44 24 04 c2 49 00 	movl   $0x49c2,0x4(%esp)
    1431:	00 
    1432:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1439:	e8 2b 2b 00 00       	call   3f69 <printf>
}
    143e:	c9                   	leave  
    143f:	c3                   	ret    

00001440 <linktest>:

void
linktest(void)
{
    1440:	55                   	push   %ebp
    1441:	89 e5                	mov    %esp,%ebp
    1443:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "linktest\n");
    1446:	c7 44 24 04 d1 49 00 	movl   $0x49d1,0x4(%esp)
    144d:	00 
    144e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1455:	e8 0f 2b 00 00       	call   3f69 <printf>

  unlink("lf1");
    145a:	c7 04 24 db 49 00 00 	movl   $0x49db,(%esp)
    1461:	e8 d6 29 00 00       	call   3e3c <unlink>
  unlink("lf2");
    1466:	c7 04 24 df 49 00 00 	movl   $0x49df,(%esp)
    146d:	e8 ca 29 00 00       	call   3e3c <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    1472:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1479:	00 
    147a:	c7 04 24 db 49 00 00 	movl   $0x49db,(%esp)
    1481:	e8 a6 29 00 00       	call   3e2c <open>
    1486:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1489:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    148d:	79 19                	jns    14a8 <linktest+0x68>
    printf(1, "create lf1 failed\n");
    148f:	c7 44 24 04 e3 49 00 	movl   $0x49e3,0x4(%esp)
    1496:	00 
    1497:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    149e:	e8 c6 2a 00 00       	call   3f69 <printf>
    exit();
    14a3:	e8 34 29 00 00       	call   3ddc <exit>
  }
  if(write(fd, "hello", 5) != 5){
    14a8:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    14af:	00 
    14b0:	c7 44 24 04 3f 49 00 	movl   $0x493f,0x4(%esp)
    14b7:	00 
    14b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14bb:	89 04 24             	mov    %eax,(%esp)
    14be:	e8 49 29 00 00       	call   3e0c <write>
    14c3:	83 f8 05             	cmp    $0x5,%eax
    14c6:	74 19                	je     14e1 <linktest+0xa1>
    printf(1, "write lf1 failed\n");
    14c8:	c7 44 24 04 f6 49 00 	movl   $0x49f6,0x4(%esp)
    14cf:	00 
    14d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    14d7:	e8 8d 2a 00 00       	call   3f69 <printf>
    exit();
    14dc:	e8 fb 28 00 00       	call   3ddc <exit>
  }
  close(fd);
    14e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14e4:	89 04 24             	mov    %eax,(%esp)
    14e7:	e8 28 29 00 00       	call   3e14 <close>

  if(link("lf1", "lf2") < 0){
    14ec:	c7 44 24 04 df 49 00 	movl   $0x49df,0x4(%esp)
    14f3:	00 
    14f4:	c7 04 24 db 49 00 00 	movl   $0x49db,(%esp)
    14fb:	e8 4c 29 00 00       	call   3e4c <link>
    1500:	85 c0                	test   %eax,%eax
    1502:	79 19                	jns    151d <linktest+0xdd>
    printf(1, "link lf1 lf2 failed\n");
    1504:	c7 44 24 04 08 4a 00 	movl   $0x4a08,0x4(%esp)
    150b:	00 
    150c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1513:	e8 51 2a 00 00       	call   3f69 <printf>
    exit();
    1518:	e8 bf 28 00 00       	call   3ddc <exit>
  }
  unlink("lf1");
    151d:	c7 04 24 db 49 00 00 	movl   $0x49db,(%esp)
    1524:	e8 13 29 00 00       	call   3e3c <unlink>

  if(open("lf1", 0) >= 0){
    1529:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1530:	00 
    1531:	c7 04 24 db 49 00 00 	movl   $0x49db,(%esp)
    1538:	e8 ef 28 00 00       	call   3e2c <open>
    153d:	85 c0                	test   %eax,%eax
    153f:	78 19                	js     155a <linktest+0x11a>
    printf(1, "unlinked lf1 but it is still there!\n");
    1541:	c7 44 24 04 20 4a 00 	movl   $0x4a20,0x4(%esp)
    1548:	00 
    1549:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1550:	e8 14 2a 00 00       	call   3f69 <printf>
    exit();
    1555:	e8 82 28 00 00       	call   3ddc <exit>
  }

  fd = open("lf2", 0);
    155a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1561:	00 
    1562:	c7 04 24 df 49 00 00 	movl   $0x49df,(%esp)
    1569:	e8 be 28 00 00       	call   3e2c <open>
    156e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1571:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1575:	79 19                	jns    1590 <linktest+0x150>
    printf(1, "open lf2 failed\n");
    1577:	c7 44 24 04 45 4a 00 	movl   $0x4a45,0x4(%esp)
    157e:	00 
    157f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1586:	e8 de 29 00 00       	call   3f69 <printf>
    exit();
    158b:	e8 4c 28 00 00       	call   3ddc <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    1590:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1597:	00 
    1598:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
    159f:	00 
    15a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15a3:	89 04 24             	mov    %eax,(%esp)
    15a6:	e8 59 28 00 00       	call   3e04 <read>
    15ab:	83 f8 05             	cmp    $0x5,%eax
    15ae:	74 19                	je     15c9 <linktest+0x189>
    printf(1, "read lf2 failed\n");
    15b0:	c7 44 24 04 56 4a 00 	movl   $0x4a56,0x4(%esp)
    15b7:	00 
    15b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15bf:	e8 a5 29 00 00       	call   3f69 <printf>
    exit();
    15c4:	e8 13 28 00 00       	call   3ddc <exit>
  }
  close(fd);
    15c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    15cc:	89 04 24             	mov    %eax,(%esp)
    15cf:	e8 40 28 00 00       	call   3e14 <close>

  if(link("lf2", "lf2") >= 0){
    15d4:	c7 44 24 04 df 49 00 	movl   $0x49df,0x4(%esp)
    15db:	00 
    15dc:	c7 04 24 df 49 00 00 	movl   $0x49df,(%esp)
    15e3:	e8 64 28 00 00       	call   3e4c <link>
    15e8:	85 c0                	test   %eax,%eax
    15ea:	78 19                	js     1605 <linktest+0x1c5>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    15ec:	c7 44 24 04 67 4a 00 	movl   $0x4a67,0x4(%esp)
    15f3:	00 
    15f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15fb:	e8 69 29 00 00       	call   3f69 <printf>
    exit();
    1600:	e8 d7 27 00 00       	call   3ddc <exit>
  }

  unlink("lf2");
    1605:	c7 04 24 df 49 00 00 	movl   $0x49df,(%esp)
    160c:	e8 2b 28 00 00       	call   3e3c <unlink>
  if(link("lf2", "lf1") >= 0){
    1611:	c7 44 24 04 db 49 00 	movl   $0x49db,0x4(%esp)
    1618:	00 
    1619:	c7 04 24 df 49 00 00 	movl   $0x49df,(%esp)
    1620:	e8 27 28 00 00       	call   3e4c <link>
    1625:	85 c0                	test   %eax,%eax
    1627:	78 19                	js     1642 <linktest+0x202>
    printf(1, "link non-existant succeeded! oops\n");
    1629:	c7 44 24 04 88 4a 00 	movl   $0x4a88,0x4(%esp)
    1630:	00 
    1631:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1638:	e8 2c 29 00 00       	call   3f69 <printf>
    exit();
    163d:	e8 9a 27 00 00       	call   3ddc <exit>
  }

  if(link(".", "lf1") >= 0){
    1642:	c7 44 24 04 db 49 00 	movl   $0x49db,0x4(%esp)
    1649:	00 
    164a:	c7 04 24 ab 4a 00 00 	movl   $0x4aab,(%esp)
    1651:	e8 f6 27 00 00       	call   3e4c <link>
    1656:	85 c0                	test   %eax,%eax
    1658:	78 19                	js     1673 <linktest+0x233>
    printf(1, "link . lf1 succeeded! oops\n");
    165a:	c7 44 24 04 ad 4a 00 	movl   $0x4aad,0x4(%esp)
    1661:	00 
    1662:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1669:	e8 fb 28 00 00       	call   3f69 <printf>
    exit();
    166e:	e8 69 27 00 00       	call   3ddc <exit>
  }

  printf(1, "linktest ok\n");
    1673:	c7 44 24 04 c9 4a 00 	movl   $0x4ac9,0x4(%esp)
    167a:	00 
    167b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1682:	e8 e2 28 00 00       	call   3f69 <printf>
}
    1687:	c9                   	leave  
    1688:	c3                   	ret    

00001689 <concreate>:

// test concurrent create/link/unlink of the same file
void
concreate(void)
{
    1689:	55                   	push   %ebp
    168a:	89 e5                	mov    %esp,%ebp
    168c:	83 ec 68             	sub    $0x68,%esp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    168f:	c7 44 24 04 d6 4a 00 	movl   $0x4ad6,0x4(%esp)
    1696:	00 
    1697:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    169e:	e8 c6 28 00 00       	call   3f69 <printf>
  file[0] = 'C';
    16a3:	c6 45 e5 43          	movb   $0x43,-0x1b(%ebp)
  file[2] = '\0';
    16a7:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
  for(i = 0; i < 40; i++){
    16ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    16b2:	e9 f7 00 00 00       	jmp    17ae <concreate+0x125>
    file[1] = '0' + i;
    16b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    16ba:	83 c0 30             	add    $0x30,%eax
    16bd:	88 45 e6             	mov    %al,-0x1a(%ebp)
    unlink(file);
    16c0:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    16c3:	89 04 24             	mov    %eax,(%esp)
    16c6:	e8 71 27 00 00       	call   3e3c <unlink>
    pid = fork();
    16cb:	e8 04 27 00 00       	call   3dd4 <fork>
    16d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid && (i % 3) == 1){
    16d3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    16d7:	74 3a                	je     1713 <concreate+0x8a>
    16d9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    16dc:	ba 56 55 55 55       	mov    $0x55555556,%edx
    16e1:	89 c8                	mov    %ecx,%eax
    16e3:	f7 ea                	imul   %edx
    16e5:	89 c8                	mov    %ecx,%eax
    16e7:	c1 f8 1f             	sar    $0x1f,%eax
    16ea:	29 c2                	sub    %eax,%edx
    16ec:	89 d0                	mov    %edx,%eax
    16ee:	01 c0                	add    %eax,%eax
    16f0:	01 d0                	add    %edx,%eax
    16f2:	89 ca                	mov    %ecx,%edx
    16f4:	29 c2                	sub    %eax,%edx
    16f6:	83 fa 01             	cmp    $0x1,%edx
    16f9:	75 18                	jne    1713 <concreate+0x8a>
      link("C0", file);
    16fb:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    16fe:	89 44 24 04          	mov    %eax,0x4(%esp)
    1702:	c7 04 24 e6 4a 00 00 	movl   $0x4ae6,(%esp)
    1709:	e8 3e 27 00 00       	call   3e4c <link>
    170e:	e9 87 00 00 00       	jmp    179a <concreate+0x111>
    } else if(pid == 0 && (i % 5) == 1){
    1713:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1717:	75 3a                	jne    1753 <concreate+0xca>
    1719:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    171c:	ba 67 66 66 66       	mov    $0x66666667,%edx
    1721:	89 c8                	mov    %ecx,%eax
    1723:	f7 ea                	imul   %edx
    1725:	d1 fa                	sar    %edx
    1727:	89 c8                	mov    %ecx,%eax
    1729:	c1 f8 1f             	sar    $0x1f,%eax
    172c:	29 c2                	sub    %eax,%edx
    172e:	89 d0                	mov    %edx,%eax
    1730:	c1 e0 02             	shl    $0x2,%eax
    1733:	01 d0                	add    %edx,%eax
    1735:	89 ca                	mov    %ecx,%edx
    1737:	29 c2                	sub    %eax,%edx
    1739:	83 fa 01             	cmp    $0x1,%edx
    173c:	75 15                	jne    1753 <concreate+0xca>
      link("C0", file);
    173e:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1741:	89 44 24 04          	mov    %eax,0x4(%esp)
    1745:	c7 04 24 e6 4a 00 00 	movl   $0x4ae6,(%esp)
    174c:	e8 fb 26 00 00       	call   3e4c <link>
    1751:	eb 47                	jmp    179a <concreate+0x111>
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    1753:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    175a:	00 
    175b:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    175e:	89 04 24             	mov    %eax,(%esp)
    1761:	e8 c6 26 00 00       	call   3e2c <open>
    1766:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(fd < 0){
    1769:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    176d:	79 20                	jns    178f <concreate+0x106>
        printf(1, "concreate create %s failed\n", file);
    176f:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1772:	89 44 24 08          	mov    %eax,0x8(%esp)
    1776:	c7 44 24 04 e9 4a 00 	movl   $0x4ae9,0x4(%esp)
    177d:	00 
    177e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1785:	e8 df 27 00 00       	call   3f69 <printf>
        exit();
    178a:	e8 4d 26 00 00       	call   3ddc <exit>
      }
      close(fd);
    178f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1792:	89 04 24             	mov    %eax,(%esp)
    1795:	e8 7a 26 00 00       	call   3e14 <close>
    }
    if(pid == 0)
    179a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    179e:	75 05                	jne    17a5 <concreate+0x11c>
      exit();
    17a0:	e8 37 26 00 00       	call   3ddc <exit>
    else
      wait();
    17a5:	e8 3a 26 00 00       	call   3de4 <wait>
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    17aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    17ae:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    17b2:	0f 8e ff fe ff ff    	jle    16b7 <concreate+0x2e>
      exit();
    else
      wait();
  }

  memset(fa, 0, sizeof(fa));
    17b8:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
    17bf:	00 
    17c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    17c7:	00 
    17c8:	8d 45 bd             	lea    -0x43(%ebp),%eax
    17cb:	89 04 24             	mov    %eax,(%esp)
    17ce:	e8 c2 22 00 00       	call   3a95 <memset>
  fd = open(".", 0);
    17d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    17da:	00 
    17db:	c7 04 24 ab 4a 00 00 	movl   $0x4aab,(%esp)
    17e2:	e8 45 26 00 00       	call   3e2c <open>
    17e7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  n = 0;
    17ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  while(read(fd, &de, sizeof(de)) > 0){
    17f1:	e9 a7 00 00 00       	jmp    189d <concreate+0x214>
    if(de.inum == 0)
    17f6:	0f b7 45 ac          	movzwl -0x54(%ebp),%eax
    17fa:	66 85 c0             	test   %ax,%ax
    17fd:	0f 84 99 00 00 00    	je     189c <concreate+0x213>
      continue;
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    1803:	0f b6 45 ae          	movzbl -0x52(%ebp),%eax
    1807:	3c 43                	cmp    $0x43,%al
    1809:	0f 85 8e 00 00 00    	jne    189d <concreate+0x214>
    180f:	0f b6 45 b0          	movzbl -0x50(%ebp),%eax
    1813:	84 c0                	test   %al,%al
    1815:	0f 85 82 00 00 00    	jne    189d <concreate+0x214>
      i = de.name[1] - '0';
    181b:	0f b6 45 af          	movzbl -0x51(%ebp),%eax
    181f:	0f be c0             	movsbl %al,%eax
    1822:	83 e8 30             	sub    $0x30,%eax
    1825:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(i < 0 || i >= sizeof(fa)){
    1828:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    182c:	78 08                	js     1836 <concreate+0x1ad>
    182e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1831:	83 f8 27             	cmp    $0x27,%eax
    1834:	76 23                	jbe    1859 <concreate+0x1d0>
        printf(1, "concreate weird file %s\n", de.name);
    1836:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1839:	83 c0 02             	add    $0x2,%eax
    183c:	89 44 24 08          	mov    %eax,0x8(%esp)
    1840:	c7 44 24 04 05 4b 00 	movl   $0x4b05,0x4(%esp)
    1847:	00 
    1848:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    184f:	e8 15 27 00 00       	call   3f69 <printf>
        exit();
    1854:	e8 83 25 00 00       	call   3ddc <exit>
      }
      if(fa[i]){
    1859:	8d 55 bd             	lea    -0x43(%ebp),%edx
    185c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    185f:	01 d0                	add    %edx,%eax
    1861:	0f b6 00             	movzbl (%eax),%eax
    1864:	84 c0                	test   %al,%al
    1866:	74 23                	je     188b <concreate+0x202>
        printf(1, "concreate duplicate file %s\n", de.name);
    1868:	8d 45 ac             	lea    -0x54(%ebp),%eax
    186b:	83 c0 02             	add    $0x2,%eax
    186e:	89 44 24 08          	mov    %eax,0x8(%esp)
    1872:	c7 44 24 04 1e 4b 00 	movl   $0x4b1e,0x4(%esp)
    1879:	00 
    187a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1881:	e8 e3 26 00 00       	call   3f69 <printf>
        exit();
    1886:	e8 51 25 00 00       	call   3ddc <exit>
      }
      fa[i] = 1;
    188b:	8d 55 bd             	lea    -0x43(%ebp),%edx
    188e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1891:	01 d0                	add    %edx,%eax
    1893:	c6 00 01             	movb   $0x1,(%eax)
      n++;
    1896:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    189a:	eb 01                	jmp    189d <concreate+0x214>
  memset(fa, 0, sizeof(fa));
  fd = open(".", 0);
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    if(de.inum == 0)
      continue;
    189c:	90                   	nop
  }

  memset(fa, 0, sizeof(fa));
  fd = open(".", 0);
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    189d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    18a4:	00 
    18a5:	8d 45 ac             	lea    -0x54(%ebp),%eax
    18a8:	89 44 24 04          	mov    %eax,0x4(%esp)
    18ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
    18af:	89 04 24             	mov    %eax,(%esp)
    18b2:	e8 4d 25 00 00       	call   3e04 <read>
    18b7:	85 c0                	test   %eax,%eax
    18b9:	0f 8f 37 ff ff ff    	jg     17f6 <concreate+0x16d>
      }
      fa[i] = 1;
      n++;
    }
  }
  close(fd);
    18bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
    18c2:	89 04 24             	mov    %eax,(%esp)
    18c5:	e8 4a 25 00 00       	call   3e14 <close>

  if(n != 40){
    18ca:	83 7d f0 28          	cmpl   $0x28,-0x10(%ebp)
    18ce:	74 19                	je     18e9 <concreate+0x260>
    printf(1, "concreate not enough files in directory listing\n");
    18d0:	c7 44 24 04 3c 4b 00 	movl   $0x4b3c,0x4(%esp)
    18d7:	00 
    18d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18df:	e8 85 26 00 00       	call   3f69 <printf>
    exit();
    18e4:	e8 f3 24 00 00       	call   3ddc <exit>
  }

  for(i = 0; i < 40; i++){
    18e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    18f0:	e9 2d 01 00 00       	jmp    1a22 <concreate+0x399>
    file[1] = '0' + i;
    18f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    18f8:	83 c0 30             	add    $0x30,%eax
    18fb:	88 45 e6             	mov    %al,-0x1a(%ebp)
    pid = fork();
    18fe:	e8 d1 24 00 00       	call   3dd4 <fork>
    1903:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    1906:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    190a:	79 19                	jns    1925 <concreate+0x29c>
      printf(1, "fork failed\n");
    190c:	c7 44 24 04 29 47 00 	movl   $0x4729,0x4(%esp)
    1913:	00 
    1914:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    191b:	e8 49 26 00 00       	call   3f69 <printf>
      exit();
    1920:	e8 b7 24 00 00       	call   3ddc <exit>
    }
    if(((i % 3) == 0 && pid == 0) ||
    1925:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    1928:	ba 56 55 55 55       	mov    $0x55555556,%edx
    192d:	89 c8                	mov    %ecx,%eax
    192f:	f7 ea                	imul   %edx
    1931:	89 c8                	mov    %ecx,%eax
    1933:	c1 f8 1f             	sar    $0x1f,%eax
    1936:	29 c2                	sub    %eax,%edx
    1938:	89 d0                	mov    %edx,%eax
    193a:	01 c0                	add    %eax,%eax
    193c:	01 d0                	add    %edx,%eax
    193e:	89 ca                	mov    %ecx,%edx
    1940:	29 c2                	sub    %eax,%edx
    1942:	85 d2                	test   %edx,%edx
    1944:	75 06                	jne    194c <concreate+0x2c3>
    1946:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    194a:	74 28                	je     1974 <concreate+0x2eb>
       ((i % 3) == 1 && pid != 0)){
    194c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    194f:	ba 56 55 55 55       	mov    $0x55555556,%edx
    1954:	89 c8                	mov    %ecx,%eax
    1956:	f7 ea                	imul   %edx
    1958:	89 c8                	mov    %ecx,%eax
    195a:	c1 f8 1f             	sar    $0x1f,%eax
    195d:	29 c2                	sub    %eax,%edx
    195f:	89 d0                	mov    %edx,%eax
    1961:	01 c0                	add    %eax,%eax
    1963:	01 d0                	add    %edx,%eax
    1965:	89 ca                	mov    %ecx,%edx
    1967:	29 c2                	sub    %eax,%edx
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
      exit();
    }
    if(((i % 3) == 0 && pid == 0) ||
    1969:	83 fa 01             	cmp    $0x1,%edx
    196c:	75 74                	jne    19e2 <concreate+0x359>
       ((i % 3) == 1 && pid != 0)){
    196e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1972:	74 6e                	je     19e2 <concreate+0x359>
      close(open(file, 0));
    1974:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    197b:	00 
    197c:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    197f:	89 04 24             	mov    %eax,(%esp)
    1982:	e8 a5 24 00 00       	call   3e2c <open>
    1987:	89 04 24             	mov    %eax,(%esp)
    198a:	e8 85 24 00 00       	call   3e14 <close>
      close(open(file, 0));
    198f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1996:	00 
    1997:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    199a:	89 04 24             	mov    %eax,(%esp)
    199d:	e8 8a 24 00 00       	call   3e2c <open>
    19a2:	89 04 24             	mov    %eax,(%esp)
    19a5:	e8 6a 24 00 00       	call   3e14 <close>
      close(open(file, 0));
    19aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    19b1:	00 
    19b2:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    19b5:	89 04 24             	mov    %eax,(%esp)
    19b8:	e8 6f 24 00 00       	call   3e2c <open>
    19bd:	89 04 24             	mov    %eax,(%esp)
    19c0:	e8 4f 24 00 00       	call   3e14 <close>
      close(open(file, 0));
    19c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    19cc:	00 
    19cd:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    19d0:	89 04 24             	mov    %eax,(%esp)
    19d3:	e8 54 24 00 00       	call   3e2c <open>
    19d8:	89 04 24             	mov    %eax,(%esp)
    19db:	e8 34 24 00 00       	call   3e14 <close>
    19e0:	eb 2c                	jmp    1a0e <concreate+0x385>
    } else {
      unlink(file);
    19e2:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    19e5:	89 04 24             	mov    %eax,(%esp)
    19e8:	e8 4f 24 00 00       	call   3e3c <unlink>
      unlink(file);
    19ed:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    19f0:	89 04 24             	mov    %eax,(%esp)
    19f3:	e8 44 24 00 00       	call   3e3c <unlink>
      unlink(file);
    19f8:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    19fb:	89 04 24             	mov    %eax,(%esp)
    19fe:	e8 39 24 00 00       	call   3e3c <unlink>
      unlink(file);
    1a03:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1a06:	89 04 24             	mov    %eax,(%esp)
    1a09:	e8 2e 24 00 00       	call   3e3c <unlink>
    }
    if(pid == 0)
    1a0e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1a12:	75 05                	jne    1a19 <concreate+0x390>
      exit();
    1a14:	e8 c3 23 00 00       	call   3ddc <exit>
    else
      wait();
    1a19:	e8 c6 23 00 00       	call   3de4 <wait>
  if(n != 40){
    printf(1, "concreate not enough files in directory listing\n");
    exit();
  }

  for(i = 0; i < 40; i++){
    1a1e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1a22:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    1a26:	0f 8e c9 fe ff ff    	jle    18f5 <concreate+0x26c>
      exit();
    else
      wait();
  }

  printf(1, "concreate ok\n");
    1a2c:	c7 44 24 04 6d 4b 00 	movl   $0x4b6d,0x4(%esp)
    1a33:	00 
    1a34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a3b:	e8 29 25 00 00       	call   3f69 <printf>
}
    1a40:	c9                   	leave  
    1a41:	c3                   	ret    

00001a42 <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink()
{
    1a42:	55                   	push   %ebp
    1a43:	89 e5                	mov    %esp,%ebp
    1a45:	83 ec 28             	sub    $0x28,%esp
  int pid, i;

  printf(1, "linkunlink test\n");
    1a48:	c7 44 24 04 7b 4b 00 	movl   $0x4b7b,0x4(%esp)
    1a4f:	00 
    1a50:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a57:	e8 0d 25 00 00       	call   3f69 <printf>

  unlink("x");
    1a5c:	c7 04 24 e2 46 00 00 	movl   $0x46e2,(%esp)
    1a63:	e8 d4 23 00 00       	call   3e3c <unlink>
  pid = fork();
    1a68:	e8 67 23 00 00       	call   3dd4 <fork>
    1a6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid < 0){
    1a70:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1a74:	79 19                	jns    1a8f <linkunlink+0x4d>
    printf(1, "fork failed\n");
    1a76:	c7 44 24 04 29 47 00 	movl   $0x4729,0x4(%esp)
    1a7d:	00 
    1a7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a85:	e8 df 24 00 00       	call   3f69 <printf>
    exit();
    1a8a:	e8 4d 23 00 00       	call   3ddc <exit>
  }

  unsigned int x = (pid ? 1 : 97);
    1a8f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1a93:	74 07                	je     1a9c <linkunlink+0x5a>
    1a95:	b8 01 00 00 00       	mov    $0x1,%eax
    1a9a:	eb 05                	jmp    1aa1 <linkunlink+0x5f>
    1a9c:	b8 61 00 00 00       	mov    $0x61,%eax
    1aa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; i < 100; i++){
    1aa4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1aab:	e9 8e 00 00 00       	jmp    1b3e <linkunlink+0xfc>
    x = x * 1103515245 + 12345;
    1ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1ab3:	69 c0 6d 4e c6 41    	imul   $0x41c64e6d,%eax,%eax
    1ab9:	05 39 30 00 00       	add    $0x3039,%eax
    1abe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((x % 3) == 0){
    1ac1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    1ac4:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1ac9:	89 c8                	mov    %ecx,%eax
    1acb:	f7 e2                	mul    %edx
    1acd:	d1 ea                	shr    %edx
    1acf:	89 d0                	mov    %edx,%eax
    1ad1:	01 c0                	add    %eax,%eax
    1ad3:	01 d0                	add    %edx,%eax
    1ad5:	89 ca                	mov    %ecx,%edx
    1ad7:	29 c2                	sub    %eax,%edx
    1ad9:	85 d2                	test   %edx,%edx
    1adb:	75 1e                	jne    1afb <linkunlink+0xb9>
      close(open("x", O_RDWR | O_CREATE));
    1add:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1ae4:	00 
    1ae5:	c7 04 24 e2 46 00 00 	movl   $0x46e2,(%esp)
    1aec:	e8 3b 23 00 00       	call   3e2c <open>
    1af1:	89 04 24             	mov    %eax,(%esp)
    1af4:	e8 1b 23 00 00       	call   3e14 <close>
    1af9:	eb 3f                	jmp    1b3a <linkunlink+0xf8>
    } else if((x % 3) == 1){
    1afb:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    1afe:	ba ab aa aa aa       	mov    $0xaaaaaaab,%edx
    1b03:	89 c8                	mov    %ecx,%eax
    1b05:	f7 e2                	mul    %edx
    1b07:	d1 ea                	shr    %edx
    1b09:	89 d0                	mov    %edx,%eax
    1b0b:	01 c0                	add    %eax,%eax
    1b0d:	01 d0                	add    %edx,%eax
    1b0f:	89 ca                	mov    %ecx,%edx
    1b11:	29 c2                	sub    %eax,%edx
    1b13:	83 fa 01             	cmp    $0x1,%edx
    1b16:	75 16                	jne    1b2e <linkunlink+0xec>
      link("cat", "x");
    1b18:	c7 44 24 04 e2 46 00 	movl   $0x46e2,0x4(%esp)
    1b1f:	00 
    1b20:	c7 04 24 8c 4b 00 00 	movl   $0x4b8c,(%esp)
    1b27:	e8 20 23 00 00       	call   3e4c <link>
    1b2c:	eb 0c                	jmp    1b3a <linkunlink+0xf8>
    } else {
      unlink("x");
    1b2e:	c7 04 24 e2 46 00 00 	movl   $0x46e2,(%esp)
    1b35:	e8 02 23 00 00       	call   3e3c <unlink>
    printf(1, "fork failed\n");
    exit();
  }

  unsigned int x = (pid ? 1 : 97);
  for(i = 0; i < 100; i++){
    1b3a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1b3e:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
    1b42:	0f 8e 68 ff ff ff    	jle    1ab0 <linkunlink+0x6e>
    } else {
      unlink("x");
    }
  }

  if(pid)
    1b48:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1b4c:	74 1b                	je     1b69 <linkunlink+0x127>
    wait();
    1b4e:	e8 91 22 00 00       	call   3de4 <wait>
  else 
    exit();

  printf(1, "linkunlink ok\n");
    1b53:	c7 44 24 04 90 4b 00 	movl   $0x4b90,0x4(%esp)
    1b5a:	00 
    1b5b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b62:	e8 02 24 00 00       	call   3f69 <printf>
    1b67:	eb 05                	jmp    1b6e <linkunlink+0x12c>
  }

  if(pid)
    wait();
  else 
    exit();
    1b69:	e8 6e 22 00 00       	call   3ddc <exit>

  printf(1, "linkunlink ok\n");
}
    1b6e:	c9                   	leave  
    1b6f:	c3                   	ret    

00001b70 <bigdir>:

// directory that uses indirect blocks
void
bigdir(void)
{
    1b70:	55                   	push   %ebp
    1b71:	89 e5                	mov    %esp,%ebp
    1b73:	83 ec 38             	sub    $0x38,%esp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    1b76:	c7 44 24 04 9f 4b 00 	movl   $0x4b9f,0x4(%esp)
    1b7d:	00 
    1b7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b85:	e8 df 23 00 00       	call   3f69 <printf>
  unlink("bd");
    1b8a:	c7 04 24 ac 4b 00 00 	movl   $0x4bac,(%esp)
    1b91:	e8 a6 22 00 00       	call   3e3c <unlink>

  fd = open("bd", O_CREATE);
    1b96:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    1b9d:	00 
    1b9e:	c7 04 24 ac 4b 00 00 	movl   $0x4bac,(%esp)
    1ba5:	e8 82 22 00 00       	call   3e2c <open>
    1baa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd < 0){
    1bad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1bb1:	79 19                	jns    1bcc <bigdir+0x5c>
    printf(1, "bigdir create failed\n");
    1bb3:	c7 44 24 04 af 4b 00 	movl   $0x4baf,0x4(%esp)
    1bba:	00 
    1bbb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1bc2:	e8 a2 23 00 00       	call   3f69 <printf>
    exit();
    1bc7:	e8 10 22 00 00       	call   3ddc <exit>
  }
  close(fd);
    1bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1bcf:	89 04 24             	mov    %eax,(%esp)
    1bd2:	e8 3d 22 00 00       	call   3e14 <close>

  for(i = 0; i < 500; i++){
    1bd7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1bde:	eb 68                	jmp    1c48 <bigdir+0xd8>
    name[0] = 'x';
    1be0:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    1be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1be7:	8d 50 3f             	lea    0x3f(%eax),%edx
    1bea:	85 c0                	test   %eax,%eax
    1bec:	0f 48 c2             	cmovs  %edx,%eax
    1bef:	c1 f8 06             	sar    $0x6,%eax
    1bf2:	83 c0 30             	add    $0x30,%eax
    1bf5:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    1bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1bfb:	89 c2                	mov    %eax,%edx
    1bfd:	c1 fa 1f             	sar    $0x1f,%edx
    1c00:	c1 ea 1a             	shr    $0x1a,%edx
    1c03:	01 d0                	add    %edx,%eax
    1c05:	83 e0 3f             	and    $0x3f,%eax
    1c08:	29 d0                	sub    %edx,%eax
    1c0a:	83 c0 30             	add    $0x30,%eax
    1c0d:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    1c10:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(link("bd", name) != 0){
    1c14:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    1c17:	89 44 24 04          	mov    %eax,0x4(%esp)
    1c1b:	c7 04 24 ac 4b 00 00 	movl   $0x4bac,(%esp)
    1c22:	e8 25 22 00 00       	call   3e4c <link>
    1c27:	85 c0                	test   %eax,%eax
    1c29:	74 19                	je     1c44 <bigdir+0xd4>
      printf(1, "bigdir link failed\n");
    1c2b:	c7 44 24 04 c5 4b 00 	movl   $0x4bc5,0x4(%esp)
    1c32:	00 
    1c33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1c3a:	e8 2a 23 00 00       	call   3f69 <printf>
      exit();
    1c3f:	e8 98 21 00 00       	call   3ddc <exit>
    printf(1, "bigdir create failed\n");
    exit();
  }
  close(fd);

  for(i = 0; i < 500; i++){
    1c44:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1c48:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    1c4f:	7e 8f                	jle    1be0 <bigdir+0x70>
      printf(1, "bigdir link failed\n");
      exit();
    }
  }

  unlink("bd");
    1c51:	c7 04 24 ac 4b 00 00 	movl   $0x4bac,(%esp)
    1c58:	e8 df 21 00 00       	call   3e3c <unlink>
  for(i = 0; i < 500; i++){
    1c5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1c64:	eb 60                	jmp    1cc6 <bigdir+0x156>
    name[0] = 'x';
    1c66:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    1c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1c6d:	8d 50 3f             	lea    0x3f(%eax),%edx
    1c70:	85 c0                	test   %eax,%eax
    1c72:	0f 48 c2             	cmovs  %edx,%eax
    1c75:	c1 f8 06             	sar    $0x6,%eax
    1c78:	83 c0 30             	add    $0x30,%eax
    1c7b:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    1c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1c81:	89 c2                	mov    %eax,%edx
    1c83:	c1 fa 1f             	sar    $0x1f,%edx
    1c86:	c1 ea 1a             	shr    $0x1a,%edx
    1c89:	01 d0                	add    %edx,%eax
    1c8b:	83 e0 3f             	and    $0x3f,%eax
    1c8e:	29 d0                	sub    %edx,%eax
    1c90:	83 c0 30             	add    $0x30,%eax
    1c93:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    1c96:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(unlink(name) != 0){
    1c9a:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    1c9d:	89 04 24             	mov    %eax,(%esp)
    1ca0:	e8 97 21 00 00       	call   3e3c <unlink>
    1ca5:	85 c0                	test   %eax,%eax
    1ca7:	74 19                	je     1cc2 <bigdir+0x152>
      printf(1, "bigdir unlink failed");
    1ca9:	c7 44 24 04 d9 4b 00 	movl   $0x4bd9,0x4(%esp)
    1cb0:	00 
    1cb1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1cb8:	e8 ac 22 00 00       	call   3f69 <printf>
      exit();
    1cbd:	e8 1a 21 00 00       	call   3ddc <exit>
      exit();
    }
  }

  unlink("bd");
  for(i = 0; i < 500; i++){
    1cc2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    1cc6:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    1ccd:	7e 97                	jle    1c66 <bigdir+0xf6>
      printf(1, "bigdir unlink failed");
      exit();
    }
  }

  printf(1, "bigdir ok\n");
    1ccf:	c7 44 24 04 ee 4b 00 	movl   $0x4bee,0x4(%esp)
    1cd6:	00 
    1cd7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1cde:	e8 86 22 00 00       	call   3f69 <printf>
}
    1ce3:	c9                   	leave  
    1ce4:	c3                   	ret    

00001ce5 <subdir>:

void
subdir(void)
{
    1ce5:	55                   	push   %ebp
    1ce6:	89 e5                	mov    %esp,%ebp
    1ce8:	83 ec 28             	sub    $0x28,%esp
  int fd, cc;

  printf(1, "subdir test\n");
    1ceb:	c7 44 24 04 f9 4b 00 	movl   $0x4bf9,0x4(%esp)
    1cf2:	00 
    1cf3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1cfa:	e8 6a 22 00 00       	call   3f69 <printf>

  unlink("ff");
    1cff:	c7 04 24 06 4c 00 00 	movl   $0x4c06,(%esp)
    1d06:	e8 31 21 00 00       	call   3e3c <unlink>
  if(mkdir("dd") != 0){
    1d0b:	c7 04 24 09 4c 00 00 	movl   $0x4c09,(%esp)
    1d12:	e8 3d 21 00 00       	call   3e54 <mkdir>
    1d17:	85 c0                	test   %eax,%eax
    1d19:	74 19                	je     1d34 <subdir+0x4f>
    printf(1, "subdir mkdir dd failed\n");
    1d1b:	c7 44 24 04 0c 4c 00 	movl   $0x4c0c,0x4(%esp)
    1d22:	00 
    1d23:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d2a:	e8 3a 22 00 00       	call   3f69 <printf>
    exit();
    1d2f:	e8 a8 20 00 00       	call   3ddc <exit>
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    1d34:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1d3b:	00 
    1d3c:	c7 04 24 24 4c 00 00 	movl   $0x4c24,(%esp)
    1d43:	e8 e4 20 00 00       	call   3e2c <open>
    1d48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1d4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1d4f:	79 19                	jns    1d6a <subdir+0x85>
    printf(1, "create dd/ff failed\n");
    1d51:	c7 44 24 04 2a 4c 00 	movl   $0x4c2a,0x4(%esp)
    1d58:	00 
    1d59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1d60:	e8 04 22 00 00       	call   3f69 <printf>
    exit();
    1d65:	e8 72 20 00 00       	call   3ddc <exit>
  }
  write(fd, "ff", 2);
    1d6a:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    1d71:	00 
    1d72:	c7 44 24 04 06 4c 00 	movl   $0x4c06,0x4(%esp)
    1d79:	00 
    1d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1d7d:	89 04 24             	mov    %eax,(%esp)
    1d80:	e8 87 20 00 00       	call   3e0c <write>
  close(fd);
    1d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1d88:	89 04 24             	mov    %eax,(%esp)
    1d8b:	e8 84 20 00 00       	call   3e14 <close>
  
  if(unlink("dd") >= 0){
    1d90:	c7 04 24 09 4c 00 00 	movl   $0x4c09,(%esp)
    1d97:	e8 a0 20 00 00       	call   3e3c <unlink>
    1d9c:	85 c0                	test   %eax,%eax
    1d9e:	78 19                	js     1db9 <subdir+0xd4>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    1da0:	c7 44 24 04 40 4c 00 	movl   $0x4c40,0x4(%esp)
    1da7:	00 
    1da8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1daf:	e8 b5 21 00 00       	call   3f69 <printf>
    exit();
    1db4:	e8 23 20 00 00       	call   3ddc <exit>
  }

  if(mkdir("/dd/dd") != 0){
    1db9:	c7 04 24 66 4c 00 00 	movl   $0x4c66,(%esp)
    1dc0:	e8 8f 20 00 00       	call   3e54 <mkdir>
    1dc5:	85 c0                	test   %eax,%eax
    1dc7:	74 19                	je     1de2 <subdir+0xfd>
    printf(1, "subdir mkdir dd/dd failed\n");
    1dc9:	c7 44 24 04 6d 4c 00 	movl   $0x4c6d,0x4(%esp)
    1dd0:	00 
    1dd1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1dd8:	e8 8c 21 00 00       	call   3f69 <printf>
    exit();
    1ddd:	e8 fa 1f 00 00       	call   3ddc <exit>
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    1de2:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1de9:	00 
    1dea:	c7 04 24 88 4c 00 00 	movl   $0x4c88,(%esp)
    1df1:	e8 36 20 00 00       	call   3e2c <open>
    1df6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1df9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1dfd:	79 19                	jns    1e18 <subdir+0x133>
    printf(1, "create dd/dd/ff failed\n");
    1dff:	c7 44 24 04 91 4c 00 	movl   $0x4c91,0x4(%esp)
    1e06:	00 
    1e07:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1e0e:	e8 56 21 00 00       	call   3f69 <printf>
    exit();
    1e13:	e8 c4 1f 00 00       	call   3ddc <exit>
  }
  write(fd, "FF", 2);
    1e18:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    1e1f:	00 
    1e20:	c7 44 24 04 a9 4c 00 	movl   $0x4ca9,0x4(%esp)
    1e27:	00 
    1e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1e2b:	89 04 24             	mov    %eax,(%esp)
    1e2e:	e8 d9 1f 00 00       	call   3e0c <write>
  close(fd);
    1e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1e36:	89 04 24             	mov    %eax,(%esp)
    1e39:	e8 d6 1f 00 00       	call   3e14 <close>

  fd = open("dd/dd/../ff", 0);
    1e3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1e45:	00 
    1e46:	c7 04 24 ac 4c 00 00 	movl   $0x4cac,(%esp)
    1e4d:	e8 da 1f 00 00       	call   3e2c <open>
    1e52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1e55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1e59:	79 19                	jns    1e74 <subdir+0x18f>
    printf(1, "open dd/dd/../ff failed\n");
    1e5b:	c7 44 24 04 b8 4c 00 	movl   $0x4cb8,0x4(%esp)
    1e62:	00 
    1e63:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1e6a:	e8 fa 20 00 00       	call   3f69 <printf>
    exit();
    1e6f:	e8 68 1f 00 00       	call   3ddc <exit>
  }
  cc = read(fd, buf, sizeof(buf));
    1e74:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    1e7b:	00 
    1e7c:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
    1e83:	00 
    1e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1e87:	89 04 24             	mov    %eax,(%esp)
    1e8a:	e8 75 1f 00 00       	call   3e04 <read>
    1e8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(cc != 2 || buf[0] != 'f'){
    1e92:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
    1e96:	75 0b                	jne    1ea3 <subdir+0x1be>
    1e98:	0f b6 05 00 89 00 00 	movzbl 0x8900,%eax
    1e9f:	3c 66                	cmp    $0x66,%al
    1ea1:	74 19                	je     1ebc <subdir+0x1d7>
    printf(1, "dd/dd/../ff wrong content\n");
    1ea3:	c7 44 24 04 d1 4c 00 	movl   $0x4cd1,0x4(%esp)
    1eaa:	00 
    1eab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1eb2:	e8 b2 20 00 00       	call   3f69 <printf>
    exit();
    1eb7:	e8 20 1f 00 00       	call   3ddc <exit>
  }
  close(fd);
    1ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1ebf:	89 04 24             	mov    %eax,(%esp)
    1ec2:	e8 4d 1f 00 00       	call   3e14 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    1ec7:	c7 44 24 04 ec 4c 00 	movl   $0x4cec,0x4(%esp)
    1ece:	00 
    1ecf:	c7 04 24 88 4c 00 00 	movl   $0x4c88,(%esp)
    1ed6:	e8 71 1f 00 00       	call   3e4c <link>
    1edb:	85 c0                	test   %eax,%eax
    1edd:	74 19                	je     1ef8 <subdir+0x213>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    1edf:	c7 44 24 04 f8 4c 00 	movl   $0x4cf8,0x4(%esp)
    1ee6:	00 
    1ee7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1eee:	e8 76 20 00 00       	call   3f69 <printf>
    exit();
    1ef3:	e8 e4 1e 00 00       	call   3ddc <exit>
  }

  if(unlink("dd/dd/ff") != 0){
    1ef8:	c7 04 24 88 4c 00 00 	movl   $0x4c88,(%esp)
    1eff:	e8 38 1f 00 00       	call   3e3c <unlink>
    1f04:	85 c0                	test   %eax,%eax
    1f06:	74 19                	je     1f21 <subdir+0x23c>
    printf(1, "unlink dd/dd/ff failed\n");
    1f08:	c7 44 24 04 19 4d 00 	movl   $0x4d19,0x4(%esp)
    1f0f:	00 
    1f10:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f17:	e8 4d 20 00 00       	call   3f69 <printf>
    exit();
    1f1c:	e8 bb 1e 00 00       	call   3ddc <exit>
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    1f21:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1f28:	00 
    1f29:	c7 04 24 88 4c 00 00 	movl   $0x4c88,(%esp)
    1f30:	e8 f7 1e 00 00       	call   3e2c <open>
    1f35:	85 c0                	test   %eax,%eax
    1f37:	78 19                	js     1f52 <subdir+0x26d>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    1f39:	c7 44 24 04 34 4d 00 	movl   $0x4d34,0x4(%esp)
    1f40:	00 
    1f41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f48:	e8 1c 20 00 00       	call   3f69 <printf>
    exit();
    1f4d:	e8 8a 1e 00 00       	call   3ddc <exit>
  }

  if(chdir("dd") != 0){
    1f52:	c7 04 24 09 4c 00 00 	movl   $0x4c09,(%esp)
    1f59:	e8 fe 1e 00 00       	call   3e5c <chdir>
    1f5e:	85 c0                	test   %eax,%eax
    1f60:	74 19                	je     1f7b <subdir+0x296>
    printf(1, "chdir dd failed\n");
    1f62:	c7 44 24 04 58 4d 00 	movl   $0x4d58,0x4(%esp)
    1f69:	00 
    1f6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f71:	e8 f3 1f 00 00       	call   3f69 <printf>
    exit();
    1f76:	e8 61 1e 00 00       	call   3ddc <exit>
  }
  if(chdir("dd/../../dd") != 0){
    1f7b:	c7 04 24 69 4d 00 00 	movl   $0x4d69,(%esp)
    1f82:	e8 d5 1e 00 00       	call   3e5c <chdir>
    1f87:	85 c0                	test   %eax,%eax
    1f89:	74 19                	je     1fa4 <subdir+0x2bf>
    printf(1, "chdir dd/../../dd failed\n");
    1f8b:	c7 44 24 04 75 4d 00 	movl   $0x4d75,0x4(%esp)
    1f92:	00 
    1f93:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f9a:	e8 ca 1f 00 00       	call   3f69 <printf>
    exit();
    1f9f:	e8 38 1e 00 00       	call   3ddc <exit>
  }
  if(chdir("dd/../../../dd") != 0){
    1fa4:	c7 04 24 8f 4d 00 00 	movl   $0x4d8f,(%esp)
    1fab:	e8 ac 1e 00 00       	call   3e5c <chdir>
    1fb0:	85 c0                	test   %eax,%eax
    1fb2:	74 19                	je     1fcd <subdir+0x2e8>
    printf(1, "chdir dd/../../dd failed\n");
    1fb4:	c7 44 24 04 75 4d 00 	movl   $0x4d75,0x4(%esp)
    1fbb:	00 
    1fbc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1fc3:	e8 a1 1f 00 00       	call   3f69 <printf>
    exit();
    1fc8:	e8 0f 1e 00 00       	call   3ddc <exit>
  }
  if(chdir("./..") != 0){
    1fcd:	c7 04 24 9e 4d 00 00 	movl   $0x4d9e,(%esp)
    1fd4:	e8 83 1e 00 00       	call   3e5c <chdir>
    1fd9:	85 c0                	test   %eax,%eax
    1fdb:	74 19                	je     1ff6 <subdir+0x311>
    printf(1, "chdir ./.. failed\n");
    1fdd:	c7 44 24 04 a3 4d 00 	movl   $0x4da3,0x4(%esp)
    1fe4:	00 
    1fe5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1fec:	e8 78 1f 00 00       	call   3f69 <printf>
    exit();
    1ff1:	e8 e6 1d 00 00       	call   3ddc <exit>
  }

  fd = open("dd/dd/ffff", 0);
    1ff6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1ffd:	00 
    1ffe:	c7 04 24 ec 4c 00 00 	movl   $0x4cec,(%esp)
    2005:	e8 22 1e 00 00       	call   3e2c <open>
    200a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    200d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2011:	79 19                	jns    202c <subdir+0x347>
    printf(1, "open dd/dd/ffff failed\n");
    2013:	c7 44 24 04 b6 4d 00 	movl   $0x4db6,0x4(%esp)
    201a:	00 
    201b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2022:	e8 42 1f 00 00       	call   3f69 <printf>
    exit();
    2027:	e8 b0 1d 00 00       	call   3ddc <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    202c:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    2033:	00 
    2034:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
    203b:	00 
    203c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    203f:	89 04 24             	mov    %eax,(%esp)
    2042:	e8 bd 1d 00 00       	call   3e04 <read>
    2047:	83 f8 02             	cmp    $0x2,%eax
    204a:	74 19                	je     2065 <subdir+0x380>
    printf(1, "read dd/dd/ffff wrong len\n");
    204c:	c7 44 24 04 ce 4d 00 	movl   $0x4dce,0x4(%esp)
    2053:	00 
    2054:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    205b:	e8 09 1f 00 00       	call   3f69 <printf>
    exit();
    2060:	e8 77 1d 00 00       	call   3ddc <exit>
  }
  close(fd);
    2065:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2068:	89 04 24             	mov    %eax,(%esp)
    206b:	e8 a4 1d 00 00       	call   3e14 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2070:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2077:	00 
    2078:	c7 04 24 88 4c 00 00 	movl   $0x4c88,(%esp)
    207f:	e8 a8 1d 00 00       	call   3e2c <open>
    2084:	85 c0                	test   %eax,%eax
    2086:	78 19                	js     20a1 <subdir+0x3bc>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    2088:	c7 44 24 04 ec 4d 00 	movl   $0x4dec,0x4(%esp)
    208f:	00 
    2090:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2097:	e8 cd 1e 00 00       	call   3f69 <printf>
    exit();
    209c:	e8 3b 1d 00 00       	call   3ddc <exit>
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    20a1:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    20a8:	00 
    20a9:	c7 04 24 11 4e 00 00 	movl   $0x4e11,(%esp)
    20b0:	e8 77 1d 00 00       	call   3e2c <open>
    20b5:	85 c0                	test   %eax,%eax
    20b7:	78 19                	js     20d2 <subdir+0x3ed>
    printf(1, "create dd/ff/ff succeeded!\n");
    20b9:	c7 44 24 04 1a 4e 00 	movl   $0x4e1a,0x4(%esp)
    20c0:	00 
    20c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    20c8:	e8 9c 1e 00 00       	call   3f69 <printf>
    exit();
    20cd:	e8 0a 1d 00 00       	call   3ddc <exit>
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    20d2:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    20d9:	00 
    20da:	c7 04 24 36 4e 00 00 	movl   $0x4e36,(%esp)
    20e1:	e8 46 1d 00 00       	call   3e2c <open>
    20e6:	85 c0                	test   %eax,%eax
    20e8:	78 19                	js     2103 <subdir+0x41e>
    printf(1, "create dd/xx/ff succeeded!\n");
    20ea:	c7 44 24 04 3f 4e 00 	movl   $0x4e3f,0x4(%esp)
    20f1:	00 
    20f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    20f9:	e8 6b 1e 00 00       	call   3f69 <printf>
    exit();
    20fe:	e8 d9 1c 00 00       	call   3ddc <exit>
  }
  if(open("dd", O_CREATE) >= 0){
    2103:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    210a:	00 
    210b:	c7 04 24 09 4c 00 00 	movl   $0x4c09,(%esp)
    2112:	e8 15 1d 00 00       	call   3e2c <open>
    2117:	85 c0                	test   %eax,%eax
    2119:	78 19                	js     2134 <subdir+0x44f>
    printf(1, "create dd succeeded!\n");
    211b:	c7 44 24 04 5b 4e 00 	movl   $0x4e5b,0x4(%esp)
    2122:	00 
    2123:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    212a:	e8 3a 1e 00 00       	call   3f69 <printf>
    exit();
    212f:	e8 a8 1c 00 00       	call   3ddc <exit>
  }
  if(open("dd", O_RDWR) >= 0){
    2134:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    213b:	00 
    213c:	c7 04 24 09 4c 00 00 	movl   $0x4c09,(%esp)
    2143:	e8 e4 1c 00 00       	call   3e2c <open>
    2148:	85 c0                	test   %eax,%eax
    214a:	78 19                	js     2165 <subdir+0x480>
    printf(1, "open dd rdwr succeeded!\n");
    214c:	c7 44 24 04 71 4e 00 	movl   $0x4e71,0x4(%esp)
    2153:	00 
    2154:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    215b:	e8 09 1e 00 00       	call   3f69 <printf>
    exit();
    2160:	e8 77 1c 00 00       	call   3ddc <exit>
  }
  if(open("dd", O_WRONLY) >= 0){
    2165:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
    216c:	00 
    216d:	c7 04 24 09 4c 00 00 	movl   $0x4c09,(%esp)
    2174:	e8 b3 1c 00 00       	call   3e2c <open>
    2179:	85 c0                	test   %eax,%eax
    217b:	78 19                	js     2196 <subdir+0x4b1>
    printf(1, "open dd wronly succeeded!\n");
    217d:	c7 44 24 04 8a 4e 00 	movl   $0x4e8a,0x4(%esp)
    2184:	00 
    2185:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    218c:	e8 d8 1d 00 00       	call   3f69 <printf>
    exit();
    2191:	e8 46 1c 00 00       	call   3ddc <exit>
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    2196:	c7 44 24 04 a5 4e 00 	movl   $0x4ea5,0x4(%esp)
    219d:	00 
    219e:	c7 04 24 11 4e 00 00 	movl   $0x4e11,(%esp)
    21a5:	e8 a2 1c 00 00       	call   3e4c <link>
    21aa:	85 c0                	test   %eax,%eax
    21ac:	75 19                	jne    21c7 <subdir+0x4e2>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    21ae:	c7 44 24 04 b0 4e 00 	movl   $0x4eb0,0x4(%esp)
    21b5:	00 
    21b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21bd:	e8 a7 1d 00 00       	call   3f69 <printf>
    exit();
    21c2:	e8 15 1c 00 00       	call   3ddc <exit>
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    21c7:	c7 44 24 04 a5 4e 00 	movl   $0x4ea5,0x4(%esp)
    21ce:	00 
    21cf:	c7 04 24 36 4e 00 00 	movl   $0x4e36,(%esp)
    21d6:	e8 71 1c 00 00       	call   3e4c <link>
    21db:	85 c0                	test   %eax,%eax
    21dd:	75 19                	jne    21f8 <subdir+0x513>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    21df:	c7 44 24 04 d4 4e 00 	movl   $0x4ed4,0x4(%esp)
    21e6:	00 
    21e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21ee:	e8 76 1d 00 00       	call   3f69 <printf>
    exit();
    21f3:	e8 e4 1b 00 00       	call   3ddc <exit>
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    21f8:	c7 44 24 04 ec 4c 00 	movl   $0x4cec,0x4(%esp)
    21ff:	00 
    2200:	c7 04 24 24 4c 00 00 	movl   $0x4c24,(%esp)
    2207:	e8 40 1c 00 00       	call   3e4c <link>
    220c:	85 c0                	test   %eax,%eax
    220e:	75 19                	jne    2229 <subdir+0x544>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    2210:	c7 44 24 04 f8 4e 00 	movl   $0x4ef8,0x4(%esp)
    2217:	00 
    2218:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    221f:	e8 45 1d 00 00       	call   3f69 <printf>
    exit();
    2224:	e8 b3 1b 00 00       	call   3ddc <exit>
  }
  if(mkdir("dd/ff/ff") == 0){
    2229:	c7 04 24 11 4e 00 00 	movl   $0x4e11,(%esp)
    2230:	e8 1f 1c 00 00       	call   3e54 <mkdir>
    2235:	85 c0                	test   %eax,%eax
    2237:	75 19                	jne    2252 <subdir+0x56d>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    2239:	c7 44 24 04 1a 4f 00 	movl   $0x4f1a,0x4(%esp)
    2240:	00 
    2241:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2248:	e8 1c 1d 00 00       	call   3f69 <printf>
    exit();
    224d:	e8 8a 1b 00 00       	call   3ddc <exit>
  }
  if(mkdir("dd/xx/ff") == 0){
    2252:	c7 04 24 36 4e 00 00 	movl   $0x4e36,(%esp)
    2259:	e8 f6 1b 00 00       	call   3e54 <mkdir>
    225e:	85 c0                	test   %eax,%eax
    2260:	75 19                	jne    227b <subdir+0x596>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    2262:	c7 44 24 04 35 4f 00 	movl   $0x4f35,0x4(%esp)
    2269:	00 
    226a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2271:	e8 f3 1c 00 00       	call   3f69 <printf>
    exit();
    2276:	e8 61 1b 00 00       	call   3ddc <exit>
  }
  if(mkdir("dd/dd/ffff") == 0){
    227b:	c7 04 24 ec 4c 00 00 	movl   $0x4cec,(%esp)
    2282:	e8 cd 1b 00 00       	call   3e54 <mkdir>
    2287:	85 c0                	test   %eax,%eax
    2289:	75 19                	jne    22a4 <subdir+0x5bf>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    228b:	c7 44 24 04 50 4f 00 	movl   $0x4f50,0x4(%esp)
    2292:	00 
    2293:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    229a:	e8 ca 1c 00 00       	call   3f69 <printf>
    exit();
    229f:	e8 38 1b 00 00       	call   3ddc <exit>
  }
  if(unlink("dd/xx/ff") == 0){
    22a4:	c7 04 24 36 4e 00 00 	movl   $0x4e36,(%esp)
    22ab:	e8 8c 1b 00 00       	call   3e3c <unlink>
    22b0:	85 c0                	test   %eax,%eax
    22b2:	75 19                	jne    22cd <subdir+0x5e8>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    22b4:	c7 44 24 04 6d 4f 00 	movl   $0x4f6d,0x4(%esp)
    22bb:	00 
    22bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22c3:	e8 a1 1c 00 00       	call   3f69 <printf>
    exit();
    22c8:	e8 0f 1b 00 00       	call   3ddc <exit>
  }
  if(unlink("dd/ff/ff") == 0){
    22cd:	c7 04 24 11 4e 00 00 	movl   $0x4e11,(%esp)
    22d4:	e8 63 1b 00 00       	call   3e3c <unlink>
    22d9:	85 c0                	test   %eax,%eax
    22db:	75 19                	jne    22f6 <subdir+0x611>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    22dd:	c7 44 24 04 89 4f 00 	movl   $0x4f89,0x4(%esp)
    22e4:	00 
    22e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22ec:	e8 78 1c 00 00       	call   3f69 <printf>
    exit();
    22f1:	e8 e6 1a 00 00       	call   3ddc <exit>
  }
  if(chdir("dd/ff") == 0){
    22f6:	c7 04 24 24 4c 00 00 	movl   $0x4c24,(%esp)
    22fd:	e8 5a 1b 00 00       	call   3e5c <chdir>
    2302:	85 c0                	test   %eax,%eax
    2304:	75 19                	jne    231f <subdir+0x63a>
    printf(1, "chdir dd/ff succeeded!\n");
    2306:	c7 44 24 04 a5 4f 00 	movl   $0x4fa5,0x4(%esp)
    230d:	00 
    230e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2315:	e8 4f 1c 00 00       	call   3f69 <printf>
    exit();
    231a:	e8 bd 1a 00 00       	call   3ddc <exit>
  }
  if(chdir("dd/xx") == 0){
    231f:	c7 04 24 bd 4f 00 00 	movl   $0x4fbd,(%esp)
    2326:	e8 31 1b 00 00       	call   3e5c <chdir>
    232b:	85 c0                	test   %eax,%eax
    232d:	75 19                	jne    2348 <subdir+0x663>
    printf(1, "chdir dd/xx succeeded!\n");
    232f:	c7 44 24 04 c3 4f 00 	movl   $0x4fc3,0x4(%esp)
    2336:	00 
    2337:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    233e:	e8 26 1c 00 00       	call   3f69 <printf>
    exit();
    2343:	e8 94 1a 00 00       	call   3ddc <exit>
  }

  if(unlink("dd/dd/ffff") != 0){
    2348:	c7 04 24 ec 4c 00 00 	movl   $0x4cec,(%esp)
    234f:	e8 e8 1a 00 00       	call   3e3c <unlink>
    2354:	85 c0                	test   %eax,%eax
    2356:	74 19                	je     2371 <subdir+0x68c>
    printf(1, "unlink dd/dd/ff failed\n");
    2358:	c7 44 24 04 19 4d 00 	movl   $0x4d19,0x4(%esp)
    235f:	00 
    2360:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2367:	e8 fd 1b 00 00       	call   3f69 <printf>
    exit();
    236c:	e8 6b 1a 00 00       	call   3ddc <exit>
  }
  if(unlink("dd/ff") != 0){
    2371:	c7 04 24 24 4c 00 00 	movl   $0x4c24,(%esp)
    2378:	e8 bf 1a 00 00       	call   3e3c <unlink>
    237d:	85 c0                	test   %eax,%eax
    237f:	74 19                	je     239a <subdir+0x6b5>
    printf(1, "unlink dd/ff failed\n");
    2381:	c7 44 24 04 db 4f 00 	movl   $0x4fdb,0x4(%esp)
    2388:	00 
    2389:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2390:	e8 d4 1b 00 00       	call   3f69 <printf>
    exit();
    2395:	e8 42 1a 00 00       	call   3ddc <exit>
  }
  if(unlink("dd") == 0){
    239a:	c7 04 24 09 4c 00 00 	movl   $0x4c09,(%esp)
    23a1:	e8 96 1a 00 00       	call   3e3c <unlink>
    23a6:	85 c0                	test   %eax,%eax
    23a8:	75 19                	jne    23c3 <subdir+0x6de>
    printf(1, "unlink non-empty dd succeeded!\n");
    23aa:	c7 44 24 04 f0 4f 00 	movl   $0x4ff0,0x4(%esp)
    23b1:	00 
    23b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23b9:	e8 ab 1b 00 00       	call   3f69 <printf>
    exit();
    23be:	e8 19 1a 00 00       	call   3ddc <exit>
  }
  if(unlink("dd/dd") < 0){
    23c3:	c7 04 24 10 50 00 00 	movl   $0x5010,(%esp)
    23ca:	e8 6d 1a 00 00       	call   3e3c <unlink>
    23cf:	85 c0                	test   %eax,%eax
    23d1:	79 19                	jns    23ec <subdir+0x707>
    printf(1, "unlink dd/dd failed\n");
    23d3:	c7 44 24 04 16 50 00 	movl   $0x5016,0x4(%esp)
    23da:	00 
    23db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23e2:	e8 82 1b 00 00       	call   3f69 <printf>
    exit();
    23e7:	e8 f0 19 00 00       	call   3ddc <exit>
  }
  if(unlink("dd") < 0){
    23ec:	c7 04 24 09 4c 00 00 	movl   $0x4c09,(%esp)
    23f3:	e8 44 1a 00 00       	call   3e3c <unlink>
    23f8:	85 c0                	test   %eax,%eax
    23fa:	79 19                	jns    2415 <subdir+0x730>
    printf(1, "unlink dd failed\n");
    23fc:	c7 44 24 04 2b 50 00 	movl   $0x502b,0x4(%esp)
    2403:	00 
    2404:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    240b:	e8 59 1b 00 00       	call   3f69 <printf>
    exit();
    2410:	e8 c7 19 00 00       	call   3ddc <exit>
  }

  printf(1, "subdir ok\n");
    2415:	c7 44 24 04 3d 50 00 	movl   $0x503d,0x4(%esp)
    241c:	00 
    241d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2424:	e8 40 1b 00 00       	call   3f69 <printf>
}
    2429:	c9                   	leave  
    242a:	c3                   	ret    

0000242b <bigwrite>:

// test writes that are larger than the log.
void
bigwrite(void)
{
    242b:	55                   	push   %ebp
    242c:	89 e5                	mov    %esp,%ebp
    242e:	83 ec 28             	sub    $0x28,%esp
  int fd, sz;

  printf(1, "bigwrite test\n");
    2431:	c7 44 24 04 48 50 00 	movl   $0x5048,0x4(%esp)
    2438:	00 
    2439:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2440:	e8 24 1b 00 00       	call   3f69 <printf>

  unlink("bigwrite");
    2445:	c7 04 24 57 50 00 00 	movl   $0x5057,(%esp)
    244c:	e8 eb 19 00 00       	call   3e3c <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    2451:	c7 45 f4 f3 01 00 00 	movl   $0x1f3,-0xc(%ebp)
    2458:	e9 b3 00 00 00       	jmp    2510 <bigwrite+0xe5>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    245d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2464:	00 
    2465:	c7 04 24 57 50 00 00 	movl   $0x5057,(%esp)
    246c:	e8 bb 19 00 00       	call   3e2c <open>
    2471:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fd < 0){
    2474:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2478:	79 19                	jns    2493 <bigwrite+0x68>
      printf(1, "cannot create bigwrite\n");
    247a:	c7 44 24 04 60 50 00 	movl   $0x5060,0x4(%esp)
    2481:	00 
    2482:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2489:	e8 db 1a 00 00       	call   3f69 <printf>
      exit();
    248e:	e8 49 19 00 00       	call   3ddc <exit>
    }
    int i;
    for(i = 0; i < 2; i++){
    2493:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    249a:	eb 50                	jmp    24ec <bigwrite+0xc1>
      int cc = write(fd, buf, sz);
    249c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    249f:	89 44 24 08          	mov    %eax,0x8(%esp)
    24a3:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
    24aa:	00 
    24ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
    24ae:	89 04 24             	mov    %eax,(%esp)
    24b1:	e8 56 19 00 00       	call   3e0c <write>
    24b6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(cc != sz){
    24b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
    24bc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    24bf:	74 27                	je     24e8 <bigwrite+0xbd>
        printf(1, "write(%d) ret %d\n", sz, cc);
    24c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    24c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
    24c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    24cb:	89 44 24 08          	mov    %eax,0x8(%esp)
    24cf:	c7 44 24 04 78 50 00 	movl   $0x5078,0x4(%esp)
    24d6:	00 
    24d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24de:	e8 86 1a 00 00       	call   3f69 <printf>
        exit();
    24e3:	e8 f4 18 00 00       	call   3ddc <exit>
    if(fd < 0){
      printf(1, "cannot create bigwrite\n");
      exit();
    }
    int i;
    for(i = 0; i < 2; i++){
    24e8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    24ec:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
    24f0:	7e aa                	jle    249c <bigwrite+0x71>
      if(cc != sz){
        printf(1, "write(%d) ret %d\n", sz, cc);
        exit();
      }
    }
    close(fd);
    24f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
    24f5:	89 04 24             	mov    %eax,(%esp)
    24f8:	e8 17 19 00 00       	call   3e14 <close>
    unlink("bigwrite");
    24fd:	c7 04 24 57 50 00 00 	movl   $0x5057,(%esp)
    2504:	e8 33 19 00 00       	call   3e3c <unlink>
  int fd, sz;

  printf(1, "bigwrite test\n");

  unlink("bigwrite");
  for(sz = 499; sz < 12*512; sz += 471){
    2509:	81 45 f4 d7 01 00 00 	addl   $0x1d7,-0xc(%ebp)
    2510:	81 7d f4 ff 17 00 00 	cmpl   $0x17ff,-0xc(%ebp)
    2517:	0f 8e 40 ff ff ff    	jle    245d <bigwrite+0x32>
    }
    close(fd);
    unlink("bigwrite");
  }

  printf(1, "bigwrite ok\n");
    251d:	c7 44 24 04 8a 50 00 	movl   $0x508a,0x4(%esp)
    2524:	00 
    2525:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    252c:	e8 38 1a 00 00       	call   3f69 <printf>
}
    2531:	c9                   	leave  
    2532:	c3                   	ret    

00002533 <bigfile>:

void
bigfile(void)
{
    2533:	55                   	push   %ebp
    2534:	89 e5                	mov    %esp,%ebp
    2536:	83 ec 28             	sub    $0x28,%esp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    2539:	c7 44 24 04 97 50 00 	movl   $0x5097,0x4(%esp)
    2540:	00 
    2541:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2548:	e8 1c 1a 00 00       	call   3f69 <printf>

  unlink("bigfile");
    254d:	c7 04 24 a5 50 00 00 	movl   $0x50a5,(%esp)
    2554:	e8 e3 18 00 00       	call   3e3c <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    2559:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2560:	00 
    2561:	c7 04 24 a5 50 00 00 	movl   $0x50a5,(%esp)
    2568:	e8 bf 18 00 00       	call   3e2c <open>
    256d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    2570:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    2574:	79 19                	jns    258f <bigfile+0x5c>
    printf(1, "cannot create bigfile");
    2576:	c7 44 24 04 ad 50 00 	movl   $0x50ad,0x4(%esp)
    257d:	00 
    257e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2585:	e8 df 19 00 00       	call   3f69 <printf>
    exit();
    258a:	e8 4d 18 00 00       	call   3ddc <exit>
  }
  for(i = 0; i < 20; i++){
    258f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2596:	eb 5a                	jmp    25f2 <bigfile+0xbf>
    memset(buf, i, 600);
    2598:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    259f:	00 
    25a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    25a3:	89 44 24 04          	mov    %eax,0x4(%esp)
    25a7:	c7 04 24 00 89 00 00 	movl   $0x8900,(%esp)
    25ae:	e8 e2 14 00 00       	call   3a95 <memset>
    if(write(fd, buf, 600) != 600){
    25b3:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    25ba:	00 
    25bb:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
    25c2:	00 
    25c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    25c6:	89 04 24             	mov    %eax,(%esp)
    25c9:	e8 3e 18 00 00       	call   3e0c <write>
    25ce:	3d 58 02 00 00       	cmp    $0x258,%eax
    25d3:	74 19                	je     25ee <bigfile+0xbb>
      printf(1, "write bigfile failed\n");
    25d5:	c7 44 24 04 c3 50 00 	movl   $0x50c3,0x4(%esp)
    25dc:	00 
    25dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25e4:	e8 80 19 00 00       	call   3f69 <printf>
      exit();
    25e9:	e8 ee 17 00 00       	call   3ddc <exit>
  fd = open("bigfile", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "cannot create bigfile");
    exit();
  }
  for(i = 0; i < 20; i++){
    25ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    25f2:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    25f6:	7e a0                	jle    2598 <bigfile+0x65>
    if(write(fd, buf, 600) != 600){
      printf(1, "write bigfile failed\n");
      exit();
    }
  }
  close(fd);
    25f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
    25fb:	89 04 24             	mov    %eax,(%esp)
    25fe:	e8 11 18 00 00       	call   3e14 <close>

  fd = open("bigfile", 0);
    2603:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    260a:	00 
    260b:	c7 04 24 a5 50 00 00 	movl   $0x50a5,(%esp)
    2612:	e8 15 18 00 00       	call   3e2c <open>
    2617:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    261a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    261e:	79 19                	jns    2639 <bigfile+0x106>
    printf(1, "cannot open bigfile\n");
    2620:	c7 44 24 04 d9 50 00 	movl   $0x50d9,0x4(%esp)
    2627:	00 
    2628:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    262f:	e8 35 19 00 00       	call   3f69 <printf>
    exit();
    2634:	e8 a3 17 00 00       	call   3ddc <exit>
  }
  total = 0;
    2639:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(i = 0; ; i++){
    2640:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    cc = read(fd, buf, 300);
    2647:	c7 44 24 08 2c 01 00 	movl   $0x12c,0x8(%esp)
    264e:	00 
    264f:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
    2656:	00 
    2657:	8b 45 ec             	mov    -0x14(%ebp),%eax
    265a:	89 04 24             	mov    %eax,(%esp)
    265d:	e8 a2 17 00 00       	call   3e04 <read>
    2662:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(cc < 0){
    2665:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2669:	79 19                	jns    2684 <bigfile+0x151>
      printf(1, "read bigfile failed\n");
    266b:	c7 44 24 04 ee 50 00 	movl   $0x50ee,0x4(%esp)
    2672:	00 
    2673:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    267a:	e8 ea 18 00 00       	call   3f69 <printf>
      exit();
    267f:	e8 58 17 00 00       	call   3ddc <exit>
    }
    if(cc == 0)
    2684:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2688:	74 7e                	je     2708 <bigfile+0x1d5>
      break;
    if(cc != 300){
    268a:	81 7d e8 2c 01 00 00 	cmpl   $0x12c,-0x18(%ebp)
    2691:	74 19                	je     26ac <bigfile+0x179>
      printf(1, "short read bigfile\n");
    2693:	c7 44 24 04 03 51 00 	movl   $0x5103,0x4(%esp)
    269a:	00 
    269b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26a2:	e8 c2 18 00 00       	call   3f69 <printf>
      exit();
    26a7:	e8 30 17 00 00       	call   3ddc <exit>
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    26ac:	0f b6 05 00 89 00 00 	movzbl 0x8900,%eax
    26b3:	0f be d0             	movsbl %al,%edx
    26b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    26b9:	89 c1                	mov    %eax,%ecx
    26bb:	c1 e9 1f             	shr    $0x1f,%ecx
    26be:	01 c8                	add    %ecx,%eax
    26c0:	d1 f8                	sar    %eax
    26c2:	39 c2                	cmp    %eax,%edx
    26c4:	75 1a                	jne    26e0 <bigfile+0x1ad>
    26c6:	0f b6 05 2b 8a 00 00 	movzbl 0x8a2b,%eax
    26cd:	0f be d0             	movsbl %al,%edx
    26d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    26d3:	89 c1                	mov    %eax,%ecx
    26d5:	c1 e9 1f             	shr    $0x1f,%ecx
    26d8:	01 c8                	add    %ecx,%eax
    26da:	d1 f8                	sar    %eax
    26dc:	39 c2                	cmp    %eax,%edx
    26de:	74 19                	je     26f9 <bigfile+0x1c6>
      printf(1, "read bigfile wrong data\n");
    26e0:	c7 44 24 04 17 51 00 	movl   $0x5117,0x4(%esp)
    26e7:	00 
    26e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26ef:	e8 75 18 00 00       	call   3f69 <printf>
      exit();
    26f4:	e8 e3 16 00 00       	call   3ddc <exit>
    }
    total += cc;
    26f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
    26fc:	01 45 f0             	add    %eax,-0x10(%ebp)
  if(fd < 0){
    printf(1, "cannot open bigfile\n");
    exit();
  }
  total = 0;
  for(i = 0; ; i++){
    26ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(buf[0] != i/2 || buf[299] != i/2){
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
    2703:	e9 3f ff ff ff       	jmp    2647 <bigfile+0x114>
    if(cc < 0){
      printf(1, "read bigfile failed\n");
      exit();
    }
    if(cc == 0)
      break;
    2708:	90                   	nop
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
  close(fd);
    2709:	8b 45 ec             	mov    -0x14(%ebp),%eax
    270c:	89 04 24             	mov    %eax,(%esp)
    270f:	e8 00 17 00 00       	call   3e14 <close>
  if(total != 20*600){
    2714:	81 7d f0 e0 2e 00 00 	cmpl   $0x2ee0,-0x10(%ebp)
    271b:	74 19                	je     2736 <bigfile+0x203>
    printf(1, "read bigfile wrong total\n");
    271d:	c7 44 24 04 30 51 00 	movl   $0x5130,0x4(%esp)
    2724:	00 
    2725:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    272c:	e8 38 18 00 00       	call   3f69 <printf>
    exit();
    2731:	e8 a6 16 00 00       	call   3ddc <exit>
  }
  unlink("bigfile");
    2736:	c7 04 24 a5 50 00 00 	movl   $0x50a5,(%esp)
    273d:	e8 fa 16 00 00       	call   3e3c <unlink>

  printf(1, "bigfile test ok\n");
    2742:	c7 44 24 04 4a 51 00 	movl   $0x514a,0x4(%esp)
    2749:	00 
    274a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2751:	e8 13 18 00 00       	call   3f69 <printf>
}
    2756:	c9                   	leave  
    2757:	c3                   	ret    

00002758 <fourteen>:

void
fourteen(void)
{
    2758:	55                   	push   %ebp
    2759:	89 e5                	mov    %esp,%ebp
    275b:	83 ec 28             	sub    $0x28,%esp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
    275e:	c7 44 24 04 5b 51 00 	movl   $0x515b,0x4(%esp)
    2765:	00 
    2766:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    276d:	e8 f7 17 00 00       	call   3f69 <printf>

  if(mkdir("12345678901234") != 0){
    2772:	c7 04 24 6a 51 00 00 	movl   $0x516a,(%esp)
    2779:	e8 d6 16 00 00       	call   3e54 <mkdir>
    277e:	85 c0                	test   %eax,%eax
    2780:	74 19                	je     279b <fourteen+0x43>
    printf(1, "mkdir 12345678901234 failed\n");
    2782:	c7 44 24 04 79 51 00 	movl   $0x5179,0x4(%esp)
    2789:	00 
    278a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2791:	e8 d3 17 00 00       	call   3f69 <printf>
    exit();
    2796:	e8 41 16 00 00       	call   3ddc <exit>
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    279b:	c7 04 24 98 51 00 00 	movl   $0x5198,(%esp)
    27a2:	e8 ad 16 00 00       	call   3e54 <mkdir>
    27a7:	85 c0                	test   %eax,%eax
    27a9:	74 19                	je     27c4 <fourteen+0x6c>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    27ab:	c7 44 24 04 b8 51 00 	movl   $0x51b8,0x4(%esp)
    27b2:	00 
    27b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27ba:	e8 aa 17 00 00       	call   3f69 <printf>
    exit();
    27bf:	e8 18 16 00 00       	call   3ddc <exit>
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    27c4:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    27cb:	00 
    27cc:	c7 04 24 e8 51 00 00 	movl   $0x51e8,(%esp)
    27d3:	e8 54 16 00 00       	call   3e2c <open>
    27d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    27db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    27df:	79 19                	jns    27fa <fourteen+0xa2>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    27e1:	c7 44 24 04 18 52 00 	movl   $0x5218,0x4(%esp)
    27e8:	00 
    27e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27f0:	e8 74 17 00 00       	call   3f69 <printf>
    exit();
    27f5:	e8 e2 15 00 00       	call   3ddc <exit>
  }
  close(fd);
    27fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
    27fd:	89 04 24             	mov    %eax,(%esp)
    2800:	e8 0f 16 00 00       	call   3e14 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2805:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    280c:	00 
    280d:	c7 04 24 58 52 00 00 	movl   $0x5258,(%esp)
    2814:	e8 13 16 00 00       	call   3e2c <open>
    2819:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    281c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2820:	79 19                	jns    283b <fourteen+0xe3>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    2822:	c7 44 24 04 88 52 00 	movl   $0x5288,0x4(%esp)
    2829:	00 
    282a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2831:	e8 33 17 00 00       	call   3f69 <printf>
    exit();
    2836:	e8 a1 15 00 00       	call   3ddc <exit>
  }
  close(fd);
    283b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    283e:	89 04 24             	mov    %eax,(%esp)
    2841:	e8 ce 15 00 00       	call   3e14 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
    2846:	c7 04 24 c2 52 00 00 	movl   $0x52c2,(%esp)
    284d:	e8 02 16 00 00       	call   3e54 <mkdir>
    2852:	85 c0                	test   %eax,%eax
    2854:	75 19                	jne    286f <fourteen+0x117>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    2856:	c7 44 24 04 e0 52 00 	movl   $0x52e0,0x4(%esp)
    285d:	00 
    285e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2865:	e8 ff 16 00 00       	call   3f69 <printf>
    exit();
    286a:	e8 6d 15 00 00       	call   3ddc <exit>
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    286f:	c7 04 24 10 53 00 00 	movl   $0x5310,(%esp)
    2876:	e8 d9 15 00 00       	call   3e54 <mkdir>
    287b:	85 c0                	test   %eax,%eax
    287d:	75 19                	jne    2898 <fourteen+0x140>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    287f:	c7 44 24 04 30 53 00 	movl   $0x5330,0x4(%esp)
    2886:	00 
    2887:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    288e:	e8 d6 16 00 00       	call   3f69 <printf>
    exit();
    2893:	e8 44 15 00 00       	call   3ddc <exit>
  }

  printf(1, "fourteen ok\n");
    2898:	c7 44 24 04 61 53 00 	movl   $0x5361,0x4(%esp)
    289f:	00 
    28a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28a7:	e8 bd 16 00 00       	call   3f69 <printf>
}
    28ac:	c9                   	leave  
    28ad:	c3                   	ret    

000028ae <rmdot>:

void
rmdot(void)
{
    28ae:	55                   	push   %ebp
    28af:	89 e5                	mov    %esp,%ebp
    28b1:	83 ec 18             	sub    $0x18,%esp
  printf(1, "rmdot test\n");
    28b4:	c7 44 24 04 6e 53 00 	movl   $0x536e,0x4(%esp)
    28bb:	00 
    28bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28c3:	e8 a1 16 00 00       	call   3f69 <printf>
  if(mkdir("dots") != 0){
    28c8:	c7 04 24 7a 53 00 00 	movl   $0x537a,(%esp)
    28cf:	e8 80 15 00 00       	call   3e54 <mkdir>
    28d4:	85 c0                	test   %eax,%eax
    28d6:	74 19                	je     28f1 <rmdot+0x43>
    printf(1, "mkdir dots failed\n");
    28d8:	c7 44 24 04 7f 53 00 	movl   $0x537f,0x4(%esp)
    28df:	00 
    28e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28e7:	e8 7d 16 00 00       	call   3f69 <printf>
    exit();
    28ec:	e8 eb 14 00 00       	call   3ddc <exit>
  }
  if(chdir("dots") != 0){
    28f1:	c7 04 24 7a 53 00 00 	movl   $0x537a,(%esp)
    28f8:	e8 5f 15 00 00       	call   3e5c <chdir>
    28fd:	85 c0                	test   %eax,%eax
    28ff:	74 19                	je     291a <rmdot+0x6c>
    printf(1, "chdir dots failed\n");
    2901:	c7 44 24 04 92 53 00 	movl   $0x5392,0x4(%esp)
    2908:	00 
    2909:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2910:	e8 54 16 00 00       	call   3f69 <printf>
    exit();
    2915:	e8 c2 14 00 00       	call   3ddc <exit>
  }
  if(unlink(".") == 0){
    291a:	c7 04 24 ab 4a 00 00 	movl   $0x4aab,(%esp)
    2921:	e8 16 15 00 00       	call   3e3c <unlink>
    2926:	85 c0                	test   %eax,%eax
    2928:	75 19                	jne    2943 <rmdot+0x95>
    printf(1, "rm . worked!\n");
    292a:	c7 44 24 04 a5 53 00 	movl   $0x53a5,0x4(%esp)
    2931:	00 
    2932:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2939:	e8 2b 16 00 00       	call   3f69 <printf>
    exit();
    293e:	e8 99 14 00 00       	call   3ddc <exit>
  }
  if(unlink("..") == 0){
    2943:	c7 04 24 38 46 00 00 	movl   $0x4638,(%esp)
    294a:	e8 ed 14 00 00       	call   3e3c <unlink>
    294f:	85 c0                	test   %eax,%eax
    2951:	75 19                	jne    296c <rmdot+0xbe>
    printf(1, "rm .. worked!\n");
    2953:	c7 44 24 04 b3 53 00 	movl   $0x53b3,0x4(%esp)
    295a:	00 
    295b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2962:	e8 02 16 00 00       	call   3f69 <printf>
    exit();
    2967:	e8 70 14 00 00       	call   3ddc <exit>
  }
  if(chdir("/") != 0){
    296c:	c7 04 24 c2 53 00 00 	movl   $0x53c2,(%esp)
    2973:	e8 e4 14 00 00       	call   3e5c <chdir>
    2978:	85 c0                	test   %eax,%eax
    297a:	74 19                	je     2995 <rmdot+0xe7>
    printf(1, "chdir / failed\n");
    297c:	c7 44 24 04 c4 53 00 	movl   $0x53c4,0x4(%esp)
    2983:	00 
    2984:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    298b:	e8 d9 15 00 00       	call   3f69 <printf>
    exit();
    2990:	e8 47 14 00 00       	call   3ddc <exit>
  }
  if(unlink("dots/.") == 0){
    2995:	c7 04 24 d4 53 00 00 	movl   $0x53d4,(%esp)
    299c:	e8 9b 14 00 00       	call   3e3c <unlink>
    29a1:	85 c0                	test   %eax,%eax
    29a3:	75 19                	jne    29be <rmdot+0x110>
    printf(1, "unlink dots/. worked!\n");
    29a5:	c7 44 24 04 db 53 00 	movl   $0x53db,0x4(%esp)
    29ac:	00 
    29ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29b4:	e8 b0 15 00 00       	call   3f69 <printf>
    exit();
    29b9:	e8 1e 14 00 00       	call   3ddc <exit>
  }
  if(unlink("dots/..") == 0){
    29be:	c7 04 24 f2 53 00 00 	movl   $0x53f2,(%esp)
    29c5:	e8 72 14 00 00       	call   3e3c <unlink>
    29ca:	85 c0                	test   %eax,%eax
    29cc:	75 19                	jne    29e7 <rmdot+0x139>
    printf(1, "unlink dots/.. worked!\n");
    29ce:	c7 44 24 04 fa 53 00 	movl   $0x53fa,0x4(%esp)
    29d5:	00 
    29d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29dd:	e8 87 15 00 00       	call   3f69 <printf>
    exit();
    29e2:	e8 f5 13 00 00       	call   3ddc <exit>
  }
  if(unlink("dots") != 0){
    29e7:	c7 04 24 7a 53 00 00 	movl   $0x537a,(%esp)
    29ee:	e8 49 14 00 00       	call   3e3c <unlink>
    29f3:	85 c0                	test   %eax,%eax
    29f5:	74 19                	je     2a10 <rmdot+0x162>
    printf(1, "unlink dots failed!\n");
    29f7:	c7 44 24 04 12 54 00 	movl   $0x5412,0x4(%esp)
    29fe:	00 
    29ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a06:	e8 5e 15 00 00       	call   3f69 <printf>
    exit();
    2a0b:	e8 cc 13 00 00       	call   3ddc <exit>
  }
  printf(1, "rmdot ok\n");
    2a10:	c7 44 24 04 27 54 00 	movl   $0x5427,0x4(%esp)
    2a17:	00 
    2a18:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a1f:	e8 45 15 00 00       	call   3f69 <printf>
}
    2a24:	c9                   	leave  
    2a25:	c3                   	ret    

00002a26 <dirfile>:

void
dirfile(void)
{
    2a26:	55                   	push   %ebp
    2a27:	89 e5                	mov    %esp,%ebp
    2a29:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "dir vs file\n");
    2a2c:	c7 44 24 04 31 54 00 	movl   $0x5431,0x4(%esp)
    2a33:	00 
    2a34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a3b:	e8 29 15 00 00       	call   3f69 <printf>

  fd = open("dirfile", O_CREATE);
    2a40:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2a47:	00 
    2a48:	c7 04 24 3e 54 00 00 	movl   $0x543e,(%esp)
    2a4f:	e8 d8 13 00 00       	call   3e2c <open>
    2a54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2a57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2a5b:	79 19                	jns    2a76 <dirfile+0x50>
    printf(1, "create dirfile failed\n");
    2a5d:	c7 44 24 04 46 54 00 	movl   $0x5446,0x4(%esp)
    2a64:	00 
    2a65:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a6c:	e8 f8 14 00 00       	call   3f69 <printf>
    exit();
    2a71:	e8 66 13 00 00       	call   3ddc <exit>
  }
  close(fd);
    2a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2a79:	89 04 24             	mov    %eax,(%esp)
    2a7c:	e8 93 13 00 00       	call   3e14 <close>
  if(chdir("dirfile") == 0){
    2a81:	c7 04 24 3e 54 00 00 	movl   $0x543e,(%esp)
    2a88:	e8 cf 13 00 00       	call   3e5c <chdir>
    2a8d:	85 c0                	test   %eax,%eax
    2a8f:	75 19                	jne    2aaa <dirfile+0x84>
    printf(1, "chdir dirfile succeeded!\n");
    2a91:	c7 44 24 04 5d 54 00 	movl   $0x545d,0x4(%esp)
    2a98:	00 
    2a99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2aa0:	e8 c4 14 00 00       	call   3f69 <printf>
    exit();
    2aa5:	e8 32 13 00 00       	call   3ddc <exit>
  }
  fd = open("dirfile/xx", 0);
    2aaa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2ab1:	00 
    2ab2:	c7 04 24 77 54 00 00 	movl   $0x5477,(%esp)
    2ab9:	e8 6e 13 00 00       	call   3e2c <open>
    2abe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2ac1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2ac5:	78 19                	js     2ae0 <dirfile+0xba>
    printf(1, "create dirfile/xx succeeded!\n");
    2ac7:	c7 44 24 04 82 54 00 	movl   $0x5482,0x4(%esp)
    2ace:	00 
    2acf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ad6:	e8 8e 14 00 00       	call   3f69 <printf>
    exit();
    2adb:	e8 fc 12 00 00       	call   3ddc <exit>
  }
  fd = open("dirfile/xx", O_CREATE);
    2ae0:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2ae7:	00 
    2ae8:	c7 04 24 77 54 00 00 	movl   $0x5477,(%esp)
    2aef:	e8 38 13 00 00       	call   3e2c <open>
    2af4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2af7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2afb:	78 19                	js     2b16 <dirfile+0xf0>
    printf(1, "create dirfile/xx succeeded!\n");
    2afd:	c7 44 24 04 82 54 00 	movl   $0x5482,0x4(%esp)
    2b04:	00 
    2b05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b0c:	e8 58 14 00 00       	call   3f69 <printf>
    exit();
    2b11:	e8 c6 12 00 00       	call   3ddc <exit>
  }
  if(mkdir("dirfile/xx") == 0){
    2b16:	c7 04 24 77 54 00 00 	movl   $0x5477,(%esp)
    2b1d:	e8 32 13 00 00       	call   3e54 <mkdir>
    2b22:	85 c0                	test   %eax,%eax
    2b24:	75 19                	jne    2b3f <dirfile+0x119>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    2b26:	c7 44 24 04 a0 54 00 	movl   $0x54a0,0x4(%esp)
    2b2d:	00 
    2b2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b35:	e8 2f 14 00 00       	call   3f69 <printf>
    exit();
    2b3a:	e8 9d 12 00 00       	call   3ddc <exit>
  }
  if(unlink("dirfile/xx") == 0){
    2b3f:	c7 04 24 77 54 00 00 	movl   $0x5477,(%esp)
    2b46:	e8 f1 12 00 00       	call   3e3c <unlink>
    2b4b:	85 c0                	test   %eax,%eax
    2b4d:	75 19                	jne    2b68 <dirfile+0x142>
    printf(1, "unlink dirfile/xx succeeded!\n");
    2b4f:	c7 44 24 04 bd 54 00 	movl   $0x54bd,0x4(%esp)
    2b56:	00 
    2b57:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b5e:	e8 06 14 00 00       	call   3f69 <printf>
    exit();
    2b63:	e8 74 12 00 00       	call   3ddc <exit>
  }
  if(link("README", "dirfile/xx") == 0){
    2b68:	c7 44 24 04 77 54 00 	movl   $0x5477,0x4(%esp)
    2b6f:	00 
    2b70:	c7 04 24 db 54 00 00 	movl   $0x54db,(%esp)
    2b77:	e8 d0 12 00 00       	call   3e4c <link>
    2b7c:	85 c0                	test   %eax,%eax
    2b7e:	75 19                	jne    2b99 <dirfile+0x173>
    printf(1, "link to dirfile/xx succeeded!\n");
    2b80:	c7 44 24 04 e4 54 00 	movl   $0x54e4,0x4(%esp)
    2b87:	00 
    2b88:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b8f:	e8 d5 13 00 00       	call   3f69 <printf>
    exit();
    2b94:	e8 43 12 00 00       	call   3ddc <exit>
  }
  if(unlink("dirfile") != 0){
    2b99:	c7 04 24 3e 54 00 00 	movl   $0x543e,(%esp)
    2ba0:	e8 97 12 00 00       	call   3e3c <unlink>
    2ba5:	85 c0                	test   %eax,%eax
    2ba7:	74 19                	je     2bc2 <dirfile+0x19c>
    printf(1, "unlink dirfile failed!\n");
    2ba9:	c7 44 24 04 03 55 00 	movl   $0x5503,0x4(%esp)
    2bb0:	00 
    2bb1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2bb8:	e8 ac 13 00 00       	call   3f69 <printf>
    exit();
    2bbd:	e8 1a 12 00 00       	call   3ddc <exit>
  }

  fd = open(".", O_RDWR);
    2bc2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    2bc9:	00 
    2bca:	c7 04 24 ab 4a 00 00 	movl   $0x4aab,(%esp)
    2bd1:	e8 56 12 00 00       	call   3e2c <open>
    2bd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2bd9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2bdd:	78 19                	js     2bf8 <dirfile+0x1d2>
    printf(1, "open . for writing succeeded!\n");
    2bdf:	c7 44 24 04 1c 55 00 	movl   $0x551c,0x4(%esp)
    2be6:	00 
    2be7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2bee:	e8 76 13 00 00       	call   3f69 <printf>
    exit();
    2bf3:	e8 e4 11 00 00       	call   3ddc <exit>
  }
  fd = open(".", 0);
    2bf8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2bff:	00 
    2c00:	c7 04 24 ab 4a 00 00 	movl   $0x4aab,(%esp)
    2c07:	e8 20 12 00 00       	call   3e2c <open>
    2c0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(write(fd, "x", 1) > 0){
    2c0f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    2c16:	00 
    2c17:	c7 44 24 04 e2 46 00 	movl   $0x46e2,0x4(%esp)
    2c1e:	00 
    2c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2c22:	89 04 24             	mov    %eax,(%esp)
    2c25:	e8 e2 11 00 00       	call   3e0c <write>
    2c2a:	85 c0                	test   %eax,%eax
    2c2c:	7e 19                	jle    2c47 <dirfile+0x221>
    printf(1, "write . succeeded!\n");
    2c2e:	c7 44 24 04 3b 55 00 	movl   $0x553b,0x4(%esp)
    2c35:	00 
    2c36:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c3d:	e8 27 13 00 00       	call   3f69 <printf>
    exit();
    2c42:	e8 95 11 00 00       	call   3ddc <exit>
  }
  close(fd);
    2c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2c4a:	89 04 24             	mov    %eax,(%esp)
    2c4d:	e8 c2 11 00 00       	call   3e14 <close>

  printf(1, "dir vs file OK\n");
    2c52:	c7 44 24 04 4f 55 00 	movl   $0x554f,0x4(%esp)
    2c59:	00 
    2c5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c61:	e8 03 13 00 00       	call   3f69 <printf>
}
    2c66:	c9                   	leave  
    2c67:	c3                   	ret    

00002c68 <iref>:

// test that iput() is called at the end of _namei()
void
iref(void)
{
    2c68:	55                   	push   %ebp
    2c69:	89 e5                	mov    %esp,%ebp
    2c6b:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(1, "empty file name\n");
    2c6e:	c7 44 24 04 5f 55 00 	movl   $0x555f,0x4(%esp)
    2c75:	00 
    2c76:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c7d:	e8 e7 12 00 00       	call   3f69 <printf>

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    2c82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2c89:	e9 d2 00 00 00       	jmp    2d60 <iref+0xf8>
    if(mkdir("irefd") != 0){
    2c8e:	c7 04 24 70 55 00 00 	movl   $0x5570,(%esp)
    2c95:	e8 ba 11 00 00       	call   3e54 <mkdir>
    2c9a:	85 c0                	test   %eax,%eax
    2c9c:	74 19                	je     2cb7 <iref+0x4f>
      printf(1, "mkdir irefd failed\n");
    2c9e:	c7 44 24 04 76 55 00 	movl   $0x5576,0x4(%esp)
    2ca5:	00 
    2ca6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2cad:	e8 b7 12 00 00       	call   3f69 <printf>
      exit();
    2cb2:	e8 25 11 00 00       	call   3ddc <exit>
    }
    if(chdir("irefd") != 0){
    2cb7:	c7 04 24 70 55 00 00 	movl   $0x5570,(%esp)
    2cbe:	e8 99 11 00 00       	call   3e5c <chdir>
    2cc3:	85 c0                	test   %eax,%eax
    2cc5:	74 19                	je     2ce0 <iref+0x78>
      printf(1, "chdir irefd failed\n");
    2cc7:	c7 44 24 04 8a 55 00 	movl   $0x558a,0x4(%esp)
    2cce:	00 
    2ccf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2cd6:	e8 8e 12 00 00       	call   3f69 <printf>
      exit();
    2cdb:	e8 fc 10 00 00       	call   3ddc <exit>
    }

    mkdir("");
    2ce0:	c7 04 24 9e 55 00 00 	movl   $0x559e,(%esp)
    2ce7:	e8 68 11 00 00       	call   3e54 <mkdir>
    link("README", "");
    2cec:	c7 44 24 04 9e 55 00 	movl   $0x559e,0x4(%esp)
    2cf3:	00 
    2cf4:	c7 04 24 db 54 00 00 	movl   $0x54db,(%esp)
    2cfb:	e8 4c 11 00 00       	call   3e4c <link>
    fd = open("", O_CREATE);
    2d00:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2d07:	00 
    2d08:	c7 04 24 9e 55 00 00 	movl   $0x559e,(%esp)
    2d0f:	e8 18 11 00 00       	call   3e2c <open>
    2d14:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    2d17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2d1b:	78 0b                	js     2d28 <iref+0xc0>
      close(fd);
    2d1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2d20:	89 04 24             	mov    %eax,(%esp)
    2d23:	e8 ec 10 00 00       	call   3e14 <close>
    fd = open("xx", O_CREATE);
    2d28:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2d2f:	00 
    2d30:	c7 04 24 9f 55 00 00 	movl   $0x559f,(%esp)
    2d37:	e8 f0 10 00 00       	call   3e2c <open>
    2d3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    2d3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2d43:	78 0b                	js     2d50 <iref+0xe8>
      close(fd);
    2d45:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2d48:	89 04 24             	mov    %eax,(%esp)
    2d4b:	e8 c4 10 00 00       	call   3e14 <close>
    unlink("xx");
    2d50:	c7 04 24 9f 55 00 00 	movl   $0x559f,(%esp)
    2d57:	e8 e0 10 00 00       	call   3e3c <unlink>
  int i, fd;

  printf(1, "empty file name\n");

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    2d5c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2d60:	83 7d f4 32          	cmpl   $0x32,-0xc(%ebp)
    2d64:	0f 8e 24 ff ff ff    	jle    2c8e <iref+0x26>
    if(fd >= 0)
      close(fd);
    unlink("xx");
  }

  chdir("/");
    2d6a:	c7 04 24 c2 53 00 00 	movl   $0x53c2,(%esp)
    2d71:	e8 e6 10 00 00       	call   3e5c <chdir>
  printf(1, "empty file name OK\n");
    2d76:	c7 44 24 04 a2 55 00 	movl   $0x55a2,0x4(%esp)
    2d7d:	00 
    2d7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d85:	e8 df 11 00 00       	call   3f69 <printf>
}
    2d8a:	c9                   	leave  
    2d8b:	c3                   	ret    

00002d8c <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
    2d8c:	55                   	push   %ebp
    2d8d:	89 e5                	mov    %esp,%ebp
    2d8f:	83 ec 28             	sub    $0x28,%esp
  int n, pid;

  printf(1, "fork test\n");
    2d92:	c7 44 24 04 b6 55 00 	movl   $0x55b6,0x4(%esp)
    2d99:	00 
    2d9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2da1:	e8 c3 11 00 00       	call   3f69 <printf>

  for(n=0; n<1000; n++){
    2da6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2dad:	eb 1d                	jmp    2dcc <forktest+0x40>
    pid = fork();
    2daf:	e8 20 10 00 00       	call   3dd4 <fork>
    2db4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
    2db7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2dbb:	78 1a                	js     2dd7 <forktest+0x4b>
      break;
    if(pid == 0)
    2dbd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2dc1:	75 05                	jne    2dc8 <forktest+0x3c>
      exit();
    2dc3:	e8 14 10 00 00       	call   3ddc <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<1000; n++){
    2dc8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    2dcc:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
    2dd3:	7e da                	jle    2daf <forktest+0x23>
    2dd5:	eb 01                	jmp    2dd8 <forktest+0x4c>
    pid = fork();
    if(pid < 0)
      break;
    2dd7:	90                   	nop
    if(pid == 0)
      exit();
  }
  
  if(n == 1000){
    2dd8:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
    2ddf:	75 3f                	jne    2e20 <forktest+0x94>
    printf(1, "fork claimed to work 1000 times!\n");
    2de1:	c7 44 24 04 c4 55 00 	movl   $0x55c4,0x4(%esp)
    2de8:	00 
    2de9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2df0:	e8 74 11 00 00       	call   3f69 <printf>
    exit();
    2df5:	e8 e2 0f 00 00       	call   3ddc <exit>
  }
  
  for(; n > 0; n--){
    if(wait() < 0){
    2dfa:	e8 e5 0f 00 00       	call   3de4 <wait>
    2dff:	85 c0                	test   %eax,%eax
    2e01:	79 19                	jns    2e1c <forktest+0x90>
      printf(1, "wait stopped early\n");
    2e03:	c7 44 24 04 e6 55 00 	movl   $0x55e6,0x4(%esp)
    2e0a:	00 
    2e0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e12:	e8 52 11 00 00       	call   3f69 <printf>
      exit();
    2e17:	e8 c0 0f 00 00       	call   3ddc <exit>
  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
    exit();
  }
  
  for(; n > 0; n--){
    2e1c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    2e20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2e24:	7f d4                	jg     2dfa <forktest+0x6e>
      printf(1, "wait stopped early\n");
      exit();
    }
  }
  
  if(wait() != -1){
    2e26:	e8 b9 0f 00 00       	call   3de4 <wait>
    2e2b:	83 f8 ff             	cmp    $0xffffffff,%eax
    2e2e:	74 19                	je     2e49 <forktest+0xbd>
    printf(1, "wait got too many\n");
    2e30:	c7 44 24 04 fa 55 00 	movl   $0x55fa,0x4(%esp)
    2e37:	00 
    2e38:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e3f:	e8 25 11 00 00       	call   3f69 <printf>
    exit();
    2e44:	e8 93 0f 00 00       	call   3ddc <exit>
  }
  
  printf(1, "fork test OK\n");
    2e49:	c7 44 24 04 0d 56 00 	movl   $0x560d,0x4(%esp)
    2e50:	00 
    2e51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e58:	e8 0c 11 00 00       	call   3f69 <printf>
}
    2e5d:	c9                   	leave  
    2e5e:	c3                   	ret    

00002e5f <sbrktest>:

void
sbrktest(void)
{
    2e5f:	55                   	push   %ebp
    2e60:	89 e5                	mov    %esp,%ebp
    2e62:	53                   	push   %ebx
    2e63:	81 ec 84 00 00 00    	sub    $0x84,%esp
  int fds[2], pid, pids[10], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
    2e69:	a1 10 61 00 00       	mov    0x6110,%eax
    2e6e:	c7 44 24 04 1b 56 00 	movl   $0x561b,0x4(%esp)
    2e75:	00 
    2e76:	89 04 24             	mov    %eax,(%esp)
    2e79:	e8 eb 10 00 00       	call   3f69 <printf>
  oldbrk = sbrk(0);
    2e7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2e85:	e8 ea 0f 00 00       	call   3e74 <sbrk>
    2e8a:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // can one sbrk() less than a page?
  a = sbrk(0);
    2e8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2e94:	e8 db 0f 00 00       	call   3e74 <sbrk>
    2e99:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int i;
  for(i = 0; i < 5000; i++){ 
    2e9c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    2ea3:	eb 59                	jmp    2efe <sbrktest+0x9f>
    b = sbrk(1);
    2ea5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2eac:	e8 c3 0f 00 00       	call   3e74 <sbrk>
    2eb1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(b != a){
    2eb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2eb7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    2eba:	74 2f                	je     2eeb <sbrktest+0x8c>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
    2ebc:	a1 10 61 00 00       	mov    0x6110,%eax
    2ec1:	8b 55 e8             	mov    -0x18(%ebp),%edx
    2ec4:	89 54 24 10          	mov    %edx,0x10(%esp)
    2ec8:	8b 55 f4             	mov    -0xc(%ebp),%edx
    2ecb:	89 54 24 0c          	mov    %edx,0xc(%esp)
    2ecf:	8b 55 f0             	mov    -0x10(%ebp),%edx
    2ed2:	89 54 24 08          	mov    %edx,0x8(%esp)
    2ed6:	c7 44 24 04 26 56 00 	movl   $0x5626,0x4(%esp)
    2edd:	00 
    2ede:	89 04 24             	mov    %eax,(%esp)
    2ee1:	e8 83 10 00 00       	call   3f69 <printf>
      exit();
    2ee6:	e8 f1 0e 00 00       	call   3ddc <exit>
    }
    *b = 1;
    2eeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2eee:	c6 00 01             	movb   $0x1,(%eax)
    a = b + 1;
    2ef1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2ef4:	83 c0 01             	add    $0x1,%eax
    2ef7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  oldbrk = sbrk(0);

  // can one sbrk() less than a page?
  a = sbrk(0);
  int i;
  for(i = 0; i < 5000; i++){ 
    2efa:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    2efe:	81 7d f0 87 13 00 00 	cmpl   $0x1387,-0x10(%ebp)
    2f05:	7e 9e                	jle    2ea5 <sbrktest+0x46>
      exit();
    }
    *b = 1;
    a = b + 1;
  }
  pid = fork();
    2f07:	e8 c8 0e 00 00       	call   3dd4 <fork>
    2f0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(pid < 0){
    2f0f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    2f13:	79 1a                	jns    2f2f <sbrktest+0xd0>
    printf(stdout, "sbrk test fork failed\n");
    2f15:	a1 10 61 00 00       	mov    0x6110,%eax
    2f1a:	c7 44 24 04 41 56 00 	movl   $0x5641,0x4(%esp)
    2f21:	00 
    2f22:	89 04 24             	mov    %eax,(%esp)
    2f25:	e8 3f 10 00 00       	call   3f69 <printf>
    exit();
    2f2a:	e8 ad 0e 00 00       	call   3ddc <exit>
  }
  c = sbrk(1);
    2f2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f36:	e8 39 0f 00 00       	call   3e74 <sbrk>
    2f3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  c = sbrk(1);
    2f3e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f45:	e8 2a 0f 00 00       	call   3e74 <sbrk>
    2f4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a + 1){
    2f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2f50:	83 c0 01             	add    $0x1,%eax
    2f53:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    2f56:	74 1a                	je     2f72 <sbrktest+0x113>
    printf(stdout, "sbrk test failed post-fork\n");
    2f58:	a1 10 61 00 00       	mov    0x6110,%eax
    2f5d:	c7 44 24 04 58 56 00 	movl   $0x5658,0x4(%esp)
    2f64:	00 
    2f65:	89 04 24             	mov    %eax,(%esp)
    2f68:	e8 fc 0f 00 00       	call   3f69 <printf>
    exit();
    2f6d:	e8 6a 0e 00 00       	call   3ddc <exit>
  }
  if(pid == 0)
    2f72:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    2f76:	75 05                	jne    2f7d <sbrktest+0x11e>
    exit();
    2f78:	e8 5f 0e 00 00       	call   3ddc <exit>
  wait();
    2f7d:	e8 62 0e 00 00       	call   3de4 <wait>

  // can one grow address space to something big?
#define BIG (100*1024*1024)
  a = sbrk(0);
    2f82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2f89:	e8 e6 0e 00 00       	call   3e74 <sbrk>
    2f8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  amt = (BIG) - (uint)a;
    2f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2f94:	ba 00 00 40 06       	mov    $0x6400000,%edx
    2f99:	89 d1                	mov    %edx,%ecx
    2f9b:	29 c1                	sub    %eax,%ecx
    2f9d:	89 c8                	mov    %ecx,%eax
    2f9f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  p = sbrk(amt);
    2fa2:	8b 45 dc             	mov    -0x24(%ebp),%eax
    2fa5:	89 04 24             	mov    %eax,(%esp)
    2fa8:	e8 c7 0e 00 00       	call   3e74 <sbrk>
    2fad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if (p != a) { 
    2fb0:	8b 45 d8             	mov    -0x28(%ebp),%eax
    2fb3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    2fb6:	74 1a                	je     2fd2 <sbrktest+0x173>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    2fb8:	a1 10 61 00 00       	mov    0x6110,%eax
    2fbd:	c7 44 24 04 74 56 00 	movl   $0x5674,0x4(%esp)
    2fc4:	00 
    2fc5:	89 04 24             	mov    %eax,(%esp)
    2fc8:	e8 9c 0f 00 00       	call   3f69 <printf>
    exit();
    2fcd:	e8 0a 0e 00 00       	call   3ddc <exit>
  }
  lastaddr = (char*) (BIG-1);
    2fd2:	c7 45 d4 ff ff 3f 06 	movl   $0x63fffff,-0x2c(%ebp)
  *lastaddr = 99;
    2fd9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    2fdc:	c6 00 63             	movb   $0x63,(%eax)

  // can one de-allocate?
  a = sbrk(0);
    2fdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    2fe6:	e8 89 0e 00 00       	call   3e74 <sbrk>
    2feb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-4096);
    2fee:	c7 04 24 00 f0 ff ff 	movl   $0xfffff000,(%esp)
    2ff5:	e8 7a 0e 00 00       	call   3e74 <sbrk>
    2ffa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c == (char*)0xffffffff){
    2ffd:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    3001:	75 1a                	jne    301d <sbrktest+0x1be>
    printf(stdout, "sbrk could not deallocate\n");
    3003:	a1 10 61 00 00       	mov    0x6110,%eax
    3008:	c7 44 24 04 b2 56 00 	movl   $0x56b2,0x4(%esp)
    300f:	00 
    3010:	89 04 24             	mov    %eax,(%esp)
    3013:	e8 51 0f 00 00       	call   3f69 <printf>
    exit();
    3018:	e8 bf 0d 00 00       	call   3ddc <exit>
  }
  c = sbrk(0);
    301d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3024:	e8 4b 0e 00 00       	call   3e74 <sbrk>
    3029:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a - 4096){
    302c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    302f:	2d 00 10 00 00       	sub    $0x1000,%eax
    3034:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    3037:	74 28                	je     3061 <sbrktest+0x202>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    3039:	a1 10 61 00 00       	mov    0x6110,%eax
    303e:	8b 55 e0             	mov    -0x20(%ebp),%edx
    3041:	89 54 24 0c          	mov    %edx,0xc(%esp)
    3045:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3048:	89 54 24 08          	mov    %edx,0x8(%esp)
    304c:	c7 44 24 04 d0 56 00 	movl   $0x56d0,0x4(%esp)
    3053:	00 
    3054:	89 04 24             	mov    %eax,(%esp)
    3057:	e8 0d 0f 00 00       	call   3f69 <printf>
    exit();
    305c:	e8 7b 0d 00 00       	call   3ddc <exit>
  }

  // can one re-allocate that page?
  a = sbrk(0);
    3061:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3068:	e8 07 0e 00 00       	call   3e74 <sbrk>
    306d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(4096);
    3070:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    3077:	e8 f8 0d 00 00       	call   3e74 <sbrk>
    307c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a || sbrk(0) != a + 4096){
    307f:	8b 45 e0             	mov    -0x20(%ebp),%eax
    3082:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3085:	75 19                	jne    30a0 <sbrktest+0x241>
    3087:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    308e:	e8 e1 0d 00 00       	call   3e74 <sbrk>
    3093:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3096:	81 c2 00 10 00 00    	add    $0x1000,%edx
    309c:	39 d0                	cmp    %edx,%eax
    309e:	74 28                	je     30c8 <sbrktest+0x269>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    30a0:	a1 10 61 00 00       	mov    0x6110,%eax
    30a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
    30a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
    30ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
    30af:	89 54 24 08          	mov    %edx,0x8(%esp)
    30b3:	c7 44 24 04 08 57 00 	movl   $0x5708,0x4(%esp)
    30ba:	00 
    30bb:	89 04 24             	mov    %eax,(%esp)
    30be:	e8 a6 0e 00 00       	call   3f69 <printf>
    exit();
    30c3:	e8 14 0d 00 00       	call   3ddc <exit>
  }
  if(*lastaddr == 99){
    30c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    30cb:	0f b6 00             	movzbl (%eax),%eax
    30ce:	3c 63                	cmp    $0x63,%al
    30d0:	75 1a                	jne    30ec <sbrktest+0x28d>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    30d2:	a1 10 61 00 00       	mov    0x6110,%eax
    30d7:	c7 44 24 04 30 57 00 	movl   $0x5730,0x4(%esp)
    30de:	00 
    30df:	89 04 24             	mov    %eax,(%esp)
    30e2:	e8 82 0e 00 00       	call   3f69 <printf>
    exit();
    30e7:	e8 f0 0c 00 00       	call   3ddc <exit>
  }

  a = sbrk(0);
    30ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    30f3:	e8 7c 0d 00 00       	call   3e74 <sbrk>
    30f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-(sbrk(0) - oldbrk));
    30fb:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    30fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3105:	e8 6a 0d 00 00       	call   3e74 <sbrk>
    310a:	89 da                	mov    %ebx,%edx
    310c:	29 c2                	sub    %eax,%edx
    310e:	89 d0                	mov    %edx,%eax
    3110:	89 04 24             	mov    %eax,(%esp)
    3113:	e8 5c 0d 00 00       	call   3e74 <sbrk>
    3118:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a){
    311b:	8b 45 e0             	mov    -0x20(%ebp),%eax
    311e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3121:	74 28                	je     314b <sbrktest+0x2ec>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    3123:	a1 10 61 00 00       	mov    0x6110,%eax
    3128:	8b 55 e0             	mov    -0x20(%ebp),%edx
    312b:	89 54 24 0c          	mov    %edx,0xc(%esp)
    312f:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3132:	89 54 24 08          	mov    %edx,0x8(%esp)
    3136:	c7 44 24 04 60 57 00 	movl   $0x5760,0x4(%esp)
    313d:	00 
    313e:	89 04 24             	mov    %eax,(%esp)
    3141:	e8 23 0e 00 00       	call   3f69 <printf>
    exit();
    3146:	e8 91 0c 00 00       	call   3ddc <exit>
  }
  
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    314b:	c7 45 f4 00 00 00 80 	movl   $0x80000000,-0xc(%ebp)
    3152:	eb 7b                	jmp    31cf <sbrktest+0x370>
    ppid = getpid();
    3154:	e8 13 0d 00 00       	call   3e6c <getpid>
    3159:	89 45 d0             	mov    %eax,-0x30(%ebp)
    pid = fork();
    315c:	e8 73 0c 00 00       	call   3dd4 <fork>
    3161:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(pid < 0){
    3164:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    3168:	79 1a                	jns    3184 <sbrktest+0x325>
      printf(stdout, "fork failed\n");
    316a:	a1 10 61 00 00       	mov    0x6110,%eax
    316f:	c7 44 24 04 29 47 00 	movl   $0x4729,0x4(%esp)
    3176:	00 
    3177:	89 04 24             	mov    %eax,(%esp)
    317a:	e8 ea 0d 00 00       	call   3f69 <printf>
      exit();
    317f:	e8 58 0c 00 00       	call   3ddc <exit>
    }
    if(pid == 0){
    3184:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    3188:	75 39                	jne    31c3 <sbrktest+0x364>
      printf(stdout, "oops could read %x = %x\n", a, *a);
    318a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    318d:	0f b6 00             	movzbl (%eax),%eax
    3190:	0f be d0             	movsbl %al,%edx
    3193:	a1 10 61 00 00       	mov    0x6110,%eax
    3198:	89 54 24 0c          	mov    %edx,0xc(%esp)
    319c:	8b 55 f4             	mov    -0xc(%ebp),%edx
    319f:	89 54 24 08          	mov    %edx,0x8(%esp)
    31a3:	c7 44 24 04 81 57 00 	movl   $0x5781,0x4(%esp)
    31aa:	00 
    31ab:	89 04 24             	mov    %eax,(%esp)
    31ae:	e8 b6 0d 00 00       	call   3f69 <printf>
      kill(ppid);
    31b3:	8b 45 d0             	mov    -0x30(%ebp),%eax
    31b6:	89 04 24             	mov    %eax,(%esp)
    31b9:	e8 5e 0c 00 00       	call   3e1c <kill>
      exit();
    31be:	e8 19 0c 00 00       	call   3ddc <exit>
    }
    wait();
    31c3:	e8 1c 0c 00 00       	call   3de4 <wait>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    exit();
  }
  
  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    31c8:	81 45 f4 50 c3 00 00 	addl   $0xc350,-0xc(%ebp)
    31cf:	81 7d f4 7f 84 1e 80 	cmpl   $0x801e847f,-0xc(%ebp)
    31d6:	0f 86 78 ff ff ff    	jbe    3154 <sbrktest+0x2f5>
    wait();
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    31dc:	8d 45 c8             	lea    -0x38(%ebp),%eax
    31df:	89 04 24             	mov    %eax,(%esp)
    31e2:	e8 15 0c 00 00       	call   3dfc <pipe>
    31e7:	85 c0                	test   %eax,%eax
    31e9:	74 19                	je     3204 <sbrktest+0x3a5>
    printf(1, "pipe() failed\n");
    31eb:	c7 44 24 04 7d 46 00 	movl   $0x467d,0x4(%esp)
    31f2:	00 
    31f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    31fa:	e8 6a 0d 00 00       	call   3f69 <printf>
    exit();
    31ff:	e8 d8 0b 00 00       	call   3ddc <exit>
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3204:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    320b:	e9 89 00 00 00       	jmp    3299 <sbrktest+0x43a>
    if((pids[i] = fork()) == 0){
    3210:	e8 bf 0b 00 00       	call   3dd4 <fork>
    3215:	8b 55 f0             	mov    -0x10(%ebp),%edx
    3218:	89 44 95 a0          	mov    %eax,-0x60(%ebp,%edx,4)
    321c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    321f:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    3223:	85 c0                	test   %eax,%eax
    3225:	75 48                	jne    326f <sbrktest+0x410>
      // allocate a lot of memory
      sbrk(BIG - (uint)sbrk(0));
    3227:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    322e:	e8 41 0c 00 00       	call   3e74 <sbrk>
    3233:	ba 00 00 40 06       	mov    $0x6400000,%edx
    3238:	89 d1                	mov    %edx,%ecx
    323a:	29 c1                	sub    %eax,%ecx
    323c:	89 c8                	mov    %ecx,%eax
    323e:	89 04 24             	mov    %eax,(%esp)
    3241:	e8 2e 0c 00 00       	call   3e74 <sbrk>
      write(fds[1], "x", 1);
    3246:	8b 45 cc             	mov    -0x34(%ebp),%eax
    3249:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3250:	00 
    3251:	c7 44 24 04 e2 46 00 	movl   $0x46e2,0x4(%esp)
    3258:	00 
    3259:	89 04 24             	mov    %eax,(%esp)
    325c:	e8 ab 0b 00 00       	call   3e0c <write>
      // sit around until killed
      for(;;) sleep(1000);
    3261:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
    3268:	e8 0f 0c 00 00       	call   3e7c <sleep>
    326d:	eb f2                	jmp    3261 <sbrktest+0x402>
    }
    if(pids[i] != -1)
    326f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3272:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    3276:	83 f8 ff             	cmp    $0xffffffff,%eax
    3279:	74 1a                	je     3295 <sbrktest+0x436>
      read(fds[0], &scratch, 1);
    327b:	8b 45 c8             	mov    -0x38(%ebp),%eax
    327e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3285:	00 
    3286:	8d 55 9f             	lea    -0x61(%ebp),%edx
    3289:	89 54 24 04          	mov    %edx,0x4(%esp)
    328d:	89 04 24             	mov    %eax,(%esp)
    3290:	e8 6f 0b 00 00       	call   3e04 <read>
  // failed allocation?
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit();
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3295:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    3299:	8b 45 f0             	mov    -0x10(%ebp),%eax
    329c:	83 f8 09             	cmp    $0x9,%eax
    329f:	0f 86 6b ff ff ff    	jbe    3210 <sbrktest+0x3b1>
    if(pids[i] != -1)
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
    32a5:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    32ac:	e8 c3 0b 00 00       	call   3e74 <sbrk>
    32b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    32b4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    32bb:	eb 27                	jmp    32e4 <sbrktest+0x485>
    if(pids[i] == -1)
    32bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
    32c0:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    32c4:	83 f8 ff             	cmp    $0xffffffff,%eax
    32c7:	74 16                	je     32df <sbrktest+0x480>
      continue;
    kill(pids[i]);
    32c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    32cc:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    32d0:	89 04 24             	mov    %eax,(%esp)
    32d3:	e8 44 0b 00 00       	call   3e1c <kill>
    wait();
    32d8:	e8 07 0b 00 00       	call   3de4 <wait>
    32dd:	eb 01                	jmp    32e0 <sbrktest+0x481>
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    if(pids[i] == -1)
      continue;
    32df:	90                   	nop
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    32e0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    32e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    32e7:	83 f8 09             	cmp    $0x9,%eax
    32ea:	76 d1                	jbe    32bd <sbrktest+0x45e>
    if(pids[i] == -1)
      continue;
    kill(pids[i]);
    wait();
  }
  if(c == (char*)0xffffffff){
    32ec:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    32f0:	75 1a                	jne    330c <sbrktest+0x4ad>
    printf(stdout, "failed sbrk leaked memory\n");
    32f2:	a1 10 61 00 00       	mov    0x6110,%eax
    32f7:	c7 44 24 04 9a 57 00 	movl   $0x579a,0x4(%esp)
    32fe:	00 
    32ff:	89 04 24             	mov    %eax,(%esp)
    3302:	e8 62 0c 00 00       	call   3f69 <printf>
    exit();
    3307:	e8 d0 0a 00 00       	call   3ddc <exit>
  }

  if(sbrk(0) > oldbrk)
    330c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3313:	e8 5c 0b 00 00       	call   3e74 <sbrk>
    3318:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    331b:	76 1d                	jbe    333a <sbrktest+0x4db>
    sbrk(-(sbrk(0) - oldbrk));
    331d:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    3320:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3327:	e8 48 0b 00 00       	call   3e74 <sbrk>
    332c:	89 da                	mov    %ebx,%edx
    332e:	29 c2                	sub    %eax,%edx
    3330:	89 d0                	mov    %edx,%eax
    3332:	89 04 24             	mov    %eax,(%esp)
    3335:	e8 3a 0b 00 00       	call   3e74 <sbrk>

  printf(stdout, "sbrk test OK\n");
    333a:	a1 10 61 00 00       	mov    0x6110,%eax
    333f:	c7 44 24 04 b5 57 00 	movl   $0x57b5,0x4(%esp)
    3346:	00 
    3347:	89 04 24             	mov    %eax,(%esp)
    334a:	e8 1a 0c 00 00       	call   3f69 <printf>
}
    334f:	81 c4 84 00 00 00    	add    $0x84,%esp
    3355:	5b                   	pop    %ebx
    3356:	5d                   	pop    %ebp
    3357:	c3                   	ret    

00003358 <validateint>:

void
validateint(int *p)
{
    3358:	55                   	push   %ebp
    3359:	89 e5                	mov    %esp,%ebp
    335b:	56                   	push   %esi
    335c:	53                   	push   %ebx
    335d:	83 ec 14             	sub    $0x14,%esp
  int res;
  asm("mov %%esp, %%ebx\n\t"
    3360:	c7 45 e4 0d 00 00 00 	movl   $0xd,-0x1c(%ebp)
    3367:	8b 55 08             	mov    0x8(%ebp),%edx
    336a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    336d:	89 d1                	mov    %edx,%ecx
    336f:	89 e3                	mov    %esp,%ebx
    3371:	89 cc                	mov    %ecx,%esp
    3373:	cd 40                	int    $0x40
    3375:	89 dc                	mov    %ebx,%esp
    3377:	89 c6                	mov    %eax,%esi
    3379:	89 75 f4             	mov    %esi,-0xc(%ebp)
      "int %2\n\t"
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
}
    337c:	83 c4 14             	add    $0x14,%esp
    337f:	5b                   	pop    %ebx
    3380:	5e                   	pop    %esi
    3381:	5d                   	pop    %ebp
    3382:	c3                   	ret    

00003383 <validatetest>:

void
validatetest(void)
{
    3383:	55                   	push   %ebp
    3384:	89 e5                	mov    %esp,%ebp
    3386:	83 ec 28             	sub    $0x28,%esp
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
    3389:	a1 10 61 00 00       	mov    0x6110,%eax
    338e:	c7 44 24 04 c3 57 00 	movl   $0x57c3,0x4(%esp)
    3395:	00 
    3396:	89 04 24             	mov    %eax,(%esp)
    3399:	e8 cb 0b 00 00       	call   3f69 <printf>
  hi = 1100*1024;
    339e:	c7 45 f0 00 30 11 00 	movl   $0x113000,-0x10(%ebp)

  for(p = 0; p <= (uint)hi; p += 4096){
    33a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    33ac:	eb 7f                	jmp    342d <validatetest+0xaa>
    if((pid = fork()) == 0){
    33ae:	e8 21 0a 00 00       	call   3dd4 <fork>
    33b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    33b6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    33ba:	75 10                	jne    33cc <validatetest+0x49>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
    33bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    33bf:	89 04 24             	mov    %eax,(%esp)
    33c2:	e8 91 ff ff ff       	call   3358 <validateint>
      exit();
    33c7:	e8 10 0a 00 00       	call   3ddc <exit>
    }
    sleep(0);
    33cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    33d3:	e8 a4 0a 00 00       	call   3e7c <sleep>
    sleep(0);
    33d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    33df:	e8 98 0a 00 00       	call   3e7c <sleep>
    kill(pid);
    33e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
    33e7:	89 04 24             	mov    %eax,(%esp)
    33ea:	e8 2d 0a 00 00       	call   3e1c <kill>
    wait();
    33ef:	e8 f0 09 00 00       	call   3de4 <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    33f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    33f7:	89 44 24 04          	mov    %eax,0x4(%esp)
    33fb:	c7 04 24 d2 57 00 00 	movl   $0x57d2,(%esp)
    3402:	e8 45 0a 00 00       	call   3e4c <link>
    3407:	83 f8 ff             	cmp    $0xffffffff,%eax
    340a:	74 1a                	je     3426 <validatetest+0xa3>
      printf(stdout, "link should not succeed\n");
    340c:	a1 10 61 00 00       	mov    0x6110,%eax
    3411:	c7 44 24 04 dd 57 00 	movl   $0x57dd,0x4(%esp)
    3418:	00 
    3419:	89 04 24             	mov    %eax,(%esp)
    341c:	e8 48 0b 00 00       	call   3f69 <printf>
      exit();
    3421:	e8 b6 09 00 00       	call   3ddc <exit>
  uint p;

  printf(stdout, "validate test\n");
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    3426:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    342d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3430:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3433:	0f 83 75 ff ff ff    	jae    33ae <validatetest+0x2b>
      printf(stdout, "link should not succeed\n");
      exit();
    }
  }

  printf(stdout, "validate ok\n");
    3439:	a1 10 61 00 00       	mov    0x6110,%eax
    343e:	c7 44 24 04 f6 57 00 	movl   $0x57f6,0x4(%esp)
    3445:	00 
    3446:	89 04 24             	mov    %eax,(%esp)
    3449:	e8 1b 0b 00 00       	call   3f69 <printf>
}
    344e:	c9                   	leave  
    344f:	c3                   	ret    

00003450 <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
    3450:	55                   	push   %ebp
    3451:	89 e5                	mov    %esp,%ebp
    3453:	83 ec 28             	sub    $0x28,%esp
  int i;

  printf(stdout, "bss test\n");
    3456:	a1 10 61 00 00       	mov    0x6110,%eax
    345b:	c7 44 24 04 03 58 00 	movl   $0x5803,0x4(%esp)
    3462:	00 
    3463:	89 04 24             	mov    %eax,(%esp)
    3466:	e8 fe 0a 00 00       	call   3f69 <printf>
  for(i = 0; i < sizeof(uninit); i++){
    346b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3472:	eb 2d                	jmp    34a1 <bsstest+0x51>
    if(uninit[i] != '\0'){
    3474:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3477:	05 e0 61 00 00       	add    $0x61e0,%eax
    347c:	0f b6 00             	movzbl (%eax),%eax
    347f:	84 c0                	test   %al,%al
    3481:	74 1a                	je     349d <bsstest+0x4d>
      printf(stdout, "bss test failed\n");
    3483:	a1 10 61 00 00       	mov    0x6110,%eax
    3488:	c7 44 24 04 0d 58 00 	movl   $0x580d,0x4(%esp)
    348f:	00 
    3490:	89 04 24             	mov    %eax,(%esp)
    3493:	e8 d1 0a 00 00       	call   3f69 <printf>
      exit();
    3498:	e8 3f 09 00 00       	call   3ddc <exit>
bsstest(void)
{
  int i;

  printf(stdout, "bss test\n");
  for(i = 0; i < sizeof(uninit); i++){
    349d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    34a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    34a4:	3d 0f 27 00 00       	cmp    $0x270f,%eax
    34a9:	76 c9                	jbe    3474 <bsstest+0x24>
    if(uninit[i] != '\0'){
      printf(stdout, "bss test failed\n");
      exit();
    }
  }
  printf(stdout, "bss test ok\n");
    34ab:	a1 10 61 00 00       	mov    0x6110,%eax
    34b0:	c7 44 24 04 1e 58 00 	movl   $0x581e,0x4(%esp)
    34b7:	00 
    34b8:	89 04 24             	mov    %eax,(%esp)
    34bb:	e8 a9 0a 00 00       	call   3f69 <printf>
}
    34c0:	c9                   	leave  
    34c1:	c3                   	ret    

000034c2 <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(void)
{
    34c2:	55                   	push   %ebp
    34c3:	89 e5                	mov    %esp,%ebp
    34c5:	83 ec 28             	sub    $0x28,%esp
  int pid, fd;

  unlink("bigarg-ok");
    34c8:	c7 04 24 2b 58 00 00 	movl   $0x582b,(%esp)
    34cf:	e8 68 09 00 00       	call   3e3c <unlink>
  pid = fork();
    34d4:	e8 fb 08 00 00       	call   3dd4 <fork>
    34d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid == 0){
    34dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    34e0:	0f 85 90 00 00 00    	jne    3576 <bigargtest+0xb4>
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    34e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    34ed:	eb 12                	jmp    3501 <bigargtest+0x3f>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    34ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
    34f2:	c7 04 85 40 61 00 00 	movl   $0x5838,0x6140(,%eax,4)
    34f9:	38 58 00 00 
  unlink("bigarg-ok");
  pid = fork();
  if(pid == 0){
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    34fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    3501:	83 7d f4 1e          	cmpl   $0x1e,-0xc(%ebp)
    3505:	7e e8                	jle    34ef <bigargtest+0x2d>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    args[MAXARG-1] = 0;
    3507:	c7 05 bc 61 00 00 00 	movl   $0x0,0x61bc
    350e:	00 00 00 
    printf(stdout, "bigarg test\n");
    3511:	a1 10 61 00 00       	mov    0x6110,%eax
    3516:	c7 44 24 04 15 59 00 	movl   $0x5915,0x4(%esp)
    351d:	00 
    351e:	89 04 24             	mov    %eax,(%esp)
    3521:	e8 43 0a 00 00       	call   3f69 <printf>
    exec("echo", args);
    3526:	c7 44 24 04 40 61 00 	movl   $0x6140,0x4(%esp)
    352d:	00 
    352e:	c7 04 24 3c 43 00 00 	movl   $0x433c,(%esp)
    3535:	e8 ea 08 00 00       	call   3e24 <exec>
    printf(stdout, "bigarg test ok\n");
    353a:	a1 10 61 00 00       	mov    0x6110,%eax
    353f:	c7 44 24 04 22 59 00 	movl   $0x5922,0x4(%esp)
    3546:	00 
    3547:	89 04 24             	mov    %eax,(%esp)
    354a:	e8 1a 0a 00 00       	call   3f69 <printf>
    fd = open("bigarg-ok", O_CREATE);
    354f:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3556:	00 
    3557:	c7 04 24 2b 58 00 00 	movl   $0x582b,(%esp)
    355e:	e8 c9 08 00 00       	call   3e2c <open>
    3563:	89 45 ec             	mov    %eax,-0x14(%ebp)
    close(fd);
    3566:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3569:	89 04 24             	mov    %eax,(%esp)
    356c:	e8 a3 08 00 00       	call   3e14 <close>
    exit();
    3571:	e8 66 08 00 00       	call   3ddc <exit>
  } else if(pid < 0){
    3576:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    357a:	79 1a                	jns    3596 <bigargtest+0xd4>
    printf(stdout, "bigargtest: fork failed\n");
    357c:	a1 10 61 00 00       	mov    0x6110,%eax
    3581:	c7 44 24 04 32 59 00 	movl   $0x5932,0x4(%esp)
    3588:	00 
    3589:	89 04 24             	mov    %eax,(%esp)
    358c:	e8 d8 09 00 00       	call   3f69 <printf>
    exit();
    3591:	e8 46 08 00 00       	call   3ddc <exit>
  }
  wait();
    3596:	e8 49 08 00 00       	call   3de4 <wait>
  fd = open("bigarg-ok", 0);
    359b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    35a2:	00 
    35a3:	c7 04 24 2b 58 00 00 	movl   $0x582b,(%esp)
    35aa:	e8 7d 08 00 00       	call   3e2c <open>
    35af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    35b2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    35b6:	79 1a                	jns    35d2 <bigargtest+0x110>
    printf(stdout, "bigarg test failed!\n");
    35b8:	a1 10 61 00 00       	mov    0x6110,%eax
    35bd:	c7 44 24 04 4b 59 00 	movl   $0x594b,0x4(%esp)
    35c4:	00 
    35c5:	89 04 24             	mov    %eax,(%esp)
    35c8:	e8 9c 09 00 00       	call   3f69 <printf>
    exit();
    35cd:	e8 0a 08 00 00       	call   3ddc <exit>
  }
  close(fd);
    35d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
    35d5:	89 04 24             	mov    %eax,(%esp)
    35d8:	e8 37 08 00 00       	call   3e14 <close>
  unlink("bigarg-ok");
    35dd:	c7 04 24 2b 58 00 00 	movl   $0x582b,(%esp)
    35e4:	e8 53 08 00 00       	call   3e3c <unlink>
}
    35e9:	c9                   	leave  
    35ea:	c3                   	ret    

000035eb <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    35eb:	55                   	push   %ebp
    35ec:	89 e5                	mov    %esp,%ebp
    35ee:	53                   	push   %ebx
    35ef:	83 ec 74             	sub    $0x74,%esp
  int nfiles;
  int fsblocks = 0;
    35f2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  printf(1, "fsfull test\n");
    35f9:	c7 44 24 04 60 59 00 	movl   $0x5960,0x4(%esp)
    3600:	00 
    3601:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3608:	e8 5c 09 00 00       	call   3f69 <printf>

  for(nfiles = 0; ; nfiles++){
    360d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    char name[64];
    name[0] = 'f';
    3614:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    3618:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    361b:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3620:	89 c8                	mov    %ecx,%eax
    3622:	f7 ea                	imul   %edx
    3624:	c1 fa 06             	sar    $0x6,%edx
    3627:	89 c8                	mov    %ecx,%eax
    3629:	c1 f8 1f             	sar    $0x1f,%eax
    362c:	89 d1                	mov    %edx,%ecx
    362e:	29 c1                	sub    %eax,%ecx
    3630:	89 c8                	mov    %ecx,%eax
    3632:	83 c0 30             	add    $0x30,%eax
    3635:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    3638:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    363b:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    3640:	89 d8                	mov    %ebx,%eax
    3642:	f7 ea                	imul   %edx
    3644:	c1 fa 06             	sar    $0x6,%edx
    3647:	89 d8                	mov    %ebx,%eax
    3649:	c1 f8 1f             	sar    $0x1f,%eax
    364c:	89 d1                	mov    %edx,%ecx
    364e:	29 c1                	sub    %eax,%ecx
    3650:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    3656:	89 d9                	mov    %ebx,%ecx
    3658:	29 c1                	sub    %eax,%ecx
    365a:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    365f:	89 c8                	mov    %ecx,%eax
    3661:	f7 ea                	imul   %edx
    3663:	c1 fa 05             	sar    $0x5,%edx
    3666:	89 c8                	mov    %ecx,%eax
    3668:	c1 f8 1f             	sar    $0x1f,%eax
    366b:	89 d1                	mov    %edx,%ecx
    366d:	29 c1                	sub    %eax,%ecx
    366f:	89 c8                	mov    %ecx,%eax
    3671:	83 c0 30             	add    $0x30,%eax
    3674:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    3677:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    367a:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    367f:	89 d8                	mov    %ebx,%eax
    3681:	f7 ea                	imul   %edx
    3683:	c1 fa 05             	sar    $0x5,%edx
    3686:	89 d8                	mov    %ebx,%eax
    3688:	c1 f8 1f             	sar    $0x1f,%eax
    368b:	89 d1                	mov    %edx,%ecx
    368d:	29 c1                	sub    %eax,%ecx
    368f:	6b c1 64             	imul   $0x64,%ecx,%eax
    3692:	89 d9                	mov    %ebx,%ecx
    3694:	29 c1                	sub    %eax,%ecx
    3696:	ba 67 66 66 66       	mov    $0x66666667,%edx
    369b:	89 c8                	mov    %ecx,%eax
    369d:	f7 ea                	imul   %edx
    369f:	c1 fa 02             	sar    $0x2,%edx
    36a2:	89 c8                	mov    %ecx,%eax
    36a4:	c1 f8 1f             	sar    $0x1f,%eax
    36a7:	89 d1                	mov    %edx,%ecx
    36a9:	29 c1                	sub    %eax,%ecx
    36ab:	89 c8                	mov    %ecx,%eax
    36ad:	83 c0 30             	add    $0x30,%eax
    36b0:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    36b3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    36b6:	ba 67 66 66 66       	mov    $0x66666667,%edx
    36bb:	89 c8                	mov    %ecx,%eax
    36bd:	f7 ea                	imul   %edx
    36bf:	c1 fa 02             	sar    $0x2,%edx
    36c2:	89 c8                	mov    %ecx,%eax
    36c4:	c1 f8 1f             	sar    $0x1f,%eax
    36c7:	29 c2                	sub    %eax,%edx
    36c9:	89 d0                	mov    %edx,%eax
    36cb:	c1 e0 02             	shl    $0x2,%eax
    36ce:	01 d0                	add    %edx,%eax
    36d0:	01 c0                	add    %eax,%eax
    36d2:	89 ca                	mov    %ecx,%edx
    36d4:	29 c2                	sub    %eax,%edx
    36d6:	89 d0                	mov    %edx,%eax
    36d8:	83 c0 30             	add    $0x30,%eax
    36db:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    36de:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    printf(1, "writing %s\n", name);
    36e2:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    36e5:	89 44 24 08          	mov    %eax,0x8(%esp)
    36e9:	c7 44 24 04 6d 59 00 	movl   $0x596d,0x4(%esp)
    36f0:	00 
    36f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    36f8:	e8 6c 08 00 00       	call   3f69 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    36fd:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    3704:	00 
    3705:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3708:	89 04 24             	mov    %eax,(%esp)
    370b:	e8 1c 07 00 00       	call   3e2c <open>
    3710:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(fd < 0){
    3713:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    3717:	79 20                	jns    3739 <fsfull+0x14e>
      printf(1, "open %s failed\n", name);
    3719:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    371c:	89 44 24 08          	mov    %eax,0x8(%esp)
    3720:	c7 44 24 04 79 59 00 	movl   $0x5979,0x4(%esp)
    3727:	00 
    3728:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    372f:	e8 35 08 00 00       	call   3f69 <printf>
    close(fd);
    if(total == 0)
      break;
  }

  while(nfiles >= 0){
    3734:	e9 51 01 00 00       	jmp    388a <fsfull+0x29f>
    int fd = open(name, O_CREATE|O_RDWR);
    if(fd < 0){
      printf(1, "open %s failed\n", name);
      break;
    }
    int total = 0;
    3739:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while(1){
      int cc = write(fd, buf, 512);
    3740:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    3747:	00 
    3748:	c7 44 24 04 00 89 00 	movl   $0x8900,0x4(%esp)
    374f:	00 
    3750:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3753:	89 04 24             	mov    %eax,(%esp)
    3756:	e8 b1 06 00 00       	call   3e0c <write>
    375b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(cc < 512)
    375e:	81 7d e4 ff 01 00 00 	cmpl   $0x1ff,-0x1c(%ebp)
    3765:	7e 0c                	jle    3773 <fsfull+0x188>
        break;
      total += cc;
    3767:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    376a:	01 45 ec             	add    %eax,-0x14(%ebp)
      fsblocks++;
    376d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    }
    3771:	eb cd                	jmp    3740 <fsfull+0x155>
    }
    int total = 0;
    while(1){
      int cc = write(fd, buf, 512);
      if(cc < 512)
        break;
    3773:	90                   	nop
      total += cc;
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    3774:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3777:	89 44 24 08          	mov    %eax,0x8(%esp)
    377b:	c7 44 24 04 89 59 00 	movl   $0x5989,0x4(%esp)
    3782:	00 
    3783:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    378a:	e8 da 07 00 00       	call   3f69 <printf>
    close(fd);
    378f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3792:	89 04 24             	mov    %eax,(%esp)
    3795:	e8 7a 06 00 00       	call   3e14 <close>
    if(total == 0)
    379a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    379e:	0f 84 e6 00 00 00    	je     388a <fsfull+0x29f>
  int nfiles;
  int fsblocks = 0;

  printf(1, "fsfull test\n");

  for(nfiles = 0; ; nfiles++){
    37a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
  }
    37a8:	e9 67 fe ff ff       	jmp    3614 <fsfull+0x29>

  while(nfiles >= 0){
    char name[64];
    name[0] = 'f';
    37ad:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    37b1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    37b4:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    37b9:	89 c8                	mov    %ecx,%eax
    37bb:	f7 ea                	imul   %edx
    37bd:	c1 fa 06             	sar    $0x6,%edx
    37c0:	89 c8                	mov    %ecx,%eax
    37c2:	c1 f8 1f             	sar    $0x1f,%eax
    37c5:	89 d1                	mov    %edx,%ecx
    37c7:	29 c1                	sub    %eax,%ecx
    37c9:	89 c8                	mov    %ecx,%eax
    37cb:	83 c0 30             	add    $0x30,%eax
    37ce:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    37d1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    37d4:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
    37d9:	89 d8                	mov    %ebx,%eax
    37db:	f7 ea                	imul   %edx
    37dd:	c1 fa 06             	sar    $0x6,%edx
    37e0:	89 d8                	mov    %ebx,%eax
    37e2:	c1 f8 1f             	sar    $0x1f,%eax
    37e5:	89 d1                	mov    %edx,%ecx
    37e7:	29 c1                	sub    %eax,%ecx
    37e9:	69 c1 e8 03 00 00    	imul   $0x3e8,%ecx,%eax
    37ef:	89 d9                	mov    %ebx,%ecx
    37f1:	29 c1                	sub    %eax,%ecx
    37f3:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    37f8:	89 c8                	mov    %ecx,%eax
    37fa:	f7 ea                	imul   %edx
    37fc:	c1 fa 05             	sar    $0x5,%edx
    37ff:	89 c8                	mov    %ecx,%eax
    3801:	c1 f8 1f             	sar    $0x1f,%eax
    3804:	89 d1                	mov    %edx,%ecx
    3806:	29 c1                	sub    %eax,%ecx
    3808:	89 c8                	mov    %ecx,%eax
    380a:	83 c0 30             	add    $0x30,%eax
    380d:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    3810:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3813:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
    3818:	89 d8                	mov    %ebx,%eax
    381a:	f7 ea                	imul   %edx
    381c:	c1 fa 05             	sar    $0x5,%edx
    381f:	89 d8                	mov    %ebx,%eax
    3821:	c1 f8 1f             	sar    $0x1f,%eax
    3824:	89 d1                	mov    %edx,%ecx
    3826:	29 c1                	sub    %eax,%ecx
    3828:	6b c1 64             	imul   $0x64,%ecx,%eax
    382b:	89 d9                	mov    %ebx,%ecx
    382d:	29 c1                	sub    %eax,%ecx
    382f:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3834:	89 c8                	mov    %ecx,%eax
    3836:	f7 ea                	imul   %edx
    3838:	c1 fa 02             	sar    $0x2,%edx
    383b:	89 c8                	mov    %ecx,%eax
    383d:	c1 f8 1f             	sar    $0x1f,%eax
    3840:	89 d1                	mov    %edx,%ecx
    3842:	29 c1                	sub    %eax,%ecx
    3844:	89 c8                	mov    %ecx,%eax
    3846:	83 c0 30             	add    $0x30,%eax
    3849:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    384c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    384f:	ba 67 66 66 66       	mov    $0x66666667,%edx
    3854:	89 c8                	mov    %ecx,%eax
    3856:	f7 ea                	imul   %edx
    3858:	c1 fa 02             	sar    $0x2,%edx
    385b:	89 c8                	mov    %ecx,%eax
    385d:	c1 f8 1f             	sar    $0x1f,%eax
    3860:	29 c2                	sub    %eax,%edx
    3862:	89 d0                	mov    %edx,%eax
    3864:	c1 e0 02             	shl    $0x2,%eax
    3867:	01 d0                	add    %edx,%eax
    3869:	01 c0                	add    %eax,%eax
    386b:	89 ca                	mov    %ecx,%edx
    386d:	29 c2                	sub    %eax,%edx
    386f:	89 d0                	mov    %edx,%eax
    3871:	83 c0 30             	add    $0x30,%eax
    3874:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    3877:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    unlink(name);
    387b:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    387e:	89 04 24             	mov    %eax,(%esp)
    3881:	e8 b6 05 00 00       	call   3e3c <unlink>
    nfiles--;
    3886:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    close(fd);
    if(total == 0)
      break;
  }

  while(nfiles >= 0){
    388a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    388e:	0f 89 19 ff ff ff    	jns    37ad <fsfull+0x1c2>
    name[5] = '\0';
    unlink(name);
    nfiles--;
  }

  printf(1, "fsfull test finished\n");
    3894:	c7 44 24 04 99 59 00 	movl   $0x5999,0x4(%esp)
    389b:	00 
    389c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    38a3:	e8 c1 06 00 00       	call   3f69 <printf>
}
    38a8:	83 c4 74             	add    $0x74,%esp
    38ab:	5b                   	pop    %ebx
    38ac:	5d                   	pop    %ebp
    38ad:	c3                   	ret    

000038ae <rand>:

unsigned long randstate = 1;
unsigned int
rand()
{
    38ae:	55                   	push   %ebp
    38af:	89 e5                	mov    %esp,%ebp
  randstate = randstate * 1664525 + 1013904223;
    38b1:	a1 14 61 00 00       	mov    0x6114,%eax
    38b6:	69 c0 0d 66 19 00    	imul   $0x19660d,%eax,%eax
    38bc:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
    38c1:	a3 14 61 00 00       	mov    %eax,0x6114
  return randstate;
    38c6:	a1 14 61 00 00       	mov    0x6114,%eax
}
    38cb:	5d                   	pop    %ebp
    38cc:	c3                   	ret    

000038cd <main>:

int
main(int argc, char *argv[])
{
    38cd:	55                   	push   %ebp
    38ce:	89 e5                	mov    %esp,%ebp
    38d0:	83 e4 f0             	and    $0xfffffff0,%esp
    38d3:	83 ec 10             	sub    $0x10,%esp
  printf(1, "usertests starting\n");
    38d6:	c7 44 24 04 af 59 00 	movl   $0x59af,0x4(%esp)
    38dd:	00 
    38de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    38e5:	e8 7f 06 00 00       	call   3f69 <printf>

  if(open("usertests.ran", 0) >= 0){
    38ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    38f1:	00 
    38f2:	c7 04 24 c3 59 00 00 	movl   $0x59c3,(%esp)
    38f9:	e8 2e 05 00 00       	call   3e2c <open>
    38fe:	85 c0                	test   %eax,%eax
    3900:	78 19                	js     391b <main+0x4e>
    printf(1, "already ran user tests -- rebuild fs.img\n");
    3902:	c7 44 24 04 d4 59 00 	movl   $0x59d4,0x4(%esp)
    3909:	00 
    390a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3911:	e8 53 06 00 00       	call   3f69 <printf>
    exit();
    3916:	e8 c1 04 00 00       	call   3ddc <exit>
  }
  close(open("usertests.ran", O_CREATE));
    391b:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3922:	00 
    3923:	c7 04 24 c3 59 00 00 	movl   $0x59c3,(%esp)
    392a:	e8 fd 04 00 00       	call   3e2c <open>
    392f:	89 04 24             	mov    %eax,(%esp)
    3932:	e8 dd 04 00 00       	call   3e14 <close>

  bigargtest();
    3937:	e8 86 fb ff ff       	call   34c2 <bigargtest>
  bigwrite();
    393c:	e8 ea ea ff ff       	call   242b <bigwrite>
  bigargtest();
    3941:	e8 7c fb ff ff       	call   34c2 <bigargtest>
  bsstest();
    3946:	e8 05 fb ff ff       	call   3450 <bsstest>
  sbrktest();
    394b:	e8 0f f5 ff ff       	call   2e5f <sbrktest>
  validatetest();
    3950:	e8 2e fa ff ff       	call   3383 <validatetest>

  opentest();
    3955:	e8 a6 c6 ff ff       	call   0 <opentest>
  writetest();
    395a:	e8 4c c7 ff ff       	call   ab <writetest>
  writetest1();
    395f:	e8 5c c9 ff ff       	call   2c0 <writetest1>
  createtest();
    3964:	e8 60 cb ff ff       	call   4c9 <createtest>

  mem();
    3969:	e8 01 d1 ff ff       	call   a6f <mem>
  pipe1();
    396e:	e8 37 cd ff ff       	call   6aa <pipe1>
  preempt();
    3973:	e8 20 cf ff ff       	call   898 <preempt>
  exitwait();
    3978:	e8 74 d0 ff ff       	call   9f1 <exitwait>

  rmdot();
    397d:	e8 2c ef ff ff       	call   28ae <rmdot>
  fourteen();
    3982:	e8 d1 ed ff ff       	call   2758 <fourteen>
  bigfile();
    3987:	e8 a7 eb ff ff       	call   2533 <bigfile>
  subdir();
    398c:	e8 54 e3 ff ff       	call   1ce5 <subdir>
  concreate();
    3991:	e8 f3 dc ff ff       	call   1689 <concreate>
  linkunlink();
    3996:	e8 a7 e0 ff ff       	call   1a42 <linkunlink>
  linktest();
    399b:	e8 a0 da ff ff       	call   1440 <linktest>
  unlinkread();
    39a0:	e8 c6 d8 ff ff       	call   126b <unlinkread>
  createdelete();
    39a5:	e8 10 d6 ff ff       	call   fba <createdelete>
  twofiles();
    39aa:	e8 a3 d3 ff ff       	call   d52 <twofiles>
  sharedfd();
    39af:	e8 a0 d1 ff ff       	call   b54 <sharedfd>
  dirfile();
    39b4:	e8 6d f0 ff ff       	call   2a26 <dirfile>
  iref();
    39b9:	e8 aa f2 ff ff       	call   2c68 <iref>
  forktest();
    39be:	e8 c9 f3 ff ff       	call   2d8c <forktest>
  bigdir(); // slow
    39c3:	e8 a8 e1 ff ff       	call   1b70 <bigdir>

  exectest();
    39c8:	e8 8e cc ff ff       	call   65b <exectest>

  exit();
    39cd:	e8 0a 04 00 00       	call   3ddc <exit>
    39d2:	66 90                	xchg   %ax,%ax

000039d4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    39d4:	55                   	push   %ebp
    39d5:	89 e5                	mov    %esp,%ebp
    39d7:	57                   	push   %edi
    39d8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    39d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
    39dc:	8b 55 10             	mov    0x10(%ebp),%edx
    39df:	8b 45 0c             	mov    0xc(%ebp),%eax
    39e2:	89 cb                	mov    %ecx,%ebx
    39e4:	89 df                	mov    %ebx,%edi
    39e6:	89 d1                	mov    %edx,%ecx
    39e8:	fc                   	cld    
    39e9:	f3 aa                	rep stos %al,%es:(%edi)
    39eb:	89 ca                	mov    %ecx,%edx
    39ed:	89 fb                	mov    %edi,%ebx
    39ef:	89 5d 08             	mov    %ebx,0x8(%ebp)
    39f2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    39f5:	5b                   	pop    %ebx
    39f6:	5f                   	pop    %edi
    39f7:	5d                   	pop    %ebp
    39f8:	c3                   	ret    

000039f9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    39f9:	55                   	push   %ebp
    39fa:	89 e5                	mov    %esp,%ebp
    39fc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    39ff:	8b 45 08             	mov    0x8(%ebp),%eax
    3a02:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    3a05:	90                   	nop
    3a06:	8b 45 0c             	mov    0xc(%ebp),%eax
    3a09:	0f b6 10             	movzbl (%eax),%edx
    3a0c:	8b 45 08             	mov    0x8(%ebp),%eax
    3a0f:	88 10                	mov    %dl,(%eax)
    3a11:	8b 45 08             	mov    0x8(%ebp),%eax
    3a14:	0f b6 00             	movzbl (%eax),%eax
    3a17:	84 c0                	test   %al,%al
    3a19:	0f 95 c0             	setne  %al
    3a1c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3a20:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    3a24:	84 c0                	test   %al,%al
    3a26:	75 de                	jne    3a06 <strcpy+0xd>
    ;
  return os;
    3a28:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3a2b:	c9                   	leave  
    3a2c:	c3                   	ret    

00003a2d <strcmp>:

int
strcmp(const char *p, const char *q)
{
    3a2d:	55                   	push   %ebp
    3a2e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    3a30:	eb 08                	jmp    3a3a <strcmp+0xd>
    p++, q++;
    3a32:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3a36:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    3a3a:	8b 45 08             	mov    0x8(%ebp),%eax
    3a3d:	0f b6 00             	movzbl (%eax),%eax
    3a40:	84 c0                	test   %al,%al
    3a42:	74 10                	je     3a54 <strcmp+0x27>
    3a44:	8b 45 08             	mov    0x8(%ebp),%eax
    3a47:	0f b6 10             	movzbl (%eax),%edx
    3a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
    3a4d:	0f b6 00             	movzbl (%eax),%eax
    3a50:	38 c2                	cmp    %al,%dl
    3a52:	74 de                	je     3a32 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    3a54:	8b 45 08             	mov    0x8(%ebp),%eax
    3a57:	0f b6 00             	movzbl (%eax),%eax
    3a5a:	0f b6 d0             	movzbl %al,%edx
    3a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
    3a60:	0f b6 00             	movzbl (%eax),%eax
    3a63:	0f b6 c0             	movzbl %al,%eax
    3a66:	89 d1                	mov    %edx,%ecx
    3a68:	29 c1                	sub    %eax,%ecx
    3a6a:	89 c8                	mov    %ecx,%eax
}
    3a6c:	5d                   	pop    %ebp
    3a6d:	c3                   	ret    

00003a6e <strlen>:

uint
strlen(char *s)
{
    3a6e:	55                   	push   %ebp
    3a6f:	89 e5                	mov    %esp,%ebp
    3a71:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
    3a74:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    3a7b:	eb 04                	jmp    3a81 <strlen+0x13>
    3a7d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    3a81:	8b 55 fc             	mov    -0x4(%ebp),%edx
    3a84:	8b 45 08             	mov    0x8(%ebp),%eax
    3a87:	01 d0                	add    %edx,%eax
    3a89:	0f b6 00             	movzbl (%eax),%eax
    3a8c:	84 c0                	test   %al,%al
    3a8e:	75 ed                	jne    3a7d <strlen+0xf>
  return n;
    3a90:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3a93:	c9                   	leave  
    3a94:	c3                   	ret    

00003a95 <memset>:

void*
memset(void *dst, int c, uint n)
{
    3a95:	55                   	push   %ebp
    3a96:	89 e5                	mov    %esp,%ebp
    3a98:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    3a9b:	8b 45 10             	mov    0x10(%ebp),%eax
    3a9e:	89 44 24 08          	mov    %eax,0x8(%esp)
    3aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
    3aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
    3aa9:	8b 45 08             	mov    0x8(%ebp),%eax
    3aac:	89 04 24             	mov    %eax,(%esp)
    3aaf:	e8 20 ff ff ff       	call   39d4 <stosb>
  return dst;
    3ab4:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3ab7:	c9                   	leave  
    3ab8:	c3                   	ret    

00003ab9 <strchr>:

char*
strchr(const char *s, char c)
{
    3ab9:	55                   	push   %ebp
    3aba:	89 e5                	mov    %esp,%ebp
    3abc:	83 ec 04             	sub    $0x4,%esp
    3abf:	8b 45 0c             	mov    0xc(%ebp),%eax
    3ac2:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    3ac5:	eb 14                	jmp    3adb <strchr+0x22>
    if(*s == c)
    3ac7:	8b 45 08             	mov    0x8(%ebp),%eax
    3aca:	0f b6 00             	movzbl (%eax),%eax
    3acd:	3a 45 fc             	cmp    -0x4(%ebp),%al
    3ad0:	75 05                	jne    3ad7 <strchr+0x1e>
      return (char*)s;
    3ad2:	8b 45 08             	mov    0x8(%ebp),%eax
    3ad5:	eb 13                	jmp    3aea <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    3ad7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3adb:	8b 45 08             	mov    0x8(%ebp),%eax
    3ade:	0f b6 00             	movzbl (%eax),%eax
    3ae1:	84 c0                	test   %al,%al
    3ae3:	75 e2                	jne    3ac7 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    3ae5:	b8 00 00 00 00       	mov    $0x0,%eax
}
    3aea:	c9                   	leave  
    3aeb:	c3                   	ret    

00003aec <gets>:

char*
gets(char *buf, int max)
{
    3aec:	55                   	push   %ebp
    3aed:	89 e5                	mov    %esp,%ebp
    3aef:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3af2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3af9:	eb 46                	jmp    3b41 <gets+0x55>
    cc = read(0, &c, 1);
    3afb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3b02:	00 
    3b03:	8d 45 ef             	lea    -0x11(%ebp),%eax
    3b06:	89 44 24 04          	mov    %eax,0x4(%esp)
    3b0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3b11:	e8 ee 02 00 00       	call   3e04 <read>
    3b16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    3b19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3b1d:	7e 2f                	jle    3b4e <gets+0x62>
      break;
    buf[i++] = c;
    3b1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3b22:	8b 45 08             	mov    0x8(%ebp),%eax
    3b25:	01 c2                	add    %eax,%edx
    3b27:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    3b2b:	88 02                	mov    %al,(%edx)
    3b2d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
    3b31:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    3b35:	3c 0a                	cmp    $0xa,%al
    3b37:	74 16                	je     3b4f <gets+0x63>
    3b39:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    3b3d:	3c 0d                	cmp    $0xd,%al
    3b3f:	74 0e                	je     3b4f <gets+0x63>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3b44:	83 c0 01             	add    $0x1,%eax
    3b47:	3b 45 0c             	cmp    0xc(%ebp),%eax
    3b4a:	7c af                	jl     3afb <gets+0xf>
    3b4c:	eb 01                	jmp    3b4f <gets+0x63>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    3b4e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    3b4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3b52:	8b 45 08             	mov    0x8(%ebp),%eax
    3b55:	01 d0                	add    %edx,%eax
    3b57:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    3b5a:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3b5d:	c9                   	leave  
    3b5e:	c3                   	ret    

00003b5f <stat>:

int
stat(char *n, struct stat *st)
{
    3b5f:	55                   	push   %ebp
    3b60:	89 e5                	mov    %esp,%ebp
    3b62:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    3b65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3b6c:	00 
    3b6d:	8b 45 08             	mov    0x8(%ebp),%eax
    3b70:	89 04 24             	mov    %eax,(%esp)
    3b73:	e8 b4 02 00 00       	call   3e2c <open>
    3b78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    3b7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3b7f:	79 07                	jns    3b88 <stat+0x29>
    return -1;
    3b81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    3b86:	eb 23                	jmp    3bab <stat+0x4c>
  r = fstat(fd, st);
    3b88:	8b 45 0c             	mov    0xc(%ebp),%eax
    3b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
    3b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3b92:	89 04 24             	mov    %eax,(%esp)
    3b95:	e8 aa 02 00 00       	call   3e44 <fstat>
    3b9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    3b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3ba0:	89 04 24             	mov    %eax,(%esp)
    3ba3:	e8 6c 02 00 00       	call   3e14 <close>
  return r;
    3ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    3bab:	c9                   	leave  
    3bac:	c3                   	ret    

00003bad <atoi>:

int
atoi(const char *s)
{
    3bad:	55                   	push   %ebp
    3bae:	89 e5                	mov    %esp,%ebp
    3bb0:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    3bb3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    3bba:	eb 23                	jmp    3bdf <atoi+0x32>
    n = n*10 + *s++ - '0';
    3bbc:	8b 55 fc             	mov    -0x4(%ebp),%edx
    3bbf:	89 d0                	mov    %edx,%eax
    3bc1:	c1 e0 02             	shl    $0x2,%eax
    3bc4:	01 d0                	add    %edx,%eax
    3bc6:	01 c0                	add    %eax,%eax
    3bc8:	89 c2                	mov    %eax,%edx
    3bca:	8b 45 08             	mov    0x8(%ebp),%eax
    3bcd:	0f b6 00             	movzbl (%eax),%eax
    3bd0:	0f be c0             	movsbl %al,%eax
    3bd3:	01 d0                	add    %edx,%eax
    3bd5:	83 e8 30             	sub    $0x30,%eax
    3bd8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    3bdb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    3bdf:	8b 45 08             	mov    0x8(%ebp),%eax
    3be2:	0f b6 00             	movzbl (%eax),%eax
    3be5:	3c 2f                	cmp    $0x2f,%al
    3be7:	7e 0a                	jle    3bf3 <atoi+0x46>
    3be9:	8b 45 08             	mov    0x8(%ebp),%eax
    3bec:	0f b6 00             	movzbl (%eax),%eax
    3bef:	3c 39                	cmp    $0x39,%al
    3bf1:	7e c9                	jle    3bbc <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    3bf3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3bf6:	c9                   	leave  
    3bf7:	c3                   	ret    

00003bf8 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    3bf8:	55                   	push   %ebp
    3bf9:	89 e5                	mov    %esp,%ebp
    3bfb:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
    3bfe:	8b 45 08             	mov    0x8(%ebp),%eax
    3c01:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    3c04:	8b 45 0c             	mov    0xc(%ebp),%eax
    3c07:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    3c0a:	eb 13                	jmp    3c1f <memmove+0x27>
    *dst++ = *src++;
    3c0c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    3c0f:	0f b6 10             	movzbl (%eax),%edx
    3c12:	8b 45 fc             	mov    -0x4(%ebp),%eax
    3c15:	88 10                	mov    %dl,(%eax)
    3c17:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    3c1b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    3c1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    3c23:	0f 9f c0             	setg   %al
    3c26:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    3c2a:	84 c0                	test   %al,%al
    3c2c:	75 de                	jne    3c0c <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    3c2e:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3c31:	c9                   	leave  
    3c32:	c3                   	ret    

00003c33 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
    3c33:	55                   	push   %ebp
    3c34:	89 e5                	mov    %esp,%ebp
    3c36:	83 ec 38             	sub    $0x38,%esp
    3c39:	8b 45 10             	mov    0x10(%ebp),%eax
    3c3c:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
    3c3f:	8b 45 14             	mov    0x14(%ebp),%eax
    3c42:	8b 00                	mov    (%eax),%eax
    3c44:	89 45 f4             	mov    %eax,-0xc(%ebp)
    3c47:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
    3c4e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    3c52:	74 06                	je     3c5a <strtok+0x27>
    3c54:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
    3c58:	75 5a                	jne    3cb4 <strtok+0x81>
    return match;
    3c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3c5d:	eb 76                	jmp    3cd5 <strtok+0xa2>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
    3c5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3c62:	8b 45 0c             	mov    0xc(%ebp),%eax
    3c65:	01 d0                	add    %edx,%eax
    3c67:	0f b6 00             	movzbl (%eax),%eax
    3c6a:	3a 45 e4             	cmp    -0x1c(%ebp),%al
    3c6d:	74 06                	je     3c75 <strtok+0x42>
      {
	index++;
    3c6f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    3c73:	eb 40                	jmp    3cb5 <strtok+0x82>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
    3c75:	8b 45 14             	mov    0x14(%ebp),%eax
    3c78:	8b 00                	mov    (%eax),%eax
    3c7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3c7d:	29 c2                	sub    %eax,%edx
    3c7f:	8b 45 14             	mov    0x14(%ebp),%eax
    3c82:	8b 00                	mov    (%eax),%eax
    3c84:	89 c1                	mov    %eax,%ecx
    3c86:	8b 45 0c             	mov    0xc(%ebp),%eax
    3c89:	01 c8                	add    %ecx,%eax
    3c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
    3c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
    3c93:	8b 45 08             	mov    0x8(%ebp),%eax
    3c96:	89 04 24             	mov    %eax,(%esp)
    3c99:	e8 39 00 00 00       	call   3cd7 <strncpy>
    3c9e:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
    3ca1:	8b 45 08             	mov    0x8(%ebp),%eax
    3ca4:	0f b6 00             	movzbl (%eax),%eax
    3ca7:	84 c0                	test   %al,%al
    3ca9:	74 1b                	je     3cc6 <strtok+0x93>
	  match = 1;
    3cab:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
    3cb2:	eb 12                	jmp    3cc6 <strtok+0x93>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
    3cb4:	90                   	nop
    3cb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
    3cbb:	01 d0                	add    %edx,%eax
    3cbd:	0f b6 00             	movzbl (%eax),%eax
    3cc0:	84 c0                	test   %al,%al
    3cc2:	75 9b                	jne    3c5f <strtok+0x2c>
    3cc4:	eb 01                	jmp    3cc7 <strtok+0x94>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
    3cc6:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
    3cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3cca:	8d 50 01             	lea    0x1(%eax),%edx
    3ccd:	8b 45 14             	mov    0x14(%ebp),%eax
    3cd0:	89 10                	mov    %edx,(%eax)
  return match;
    3cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    3cd5:	c9                   	leave  
    3cd6:	c3                   	ret    

00003cd7 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    3cd7:	55                   	push   %ebp
    3cd8:	89 e5                	mov    %esp,%ebp
    3cda:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
    3cdd:	8b 45 08             	mov    0x8(%ebp),%eax
    3ce0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
    3ce3:	90                   	nop
    3ce4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    3ce8:	0f 9f c0             	setg   %al
    3ceb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    3cef:	84 c0                	test   %al,%al
    3cf1:	74 30                	je     3d23 <strncpy+0x4c>
    3cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
    3cf6:	0f b6 10             	movzbl (%eax),%edx
    3cf9:	8b 45 08             	mov    0x8(%ebp),%eax
    3cfc:	88 10                	mov    %dl,(%eax)
    3cfe:	8b 45 08             	mov    0x8(%ebp),%eax
    3d01:	0f b6 00             	movzbl (%eax),%eax
    3d04:	84 c0                	test   %al,%al
    3d06:	0f 95 c0             	setne  %al
    3d09:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3d0d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    3d11:	84 c0                	test   %al,%al
    3d13:	75 cf                	jne    3ce4 <strncpy+0xd>
    ;
  while(n-- > 0)
    3d15:	eb 0c                	jmp    3d23 <strncpy+0x4c>
    *s++ = 0;
    3d17:	8b 45 08             	mov    0x8(%ebp),%eax
    3d1a:	c6 00 00             	movb   $0x0,(%eax)
    3d1d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3d21:	eb 01                	jmp    3d24 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
    3d23:	90                   	nop
    3d24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    3d28:	0f 9f c0             	setg   %al
    3d2b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    3d2f:	84 c0                	test   %al,%al
    3d31:	75 e4                	jne    3d17 <strncpy+0x40>
    *s++ = 0;
  return os;
    3d33:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3d36:	c9                   	leave  
    3d37:	c3                   	ret    

00003d38 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    3d38:	55                   	push   %ebp
    3d39:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
    3d3b:	eb 0c                	jmp    3d49 <strncmp+0x11>
    n--, p++, q++;
    3d3d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    3d41:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3d45:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
    3d49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    3d4d:	74 1a                	je     3d69 <strncmp+0x31>
    3d4f:	8b 45 08             	mov    0x8(%ebp),%eax
    3d52:	0f b6 00             	movzbl (%eax),%eax
    3d55:	84 c0                	test   %al,%al
    3d57:	74 10                	je     3d69 <strncmp+0x31>
    3d59:	8b 45 08             	mov    0x8(%ebp),%eax
    3d5c:	0f b6 10             	movzbl (%eax),%edx
    3d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
    3d62:	0f b6 00             	movzbl (%eax),%eax
    3d65:	38 c2                	cmp    %al,%dl
    3d67:	74 d4                	je     3d3d <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
    3d69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
    3d6d:	75 07                	jne    3d76 <strncmp+0x3e>
    return 0;
    3d6f:	b8 00 00 00 00       	mov    $0x0,%eax
    3d74:	eb 18                	jmp    3d8e <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
    3d76:	8b 45 08             	mov    0x8(%ebp),%eax
    3d79:	0f b6 00             	movzbl (%eax),%eax
    3d7c:	0f b6 d0             	movzbl %al,%edx
    3d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
    3d82:	0f b6 00             	movzbl (%eax),%eax
    3d85:	0f b6 c0             	movzbl %al,%eax
    3d88:	89 d1                	mov    %edx,%ecx
    3d8a:	29 c1                	sub    %eax,%ecx
    3d8c:	89 c8                	mov    %ecx,%eax
}
    3d8e:	5d                   	pop    %ebp
    3d8f:	c3                   	ret    

00003d90 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
    3d90:	55                   	push   %ebp
    3d91:	89 e5                	mov    %esp,%ebp
  while(*p){
    3d93:	eb 13                	jmp    3da8 <strcat+0x18>
    *dest++ = *p++;
    3d95:	8b 45 0c             	mov    0xc(%ebp),%eax
    3d98:	0f b6 10             	movzbl (%eax),%edx
    3d9b:	8b 45 08             	mov    0x8(%ebp),%eax
    3d9e:	88 10                	mov    %dl,(%eax)
    3da0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3da4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    3da8:	8b 45 0c             	mov    0xc(%ebp),%eax
    3dab:	0f b6 00             	movzbl (%eax),%eax
    3dae:	84 c0                	test   %al,%al
    3db0:	75 e3                	jne    3d95 <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
    3db2:	eb 13                	jmp    3dc7 <strcat+0x37>
    *dest++ = *q++;
    3db4:	8b 45 10             	mov    0x10(%ebp),%eax
    3db7:	0f b6 10             	movzbl (%eax),%edx
    3dba:	8b 45 08             	mov    0x8(%ebp),%eax
    3dbd:	88 10                	mov    %dl,(%eax)
    3dbf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    3dc3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
    3dc7:	8b 45 10             	mov    0x10(%ebp),%eax
    3dca:	0f b6 00             	movzbl (%eax),%eax
    3dcd:	84 c0                	test   %al,%al
    3dcf:	75 e3                	jne    3db4 <strcat+0x24>
    *dest++ = *q++;
  }  
    3dd1:	5d                   	pop    %ebp
    3dd2:	c3                   	ret    
    3dd3:	90                   	nop

00003dd4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    3dd4:	b8 01 00 00 00       	mov    $0x1,%eax
    3dd9:	cd 40                	int    $0x40
    3ddb:	c3                   	ret    

00003ddc <exit>:
SYSCALL(exit)
    3ddc:	b8 02 00 00 00       	mov    $0x2,%eax
    3de1:	cd 40                	int    $0x40
    3de3:	c3                   	ret    

00003de4 <wait>:
SYSCALL(wait)
    3de4:	b8 03 00 00 00       	mov    $0x3,%eax
    3de9:	cd 40                	int    $0x40
    3deb:	c3                   	ret    

00003dec <wait2>:
SYSCALL(wait2)
    3dec:	b8 16 00 00 00       	mov    $0x16,%eax
    3df1:	cd 40                	int    $0x40
    3df3:	c3                   	ret    

00003df4 <nice>:
SYSCALL(nice)
    3df4:	b8 17 00 00 00       	mov    $0x17,%eax
    3df9:	cd 40                	int    $0x40
    3dfb:	c3                   	ret    

00003dfc <pipe>:
SYSCALL(pipe)
    3dfc:	b8 04 00 00 00       	mov    $0x4,%eax
    3e01:	cd 40                	int    $0x40
    3e03:	c3                   	ret    

00003e04 <read>:
SYSCALL(read)
    3e04:	b8 05 00 00 00       	mov    $0x5,%eax
    3e09:	cd 40                	int    $0x40
    3e0b:	c3                   	ret    

00003e0c <write>:
SYSCALL(write)
    3e0c:	b8 10 00 00 00       	mov    $0x10,%eax
    3e11:	cd 40                	int    $0x40
    3e13:	c3                   	ret    

00003e14 <close>:
SYSCALL(close)
    3e14:	b8 15 00 00 00       	mov    $0x15,%eax
    3e19:	cd 40                	int    $0x40
    3e1b:	c3                   	ret    

00003e1c <kill>:
SYSCALL(kill)
    3e1c:	b8 06 00 00 00       	mov    $0x6,%eax
    3e21:	cd 40                	int    $0x40
    3e23:	c3                   	ret    

00003e24 <exec>:
SYSCALL(exec)
    3e24:	b8 07 00 00 00       	mov    $0x7,%eax
    3e29:	cd 40                	int    $0x40
    3e2b:	c3                   	ret    

00003e2c <open>:
SYSCALL(open)
    3e2c:	b8 0f 00 00 00       	mov    $0xf,%eax
    3e31:	cd 40                	int    $0x40
    3e33:	c3                   	ret    

00003e34 <mknod>:
SYSCALL(mknod)
    3e34:	b8 11 00 00 00       	mov    $0x11,%eax
    3e39:	cd 40                	int    $0x40
    3e3b:	c3                   	ret    

00003e3c <unlink>:
SYSCALL(unlink)
    3e3c:	b8 12 00 00 00       	mov    $0x12,%eax
    3e41:	cd 40                	int    $0x40
    3e43:	c3                   	ret    

00003e44 <fstat>:
SYSCALL(fstat)
    3e44:	b8 08 00 00 00       	mov    $0x8,%eax
    3e49:	cd 40                	int    $0x40
    3e4b:	c3                   	ret    

00003e4c <link>:
SYSCALL(link)
    3e4c:	b8 13 00 00 00       	mov    $0x13,%eax
    3e51:	cd 40                	int    $0x40
    3e53:	c3                   	ret    

00003e54 <mkdir>:
SYSCALL(mkdir)
    3e54:	b8 14 00 00 00       	mov    $0x14,%eax
    3e59:	cd 40                	int    $0x40
    3e5b:	c3                   	ret    

00003e5c <chdir>:
SYSCALL(chdir)
    3e5c:	b8 09 00 00 00       	mov    $0x9,%eax
    3e61:	cd 40                	int    $0x40
    3e63:	c3                   	ret    

00003e64 <dup>:
SYSCALL(dup)
    3e64:	b8 0a 00 00 00       	mov    $0xa,%eax
    3e69:	cd 40                	int    $0x40
    3e6b:	c3                   	ret    

00003e6c <getpid>:
SYSCALL(getpid)
    3e6c:	b8 0b 00 00 00       	mov    $0xb,%eax
    3e71:	cd 40                	int    $0x40
    3e73:	c3                   	ret    

00003e74 <sbrk>:
SYSCALL(sbrk)
    3e74:	b8 0c 00 00 00       	mov    $0xc,%eax
    3e79:	cd 40                	int    $0x40
    3e7b:	c3                   	ret    

00003e7c <sleep>:
SYSCALL(sleep)
    3e7c:	b8 0d 00 00 00       	mov    $0xd,%eax
    3e81:	cd 40                	int    $0x40
    3e83:	c3                   	ret    

00003e84 <uptime>:
SYSCALL(uptime)
    3e84:	b8 0e 00 00 00       	mov    $0xe,%eax
    3e89:	cd 40                	int    $0x40
    3e8b:	c3                   	ret    

00003e8c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    3e8c:	55                   	push   %ebp
    3e8d:	89 e5                	mov    %esp,%ebp
    3e8f:	83 ec 28             	sub    $0x28,%esp
    3e92:	8b 45 0c             	mov    0xc(%ebp),%eax
    3e95:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    3e98:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3e9f:	00 
    3ea0:	8d 45 f4             	lea    -0xc(%ebp),%eax
    3ea3:	89 44 24 04          	mov    %eax,0x4(%esp)
    3ea7:	8b 45 08             	mov    0x8(%ebp),%eax
    3eaa:	89 04 24             	mov    %eax,(%esp)
    3ead:	e8 5a ff ff ff       	call   3e0c <write>
}
    3eb2:	c9                   	leave  
    3eb3:	c3                   	ret    

00003eb4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    3eb4:	55                   	push   %ebp
    3eb5:	89 e5                	mov    %esp,%ebp
    3eb7:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    3eba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    3ec1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    3ec5:	74 17                	je     3ede <printint+0x2a>
    3ec7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    3ecb:	79 11                	jns    3ede <printint+0x2a>
    neg = 1;
    3ecd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    3ed4:	8b 45 0c             	mov    0xc(%ebp),%eax
    3ed7:	f7 d8                	neg    %eax
    3ed9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    3edc:	eb 06                	jmp    3ee4 <printint+0x30>
  } else {
    x = xx;
    3ede:	8b 45 0c             	mov    0xc(%ebp),%eax
    3ee1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    3ee4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    3eeb:	8b 4d 10             	mov    0x10(%ebp),%ecx
    3eee:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3ef1:	ba 00 00 00 00       	mov    $0x0,%edx
    3ef6:	f7 f1                	div    %ecx
    3ef8:	89 d0                	mov    %edx,%eax
    3efa:	0f b6 80 18 61 00 00 	movzbl 0x6118(%eax),%eax
    3f01:	8d 4d dc             	lea    -0x24(%ebp),%ecx
    3f04:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3f07:	01 ca                	add    %ecx,%edx
    3f09:	88 02                	mov    %al,(%edx)
    3f0b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
    3f0f:	8b 55 10             	mov    0x10(%ebp),%edx
    3f12:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    3f15:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3f18:	ba 00 00 00 00       	mov    $0x0,%edx
    3f1d:	f7 75 d4             	divl   -0x2c(%ebp)
    3f20:	89 45 ec             	mov    %eax,-0x14(%ebp)
    3f23:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3f27:	75 c2                	jne    3eeb <printint+0x37>
  if(neg)
    3f29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3f2d:	74 2e                	je     3f5d <printint+0xa9>
    buf[i++] = '-';
    3f2f:	8d 55 dc             	lea    -0x24(%ebp),%edx
    3f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3f35:	01 d0                	add    %edx,%eax
    3f37:	c6 00 2d             	movb   $0x2d,(%eax)
    3f3a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
    3f3e:	eb 1d                	jmp    3f5d <printint+0xa9>
    putc(fd, buf[i]);
    3f40:	8d 55 dc             	lea    -0x24(%ebp),%edx
    3f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3f46:	01 d0                	add    %edx,%eax
    3f48:	0f b6 00             	movzbl (%eax),%eax
    3f4b:	0f be c0             	movsbl %al,%eax
    3f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
    3f52:	8b 45 08             	mov    0x8(%ebp),%eax
    3f55:	89 04 24             	mov    %eax,(%esp)
    3f58:	e8 2f ff ff ff       	call   3e8c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    3f5d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
    3f61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3f65:	79 d9                	jns    3f40 <printint+0x8c>
    putc(fd, buf[i]);
}
    3f67:	c9                   	leave  
    3f68:	c3                   	ret    

00003f69 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    3f69:	55                   	push   %ebp
    3f6a:	89 e5                	mov    %esp,%ebp
    3f6c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    3f6f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    3f76:	8d 45 0c             	lea    0xc(%ebp),%eax
    3f79:	83 c0 04             	add    $0x4,%eax
    3f7c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    3f7f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    3f86:	e9 7d 01 00 00       	jmp    4108 <printf+0x19f>
    c = fmt[i] & 0xff;
    3f8b:	8b 55 0c             	mov    0xc(%ebp),%edx
    3f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3f91:	01 d0                	add    %edx,%eax
    3f93:	0f b6 00             	movzbl (%eax),%eax
    3f96:	0f be c0             	movsbl %al,%eax
    3f99:	25 ff 00 00 00       	and    $0xff,%eax
    3f9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    3fa1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    3fa5:	75 2c                	jne    3fd3 <printf+0x6a>
      if(c == '%'){
    3fa7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    3fab:	75 0c                	jne    3fb9 <printf+0x50>
        state = '%';
    3fad:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    3fb4:	e9 4b 01 00 00       	jmp    4104 <printf+0x19b>
      } else {
        putc(fd, c);
    3fb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    3fbc:	0f be c0             	movsbl %al,%eax
    3fbf:	89 44 24 04          	mov    %eax,0x4(%esp)
    3fc3:	8b 45 08             	mov    0x8(%ebp),%eax
    3fc6:	89 04 24             	mov    %eax,(%esp)
    3fc9:	e8 be fe ff ff       	call   3e8c <putc>
    3fce:	e9 31 01 00 00       	jmp    4104 <printf+0x19b>
      }
    } else if(state == '%'){
    3fd3:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    3fd7:	0f 85 27 01 00 00    	jne    4104 <printf+0x19b>
      if(c == 'd'){
    3fdd:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    3fe1:	75 2d                	jne    4010 <printf+0xa7>
        printint(fd, *ap, 10, 1);
    3fe3:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3fe6:	8b 00                	mov    (%eax),%eax
    3fe8:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    3fef:	00 
    3ff0:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    3ff7:	00 
    3ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
    3ffc:	8b 45 08             	mov    0x8(%ebp),%eax
    3fff:	89 04 24             	mov    %eax,(%esp)
    4002:	e8 ad fe ff ff       	call   3eb4 <printint>
        ap++;
    4007:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    400b:	e9 ed 00 00 00       	jmp    40fd <printf+0x194>
      } else if(c == 'x' || c == 'p'){
    4010:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    4014:	74 06                	je     401c <printf+0xb3>
    4016:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    401a:	75 2d                	jne    4049 <printf+0xe0>
        printint(fd, *ap, 16, 0);
    401c:	8b 45 e8             	mov    -0x18(%ebp),%eax
    401f:	8b 00                	mov    (%eax),%eax
    4021:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    4028:	00 
    4029:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    4030:	00 
    4031:	89 44 24 04          	mov    %eax,0x4(%esp)
    4035:	8b 45 08             	mov    0x8(%ebp),%eax
    4038:	89 04 24             	mov    %eax,(%esp)
    403b:	e8 74 fe ff ff       	call   3eb4 <printint>
        ap++;
    4040:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    4044:	e9 b4 00 00 00       	jmp    40fd <printf+0x194>
      } else if(c == 's'){
    4049:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    404d:	75 46                	jne    4095 <printf+0x12c>
        s = (char*)*ap;
    404f:	8b 45 e8             	mov    -0x18(%ebp),%eax
    4052:	8b 00                	mov    (%eax),%eax
    4054:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    4057:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    405b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    405f:	75 27                	jne    4088 <printf+0x11f>
          s = "(null)";
    4061:	c7 45 f4 fe 59 00 00 	movl   $0x59fe,-0xc(%ebp)
        while(*s != 0){
    4068:	eb 1e                	jmp    4088 <printf+0x11f>
          putc(fd, *s);
    406a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    406d:	0f b6 00             	movzbl (%eax),%eax
    4070:	0f be c0             	movsbl %al,%eax
    4073:	89 44 24 04          	mov    %eax,0x4(%esp)
    4077:	8b 45 08             	mov    0x8(%ebp),%eax
    407a:	89 04 24             	mov    %eax,(%esp)
    407d:	e8 0a fe ff ff       	call   3e8c <putc>
          s++;
    4082:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    4086:	eb 01                	jmp    4089 <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    4088:	90                   	nop
    4089:	8b 45 f4             	mov    -0xc(%ebp),%eax
    408c:	0f b6 00             	movzbl (%eax),%eax
    408f:	84 c0                	test   %al,%al
    4091:	75 d7                	jne    406a <printf+0x101>
    4093:	eb 68                	jmp    40fd <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    4095:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    4099:	75 1d                	jne    40b8 <printf+0x14f>
        putc(fd, *ap);
    409b:	8b 45 e8             	mov    -0x18(%ebp),%eax
    409e:	8b 00                	mov    (%eax),%eax
    40a0:	0f be c0             	movsbl %al,%eax
    40a3:	89 44 24 04          	mov    %eax,0x4(%esp)
    40a7:	8b 45 08             	mov    0x8(%ebp),%eax
    40aa:	89 04 24             	mov    %eax,(%esp)
    40ad:	e8 da fd ff ff       	call   3e8c <putc>
        ap++;
    40b2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    40b6:	eb 45                	jmp    40fd <printf+0x194>
      } else if(c == '%'){
    40b8:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    40bc:	75 17                	jne    40d5 <printf+0x16c>
        putc(fd, c);
    40be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    40c1:	0f be c0             	movsbl %al,%eax
    40c4:	89 44 24 04          	mov    %eax,0x4(%esp)
    40c8:	8b 45 08             	mov    0x8(%ebp),%eax
    40cb:	89 04 24             	mov    %eax,(%esp)
    40ce:	e8 b9 fd ff ff       	call   3e8c <putc>
    40d3:	eb 28                	jmp    40fd <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    40d5:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    40dc:	00 
    40dd:	8b 45 08             	mov    0x8(%ebp),%eax
    40e0:	89 04 24             	mov    %eax,(%esp)
    40e3:	e8 a4 fd ff ff       	call   3e8c <putc>
        putc(fd, c);
    40e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    40eb:	0f be c0             	movsbl %al,%eax
    40ee:	89 44 24 04          	mov    %eax,0x4(%esp)
    40f2:	8b 45 08             	mov    0x8(%ebp),%eax
    40f5:	89 04 24             	mov    %eax,(%esp)
    40f8:	e8 8f fd ff ff       	call   3e8c <putc>
      }
      state = 0;
    40fd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    4104:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    4108:	8b 55 0c             	mov    0xc(%ebp),%edx
    410b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    410e:	01 d0                	add    %edx,%eax
    4110:	0f b6 00             	movzbl (%eax),%eax
    4113:	84 c0                	test   %al,%al
    4115:	0f 85 70 fe ff ff    	jne    3f8b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    411b:	c9                   	leave  
    411c:	c3                   	ret    
    411d:	66 90                	xchg   %ax,%ax
    411f:	90                   	nop

00004120 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    4120:	55                   	push   %ebp
    4121:	89 e5                	mov    %esp,%ebp
    4123:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    4126:	8b 45 08             	mov    0x8(%ebp),%eax
    4129:	83 e8 08             	sub    $0x8,%eax
    412c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    412f:	a1 c8 61 00 00       	mov    0x61c8,%eax
    4134:	89 45 fc             	mov    %eax,-0x4(%ebp)
    4137:	eb 24                	jmp    415d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    4139:	8b 45 fc             	mov    -0x4(%ebp),%eax
    413c:	8b 00                	mov    (%eax),%eax
    413e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    4141:	77 12                	ja     4155 <free+0x35>
    4143:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4146:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    4149:	77 24                	ja     416f <free+0x4f>
    414b:	8b 45 fc             	mov    -0x4(%ebp),%eax
    414e:	8b 00                	mov    (%eax),%eax
    4150:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    4153:	77 1a                	ja     416f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4155:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4158:	8b 00                	mov    (%eax),%eax
    415a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    415d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4160:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    4163:	76 d4                	jbe    4139 <free+0x19>
    4165:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4168:	8b 00                	mov    (%eax),%eax
    416a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    416d:	76 ca                	jbe    4139 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    416f:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4172:	8b 40 04             	mov    0x4(%eax),%eax
    4175:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    417c:	8b 45 f8             	mov    -0x8(%ebp),%eax
    417f:	01 c2                	add    %eax,%edx
    4181:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4184:	8b 00                	mov    (%eax),%eax
    4186:	39 c2                	cmp    %eax,%edx
    4188:	75 24                	jne    41ae <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    418a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    418d:	8b 50 04             	mov    0x4(%eax),%edx
    4190:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4193:	8b 00                	mov    (%eax),%eax
    4195:	8b 40 04             	mov    0x4(%eax),%eax
    4198:	01 c2                	add    %eax,%edx
    419a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    419d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    41a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
    41a3:	8b 00                	mov    (%eax),%eax
    41a5:	8b 10                	mov    (%eax),%edx
    41a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    41aa:	89 10                	mov    %edx,(%eax)
    41ac:	eb 0a                	jmp    41b8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    41ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
    41b1:	8b 10                	mov    (%eax),%edx
    41b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    41b6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    41b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    41bb:	8b 40 04             	mov    0x4(%eax),%eax
    41be:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    41c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
    41c8:	01 d0                	add    %edx,%eax
    41ca:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    41cd:	75 20                	jne    41ef <free+0xcf>
    p->s.size += bp->s.size;
    41cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
    41d2:	8b 50 04             	mov    0x4(%eax),%edx
    41d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
    41d8:	8b 40 04             	mov    0x4(%eax),%eax
    41db:	01 c2                	add    %eax,%edx
    41dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
    41e0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    41e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    41e6:	8b 10                	mov    (%eax),%edx
    41e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    41eb:	89 10                	mov    %edx,(%eax)
    41ed:	eb 08                	jmp    41f7 <free+0xd7>
  } else
    p->s.ptr = bp;
    41ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
    41f2:	8b 55 f8             	mov    -0x8(%ebp),%edx
    41f5:	89 10                	mov    %edx,(%eax)
  freep = p;
    41f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
    41fa:	a3 c8 61 00 00       	mov    %eax,0x61c8
}
    41ff:	c9                   	leave  
    4200:	c3                   	ret    

00004201 <morecore>:

static Header*
morecore(uint nu)
{
    4201:	55                   	push   %ebp
    4202:	89 e5                	mov    %esp,%ebp
    4204:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    4207:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    420e:	77 07                	ja     4217 <morecore+0x16>
    nu = 4096;
    4210:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    4217:	8b 45 08             	mov    0x8(%ebp),%eax
    421a:	c1 e0 03             	shl    $0x3,%eax
    421d:	89 04 24             	mov    %eax,(%esp)
    4220:	e8 4f fc ff ff       	call   3e74 <sbrk>
    4225:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    4228:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    422c:	75 07                	jne    4235 <morecore+0x34>
    return 0;
    422e:	b8 00 00 00 00       	mov    $0x0,%eax
    4233:	eb 22                	jmp    4257 <morecore+0x56>
  hp = (Header*)p;
    4235:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4238:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    423b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    423e:	8b 55 08             	mov    0x8(%ebp),%edx
    4241:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    4244:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4247:	83 c0 08             	add    $0x8,%eax
    424a:	89 04 24             	mov    %eax,(%esp)
    424d:	e8 ce fe ff ff       	call   4120 <free>
  return freep;
    4252:	a1 c8 61 00 00       	mov    0x61c8,%eax
}
    4257:	c9                   	leave  
    4258:	c3                   	ret    

00004259 <malloc>:

void*
malloc(uint nbytes)
{
    4259:	55                   	push   %ebp
    425a:	89 e5                	mov    %esp,%ebp
    425c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    425f:	8b 45 08             	mov    0x8(%ebp),%eax
    4262:	83 c0 07             	add    $0x7,%eax
    4265:	c1 e8 03             	shr    $0x3,%eax
    4268:	83 c0 01             	add    $0x1,%eax
    426b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    426e:	a1 c8 61 00 00       	mov    0x61c8,%eax
    4273:	89 45 f0             	mov    %eax,-0x10(%ebp)
    4276:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    427a:	75 23                	jne    429f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
    427c:	c7 45 f0 c0 61 00 00 	movl   $0x61c0,-0x10(%ebp)
    4283:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4286:	a3 c8 61 00 00       	mov    %eax,0x61c8
    428b:	a1 c8 61 00 00       	mov    0x61c8,%eax
    4290:	a3 c0 61 00 00       	mov    %eax,0x61c0
    base.s.size = 0;
    4295:	c7 05 c4 61 00 00 00 	movl   $0x0,0x61c4
    429c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    429f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    42a2:	8b 00                	mov    (%eax),%eax
    42a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    42a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    42aa:	8b 40 04             	mov    0x4(%eax),%eax
    42ad:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    42b0:	72 4d                	jb     42ff <malloc+0xa6>
      if(p->s.size == nunits)
    42b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    42b5:	8b 40 04             	mov    0x4(%eax),%eax
    42b8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    42bb:	75 0c                	jne    42c9 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
    42bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    42c0:	8b 10                	mov    (%eax),%edx
    42c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
    42c5:	89 10                	mov    %edx,(%eax)
    42c7:	eb 26                	jmp    42ef <malloc+0x96>
      else {
        p->s.size -= nunits;
    42c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    42cc:	8b 40 04             	mov    0x4(%eax),%eax
    42cf:	89 c2                	mov    %eax,%edx
    42d1:	2b 55 ec             	sub    -0x14(%ebp),%edx
    42d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    42d7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    42da:	8b 45 f4             	mov    -0xc(%ebp),%eax
    42dd:	8b 40 04             	mov    0x4(%eax),%eax
    42e0:	c1 e0 03             	shl    $0x3,%eax
    42e3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    42e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    42e9:	8b 55 ec             	mov    -0x14(%ebp),%edx
    42ec:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    42ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
    42f2:	a3 c8 61 00 00       	mov    %eax,0x61c8
      return (void*)(p + 1);
    42f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    42fa:	83 c0 08             	add    $0x8,%eax
    42fd:	eb 38                	jmp    4337 <malloc+0xde>
    }
    if(p == freep)
    42ff:	a1 c8 61 00 00       	mov    0x61c8,%eax
    4304:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    4307:	75 1b                	jne    4324 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
    4309:	8b 45 ec             	mov    -0x14(%ebp),%eax
    430c:	89 04 24             	mov    %eax,(%esp)
    430f:	e8 ed fe ff ff       	call   4201 <morecore>
    4314:	89 45 f4             	mov    %eax,-0xc(%ebp)
    4317:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    431b:	75 07                	jne    4324 <malloc+0xcb>
        return 0;
    431d:	b8 00 00 00 00       	mov    $0x0,%eax
    4322:	eb 13                	jmp    4337 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4324:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4327:	89 45 f0             	mov    %eax,-0x10(%ebp)
    432a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    432d:	8b 00                	mov    (%eax),%eax
    432f:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    4332:	e9 70 ff ff ff       	jmp    42a7 <malloc+0x4e>
}
    4337:	c9                   	leave  
    4338:	c3                   	ret    
