
_sanity:     file format elf32-i386


Disassembly of section .text:

00000000 <foo>:
}
*/

void
foo(int cid)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 24             	sub    $0x24,%esp
  int i;
  switch(cid%3)
   7:	8b 4d 08             	mov    0x8(%ebp),%ecx
   a:	ba 56 55 55 55       	mov    $0x55555556,%edx
   f:	89 c8                	mov    %ecx,%eax
  11:	f7 ea                	imul   %edx
  13:	89 c8                	mov    %ecx,%eax
  15:	c1 f8 1f             	sar    $0x1f,%eax
  18:	89 d3                	mov    %edx,%ebx
  1a:	29 c3                	sub    %eax,%ebx
  1c:	89 d8                	mov    %ebx,%eax
  1e:	89 c2                	mov    %eax,%edx
  20:	01 d2                	add    %edx,%edx
  22:	01 c2                	add    %eax,%edx
  24:	89 c8                	mov    %ecx,%eax
  26:	29 d0                	sub    %edx,%eax
  28:	85 c0                	test   %eax,%eax
  2a:	74 07                	je     33 <foo+0x33>
  2c:	83 f8 01             	cmp    $0x1,%eax
  2f:	74 09                	je     3a <foo+0x3a>
  31:	eb 12                	jmp    45 <foo+0x45>
  {
    case 0:
      nice();
  33:	e8 34 08 00 00       	call   86c <nice>
      break;
  38:	eb 0b                	jmp    45 <foo+0x45>
    case 1:
      nice();
  3a:	e8 2d 08 00 00       	call   86c <nice>
      nice();
  3f:	e8 28 08 00 00       	call   86c <nice>
      break;
  44:	90                   	nop
  }
  for (i=0;i<50;i++)
  45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4c:	eb 29                	jmp    77 <foo+0x77>
     printf(1, "child %d prints for the %d time\n",cid,i+1);
  4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  51:	83 c0 01             	add    $0x1,%eax
  54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  58:	8b 45 08             	mov    0x8(%ebp),%eax
  5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  5f:	c7 44 24 04 a0 0d 00 	movl   $0xda0,0x4(%esp)
  66:	00 
  67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  6e:	e8 68 09 00 00       	call   9db <printf>
    case 1:
      nice();
      nice();
      break;
  }
  for (i=0;i<50;i++)
  73:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  77:	83 7d f4 31          	cmpl   $0x31,-0xc(%ebp)
  7b:	7e d1                	jle    4e <foo+0x4e>
     printf(1, "child %d prints for the %d time\n",cid,i+1);
}
  7d:	83 c4 24             	add    $0x24,%esp
  80:	5b                   	pop    %ebx
  81:	5d                   	pop    %ebp
  82:	c3                   	ret    

00000083 <sanity>:

void
sanity(void)
{
  83:	55                   	push   %ebp
  84:	89 e5                	mov    %esp,%ebp
  86:	56                   	push   %esi
  87:	53                   	push   %ebx
  88:	81 ec c0 01 00 00    	sub    $0x1c0,%esp
  int avg_medium_wtime;
  int avg_medium_rtime;
  int avg_low_wtime;
  int avg_low_rtime;
  int temp;
  int found = 0;
  8e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  
  printf(1, "sanity test\n");
  95:	c7 44 24 04 c1 0d 00 	movl   $0xdc1,0x4(%esp)
  9c:	00 
  9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  a4:	e8 32 09 00 00       	call   9db <printf>

  int i,cid;
  for(;cid<30;cid++)
  a9:	eb 31                	jmp    dc <sanity+0x59>
  {  
    pid[cid] = fork();
  ab:	e8 9c 07 00 00       	call   84c <fork>
  b0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  b3:	89 84 95 58 fe ff ff 	mov    %eax,-0x1a8(%ebp,%edx,4)
    if(pid[cid] == 0)
  ba:	8b 45 cc             	mov    -0x34(%ebp),%eax
  bd:	8b 84 85 58 fe ff ff 	mov    -0x1a8(%ebp,%eax,4),%eax
  c4:	85 c0                	test   %eax,%eax
  c6:	75 10                	jne    d8 <sanity+0x55>
    {
      foo(cid);
  c8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  cb:	89 04 24             	mov    %eax,(%esp)
  ce:	e8 2d ff ff ff       	call   0 <foo>
      exit();      
  d3:	e8 7c 07 00 00       	call   854 <exit>
  int found = 0;
  
  printf(1, "sanity test\n");

  int i,cid;
  for(;cid<30;cid++)
  d8:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
  dc:	83 7d cc 1d          	cmpl   $0x1d,-0x34(%ebp)
  e0:	7e c9                	jle    ab <sanity+0x28>
      foo(cid);
      exit();      
    }
  }
  
  for(i=0;i<30;i++,found=0)
  e2:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  e9:	e9 11 01 00 00       	jmp    1ff <sanity+0x17c>
  {
    temp = wait2(&tempwtime,&temprtime);
  ee:	8d 85 d0 fe ff ff    	lea    -0x130(%ebp),%eax
  f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  f8:	8d 85 d4 fe ff ff    	lea    -0x12c(%ebp),%eax
  fe:	89 04 24             	mov    %eax,(%esp)
 101:	e8 5e 07 00 00       	call   864 <wait2>
 106:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for(cid=0;cid<30 && !found;cid++)
 109:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
 110:	eb 3a                	jmp    14c <sanity+0xc9>
    {
      if(pid[cid] == temp)
 112:	8b 45 cc             	mov    -0x34(%ebp),%eax
 115:	8b 84 85 58 fe ff ff 	mov    -0x1a8(%ebp,%eax,4),%eax
 11c:	3b 45 c8             	cmp    -0x38(%ebp),%eax
 11f:	75 27                	jne    148 <sanity+0xc5>
      {
	 wTime[cid] = tempwtime;
 121:	8b 95 d4 fe ff ff    	mov    -0x12c(%ebp),%edx
 127:	8b 45 cc             	mov    -0x34(%ebp),%eax
 12a:	89 94 85 50 ff ff ff 	mov    %edx,-0xb0(%ebp,%eax,4)
	 rTime[cid] = temprtime;
 131:	8b 95 d0 fe ff ff    	mov    -0x130(%ebp),%edx
 137:	8b 45 cc             	mov    -0x34(%ebp),%eax
 13a:	89 94 85 d8 fe ff ff 	mov    %edx,-0x128(%ebp,%eax,4)
	found = 1;
 141:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  }
  
  for(i=0;i<30;i++,found=0)
  {
    temp = wait2(&tempwtime,&temprtime);
    for(cid=0;cid<30 && !found;cid++)
 148:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
 14c:	83 7d cc 1d          	cmpl   $0x1d,-0x34(%ebp)
 150:	7f 06                	jg     158 <sanity+0xd5>
 152:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 156:	74 ba                	je     112 <sanity+0x8f>
	 wTime[cid] = tempwtime;
	 rTime[cid] = temprtime;
	found = 1;
      }
    }
    avg_all_wtime += wTime[cid];
 158:	8b 45 cc             	mov    -0x34(%ebp),%eax
 15b:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 162:	01 45 f4             	add    %eax,-0xc(%ebp)
    avg_all_rtime += rTime[cid];
 165:	8b 45 cc             	mov    -0x34(%ebp),%eax
 168:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 16f:	01 45 f0             	add    %eax,-0x10(%ebp)
    
    switch(cid%3)
 172:	8b 4d cc             	mov    -0x34(%ebp),%ecx
 175:	ba 56 55 55 55       	mov    $0x55555556,%edx
 17a:	89 c8                	mov    %ecx,%eax
 17c:	f7 ea                	imul   %edx
 17e:	89 c8                	mov    %ecx,%eax
 180:	c1 f8 1f             	sar    $0x1f,%eax
 183:	89 d3                	mov    %edx,%ebx
 185:	29 c3                	sub    %eax,%ebx
 187:	89 d8                	mov    %ebx,%eax
 189:	89 c2                	mov    %eax,%edx
 18b:	01 d2                	add    %edx,%edx
 18d:	01 c2                	add    %eax,%edx
 18f:	89 c8                	mov    %ecx,%eax
 191:	29 d0                	sub    %edx,%eax
 193:	83 f8 01             	cmp    $0x1,%eax
 196:	74 25                	je     1bd <sanity+0x13a>
 198:	83 f8 02             	cmp    $0x2,%eax
 19b:	74 3c                	je     1d9 <sanity+0x156>
 19d:	85 c0                	test   %eax,%eax
 19f:	75 53                	jne    1f4 <sanity+0x171>
    {
      case 0:
	avg_medium_wtime += wTime[cid];
 1a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1a4:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 1ab:	01 45 e4             	add    %eax,-0x1c(%ebp)
	avg_medium_rtime += rTime[cid];
 1ae:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1b1:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 1b8:	01 45 e0             	add    %eax,-0x20(%ebp)
	break;
 1bb:	eb 37                	jmp    1f4 <sanity+0x171>
      case 1:
	avg_low_wtime += wTime[cid];
 1bd:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1c0:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 1c7:	01 45 dc             	add    %eax,-0x24(%ebp)
	avg_low_rtime += rTime[cid];
 1ca:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1cd:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 1d4:	01 45 d8             	add    %eax,-0x28(%ebp)
	break;
 1d7:	eb 1b                	jmp    1f4 <sanity+0x171>
      case 2:
	avg_high_wtime += wTime[cid];
 1d9:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1dc:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 1e3:	01 45 ec             	add    %eax,-0x14(%ebp)
	avg_high_rtime += rTime[cid];
 1e6:	8b 45 cc             	mov    -0x34(%ebp),%eax
 1e9:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 1f0:	01 45 e8             	add    %eax,-0x18(%ebp)
	break;
 1f3:	90                   	nop
      foo(cid);
      exit();      
    }
  }
  
  for(i=0;i<30;i++,found=0)
 1f4:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
 1f8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 1ff:	83 7d d0 1d          	cmpl   $0x1d,-0x30(%ebp)
 203:	0f 8e e5 fe ff ff    	jle    ee <sanity+0x6b>
	avg_high_rtime += rTime[cid];
	break;
    }
  }

  printf(1, "All: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_all_wtime/30, avg_all_rtime/30, (avg_all_wtime + avg_all_rtime)/30);
 209:	8b 45 f0             	mov    -0x10(%ebp),%eax
 20c:	8b 55 f4             	mov    -0xc(%ebp),%edx
 20f:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 212:	ba 89 88 88 88       	mov    $0x88888889,%edx
 217:	89 c8                	mov    %ecx,%eax
 219:	f7 ea                	imul   %edx
 21b:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
 21e:	89 c2                	mov    %eax,%edx
 220:	c1 fa 04             	sar    $0x4,%edx
 223:	89 c8                	mov    %ecx,%eax
 225:	c1 f8 1f             	sar    $0x1f,%eax
 228:	89 d6                	mov    %edx,%esi
 22a:	29 c6                	sub    %eax,%esi
 22c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
 22f:	ba 89 88 88 88       	mov    $0x88888889,%edx
 234:	89 c8                	mov    %ecx,%eax
 236:	f7 ea                	imul   %edx
 238:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
 23b:	89 c2                	mov    %eax,%edx
 23d:	c1 fa 04             	sar    $0x4,%edx
 240:	89 c8                	mov    %ecx,%eax
 242:	c1 f8 1f             	sar    $0x1f,%eax
 245:	89 d3                	mov    %edx,%ebx
 247:	29 c3                	sub    %eax,%ebx
 249:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 24c:	ba 89 88 88 88       	mov    $0x88888889,%edx
 251:	89 c8                	mov    %ecx,%eax
 253:	f7 ea                	imul   %edx
 255:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
 258:	89 c2                	mov    %eax,%edx
 25a:	c1 fa 04             	sar    $0x4,%edx
 25d:	89 c8                	mov    %ecx,%eax
 25f:	c1 f8 1f             	sar    $0x1f,%eax
 262:	89 d1                	mov    %edx,%ecx
 264:	29 c1                	sub    %eax,%ecx
 266:	89 c8                	mov    %ecx,%eax
 268:	89 74 24 10          	mov    %esi,0x10(%esp)
 26c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 270:	89 44 24 08          	mov    %eax,0x8(%esp)
 274:	c7 44 24 04 d0 0d 00 	movl   $0xdd0,0x4(%esp)
 27b:	00 
 27c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 283:	e8 53 07 00 00       	call   9db <printf>
  printf(1, "High priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_high_wtime/10, avg_high_rtime/10, (avg_high_wtime + avg_high_rtime)/10);
 288:	8b 45 e8             	mov    -0x18(%ebp),%eax
 28b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 28e:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 291:	ba 67 66 66 66       	mov    $0x66666667,%edx
 296:	89 c8                	mov    %ecx,%eax
 298:	f7 ea                	imul   %edx
 29a:	c1 fa 02             	sar    $0x2,%edx
 29d:	89 c8                	mov    %ecx,%eax
 29f:	c1 f8 1f             	sar    $0x1f,%eax
 2a2:	89 d6                	mov    %edx,%esi
 2a4:	29 c6                	sub    %eax,%esi
 2a6:	8b 4d e8             	mov    -0x18(%ebp),%ecx
 2a9:	ba 67 66 66 66       	mov    $0x66666667,%edx
 2ae:	89 c8                	mov    %ecx,%eax
 2b0:	f7 ea                	imul   %edx
 2b2:	c1 fa 02             	sar    $0x2,%edx
 2b5:	89 c8                	mov    %ecx,%eax
 2b7:	c1 f8 1f             	sar    $0x1f,%eax
 2ba:	89 d3                	mov    %edx,%ebx
 2bc:	29 c3                	sub    %eax,%ebx
 2be:	8b 4d ec             	mov    -0x14(%ebp),%ecx
 2c1:	ba 67 66 66 66       	mov    $0x66666667,%edx
 2c6:	89 c8                	mov    %ecx,%eax
 2c8:	f7 ea                	imul   %edx
 2ca:	c1 fa 02             	sar    $0x2,%edx
 2cd:	89 c8                	mov    %ecx,%eax
 2cf:	c1 f8 1f             	sar    $0x1f,%eax
 2d2:	89 d1                	mov    %edx,%ecx
 2d4:	29 c1                	sub    %eax,%ecx
 2d6:	89 c8                	mov    %ecx,%eax
 2d8:	89 74 24 10          	mov    %esi,0x10(%esp)
 2dc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 2e0:	89 44 24 08          	mov    %eax,0x8(%esp)
 2e4:	c7 44 24 04 28 0e 00 	movl   $0xe28,0x4(%esp)
 2eb:	00 
 2ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2f3:	e8 e3 06 00 00       	call   9db <printf>
  printf(1, "Medium priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_medium_wtime/10, avg_medium_rtime/10, (avg_medium_wtime + avg_medium_rtime)/10);
 2f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
 2fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 2fe:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 301:	ba 67 66 66 66       	mov    $0x66666667,%edx
 306:	89 c8                	mov    %ecx,%eax
 308:	f7 ea                	imul   %edx
 30a:	c1 fa 02             	sar    $0x2,%edx
 30d:	89 c8                	mov    %ecx,%eax
 30f:	c1 f8 1f             	sar    $0x1f,%eax
 312:	89 d6                	mov    %edx,%esi
 314:	29 c6                	sub    %eax,%esi
 316:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 319:	ba 67 66 66 66       	mov    $0x66666667,%edx
 31e:	89 c8                	mov    %ecx,%eax
 320:	f7 ea                	imul   %edx
 322:	c1 fa 02             	sar    $0x2,%edx
 325:	89 c8                	mov    %ecx,%eax
 327:	c1 f8 1f             	sar    $0x1f,%eax
 32a:	89 d3                	mov    %edx,%ebx
 32c:	29 c3                	sub    %eax,%ebx
 32e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
 331:	ba 67 66 66 66       	mov    $0x66666667,%edx
 336:	89 c8                	mov    %ecx,%eax
 338:	f7 ea                	imul   %edx
 33a:	c1 fa 02             	sar    $0x2,%edx
 33d:	89 c8                	mov    %ecx,%eax
 33f:	c1 f8 1f             	sar    $0x1f,%eax
 342:	89 d1                	mov    %edx,%ecx
 344:	29 c1                	sub    %eax,%ecx
 346:	89 c8                	mov    %ecx,%eax
 348:	89 74 24 10          	mov    %esi,0x10(%esp)
 34c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 350:	89 44 24 08          	mov    %eax,0x8(%esp)
 354:	c7 44 24 04 8c 0e 00 	movl   $0xe8c,0x4(%esp)
 35b:	00 
 35c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 363:	e8 73 06 00 00       	call   9db <printf>
  printf(1, "Low priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_low_wtime/10, avg_low_rtime/10, (avg_low_wtime + avg_low_rtime)/10);
 368:	8b 45 d8             	mov    -0x28(%ebp),%eax
 36b:	8b 55 dc             	mov    -0x24(%ebp),%edx
 36e:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 371:	ba 67 66 66 66       	mov    $0x66666667,%edx
 376:	89 c8                	mov    %ecx,%eax
 378:	f7 ea                	imul   %edx
 37a:	c1 fa 02             	sar    $0x2,%edx
 37d:	89 c8                	mov    %ecx,%eax
 37f:	c1 f8 1f             	sar    $0x1f,%eax
 382:	89 d6                	mov    %edx,%esi
 384:	29 c6                	sub    %eax,%esi
 386:	8b 4d d8             	mov    -0x28(%ebp),%ecx
 389:	ba 67 66 66 66       	mov    $0x66666667,%edx
 38e:	89 c8                	mov    %ecx,%eax
 390:	f7 ea                	imul   %edx
 392:	c1 fa 02             	sar    $0x2,%edx
 395:	89 c8                	mov    %ecx,%eax
 397:	c1 f8 1f             	sar    $0x1f,%eax
 39a:	89 d3                	mov    %edx,%ebx
 39c:	29 c3                	sub    %eax,%ebx
 39e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
 3a1:	ba 67 66 66 66       	mov    $0x66666667,%edx
 3a6:	89 c8                	mov    %ecx,%eax
 3a8:	f7 ea                	imul   %edx
 3aa:	c1 fa 02             	sar    $0x2,%edx
 3ad:	89 c8                	mov    %ecx,%eax
 3af:	c1 f8 1f             	sar    $0x1f,%eax
 3b2:	89 d1                	mov    %edx,%ecx
 3b4:	29 c1                	sub    %eax,%ecx
 3b6:	89 c8                	mov    %ecx,%eax
 3b8:	89 74 24 10          	mov    %esi,0x10(%esp)
 3bc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 3c0:	89 44 24 08          	mov    %eax,0x8(%esp)
 3c4:	c7 44 24 04 f0 0e 00 	movl   $0xef0,0x4(%esp)
 3cb:	00 
 3cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3d3:	e8 03 06 00 00       	call   9db <printf>

  for(i=0;i<30;i++)
 3d8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
 3df:	eb 56                	jmp    437 <sanity+0x3b4>
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",i,wTime[i],rTime[i],wTime[i]+rTime[i]);
 3e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
 3e4:	8b 94 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%edx
 3eb:	8b 45 d0             	mov    -0x30(%ebp),%eax
 3ee:	8b 84 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%eax
 3f5:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
 3f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
 3fb:	8b 94 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%edx
 402:	8b 45 d0             	mov    -0x30(%ebp),%eax
 405:	8b 84 85 50 ff ff ff 	mov    -0xb0(%ebp,%eax,4),%eax
 40c:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 410:	89 54 24 10          	mov    %edx,0x10(%esp)
 414:	89 44 24 0c          	mov    %eax,0xc(%esp)
 418:	8b 45 d0             	mov    -0x30(%ebp),%eax
 41b:	89 44 24 08          	mov    %eax,0x8(%esp)
 41f:	c7 44 24 04 54 0f 00 	movl   $0xf54,0x4(%esp)
 426:	00 
 427:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 42e:	e8 a8 05 00 00       	call   9db <printf>
  printf(1, "All: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_all_wtime/30, avg_all_rtime/30, (avg_all_wtime + avg_all_rtime)/30);
  printf(1, "High priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_high_wtime/10, avg_high_rtime/10, (avg_high_wtime + avg_high_rtime)/10);
  printf(1, "Medium priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_medium_wtime/10, avg_medium_rtime/10, (avg_medium_wtime + avg_medium_rtime)/10);
  printf(1, "Low priority: average waiting time: %d, average running time: %d, average turnaround time: %d, \n", avg_low_wtime/10, avg_low_rtime/10, (avg_low_wtime + avg_low_rtime)/10);

  for(i=0;i<30;i++)
 433:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
 437:	83 7d d0 1d          	cmpl   $0x1d,-0x30(%ebp)
 43b:	7e a4                	jle    3e1 <sanity+0x35e>
    printf(1, "child %d: Waiting Time: %d Running Time: %d Turnaround Time: %d\n",i,wTime[i],rTime[i],wTime[i]+rTime[i]);

}
 43d:	81 c4 c0 01 00 00    	add    $0x1c0,%esp
 443:	5b                   	pop    %ebx
 444:	5e                   	pop    %esi
 445:	5d                   	pop    %ebp
 446:	c3                   	ret    

00000447 <main>:
int
main(void)
{
 447:	55                   	push   %ebp
 448:	89 e5                	mov    %esp,%ebp
 44a:	83 e4 f0             	and    $0xfffffff0,%esp
  sanity();
 44d:	e8 31 fc ff ff       	call   83 <sanity>
  exit();
 452:	e8 fd 03 00 00       	call   854 <exit>
 457:	90                   	nop

00000458 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 458:	55                   	push   %ebp
 459:	89 e5                	mov    %esp,%ebp
 45b:	57                   	push   %edi
 45c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 45d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 460:	8b 55 10             	mov    0x10(%ebp),%edx
 463:	8b 45 0c             	mov    0xc(%ebp),%eax
 466:	89 cb                	mov    %ecx,%ebx
 468:	89 df                	mov    %ebx,%edi
 46a:	89 d1                	mov    %edx,%ecx
 46c:	fc                   	cld    
 46d:	f3 aa                	rep stos %al,%es:(%edi)
 46f:	89 ca                	mov    %ecx,%edx
 471:	89 fb                	mov    %edi,%ebx
 473:	89 5d 08             	mov    %ebx,0x8(%ebp)
 476:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 479:	5b                   	pop    %ebx
 47a:	5f                   	pop    %edi
 47b:	5d                   	pop    %ebp
 47c:	c3                   	ret    

0000047d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 47d:	55                   	push   %ebp
 47e:	89 e5                	mov    %esp,%ebp
 480:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 483:	8b 45 08             	mov    0x8(%ebp),%eax
 486:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 489:	90                   	nop
 48a:	8b 45 0c             	mov    0xc(%ebp),%eax
 48d:	0f b6 10             	movzbl (%eax),%edx
 490:	8b 45 08             	mov    0x8(%ebp),%eax
 493:	88 10                	mov    %dl,(%eax)
 495:	8b 45 08             	mov    0x8(%ebp),%eax
 498:	0f b6 00             	movzbl (%eax),%eax
 49b:	84 c0                	test   %al,%al
 49d:	0f 95 c0             	setne  %al
 4a0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4a4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 4a8:	84 c0                	test   %al,%al
 4aa:	75 de                	jne    48a <strcpy+0xd>
    ;
  return os;
 4ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4af:	c9                   	leave  
 4b0:	c3                   	ret    

000004b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4b1:	55                   	push   %ebp
 4b2:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 4b4:	eb 08                	jmp    4be <strcmp+0xd>
    p++, q++;
 4b6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4ba:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 4be:	8b 45 08             	mov    0x8(%ebp),%eax
 4c1:	0f b6 00             	movzbl (%eax),%eax
 4c4:	84 c0                	test   %al,%al
 4c6:	74 10                	je     4d8 <strcmp+0x27>
 4c8:	8b 45 08             	mov    0x8(%ebp),%eax
 4cb:	0f b6 10             	movzbl (%eax),%edx
 4ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d1:	0f b6 00             	movzbl (%eax),%eax
 4d4:	38 c2                	cmp    %al,%dl
 4d6:	74 de                	je     4b6 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 4d8:	8b 45 08             	mov    0x8(%ebp),%eax
 4db:	0f b6 00             	movzbl (%eax),%eax
 4de:	0f b6 d0             	movzbl %al,%edx
 4e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e4:	0f b6 00             	movzbl (%eax),%eax
 4e7:	0f b6 c0             	movzbl %al,%eax
 4ea:	89 d1                	mov    %edx,%ecx
 4ec:	29 c1                	sub    %eax,%ecx
 4ee:	89 c8                	mov    %ecx,%eax
}
 4f0:	5d                   	pop    %ebp
 4f1:	c3                   	ret    

000004f2 <strlen>:

uint
strlen(char *s)
{
 4f2:	55                   	push   %ebp
 4f3:	89 e5                	mov    %esp,%ebp
 4f5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++);
 4f8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 4ff:	eb 04                	jmp    505 <strlen+0x13>
 501:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 505:	8b 45 fc             	mov    -0x4(%ebp),%eax
 508:	03 45 08             	add    0x8(%ebp),%eax
 50b:	0f b6 00             	movzbl (%eax),%eax
 50e:	84 c0                	test   %al,%al
 510:	75 ef                	jne    501 <strlen+0xf>
  return n;
 512:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 515:	c9                   	leave  
 516:	c3                   	ret    

00000517 <memset>:

void*
memset(void *dst, int c, uint n)
{
 517:	55                   	push   %ebp
 518:	89 e5                	mov    %esp,%ebp
 51a:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 51d:	8b 45 10             	mov    0x10(%ebp),%eax
 520:	89 44 24 08          	mov    %eax,0x8(%esp)
 524:	8b 45 0c             	mov    0xc(%ebp),%eax
 527:	89 44 24 04          	mov    %eax,0x4(%esp)
 52b:	8b 45 08             	mov    0x8(%ebp),%eax
 52e:	89 04 24             	mov    %eax,(%esp)
 531:	e8 22 ff ff ff       	call   458 <stosb>
  return dst;
 536:	8b 45 08             	mov    0x8(%ebp),%eax
}
 539:	c9                   	leave  
 53a:	c3                   	ret    

0000053b <strchr>:

char*
strchr(const char *s, char c)
{
 53b:	55                   	push   %ebp
 53c:	89 e5                	mov    %esp,%ebp
 53e:	83 ec 04             	sub    $0x4,%esp
 541:	8b 45 0c             	mov    0xc(%ebp),%eax
 544:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 547:	eb 14                	jmp    55d <strchr+0x22>
    if(*s == c)
 549:	8b 45 08             	mov    0x8(%ebp),%eax
 54c:	0f b6 00             	movzbl (%eax),%eax
 54f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 552:	75 05                	jne    559 <strchr+0x1e>
      return (char*)s;
 554:	8b 45 08             	mov    0x8(%ebp),%eax
 557:	eb 13                	jmp    56c <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 559:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 55d:	8b 45 08             	mov    0x8(%ebp),%eax
 560:	0f b6 00             	movzbl (%eax),%eax
 563:	84 c0                	test   %al,%al
 565:	75 e2                	jne    549 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 567:	b8 00 00 00 00       	mov    $0x0,%eax
}
 56c:	c9                   	leave  
 56d:	c3                   	ret    

0000056e <gets>:

char*
gets(char *buf, int max)
{
 56e:	55                   	push   %ebp
 56f:	89 e5                	mov    %esp,%ebp
 571:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 574:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 57b:	eb 44                	jmp    5c1 <gets+0x53>
    cc = read(0, &c, 1);
 57d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 584:	00 
 585:	8d 45 ef             	lea    -0x11(%ebp),%eax
 588:	89 44 24 04          	mov    %eax,0x4(%esp)
 58c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 593:	e8 e4 02 00 00       	call   87c <read>
 598:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 59b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 59f:	7e 2d                	jle    5ce <gets+0x60>
      break;
    buf[i++] = c;
 5a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a4:	03 45 08             	add    0x8(%ebp),%eax
 5a7:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 5ab:	88 10                	mov    %dl,(%eax)
 5ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 5b1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5b5:	3c 0a                	cmp    $0xa,%al
 5b7:	74 16                	je     5cf <gets+0x61>
 5b9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 5bd:	3c 0d                	cmp    $0xd,%al
 5bf:	74 0e                	je     5cf <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c4:	83 c0 01             	add    $0x1,%eax
 5c7:	3b 45 0c             	cmp    0xc(%ebp),%eax
 5ca:	7c b1                	jl     57d <gets+0xf>
 5cc:	eb 01                	jmp    5cf <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 5ce:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 5cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d2:	03 45 08             	add    0x8(%ebp),%eax
 5d5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 5d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5db:	c9                   	leave  
 5dc:	c3                   	ret    

000005dd <stat>:

int
stat(char *n, struct stat *st)
{
 5dd:	55                   	push   %ebp
 5de:	89 e5                	mov    %esp,%ebp
 5e0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 5ea:	00 
 5eb:	8b 45 08             	mov    0x8(%ebp),%eax
 5ee:	89 04 24             	mov    %eax,(%esp)
 5f1:	e8 ae 02 00 00       	call   8a4 <open>
 5f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 5f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5fd:	79 07                	jns    606 <stat+0x29>
    return -1;
 5ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 604:	eb 23                	jmp    629 <stat+0x4c>
  r = fstat(fd, st);
 606:	8b 45 0c             	mov    0xc(%ebp),%eax
 609:	89 44 24 04          	mov    %eax,0x4(%esp)
 60d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 610:	89 04 24             	mov    %eax,(%esp)
 613:	e8 a4 02 00 00       	call   8bc <fstat>
 618:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 61b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 61e:	89 04 24             	mov    %eax,(%esp)
 621:	e8 66 02 00 00       	call   88c <close>
  return r;
 626:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 629:	c9                   	leave  
 62a:	c3                   	ret    

0000062b <atoi>:

int
atoi(const char *s)
{
 62b:	55                   	push   %ebp
 62c:	89 e5                	mov    %esp,%ebp
 62e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 631:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 638:	eb 23                	jmp    65d <atoi+0x32>
    n = n*10 + *s++ - '0';
 63a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 63d:	89 d0                	mov    %edx,%eax
 63f:	c1 e0 02             	shl    $0x2,%eax
 642:	01 d0                	add    %edx,%eax
 644:	01 c0                	add    %eax,%eax
 646:	89 c2                	mov    %eax,%edx
 648:	8b 45 08             	mov    0x8(%ebp),%eax
 64b:	0f b6 00             	movzbl (%eax),%eax
 64e:	0f be c0             	movsbl %al,%eax
 651:	01 d0                	add    %edx,%eax
 653:	83 e8 30             	sub    $0x30,%eax
 656:	89 45 fc             	mov    %eax,-0x4(%ebp)
 659:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 65d:	8b 45 08             	mov    0x8(%ebp),%eax
 660:	0f b6 00             	movzbl (%eax),%eax
 663:	3c 2f                	cmp    $0x2f,%al
 665:	7e 0a                	jle    671 <atoi+0x46>
 667:	8b 45 08             	mov    0x8(%ebp),%eax
 66a:	0f b6 00             	movzbl (%eax),%eax
 66d:	3c 39                	cmp    $0x39,%al
 66f:	7e c9                	jle    63a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 671:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 674:	c9                   	leave  
 675:	c3                   	ret    

00000676 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 676:	55                   	push   %ebp
 677:	89 e5                	mov    %esp,%ebp
 679:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 67c:	8b 45 08             	mov    0x8(%ebp),%eax
 67f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 682:	8b 45 0c             	mov    0xc(%ebp),%eax
 685:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 688:	eb 13                	jmp    69d <memmove+0x27>
    *dst++ = *src++;
 68a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68d:	0f b6 10             	movzbl (%eax),%edx
 690:	8b 45 fc             	mov    -0x4(%ebp),%eax
 693:	88 10                	mov    %dl,(%eax)
 695:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 699:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 69d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 6a1:	0f 9f c0             	setg   %al
 6a4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 6a8:	84 c0                	test   %al,%al
 6aa:	75 de                	jne    68a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 6ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6af:	c9                   	leave  
 6b0:	c3                   	ret    

000006b1 <strtok>:

int
strtok(char *dest,const char* str,const char delimeter,int* beginIndex)
{
 6b1:	55                   	push   %ebp
 6b2:	89 e5                	mov    %esp,%ebp
 6b4:	83 ec 38             	sub    $0x38,%esp
 6b7:	8b 45 10             	mov    0x10(%ebp),%eax
 6ba:	88 45 e4             	mov    %al,-0x1c(%ebp)
  int index=*beginIndex, match=0;
 6bd:	8b 45 14             	mov    0x14(%ebp),%eax
 6c0:	8b 00                	mov    (%eax),%eax
 6c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6c5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(str==0 || delimeter==0)
 6cc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6d0:	74 06                	je     6d8 <strtok+0x27>
 6d2:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
 6d6:	75 54                	jne    72c <strtok+0x7b>
    return match;
 6d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6db:	eb 6e                	jmp    74b <strtok+0x9a>
  else
  {
    while(str[index]!=0)
    {
      if(str[index]!=delimeter)
 6dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e0:	03 45 0c             	add    0xc(%ebp),%eax
 6e3:	0f b6 00             	movzbl (%eax),%eax
 6e6:	3a 45 e4             	cmp    -0x1c(%ebp),%al
 6e9:	74 06                	je     6f1 <strtok+0x40>
      {
	index++;
 6eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6ef:	eb 3c                	jmp    72d <strtok+0x7c>
      }
      else
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
 6f1:	8b 45 14             	mov    0x14(%ebp),%eax
 6f4:	8b 00                	mov    (%eax),%eax
 6f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
 6f9:	29 c2                	sub    %eax,%edx
 6fb:	8b 45 14             	mov    0x14(%ebp),%eax
 6fe:	8b 00                	mov    (%eax),%eax
 700:	03 45 0c             	add    0xc(%ebp),%eax
 703:	89 54 24 08          	mov    %edx,0x8(%esp)
 707:	89 44 24 04          	mov    %eax,0x4(%esp)
 70b:	8b 45 08             	mov    0x8(%ebp),%eax
 70e:	89 04 24             	mov    %eax,(%esp)
 711:	e8 37 00 00 00       	call   74d <strncpy>
 716:	89 45 08             	mov    %eax,0x8(%ebp)
	if(*dest){
 719:	8b 45 08             	mov    0x8(%ebp),%eax
 71c:	0f b6 00             	movzbl (%eax),%eax
 71f:	84 c0                	test   %al,%al
 721:	74 19                	je     73c <strtok+0x8b>
	  match = 1;
 723:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	break;
 72a:	eb 10                	jmp    73c <strtok+0x8b>
  int index=*beginIndex, match=0;
  if(str==0 || delimeter==0)
    return match;
  else
  {
    while(str[index]!=0)
 72c:	90                   	nop
 72d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 730:	03 45 0c             	add    0xc(%ebp),%eax
 733:	0f b6 00             	movzbl (%eax),%eax
 736:	84 c0                	test   %al,%al
 738:	75 a3                	jne    6dd <strtok+0x2c>
 73a:	eb 01                	jmp    73d <strtok+0x8c>
      {
	dest = strncpy(dest,str+(*beginIndex),index-(*beginIndex));
	if(*dest){
	  match = 1;
	}
	break;
 73c:	90                   	nop
      }
    }
  }
  *beginIndex = index+1;
 73d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 740:	8d 50 01             	lea    0x1(%eax),%edx
 743:	8b 45 14             	mov    0x14(%ebp),%eax
 746:	89 10                	mov    %edx,(%eax)
  return match;
 748:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 74b:	c9                   	leave  
 74c:	c3                   	ret    

0000074d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
 74d:	55                   	push   %ebp
 74e:	89 e5                	mov    %esp,%ebp
 750:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
 753:	8b 45 08             	mov    0x8(%ebp),%eax
 756:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
 759:	90                   	nop
 75a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 75e:	0f 9f c0             	setg   %al
 761:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 765:	84 c0                	test   %al,%al
 767:	74 30                	je     799 <strncpy+0x4c>
 769:	8b 45 0c             	mov    0xc(%ebp),%eax
 76c:	0f b6 10             	movzbl (%eax),%edx
 76f:	8b 45 08             	mov    0x8(%ebp),%eax
 772:	88 10                	mov    %dl,(%eax)
 774:	8b 45 08             	mov    0x8(%ebp),%eax
 777:	0f b6 00             	movzbl (%eax),%eax
 77a:	84 c0                	test   %al,%al
 77c:	0f 95 c0             	setne  %al
 77f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 783:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 787:	84 c0                	test   %al,%al
 789:	75 cf                	jne    75a <strncpy+0xd>
    ;
  while(n-- > 0)
 78b:	eb 0c                	jmp    799 <strncpy+0x4c>
    *s++ = 0;
 78d:	8b 45 08             	mov    0x8(%ebp),%eax
 790:	c6 00 00             	movb   $0x0,(%eax)
 793:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 797:	eb 01                	jmp    79a <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
 799:	90                   	nop
 79a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 79e:	0f 9f c0             	setg   %al
 7a1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 7a5:	84 c0                	test   %al,%al
 7a7:	75 e4                	jne    78d <strncpy+0x40>
    *s++ = 0;
  return os;
 7a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 7ac:	c9                   	leave  
 7ad:	c3                   	ret    

000007ae <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
 7ae:	55                   	push   %ebp
 7af:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
 7b1:	eb 0c                	jmp    7bf <strncmp+0x11>
    n--, p++, q++;
 7b3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 7b7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 7bb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
 7bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 7c3:	74 1a                	je     7df <strncmp+0x31>
 7c5:	8b 45 08             	mov    0x8(%ebp),%eax
 7c8:	0f b6 00             	movzbl (%eax),%eax
 7cb:	84 c0                	test   %al,%al
 7cd:	74 10                	je     7df <strncmp+0x31>
 7cf:	8b 45 08             	mov    0x8(%ebp),%eax
 7d2:	0f b6 10             	movzbl (%eax),%edx
 7d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 7d8:	0f b6 00             	movzbl (%eax),%eax
 7db:	38 c2                	cmp    %al,%dl
 7dd:	74 d4                	je     7b3 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
 7df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 7e3:	75 07                	jne    7ec <strncmp+0x3e>
    return 0;
 7e5:	b8 00 00 00 00       	mov    $0x0,%eax
 7ea:	eb 18                	jmp    804 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
 7ec:	8b 45 08             	mov    0x8(%ebp),%eax
 7ef:	0f b6 00             	movzbl (%eax),%eax
 7f2:	0f b6 d0             	movzbl %al,%edx
 7f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 7f8:	0f b6 00             	movzbl (%eax),%eax
 7fb:	0f b6 c0             	movzbl %al,%eax
 7fe:	89 d1                	mov    %edx,%ecx
 800:	29 c1                	sub    %eax,%ecx
 802:	89 c8                	mov    %ecx,%eax
}
 804:	5d                   	pop    %ebp
 805:	c3                   	ret    

00000806 <strcat>:

void
strcat(char *dest, const char *p, const char *q)
{
 806:	55                   	push   %ebp
 807:	89 e5                	mov    %esp,%ebp
  while(*p){
 809:	eb 13                	jmp    81e <strcat+0x18>
    *dest++ = *p++;
 80b:	8b 45 0c             	mov    0xc(%ebp),%eax
 80e:	0f b6 10             	movzbl (%eax),%edx
 811:	8b 45 08             	mov    0x8(%ebp),%eax
 814:	88 10                	mov    %dl,(%eax)
 816:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 81a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

void
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
 81e:	8b 45 0c             	mov    0xc(%ebp),%eax
 821:	0f b6 00             	movzbl (%eax),%eax
 824:	84 c0                	test   %al,%al
 826:	75 e3                	jne    80b <strcat+0x5>
    *dest++ = *p++;
  }
  while(*q){
 828:	eb 13                	jmp    83d <strcat+0x37>
    *dest++ = *q++;
 82a:	8b 45 10             	mov    0x10(%ebp),%eax
 82d:	0f b6 10             	movzbl (%eax),%edx
 830:	8b 45 08             	mov    0x8(%ebp),%eax
 833:	88 10                	mov    %dl,(%eax)
 835:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 839:	83 45 10 01          	addl   $0x1,0x10(%ebp)
strcat(char *dest, const char *p, const char *q)
{
  while(*p){
    *dest++ = *p++;
  }
  while(*q){
 83d:	8b 45 10             	mov    0x10(%ebp),%eax
 840:	0f b6 00             	movzbl (%eax),%eax
 843:	84 c0                	test   %al,%al
 845:	75 e3                	jne    82a <strcat+0x24>
    *dest++ = *q++;
  }  
 847:	5d                   	pop    %ebp
 848:	c3                   	ret    
 849:	90                   	nop
 84a:	90                   	nop
 84b:	90                   	nop

0000084c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 84c:	b8 01 00 00 00       	mov    $0x1,%eax
 851:	cd 40                	int    $0x40
 853:	c3                   	ret    

00000854 <exit>:
SYSCALL(exit)
 854:	b8 02 00 00 00       	mov    $0x2,%eax
 859:	cd 40                	int    $0x40
 85b:	c3                   	ret    

0000085c <wait>:
SYSCALL(wait)
 85c:	b8 03 00 00 00       	mov    $0x3,%eax
 861:	cd 40                	int    $0x40
 863:	c3                   	ret    

00000864 <wait2>:
SYSCALL(wait2)
 864:	b8 16 00 00 00       	mov    $0x16,%eax
 869:	cd 40                	int    $0x40
 86b:	c3                   	ret    

0000086c <nice>:
SYSCALL(nice)
 86c:	b8 17 00 00 00       	mov    $0x17,%eax
 871:	cd 40                	int    $0x40
 873:	c3                   	ret    

00000874 <pipe>:
SYSCALL(pipe)
 874:	b8 04 00 00 00       	mov    $0x4,%eax
 879:	cd 40                	int    $0x40
 87b:	c3                   	ret    

0000087c <read>:
SYSCALL(read)
 87c:	b8 05 00 00 00       	mov    $0x5,%eax
 881:	cd 40                	int    $0x40
 883:	c3                   	ret    

00000884 <write>:
SYSCALL(write)
 884:	b8 10 00 00 00       	mov    $0x10,%eax
 889:	cd 40                	int    $0x40
 88b:	c3                   	ret    

0000088c <close>:
SYSCALL(close)
 88c:	b8 15 00 00 00       	mov    $0x15,%eax
 891:	cd 40                	int    $0x40
 893:	c3                   	ret    

00000894 <kill>:
SYSCALL(kill)
 894:	b8 06 00 00 00       	mov    $0x6,%eax
 899:	cd 40                	int    $0x40
 89b:	c3                   	ret    

0000089c <exec>:
SYSCALL(exec)
 89c:	b8 07 00 00 00       	mov    $0x7,%eax
 8a1:	cd 40                	int    $0x40
 8a3:	c3                   	ret    

000008a4 <open>:
SYSCALL(open)
 8a4:	b8 0f 00 00 00       	mov    $0xf,%eax
 8a9:	cd 40                	int    $0x40
 8ab:	c3                   	ret    

000008ac <mknod>:
SYSCALL(mknod)
 8ac:	b8 11 00 00 00       	mov    $0x11,%eax
 8b1:	cd 40                	int    $0x40
 8b3:	c3                   	ret    

000008b4 <unlink>:
SYSCALL(unlink)
 8b4:	b8 12 00 00 00       	mov    $0x12,%eax
 8b9:	cd 40                	int    $0x40
 8bb:	c3                   	ret    

000008bc <fstat>:
SYSCALL(fstat)
 8bc:	b8 08 00 00 00       	mov    $0x8,%eax
 8c1:	cd 40                	int    $0x40
 8c3:	c3                   	ret    

000008c4 <link>:
SYSCALL(link)
 8c4:	b8 13 00 00 00       	mov    $0x13,%eax
 8c9:	cd 40                	int    $0x40
 8cb:	c3                   	ret    

000008cc <mkdir>:
SYSCALL(mkdir)
 8cc:	b8 14 00 00 00       	mov    $0x14,%eax
 8d1:	cd 40                	int    $0x40
 8d3:	c3                   	ret    

000008d4 <chdir>:
SYSCALL(chdir)
 8d4:	b8 09 00 00 00       	mov    $0x9,%eax
 8d9:	cd 40                	int    $0x40
 8db:	c3                   	ret    

000008dc <dup>:
SYSCALL(dup)
 8dc:	b8 0a 00 00 00       	mov    $0xa,%eax
 8e1:	cd 40                	int    $0x40
 8e3:	c3                   	ret    

000008e4 <getpid>:
SYSCALL(getpid)
 8e4:	b8 0b 00 00 00       	mov    $0xb,%eax
 8e9:	cd 40                	int    $0x40
 8eb:	c3                   	ret    

000008ec <sbrk>:
SYSCALL(sbrk)
 8ec:	b8 0c 00 00 00       	mov    $0xc,%eax
 8f1:	cd 40                	int    $0x40
 8f3:	c3                   	ret    

000008f4 <sleep>:
SYSCALL(sleep)
 8f4:	b8 0d 00 00 00       	mov    $0xd,%eax
 8f9:	cd 40                	int    $0x40
 8fb:	c3                   	ret    

000008fc <uptime>:
SYSCALL(uptime)
 8fc:	b8 0e 00 00 00       	mov    $0xe,%eax
 901:	cd 40                	int    $0x40
 903:	c3                   	ret    

00000904 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 904:	55                   	push   %ebp
 905:	89 e5                	mov    %esp,%ebp
 907:	83 ec 28             	sub    $0x28,%esp
 90a:	8b 45 0c             	mov    0xc(%ebp),%eax
 90d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 910:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 917:	00 
 918:	8d 45 f4             	lea    -0xc(%ebp),%eax
 91b:	89 44 24 04          	mov    %eax,0x4(%esp)
 91f:	8b 45 08             	mov    0x8(%ebp),%eax
 922:	89 04 24             	mov    %eax,(%esp)
 925:	e8 5a ff ff ff       	call   884 <write>
}
 92a:	c9                   	leave  
 92b:	c3                   	ret    

0000092c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 92c:	55                   	push   %ebp
 92d:	89 e5                	mov    %esp,%ebp
 92f:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 932:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 939:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 93d:	74 17                	je     956 <printint+0x2a>
 93f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 943:	79 11                	jns    956 <printint+0x2a>
    neg = 1;
 945:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 94c:	8b 45 0c             	mov    0xc(%ebp),%eax
 94f:	f7 d8                	neg    %eax
 951:	89 45 ec             	mov    %eax,-0x14(%ebp)
 954:	eb 06                	jmp    95c <printint+0x30>
  } else {
    x = xx;
 956:	8b 45 0c             	mov    0xc(%ebp),%eax
 959:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 95c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 963:	8b 4d 10             	mov    0x10(%ebp),%ecx
 966:	8b 45 ec             	mov    -0x14(%ebp),%eax
 969:	ba 00 00 00 00       	mov    $0x0,%edx
 96e:	f7 f1                	div    %ecx
 970:	89 d0                	mov    %edx,%eax
 972:	0f b6 90 a8 12 00 00 	movzbl 0x12a8(%eax),%edx
 979:	8d 45 dc             	lea    -0x24(%ebp),%eax
 97c:	03 45 f4             	add    -0xc(%ebp),%eax
 97f:	88 10                	mov    %dl,(%eax)
 981:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 985:	8b 55 10             	mov    0x10(%ebp),%edx
 988:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 98b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 98e:	ba 00 00 00 00       	mov    $0x0,%edx
 993:	f7 75 d4             	divl   -0x2c(%ebp)
 996:	89 45 ec             	mov    %eax,-0x14(%ebp)
 999:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 99d:	75 c4                	jne    963 <printint+0x37>
  if(neg)
 99f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9a3:	74 2a                	je     9cf <printint+0xa3>
    buf[i++] = '-';
 9a5:	8d 45 dc             	lea    -0x24(%ebp),%eax
 9a8:	03 45 f4             	add    -0xc(%ebp),%eax
 9ab:	c6 00 2d             	movb   $0x2d,(%eax)
 9ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 9b2:	eb 1b                	jmp    9cf <printint+0xa3>
    putc(fd, buf[i]);
 9b4:	8d 45 dc             	lea    -0x24(%ebp),%eax
 9b7:	03 45 f4             	add    -0xc(%ebp),%eax
 9ba:	0f b6 00             	movzbl (%eax),%eax
 9bd:	0f be c0             	movsbl %al,%eax
 9c0:	89 44 24 04          	mov    %eax,0x4(%esp)
 9c4:	8b 45 08             	mov    0x8(%ebp),%eax
 9c7:	89 04 24             	mov    %eax,(%esp)
 9ca:	e8 35 ff ff ff       	call   904 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 9cf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 9d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9d7:	79 db                	jns    9b4 <printint+0x88>
    putc(fd, buf[i]);
}
 9d9:	c9                   	leave  
 9da:	c3                   	ret    

000009db <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 9db:	55                   	push   %ebp
 9dc:	89 e5                	mov    %esp,%ebp
 9de:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 9e1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 9e8:	8d 45 0c             	lea    0xc(%ebp),%eax
 9eb:	83 c0 04             	add    $0x4,%eax
 9ee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 9f1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 9f8:	e9 7d 01 00 00       	jmp    b7a <printf+0x19f>
    c = fmt[i] & 0xff;
 9fd:	8b 55 0c             	mov    0xc(%ebp),%edx
 a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a03:	01 d0                	add    %edx,%eax
 a05:	0f b6 00             	movzbl (%eax),%eax
 a08:	0f be c0             	movsbl %al,%eax
 a0b:	25 ff 00 00 00       	and    $0xff,%eax
 a10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 a13:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a17:	75 2c                	jne    a45 <printf+0x6a>
      if(c == '%'){
 a19:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a1d:	75 0c                	jne    a2b <printf+0x50>
        state = '%';
 a1f:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 a26:	e9 4b 01 00 00       	jmp    b76 <printf+0x19b>
      } else {
        putc(fd, c);
 a2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a2e:	0f be c0             	movsbl %al,%eax
 a31:	89 44 24 04          	mov    %eax,0x4(%esp)
 a35:	8b 45 08             	mov    0x8(%ebp),%eax
 a38:	89 04 24             	mov    %eax,(%esp)
 a3b:	e8 c4 fe ff ff       	call   904 <putc>
 a40:	e9 31 01 00 00       	jmp    b76 <printf+0x19b>
      }
    } else if(state == '%'){
 a45:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 a49:	0f 85 27 01 00 00    	jne    b76 <printf+0x19b>
      if(c == 'd'){
 a4f:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 a53:	75 2d                	jne    a82 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 a55:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a58:	8b 00                	mov    (%eax),%eax
 a5a:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 a61:	00 
 a62:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 a69:	00 
 a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
 a6e:	8b 45 08             	mov    0x8(%ebp),%eax
 a71:	89 04 24             	mov    %eax,(%esp)
 a74:	e8 b3 fe ff ff       	call   92c <printint>
        ap++;
 a79:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a7d:	e9 ed 00 00 00       	jmp    b6f <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 a82:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 a86:	74 06                	je     a8e <printf+0xb3>
 a88:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 a8c:	75 2d                	jne    abb <printf+0xe0>
        printint(fd, *ap, 16, 0);
 a8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a91:	8b 00                	mov    (%eax),%eax
 a93:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 a9a:	00 
 a9b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 aa2:	00 
 aa3:	89 44 24 04          	mov    %eax,0x4(%esp)
 aa7:	8b 45 08             	mov    0x8(%ebp),%eax
 aaa:	89 04 24             	mov    %eax,(%esp)
 aad:	e8 7a fe ff ff       	call   92c <printint>
        ap++;
 ab2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 ab6:	e9 b4 00 00 00       	jmp    b6f <printf+0x194>
      } else if(c == 's'){
 abb:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 abf:	75 46                	jne    b07 <printf+0x12c>
        s = (char*)*ap;
 ac1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 ac4:	8b 00                	mov    (%eax),%eax
 ac6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 ac9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 acd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ad1:	75 27                	jne    afa <printf+0x11f>
          s = "(null)";
 ad3:	c7 45 f4 95 0f 00 00 	movl   $0xf95,-0xc(%ebp)
        while(*s != 0){
 ada:	eb 1e                	jmp    afa <printf+0x11f>
          putc(fd, *s);
 adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 adf:	0f b6 00             	movzbl (%eax),%eax
 ae2:	0f be c0             	movsbl %al,%eax
 ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
 ae9:	8b 45 08             	mov    0x8(%ebp),%eax
 aec:	89 04 24             	mov    %eax,(%esp)
 aef:	e8 10 fe ff ff       	call   904 <putc>
          s++;
 af4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 af8:	eb 01                	jmp    afb <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 afa:	90                   	nop
 afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afe:	0f b6 00             	movzbl (%eax),%eax
 b01:	84 c0                	test   %al,%al
 b03:	75 d7                	jne    adc <printf+0x101>
 b05:	eb 68                	jmp    b6f <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 b07:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 b0b:	75 1d                	jne    b2a <printf+0x14f>
        putc(fd, *ap);
 b0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b10:	8b 00                	mov    (%eax),%eax
 b12:	0f be c0             	movsbl %al,%eax
 b15:	89 44 24 04          	mov    %eax,0x4(%esp)
 b19:	8b 45 08             	mov    0x8(%ebp),%eax
 b1c:	89 04 24             	mov    %eax,(%esp)
 b1f:	e8 e0 fd ff ff       	call   904 <putc>
        ap++;
 b24:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b28:	eb 45                	jmp    b6f <printf+0x194>
      } else if(c == '%'){
 b2a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b2e:	75 17                	jne    b47 <printf+0x16c>
        putc(fd, c);
 b30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b33:	0f be c0             	movsbl %al,%eax
 b36:	89 44 24 04          	mov    %eax,0x4(%esp)
 b3a:	8b 45 08             	mov    0x8(%ebp),%eax
 b3d:	89 04 24             	mov    %eax,(%esp)
 b40:	e8 bf fd ff ff       	call   904 <putc>
 b45:	eb 28                	jmp    b6f <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b47:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 b4e:	00 
 b4f:	8b 45 08             	mov    0x8(%ebp),%eax
 b52:	89 04 24             	mov    %eax,(%esp)
 b55:	e8 aa fd ff ff       	call   904 <putc>
        putc(fd, c);
 b5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b5d:	0f be c0             	movsbl %al,%eax
 b60:	89 44 24 04          	mov    %eax,0x4(%esp)
 b64:	8b 45 08             	mov    0x8(%ebp),%eax
 b67:	89 04 24             	mov    %eax,(%esp)
 b6a:	e8 95 fd ff ff       	call   904 <putc>
      }
      state = 0;
 b6f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 b76:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 b7a:	8b 55 0c             	mov    0xc(%ebp),%edx
 b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b80:	01 d0                	add    %edx,%eax
 b82:	0f b6 00             	movzbl (%eax),%eax
 b85:	84 c0                	test   %al,%al
 b87:	0f 85 70 fe ff ff    	jne    9fd <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 b8d:	c9                   	leave  
 b8e:	c3                   	ret    
 b8f:	90                   	nop

00000b90 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b90:	55                   	push   %ebp
 b91:	89 e5                	mov    %esp,%ebp
 b93:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b96:	8b 45 08             	mov    0x8(%ebp),%eax
 b99:	83 e8 08             	sub    $0x8,%eax
 b9c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b9f:	a1 c4 12 00 00       	mov    0x12c4,%eax
 ba4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ba7:	eb 24                	jmp    bcd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ba9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bac:	8b 00                	mov    (%eax),%eax
 bae:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bb1:	77 12                	ja     bc5 <free+0x35>
 bb3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bb6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bb9:	77 24                	ja     bdf <free+0x4f>
 bbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bbe:	8b 00                	mov    (%eax),%eax
 bc0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 bc3:	77 1a                	ja     bdf <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bc8:	8b 00                	mov    (%eax),%eax
 bca:	89 45 fc             	mov    %eax,-0x4(%ebp)
 bcd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bd0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bd3:	76 d4                	jbe    ba9 <free+0x19>
 bd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bd8:	8b 00                	mov    (%eax),%eax
 bda:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 bdd:	76 ca                	jbe    ba9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 bdf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 be2:	8b 40 04             	mov    0x4(%eax),%eax
 be5:	c1 e0 03             	shl    $0x3,%eax
 be8:	89 c2                	mov    %eax,%edx
 bea:	03 55 f8             	add    -0x8(%ebp),%edx
 bed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bf0:	8b 00                	mov    (%eax),%eax
 bf2:	39 c2                	cmp    %eax,%edx
 bf4:	75 24                	jne    c1a <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 bf6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bf9:	8b 50 04             	mov    0x4(%eax),%edx
 bfc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bff:	8b 00                	mov    (%eax),%eax
 c01:	8b 40 04             	mov    0x4(%eax),%eax
 c04:	01 c2                	add    %eax,%edx
 c06:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c09:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 c0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c0f:	8b 00                	mov    (%eax),%eax
 c11:	8b 10                	mov    (%eax),%edx
 c13:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c16:	89 10                	mov    %edx,(%eax)
 c18:	eb 0a                	jmp    c24 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 c1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c1d:	8b 10                	mov    (%eax),%edx
 c1f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c22:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 c24:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c27:	8b 40 04             	mov    0x4(%eax),%eax
 c2a:	c1 e0 03             	shl    $0x3,%eax
 c2d:	03 45 fc             	add    -0x4(%ebp),%eax
 c30:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c33:	75 20                	jne    c55 <free+0xc5>
    p->s.size += bp->s.size;
 c35:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c38:	8b 50 04             	mov    0x4(%eax),%edx
 c3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c3e:	8b 40 04             	mov    0x4(%eax),%eax
 c41:	01 c2                	add    %eax,%edx
 c43:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c46:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 c49:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c4c:	8b 10                	mov    (%eax),%edx
 c4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c51:	89 10                	mov    %edx,(%eax)
 c53:	eb 08                	jmp    c5d <free+0xcd>
  } else
    p->s.ptr = bp;
 c55:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c58:	8b 55 f8             	mov    -0x8(%ebp),%edx
 c5b:	89 10                	mov    %edx,(%eax)
  freep = p;
 c5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c60:	a3 c4 12 00 00       	mov    %eax,0x12c4
}
 c65:	c9                   	leave  
 c66:	c3                   	ret    

00000c67 <morecore>:

static Header*
morecore(uint nu)
{
 c67:	55                   	push   %ebp
 c68:	89 e5                	mov    %esp,%ebp
 c6a:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 c6d:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 c74:	77 07                	ja     c7d <morecore+0x16>
    nu = 4096;
 c76:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 c7d:	8b 45 08             	mov    0x8(%ebp),%eax
 c80:	c1 e0 03             	shl    $0x3,%eax
 c83:	89 04 24             	mov    %eax,(%esp)
 c86:	e8 61 fc ff ff       	call   8ec <sbrk>
 c8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 c8e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 c92:	75 07                	jne    c9b <morecore+0x34>
    return 0;
 c94:	b8 00 00 00 00       	mov    $0x0,%eax
 c99:	eb 22                	jmp    cbd <morecore+0x56>
  hp = (Header*)p;
 c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 ca1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ca4:	8b 55 08             	mov    0x8(%ebp),%edx
 ca7:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cad:	83 c0 08             	add    $0x8,%eax
 cb0:	89 04 24             	mov    %eax,(%esp)
 cb3:	e8 d8 fe ff ff       	call   b90 <free>
  return freep;
 cb8:	a1 c4 12 00 00       	mov    0x12c4,%eax
}
 cbd:	c9                   	leave  
 cbe:	c3                   	ret    

00000cbf <malloc>:

void*
malloc(uint nbytes)
{
 cbf:	55                   	push   %ebp
 cc0:	89 e5                	mov    %esp,%ebp
 cc2:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 cc5:	8b 45 08             	mov    0x8(%ebp),%eax
 cc8:	83 c0 07             	add    $0x7,%eax
 ccb:	c1 e8 03             	shr    $0x3,%eax
 cce:	83 c0 01             	add    $0x1,%eax
 cd1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 cd4:	a1 c4 12 00 00       	mov    0x12c4,%eax
 cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 cdc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 ce0:	75 23                	jne    d05 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 ce2:	c7 45 f0 bc 12 00 00 	movl   $0x12bc,-0x10(%ebp)
 ce9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cec:	a3 c4 12 00 00       	mov    %eax,0x12c4
 cf1:	a1 c4 12 00 00       	mov    0x12c4,%eax
 cf6:	a3 bc 12 00 00       	mov    %eax,0x12bc
    base.s.size = 0;
 cfb:	c7 05 c0 12 00 00 00 	movl   $0x0,0x12c0
 d02:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d08:	8b 00                	mov    (%eax),%eax
 d0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d10:	8b 40 04             	mov    0x4(%eax),%eax
 d13:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d16:	72 4d                	jb     d65 <malloc+0xa6>
      if(p->s.size == nunits)
 d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d1b:	8b 40 04             	mov    0x4(%eax),%eax
 d1e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d21:	75 0c                	jne    d2f <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d26:	8b 10                	mov    (%eax),%edx
 d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d2b:	89 10                	mov    %edx,(%eax)
 d2d:	eb 26                	jmp    d55 <malloc+0x96>
      else {
        p->s.size -= nunits;
 d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d32:	8b 40 04             	mov    0x4(%eax),%eax
 d35:	89 c2                	mov    %eax,%edx
 d37:	2b 55 ec             	sub    -0x14(%ebp),%edx
 d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d3d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d43:	8b 40 04             	mov    0x4(%eax),%eax
 d46:	c1 e0 03             	shl    $0x3,%eax
 d49:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d4f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 d52:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d58:	a3 c4 12 00 00       	mov    %eax,0x12c4
      return (void*)(p + 1);
 d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d60:	83 c0 08             	add    $0x8,%eax
 d63:	eb 38                	jmp    d9d <malloc+0xde>
    }
    if(p == freep)
 d65:	a1 c4 12 00 00       	mov    0x12c4,%eax
 d6a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 d6d:	75 1b                	jne    d8a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 d6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 d72:	89 04 24             	mov    %eax,(%esp)
 d75:	e8 ed fe ff ff       	call   c67 <morecore>
 d7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 d7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 d81:	75 07                	jne    d8a <malloc+0xcb>
        return 0;
 d83:	b8 00 00 00 00       	mov    $0x0,%eax
 d88:	eb 13                	jmp    d9d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d93:	8b 00                	mov    (%eax),%eax
 d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 d98:	e9 70 ff ff ff       	jmp    d0d <malloc+0x4e>
}
 d9d:	c9                   	leave  
 d9e:	c3                   	ret    
