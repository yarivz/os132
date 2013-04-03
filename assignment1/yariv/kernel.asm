
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 6f 37 10 80       	mov    $0x8010376f,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 38 87 10 	movl   $0x80108738,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 50 50 00 00       	call   8010509e <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 db 10 80 84 	movl   $0x8010db84,0x8010db90
80100055:	db 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 db 10 80 84 	movl   $0x8010db84,0x8010db94
8010005f:	db 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 db 10 80       	mov    0x8010db94,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 db 10 80       	mov    %eax,0x8010db94

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801000bd:	e8 fd 4f 00 00       	call   801050bf <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 db 10 80       	mov    0x8010db94,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	89 c2                	mov    %eax,%edx
801000f5:	83 ca 01             	or     $0x1,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100104:	e8 18 50 00 00       	call   80105121 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 b6 4c 00 00       	call   80104dda <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 db 10 80       	mov    0x8010db90,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010017c:	e8 a0 4f 00 00       	call   80105121 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 84 db 10 80 	cmpl   $0x8010db84,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 3f 87 10 80 	movl   $0x8010873f,(%esp)
8010019f:	e8 99 03 00 00       	call   8010053d <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 44 29 00 00       	call   80102b1c <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 50 87 10 80 	movl   $0x80108750,(%esp)
801001f6:	e8 42 03 00 00       	call   8010053d <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	89 c2                	mov    %eax,%edx
80100202:	83 ca 04             	or     $0x4,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 07 29 00 00       	call   80102b1c <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 57 87 10 80 	movl   $0x80108757,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 7e 4e 00 00       	call   801050bf <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 94 db 10 80    	mov    0x8010db94,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 db 10 80 	movl   $0x8010db84,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 db 10 80       	mov    0x8010db94,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 db 10 80       	mov    %eax,0x8010db94

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 fe             	and    $0xfffffffe,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 14 4c 00 00       	call   80104eb6 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 73 4e 00 00       	call   80105121 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	53                   	push   %ebx
801002b4:	83 ec 14             	sub    $0x14,%esp
801002b7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002be:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801002c2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801002c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801002ca:	ec                   	in     (%dx),%al
801002cb:	89 c3                	mov    %eax,%ebx
801002cd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002d0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801002d4:	83 c4 14             	add    $0x14,%esp
801002d7:	5b                   	pop    %ebx
801002d8:	5d                   	pop    %ebp
801002d9:	c3                   	ret    

801002da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002da:	55                   	push   %ebp
801002db:	89 e5                	mov    %esp,%ebp
801002dd:	83 ec 08             	sub    $0x8,%esp
801002e0:	8b 55 08             	mov    0x8(%ebp),%edx
801002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801002e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002f5:	ee                   	out    %al,(%dx)
}
801002f6:	c9                   	leave  
801002f7:	c3                   	ret    

801002f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002f8:	55                   	push   %ebp
801002f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002fb:	fa                   	cli    
}
801002fc:	5d                   	pop    %ebp
801002fd:	c3                   	ret    

801002fe <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002fe:	55                   	push   %ebp
801002ff:	89 e5                	mov    %esp,%ebp
80100301:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100304:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100308:	74 19                	je     80100323 <printint+0x25>
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	c1 e8 1f             	shr    $0x1f,%eax
80100310:	89 45 10             	mov    %eax,0x10(%ebp)
80100313:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100317:	74 0a                	je     80100323 <printint+0x25>
    x = -xx;
80100319:	8b 45 08             	mov    0x8(%ebp),%eax
8010031c:	f7 d8                	neg    %eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100321:	eb 06                	jmp    80100329 <printint+0x2b>
  else
    x = xx;
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100336:	ba 00 00 00 00       	mov    $0x0,%edx
8010033b:	f7 f1                	div    %ecx
8010033d:	89 d0                	mov    %edx,%eax
8010033f:	0f b6 90 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%edx
80100346:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100349:	03 45 f4             	add    -0xc(%ebp),%eax
8010034c:	88 10                	mov    %dl,(%eax)
8010034e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100352:	8b 55 0c             	mov    0xc(%ebp),%edx
80100355:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 75 d4             	divl   -0x2c(%ebp)
80100363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036a:	75 c4                	jne    80100330 <printint+0x32>

  if(sign)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 23                	je     80100395 <printint+0x97>
    buf[i++] = '-';
80100372:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100375:	03 45 f4             	add    -0xc(%ebp),%eax
80100378:	c6 00 2d             	movb   $0x2d,(%eax)
8010037b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
8010037f:	eb 14                	jmp    80100395 <printint+0x97>
    consputc(buf[i]);
80100381:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100384:	03 45 f4             	add    -0xc(%ebp),%eax
80100387:	0f b6 00             	movzbl (%eax),%eax
8010038a:	0f be c0             	movsbl %al,%eax
8010038d:	89 04 24             	mov    %eax,(%esp)
80100390:	e8 46 04 00 00       	call   801007db <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100395:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010039d:	79 e2                	jns    80100381 <printint+0x83>
    consputc(buf[i]);
}
8010039f:	c9                   	leave  
801003a0:	c3                   	ret    

801003a1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a1:	55                   	push   %ebp
801003a2:	89 e5                	mov    %esp,%ebp
801003a4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a7:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003bc:	e8 fe 4c 00 00       	call   801050bf <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 5e 87 10 80 	movl   $0x8010875e,(%esp)
801003cf:	e8 69 01 00 00       	call   8010053d <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e1:	e9 20 01 00 00       	jmp    80100506 <cprintf+0x165>
    if(c != '%'){
801003e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003ea:	74 10                	je     801003fc <cprintf+0x5b>
      consputc(c);
801003ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ef:	89 04 24             	mov    %eax,(%esp)
801003f2:	e8 e4 03 00 00       	call   801007db <consputc>
      continue;
801003f7:	e9 06 01 00 00       	jmp    80100502 <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
801003fc:	8b 55 08             	mov    0x8(%ebp),%edx
801003ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100406:	01 d0                	add    %edx,%eax
80100408:	0f b6 00             	movzbl (%eax),%eax
8010040b:	0f be c0             	movsbl %al,%eax
8010040e:	25 ff 00 00 00       	and    $0xff,%eax
80100413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100416:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010041a:	0f 84 08 01 00 00    	je     80100528 <cprintf+0x187>
      break;
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4d                	je     80100475 <cprintf+0xd4>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0x9f>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13b>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xae>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x149>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 53                	je     80100498 <cprintf+0xf7>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2b                	je     80100475 <cprintf+0xd4>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x149>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8b 00                	mov    (%eax),%eax
80100454:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100458:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010045f:	00 
80100460:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100467:	00 
80100468:	89 04 24             	mov    %eax,(%esp)
8010046b:	e8 8e fe ff ff       	call   801002fe <printint>
      break;
80100470:	e9 8d 00 00 00       	jmp    80100502 <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100478:	8b 00                	mov    (%eax),%eax
8010047a:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
8010047e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100485:	00 
80100486:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010048d:	00 
8010048e:	89 04 24             	mov    %eax,(%esp)
80100491:	e8 68 fe ff ff       	call   801002fe <printint>
      break;
80100496:	eb 6a                	jmp    80100502 <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
80100498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049b:	8b 00                	mov    (%eax),%eax
8010049d:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004a4:	0f 94 c0             	sete   %al
801004a7:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004ab:	84 c0                	test   %al,%al
801004ad:	74 20                	je     801004cf <cprintf+0x12e>
        s = "(null)";
801004af:	c7 45 ec 67 87 10 80 	movl   $0x80108767,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 12 03 00 00       	call   801007db <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004c9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004cd:	eb 01                	jmp    801004d0 <cprintf+0x12f>
801004cf:	90                   	nop
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 de                	jne    801004b8 <cprintf+0x117>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x161>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 f3 02 00 00       	call   801007db <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 e5 02 00 00       	call   801007db <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 da 02 00 00       	call   801007db <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 c0 fe ff ff    	jne    801003e6 <cprintf+0x45>
80100526:	eb 01                	jmp    80100529 <cprintf+0x188>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100528:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100529:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052d:	74 0c                	je     8010053b <cprintf+0x19a>
    release(&cons.lock);
8010052f:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100536:	e8 e6 4b 00 00       	call   80105121 <release>
}
8010053b:	c9                   	leave  
8010053c:	c3                   	ret    

8010053d <panic>:

void
panic(char *s)
{
8010053d:	55                   	push   %ebp
8010053e:	89 e5                	mov    %esp,%ebp
80100540:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100543:	e8 b0 fd ff ff       	call   801002f8 <cli>
  cons.locking = 0;
80100548:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 6e 87 10 80 	movl   $0x8010876e,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 7d 87 10 80 	movl   $0x8010877d,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 d9 4b 00 00       	call   80105170 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 7f 87 10 80 	movl   $0x8010877f,(%esp)
801005b2:	e8 ea fd ff ff       	call   801003a1 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005bb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bf:	7e df                	jle    801005a0 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005c1:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005c8:	00 00 00 
  for(;;)
    ;
801005cb:	eb fe                	jmp    801005cb <panic+0x8e>

801005cd <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005cd:	55                   	push   %ebp
801005ce:	89 e5                	mov    %esp,%ebp
801005d0:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d3:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005da:	00 
801005db:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005e2:	e8 f3 fc ff ff       	call   801002da <outb>
  pos = inb(CRTPORT+1) << 8;
801005e7:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005ee:	e8 bd fc ff ff       	call   801002b0 <inb>
801005f3:	0f b6 c0             	movzbl %al,%eax
801005f6:	c1 e0 08             	shl    $0x8,%eax
801005f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005fc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100603:	00 
80100604:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010060b:	e8 ca fc ff ff       	call   801002da <outb>
  pos |= inb(CRTPORT+1);
80100610:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100617:	e8 94 fc ff ff       	call   801002b0 <inb>
8010061c:	0f b6 c0             	movzbl %al,%eax
8010061f:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100622:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100626:	75 33                	jne    8010065b <cgaputc+0x8e>
    pos += 80 - pos%80;
80100628:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010062b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100630:	89 c8                	mov    %ecx,%eax
80100632:	f7 ea                	imul   %edx
80100634:	c1 fa 05             	sar    $0x5,%edx
80100637:	89 c8                	mov    %ecx,%eax
80100639:	c1 f8 1f             	sar    $0x1f,%eax
8010063c:	29 c2                	sub    %eax,%edx
8010063e:	89 d0                	mov    %edx,%eax
80100640:	c1 e0 02             	shl    $0x2,%eax
80100643:	01 d0                	add    %edx,%eax
80100645:	c1 e0 04             	shl    $0x4,%eax
80100648:	89 ca                	mov    %ecx,%edx
8010064a:	29 c2                	sub    %eax,%edx
8010064c:	b8 50 00 00 00       	mov    $0x50,%eax
80100651:	29 d0                	sub    %edx,%eax
80100653:	01 45 f4             	add    %eax,-0xc(%ebp)
80100656:	e9 a8 00 00 00       	jmp    80100703 <cgaputc+0x136>
  else if(c == BACKSPACE){
8010065b:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100662:	75 13                	jne    80100677 <cgaputc+0xaa>
    if(pos > 0) --pos;
80100664:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100668:	0f 8e 95 00 00 00    	jle    80100703 <cgaputc+0x136>
8010066e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100672:	e9 8c 00 00 00       	jmp    80100703 <cgaputc+0x136>
  }
  else if(c == KEY_LF){
80100677:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
8010067e:	75 2e                	jne    801006ae <cgaputc+0xe1>
    if(pos%80 > 0) --pos;
80100680:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100683:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100688:	89 c8                	mov    %ecx,%eax
8010068a:	f7 ea                	imul   %edx
8010068c:	c1 fa 05             	sar    $0x5,%edx
8010068f:	89 c8                	mov    %ecx,%eax
80100691:	c1 f8 1f             	sar    $0x1f,%eax
80100694:	29 c2                	sub    %eax,%edx
80100696:	89 d0                	mov    %edx,%eax
80100698:	c1 e0 02             	shl    $0x2,%eax
8010069b:	01 d0                	add    %edx,%eax
8010069d:	c1 e0 04             	shl    $0x4,%eax
801006a0:	89 ca                	mov    %ecx,%edx
801006a2:	29 c2                	sub    %eax,%edx
801006a4:	85 d2                	test   %edx,%edx
801006a6:	7e 5b                	jle    80100703 <cgaputc+0x136>
801006a8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006ac:	eb 55                	jmp    80100703 <cgaputc+0x136>
  }
  else if(c == KEY_RT){
801006ae:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
801006b5:	75 2f                	jne    801006e6 <cgaputc+0x119>
    if(pos%80 < 79) ++pos;
801006b7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ba:	ba 67 66 66 66       	mov    $0x66666667,%edx
801006bf:	89 c8                	mov    %ecx,%eax
801006c1:	f7 ea                	imul   %edx
801006c3:	c1 fa 05             	sar    $0x5,%edx
801006c6:	89 c8                	mov    %ecx,%eax
801006c8:	c1 f8 1f             	sar    $0x1f,%eax
801006cb:	29 c2                	sub    %eax,%edx
801006cd:	89 d0                	mov    %edx,%eax
801006cf:	c1 e0 02             	shl    $0x2,%eax
801006d2:	01 d0                	add    %edx,%eax
801006d4:	c1 e0 04             	shl    $0x4,%eax
801006d7:	89 ca                	mov    %ecx,%edx
801006d9:	29 c2                	sub    %eax,%edx
801006db:	83 fa 4e             	cmp    $0x4e,%edx
801006de:	7f 23                	jg     80100703 <cgaputc+0x136>
801006e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801006e4:	eb 1d                	jmp    80100703 <cgaputc+0x136>
  }
  else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006e6:	a1 00 90 10 80       	mov    0x80109000,%eax
801006eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006ee:	01 d2                	add    %edx,%edx
801006f0:	01 c2                	add    %eax,%edx
801006f2:	8b 45 08             	mov    0x8(%ebp),%eax
801006f5:	66 25 ff 00          	and    $0xff,%ax
801006f9:	80 cc 07             	or     $0x7,%ah
801006fc:	66 89 02             	mov    %ax,(%edx)
801006ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
80100703:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010070a:	7e 53                	jle    8010075f <cgaputc+0x192>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010070c:	a1 00 90 10 80       	mov    0x80109000,%eax
80100711:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100717:	a1 00 90 10 80       	mov    0x80109000,%eax
8010071c:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
80100723:	00 
80100724:	89 54 24 04          	mov    %edx,0x4(%esp)
80100728:	89 04 24             	mov    %eax,(%esp)
8010072b:	e8 b1 4c 00 00       	call   801053e1 <memmove>
    pos -= 80;
80100730:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100734:	b8 80 07 00 00       	mov    $0x780,%eax
80100739:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010073c:	01 c0                	add    %eax,%eax
8010073e:	8b 15 00 90 10 80    	mov    0x80109000,%edx
80100744:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100747:	01 c9                	add    %ecx,%ecx
80100749:	01 ca                	add    %ecx,%edx
8010074b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010074f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100756:	00 
80100757:	89 14 24             	mov    %edx,(%esp)
8010075a:	e8 af 4b 00 00       	call   8010530e <memset>
  }
  
  outb(CRTPORT, 14);
8010075f:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100766:	00 
80100767:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010076e:	e8 67 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
80100773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100776:	c1 f8 08             	sar    $0x8,%eax
80100779:	0f b6 c0             	movzbl %al,%eax
8010077c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100780:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100787:	e8 4e fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
8010078c:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100793:	00 
80100794:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010079b:	e8 3a fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
801007a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007a3:	0f b6 c0             	movzbl %al,%eax
801007a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801007aa:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801007b1:	e8 24 fb ff ff       	call   801002da <outb>
  if(c != KEY_LF && c != KEY_RT)
801007b6:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
801007bd:	74 1a                	je     801007d9 <cgaputc+0x20c>
801007bf:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
801007c6:	74 11                	je     801007d9 <cgaputc+0x20c>
    crt[pos] = ' ' | 0x0700;
801007c8:	a1 00 90 10 80       	mov    0x80109000,%eax
801007cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801007d0:	01 d2                	add    %edx,%edx
801007d2:	01 d0                	add    %edx,%eax
801007d4:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007d9:	c9                   	leave  
801007da:	c3                   	ret    

801007db <consputc>:

void
consputc(int c)
{
801007db:	55                   	push   %ebp
801007dc:	89 e5                	mov    %esp,%ebp
801007de:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
801007e1:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
801007e6:	85 c0                	test   %eax,%eax
801007e8:	74 07                	je     801007f1 <consputc+0x16>
    cli();
801007ea:	e8 09 fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
801007ef:	eb fe                	jmp    801007ef <consputc+0x14>
  }

  if(c == BACKSPACE){
801007f1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007f8:	75 26                	jne    80100820 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007fa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100801:	e8 97 65 00 00       	call   80106d9d <uartputc>
80100806:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010080d:	e8 8b 65 00 00       	call   80106d9d <uartputc>
80100812:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100819:	e8 7f 65 00 00       	call   80106d9d <uartputc>
8010081e:	eb 0b                	jmp    8010082b <consputc+0x50>
  }
  else if (c == KEY_RT){
    uartputc(0x601);
  }*/
  else
    uartputc(c);
80100820:	8b 45 08             	mov    0x8(%ebp),%eax
80100823:	89 04 24             	mov    %eax,(%esp)
80100826:	e8 72 65 00 00       	call   80106d9d <uartputc>
  cgaputc(c);
8010082b:	8b 45 08             	mov    0x8(%ebp),%eax
8010082e:	89 04 24             	mov    %eax,(%esp)
80100831:	e8 97 fd ff ff       	call   801005cd <cgaputc>
}
80100836:	c9                   	leave  
80100837:	c3                   	ret    

80100838 <shiftRightBuf>:

#define C(x)  ((x)-'@')  // Control-x

void
shiftRightBuf(int e, int k)
{
80100838:	55                   	push   %ebp
80100839:	89 e5                	mov    %esp,%ebp
8010083b:	83 ec 10             	sub    $0x10,%esp
  int i = e+1;
8010083e:	8b 45 08             	mov    0x8(%ebp),%eax
80100841:	83 c0 01             	add    $0x1,%eax
80100844:	89 45 fc             	mov    %eax,-0x4(%ebp)
  int j=0;
80100847:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(;j < k ;i--,j++){
8010084e:	eb 21                	jmp    80100871 <shiftRightBuf+0x39>
    input.buf[i] = input.buf[i-1];
80100850:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100853:	83 e8 01             	sub    $0x1,%eax
80100856:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
8010085d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80100860:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
80100866:	88 42 04             	mov    %al,0x4(%edx)
void
shiftRightBuf(int e, int k)
{
  int i = e+1;
  int j=0;
  for(;j < k ;i--,j++){
80100869:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010086d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80100871:	8b 45 f8             	mov    -0x8(%ebp),%eax
80100874:	3b 45 0c             	cmp    0xc(%ebp),%eax
80100877:	7c d7                	jl     80100850 <shiftRightBuf+0x18>
    input.buf[i] = input.buf[i-1];
  }
}
80100879:	c9                   	leave  
8010087a:	c3                   	ret    

8010087b <shiftLeftBuf>:

void
shiftLeftBuf(int e, int k)
{
8010087b:	55                   	push   %ebp
8010087c:	89 e5                	mov    %esp,%ebp
8010087e:	83 ec 10             	sub    $0x10,%esp
  int i = e+k;
80100881:	8b 45 0c             	mov    0xc(%ebp),%eax
80100884:	8b 55 08             	mov    0x8(%ebp),%edx
80100887:	01 d0                	add    %edx,%eax
80100889:	89 45 fc             	mov    %eax,-0x4(%ebp)
  int j=0;
8010088c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(;j < (-1)*k ;i++,j++){
80100893:	eb 21                	jmp    801008b6 <shiftLeftBuf+0x3b>
    input.buf[i] = input.buf[i+1];
80100895:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100898:	83 c0 01             	add    $0x1,%eax
8010089b:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
801008a2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801008a5:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
801008ab:	88 42 04             	mov    %al,0x4(%edx)
void
shiftLeftBuf(int e, int k)
{
  int i = e+k;
  int j=0;
  for(;j < (-1)*k ;i++,j++){
801008ae:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801008b2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801008b9:	f7 d8                	neg    %eax
801008bb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801008be:	7f d5                	jg     80100895 <shiftLeftBuf+0x1a>
    input.buf[i] = input.buf[i+1];
  }
  input.buf[e] = ' ';
801008c0:	8b 45 08             	mov    0x8(%ebp),%eax
801008c3:	05 d0 dd 10 80       	add    $0x8010ddd0,%eax
801008c8:	c6 40 04 20          	movb   $0x20,0x4(%eax)
}
801008cc:	c9                   	leave  
801008cd:	c3                   	ret    

801008ce <consoleintr>:

void
consoleintr(int (*getc)(void))
{
801008ce:	55                   	push   %ebp
801008cf:	89 e5                	mov    %esp,%ebp
801008d1:	83 ec 38             	sub    $0x38,%esp
  int c;

  acquire(&input.lock);
801008d4:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
801008db:	e8 df 47 00 00       	call   801050bf <acquire>
  while((c = getc()) >= 0){
801008e0:	e9 89 03 00 00       	jmp    80100c6e <consoleintr+0x3a0>
    switch(c){
801008e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801008e8:	83 f8 15             	cmp    $0x15,%eax
801008eb:	74 59                	je     80100946 <consoleintr+0x78>
801008ed:	83 f8 15             	cmp    $0x15,%eax
801008f0:	7f 0f                	jg     80100901 <consoleintr+0x33>
801008f2:	83 f8 08             	cmp    $0x8,%eax
801008f5:	74 7e                	je     80100975 <consoleintr+0xa7>
801008f7:	83 f8 10             	cmp    $0x10,%eax
801008fa:	74 25                	je     80100921 <consoleintr+0x53>
801008fc:	e9 ca 01 00 00       	jmp    80100acb <consoleintr+0x1fd>
80100901:	3d e4 00 00 00       	cmp    $0xe4,%eax
80100906:	0f 84 40 01 00 00    	je     80100a4c <consoleintr+0x17e>
8010090c:	3d e5 00 00 00       	cmp    $0xe5,%eax
80100911:	0f 84 78 01 00 00    	je     80100a8f <consoleintr+0x1c1>
80100917:	83 f8 7f             	cmp    $0x7f,%eax
8010091a:	74 59                	je     80100975 <consoleintr+0xa7>
8010091c:	e9 aa 01 00 00       	jmp    80100acb <consoleintr+0x1fd>
    case C('P'):  // Process listing.
      procdump();
80100921:	e8 36 46 00 00       	call   80104f5c <procdump>
      break;
80100926:	e9 43 03 00 00       	jmp    80100c6e <consoleintr+0x3a0>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010092b:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100930:	83 e8 01             	sub    $0x1,%eax
80100933:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
80100938:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010093f:	e8 97 fe ff ff       	call   801007db <consputc>
80100944:	eb 01                	jmp    80100947 <consoleintr+0x79>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100946:	90                   	nop
80100947:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010094d:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100952:	39 c2                	cmp    %eax,%edx
80100954:	0f 84 07 03 00 00    	je     80100c61 <consoleintr+0x393>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010095a:	a1 5c de 10 80       	mov    0x8010de5c,%eax
8010095f:	83 e8 01             	sub    $0x1,%eax
80100962:	83 e0 7f             	and    $0x7f,%eax
80100965:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010096c:	3c 0a                	cmp    $0xa,%al
8010096e:	75 bb                	jne    8010092b <consoleintr+0x5d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100970:	e9 ec 02 00 00       	jmp    80100c61 <consoleintr+0x393>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100975:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010097b:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100980:	39 c2                	cmp    %eax,%edx
80100982:	0f 84 dc 02 00 00    	je     80100c64 <consoleintr+0x396>
	if(input.a<0)
80100988:	a1 60 de 10 80       	mov    0x8010de60,%eax
8010098d:	85 c0                	test   %eax,%eax
8010098f:	0f 89 99 00 00 00    	jns    80100a2e <consoleintr+0x160>
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
80100995:	a1 60 de 10 80       	mov    0x8010de60,%eax
8010099a:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801009a0:	83 ea 01             	sub    $0x1,%edx
801009a3:	83 e2 7f             	and    $0x7f,%edx
801009a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801009aa:	89 14 24             	mov    %edx,(%esp)
801009ad:	e8 c9 fe ff ff       	call   8010087b <shiftLeftBuf>
	    int i = input.e+input.a-1;
801009b2:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801009b8:	a1 60 de 10 80       	mov    0x8010de60,%eax
801009bd:	01 d0                	add    %edx,%eax
801009bf:	83 e8 01             	sub    $0x1,%eax
801009c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    consputc(KEY_LF);
801009c5:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
801009cc:	e8 0a fe ff ff       	call   801007db <consputc>
	    for(;i<input.e;i++){
801009d1:	eb 1b                	jmp    801009ee <consoleintr+0x120>
	      consputc(input.buf[i]);
801009d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801009d6:	05 d0 dd 10 80       	add    $0x8010ddd0,%eax
801009db:	0f b6 40 04          	movzbl 0x4(%eax),%eax
801009df:	0f be c0             	movsbl %al,%eax
801009e2:	89 04 24             	mov    %eax,(%esp)
801009e5:	e8 f1 fd ff ff       	call   801007db <consputc>
	if(input.a<0)
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
	    int i = input.e+input.a-1;
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
801009ea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801009ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801009f1:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801009f6:	39 c2                	cmp    %eax,%edx
801009f8:	72 d9                	jb     801009d3 <consoleintr+0x105>
	      consputc(input.buf[i]);
	    }
	    i = input.e+input.a;
801009fa:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a00:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a05:	01 d0                	add    %edx,%eax
80100a07:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    for(;i<input.e+1;i++){
80100a0a:	eb 10                	jmp    80100a1c <consoleintr+0x14e>
	      consputc(KEY_LF);
80100a0c:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a13:	e8 c3 fd ff ff       	call   801007db <consputc>
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
	      consputc(input.buf[i]);
	    }
	    i = input.e+input.a;
	    for(;i<input.e+1;i++){
80100a18:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a1f:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a25:	83 c2 01             	add    $0x1,%edx
80100a28:	39 d0                	cmp    %edx,%eax
80100a2a:	72 e0                	jb     80100a0c <consoleintr+0x13e>
80100a2c:	eb 0c                	jmp    80100a3a <consoleintr+0x16c>
	      consputc(KEY_LF);
	    }
	}
	else
	{
	  consputc(BACKSPACE);
80100a2e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100a35:	e8 a1 fd ff ff       	call   801007db <consputc>
	}
	input.e--;
80100a3a:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a3f:	83 e8 01             	sub    $0x1,%eax
80100a42:	a3 5c de 10 80       	mov    %eax,0x8010de5c
      }
      break;
80100a47:	e9 18 02 00 00       	jmp    80100c64 <consoleintr+0x396>
    case KEY_LF: //LEFT KEY
     if(input.e % INPUT_BUF > 0 && input.e+input.a>0)
80100a4c:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a51:	83 e0 7f             	and    $0x7f,%eax
80100a54:	85 c0                	test   %eax,%eax
80100a56:	0f 84 0b 02 00 00    	je     80100c67 <consoleintr+0x399>
80100a5c:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a62:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a67:	01 d0                	add    %edx,%eax
80100a69:	85 c0                	test   %eax,%eax
80100a6b:	0f 84 f6 01 00 00    	je     80100c67 <consoleintr+0x399>
      {
        input.a--;
80100a71:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a76:	83 e8 01             	sub    $0x1,%eax
80100a79:	a3 60 de 10 80       	mov    %eax,0x8010de60
        consputc(KEY_LF);
80100a7e:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a85:	e8 51 fd ff ff       	call   801007db <consputc>
      }
      break;
80100a8a:	e9 d8 01 00 00       	jmp    80100c67 <consoleintr+0x399>
    case KEY_RT: //RIGHT KEY
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
80100a8f:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a94:	85 c0                	test   %eax,%eax
80100a96:	0f 89 ce 01 00 00    	jns    80100c6a <consoleintr+0x39c>
80100a9c:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100aa1:	83 e0 7f             	and    $0x7f,%eax
80100aa4:	83 f8 7e             	cmp    $0x7e,%eax
80100aa7:	0f 87 bd 01 00 00    	ja     80100c6a <consoleintr+0x39c>
      {
        input.a++;
80100aad:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100ab2:	83 c0 01             	add    $0x1,%eax
80100ab5:	a3 60 de 10 80       	mov    %eax,0x8010de60
        consputc(KEY_RT);
80100aba:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100ac1:	e8 15 fd ff ff       	call   801007db <consputc>
      }
      break;
80100ac6:	e9 9f 01 00 00       	jmp    80100c6a <consoleintr+0x39c>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
80100acb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100acf:	0f 84 98 01 00 00    	je     80100c6d <consoleintr+0x39f>
80100ad5:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100adb:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100ae0:	89 d1                	mov    %edx,%ecx
80100ae2:	29 c1                	sub    %eax,%ecx
80100ae4:	89 c8                	mov    %ecx,%eax
80100ae6:	83 f8 7f             	cmp    $0x7f,%eax
80100ae9:	0f 87 7e 01 00 00    	ja     80100c6d <consoleintr+0x39f>
      {
	c = (c == '\r') ? '\n' : c;
80100aef:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
80100af3:	74 05                	je     80100afa <consoleintr+0x22c>
80100af5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100af8:	eb 05                	jmp    80100aff <consoleintr+0x231>
80100afa:	b8 0a 00 00 00       	mov    $0xa,%eax
80100aff:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(c != '\n' && input.a < 0)
80100b02:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100b06:	0f 84 ef 00 00 00    	je     80100bfb <consoleintr+0x32d>
80100b0c:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100b11:	85 c0                	test   %eax,%eax
80100b13:	0f 89 e2 00 00 00    	jns    80100bfb <consoleintr+0x32d>
	{
	    int j = (INPUT_BUF-(input.e-input.w));
80100b19:	8b 15 58 de 10 80    	mov    0x8010de58,%edx
80100b1f:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b24:	89 d1                	mov    %edx,%ecx
80100b26:	29 c1                	sub    %eax,%ecx
80100b28:	89 c8                	mov    %ecx,%eax
80100b2a:	83 e8 80             	sub    $0xffffff80,%eax
80100b2d:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    int k = ((-1)*input.a > j) ? j : (-1)*input.a;
80100b30:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100b35:	89 c2                	mov    %eax,%edx
80100b37:	f7 da                	neg    %edx
80100b39:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b3c:	39 c2                	cmp    %eax,%edx
80100b3e:	0f 4e c2             	cmovle %edx,%eax
80100b41:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	    shiftRightBuf((input.e-1) % INPUT_BUF,k);
80100b44:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b49:	83 e8 01             	sub    $0x1,%eax
80100b4c:	89 c2                	mov    %eax,%edx
80100b4e:	83 e2 7f             	and    $0x7f,%edx
80100b51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b58:	89 14 24             	mov    %edx,(%esp)
80100b5b:	e8 d8 fc ff ff       	call   80100838 <shiftRightBuf>
	    input.buf[(input.e-k) % INPUT_BUF] = c;
80100b60:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100b66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b69:	89 d1                	mov    %edx,%ecx
80100b6b:	29 c1                	sub    %eax,%ecx
80100b6d:	89 c8                	mov    %ecx,%eax
80100b6f:	89 c2                	mov    %eax,%edx
80100b71:	83 e2 7f             	and    $0x7f,%edx
80100b74:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100b77:	88 82 d4 dd 10 80    	mov    %al,-0x7fef222c(%edx)
	    int i = input.e-k;
80100b7d:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100b83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b86:	89 d1                	mov    %edx,%ecx
80100b88:	29 c1                	sub    %eax,%ecx
80100b8a:	89 c8                	mov    %ecx,%eax
80100b8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    
	    for(;i<input.e+1;i++){
80100b8f:	eb 1b                	jmp    80100bac <consoleintr+0x2de>
	      consputc(input.buf[i]);
80100b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b94:	05 d0 dd 10 80       	add    $0x8010ddd0,%eax
80100b99:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80100b9d:	0f be c0             	movsbl %al,%eax
80100ba0:	89 04 24             	mov    %eax,(%esp)
80100ba3:	e8 33 fc ff ff       	call   801007db <consputc>
	    int k = ((-1)*input.a > j) ? j : (-1)*input.a;
	    shiftRightBuf((input.e-1) % INPUT_BUF,k);
	    input.buf[(input.e-k) % INPUT_BUF] = c;
	    int i = input.e-k;
	    
	    for(;i<input.e+1;i++){
80100ba8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100baf:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100bb5:	83 c2 01             	add    $0x1,%edx
80100bb8:	39 d0                	cmp    %edx,%eax
80100bba:	72 d5                	jb     80100b91 <consoleintr+0x2c3>
	      consputc(input.buf[i]);
	    }
	    i = input.e-k;
80100bbc:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100bc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100bc5:	89 d1                	mov    %edx,%ecx
80100bc7:	29 c1                	sub    %eax,%ecx
80100bc9:	89 c8                	mov    %ecx,%eax
80100bcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e;i++){
80100bce:	eb 10                	jmp    80100be0 <consoleintr+0x312>
	      consputc(KEY_LF);
80100bd0:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100bd7:	e8 ff fb ff ff       	call   801007db <consputc>
	    
	    for(;i<input.e+1;i++){
	      consputc(input.buf[i]);
	    }
	    i = input.e-k;
	    for(;i<input.e;i++){
80100bdc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100be0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100be3:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100be8:	39 c2                	cmp    %eax,%edx
80100bea:	72 e4                	jb     80100bd0 <consoleintr+0x302>
	      consputc(KEY_LF);
	    }
	    input.e++;
80100bec:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bf1:	83 c0 01             	add    $0x1,%eax
80100bf4:	a3 5c de 10 80       	mov    %eax,0x8010de5c
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
      {
	c = (c == '\r') ? '\n' : c;
	if(c != '\n' && input.a < 0)
	{
80100bf9:	eb 26                	jmp    80100c21 <consoleintr+0x353>
	      consputc(KEY_LF);
	    }
	    input.e++;
	}
	else {
	  input.buf[input.e++ % INPUT_BUF] = c;
80100bfb:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100c00:	89 c1                	mov    %eax,%ecx
80100c02:	83 e1 7f             	and    $0x7f,%ecx
80100c05:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100c08:	88 91 d4 dd 10 80    	mov    %dl,-0x7fef222c(%ecx)
80100c0e:	83 c0 01             	add    $0x1,%eax
80100c11:	a3 5c de 10 80       	mov    %eax,0x8010de5c
          consputc(c);
80100c16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100c19:	89 04 24             	mov    %eax,(%esp)
80100c1c:	e8 ba fb ff ff       	call   801007db <consputc>
	}
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100c21:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100c25:	74 18                	je     80100c3f <consoleintr+0x371>
80100c27:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100c2b:	74 12                	je     80100c3f <consoleintr+0x371>
80100c2d:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100c32:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100c38:	83 ea 80             	sub    $0xffffff80,%edx
80100c3b:	39 d0                	cmp    %edx,%eax
80100c3d:	75 2e                	jne    80100c6d <consoleintr+0x39f>
          input.a = 0;
80100c3f:	c7 05 60 de 10 80 00 	movl   $0x0,0x8010de60
80100c46:	00 00 00 
	  input.w = input.e;
80100c49:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100c4e:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
80100c53:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100c5a:	e8 57 42 00 00       	call   80104eb6 <wakeup>
        }
      }
      break;
80100c5f:	eb 0c                	jmp    80100c6d <consoleintr+0x39f>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100c61:	90                   	nop
80100c62:	eb 0a                	jmp    80100c6e <consoleintr+0x3a0>
	{
	  consputc(BACKSPACE);
	}
	input.e--;
      }
      break;
80100c64:	90                   	nop
80100c65:	eb 07                	jmp    80100c6e <consoleintr+0x3a0>
     if(input.e % INPUT_BUF > 0 && input.e+input.a>0)
      {
        input.a--;
        consputc(KEY_LF);
      }
      break;
80100c67:	90                   	nop
80100c68:	eb 04                	jmp    80100c6e <consoleintr+0x3a0>
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
      {
        input.a++;
        consputc(KEY_RT);
      }
      break;
80100c6a:	90                   	nop
80100c6b:	eb 01                	jmp    80100c6e <consoleintr+0x3a0>
          input.a = 0;
	  input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
80100c6d:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80100c71:	ff d0                	call   *%eax
80100c73:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100c76:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100c7a:	0f 89 65 fc ff ff    	jns    801008e5 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100c80:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c87:	e8 95 44 00 00       	call   80105121 <release>
}
80100c8c:	c9                   	leave  
80100c8d:	c3                   	ret    

80100c8e <consoleread>:


int
consoleread(struct inode *ip, char *dst, int n)
{
80100c8e:	55                   	push   %ebp
80100c8f:	89 e5                	mov    %esp,%ebp
80100c91:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100c94:	8b 45 08             	mov    0x8(%ebp),%eax
80100c97:	89 04 24             	mov    %eax,(%esp)
80100c9a:	e8 7f 10 00 00       	call   80101d1e <iunlock>
  target = n;
80100c9f:	8b 45 10             	mov    0x10(%ebp),%eax
80100ca2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100ca5:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100cac:	e8 0e 44 00 00       	call   801050bf <acquire>
  while(n > 0){
80100cb1:	e9 a8 00 00 00       	jmp    80100d5e <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
80100cb6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100cbc:	8b 40 24             	mov    0x24(%eax),%eax
80100cbf:	85 c0                	test   %eax,%eax
80100cc1:	74 21                	je     80100ce4 <consoleread+0x56>
        release(&input.lock);
80100cc3:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100cca:	e8 52 44 00 00       	call   80105121 <release>
        ilock(ip);
80100ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80100cd2:	89 04 24             	mov    %eax,(%esp)
80100cd5:	e8 f6 0e 00 00       	call   80101bd0 <ilock>
        return -1;
80100cda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100cdf:	e9 a9 00 00 00       	jmp    80100d8d <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
80100ce4:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
80100ceb:	80 
80100cec:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100cf3:	e8 e2 40 00 00       	call   80104dda <sleep>
80100cf8:	eb 01                	jmp    80100cfb <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100cfa:	90                   	nop
80100cfb:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100d01:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100d06:	39 c2                	cmp    %eax,%edx
80100d08:	74 ac                	je     80100cb6 <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100d0a:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100d0f:	89 c2                	mov    %eax,%edx
80100d11:	83 e2 7f             	and    $0x7f,%edx
80100d14:	0f b6 92 d4 dd 10 80 	movzbl -0x7fef222c(%edx),%edx
80100d1b:	0f be d2             	movsbl %dl,%edx
80100d1e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100d21:	83 c0 01             	add    $0x1,%eax
80100d24:	a3 54 de 10 80       	mov    %eax,0x8010de54
    if(c == C('D')){  // EOF
80100d29:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100d2d:	75 17                	jne    80100d46 <consoleread+0xb8>
      if(n < target){
80100d2f:	8b 45 10             	mov    0x10(%ebp),%eax
80100d32:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100d35:	73 2f                	jae    80100d66 <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100d37:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100d3c:	83 e8 01             	sub    $0x1,%eax
80100d3f:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
80100d44:	eb 20                	jmp    80100d66 <consoleread+0xd8>
    }
    *dst++ = c;
80100d46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100d49:	89 c2                	mov    %eax,%edx
80100d4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d4e:	88 10                	mov    %dl,(%eax)
80100d50:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
80100d54:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100d58:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100d5c:	74 0b                	je     80100d69 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100d5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100d62:	7f 96                	jg     80100cfa <consoleread+0x6c>
80100d64:	eb 04                	jmp    80100d6a <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100d66:	90                   	nop
80100d67:	eb 01                	jmp    80100d6a <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100d69:	90                   	nop
  }
  release(&input.lock);
80100d6a:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100d71:	e8 ab 43 00 00       	call   80105121 <release>
  ilock(ip);
80100d76:	8b 45 08             	mov    0x8(%ebp),%eax
80100d79:	89 04 24             	mov    %eax,(%esp)
80100d7c:	e8 4f 0e 00 00       	call   80101bd0 <ilock>

  return target - n;
80100d81:	8b 45 10             	mov    0x10(%ebp),%eax
80100d84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d87:	89 d1                	mov    %edx,%ecx
80100d89:	29 c1                	sub    %eax,%ecx
80100d8b:	89 c8                	mov    %ecx,%eax
}
80100d8d:	c9                   	leave  
80100d8e:	c3                   	ret    

80100d8f <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100d8f:	55                   	push   %ebp
80100d90:	89 e5                	mov    %esp,%ebp
80100d92:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100d95:	8b 45 08             	mov    0x8(%ebp),%eax
80100d98:	89 04 24             	mov    %eax,(%esp)
80100d9b:	e8 7e 0f 00 00       	call   80101d1e <iunlock>
  acquire(&cons.lock);
80100da0:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100da7:	e8 13 43 00 00       	call   801050bf <acquire>
  for(i = 0; i < n; i++)
80100dac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100db3:	eb 1d                	jmp    80100dd2 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100db8:	03 45 0c             	add    0xc(%ebp),%eax
80100dbb:	0f b6 00             	movzbl (%eax),%eax
80100dbe:	0f be c0             	movsbl %al,%eax
80100dc1:	25 ff 00 00 00       	and    $0xff,%eax
80100dc6:	89 04 24             	mov    %eax,(%esp)
80100dc9:	e8 0d fa ff ff       	call   801007db <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100dce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100dd5:	3b 45 10             	cmp    0x10(%ebp),%eax
80100dd8:	7c db                	jl     80100db5 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100dda:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100de1:	e8 3b 43 00 00       	call   80105121 <release>
  ilock(ip);
80100de6:	8b 45 08             	mov    0x8(%ebp),%eax
80100de9:	89 04 24             	mov    %eax,(%esp)
80100dec:	e8 df 0d 00 00       	call   80101bd0 <ilock>

  return n;
80100df1:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100df4:	c9                   	leave  
80100df5:	c3                   	ret    

80100df6 <consoleinit>:

void
consoleinit(void)
{
80100df6:	55                   	push   %ebp
80100df7:	89 e5                	mov    %esp,%ebp
80100df9:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100dfc:	c7 44 24 04 83 87 10 	movl   $0x80108783,0x4(%esp)
80100e03:	80 
80100e04:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100e0b:	e8 8e 42 00 00       	call   8010509e <initlock>
  initlock(&input.lock, "input");
80100e10:	c7 44 24 04 8b 87 10 	movl   $0x8010878b,0x4(%esp)
80100e17:	80 
80100e18:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100e1f:	e8 7a 42 00 00       	call   8010509e <initlock>

  devsw[CONSOLE].write = consolewrite;
80100e24:	c7 05 2c e8 10 80 8f 	movl   $0x80100d8f,0x8010e82c
80100e2b:	0d 10 80 
  devsw[CONSOLE].read = consoleread;
80100e2e:	c7 05 28 e8 10 80 8e 	movl   $0x80100c8e,0x8010e828
80100e35:	0c 10 80 
  cons.locking = 1;
80100e38:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100e3f:	00 00 00 

  picenable(IRQ_KBD);
80100e42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e49:	e8 db 2f 00 00       	call   80103e29 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100e4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100e55:	00 
80100e56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e5d:	e8 7c 1e 00 00       	call   80102cde <ioapicenable>
}
80100e62:	c9                   	leave  
80100e63:	c3                   	ret    

80100e64 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100e64:	55                   	push   %ebp
80100e65:	89 e5                	mov    %esp,%ebp
80100e67:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100e6d:	8b 45 08             	mov    0x8(%ebp),%eax
80100e70:	89 04 24             	mov    %eax,(%esp)
80100e73:	e8 fa 18 00 00       	call   80102772 <namei>
80100e78:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100e7b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100e7f:	75 0a                	jne    80100e8b <exec+0x27>
    return -1;
80100e81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e86:	e9 da 03 00 00       	jmp    80101265 <exec+0x401>
  ilock(ip);
80100e8b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e8e:	89 04 24             	mov    %eax,(%esp)
80100e91:	e8 3a 0d 00 00       	call   80101bd0 <ilock>
  pgdir = 0;
80100e96:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100e9d:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100ea4:	00 
80100ea5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100eac:	00 
80100ead:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
80100eb7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100eba:	89 04 24             	mov    %eax,(%esp)
80100ebd:	e8 04 12 00 00       	call   801020c6 <readi>
80100ec2:	83 f8 33             	cmp    $0x33,%eax
80100ec5:	0f 86 54 03 00 00    	jbe    8010121f <exec+0x3bb>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100ecb:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100ed1:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100ed6:	0f 85 46 03 00 00    	jne    80101222 <exec+0x3be>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100edc:	c7 04 24 67 2e 10 80 	movl   $0x80102e67,(%esp)
80100ee3:	e8 f9 6f 00 00       	call   80107ee1 <setupkvm>
80100ee8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100eeb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100eef:	0f 84 30 03 00 00    	je     80101225 <exec+0x3c1>
    goto bad;

  // Load program into memory.
  sz = 0;
80100ef5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100efc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100f03:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100f09:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100f0c:	e9 c5 00 00 00       	jmp    80100fd6 <exec+0x172>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100f11:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100f14:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100f1b:	00 
80100f1c:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f20:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100f26:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f2d:	89 04 24             	mov    %eax,(%esp)
80100f30:	e8 91 11 00 00       	call   801020c6 <readi>
80100f35:	83 f8 20             	cmp    $0x20,%eax
80100f38:	0f 85 ea 02 00 00    	jne    80101228 <exec+0x3c4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100f3e:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100f44:	83 f8 01             	cmp    $0x1,%eax
80100f47:	75 7f                	jne    80100fc8 <exec+0x164>
      continue;
    if(ph.memsz < ph.filesz)
80100f49:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100f4f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100f55:	39 c2                	cmp    %eax,%edx
80100f57:	0f 82 ce 02 00 00    	jb     8010122b <exec+0x3c7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100f5d:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100f63:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100f69:	01 d0                	add    %edx,%eax
80100f6b:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f72:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f76:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f79:	89 04 24             	mov    %eax,(%esp)
80100f7c:	e8 32 73 00 00       	call   801082b3 <allocuvm>
80100f81:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f84:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f88:	0f 84 a0 02 00 00    	je     8010122e <exec+0x3ca>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100f8e:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100f94:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100f9a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100fa0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100fa4:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100fa8:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100fab:	89 54 24 08          	mov    %edx,0x8(%esp)
80100faf:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fb3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fb6:	89 04 24             	mov    %eax,(%esp)
80100fb9:	e8 06 72 00 00       	call   801081c4 <loaduvm>
80100fbe:	85 c0                	test   %eax,%eax
80100fc0:	0f 88 6b 02 00 00    	js     80101231 <exec+0x3cd>
80100fc6:	eb 01                	jmp    80100fc9 <exec+0x165>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100fc8:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100fc9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100fcd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100fd0:	83 c0 20             	add    $0x20,%eax
80100fd3:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100fd6:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100fdd:	0f b7 c0             	movzwl %ax,%eax
80100fe0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100fe3:	0f 8f 28 ff ff ff    	jg     80100f11 <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100fe9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100fec:	89 04 24             	mov    %eax,(%esp)
80100fef:	e8 60 0e 00 00       	call   80101e54 <iunlockput>
  ip = 0;
80100ff4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100ffb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ffe:	05 ff 0f 00 00       	add    $0xfff,%eax
80101003:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80101008:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
8010100b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010100e:	05 00 20 00 00       	add    $0x2000,%eax
80101013:	89 44 24 08          	mov    %eax,0x8(%esp)
80101017:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010101a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010101e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101021:	89 04 24             	mov    %eax,(%esp)
80101024:	e8 8a 72 00 00       	call   801082b3 <allocuvm>
80101029:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010102c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101030:	0f 84 fe 01 00 00    	je     80101234 <exec+0x3d0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80101036:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101039:	2d 00 20 00 00       	sub    $0x2000,%eax
8010103e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101042:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101045:	89 04 24             	mov    %eax,(%esp)
80101048:	e8 8a 74 00 00       	call   801084d7 <clearpteu>
  sp = sz;
8010104d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101050:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80101053:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010105a:	e9 81 00 00 00       	jmp    801010e0 <exec+0x27c>
    if(argc >= MAXARG)
8010105f:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80101063:	0f 87 ce 01 00 00    	ja     80101237 <exec+0x3d3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101069:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010106c:	c1 e0 02             	shl    $0x2,%eax
8010106f:	03 45 0c             	add    0xc(%ebp),%eax
80101072:	8b 00                	mov    (%eax),%eax
80101074:	89 04 24             	mov    %eax,(%esp)
80101077:	e8 10 45 00 00       	call   8010558c <strlen>
8010107c:	f7 d0                	not    %eax
8010107e:	03 45 dc             	add    -0x24(%ebp),%eax
80101081:	83 e0 fc             	and    $0xfffffffc,%eax
80101084:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80101087:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010108a:	c1 e0 02             	shl    $0x2,%eax
8010108d:	03 45 0c             	add    0xc(%ebp),%eax
80101090:	8b 00                	mov    (%eax),%eax
80101092:	89 04 24             	mov    %eax,(%esp)
80101095:	e8 f2 44 00 00       	call   8010558c <strlen>
8010109a:	83 c0 01             	add    $0x1,%eax
8010109d:	89 c2                	mov    %eax,%edx
8010109f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010a2:	c1 e0 02             	shl    $0x2,%eax
801010a5:	03 45 0c             	add    0xc(%ebp),%eax
801010a8:	8b 00                	mov    (%eax),%eax
801010aa:	89 54 24 0c          	mov    %edx,0xc(%esp)
801010ae:	89 44 24 08          	mov    %eax,0x8(%esp)
801010b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801010b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801010bc:	89 04 24             	mov    %eax,(%esp)
801010bf:	e8 c7 75 00 00       	call   8010868b <copyout>
801010c4:	85 c0                	test   %eax,%eax
801010c6:	0f 88 6e 01 00 00    	js     8010123a <exec+0x3d6>
      goto bad;
    ustack[3+argc] = sp;
801010cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010cf:	8d 50 03             	lea    0x3(%eax),%edx
801010d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010d5:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
801010dc:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801010e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010e3:	c1 e0 02             	shl    $0x2,%eax
801010e6:	03 45 0c             	add    0xc(%ebp),%eax
801010e9:	8b 00                	mov    (%eax),%eax
801010eb:	85 c0                	test   %eax,%eax
801010ed:	0f 85 6c ff ff ff    	jne    8010105f <exec+0x1fb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
801010f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010f6:	83 c0 03             	add    $0x3,%eax
801010f9:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80101100:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80101104:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
8010110b:	ff ff ff 
  ustack[1] = argc;
8010110e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101111:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80101117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010111a:	83 c0 01             	add    $0x1,%eax
8010111d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101124:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101127:	29 d0                	sub    %edx,%eax
80101129:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
8010112f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101132:	83 c0 04             	add    $0x4,%eax
80101135:	c1 e0 02             	shl    $0x2,%eax
80101138:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
8010113b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010113e:	83 c0 04             	add    $0x4,%eax
80101141:	c1 e0 02             	shl    $0x2,%eax
80101144:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101148:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
8010114e:	89 44 24 08          	mov    %eax,0x8(%esp)
80101152:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101155:	89 44 24 04          	mov    %eax,0x4(%esp)
80101159:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010115c:	89 04 24             	mov    %eax,(%esp)
8010115f:	e8 27 75 00 00       	call   8010868b <copyout>
80101164:	85 c0                	test   %eax,%eax
80101166:	0f 88 d1 00 00 00    	js     8010123d <exec+0x3d9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010116c:	8b 45 08             	mov    0x8(%ebp),%eax
8010116f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101172:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101175:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101178:	eb 17                	jmp    80101191 <exec+0x32d>
    if(*s == '/')
8010117a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010117d:	0f b6 00             	movzbl (%eax),%eax
80101180:	3c 2f                	cmp    $0x2f,%al
80101182:	75 09                	jne    8010118d <exec+0x329>
      last = s+1;
80101184:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101187:	83 c0 01             	add    $0x1,%eax
8010118a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010118d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101194:	0f b6 00             	movzbl (%eax),%eax
80101197:	84 c0                	test   %al,%al
80101199:	75 df                	jne    8010117a <exec+0x316>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
8010119b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011a1:	8d 50 6c             	lea    0x6c(%eax),%edx
801011a4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801011ab:	00 
801011ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011af:	89 44 24 04          	mov    %eax,0x4(%esp)
801011b3:	89 14 24             	mov    %edx,(%esp)
801011b6:	e8 83 43 00 00       	call   8010553e <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
801011bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011c1:	8b 40 04             	mov    0x4(%eax),%eax
801011c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
801011c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011cd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801011d0:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
801011d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011d9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801011dc:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
801011de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011e4:	8b 40 18             	mov    0x18(%eax),%eax
801011e7:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
801011ed:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801011f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011f6:	8b 40 18             	mov    0x18(%eax),%eax
801011f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
801011fc:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
801011ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101205:	89 04 24             	mov    %eax,(%esp)
80101208:	e8 c5 6d 00 00       	call   80107fd2 <switchuvm>
  freevm(oldpgdir);
8010120d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101210:	89 04 24             	mov    %eax,(%esp)
80101213:	e8 31 72 00 00       	call   80108449 <freevm>
  return 0;
80101218:	b8 00 00 00 00       	mov    $0x0,%eax
8010121d:	eb 46                	jmp    80101265 <exec+0x401>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
8010121f:	90                   	nop
80101220:	eb 1c                	jmp    8010123e <exec+0x3da>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80101222:	90                   	nop
80101223:	eb 19                	jmp    8010123e <exec+0x3da>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
80101225:	90                   	nop
80101226:	eb 16                	jmp    8010123e <exec+0x3da>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101228:	90                   	nop
80101229:	eb 13                	jmp    8010123e <exec+0x3da>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
8010122b:	90                   	nop
8010122c:	eb 10                	jmp    8010123e <exec+0x3da>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
8010122e:	90                   	nop
8010122f:	eb 0d                	jmp    8010123e <exec+0x3da>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80101231:	90                   	nop
80101232:	eb 0a                	jmp    8010123e <exec+0x3da>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80101234:	90                   	nop
80101235:	eb 07                	jmp    8010123e <exec+0x3da>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80101237:	90                   	nop
80101238:	eb 04                	jmp    8010123e <exec+0x3da>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
8010123a:	90                   	nop
8010123b:	eb 01                	jmp    8010123e <exec+0x3da>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
8010123d:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
8010123e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101242:	74 0b                	je     8010124f <exec+0x3eb>
    freevm(pgdir);
80101244:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101247:	89 04 24             	mov    %eax,(%esp)
8010124a:	e8 fa 71 00 00       	call   80108449 <freevm>
  if(ip)
8010124f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101253:	74 0b                	je     80101260 <exec+0x3fc>
    iunlockput(ip);
80101255:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101258:	89 04 24             	mov    %eax,(%esp)
8010125b:	e8 f4 0b 00 00       	call   80101e54 <iunlockput>
  return -1;
80101260:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101265:	c9                   	leave  
80101266:	c3                   	ret    
	...

80101268 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101268:	55                   	push   %ebp
80101269:	89 e5                	mov    %esp,%ebp
8010126b:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
8010126e:	c7 44 24 04 91 87 10 	movl   $0x80108791,0x4(%esp)
80101275:	80 
80101276:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010127d:	e8 1c 3e 00 00       	call   8010509e <initlock>
}
80101282:	c9                   	leave  
80101283:	c3                   	ret    

80101284 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101284:	55                   	push   %ebp
80101285:	89 e5                	mov    %esp,%ebp
80101287:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
8010128a:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101291:	e8 29 3e 00 00       	call   801050bf <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101296:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
8010129d:	eb 29                	jmp    801012c8 <filealloc+0x44>
    if(f->ref == 0){
8010129f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012a2:	8b 40 04             	mov    0x4(%eax),%eax
801012a5:	85 c0                	test   %eax,%eax
801012a7:	75 1b                	jne    801012c4 <filealloc+0x40>
      f->ref = 1;
801012a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ac:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
801012b3:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012ba:	e8 62 3e 00 00       	call   80105121 <release>
      return f;
801012bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c2:	eb 1e                	jmp    801012e2 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801012c4:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801012c8:	81 7d f4 14 e8 10 80 	cmpl   $0x8010e814,-0xc(%ebp)
801012cf:	72 ce                	jb     8010129f <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801012d1:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012d8:	e8 44 3e 00 00       	call   80105121 <release>
  return 0;
801012dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801012e2:	c9                   	leave  
801012e3:	c3                   	ret    

801012e4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801012e4:	55                   	push   %ebp
801012e5:	89 e5                	mov    %esp,%ebp
801012e7:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
801012ea:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012f1:	e8 c9 3d 00 00       	call   801050bf <acquire>
  if(f->ref < 1)
801012f6:	8b 45 08             	mov    0x8(%ebp),%eax
801012f9:	8b 40 04             	mov    0x4(%eax),%eax
801012fc:	85 c0                	test   %eax,%eax
801012fe:	7f 0c                	jg     8010130c <filedup+0x28>
    panic("filedup");
80101300:	c7 04 24 98 87 10 80 	movl   $0x80108798,(%esp)
80101307:	e8 31 f2 ff ff       	call   8010053d <panic>
  f->ref++;
8010130c:	8b 45 08             	mov    0x8(%ebp),%eax
8010130f:	8b 40 04             	mov    0x4(%eax),%eax
80101312:	8d 50 01             	lea    0x1(%eax),%edx
80101315:	8b 45 08             	mov    0x8(%ebp),%eax
80101318:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010131b:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101322:	e8 fa 3d 00 00       	call   80105121 <release>
  return f;
80101327:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010132a:	c9                   	leave  
8010132b:	c3                   	ret    

8010132c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010132c:	55                   	push   %ebp
8010132d:	89 e5                	mov    %esp,%ebp
8010132f:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80101332:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101339:	e8 81 3d 00 00       	call   801050bf <acquire>
  if(f->ref < 1)
8010133e:	8b 45 08             	mov    0x8(%ebp),%eax
80101341:	8b 40 04             	mov    0x4(%eax),%eax
80101344:	85 c0                	test   %eax,%eax
80101346:	7f 0c                	jg     80101354 <fileclose+0x28>
    panic("fileclose");
80101348:	c7 04 24 a0 87 10 80 	movl   $0x801087a0,(%esp)
8010134f:	e8 e9 f1 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80101354:	8b 45 08             	mov    0x8(%ebp),%eax
80101357:	8b 40 04             	mov    0x4(%eax),%eax
8010135a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010135d:	8b 45 08             	mov    0x8(%ebp),%eax
80101360:	89 50 04             	mov    %edx,0x4(%eax)
80101363:	8b 45 08             	mov    0x8(%ebp),%eax
80101366:	8b 40 04             	mov    0x4(%eax),%eax
80101369:	85 c0                	test   %eax,%eax
8010136b:	7e 11                	jle    8010137e <fileclose+0x52>
    release(&ftable.lock);
8010136d:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101374:	e8 a8 3d 00 00       	call   80105121 <release>
    return;
80101379:	e9 82 00 00 00       	jmp    80101400 <fileclose+0xd4>
  }
  ff = *f;
8010137e:	8b 45 08             	mov    0x8(%ebp),%eax
80101381:	8b 10                	mov    (%eax),%edx
80101383:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101386:	8b 50 04             	mov    0x4(%eax),%edx
80101389:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010138c:	8b 50 08             	mov    0x8(%eax),%edx
8010138f:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101392:	8b 50 0c             	mov    0xc(%eax),%edx
80101395:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101398:	8b 50 10             	mov    0x10(%eax),%edx
8010139b:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010139e:	8b 40 14             	mov    0x14(%eax),%eax
801013a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801013a4:	8b 45 08             	mov    0x8(%ebp),%eax
801013a7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801013ae:	8b 45 08             	mov    0x8(%ebp),%eax
801013b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801013b7:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801013be:	e8 5e 3d 00 00       	call   80105121 <release>
  
  if(ff.type == FD_PIPE)
801013c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013c6:	83 f8 01             	cmp    $0x1,%eax
801013c9:	75 18                	jne    801013e3 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
801013cb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801013cf:	0f be d0             	movsbl %al,%edx
801013d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801013d9:	89 04 24             	mov    %eax,(%esp)
801013dc:	e8 02 2d 00 00       	call   801040e3 <pipeclose>
801013e1:	eb 1d                	jmp    80101400 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801013e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013e6:	83 f8 02             	cmp    $0x2,%eax
801013e9:	75 15                	jne    80101400 <fileclose+0xd4>
    begin_trans();
801013eb:	e8 95 21 00 00       	call   80103585 <begin_trans>
    iput(ff.ip);
801013f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f3:	89 04 24             	mov    %eax,(%esp)
801013f6:	e8 88 09 00 00       	call   80101d83 <iput>
    commit_trans();
801013fb:	e8 ce 21 00 00       	call   801035ce <commit_trans>
  }
}
80101400:	c9                   	leave  
80101401:	c3                   	ret    

80101402 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101402:	55                   	push   %ebp
80101403:	89 e5                	mov    %esp,%ebp
80101405:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101408:	8b 45 08             	mov    0x8(%ebp),%eax
8010140b:	8b 00                	mov    (%eax),%eax
8010140d:	83 f8 02             	cmp    $0x2,%eax
80101410:	75 38                	jne    8010144a <filestat+0x48>
    ilock(f->ip);
80101412:	8b 45 08             	mov    0x8(%ebp),%eax
80101415:	8b 40 10             	mov    0x10(%eax),%eax
80101418:	89 04 24             	mov    %eax,(%esp)
8010141b:	e8 b0 07 00 00       	call   80101bd0 <ilock>
    stati(f->ip, st);
80101420:	8b 45 08             	mov    0x8(%ebp),%eax
80101423:	8b 40 10             	mov    0x10(%eax),%eax
80101426:	8b 55 0c             	mov    0xc(%ebp),%edx
80101429:	89 54 24 04          	mov    %edx,0x4(%esp)
8010142d:	89 04 24             	mov    %eax,(%esp)
80101430:	e8 4c 0c 00 00       	call   80102081 <stati>
    iunlock(f->ip);
80101435:	8b 45 08             	mov    0x8(%ebp),%eax
80101438:	8b 40 10             	mov    0x10(%eax),%eax
8010143b:	89 04 24             	mov    %eax,(%esp)
8010143e:	e8 db 08 00 00       	call   80101d1e <iunlock>
    return 0;
80101443:	b8 00 00 00 00       	mov    $0x0,%eax
80101448:	eb 05                	jmp    8010144f <filestat+0x4d>
  }
  return -1;
8010144a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010144f:	c9                   	leave  
80101450:	c3                   	ret    

80101451 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101451:	55                   	push   %ebp
80101452:	89 e5                	mov    %esp,%ebp
80101454:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101457:	8b 45 08             	mov    0x8(%ebp),%eax
8010145a:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010145e:	84 c0                	test   %al,%al
80101460:	75 0a                	jne    8010146c <fileread+0x1b>
    return -1;
80101462:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101467:	e9 9f 00 00 00       	jmp    8010150b <fileread+0xba>
  if(f->type == FD_PIPE)
8010146c:	8b 45 08             	mov    0x8(%ebp),%eax
8010146f:	8b 00                	mov    (%eax),%eax
80101471:	83 f8 01             	cmp    $0x1,%eax
80101474:	75 1e                	jne    80101494 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101476:	8b 45 08             	mov    0x8(%ebp),%eax
80101479:	8b 40 0c             	mov    0xc(%eax),%eax
8010147c:	8b 55 10             	mov    0x10(%ebp),%edx
8010147f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101483:	8b 55 0c             	mov    0xc(%ebp),%edx
80101486:	89 54 24 04          	mov    %edx,0x4(%esp)
8010148a:	89 04 24             	mov    %eax,(%esp)
8010148d:	e8 d3 2d 00 00       	call   80104265 <piperead>
80101492:	eb 77                	jmp    8010150b <fileread+0xba>
  if(f->type == FD_INODE){
80101494:	8b 45 08             	mov    0x8(%ebp),%eax
80101497:	8b 00                	mov    (%eax),%eax
80101499:	83 f8 02             	cmp    $0x2,%eax
8010149c:	75 61                	jne    801014ff <fileread+0xae>
    ilock(f->ip);
8010149e:	8b 45 08             	mov    0x8(%ebp),%eax
801014a1:	8b 40 10             	mov    0x10(%eax),%eax
801014a4:	89 04 24             	mov    %eax,(%esp)
801014a7:	e8 24 07 00 00       	call   80101bd0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801014ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
801014af:	8b 45 08             	mov    0x8(%ebp),%eax
801014b2:	8b 50 14             	mov    0x14(%eax),%edx
801014b5:	8b 45 08             	mov    0x8(%ebp),%eax
801014b8:	8b 40 10             	mov    0x10(%eax),%eax
801014bb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801014bf:	89 54 24 08          	mov    %edx,0x8(%esp)
801014c3:	8b 55 0c             	mov    0xc(%ebp),%edx
801014c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801014ca:	89 04 24             	mov    %eax,(%esp)
801014cd:	e8 f4 0b 00 00       	call   801020c6 <readi>
801014d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801014d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801014d9:	7e 11                	jle    801014ec <fileread+0x9b>
      f->off += r;
801014db:	8b 45 08             	mov    0x8(%ebp),%eax
801014de:	8b 50 14             	mov    0x14(%eax),%edx
801014e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014e4:	01 c2                	add    %eax,%edx
801014e6:	8b 45 08             	mov    0x8(%ebp),%eax
801014e9:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801014ec:	8b 45 08             	mov    0x8(%ebp),%eax
801014ef:	8b 40 10             	mov    0x10(%eax),%eax
801014f2:	89 04 24             	mov    %eax,(%esp)
801014f5:	e8 24 08 00 00       	call   80101d1e <iunlock>
    return r;
801014fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014fd:	eb 0c                	jmp    8010150b <fileread+0xba>
  }
  panic("fileread");
801014ff:	c7 04 24 aa 87 10 80 	movl   $0x801087aa,(%esp)
80101506:	e8 32 f0 ff ff       	call   8010053d <panic>
}
8010150b:	c9                   	leave  
8010150c:	c3                   	ret    

8010150d <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010150d:	55                   	push   %ebp
8010150e:	89 e5                	mov    %esp,%ebp
80101510:	53                   	push   %ebx
80101511:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101514:	8b 45 08             	mov    0x8(%ebp),%eax
80101517:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010151b:	84 c0                	test   %al,%al
8010151d:	75 0a                	jne    80101529 <filewrite+0x1c>
    return -1;
8010151f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101524:	e9 23 01 00 00       	jmp    8010164c <filewrite+0x13f>
  if(f->type == FD_PIPE)
80101529:	8b 45 08             	mov    0x8(%ebp),%eax
8010152c:	8b 00                	mov    (%eax),%eax
8010152e:	83 f8 01             	cmp    $0x1,%eax
80101531:	75 21                	jne    80101554 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101533:	8b 45 08             	mov    0x8(%ebp),%eax
80101536:	8b 40 0c             	mov    0xc(%eax),%eax
80101539:	8b 55 10             	mov    0x10(%ebp),%edx
8010153c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101540:	8b 55 0c             	mov    0xc(%ebp),%edx
80101543:	89 54 24 04          	mov    %edx,0x4(%esp)
80101547:	89 04 24             	mov    %eax,(%esp)
8010154a:	e8 26 2c 00 00       	call   80104175 <pipewrite>
8010154f:	e9 f8 00 00 00       	jmp    8010164c <filewrite+0x13f>
  if(f->type == FD_INODE){
80101554:	8b 45 08             	mov    0x8(%ebp),%eax
80101557:	8b 00                	mov    (%eax),%eax
80101559:	83 f8 02             	cmp    $0x2,%eax
8010155c:	0f 85 de 00 00 00    	jne    80101640 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101562:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101569:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101570:	e9 a8 00 00 00       	jmp    8010161d <filewrite+0x110>
      int n1 = n - i;
80101575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101578:	8b 55 10             	mov    0x10(%ebp),%edx
8010157b:	89 d1                	mov    %edx,%ecx
8010157d:	29 c1                	sub    %eax,%ecx
8010157f:	89 c8                	mov    %ecx,%eax
80101581:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101587:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010158a:	7e 06                	jle    80101592 <filewrite+0x85>
        n1 = max;
8010158c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010158f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
80101592:	e8 ee 1f 00 00       	call   80103585 <begin_trans>
      ilock(f->ip);
80101597:	8b 45 08             	mov    0x8(%ebp),%eax
8010159a:	8b 40 10             	mov    0x10(%eax),%eax
8010159d:	89 04 24             	mov    %eax,(%esp)
801015a0:	e8 2b 06 00 00       	call   80101bd0 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801015a5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
801015a8:	8b 45 08             	mov    0x8(%ebp),%eax
801015ab:	8b 48 14             	mov    0x14(%eax),%ecx
801015ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015b1:	89 c2                	mov    %eax,%edx
801015b3:	03 55 0c             	add    0xc(%ebp),%edx
801015b6:	8b 45 08             	mov    0x8(%ebp),%eax
801015b9:	8b 40 10             	mov    0x10(%eax),%eax
801015bc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801015c0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801015c4:	89 54 24 04          	mov    %edx,0x4(%esp)
801015c8:	89 04 24             	mov    %eax,(%esp)
801015cb:	e8 61 0c 00 00       	call   80102231 <writei>
801015d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
801015d3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801015d7:	7e 11                	jle    801015ea <filewrite+0xdd>
        f->off += r;
801015d9:	8b 45 08             	mov    0x8(%ebp),%eax
801015dc:	8b 50 14             	mov    0x14(%eax),%edx
801015df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015e2:	01 c2                	add    %eax,%edx
801015e4:	8b 45 08             	mov    0x8(%ebp),%eax
801015e7:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801015ea:	8b 45 08             	mov    0x8(%ebp),%eax
801015ed:	8b 40 10             	mov    0x10(%eax),%eax
801015f0:	89 04 24             	mov    %eax,(%esp)
801015f3:	e8 26 07 00 00       	call   80101d1e <iunlock>
      commit_trans();
801015f8:	e8 d1 1f 00 00       	call   801035ce <commit_trans>

      if(r < 0)
801015fd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101601:	78 28                	js     8010162b <filewrite+0x11e>
        break;
      if(r != n1)
80101603:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101606:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101609:	74 0c                	je     80101617 <filewrite+0x10a>
        panic("short filewrite");
8010160b:	c7 04 24 b3 87 10 80 	movl   $0x801087b3,(%esp)
80101612:	e8 26 ef ff ff       	call   8010053d <panic>
      i += r;
80101617:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010161a:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010161d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101620:	3b 45 10             	cmp    0x10(%ebp),%eax
80101623:	0f 8c 4c ff ff ff    	jl     80101575 <filewrite+0x68>
80101629:	eb 01                	jmp    8010162c <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
8010162b:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010162c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010162f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101632:	75 05                	jne    80101639 <filewrite+0x12c>
80101634:	8b 45 10             	mov    0x10(%ebp),%eax
80101637:	eb 05                	jmp    8010163e <filewrite+0x131>
80101639:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010163e:	eb 0c                	jmp    8010164c <filewrite+0x13f>
  }
  panic("filewrite");
80101640:	c7 04 24 c3 87 10 80 	movl   $0x801087c3,(%esp)
80101647:	e8 f1 ee ff ff       	call   8010053d <panic>
}
8010164c:	83 c4 24             	add    $0x24,%esp
8010164f:	5b                   	pop    %ebx
80101650:	5d                   	pop    %ebp
80101651:	c3                   	ret    
	...

80101654 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101654:	55                   	push   %ebp
80101655:	89 e5                	mov    %esp,%ebp
80101657:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010165a:	8b 45 08             	mov    0x8(%ebp),%eax
8010165d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101664:	00 
80101665:	89 04 24             	mov    %eax,(%esp)
80101668:	e8 39 eb ff ff       	call   801001a6 <bread>
8010166d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101673:	83 c0 18             	add    $0x18,%eax
80101676:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010167d:	00 
8010167e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101682:	8b 45 0c             	mov    0xc(%ebp),%eax
80101685:	89 04 24             	mov    %eax,(%esp)
80101688:	e8 54 3d 00 00       	call   801053e1 <memmove>
  brelse(bp);
8010168d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101690:	89 04 24             	mov    %eax,(%esp)
80101693:	e8 7f eb ff ff       	call   80100217 <brelse>
}
80101698:	c9                   	leave  
80101699:	c3                   	ret    

8010169a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010169a:	55                   	push   %ebp
8010169b:	89 e5                	mov    %esp,%ebp
8010169d:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801016a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801016a3:	8b 45 08             	mov    0x8(%ebp),%eax
801016a6:	89 54 24 04          	mov    %edx,0x4(%esp)
801016aa:	89 04 24             	mov    %eax,(%esp)
801016ad:	e8 f4 ea ff ff       	call   801001a6 <bread>
801016b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801016b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016b8:	83 c0 18             	add    $0x18,%eax
801016bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801016c2:	00 
801016c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801016ca:	00 
801016cb:	89 04 24             	mov    %eax,(%esp)
801016ce:	e8 3b 3c 00 00       	call   8010530e <memset>
  log_write(bp);
801016d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d6:	89 04 24             	mov    %eax,(%esp)
801016d9:	e8 48 1f 00 00       	call   80103626 <log_write>
  brelse(bp);
801016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e1:	89 04 24             	mov    %eax,(%esp)
801016e4:	e8 2e eb ff ff       	call   80100217 <brelse>
}
801016e9:	c9                   	leave  
801016ea:	c3                   	ret    

801016eb <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801016eb:	55                   	push   %ebp
801016ec:	89 e5                	mov    %esp,%ebp
801016ee:	53                   	push   %ebx
801016ef:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801016f2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801016f9:	8b 45 08             	mov    0x8(%ebp),%eax
801016fc:	8d 55 d8             	lea    -0x28(%ebp),%edx
801016ff:	89 54 24 04          	mov    %edx,0x4(%esp)
80101703:	89 04 24             	mov    %eax,(%esp)
80101706:	e8 49 ff ff ff       	call   80101654 <readsb>
  for(b = 0; b < sb.size; b += BPB){
8010170b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101712:	e9 11 01 00 00       	jmp    80101828 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010171a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101720:	85 c0                	test   %eax,%eax
80101722:	0f 48 c2             	cmovs  %edx,%eax
80101725:	c1 f8 0c             	sar    $0xc,%eax
80101728:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010172b:	c1 ea 03             	shr    $0x3,%edx
8010172e:	01 d0                	add    %edx,%eax
80101730:	83 c0 03             	add    $0x3,%eax
80101733:	89 44 24 04          	mov    %eax,0x4(%esp)
80101737:	8b 45 08             	mov    0x8(%ebp),%eax
8010173a:	89 04 24             	mov    %eax,(%esp)
8010173d:	e8 64 ea ff ff       	call   801001a6 <bread>
80101742:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101745:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010174c:	e9 a7 00 00 00       	jmp    801017f8 <balloc+0x10d>
      m = 1 << (bi % 8);
80101751:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101754:	89 c2                	mov    %eax,%edx
80101756:	c1 fa 1f             	sar    $0x1f,%edx
80101759:	c1 ea 1d             	shr    $0x1d,%edx
8010175c:	01 d0                	add    %edx,%eax
8010175e:	83 e0 07             	and    $0x7,%eax
80101761:	29 d0                	sub    %edx,%eax
80101763:	ba 01 00 00 00       	mov    $0x1,%edx
80101768:	89 d3                	mov    %edx,%ebx
8010176a:	89 c1                	mov    %eax,%ecx
8010176c:	d3 e3                	shl    %cl,%ebx
8010176e:	89 d8                	mov    %ebx,%eax
80101770:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101773:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101776:	8d 50 07             	lea    0x7(%eax),%edx
80101779:	85 c0                	test   %eax,%eax
8010177b:	0f 48 c2             	cmovs  %edx,%eax
8010177e:	c1 f8 03             	sar    $0x3,%eax
80101781:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101784:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101789:	0f b6 c0             	movzbl %al,%eax
8010178c:	23 45 e8             	and    -0x18(%ebp),%eax
8010178f:	85 c0                	test   %eax,%eax
80101791:	75 61                	jne    801017f4 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
80101793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101796:	8d 50 07             	lea    0x7(%eax),%edx
80101799:	85 c0                	test   %eax,%eax
8010179b:	0f 48 c2             	cmovs  %edx,%eax
8010179e:	c1 f8 03             	sar    $0x3,%eax
801017a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017a4:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801017a9:	89 d1                	mov    %edx,%ecx
801017ab:	8b 55 e8             	mov    -0x18(%ebp),%edx
801017ae:	09 ca                	or     %ecx,%edx
801017b0:	89 d1                	mov    %edx,%ecx
801017b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017b5:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801017b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017bc:	89 04 24             	mov    %eax,(%esp)
801017bf:	e8 62 1e 00 00       	call   80103626 <log_write>
        brelse(bp);
801017c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017c7:	89 04 24             	mov    %eax,(%esp)
801017ca:	e8 48 ea ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
801017cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017d5:	01 c2                	add    %eax,%edx
801017d7:	8b 45 08             	mov    0x8(%ebp),%eax
801017da:	89 54 24 04          	mov    %edx,0x4(%esp)
801017de:	89 04 24             	mov    %eax,(%esp)
801017e1:	e8 b4 fe ff ff       	call   8010169a <bzero>
        return b + bi;
801017e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017ec:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
801017ee:	83 c4 34             	add    $0x34,%esp
801017f1:	5b                   	pop    %ebx
801017f2:	5d                   	pop    %ebp
801017f3:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801017f4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801017f8:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801017ff:	7f 15                	jg     80101816 <balloc+0x12b>
80101801:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101804:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101807:	01 d0                	add    %edx,%eax
80101809:	89 c2                	mov    %eax,%edx
8010180b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010180e:	39 c2                	cmp    %eax,%edx
80101810:	0f 82 3b ff ff ff    	jb     80101751 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101816:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101819:	89 04 24             	mov    %eax,(%esp)
8010181c:	e8 f6 e9 ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101821:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101828:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010182b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010182e:	39 c2                	cmp    %eax,%edx
80101830:	0f 82 e1 fe ff ff    	jb     80101717 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101836:	c7 04 24 cd 87 10 80 	movl   $0x801087cd,(%esp)
8010183d:	e8 fb ec ff ff       	call   8010053d <panic>

80101842 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101842:	55                   	push   %ebp
80101843:	89 e5                	mov    %esp,%ebp
80101845:	53                   	push   %ebx
80101846:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101849:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010184c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101850:	8b 45 08             	mov    0x8(%ebp),%eax
80101853:	89 04 24             	mov    %eax,(%esp)
80101856:	e8 f9 fd ff ff       	call   80101654 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
8010185b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010185e:	89 c2                	mov    %eax,%edx
80101860:	c1 ea 0c             	shr    $0xc,%edx
80101863:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101866:	c1 e8 03             	shr    $0x3,%eax
80101869:	01 d0                	add    %edx,%eax
8010186b:	8d 50 03             	lea    0x3(%eax),%edx
8010186e:	8b 45 08             	mov    0x8(%ebp),%eax
80101871:	89 54 24 04          	mov    %edx,0x4(%esp)
80101875:	89 04 24             	mov    %eax,(%esp)
80101878:	e8 29 e9 ff ff       	call   801001a6 <bread>
8010187d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101880:	8b 45 0c             	mov    0xc(%ebp),%eax
80101883:	25 ff 0f 00 00       	and    $0xfff,%eax
80101888:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010188b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188e:	89 c2                	mov    %eax,%edx
80101890:	c1 fa 1f             	sar    $0x1f,%edx
80101893:	c1 ea 1d             	shr    $0x1d,%edx
80101896:	01 d0                	add    %edx,%eax
80101898:	83 e0 07             	and    $0x7,%eax
8010189b:	29 d0                	sub    %edx,%eax
8010189d:	ba 01 00 00 00       	mov    $0x1,%edx
801018a2:	89 d3                	mov    %edx,%ebx
801018a4:	89 c1                	mov    %eax,%ecx
801018a6:	d3 e3                	shl    %cl,%ebx
801018a8:	89 d8                	mov    %ebx,%eax
801018aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801018ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b0:	8d 50 07             	lea    0x7(%eax),%edx
801018b3:	85 c0                	test   %eax,%eax
801018b5:	0f 48 c2             	cmovs  %edx,%eax
801018b8:	c1 f8 03             	sar    $0x3,%eax
801018bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018be:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801018c3:	0f b6 c0             	movzbl %al,%eax
801018c6:	23 45 ec             	and    -0x14(%ebp),%eax
801018c9:	85 c0                	test   %eax,%eax
801018cb:	75 0c                	jne    801018d9 <bfree+0x97>
    panic("freeing free block");
801018cd:	c7 04 24 e3 87 10 80 	movl   $0x801087e3,(%esp)
801018d4:	e8 64 ec ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
801018d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018dc:	8d 50 07             	lea    0x7(%eax),%edx
801018df:	85 c0                	test   %eax,%eax
801018e1:	0f 48 c2             	cmovs  %edx,%eax
801018e4:	c1 f8 03             	sar    $0x3,%eax
801018e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018ea:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801018ef:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801018f2:	f7 d1                	not    %ecx
801018f4:	21 ca                	and    %ecx,%edx
801018f6:	89 d1                	mov    %edx,%ecx
801018f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018fb:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801018ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101902:	89 04 24             	mov    %eax,(%esp)
80101905:	e8 1c 1d 00 00       	call   80103626 <log_write>
  brelse(bp);
8010190a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190d:	89 04 24             	mov    %eax,(%esp)
80101910:	e8 02 e9 ff ff       	call   80100217 <brelse>
}
80101915:	83 c4 34             	add    $0x34,%esp
80101918:	5b                   	pop    %ebx
80101919:	5d                   	pop    %ebp
8010191a:	c3                   	ret    

8010191b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
8010191b:	55                   	push   %ebp
8010191c:	89 e5                	mov    %esp,%ebp
8010191e:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101921:	c7 44 24 04 f6 87 10 	movl   $0x801087f6,0x4(%esp)
80101928:	80 
80101929:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101930:	e8 69 37 00 00       	call   8010509e <initlock>
}
80101935:	c9                   	leave  
80101936:	c3                   	ret    

80101937 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101937:	55                   	push   %ebp
80101938:	89 e5                	mov    %esp,%ebp
8010193a:	83 ec 48             	sub    $0x48,%esp
8010193d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101940:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101944:	8b 45 08             	mov    0x8(%ebp),%eax
80101947:	8d 55 dc             	lea    -0x24(%ebp),%edx
8010194a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010194e:	89 04 24             	mov    %eax,(%esp)
80101951:	e8 fe fc ff ff       	call   80101654 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
80101956:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010195d:	e9 98 00 00 00       	jmp    801019fa <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
80101962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101965:	c1 e8 03             	shr    $0x3,%eax
80101968:	83 c0 02             	add    $0x2,%eax
8010196b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010196f:	8b 45 08             	mov    0x8(%ebp),%eax
80101972:	89 04 24             	mov    %eax,(%esp)
80101975:	e8 2c e8 ff ff       	call   801001a6 <bread>
8010197a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010197d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101980:	8d 50 18             	lea    0x18(%eax),%edx
80101983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101986:	83 e0 07             	and    $0x7,%eax
80101989:	c1 e0 06             	shl    $0x6,%eax
8010198c:	01 d0                	add    %edx,%eax
8010198e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101991:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101994:	0f b7 00             	movzwl (%eax),%eax
80101997:	66 85 c0             	test   %ax,%ax
8010199a:	75 4f                	jne    801019eb <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
8010199c:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801019a3:	00 
801019a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801019ab:	00 
801019ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801019af:	89 04 24             	mov    %eax,(%esp)
801019b2:	e8 57 39 00 00       	call   8010530e <memset>
      dip->type = type;
801019b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801019ba:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801019be:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801019c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019c4:	89 04 24             	mov    %eax,(%esp)
801019c7:	e8 5a 1c 00 00       	call   80103626 <log_write>
      brelse(bp);
801019cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cf:	89 04 24             	mov    %eax,(%esp)
801019d2:	e8 40 e8 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
801019d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019da:	89 44 24 04          	mov    %eax,0x4(%esp)
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	89 04 24             	mov    %eax,(%esp)
801019e4:	e8 e3 00 00 00       	call   80101acc <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
801019e9:	c9                   	leave  
801019ea:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801019eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ee:	89 04 24             	mov    %eax,(%esp)
801019f1:	e8 21 e8 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801019f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801019fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101a00:	39 c2                	cmp    %eax,%edx
80101a02:	0f 82 5a ff ff ff    	jb     80101962 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101a08:	c7 04 24 fd 87 10 80 	movl   $0x801087fd,(%esp)
80101a0f:	e8 29 eb ff ff       	call   8010053d <panic>

80101a14 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101a14:	55                   	push   %ebp
80101a15:	89 e5                	mov    %esp,%ebp
80101a17:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1d:	8b 40 04             	mov    0x4(%eax),%eax
80101a20:	c1 e8 03             	shr    $0x3,%eax
80101a23:	8d 50 02             	lea    0x2(%eax),%edx
80101a26:	8b 45 08             	mov    0x8(%ebp),%eax
80101a29:	8b 00                	mov    (%eax),%eax
80101a2b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a2f:	89 04 24             	mov    %eax,(%esp)
80101a32:	e8 6f e7 ff ff       	call   801001a6 <bread>
80101a37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3d:	8d 50 18             	lea    0x18(%eax),%edx
80101a40:	8b 45 08             	mov    0x8(%ebp),%eax
80101a43:	8b 40 04             	mov    0x4(%eax),%eax
80101a46:	83 e0 07             	and    $0x7,%eax
80101a49:	c1 e0 06             	shl    $0x6,%eax
80101a4c:	01 d0                	add    %edx,%eax
80101a4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a61:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a68:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6f:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a76:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a84:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101a88:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8b:	8b 50 18             	mov    0x18(%eax),%edx
80101a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a91:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a94:	8b 45 08             	mov    0x8(%ebp),%eax
80101a97:	8d 50 1c             	lea    0x1c(%eax),%edx
80101a9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9d:	83 c0 0c             	add    $0xc,%eax
80101aa0:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101aa7:	00 
80101aa8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101aac:	89 04 24             	mov    %eax,(%esp)
80101aaf:	e8 2d 39 00 00       	call   801053e1 <memmove>
  log_write(bp);
80101ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab7:	89 04 24             	mov    %eax,(%esp)
80101aba:	e8 67 1b 00 00       	call   80103626 <log_write>
  brelse(bp);
80101abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac2:	89 04 24             	mov    %eax,(%esp)
80101ac5:	e8 4d e7 ff ff       	call   80100217 <brelse>
}
80101aca:	c9                   	leave  
80101acb:	c3                   	ret    

80101acc <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101acc:	55                   	push   %ebp
80101acd:	89 e5                	mov    %esp,%ebp
80101acf:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101ad2:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101ad9:	e8 e1 35 00 00       	call   801050bf <acquire>

  // Is the inode already cached?
  empty = 0;
80101ade:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101ae5:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
80101aec:	eb 59                	jmp    80101b47 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af1:	8b 40 08             	mov    0x8(%eax),%eax
80101af4:	85 c0                	test   %eax,%eax
80101af6:	7e 35                	jle    80101b2d <iget+0x61>
80101af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101afb:	8b 00                	mov    (%eax),%eax
80101afd:	3b 45 08             	cmp    0x8(%ebp),%eax
80101b00:	75 2b                	jne    80101b2d <iget+0x61>
80101b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b05:	8b 40 04             	mov    0x4(%eax),%eax
80101b08:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101b0b:	75 20                	jne    80101b2d <iget+0x61>
      ip->ref++;
80101b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b10:	8b 40 08             	mov    0x8(%eax),%eax
80101b13:	8d 50 01             	lea    0x1(%eax),%edx
80101b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b19:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101b1c:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b23:	e8 f9 35 00 00       	call   80105121 <release>
      return ip;
80101b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b2b:	eb 6f                	jmp    80101b9c <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101b2d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b31:	75 10                	jne    80101b43 <iget+0x77>
80101b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b36:	8b 40 08             	mov    0x8(%eax),%eax
80101b39:	85 c0                	test   %eax,%eax
80101b3b:	75 06                	jne    80101b43 <iget+0x77>
      empty = ip;
80101b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b40:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101b43:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101b47:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
80101b4e:	72 9e                	jb     80101aee <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101b50:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b54:	75 0c                	jne    80101b62 <iget+0x96>
    panic("iget: no inodes");
80101b56:	c7 04 24 0f 88 10 80 	movl   $0x8010880f,(%esp)
80101b5d:	e8 db e9 ff ff       	call   8010053d <panic>

  ip = empty;
80101b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b65:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b6b:	8b 55 08             	mov    0x8(%ebp),%edx
80101b6e:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b73:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b76:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b7c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b86:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101b8d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b94:	e8 88 35 00 00       	call   80105121 <release>

  return ip;
80101b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b9c:	c9                   	leave  
80101b9d:	c3                   	ret    

80101b9e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b9e:	55                   	push   %ebp
80101b9f:	89 e5                	mov    %esp,%ebp
80101ba1:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101ba4:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101bab:	e8 0f 35 00 00       	call   801050bf <acquire>
  ip->ref++;
80101bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb3:	8b 40 08             	mov    0x8(%eax),%eax
80101bb6:	8d 50 01             	lea    0x1(%eax),%edx
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bbf:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101bc6:	e8 56 35 00 00       	call   80105121 <release>
  return ip;
80101bcb:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101bce:	c9                   	leave  
80101bcf:	c3                   	ret    

80101bd0 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101bd0:	55                   	push   %ebp
80101bd1:	89 e5                	mov    %esp,%ebp
80101bd3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101bd6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bda:	74 0a                	je     80101be6 <ilock+0x16>
80101bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdf:	8b 40 08             	mov    0x8(%eax),%eax
80101be2:	85 c0                	test   %eax,%eax
80101be4:	7f 0c                	jg     80101bf2 <ilock+0x22>
    panic("ilock");
80101be6:	c7 04 24 1f 88 10 80 	movl   $0x8010881f,(%esp)
80101bed:	e8 4b e9 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101bf2:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101bf9:	e8 c1 34 00 00       	call   801050bf <acquire>
  while(ip->flags & I_BUSY)
80101bfe:	eb 13                	jmp    80101c13 <ilock+0x43>
    sleep(ip, &icache.lock);
80101c00:	c7 44 24 04 80 e8 10 	movl   $0x8010e880,0x4(%esp)
80101c07:	80 
80101c08:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0b:	89 04 24             	mov    %eax,(%esp)
80101c0e:	e8 c7 31 00 00       	call   80104dda <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101c13:	8b 45 08             	mov    0x8(%ebp),%eax
80101c16:	8b 40 0c             	mov    0xc(%eax),%eax
80101c19:	83 e0 01             	and    $0x1,%eax
80101c1c:	84 c0                	test   %al,%al
80101c1e:	75 e0                	jne    80101c00 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101c20:	8b 45 08             	mov    0x8(%ebp),%eax
80101c23:	8b 40 0c             	mov    0xc(%eax),%eax
80101c26:	89 c2                	mov    %eax,%edx
80101c28:	83 ca 01             	or     $0x1,%edx
80101c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2e:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101c31:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101c38:	e8 e4 34 00 00       	call   80105121 <release>

  if(!(ip->flags & I_VALID)){
80101c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c40:	8b 40 0c             	mov    0xc(%eax),%eax
80101c43:	83 e0 02             	and    $0x2,%eax
80101c46:	85 c0                	test   %eax,%eax
80101c48:	0f 85 ce 00 00 00    	jne    80101d1c <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c51:	8b 40 04             	mov    0x4(%eax),%eax
80101c54:	c1 e8 03             	shr    $0x3,%eax
80101c57:	8d 50 02             	lea    0x2(%eax),%edx
80101c5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5d:	8b 00                	mov    (%eax),%eax
80101c5f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c63:	89 04 24             	mov    %eax,(%esp)
80101c66:	e8 3b e5 ff ff       	call   801001a6 <bread>
80101c6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c71:	8d 50 18             	lea    0x18(%eax),%edx
80101c74:	8b 45 08             	mov    0x8(%ebp),%eax
80101c77:	8b 40 04             	mov    0x4(%eax),%eax
80101c7a:	83 e0 07             	and    $0x7,%eax
80101c7d:	c1 e0 06             	shl    $0x6,%eax
80101c80:	01 d0                	add    %edx,%eax
80101c82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c88:	0f b7 10             	movzwl (%eax),%edx
80101c8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8e:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101c92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c95:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101c99:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9c:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ca3:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80101caa:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb1:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101cb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb8:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cbf:	8b 50 08             	mov    0x8(%eax),%edx
80101cc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc5:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ccb:	8d 50 0c             	lea    0xc(%eax),%edx
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	83 c0 1c             	add    $0x1c,%eax
80101cd4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101cdb:	00 
80101cdc:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ce0:	89 04 24             	mov    %eax,(%esp)
80101ce3:	e8 f9 36 00 00       	call   801053e1 <memmove>
    brelse(bp);
80101ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ceb:	89 04 24             	mov    %eax,(%esp)
80101cee:	e8 24 e5 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf6:	8b 40 0c             	mov    0xc(%eax),%eax
80101cf9:	89 c2                	mov    %eax,%edx
80101cfb:	83 ca 02             	or     $0x2,%edx
80101cfe:	8b 45 08             	mov    0x8(%ebp),%eax
80101d01:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101d04:	8b 45 08             	mov    0x8(%ebp),%eax
80101d07:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d0b:	66 85 c0             	test   %ax,%ax
80101d0e:	75 0c                	jne    80101d1c <ilock+0x14c>
      panic("ilock: no type");
80101d10:	c7 04 24 25 88 10 80 	movl   $0x80108825,(%esp)
80101d17:	e8 21 e8 ff ff       	call   8010053d <panic>
  }
}
80101d1c:	c9                   	leave  
80101d1d:	c3                   	ret    

80101d1e <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101d1e:	55                   	push   %ebp
80101d1f:	89 e5                	mov    %esp,%ebp
80101d21:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101d24:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101d28:	74 17                	je     80101d41 <iunlock+0x23>
80101d2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2d:	8b 40 0c             	mov    0xc(%eax),%eax
80101d30:	83 e0 01             	and    $0x1,%eax
80101d33:	85 c0                	test   %eax,%eax
80101d35:	74 0a                	je     80101d41 <iunlock+0x23>
80101d37:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3a:	8b 40 08             	mov    0x8(%eax),%eax
80101d3d:	85 c0                	test   %eax,%eax
80101d3f:	7f 0c                	jg     80101d4d <iunlock+0x2f>
    panic("iunlock");
80101d41:	c7 04 24 34 88 10 80 	movl   $0x80108834,(%esp)
80101d48:	e8 f0 e7 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101d4d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d54:	e8 66 33 00 00       	call   801050bf <acquire>
  ip->flags &= ~I_BUSY;
80101d59:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5c:	8b 40 0c             	mov    0xc(%eax),%eax
80101d5f:	89 c2                	mov    %eax,%edx
80101d61:	83 e2 fe             	and    $0xfffffffe,%edx
80101d64:	8b 45 08             	mov    0x8(%ebp),%eax
80101d67:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6d:	89 04 24             	mov    %eax,(%esp)
80101d70:	e8 41 31 00 00       	call   80104eb6 <wakeup>
  release(&icache.lock);
80101d75:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d7c:	e8 a0 33 00 00       	call   80105121 <release>
}
80101d81:	c9                   	leave  
80101d82:	c3                   	ret    

80101d83 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101d83:	55                   	push   %ebp
80101d84:	89 e5                	mov    %esp,%ebp
80101d86:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101d89:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d90:	e8 2a 33 00 00       	call   801050bf <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101d95:	8b 45 08             	mov    0x8(%ebp),%eax
80101d98:	8b 40 08             	mov    0x8(%eax),%eax
80101d9b:	83 f8 01             	cmp    $0x1,%eax
80101d9e:	0f 85 93 00 00 00    	jne    80101e37 <iput+0xb4>
80101da4:	8b 45 08             	mov    0x8(%ebp),%eax
80101da7:	8b 40 0c             	mov    0xc(%eax),%eax
80101daa:	83 e0 02             	and    $0x2,%eax
80101dad:	85 c0                	test   %eax,%eax
80101daf:	0f 84 82 00 00 00    	je     80101e37 <iput+0xb4>
80101db5:	8b 45 08             	mov    0x8(%ebp),%eax
80101db8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101dbc:	66 85 c0             	test   %ax,%ax
80101dbf:	75 76                	jne    80101e37 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc4:	8b 40 0c             	mov    0xc(%eax),%eax
80101dc7:	83 e0 01             	and    $0x1,%eax
80101dca:	84 c0                	test   %al,%al
80101dcc:	74 0c                	je     80101dda <iput+0x57>
      panic("iput busy");
80101dce:	c7 04 24 3c 88 10 80 	movl   $0x8010883c,(%esp)
80101dd5:	e8 63 e7 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101dda:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddd:	8b 40 0c             	mov    0xc(%eax),%eax
80101de0:	89 c2                	mov    %eax,%edx
80101de2:	83 ca 01             	or     $0x1,%edx
80101de5:	8b 45 08             	mov    0x8(%ebp),%eax
80101de8:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101deb:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101df2:	e8 2a 33 00 00       	call   80105121 <release>
    itrunc(ip);
80101df7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfa:	89 04 24             	mov    %eax,(%esp)
80101dfd:	e8 72 01 00 00       	call   80101f74 <itrunc>
    ip->type = 0;
80101e02:	8b 45 08             	mov    0x8(%ebp),%eax
80101e05:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0e:	89 04 24             	mov    %eax,(%esp)
80101e11:	e8 fe fb ff ff       	call   80101a14 <iupdate>
    acquire(&icache.lock);
80101e16:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101e1d:	e8 9d 32 00 00       	call   801050bf <acquire>
    ip->flags = 0;
80101e22:	8b 45 08             	mov    0x8(%ebp),%eax
80101e25:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2f:	89 04 24             	mov    %eax,(%esp)
80101e32:	e8 7f 30 00 00       	call   80104eb6 <wakeup>
  }
  ip->ref--;
80101e37:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3a:	8b 40 08             	mov    0x8(%eax),%eax
80101e3d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101e40:	8b 45 08             	mov    0x8(%ebp),%eax
80101e43:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101e46:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101e4d:	e8 cf 32 00 00       	call   80105121 <release>
}
80101e52:	c9                   	leave  
80101e53:	c3                   	ret    

80101e54 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101e54:	55                   	push   %ebp
80101e55:	89 e5                	mov    %esp,%ebp
80101e57:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5d:	89 04 24             	mov    %eax,(%esp)
80101e60:	e8 b9 fe ff ff       	call   80101d1e <iunlock>
  iput(ip);
80101e65:	8b 45 08             	mov    0x8(%ebp),%eax
80101e68:	89 04 24             	mov    %eax,(%esp)
80101e6b:	e8 13 ff ff ff       	call   80101d83 <iput>
}
80101e70:	c9                   	leave  
80101e71:	c3                   	ret    

80101e72 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101e72:	55                   	push   %ebp
80101e73:	89 e5                	mov    %esp,%ebp
80101e75:	53                   	push   %ebx
80101e76:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101e79:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101e7d:	77 3e                	ja     80101ebd <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101e7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e82:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e85:	83 c2 04             	add    $0x4,%edx
80101e88:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e93:	75 20                	jne    80101eb5 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e95:	8b 45 08             	mov    0x8(%ebp),%eax
80101e98:	8b 00                	mov    (%eax),%eax
80101e9a:	89 04 24             	mov    %eax,(%esp)
80101e9d:	e8 49 f8 ff ff       	call   801016eb <balloc>
80101ea2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ea5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea8:	8b 55 0c             	mov    0xc(%ebp),%edx
80101eab:	8d 4a 04             	lea    0x4(%edx),%ecx
80101eae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101eb1:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eb8:	e9 b1 00 00 00       	jmp    80101f6e <bmap+0xfc>
  }
  bn -= NDIRECT;
80101ebd:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ec1:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101ec5:	0f 87 97 00 00 00    	ja     80101f62 <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101ecb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ece:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ed1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ed4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ed8:	75 19                	jne    80101ef3 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101eda:	8b 45 08             	mov    0x8(%ebp),%eax
80101edd:	8b 00                	mov    (%eax),%eax
80101edf:	89 04 24             	mov    %eax,(%esp)
80101ee2:	e8 04 f8 ff ff       	call   801016eb <balloc>
80101ee7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101eea:	8b 45 08             	mov    0x8(%ebp),%eax
80101eed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ef0:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef6:	8b 00                	mov    (%eax),%eax
80101ef8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101efb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eff:	89 04 24             	mov    %eax,(%esp)
80101f02:	e8 9f e2 ff ff       	call   801001a6 <bread>
80101f07:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101f0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f0d:	83 c0 18             	add    $0x18,%eax
80101f10:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101f13:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f16:	c1 e0 02             	shl    $0x2,%eax
80101f19:	03 45 ec             	add    -0x14(%ebp),%eax
80101f1c:	8b 00                	mov    (%eax),%eax
80101f1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101f25:	75 2b                	jne    80101f52 <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101f27:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f2a:	c1 e0 02             	shl    $0x2,%eax
80101f2d:	89 c3                	mov    %eax,%ebx
80101f2f:	03 5d ec             	add    -0x14(%ebp),%ebx
80101f32:	8b 45 08             	mov    0x8(%ebp),%eax
80101f35:	8b 00                	mov    (%eax),%eax
80101f37:	89 04 24             	mov    %eax,(%esp)
80101f3a:	e8 ac f7 ff ff       	call   801016eb <balloc>
80101f3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f45:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f4a:	89 04 24             	mov    %eax,(%esp)
80101f4d:	e8 d4 16 00 00       	call   80103626 <log_write>
    }
    brelse(bp);
80101f52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f55:	89 04 24             	mov    %eax,(%esp)
80101f58:	e8 ba e2 ff ff       	call   80100217 <brelse>
    return addr;
80101f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f60:	eb 0c                	jmp    80101f6e <bmap+0xfc>
  }

  panic("bmap: out of range");
80101f62:	c7 04 24 46 88 10 80 	movl   $0x80108846,(%esp)
80101f69:	e8 cf e5 ff ff       	call   8010053d <panic>
}
80101f6e:	83 c4 24             	add    $0x24,%esp
80101f71:	5b                   	pop    %ebx
80101f72:	5d                   	pop    %ebp
80101f73:	c3                   	ret    

80101f74 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f74:	55                   	push   %ebp
80101f75:	89 e5                	mov    %esp,%ebp
80101f77:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f81:	eb 44                	jmp    80101fc7 <itrunc+0x53>
    if(ip->addrs[i]){
80101f83:	8b 45 08             	mov    0x8(%ebp),%eax
80101f86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f89:	83 c2 04             	add    $0x4,%edx
80101f8c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f90:	85 c0                	test   %eax,%eax
80101f92:	74 2f                	je     80101fc3 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101f94:	8b 45 08             	mov    0x8(%ebp),%eax
80101f97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f9a:	83 c2 04             	add    $0x4,%edx
80101f9d:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa4:	8b 00                	mov    (%eax),%eax
80101fa6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101faa:	89 04 24             	mov    %eax,(%esp)
80101fad:	e8 90 f8 ff ff       	call   80101842 <bfree>
      ip->addrs[i] = 0;
80101fb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101fb8:	83 c2 04             	add    $0x4,%edx
80101fbb:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101fc2:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101fc3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101fc7:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101fcb:	7e b6                	jle    80101f83 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101fd3:	85 c0                	test   %eax,%eax
80101fd5:	0f 84 8f 00 00 00    	je     8010206a <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fde:	8b 50 4c             	mov    0x4c(%eax),%edx
80101fe1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe4:	8b 00                	mov    (%eax),%eax
80101fe6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fea:	89 04 24             	mov    %eax,(%esp)
80101fed:	e8 b4 e1 ff ff       	call   801001a6 <bread>
80101ff2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ff5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff8:	83 c0 18             	add    $0x18,%eax
80101ffb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ffe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80102005:	eb 2f                	jmp    80102036 <itrunc+0xc2>
      if(a[j])
80102007:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200a:	c1 e0 02             	shl    $0x2,%eax
8010200d:	03 45 e8             	add    -0x18(%ebp),%eax
80102010:	8b 00                	mov    (%eax),%eax
80102012:	85 c0                	test   %eax,%eax
80102014:	74 1c                	je     80102032 <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80102016:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102019:	c1 e0 02             	shl    $0x2,%eax
8010201c:	03 45 e8             	add    -0x18(%ebp),%eax
8010201f:	8b 10                	mov    (%eax),%edx
80102021:	8b 45 08             	mov    0x8(%ebp),%eax
80102024:	8b 00                	mov    (%eax),%eax
80102026:	89 54 24 04          	mov    %edx,0x4(%esp)
8010202a:	89 04 24             	mov    %eax,(%esp)
8010202d:	e8 10 f8 ff ff       	call   80101842 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80102032:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80102036:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102039:	83 f8 7f             	cmp    $0x7f,%eax
8010203c:	76 c9                	jbe    80102007 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
8010203e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102041:	89 04 24             	mov    %eax,(%esp)
80102044:	e8 ce e1 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102049:	8b 45 08             	mov    0x8(%ebp),%eax
8010204c:	8b 50 4c             	mov    0x4c(%eax),%edx
8010204f:	8b 45 08             	mov    0x8(%ebp),%eax
80102052:	8b 00                	mov    (%eax),%eax
80102054:	89 54 24 04          	mov    %edx,0x4(%esp)
80102058:	89 04 24             	mov    %eax,(%esp)
8010205b:	e8 e2 f7 ff ff       	call   80101842 <bfree>
    ip->addrs[NDIRECT] = 0;
80102060:	8b 45 08             	mov    0x8(%ebp),%eax
80102063:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
8010206a:	8b 45 08             	mov    0x8(%ebp),%eax
8010206d:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	89 04 24             	mov    %eax,(%esp)
8010207a:	e8 95 f9 ff ff       	call   80101a14 <iupdate>
}
8010207f:	c9                   	leave  
80102080:	c3                   	ret    

80102081 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80102081:	55                   	push   %ebp
80102082:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102084:	8b 45 08             	mov    0x8(%ebp),%eax
80102087:	8b 00                	mov    (%eax),%eax
80102089:	89 c2                	mov    %eax,%edx
8010208b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010208e:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102091:	8b 45 08             	mov    0x8(%ebp),%eax
80102094:	8b 50 04             	mov    0x4(%eax),%edx
80102097:	8b 45 0c             	mov    0xc(%ebp),%eax
8010209a:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
8010209d:	8b 45 08             	mov    0x8(%ebp),%eax
801020a0:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801020a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801020a7:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
801020aa:	8b 45 08             	mov    0x8(%ebp),%eax
801020ad:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801020b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801020b4:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
801020b8:	8b 45 08             	mov    0x8(%ebp),%eax
801020bb:	8b 50 18             	mov    0x18(%eax),%edx
801020be:	8b 45 0c             	mov    0xc(%ebp),%eax
801020c1:	89 50 10             	mov    %edx,0x10(%eax)
}
801020c4:	5d                   	pop    %ebp
801020c5:	c3                   	ret    

801020c6 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801020c6:	55                   	push   %ebp
801020c7:	89 e5                	mov    %esp,%ebp
801020c9:	53                   	push   %ebx
801020ca:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020cd:	8b 45 08             	mov    0x8(%ebp),%eax
801020d0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020d4:	66 83 f8 03          	cmp    $0x3,%ax
801020d8:	75 60                	jne    8010213a <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801020da:	8b 45 08             	mov    0x8(%ebp),%eax
801020dd:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020e1:	66 85 c0             	test   %ax,%ax
801020e4:	78 20                	js     80102106 <readi+0x40>
801020e6:	8b 45 08             	mov    0x8(%ebp),%eax
801020e9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020ed:	66 83 f8 09          	cmp    $0x9,%ax
801020f1:	7f 13                	jg     80102106 <readi+0x40>
801020f3:	8b 45 08             	mov    0x8(%ebp),%eax
801020f6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020fa:	98                   	cwtl   
801020fb:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
80102102:	85 c0                	test   %eax,%eax
80102104:	75 0a                	jne    80102110 <readi+0x4a>
      return -1;
80102106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010210b:	e9 1b 01 00 00       	jmp    8010222b <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80102110:	8b 45 08             	mov    0x8(%ebp),%eax
80102113:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102117:	98                   	cwtl   
80102118:	8b 14 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%edx
8010211f:	8b 45 14             	mov    0x14(%ebp),%eax
80102122:	89 44 24 08          	mov    %eax,0x8(%esp)
80102126:	8b 45 0c             	mov    0xc(%ebp),%eax
80102129:	89 44 24 04          	mov    %eax,0x4(%esp)
8010212d:	8b 45 08             	mov    0x8(%ebp),%eax
80102130:	89 04 24             	mov    %eax,(%esp)
80102133:	ff d2                	call   *%edx
80102135:	e9 f1 00 00 00       	jmp    8010222b <readi+0x165>
  }

  if(off > ip->size || off + n < off)
8010213a:	8b 45 08             	mov    0x8(%ebp),%eax
8010213d:	8b 40 18             	mov    0x18(%eax),%eax
80102140:	3b 45 10             	cmp    0x10(%ebp),%eax
80102143:	72 0d                	jb     80102152 <readi+0x8c>
80102145:	8b 45 14             	mov    0x14(%ebp),%eax
80102148:	8b 55 10             	mov    0x10(%ebp),%edx
8010214b:	01 d0                	add    %edx,%eax
8010214d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102150:	73 0a                	jae    8010215c <readi+0x96>
    return -1;
80102152:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102157:	e9 cf 00 00 00       	jmp    8010222b <readi+0x165>
  if(off + n > ip->size)
8010215c:	8b 45 14             	mov    0x14(%ebp),%eax
8010215f:	8b 55 10             	mov    0x10(%ebp),%edx
80102162:	01 c2                	add    %eax,%edx
80102164:	8b 45 08             	mov    0x8(%ebp),%eax
80102167:	8b 40 18             	mov    0x18(%eax),%eax
8010216a:	39 c2                	cmp    %eax,%edx
8010216c:	76 0c                	jbe    8010217a <readi+0xb4>
    n = ip->size - off;
8010216e:	8b 45 08             	mov    0x8(%ebp),%eax
80102171:	8b 40 18             	mov    0x18(%eax),%eax
80102174:	2b 45 10             	sub    0x10(%ebp),%eax
80102177:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010217a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102181:	e9 96 00 00 00       	jmp    8010221c <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102186:	8b 45 10             	mov    0x10(%ebp),%eax
80102189:	c1 e8 09             	shr    $0x9,%eax
8010218c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102190:	8b 45 08             	mov    0x8(%ebp),%eax
80102193:	89 04 24             	mov    %eax,(%esp)
80102196:	e8 d7 fc ff ff       	call   80101e72 <bmap>
8010219b:	8b 55 08             	mov    0x8(%ebp),%edx
8010219e:	8b 12                	mov    (%edx),%edx
801021a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801021a4:	89 14 24             	mov    %edx,(%esp)
801021a7:	e8 fa df ff ff       	call   801001a6 <bread>
801021ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021af:	8b 45 10             	mov    0x10(%ebp),%eax
801021b2:	89 c2                	mov    %eax,%edx
801021b4:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801021ba:	b8 00 02 00 00       	mov    $0x200,%eax
801021bf:	89 c1                	mov    %eax,%ecx
801021c1:	29 d1                	sub    %edx,%ecx
801021c3:	89 ca                	mov    %ecx,%edx
801021c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021c8:	8b 4d 14             	mov    0x14(%ebp),%ecx
801021cb:	89 cb                	mov    %ecx,%ebx
801021cd:	29 c3                	sub    %eax,%ebx
801021cf:	89 d8                	mov    %ebx,%eax
801021d1:	39 c2                	cmp    %eax,%edx
801021d3:	0f 46 c2             	cmovbe %edx,%eax
801021d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801021d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021dc:	8d 50 18             	lea    0x18(%eax),%edx
801021df:	8b 45 10             	mov    0x10(%ebp),%eax
801021e2:	25 ff 01 00 00       	and    $0x1ff,%eax
801021e7:	01 c2                	add    %eax,%edx
801021e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021ec:	89 44 24 08          	mov    %eax,0x8(%esp)
801021f0:	89 54 24 04          	mov    %edx,0x4(%esp)
801021f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801021f7:	89 04 24             	mov    %eax,(%esp)
801021fa:	e8 e2 31 00 00       	call   801053e1 <memmove>
    brelse(bp);
801021ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102202:	89 04 24             	mov    %eax,(%esp)
80102205:	e8 0d e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010220a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010220d:	01 45 f4             	add    %eax,-0xc(%ebp)
80102210:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102213:	01 45 10             	add    %eax,0x10(%ebp)
80102216:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102219:	01 45 0c             	add    %eax,0xc(%ebp)
8010221c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010221f:	3b 45 14             	cmp    0x14(%ebp),%eax
80102222:	0f 82 5e ff ff ff    	jb     80102186 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102228:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010222b:	83 c4 24             	add    $0x24,%esp
8010222e:	5b                   	pop    %ebx
8010222f:	5d                   	pop    %ebp
80102230:	c3                   	ret    

80102231 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102231:	55                   	push   %ebp
80102232:	89 e5                	mov    %esp,%ebp
80102234:	53                   	push   %ebx
80102235:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102238:	8b 45 08             	mov    0x8(%ebp),%eax
8010223b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010223f:	66 83 f8 03          	cmp    $0x3,%ax
80102243:	75 60                	jne    801022a5 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102245:	8b 45 08             	mov    0x8(%ebp),%eax
80102248:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010224c:	66 85 c0             	test   %ax,%ax
8010224f:	78 20                	js     80102271 <writei+0x40>
80102251:	8b 45 08             	mov    0x8(%ebp),%eax
80102254:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102258:	66 83 f8 09          	cmp    $0x9,%ax
8010225c:	7f 13                	jg     80102271 <writei+0x40>
8010225e:	8b 45 08             	mov    0x8(%ebp),%eax
80102261:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102265:	98                   	cwtl   
80102266:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
8010226d:	85 c0                	test   %eax,%eax
8010226f:	75 0a                	jne    8010227b <writei+0x4a>
      return -1;
80102271:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102276:	e9 46 01 00 00       	jmp    801023c1 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
8010227b:	8b 45 08             	mov    0x8(%ebp),%eax
8010227e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102282:	98                   	cwtl   
80102283:	8b 14 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%edx
8010228a:	8b 45 14             	mov    0x14(%ebp),%eax
8010228d:	89 44 24 08          	mov    %eax,0x8(%esp)
80102291:	8b 45 0c             	mov    0xc(%ebp),%eax
80102294:	89 44 24 04          	mov    %eax,0x4(%esp)
80102298:	8b 45 08             	mov    0x8(%ebp),%eax
8010229b:	89 04 24             	mov    %eax,(%esp)
8010229e:	ff d2                	call   *%edx
801022a0:	e9 1c 01 00 00       	jmp    801023c1 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
801022a5:	8b 45 08             	mov    0x8(%ebp),%eax
801022a8:	8b 40 18             	mov    0x18(%eax),%eax
801022ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801022ae:	72 0d                	jb     801022bd <writei+0x8c>
801022b0:	8b 45 14             	mov    0x14(%ebp),%eax
801022b3:	8b 55 10             	mov    0x10(%ebp),%edx
801022b6:	01 d0                	add    %edx,%eax
801022b8:	3b 45 10             	cmp    0x10(%ebp),%eax
801022bb:	73 0a                	jae    801022c7 <writei+0x96>
    return -1;
801022bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c2:	e9 fa 00 00 00       	jmp    801023c1 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
801022c7:	8b 45 14             	mov    0x14(%ebp),%eax
801022ca:	8b 55 10             	mov    0x10(%ebp),%edx
801022cd:	01 d0                	add    %edx,%eax
801022cf:	3d 00 18 01 00       	cmp    $0x11800,%eax
801022d4:	76 0a                	jbe    801022e0 <writei+0xaf>
    return -1;
801022d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022db:	e9 e1 00 00 00       	jmp    801023c1 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022e7:	e9 a1 00 00 00       	jmp    8010238d <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801022ec:	8b 45 10             	mov    0x10(%ebp),%eax
801022ef:	c1 e8 09             	shr    $0x9,%eax
801022f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801022f6:	8b 45 08             	mov    0x8(%ebp),%eax
801022f9:	89 04 24             	mov    %eax,(%esp)
801022fc:	e8 71 fb ff ff       	call   80101e72 <bmap>
80102301:	8b 55 08             	mov    0x8(%ebp),%edx
80102304:	8b 12                	mov    (%edx),%edx
80102306:	89 44 24 04          	mov    %eax,0x4(%esp)
8010230a:	89 14 24             	mov    %edx,(%esp)
8010230d:	e8 94 de ff ff       	call   801001a6 <bread>
80102312:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102315:	8b 45 10             	mov    0x10(%ebp),%eax
80102318:	89 c2                	mov    %eax,%edx
8010231a:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102320:	b8 00 02 00 00       	mov    $0x200,%eax
80102325:	89 c1                	mov    %eax,%ecx
80102327:	29 d1                	sub    %edx,%ecx
80102329:	89 ca                	mov    %ecx,%edx
8010232b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010232e:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102331:	89 cb                	mov    %ecx,%ebx
80102333:	29 c3                	sub    %eax,%ebx
80102335:	89 d8                	mov    %ebx,%eax
80102337:	39 c2                	cmp    %eax,%edx
80102339:	0f 46 c2             	cmovbe %edx,%eax
8010233c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010233f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102342:	8d 50 18             	lea    0x18(%eax),%edx
80102345:	8b 45 10             	mov    0x10(%ebp),%eax
80102348:	25 ff 01 00 00       	and    $0x1ff,%eax
8010234d:	01 c2                	add    %eax,%edx
8010234f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102352:	89 44 24 08          	mov    %eax,0x8(%esp)
80102356:	8b 45 0c             	mov    0xc(%ebp),%eax
80102359:	89 44 24 04          	mov    %eax,0x4(%esp)
8010235d:	89 14 24             	mov    %edx,(%esp)
80102360:	e8 7c 30 00 00       	call   801053e1 <memmove>
    log_write(bp);
80102365:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102368:	89 04 24             	mov    %eax,(%esp)
8010236b:	e8 b6 12 00 00       	call   80103626 <log_write>
    brelse(bp);
80102370:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102373:	89 04 24             	mov    %eax,(%esp)
80102376:	e8 9c de ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010237b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010237e:	01 45 f4             	add    %eax,-0xc(%ebp)
80102381:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102384:	01 45 10             	add    %eax,0x10(%ebp)
80102387:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010238a:	01 45 0c             	add    %eax,0xc(%ebp)
8010238d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102390:	3b 45 14             	cmp    0x14(%ebp),%eax
80102393:	0f 82 53 ff ff ff    	jb     801022ec <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102399:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010239d:	74 1f                	je     801023be <writei+0x18d>
8010239f:	8b 45 08             	mov    0x8(%ebp),%eax
801023a2:	8b 40 18             	mov    0x18(%eax),%eax
801023a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801023a8:	73 14                	jae    801023be <writei+0x18d>
    ip->size = off;
801023aa:	8b 45 08             	mov    0x8(%ebp),%eax
801023ad:	8b 55 10             	mov    0x10(%ebp),%edx
801023b0:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801023b3:	8b 45 08             	mov    0x8(%ebp),%eax
801023b6:	89 04 24             	mov    %eax,(%esp)
801023b9:	e8 56 f6 ff ff       	call   80101a14 <iupdate>
  }
  return n;
801023be:	8b 45 14             	mov    0x14(%ebp),%eax
}
801023c1:	83 c4 24             	add    $0x24,%esp
801023c4:	5b                   	pop    %ebx
801023c5:	5d                   	pop    %ebp
801023c6:	c3                   	ret    

801023c7 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801023c7:	55                   	push   %ebp
801023c8:	89 e5                	mov    %esp,%ebp
801023ca:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801023cd:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801023d4:	00 
801023d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801023d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801023dc:	8b 45 08             	mov    0x8(%ebp),%eax
801023df:	89 04 24             	mov    %eax,(%esp)
801023e2:	e8 9e 30 00 00       	call   80105485 <strncmp>
}
801023e7:	c9                   	leave  
801023e8:	c3                   	ret    

801023e9 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801023e9:	55                   	push   %ebp
801023ea:	89 e5                	mov    %esp,%ebp
801023ec:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801023ef:	8b 45 08             	mov    0x8(%ebp),%eax
801023f2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023f6:	66 83 f8 01          	cmp    $0x1,%ax
801023fa:	74 0c                	je     80102408 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801023fc:	c7 04 24 59 88 10 80 	movl   $0x80108859,(%esp)
80102403:	e8 35 e1 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102408:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010240f:	e9 87 00 00 00       	jmp    8010249b <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102414:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010241b:	00 
8010241c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010241f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102423:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102426:	89 44 24 04          	mov    %eax,0x4(%esp)
8010242a:	8b 45 08             	mov    0x8(%ebp),%eax
8010242d:	89 04 24             	mov    %eax,(%esp)
80102430:	e8 91 fc ff ff       	call   801020c6 <readi>
80102435:	83 f8 10             	cmp    $0x10,%eax
80102438:	74 0c                	je     80102446 <dirlookup+0x5d>
      panic("dirlink read");
8010243a:	c7 04 24 6b 88 10 80 	movl   $0x8010886b,(%esp)
80102441:	e8 f7 e0 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102446:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010244a:	66 85 c0             	test   %ax,%ax
8010244d:	74 47                	je     80102496 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
8010244f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102452:	83 c0 02             	add    $0x2,%eax
80102455:	89 44 24 04          	mov    %eax,0x4(%esp)
80102459:	8b 45 0c             	mov    0xc(%ebp),%eax
8010245c:	89 04 24             	mov    %eax,(%esp)
8010245f:	e8 63 ff ff ff       	call   801023c7 <namecmp>
80102464:	85 c0                	test   %eax,%eax
80102466:	75 2f                	jne    80102497 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102468:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010246c:	74 08                	je     80102476 <dirlookup+0x8d>
        *poff = off;
8010246e:	8b 45 10             	mov    0x10(%ebp),%eax
80102471:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102474:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102476:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010247a:	0f b7 c0             	movzwl %ax,%eax
8010247d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102480:	8b 45 08             	mov    0x8(%ebp),%eax
80102483:	8b 00                	mov    (%eax),%eax
80102485:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102488:	89 54 24 04          	mov    %edx,0x4(%esp)
8010248c:	89 04 24             	mov    %eax,(%esp)
8010248f:	e8 38 f6 ff ff       	call   80101acc <iget>
80102494:	eb 19                	jmp    801024af <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102496:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102497:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010249b:	8b 45 08             	mov    0x8(%ebp),%eax
8010249e:	8b 40 18             	mov    0x18(%eax),%eax
801024a1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801024a4:	0f 87 6a ff ff ff    	ja     80102414 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801024aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024af:	c9                   	leave  
801024b0:	c3                   	ret    

801024b1 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801024b1:	55                   	push   %ebp
801024b2:	89 e5                	mov    %esp,%ebp
801024b4:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801024b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801024be:	00 
801024bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801024c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801024c6:	8b 45 08             	mov    0x8(%ebp),%eax
801024c9:	89 04 24             	mov    %eax,(%esp)
801024cc:	e8 18 ff ff ff       	call   801023e9 <dirlookup>
801024d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024d8:	74 15                	je     801024ef <dirlink+0x3e>
    iput(ip);
801024da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024dd:	89 04 24             	mov    %eax,(%esp)
801024e0:	e8 9e f8 ff ff       	call   80101d83 <iput>
    return -1;
801024e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024ea:	e9 b8 00 00 00       	jmp    801025a7 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801024f6:	eb 44                	jmp    8010253c <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024fb:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102502:	00 
80102503:	89 44 24 08          	mov    %eax,0x8(%esp)
80102507:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010250a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010250e:	8b 45 08             	mov    0x8(%ebp),%eax
80102511:	89 04 24             	mov    %eax,(%esp)
80102514:	e8 ad fb ff ff       	call   801020c6 <readi>
80102519:	83 f8 10             	cmp    $0x10,%eax
8010251c:	74 0c                	je     8010252a <dirlink+0x79>
      panic("dirlink read");
8010251e:	c7 04 24 6b 88 10 80 	movl   $0x8010886b,(%esp)
80102525:	e8 13 e0 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
8010252a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010252e:	66 85 c0             	test   %ax,%ax
80102531:	74 18                	je     8010254b <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102536:	83 c0 10             	add    $0x10,%eax
80102539:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010253c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010253f:	8b 45 08             	mov    0x8(%ebp),%eax
80102542:	8b 40 18             	mov    0x18(%eax),%eax
80102545:	39 c2                	cmp    %eax,%edx
80102547:	72 af                	jb     801024f8 <dirlink+0x47>
80102549:	eb 01                	jmp    8010254c <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
8010254b:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010254c:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102553:	00 
80102554:	8b 45 0c             	mov    0xc(%ebp),%eax
80102557:	89 44 24 04          	mov    %eax,0x4(%esp)
8010255b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010255e:	83 c0 02             	add    $0x2,%eax
80102561:	89 04 24             	mov    %eax,(%esp)
80102564:	e8 74 2f 00 00       	call   801054dd <strncpy>
  de.inum = inum;
80102569:	8b 45 10             	mov    0x10(%ebp),%eax
8010256c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102573:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010257a:	00 
8010257b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010257f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102582:	89 44 24 04          	mov    %eax,0x4(%esp)
80102586:	8b 45 08             	mov    0x8(%ebp),%eax
80102589:	89 04 24             	mov    %eax,(%esp)
8010258c:	e8 a0 fc ff ff       	call   80102231 <writei>
80102591:	83 f8 10             	cmp    $0x10,%eax
80102594:	74 0c                	je     801025a2 <dirlink+0xf1>
    panic("dirlink");
80102596:	c7 04 24 78 88 10 80 	movl   $0x80108878,(%esp)
8010259d:	e8 9b df ff ff       	call   8010053d <panic>
  
  return 0;
801025a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025a7:	c9                   	leave  
801025a8:	c3                   	ret    

801025a9 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801025a9:	55                   	push   %ebp
801025aa:	89 e5                	mov    %esp,%ebp
801025ac:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801025af:	eb 04                	jmp    801025b5 <skipelem+0xc>
    path++;
801025b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801025b5:	8b 45 08             	mov    0x8(%ebp),%eax
801025b8:	0f b6 00             	movzbl (%eax),%eax
801025bb:	3c 2f                	cmp    $0x2f,%al
801025bd:	74 f2                	je     801025b1 <skipelem+0x8>
    path++;
  if(*path == 0)
801025bf:	8b 45 08             	mov    0x8(%ebp),%eax
801025c2:	0f b6 00             	movzbl (%eax),%eax
801025c5:	84 c0                	test   %al,%al
801025c7:	75 0a                	jne    801025d3 <skipelem+0x2a>
    return 0;
801025c9:	b8 00 00 00 00       	mov    $0x0,%eax
801025ce:	e9 86 00 00 00       	jmp    80102659 <skipelem+0xb0>
  s = path;
801025d3:	8b 45 08             	mov    0x8(%ebp),%eax
801025d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801025d9:	eb 04                	jmp    801025df <skipelem+0x36>
    path++;
801025db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801025df:	8b 45 08             	mov    0x8(%ebp),%eax
801025e2:	0f b6 00             	movzbl (%eax),%eax
801025e5:	3c 2f                	cmp    $0x2f,%al
801025e7:	74 0a                	je     801025f3 <skipelem+0x4a>
801025e9:	8b 45 08             	mov    0x8(%ebp),%eax
801025ec:	0f b6 00             	movzbl (%eax),%eax
801025ef:	84 c0                	test   %al,%al
801025f1:	75 e8                	jne    801025db <skipelem+0x32>
    path++;
  len = path - s;
801025f3:	8b 55 08             	mov    0x8(%ebp),%edx
801025f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f9:	89 d1                	mov    %edx,%ecx
801025fb:	29 c1                	sub    %eax,%ecx
801025fd:	89 c8                	mov    %ecx,%eax
801025ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102602:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102606:	7e 1c                	jle    80102624 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
80102608:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010260f:	00 
80102610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102613:	89 44 24 04          	mov    %eax,0x4(%esp)
80102617:	8b 45 0c             	mov    0xc(%ebp),%eax
8010261a:	89 04 24             	mov    %eax,(%esp)
8010261d:	e8 bf 2d 00 00       	call   801053e1 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102622:	eb 28                	jmp    8010264c <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102624:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102627:	89 44 24 08          	mov    %eax,0x8(%esp)
8010262b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102632:	8b 45 0c             	mov    0xc(%ebp),%eax
80102635:	89 04 24             	mov    %eax,(%esp)
80102638:	e8 a4 2d 00 00       	call   801053e1 <memmove>
    name[len] = 0;
8010263d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102640:	03 45 0c             	add    0xc(%ebp),%eax
80102643:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102646:	eb 04                	jmp    8010264c <skipelem+0xa3>
    path++;
80102648:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010264c:	8b 45 08             	mov    0x8(%ebp),%eax
8010264f:	0f b6 00             	movzbl (%eax),%eax
80102652:	3c 2f                	cmp    $0x2f,%al
80102654:	74 f2                	je     80102648 <skipelem+0x9f>
    path++;
  return path;
80102656:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102659:	c9                   	leave  
8010265a:	c3                   	ret    

8010265b <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010265b:	55                   	push   %ebp
8010265c:	89 e5                	mov    %esp,%ebp
8010265e:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102661:	8b 45 08             	mov    0x8(%ebp),%eax
80102664:	0f b6 00             	movzbl (%eax),%eax
80102667:	3c 2f                	cmp    $0x2f,%al
80102669:	75 1c                	jne    80102687 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010266b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102672:	00 
80102673:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010267a:	e8 4d f4 ff ff       	call   80101acc <iget>
8010267f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102682:	e9 af 00 00 00       	jmp    80102736 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102687:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010268d:	8b 40 68             	mov    0x68(%eax),%eax
80102690:	89 04 24             	mov    %eax,(%esp)
80102693:	e8 06 f5 ff ff       	call   80101b9e <idup>
80102698:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010269b:	e9 96 00 00 00       	jmp    80102736 <namex+0xdb>
    ilock(ip);
801026a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a3:	89 04 24             	mov    %eax,(%esp)
801026a6:	e8 25 f5 ff ff       	call   80101bd0 <ilock>
    if(ip->type != T_DIR){
801026ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ae:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801026b2:	66 83 f8 01          	cmp    $0x1,%ax
801026b6:	74 15                	je     801026cd <namex+0x72>
      iunlockput(ip);
801026b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026bb:	89 04 24             	mov    %eax,(%esp)
801026be:	e8 91 f7 ff ff       	call   80101e54 <iunlockput>
      return 0;
801026c3:	b8 00 00 00 00       	mov    $0x0,%eax
801026c8:	e9 a3 00 00 00       	jmp    80102770 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801026cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026d1:	74 1d                	je     801026f0 <namex+0x95>
801026d3:	8b 45 08             	mov    0x8(%ebp),%eax
801026d6:	0f b6 00             	movzbl (%eax),%eax
801026d9:	84 c0                	test   %al,%al
801026db:	75 13                	jne    801026f0 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801026dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e0:	89 04 24             	mov    %eax,(%esp)
801026e3:	e8 36 f6 ff ff       	call   80101d1e <iunlock>
      return ip;
801026e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026eb:	e9 80 00 00 00       	jmp    80102770 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801026f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801026f7:	00 
801026f8:	8b 45 10             	mov    0x10(%ebp),%eax
801026fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102702:	89 04 24             	mov    %eax,(%esp)
80102705:	e8 df fc ff ff       	call   801023e9 <dirlookup>
8010270a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010270d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102711:	75 12                	jne    80102725 <namex+0xca>
      iunlockput(ip);
80102713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102716:	89 04 24             	mov    %eax,(%esp)
80102719:	e8 36 f7 ff ff       	call   80101e54 <iunlockput>
      return 0;
8010271e:	b8 00 00 00 00       	mov    $0x0,%eax
80102723:	eb 4b                	jmp    80102770 <namex+0x115>
    }
    iunlockput(ip);
80102725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102728:	89 04 24             	mov    %eax,(%esp)
8010272b:	e8 24 f7 ff ff       	call   80101e54 <iunlockput>
    ip = next;
80102730:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102733:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102736:	8b 45 10             	mov    0x10(%ebp),%eax
80102739:	89 44 24 04          	mov    %eax,0x4(%esp)
8010273d:	8b 45 08             	mov    0x8(%ebp),%eax
80102740:	89 04 24             	mov    %eax,(%esp)
80102743:	e8 61 fe ff ff       	call   801025a9 <skipelem>
80102748:	89 45 08             	mov    %eax,0x8(%ebp)
8010274b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010274f:	0f 85 4b ff ff ff    	jne    801026a0 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102755:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102759:	74 12                	je     8010276d <namex+0x112>
    iput(ip);
8010275b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010275e:	89 04 24             	mov    %eax,(%esp)
80102761:	e8 1d f6 ff ff       	call   80101d83 <iput>
    return 0;
80102766:	b8 00 00 00 00       	mov    $0x0,%eax
8010276b:	eb 03                	jmp    80102770 <namex+0x115>
  }
  return ip;
8010276d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102770:	c9                   	leave  
80102771:	c3                   	ret    

80102772 <namei>:

struct inode*
namei(char *path)
{
80102772:	55                   	push   %ebp
80102773:	89 e5                	mov    %esp,%ebp
80102775:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102778:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010277b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010277f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102786:	00 
80102787:	8b 45 08             	mov    0x8(%ebp),%eax
8010278a:	89 04 24             	mov    %eax,(%esp)
8010278d:	e8 c9 fe ff ff       	call   8010265b <namex>
}
80102792:	c9                   	leave  
80102793:	c3                   	ret    

80102794 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102794:	55                   	push   %ebp
80102795:	89 e5                	mov    %esp,%ebp
80102797:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010279a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010279d:	89 44 24 08          	mov    %eax,0x8(%esp)
801027a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801027a8:	00 
801027a9:	8b 45 08             	mov    0x8(%ebp),%eax
801027ac:	89 04 24             	mov    %eax,(%esp)
801027af:	e8 a7 fe ff ff       	call   8010265b <namex>
}
801027b4:	c9                   	leave  
801027b5:	c3                   	ret    
	...

801027b8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801027b8:	55                   	push   %ebp
801027b9:	89 e5                	mov    %esp,%ebp
801027bb:	53                   	push   %ebx
801027bc:	83 ec 14             	sub    $0x14,%esp
801027bf:	8b 45 08             	mov    0x8(%ebp),%eax
801027c2:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027c6:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801027ca:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801027ce:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801027d2:	ec                   	in     (%dx),%al
801027d3:	89 c3                	mov    %eax,%ebx
801027d5:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801027d8:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801027dc:	83 c4 14             	add    $0x14,%esp
801027df:	5b                   	pop    %ebx
801027e0:	5d                   	pop    %ebp
801027e1:	c3                   	ret    

801027e2 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801027e2:	55                   	push   %ebp
801027e3:	89 e5                	mov    %esp,%ebp
801027e5:	57                   	push   %edi
801027e6:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801027e7:	8b 55 08             	mov    0x8(%ebp),%edx
801027ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027ed:	8b 45 10             	mov    0x10(%ebp),%eax
801027f0:	89 cb                	mov    %ecx,%ebx
801027f2:	89 df                	mov    %ebx,%edi
801027f4:	89 c1                	mov    %eax,%ecx
801027f6:	fc                   	cld    
801027f7:	f3 6d                	rep insl (%dx),%es:(%edi)
801027f9:	89 c8                	mov    %ecx,%eax
801027fb:	89 fb                	mov    %edi,%ebx
801027fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102800:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102803:	5b                   	pop    %ebx
80102804:	5f                   	pop    %edi
80102805:	5d                   	pop    %ebp
80102806:	c3                   	ret    

80102807 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102807:	55                   	push   %ebp
80102808:	89 e5                	mov    %esp,%ebp
8010280a:	83 ec 08             	sub    $0x8,%esp
8010280d:	8b 55 08             	mov    0x8(%ebp),%edx
80102810:	8b 45 0c             	mov    0xc(%ebp),%eax
80102813:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102817:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010281a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010281e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102822:	ee                   	out    %al,(%dx)
}
80102823:	c9                   	leave  
80102824:	c3                   	ret    

80102825 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102825:	55                   	push   %ebp
80102826:	89 e5                	mov    %esp,%ebp
80102828:	56                   	push   %esi
80102829:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010282a:	8b 55 08             	mov    0x8(%ebp),%edx
8010282d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102830:	8b 45 10             	mov    0x10(%ebp),%eax
80102833:	89 cb                	mov    %ecx,%ebx
80102835:	89 de                	mov    %ebx,%esi
80102837:	89 c1                	mov    %eax,%ecx
80102839:	fc                   	cld    
8010283a:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010283c:	89 c8                	mov    %ecx,%eax
8010283e:	89 f3                	mov    %esi,%ebx
80102840:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102843:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102846:	5b                   	pop    %ebx
80102847:	5e                   	pop    %esi
80102848:	5d                   	pop    %ebp
80102849:	c3                   	ret    

8010284a <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010284a:	55                   	push   %ebp
8010284b:	89 e5                	mov    %esp,%ebp
8010284d:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102850:	90                   	nop
80102851:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102858:	e8 5b ff ff ff       	call   801027b8 <inb>
8010285d:	0f b6 c0             	movzbl %al,%eax
80102860:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102863:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102866:	25 c0 00 00 00       	and    $0xc0,%eax
8010286b:	83 f8 40             	cmp    $0x40,%eax
8010286e:	75 e1                	jne    80102851 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102870:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102874:	74 11                	je     80102887 <idewait+0x3d>
80102876:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102879:	83 e0 21             	and    $0x21,%eax
8010287c:	85 c0                	test   %eax,%eax
8010287e:	74 07                	je     80102887 <idewait+0x3d>
    return -1;
80102880:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102885:	eb 05                	jmp    8010288c <idewait+0x42>
  return 0;
80102887:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010288c:	c9                   	leave  
8010288d:	c3                   	ret    

8010288e <ideinit>:

void
ideinit(void)
{
8010288e:	55                   	push   %ebp
8010288f:	89 e5                	mov    %esp,%ebp
80102891:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102894:	c7 44 24 04 80 88 10 	movl   $0x80108880,0x4(%esp)
8010289b:	80 
8010289c:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801028a3:	e8 f6 27 00 00       	call   8010509e <initlock>
  picenable(IRQ_IDE);
801028a8:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801028af:	e8 75 15 00 00       	call   80103e29 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
801028b4:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
801028b9:	83 e8 01             	sub    $0x1,%eax
801028bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801028c0:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801028c7:	e8 12 04 00 00       	call   80102cde <ioapicenable>
  idewait(0);
801028cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028d3:	e8 72 ff ff ff       	call   8010284a <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801028d8:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801028df:	00 
801028e0:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028e7:	e8 1b ff ff ff       	call   80102807 <outb>
  for(i=0; i<1000; i++){
801028ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028f3:	eb 20                	jmp    80102915 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801028f5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028fc:	e8 b7 fe ff ff       	call   801027b8 <inb>
80102901:	84 c0                	test   %al,%al
80102903:	74 0c                	je     80102911 <ideinit+0x83>
      havedisk1 = 1;
80102905:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
8010290c:	00 00 00 
      break;
8010290f:	eb 0d                	jmp    8010291e <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102911:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102915:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010291c:	7e d7                	jle    801028f5 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010291e:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102925:	00 
80102926:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010292d:	e8 d5 fe ff ff       	call   80102807 <outb>
}
80102932:	c9                   	leave  
80102933:	c3                   	ret    

80102934 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102934:	55                   	push   %ebp
80102935:	89 e5                	mov    %esp,%ebp
80102937:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010293a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010293e:	75 0c                	jne    8010294c <idestart+0x18>
    panic("idestart");
80102940:	c7 04 24 84 88 10 80 	movl   $0x80108884,(%esp)
80102947:	e8 f1 db ff ff       	call   8010053d <panic>

  idewait(0);
8010294c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102953:	e8 f2 fe ff ff       	call   8010284a <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102958:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010295f:	00 
80102960:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102967:	e8 9b fe ff ff       	call   80102807 <outb>
  outb(0x1f2, 1);  // number of sectors
8010296c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102973:	00 
80102974:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010297b:	e8 87 fe ff ff       	call   80102807 <outb>
  outb(0x1f3, b->sector & 0xff);
80102980:	8b 45 08             	mov    0x8(%ebp),%eax
80102983:	8b 40 08             	mov    0x8(%eax),%eax
80102986:	0f b6 c0             	movzbl %al,%eax
80102989:	89 44 24 04          	mov    %eax,0x4(%esp)
8010298d:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102994:	e8 6e fe ff ff       	call   80102807 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102999:	8b 45 08             	mov    0x8(%ebp),%eax
8010299c:	8b 40 08             	mov    0x8(%eax),%eax
8010299f:	c1 e8 08             	shr    $0x8,%eax
801029a2:	0f b6 c0             	movzbl %al,%eax
801029a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801029a9:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801029b0:	e8 52 fe ff ff       	call   80102807 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
801029b5:	8b 45 08             	mov    0x8(%ebp),%eax
801029b8:	8b 40 08             	mov    0x8(%eax),%eax
801029bb:	c1 e8 10             	shr    $0x10,%eax
801029be:	0f b6 c0             	movzbl %al,%eax
801029c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801029c5:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801029cc:	e8 36 fe ff ff       	call   80102807 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801029d1:	8b 45 08             	mov    0x8(%ebp),%eax
801029d4:	8b 40 04             	mov    0x4(%eax),%eax
801029d7:	83 e0 01             	and    $0x1,%eax
801029da:	89 c2                	mov    %eax,%edx
801029dc:	c1 e2 04             	shl    $0x4,%edx
801029df:	8b 45 08             	mov    0x8(%ebp),%eax
801029e2:	8b 40 08             	mov    0x8(%eax),%eax
801029e5:	c1 e8 18             	shr    $0x18,%eax
801029e8:	83 e0 0f             	and    $0xf,%eax
801029eb:	09 d0                	or     %edx,%eax
801029ed:	83 c8 e0             	or     $0xffffffe0,%eax
801029f0:	0f b6 c0             	movzbl %al,%eax
801029f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f7:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801029fe:	e8 04 fe ff ff       	call   80102807 <outb>
  if(b->flags & B_DIRTY){
80102a03:	8b 45 08             	mov    0x8(%ebp),%eax
80102a06:	8b 00                	mov    (%eax),%eax
80102a08:	83 e0 04             	and    $0x4,%eax
80102a0b:	85 c0                	test   %eax,%eax
80102a0d:	74 34                	je     80102a43 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102a0f:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102a16:	00 
80102a17:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a1e:	e8 e4 fd ff ff       	call   80102807 <outb>
    outsl(0x1f0, b->data, 512/4);
80102a23:	8b 45 08             	mov    0x8(%ebp),%eax
80102a26:	83 c0 18             	add    $0x18,%eax
80102a29:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a30:	00 
80102a31:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a35:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a3c:	e8 e4 fd ff ff       	call   80102825 <outsl>
80102a41:	eb 14                	jmp    80102a57 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102a43:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102a4a:	00 
80102a4b:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a52:	e8 b0 fd ff ff       	call   80102807 <outb>
  }
}
80102a57:	c9                   	leave  
80102a58:	c3                   	ret    

80102a59 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a59:	55                   	push   %ebp
80102a5a:	89 e5                	mov    %esp,%ebp
80102a5c:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a5f:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a66:	e8 54 26 00 00       	call   801050bf <acquire>
  if((b = idequeue) == 0){
80102a6b:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a77:	75 11                	jne    80102a8a <ideintr+0x31>
    release(&idelock);
80102a79:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a80:	e8 9c 26 00 00       	call   80105121 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102a85:	e9 90 00 00 00       	jmp    80102b1a <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a8d:	8b 40 14             	mov    0x14(%eax),%eax
80102a90:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a98:	8b 00                	mov    (%eax),%eax
80102a9a:	83 e0 04             	and    $0x4,%eax
80102a9d:	85 c0                	test   %eax,%eax
80102a9f:	75 2e                	jne    80102acf <ideintr+0x76>
80102aa1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102aa8:	e8 9d fd ff ff       	call   8010284a <idewait>
80102aad:	85 c0                	test   %eax,%eax
80102aaf:	78 1e                	js     80102acf <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab4:	83 c0 18             	add    $0x18,%eax
80102ab7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102abe:	00 
80102abf:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ac3:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102aca:	e8 13 fd ff ff       	call   801027e2 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad2:	8b 00                	mov    (%eax),%eax
80102ad4:	89 c2                	mov    %eax,%edx
80102ad6:	83 ca 02             	or     $0x2,%edx
80102ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102adc:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae1:	8b 00                	mov    (%eax),%eax
80102ae3:	89 c2                	mov    %eax,%edx
80102ae5:	83 e2 fb             	and    $0xfffffffb,%edx
80102ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aeb:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af0:	89 04 24             	mov    %eax,(%esp)
80102af3:	e8 be 23 00 00       	call   80104eb6 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102af8:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102afd:	85 c0                	test   %eax,%eax
80102aff:	74 0d                	je     80102b0e <ideintr+0xb5>
    idestart(idequeue);
80102b01:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102b06:	89 04 24             	mov    %eax,(%esp)
80102b09:	e8 26 fe ff ff       	call   80102934 <idestart>

  release(&idelock);
80102b0e:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b15:	e8 07 26 00 00       	call   80105121 <release>
}
80102b1a:	c9                   	leave  
80102b1b:	c3                   	ret    

80102b1c <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b1c:	55                   	push   %ebp
80102b1d:	89 e5                	mov    %esp,%ebp
80102b1f:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102b22:	8b 45 08             	mov    0x8(%ebp),%eax
80102b25:	8b 00                	mov    (%eax),%eax
80102b27:	83 e0 01             	and    $0x1,%eax
80102b2a:	85 c0                	test   %eax,%eax
80102b2c:	75 0c                	jne    80102b3a <iderw+0x1e>
    panic("iderw: buf not busy");
80102b2e:	c7 04 24 8d 88 10 80 	movl   $0x8010888d,(%esp)
80102b35:	e8 03 da ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3d:	8b 00                	mov    (%eax),%eax
80102b3f:	83 e0 06             	and    $0x6,%eax
80102b42:	83 f8 02             	cmp    $0x2,%eax
80102b45:	75 0c                	jne    80102b53 <iderw+0x37>
    panic("iderw: nothing to do");
80102b47:	c7 04 24 a1 88 10 80 	movl   $0x801088a1,(%esp)
80102b4e:	e8 ea d9 ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102b53:	8b 45 08             	mov    0x8(%ebp),%eax
80102b56:	8b 40 04             	mov    0x4(%eax),%eax
80102b59:	85 c0                	test   %eax,%eax
80102b5b:	74 15                	je     80102b72 <iderw+0x56>
80102b5d:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102b62:	85 c0                	test   %eax,%eax
80102b64:	75 0c                	jne    80102b72 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102b66:	c7 04 24 b6 88 10 80 	movl   $0x801088b6,(%esp)
80102b6d:	e8 cb d9 ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102b72:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b79:	e8 41 25 00 00       	call   801050bf <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b81:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102b88:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102b8f:	eb 0b                	jmp    80102b9c <iderw+0x80>
80102b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b94:	8b 00                	mov    (%eax),%eax
80102b96:	83 c0 14             	add    $0x14,%eax
80102b99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9f:	8b 00                	mov    (%eax),%eax
80102ba1:	85 c0                	test   %eax,%eax
80102ba3:	75 ec                	jne    80102b91 <iderw+0x75>
    ;
  *pp = b;
80102ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba8:	8b 55 08             	mov    0x8(%ebp),%edx
80102bab:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102bad:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102bb2:	3b 45 08             	cmp    0x8(%ebp),%eax
80102bb5:	75 22                	jne    80102bd9 <iderw+0xbd>
    idestart(b);
80102bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80102bba:	89 04 24             	mov    %eax,(%esp)
80102bbd:	e8 72 fd ff ff       	call   80102934 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bc2:	eb 15                	jmp    80102bd9 <iderw+0xbd>
    sleep(b, &idelock);
80102bc4:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102bcb:	80 
80102bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80102bcf:	89 04 24             	mov    %eax,(%esp)
80102bd2:	e8 03 22 00 00       	call   80104dda <sleep>
80102bd7:	eb 01                	jmp    80102bda <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bd9:	90                   	nop
80102bda:	8b 45 08             	mov    0x8(%ebp),%eax
80102bdd:	8b 00                	mov    (%eax),%eax
80102bdf:	83 e0 06             	and    $0x6,%eax
80102be2:	83 f8 02             	cmp    $0x2,%eax
80102be5:	75 dd                	jne    80102bc4 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102be7:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102bee:	e8 2e 25 00 00       	call   80105121 <release>
}
80102bf3:	c9                   	leave  
80102bf4:	c3                   	ret    
80102bf5:	00 00                	add    %al,(%eax)
	...

80102bf8 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bf8:	55                   	push   %ebp
80102bf9:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bfb:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102c00:	8b 55 08             	mov    0x8(%ebp),%edx
80102c03:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102c05:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102c0a:	8b 40 10             	mov    0x10(%eax),%eax
}
80102c0d:	5d                   	pop    %ebp
80102c0e:	c3                   	ret    

80102c0f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102c0f:	55                   	push   %ebp
80102c10:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c12:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102c17:	8b 55 08             	mov    0x8(%ebp),%edx
80102c1a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c1c:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102c21:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c24:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c27:	5d                   	pop    %ebp
80102c28:	c3                   	ret    

80102c29 <ioapicinit>:

void
ioapicinit(void)
{
80102c29:	55                   	push   %ebp
80102c2a:	89 e5                	mov    %esp,%ebp
80102c2c:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102c2f:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102c34:	85 c0                	test   %eax,%eax
80102c36:	0f 84 9f 00 00 00    	je     80102cdb <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c3c:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
80102c43:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c46:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c4d:	e8 a6 ff ff ff       	call   80102bf8 <ioapicread>
80102c52:	c1 e8 10             	shr    $0x10,%eax
80102c55:	25 ff 00 00 00       	and    $0xff,%eax
80102c5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c64:	e8 8f ff ff ff       	call   80102bf8 <ioapicread>
80102c69:	c1 e8 18             	shr    $0x18,%eax
80102c6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c6f:	0f b6 05 20 f9 10 80 	movzbl 0x8010f920,%eax
80102c76:	0f b6 c0             	movzbl %al,%eax
80102c79:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c7c:	74 0c                	je     80102c8a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c7e:	c7 04 24 d4 88 10 80 	movl   $0x801088d4,(%esp)
80102c85:	e8 17 d7 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c91:	eb 3e                	jmp    80102cd1 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c96:	83 c0 20             	add    $0x20,%eax
80102c99:	0d 00 00 01 00       	or     $0x10000,%eax
80102c9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102ca1:	83 c2 08             	add    $0x8,%edx
80102ca4:	01 d2                	add    %edx,%edx
80102ca6:	89 44 24 04          	mov    %eax,0x4(%esp)
80102caa:	89 14 24             	mov    %edx,(%esp)
80102cad:	e8 5d ff ff ff       	call   80102c0f <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cb5:	83 c0 08             	add    $0x8,%eax
80102cb8:	01 c0                	add    %eax,%eax
80102cba:	83 c0 01             	add    $0x1,%eax
80102cbd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102cc4:	00 
80102cc5:	89 04 24             	mov    %eax,(%esp)
80102cc8:	e8 42 ff ff ff       	call   80102c0f <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ccd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102cd7:	7e ba                	jle    80102c93 <ioapicinit+0x6a>
80102cd9:	eb 01                	jmp    80102cdc <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102cdb:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102cdc:	c9                   	leave  
80102cdd:	c3                   	ret    

80102cde <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102cde:	55                   	push   %ebp
80102cdf:	89 e5                	mov    %esp,%ebp
80102ce1:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102ce4:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102ce9:	85 c0                	test   %eax,%eax
80102ceb:	74 39                	je     80102d26 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ced:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf0:	83 c0 20             	add    $0x20,%eax
80102cf3:	8b 55 08             	mov    0x8(%ebp),%edx
80102cf6:	83 c2 08             	add    $0x8,%edx
80102cf9:	01 d2                	add    %edx,%edx
80102cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cff:	89 14 24             	mov    %edx,(%esp)
80102d02:	e8 08 ff ff ff       	call   80102c0f <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102d07:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d0a:	c1 e0 18             	shl    $0x18,%eax
80102d0d:	8b 55 08             	mov    0x8(%ebp),%edx
80102d10:	83 c2 08             	add    $0x8,%edx
80102d13:	01 d2                	add    %edx,%edx
80102d15:	83 c2 01             	add    $0x1,%edx
80102d18:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d1c:	89 14 24             	mov    %edx,(%esp)
80102d1f:	e8 eb fe ff ff       	call   80102c0f <ioapicwrite>
80102d24:	eb 01                	jmp    80102d27 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102d26:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102d27:	c9                   	leave  
80102d28:	c3                   	ret    
80102d29:	00 00                	add    %al,(%eax)
	...

80102d2c <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102d2c:	55                   	push   %ebp
80102d2d:	89 e5                	mov    %esp,%ebp
80102d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d32:	05 00 00 00 80       	add    $0x80000000,%eax
80102d37:	5d                   	pop    %ebp
80102d38:	c3                   	ret    

80102d39 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d39:	55                   	push   %ebp
80102d3a:	89 e5                	mov    %esp,%ebp
80102d3c:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102d3f:	c7 44 24 04 06 89 10 	movl   $0x80108906,0x4(%esp)
80102d46:	80 
80102d47:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102d4e:	e8 4b 23 00 00       	call   8010509e <initlock>
  kmem.use_lock = 0;
80102d53:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
80102d5a:	00 00 00 
  freerange(vstart, vend);
80102d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d60:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d64:	8b 45 08             	mov    0x8(%ebp),%eax
80102d67:	89 04 24             	mov    %eax,(%esp)
80102d6a:	e8 26 00 00 00       	call   80102d95 <freerange>
}
80102d6f:	c9                   	leave  
80102d70:	c3                   	ret    

80102d71 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d71:	55                   	push   %ebp
80102d72:	89 e5                	mov    %esp,%ebp
80102d74:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d77:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102d81:	89 04 24             	mov    %eax,(%esp)
80102d84:	e8 0c 00 00 00       	call   80102d95 <freerange>
  kmem.use_lock = 1;
80102d89:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
80102d90:	00 00 00 
}
80102d93:	c9                   	leave  
80102d94:	c3                   	ret    

80102d95 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d95:	55                   	push   %ebp
80102d96:	89 e5                	mov    %esp,%ebp
80102d98:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d9e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102da3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102da8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102dab:	eb 12                	jmp    80102dbf <freerange+0x2a>
    kfree(p);
80102dad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102db0:	89 04 24             	mov    %eax,(%esp)
80102db3:	e8 16 00 00 00       	call   80102dce <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102db8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dc2:	05 00 10 00 00       	add    $0x1000,%eax
80102dc7:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102dca:	76 e1                	jbe    80102dad <freerange+0x18>
    kfree(p);
}
80102dcc:	c9                   	leave  
80102dcd:	c3                   	ret    

80102dce <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dce:	55                   	push   %ebp
80102dcf:	89 e5                	mov    %esp,%ebp
80102dd1:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd7:	25 ff 0f 00 00       	and    $0xfff,%eax
80102ddc:	85 c0                	test   %eax,%eax
80102dde:	75 1b                	jne    80102dfb <kfree+0x2d>
80102de0:	81 7d 08 1c 2a 11 80 	cmpl   $0x80112a1c,0x8(%ebp)
80102de7:	72 12                	jb     80102dfb <kfree+0x2d>
80102de9:	8b 45 08             	mov    0x8(%ebp),%eax
80102dec:	89 04 24             	mov    %eax,(%esp)
80102def:	e8 38 ff ff ff       	call   80102d2c <v2p>
80102df4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102df9:	76 0c                	jbe    80102e07 <kfree+0x39>
    panic("kfree");
80102dfb:	c7 04 24 0b 89 10 80 	movl   $0x8010890b,(%esp)
80102e02:	e8 36 d7 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102e07:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102e0e:	00 
80102e0f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102e16:	00 
80102e17:	8b 45 08             	mov    0x8(%ebp),%eax
80102e1a:	89 04 24             	mov    %eax,(%esp)
80102e1d:	e8 ec 24 00 00       	call   8010530e <memset>

  if(kmem.use_lock)
80102e22:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e27:	85 c0                	test   %eax,%eax
80102e29:	74 0c                	je     80102e37 <kfree+0x69>
    acquire(&kmem.lock);
80102e2b:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e32:	e8 88 22 00 00       	call   801050bf <acquire>
  r = (struct run*)v;
80102e37:	8b 45 08             	mov    0x8(%ebp),%eax
80102e3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e3d:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e46:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e4b:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e50:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e55:	85 c0                	test   %eax,%eax
80102e57:	74 0c                	je     80102e65 <kfree+0x97>
    release(&kmem.lock);
80102e59:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e60:	e8 bc 22 00 00       	call   80105121 <release>
}
80102e65:	c9                   	leave  
80102e66:	c3                   	ret    

80102e67 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e67:	55                   	push   %ebp
80102e68:	89 e5                	mov    %esp,%ebp
80102e6a:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102e6d:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e72:	85 c0                	test   %eax,%eax
80102e74:	74 0c                	je     80102e82 <kalloc+0x1b>
    acquire(&kmem.lock);
80102e76:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e7d:	e8 3d 22 00 00       	call   801050bf <acquire>
  r = kmem.freelist;
80102e82:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102e87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e8e:	74 0a                	je     80102e9a <kalloc+0x33>
    kmem.freelist = r->next;
80102e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e93:	8b 00                	mov    (%eax),%eax
80102e95:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e9a:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e9f:	85 c0                	test   %eax,%eax
80102ea1:	74 0c                	je     80102eaf <kalloc+0x48>
    release(&kmem.lock);
80102ea3:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102eaa:	e8 72 22 00 00       	call   80105121 <release>
  return (char*)r;
80102eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102eb2:	c9                   	leave  
80102eb3:	c3                   	ret    

80102eb4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102eb4:	55                   	push   %ebp
80102eb5:	89 e5                	mov    %esp,%ebp
80102eb7:	53                   	push   %ebx
80102eb8:	83 ec 14             	sub    $0x14,%esp
80102ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80102ebe:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ec2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102ec6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102eca:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102ece:	ec                   	in     (%dx),%al
80102ecf:	89 c3                	mov    %eax,%ebx
80102ed1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102ed4:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102ed8:	83 c4 14             	add    $0x14,%esp
80102edb:	5b                   	pop    %ebx
80102edc:	5d                   	pop    %ebp
80102edd:	c3                   	ret    

80102ede <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102ede:	55                   	push   %ebp
80102edf:	89 e5                	mov    %esp,%ebp
80102ee1:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ee4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102eeb:	e8 c4 ff ff ff       	call   80102eb4 <inb>
80102ef0:	0f b6 c0             	movzbl %al,%eax
80102ef3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ef9:	83 e0 01             	and    $0x1,%eax
80102efc:	85 c0                	test   %eax,%eax
80102efe:	75 0a                	jne    80102f0a <kbdgetc+0x2c>
    return -1;
80102f00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f05:	e9 23 01 00 00       	jmp    8010302d <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102f0a:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102f11:	e8 9e ff ff ff       	call   80102eb4 <inb>
80102f16:	0f b6 c0             	movzbl %al,%eax
80102f19:	89 45 fc             	mov    %eax,-0x4(%ebp)
    
  if(data == 0xE0){
80102f1c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f23:	75 17                	jne    80102f3c <kbdgetc+0x5e>
    shift |= E0ESC;
80102f25:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f2a:	83 c8 40             	or     $0x40,%eax
80102f2d:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102f32:	b8 00 00 00 00       	mov    $0x0,%eax
80102f37:	e9 f1 00 00 00       	jmp    8010302d <kbdgetc+0x14f>
  } else if(data & 0x80){
80102f3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f3f:	25 80 00 00 00       	and    $0x80,%eax
80102f44:	85 c0                	test   %eax,%eax
80102f46:	74 45                	je     80102f8d <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f48:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f4d:	83 e0 40             	and    $0x40,%eax
80102f50:	85 c0                	test   %eax,%eax
80102f52:	75 08                	jne    80102f5c <kbdgetc+0x7e>
80102f54:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f57:	83 e0 7f             	and    $0x7f,%eax
80102f5a:	eb 03                	jmp    80102f5f <kbdgetc+0x81>
80102f5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f62:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f65:	05 20 90 10 80       	add    $0x80109020,%eax
80102f6a:	0f b6 00             	movzbl (%eax),%eax
80102f6d:	83 c8 40             	or     $0x40,%eax
80102f70:	0f b6 c0             	movzbl %al,%eax
80102f73:	f7 d0                	not    %eax
80102f75:	89 c2                	mov    %eax,%edx
80102f77:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f7c:	21 d0                	and    %edx,%eax
80102f7e:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102f83:	b8 00 00 00 00       	mov    $0x0,%eax
80102f88:	e9 a0 00 00 00       	jmp    8010302d <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102f8d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f92:	83 e0 40             	and    $0x40,%eax
80102f95:	85 c0                	test   %eax,%eax
80102f97:	74 14                	je     80102fad <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f99:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102fa0:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fa5:	83 e0 bf             	and    $0xffffffbf,%eax
80102fa8:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102fad:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fb0:	05 20 90 10 80       	add    $0x80109020,%eax
80102fb5:	0f b6 00             	movzbl (%eax),%eax
80102fb8:	0f b6 d0             	movzbl %al,%edx
80102fbb:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fc0:	09 d0                	or     %edx,%eax
80102fc2:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102fc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fca:	05 20 91 10 80       	add    $0x80109120,%eax
80102fcf:	0f b6 00             	movzbl (%eax),%eax
80102fd2:	0f b6 d0             	movzbl %al,%edx
80102fd5:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fda:	31 d0                	xor    %edx,%eax
80102fdc:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fe1:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fe6:	83 e0 03             	and    $0x3,%eax
80102fe9:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
80102ff0:	03 45 fc             	add    -0x4(%ebp),%eax
80102ff3:	0f b6 00             	movzbl (%eax),%eax
80102ff6:	0f b6 c0             	movzbl %al,%eax
80102ff9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ffc:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80103001:	83 e0 08             	and    $0x8,%eax
80103004:	85 c0                	test   %eax,%eax
80103006:	74 22                	je     8010302a <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80103008:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
8010300c:	76 0c                	jbe    8010301a <kbdgetc+0x13c>
8010300e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80103012:	77 06                	ja     8010301a <kbdgetc+0x13c>
      c += 'A' - 'a';
80103014:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103018:	eb 10                	jmp    8010302a <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
8010301a:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010301e:	76 0a                	jbe    8010302a <kbdgetc+0x14c>
80103020:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103024:	77 04                	ja     8010302a <kbdgetc+0x14c>
      c += 'a' - 'A';
80103026:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
8010302a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010302d:	c9                   	leave  
8010302e:	c3                   	ret    

8010302f <kbdintr>:

void
kbdintr(void)
{
8010302f:	55                   	push   %ebp
80103030:	89 e5                	mov    %esp,%ebp
80103032:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80103035:	c7 04 24 de 2e 10 80 	movl   $0x80102ede,(%esp)
8010303c:	e8 8d d8 ff ff       	call   801008ce <consoleintr>
}
80103041:	c9                   	leave  
80103042:	c3                   	ret    
	...

80103044 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103044:	55                   	push   %ebp
80103045:	89 e5                	mov    %esp,%ebp
80103047:	83 ec 08             	sub    $0x8,%esp
8010304a:	8b 55 08             	mov    0x8(%ebp),%edx
8010304d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103050:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103054:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103057:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010305b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010305f:	ee                   	out    %al,(%dx)
}
80103060:	c9                   	leave  
80103061:	c3                   	ret    

80103062 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103062:	55                   	push   %ebp
80103063:	89 e5                	mov    %esp,%ebp
80103065:	53                   	push   %ebx
80103066:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103069:	9c                   	pushf  
8010306a:	5b                   	pop    %ebx
8010306b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010306e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103071:	83 c4 10             	add    $0x10,%esp
80103074:	5b                   	pop    %ebx
80103075:	5d                   	pop    %ebp
80103076:	c3                   	ret    

80103077 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103077:	55                   	push   %ebp
80103078:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010307a:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010307f:	8b 55 08             	mov    0x8(%ebp),%edx
80103082:	c1 e2 02             	shl    $0x2,%edx
80103085:	01 c2                	add    %eax,%edx
80103087:	8b 45 0c             	mov    0xc(%ebp),%eax
8010308a:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010308c:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103091:	83 c0 20             	add    $0x20,%eax
80103094:	8b 00                	mov    (%eax),%eax
}
80103096:	5d                   	pop    %ebp
80103097:	c3                   	ret    

80103098 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80103098:	55                   	push   %ebp
80103099:	89 e5                	mov    %esp,%ebp
8010309b:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
8010309e:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801030a3:	85 c0                	test   %eax,%eax
801030a5:	0f 84 47 01 00 00    	je     801031f2 <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801030ab:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
801030b2:	00 
801030b3:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
801030ba:	e8 b8 ff ff ff       	call   80103077 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030bf:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
801030c6:	00 
801030c7:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
801030ce:	e8 a4 ff ff ff       	call   80103077 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801030d3:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
801030da:	00 
801030db:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030e2:	e8 90 ff ff ff       	call   80103077 <lapicw>
  lapicw(TICR, 10000000); 
801030e7:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801030ee:	00 
801030ef:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801030f6:	e8 7c ff ff ff       	call   80103077 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030fb:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103102:	00 
80103103:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
8010310a:	e8 68 ff ff ff       	call   80103077 <lapicw>
  lapicw(LINT1, MASKED);
8010310f:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103116:	00 
80103117:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
8010311e:	e8 54 ff ff ff       	call   80103077 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103123:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103128:	83 c0 30             	add    $0x30,%eax
8010312b:	8b 00                	mov    (%eax),%eax
8010312d:	c1 e8 10             	shr    $0x10,%eax
80103130:	25 ff 00 00 00       	and    $0xff,%eax
80103135:	83 f8 03             	cmp    $0x3,%eax
80103138:	76 14                	jbe    8010314e <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
8010313a:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103141:	00 
80103142:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103149:	e8 29 ff ff ff       	call   80103077 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010314e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103155:	00 
80103156:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
8010315d:	e8 15 ff ff ff       	call   80103077 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103162:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103169:	00 
8010316a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103171:	e8 01 ff ff ff       	call   80103077 <lapicw>
  lapicw(ESR, 0);
80103176:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010317d:	00 
8010317e:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103185:	e8 ed fe ff ff       	call   80103077 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010318a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103191:	00 
80103192:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103199:	e8 d9 fe ff ff       	call   80103077 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010319e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031a5:	00 
801031a6:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801031ad:	e8 c5 fe ff ff       	call   80103077 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801031b2:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
801031b9:	00 
801031ba:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031c1:	e8 b1 fe ff ff       	call   80103077 <lapicw>
  while(lapic[ICRLO] & DELIVS)
801031c6:	90                   	nop
801031c7:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031cc:	05 00 03 00 00       	add    $0x300,%eax
801031d1:	8b 00                	mov    (%eax),%eax
801031d3:	25 00 10 00 00       	and    $0x1000,%eax
801031d8:	85 c0                	test   %eax,%eax
801031da:	75 eb                	jne    801031c7 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031e3:	00 
801031e4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801031eb:	e8 87 fe ff ff       	call   80103077 <lapicw>
801031f0:	eb 01                	jmp    801031f3 <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
801031f2:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801031f3:	c9                   	leave  
801031f4:	c3                   	ret    

801031f5 <cpunum>:

int
cpunum(void)
{
801031f5:	55                   	push   %ebp
801031f6:	89 e5                	mov    %esp,%ebp
801031f8:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801031fb:	e8 62 fe ff ff       	call   80103062 <readeflags>
80103200:	25 00 02 00 00       	and    $0x200,%eax
80103205:	85 c0                	test   %eax,%eax
80103207:	74 29                	je     80103232 <cpunum+0x3d>
    static int n;
    if(n++ == 0)
80103209:	a1 40 b6 10 80       	mov    0x8010b640,%eax
8010320e:	85 c0                	test   %eax,%eax
80103210:	0f 94 c2             	sete   %dl
80103213:	83 c0 01             	add    $0x1,%eax
80103216:	a3 40 b6 10 80       	mov    %eax,0x8010b640
8010321b:	84 d2                	test   %dl,%dl
8010321d:	74 13                	je     80103232 <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
8010321f:	8b 45 04             	mov    0x4(%ebp),%eax
80103222:	89 44 24 04          	mov    %eax,0x4(%esp)
80103226:	c7 04 24 14 89 10 80 	movl   $0x80108914,(%esp)
8010322d:	e8 6f d1 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80103232:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103237:	85 c0                	test   %eax,%eax
80103239:	74 0f                	je     8010324a <cpunum+0x55>
    return lapic[ID]>>24;
8010323b:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103240:	83 c0 20             	add    $0x20,%eax
80103243:	8b 00                	mov    (%eax),%eax
80103245:	c1 e8 18             	shr    $0x18,%eax
80103248:	eb 05                	jmp    8010324f <cpunum+0x5a>
  return 0;
8010324a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010324f:	c9                   	leave  
80103250:	c3                   	ret    

80103251 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103251:	55                   	push   %ebp
80103252:	89 e5                	mov    %esp,%ebp
80103254:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103257:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010325c:	85 c0                	test   %eax,%eax
8010325e:	74 14                	je     80103274 <lapiceoi+0x23>
    lapicw(EOI, 0);
80103260:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103267:	00 
80103268:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010326f:	e8 03 fe ff ff       	call   80103077 <lapicw>
}
80103274:	c9                   	leave  
80103275:	c3                   	ret    

80103276 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103276:	55                   	push   %ebp
80103277:	89 e5                	mov    %esp,%ebp
}
80103279:	5d                   	pop    %ebp
8010327a:	c3                   	ret    

8010327b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010327b:	55                   	push   %ebp
8010327c:	89 e5                	mov    %esp,%ebp
8010327e:	83 ec 1c             	sub    $0x1c,%esp
80103281:	8b 45 08             	mov    0x8(%ebp),%eax
80103284:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80103287:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010328e:	00 
8010328f:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103296:	e8 a9 fd ff ff       	call   80103044 <outb>
  outb(IO_RTC+1, 0x0A);
8010329b:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801032a2:	00 
801032a3:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801032aa:	e8 95 fd ff ff       	call   80103044 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801032af:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801032b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032b9:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801032be:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032c1:	8d 50 02             	lea    0x2(%eax),%edx
801032c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801032c7:	c1 e8 04             	shr    $0x4,%eax
801032ca:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801032cd:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032d1:	c1 e0 18             	shl    $0x18,%eax
801032d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801032d8:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032df:	e8 93 fd ff ff       	call   80103077 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801032e4:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801032eb:	00 
801032ec:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032f3:	e8 7f fd ff ff       	call   80103077 <lapicw>
  microdelay(200);
801032f8:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032ff:	e8 72 ff ff ff       	call   80103276 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103304:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
8010330b:	00 
8010330c:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103313:	e8 5f fd ff ff       	call   80103077 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103318:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010331f:	e8 52 ff ff ff       	call   80103276 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103324:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010332b:	eb 40                	jmp    8010336d <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
8010332d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103331:	c1 e0 18             	shl    $0x18,%eax
80103334:	89 44 24 04          	mov    %eax,0x4(%esp)
80103338:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010333f:	e8 33 fd ff ff       	call   80103077 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103344:	8b 45 0c             	mov    0xc(%ebp),%eax
80103347:	c1 e8 0c             	shr    $0xc,%eax
8010334a:	80 cc 06             	or     $0x6,%ah
8010334d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103351:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103358:	e8 1a fd ff ff       	call   80103077 <lapicw>
    microdelay(200);
8010335d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103364:	e8 0d ff ff ff       	call   80103276 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103369:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010336d:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103371:	7e ba                	jle    8010332d <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103373:	c9                   	leave  
80103374:	c3                   	ret    
80103375:	00 00                	add    %al,(%eax)
	...

80103378 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103378:	55                   	push   %ebp
80103379:	89 e5                	mov    %esp,%ebp
8010337b:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010337e:	c7 44 24 04 40 89 10 	movl   $0x80108940,0x4(%esp)
80103385:	80 
80103386:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010338d:	e8 0c 1d 00 00       	call   8010509e <initlock>
  readsb(ROOTDEV, &sb);
80103392:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103395:	89 44 24 04          	mov    %eax,0x4(%esp)
80103399:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801033a0:	e8 af e2 ff ff       	call   80101654 <readsb>
  log.start = sb.size - sb.nlog;
801033a5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801033a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033ab:	89 d1                	mov    %edx,%ecx
801033ad:	29 c1                	sub    %eax,%ecx
801033af:	89 c8                	mov    %ecx,%eax
801033b1:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
801033b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b9:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
801033be:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
801033c5:	00 00 00 
  recover_from_log();
801033c8:	e8 97 01 00 00       	call   80103564 <recover_from_log>
}
801033cd:	c9                   	leave  
801033ce:	c3                   	ret    

801033cf <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801033cf:	55                   	push   %ebp
801033d0:	89 e5                	mov    %esp,%ebp
801033d2:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033dc:	e9 89 00 00 00       	jmp    8010346a <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033e1:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801033e6:	03 45 f4             	add    -0xc(%ebp),%eax
801033e9:	83 c0 01             	add    $0x1,%eax
801033ec:	89 c2                	mov    %eax,%edx
801033ee:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801033f3:	89 54 24 04          	mov    %edx,0x4(%esp)
801033f7:	89 04 24             	mov    %eax,(%esp)
801033fa:	e8 a7 cd ff ff       	call   801001a6 <bread>
801033ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
80103402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103405:	83 c0 10             	add    $0x10,%eax
80103408:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
8010340f:	89 c2                	mov    %eax,%edx
80103411:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103416:	89 54 24 04          	mov    %edx,0x4(%esp)
8010341a:	89 04 24             	mov    %eax,(%esp)
8010341d:	e8 84 cd ff ff       	call   801001a6 <bread>
80103422:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103425:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103428:	8d 50 18             	lea    0x18(%eax),%edx
8010342b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010342e:	83 c0 18             	add    $0x18,%eax
80103431:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103438:	00 
80103439:	89 54 24 04          	mov    %edx,0x4(%esp)
8010343d:	89 04 24             	mov    %eax,(%esp)
80103440:	e8 9c 1f 00 00       	call   801053e1 <memmove>
    bwrite(dbuf);  // write dst to disk
80103445:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103448:	89 04 24             	mov    %eax,(%esp)
8010344b:	e8 8d cd ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103450:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103453:	89 04 24             	mov    %eax,(%esp)
80103456:	e8 bc cd ff ff       	call   80100217 <brelse>
    brelse(dbuf);
8010345b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345e:	89 04 24             	mov    %eax,(%esp)
80103461:	e8 b1 cd ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103466:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010346a:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010346f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103472:	0f 8f 69 ff ff ff    	jg     801033e1 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103478:	c9                   	leave  
80103479:	c3                   	ret    

8010347a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010347a:	55                   	push   %ebp
8010347b:	89 e5                	mov    %esp,%ebp
8010347d:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103480:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103485:	89 c2                	mov    %eax,%edx
80103487:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
8010348c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103490:	89 04 24             	mov    %eax,(%esp)
80103493:	e8 0e cd ff ff       	call   801001a6 <bread>
80103498:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010349b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010349e:	83 c0 18             	add    $0x18,%eax
801034a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801034a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034a7:	8b 00                	mov    (%eax),%eax
801034a9:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
801034ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034b5:	eb 1b                	jmp    801034d2 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
801034b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034bd:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034c4:	83 c2 10             	add    $0x10,%edx
801034c7:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034d2:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801034d7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034da:	7f db                	jg     801034b7 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801034dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034df:	89 04 24             	mov    %eax,(%esp)
801034e2:	e8 30 cd ff ff       	call   80100217 <brelse>
}
801034e7:	c9                   	leave  
801034e8:	c3                   	ret    

801034e9 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034e9:	55                   	push   %ebp
801034ea:	89 e5                	mov    %esp,%ebp
801034ec:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034ef:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801034f4:	89 c2                	mov    %eax,%edx
801034f6:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801034fb:	89 54 24 04          	mov    %edx,0x4(%esp)
801034ff:	89 04 24             	mov    %eax,(%esp)
80103502:	e8 9f cc ff ff       	call   801001a6 <bread>
80103507:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010350a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010350d:	83 c0 18             	add    $0x18,%eax
80103510:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103513:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
80103519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010351c:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010351e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103525:	eb 1b                	jmp    80103542 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
80103527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010352a:	83 c0 10             	add    $0x10,%eax
8010352d:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
80103534:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010353a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010353e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103542:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103547:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010354a:	7f db                	jg     80103527 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
8010354c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010354f:	89 04 24             	mov    %eax,(%esp)
80103552:	e8 86 cc ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103557:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010355a:	89 04 24             	mov    %eax,(%esp)
8010355d:	e8 b5 cc ff ff       	call   80100217 <brelse>
}
80103562:	c9                   	leave  
80103563:	c3                   	ret    

80103564 <recover_from_log>:

static void
recover_from_log(void)
{
80103564:	55                   	push   %ebp
80103565:	89 e5                	mov    %esp,%ebp
80103567:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010356a:	e8 0b ff ff ff       	call   8010347a <read_head>
  install_trans(); // if committed, copy from log to disk
8010356f:	e8 5b fe ff ff       	call   801033cf <install_trans>
  log.lh.n = 0;
80103574:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
8010357b:	00 00 00 
  write_head(); // clear the log
8010357e:	e8 66 ff ff ff       	call   801034e9 <write_head>
}
80103583:	c9                   	leave  
80103584:	c3                   	ret    

80103585 <begin_trans>:

void
begin_trans(void)
{
80103585:	55                   	push   %ebp
80103586:	89 e5                	mov    %esp,%ebp
80103588:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
8010358b:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103592:	e8 28 1b 00 00       	call   801050bf <acquire>
  while (log.busy) {
80103597:	eb 14                	jmp    801035ad <begin_trans+0x28>
    sleep(&log, &log.lock);
80103599:	c7 44 24 04 a0 f8 10 	movl   $0x8010f8a0,0x4(%esp)
801035a0:	80 
801035a1:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035a8:	e8 2d 18 00 00       	call   80104dda <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
801035ad:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
801035b2:	85 c0                	test   %eax,%eax
801035b4:	75 e3                	jne    80103599 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
801035b6:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
801035bd:	00 00 00 
  release(&log.lock);
801035c0:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035c7:	e8 55 1b 00 00       	call   80105121 <release>
}
801035cc:	c9                   	leave  
801035cd:	c3                   	ret    

801035ce <commit_trans>:

void
commit_trans(void)
{
801035ce:	55                   	push   %ebp
801035cf:	89 e5                	mov    %esp,%ebp
801035d1:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
801035d4:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035d9:	85 c0                	test   %eax,%eax
801035db:	7e 19                	jle    801035f6 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
801035dd:	e8 07 ff ff ff       	call   801034e9 <write_head>
    install_trans(); // Now install writes to home locations
801035e2:	e8 e8 fd ff ff       	call   801033cf <install_trans>
    log.lh.n = 0; 
801035e7:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
801035ee:	00 00 00 
    write_head();    // Erase the transaction from the log
801035f1:	e8 f3 fe ff ff       	call   801034e9 <write_head>
  }
  
  acquire(&log.lock);
801035f6:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035fd:	e8 bd 1a 00 00       	call   801050bf <acquire>
  log.busy = 0;
80103602:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
80103609:	00 00 00 
  wakeup(&log);
8010360c:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103613:	e8 9e 18 00 00       	call   80104eb6 <wakeup>
  release(&log.lock);
80103618:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010361f:	e8 fd 1a 00 00       	call   80105121 <release>
}
80103624:	c9                   	leave  
80103625:	c3                   	ret    

80103626 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103626:	55                   	push   %ebp
80103627:	89 e5                	mov    %esp,%ebp
80103629:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010362c:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103631:	83 f8 09             	cmp    $0x9,%eax
80103634:	7f 12                	jg     80103648 <log_write+0x22>
80103636:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010363b:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
80103641:	83 ea 01             	sub    $0x1,%edx
80103644:	39 d0                	cmp    %edx,%eax
80103646:	7c 0c                	jl     80103654 <log_write+0x2e>
    panic("too big a transaction");
80103648:	c7 04 24 44 89 10 80 	movl   $0x80108944,(%esp)
8010364f:	e8 e9 ce ff ff       	call   8010053d <panic>
  if (!log.busy)
80103654:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103659:	85 c0                	test   %eax,%eax
8010365b:	75 0c                	jne    80103669 <log_write+0x43>
    panic("write outside of trans");
8010365d:	c7 04 24 5a 89 10 80 	movl   $0x8010895a,(%esp)
80103664:	e8 d4 ce ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
80103669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103670:	eb 1d                	jmp    8010368f <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
80103672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103675:	83 c0 10             	add    $0x10,%eax
80103678:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
8010367f:	89 c2                	mov    %eax,%edx
80103681:	8b 45 08             	mov    0x8(%ebp),%eax
80103684:	8b 40 08             	mov    0x8(%eax),%eax
80103687:	39 c2                	cmp    %eax,%edx
80103689:	74 10                	je     8010369b <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
8010368b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010368f:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103694:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103697:	7f d9                	jg     80103672 <log_write+0x4c>
80103699:	eb 01                	jmp    8010369c <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
8010369b:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
8010369c:	8b 45 08             	mov    0x8(%ebp),%eax
8010369f:	8b 40 08             	mov    0x8(%eax),%eax
801036a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036a5:	83 c2 10             	add    $0x10,%edx
801036a8:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
801036af:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801036b4:	03 45 f4             	add    -0xc(%ebp),%eax
801036b7:	83 c0 01             	add    $0x1,%eax
801036ba:	89 c2                	mov    %eax,%edx
801036bc:	8b 45 08             	mov    0x8(%ebp),%eax
801036bf:	8b 40 04             	mov    0x4(%eax),%eax
801036c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801036c6:	89 04 24             	mov    %eax,(%esp)
801036c9:	e8 d8 ca ff ff       	call   801001a6 <bread>
801036ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
801036d1:	8b 45 08             	mov    0x8(%ebp),%eax
801036d4:	8d 50 18             	lea    0x18(%eax),%edx
801036d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036da:	83 c0 18             	add    $0x18,%eax
801036dd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036e4:	00 
801036e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801036e9:	89 04 24             	mov    %eax,(%esp)
801036ec:	e8 f0 1c 00 00       	call   801053e1 <memmove>
  bwrite(lbuf);
801036f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036f4:	89 04 24             	mov    %eax,(%esp)
801036f7:	e8 e1 ca ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
801036fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036ff:	89 04 24             	mov    %eax,(%esp)
80103702:	e8 10 cb ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
80103707:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010370c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010370f:	75 0d                	jne    8010371e <log_write+0xf8>
    log.lh.n++;
80103711:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103716:	83 c0 01             	add    $0x1,%eax
80103719:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 00                	mov    (%eax),%eax
80103723:	89 c2                	mov    %eax,%edx
80103725:	83 ca 04             	or     $0x4,%edx
80103728:	8b 45 08             	mov    0x8(%ebp),%eax
8010372b:	89 10                	mov    %edx,(%eax)
}
8010372d:	c9                   	leave  
8010372e:	c3                   	ret    
	...

80103730 <v2p>:
80103730:	55                   	push   %ebp
80103731:	89 e5                	mov    %esp,%ebp
80103733:	8b 45 08             	mov    0x8(%ebp),%eax
80103736:	05 00 00 00 80       	add    $0x80000000,%eax
8010373b:	5d                   	pop    %ebp
8010373c:	c3                   	ret    

8010373d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010373d:	55                   	push   %ebp
8010373e:	89 e5                	mov    %esp,%ebp
80103740:	8b 45 08             	mov    0x8(%ebp),%eax
80103743:	05 00 00 00 80       	add    $0x80000000,%eax
80103748:	5d                   	pop    %ebp
80103749:	c3                   	ret    

8010374a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010374a:	55                   	push   %ebp
8010374b:	89 e5                	mov    %esp,%ebp
8010374d:	53                   	push   %ebx
8010374e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80103751:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103754:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80103757:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010375a:	89 c3                	mov    %eax,%ebx
8010375c:	89 d8                	mov    %ebx,%eax
8010375e:	f0 87 02             	lock xchg %eax,(%edx)
80103761:	89 c3                	mov    %eax,%ebx
80103763:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103766:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103769:	83 c4 10             	add    $0x10,%esp
8010376c:	5b                   	pop    %ebx
8010376d:	5d                   	pop    %ebp
8010376e:	c3                   	ret    

8010376f <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010376f:	55                   	push   %ebp
80103770:	89 e5                	mov    %esp,%ebp
80103772:	83 e4 f0             	and    $0xfffffff0,%esp
80103775:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103778:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010377f:	80 
80103780:	c7 04 24 1c 2a 11 80 	movl   $0x80112a1c,(%esp)
80103787:	e8 ad f5 ff ff       	call   80102d39 <kinit1>
  kvmalloc();      // kernel page table
8010378c:	e8 0d 48 00 00       	call   80107f9e <kvmalloc>
  mpinit();        // collect info about this machine
80103791:	e8 63 04 00 00       	call   80103bf9 <mpinit>
  lapicinit(mpbcpu());
80103796:	e8 2e 02 00 00       	call   801039c9 <mpbcpu>
8010379b:	89 04 24             	mov    %eax,(%esp)
8010379e:	e8 f5 f8 ff ff       	call   80103098 <lapicinit>
  seginit();       // set up segments
801037a3:	e8 99 41 00 00       	call   80107941 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037a8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037ae:	0f b6 00             	movzbl (%eax),%eax
801037b1:	0f b6 c0             	movzbl %al,%eax
801037b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801037b8:	c7 04 24 71 89 10 80 	movl   $0x80108971,(%esp)
801037bf:	e8 dd cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037c4:	e8 95 06 00 00       	call   80103e5e <picinit>
  ioapicinit();    // another interrupt controller
801037c9:	e8 5b f4 ff ff       	call   80102c29 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037ce:	e8 23 d6 ff ff       	call   80100df6 <consoleinit>
  uartinit();      // serial port
801037d3:	e8 b4 34 00 00       	call   80106c8c <uartinit>
  pinit();         // process table
801037d8:	e8 96 0b 00 00       	call   80104373 <pinit>
  tvinit();        // trap vectors
801037dd:	e8 2d 30 00 00       	call   8010680f <tvinit>
  binit();         // buffer cache
801037e2:	e8 4d c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037e7:	e8 7c da ff ff       	call   80101268 <fileinit>
  iinit();         // inode cache
801037ec:	e8 2a e1 ff ff       	call   8010191b <iinit>
  ideinit();       // disk
801037f1:	e8 98 f0 ff ff       	call   8010288e <ideinit>
  if(!ismp)
801037f6:	a1 24 f9 10 80       	mov    0x8010f924,%eax
801037fb:	85 c0                	test   %eax,%eax
801037fd:	75 05                	jne    80103804 <main+0x95>
    timerinit();   // uniprocessor timer
801037ff:	e8 4e 2f 00 00       	call   80106752 <timerinit>
  startothers();   // start other processors
80103804:	e8 87 00 00 00       	call   80103890 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103809:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103810:	8e 
80103811:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103818:	e8 54 f5 ff ff       	call   80102d71 <kinit2>
  userinit();      // first user process
8010381d:	e8 6f 0c 00 00       	call   80104491 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103822:	e8 22 00 00 00       	call   80103849 <mpmain>

80103827 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103827:	55                   	push   %ebp
80103828:	89 e5                	mov    %esp,%ebp
8010382a:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
8010382d:	e8 83 47 00 00       	call   80107fb5 <switchkvm>
  seginit();
80103832:	e8 0a 41 00 00       	call   80107941 <seginit>
  lapicinit(cpunum());
80103837:	e8 b9 f9 ff ff       	call   801031f5 <cpunum>
8010383c:	89 04 24             	mov    %eax,(%esp)
8010383f:	e8 54 f8 ff ff       	call   80103098 <lapicinit>
  mpmain();
80103844:	e8 00 00 00 00       	call   80103849 <mpmain>

80103849 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103849:	55                   	push   %ebp
8010384a:	89 e5                	mov    %esp,%ebp
8010384c:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010384f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103855:	0f b6 00             	movzbl (%eax),%eax
80103858:	0f b6 c0             	movzbl %al,%eax
8010385b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010385f:	c7 04 24 88 89 10 80 	movl   $0x80108988,(%esp)
80103866:	e8 36 cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
8010386b:	e8 13 31 00 00       	call   80106983 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103870:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103876:	05 a8 00 00 00       	add    $0xa8,%eax
8010387b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103882:	00 
80103883:	89 04 24             	mov    %eax,(%esp)
80103886:	e8 bf fe ff ff       	call   8010374a <xchg>
  scheduler();     // start running processes
8010388b:	e8 9e 13 00 00       	call   80104c2e <scheduler>

80103890 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103890:	55                   	push   %ebp
80103891:	89 e5                	mov    %esp,%ebp
80103893:	53                   	push   %ebx
80103894:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103897:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
8010389e:	e8 9a fe ff ff       	call   8010373d <p2v>
801038a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038a6:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038ab:	89 44 24 08          	mov    %eax,0x8(%esp)
801038af:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
801038b6:	80 
801038b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ba:	89 04 24             	mov    %eax,(%esp)
801038bd:	e8 1f 1b 00 00       	call   801053e1 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801038c2:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
801038c9:	e9 86 00 00 00       	jmp    80103954 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
801038ce:	e8 22 f9 ff ff       	call   801031f5 <cpunum>
801038d3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038d9:	05 40 f9 10 80       	add    $0x8010f940,%eax
801038de:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038e1:	74 69                	je     8010394c <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038e3:	e8 7f f5 ff ff       	call   80102e67 <kalloc>
801038e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ee:	83 e8 04             	sub    $0x4,%eax
801038f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038f4:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038fa:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ff:	83 e8 08             	sub    $0x8,%eax
80103902:	c7 00 27 38 10 80    	movl   $0x80103827,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103908:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390b:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010390e:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103915:	e8 16 fe ff ff       	call   80103730 <v2p>
8010391a:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010391c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010391f:	89 04 24             	mov    %eax,(%esp)
80103922:	e8 09 fe ff ff       	call   80103730 <v2p>
80103927:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010392a:	0f b6 12             	movzbl (%edx),%edx
8010392d:	0f b6 d2             	movzbl %dl,%edx
80103930:	89 44 24 04          	mov    %eax,0x4(%esp)
80103934:	89 14 24             	mov    %edx,(%esp)
80103937:	e8 3f f9 ff ff       	call   8010327b <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010393c:	90                   	nop
8010393d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103940:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103946:	85 c0                	test   %eax,%eax
80103948:	74 f3                	je     8010393d <startothers+0xad>
8010394a:	eb 01                	jmp    8010394d <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
8010394c:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010394d:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103954:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103959:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010395f:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103964:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103967:	0f 87 61 ff ff ff    	ja     801038ce <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
8010396d:	83 c4 24             	add    $0x24,%esp
80103970:	5b                   	pop    %ebx
80103971:	5d                   	pop    %ebp
80103972:	c3                   	ret    
	...

80103974 <p2v>:
80103974:	55                   	push   %ebp
80103975:	89 e5                	mov    %esp,%ebp
80103977:	8b 45 08             	mov    0x8(%ebp),%eax
8010397a:	05 00 00 00 80       	add    $0x80000000,%eax
8010397f:	5d                   	pop    %ebp
80103980:	c3                   	ret    

80103981 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103981:	55                   	push   %ebp
80103982:	89 e5                	mov    %esp,%ebp
80103984:	53                   	push   %ebx
80103985:	83 ec 14             	sub    $0x14,%esp
80103988:	8b 45 08             	mov    0x8(%ebp),%eax
8010398b:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010398f:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103993:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80103997:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010399b:	ec                   	in     (%dx),%al
8010399c:	89 c3                	mov    %eax,%ebx
8010399e:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801039a1:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801039a5:	83 c4 14             	add    $0x14,%esp
801039a8:	5b                   	pop    %ebx
801039a9:	5d                   	pop    %ebp
801039aa:	c3                   	ret    

801039ab <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039ab:	55                   	push   %ebp
801039ac:	89 e5                	mov    %esp,%ebp
801039ae:	83 ec 08             	sub    $0x8,%esp
801039b1:	8b 55 08             	mov    0x8(%ebp),%edx
801039b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801039b7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039bb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039be:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039c2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039c6:	ee                   	out    %al,(%dx)
}
801039c7:	c9                   	leave  
801039c8:	c3                   	ret    

801039c9 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039c9:	55                   	push   %ebp
801039ca:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039cc:	a1 44 b6 10 80       	mov    0x8010b644,%eax
801039d1:	89 c2                	mov    %eax,%edx
801039d3:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
801039d8:	89 d1                	mov    %edx,%ecx
801039da:	29 c1                	sub    %eax,%ecx
801039dc:	89 c8                	mov    %ecx,%eax
801039de:	c1 f8 02             	sar    $0x2,%eax
801039e1:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801039e7:	5d                   	pop    %ebp
801039e8:	c3                   	ret    

801039e9 <sum>:

static uchar
sum(uchar *addr, int len)
{
801039e9:	55                   	push   %ebp
801039ea:	89 e5                	mov    %esp,%ebp
801039ec:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039ef:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039f6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039fd:	eb 13                	jmp    80103a12 <sum+0x29>
    sum += addr[i];
801039ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a02:	03 45 08             	add    0x8(%ebp),%eax
80103a05:	0f b6 00             	movzbl (%eax),%eax
80103a08:	0f b6 c0             	movzbl %al,%eax
80103a0b:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a0e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a12:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a15:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a18:	7c e5                	jl     801039ff <sum+0x16>
    sum += addr[i];
  return sum;
80103a1a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a1d:	c9                   	leave  
80103a1e:	c3                   	ret    

80103a1f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a1f:	55                   	push   %ebp
80103a20:	89 e5                	mov    %esp,%ebp
80103a22:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a25:	8b 45 08             	mov    0x8(%ebp),%eax
80103a28:	89 04 24             	mov    %eax,(%esp)
80103a2b:	e8 44 ff ff ff       	call   80103974 <p2v>
80103a30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a33:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a36:	03 45 f0             	add    -0x10(%ebp),%eax
80103a39:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a42:	eb 3f                	jmp    80103a83 <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a44:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a4b:	00 
80103a4c:	c7 44 24 04 9c 89 10 	movl   $0x8010899c,0x4(%esp)
80103a53:	80 
80103a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a57:	89 04 24             	mov    %eax,(%esp)
80103a5a:	e8 26 19 00 00       	call   80105385 <memcmp>
80103a5f:	85 c0                	test   %eax,%eax
80103a61:	75 1c                	jne    80103a7f <mpsearch1+0x60>
80103a63:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a6a:	00 
80103a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a6e:	89 04 24             	mov    %eax,(%esp)
80103a71:	e8 73 ff ff ff       	call   801039e9 <sum>
80103a76:	84 c0                	test   %al,%al
80103a78:	75 05                	jne    80103a7f <mpsearch1+0x60>
      return (struct mp*)p;
80103a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7d:	eb 11                	jmp    80103a90 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a7f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a86:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a89:	72 b9                	jb     80103a44 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a90:	c9                   	leave  
80103a91:	c3                   	ret    

80103a92 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a92:	55                   	push   %ebp
80103a93:	89 e5                	mov    %esp,%ebp
80103a95:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a98:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa2:	83 c0 0f             	add    $0xf,%eax
80103aa5:	0f b6 00             	movzbl (%eax),%eax
80103aa8:	0f b6 c0             	movzbl %al,%eax
80103aab:	89 c2                	mov    %eax,%edx
80103aad:	c1 e2 08             	shl    $0x8,%edx
80103ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab3:	83 c0 0e             	add    $0xe,%eax
80103ab6:	0f b6 00             	movzbl (%eax),%eax
80103ab9:	0f b6 c0             	movzbl %al,%eax
80103abc:	09 d0                	or     %edx,%eax
80103abe:	c1 e0 04             	shl    $0x4,%eax
80103ac1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ac4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ac8:	74 21                	je     80103aeb <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103aca:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ad1:	00 
80103ad2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad5:	89 04 24             	mov    %eax,(%esp)
80103ad8:	e8 42 ff ff ff       	call   80103a1f <mpsearch1>
80103add:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ae0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ae4:	74 50                	je     80103b36 <mpsearch+0xa4>
      return mp;
80103ae6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ae9:	eb 5f                	jmp    80103b4a <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aee:	83 c0 14             	add    $0x14,%eax
80103af1:	0f b6 00             	movzbl (%eax),%eax
80103af4:	0f b6 c0             	movzbl %al,%eax
80103af7:	89 c2                	mov    %eax,%edx
80103af9:	c1 e2 08             	shl    $0x8,%edx
80103afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aff:	83 c0 13             	add    $0x13,%eax
80103b02:	0f b6 00             	movzbl (%eax),%eax
80103b05:	0f b6 c0             	movzbl %al,%eax
80103b08:	09 d0                	or     %edx,%eax
80103b0a:	c1 e0 0a             	shl    $0xa,%eax
80103b0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b13:	2d 00 04 00 00       	sub    $0x400,%eax
80103b18:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b1f:	00 
80103b20:	89 04 24             	mov    %eax,(%esp)
80103b23:	e8 f7 fe ff ff       	call   80103a1f <mpsearch1>
80103b28:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b2b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b2f:	74 05                	je     80103b36 <mpsearch+0xa4>
      return mp;
80103b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b34:	eb 14                	jmp    80103b4a <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b36:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b3d:	00 
80103b3e:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b45:	e8 d5 fe ff ff       	call   80103a1f <mpsearch1>
}
80103b4a:	c9                   	leave  
80103b4b:	c3                   	ret    

80103b4c <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b4c:	55                   	push   %ebp
80103b4d:	89 e5                	mov    %esp,%ebp
80103b4f:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b52:	e8 3b ff ff ff       	call   80103a92 <mpsearch>
80103b57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b5e:	74 0a                	je     80103b6a <mpconfig+0x1e>
80103b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b63:	8b 40 04             	mov    0x4(%eax),%eax
80103b66:	85 c0                	test   %eax,%eax
80103b68:	75 0a                	jne    80103b74 <mpconfig+0x28>
    return 0;
80103b6a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b6f:	e9 83 00 00 00       	jmp    80103bf7 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b77:	8b 40 04             	mov    0x4(%eax),%eax
80103b7a:	89 04 24             	mov    %eax,(%esp)
80103b7d:	e8 f2 fd ff ff       	call   80103974 <p2v>
80103b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b85:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b8c:	00 
80103b8d:	c7 44 24 04 a1 89 10 	movl   $0x801089a1,0x4(%esp)
80103b94:	80 
80103b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b98:	89 04 24             	mov    %eax,(%esp)
80103b9b:	e8 e5 17 00 00       	call   80105385 <memcmp>
80103ba0:	85 c0                	test   %eax,%eax
80103ba2:	74 07                	je     80103bab <mpconfig+0x5f>
    return 0;
80103ba4:	b8 00 00 00 00       	mov    $0x0,%eax
80103ba9:	eb 4c                	jmp    80103bf7 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bae:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bb2:	3c 01                	cmp    $0x1,%al
80103bb4:	74 12                	je     80103bc8 <mpconfig+0x7c>
80103bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb9:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bbd:	3c 04                	cmp    $0x4,%al
80103bbf:	74 07                	je     80103bc8 <mpconfig+0x7c>
    return 0;
80103bc1:	b8 00 00 00 00       	mov    $0x0,%eax
80103bc6:	eb 2f                	jmp    80103bf7 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bcb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bcf:	0f b7 c0             	movzwl %ax,%eax
80103bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd9:	89 04 24             	mov    %eax,(%esp)
80103bdc:	e8 08 fe ff ff       	call   801039e9 <sum>
80103be1:	84 c0                	test   %al,%al
80103be3:	74 07                	je     80103bec <mpconfig+0xa0>
    return 0;
80103be5:	b8 00 00 00 00       	mov    $0x0,%eax
80103bea:	eb 0b                	jmp    80103bf7 <mpconfig+0xab>
  *pmp = mp;
80103bec:	8b 45 08             	mov    0x8(%ebp),%eax
80103bef:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bf2:	89 10                	mov    %edx,(%eax)
  return conf;
80103bf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bf7:	c9                   	leave  
80103bf8:	c3                   	ret    

80103bf9 <mpinit>:

void
mpinit(void)
{
80103bf9:	55                   	push   %ebp
80103bfa:	89 e5                	mov    %esp,%ebp
80103bfc:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103bff:	c7 05 44 b6 10 80 40 	movl   $0x8010f940,0x8010b644
80103c06:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103c09:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c0c:	89 04 24             	mov    %eax,(%esp)
80103c0f:	e8 38 ff ff ff       	call   80103b4c <mpconfig>
80103c14:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c1b:	0f 84 9c 01 00 00    	je     80103dbd <mpinit+0x1c4>
    return;
  ismp = 1;
80103c21:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
80103c28:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c2e:	8b 40 24             	mov    0x24(%eax),%eax
80103c31:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c39:	83 c0 2c             	add    $0x2c,%eax
80103c3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c42:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c46:	0f b7 c0             	movzwl %ax,%eax
80103c49:	03 45 f0             	add    -0x10(%ebp),%eax
80103c4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c4f:	e9 f4 00 00 00       	jmp    80103d48 <mpinit+0x14f>
    switch(*p){
80103c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c57:	0f b6 00             	movzbl (%eax),%eax
80103c5a:	0f b6 c0             	movzbl %al,%eax
80103c5d:	83 f8 04             	cmp    $0x4,%eax
80103c60:	0f 87 bf 00 00 00    	ja     80103d25 <mpinit+0x12c>
80103c66:	8b 04 85 e4 89 10 80 	mov    -0x7fef761c(,%eax,4),%eax
80103c6d:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c72:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c75:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c78:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c7c:	0f b6 d0             	movzbl %al,%edx
80103c7f:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c84:	39 c2                	cmp    %eax,%edx
80103c86:	74 2d                	je     80103cb5 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c88:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c8b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c8f:	0f b6 d0             	movzbl %al,%edx
80103c92:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c97:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c9f:	c7 04 24 a6 89 10 80 	movl   $0x801089a6,(%esp)
80103ca6:	e8 f6 c6 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103cab:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103cb2:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103cb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cb8:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103cbc:	0f b6 c0             	movzbl %al,%eax
80103cbf:	83 e0 02             	and    $0x2,%eax
80103cc2:	85 c0                	test   %eax,%eax
80103cc4:	74 15                	je     80103cdb <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103cc6:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103ccb:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103cd1:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103cd6:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103cdb:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
80103ce1:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103ce6:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103cec:	81 c2 40 f9 10 80    	add    $0x8010f940,%edx
80103cf2:	88 02                	mov    %al,(%edx)
      ncpu++;
80103cf4:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103cf9:	83 c0 01             	add    $0x1,%eax
80103cfc:	a3 20 ff 10 80       	mov    %eax,0x8010ff20
      p += sizeof(struct mpproc);
80103d01:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d05:	eb 41                	jmp    80103d48 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d10:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d14:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
80103d19:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d1d:	eb 29                	jmp    80103d48 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d1f:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d23:	eb 23                	jmp    80103d48 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d28:	0f b6 00             	movzbl (%eax),%eax
80103d2b:	0f b6 c0             	movzbl %al,%eax
80103d2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d32:	c7 04 24 c4 89 10 80 	movl   $0x801089c4,(%esp)
80103d39:	e8 63 c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103d3e:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103d45:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d4e:	0f 82 00 ff ff ff    	jb     80103c54 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d54:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80103d59:	85 c0                	test   %eax,%eax
80103d5b:	75 1d                	jne    80103d7a <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d5d:	c7 05 20 ff 10 80 01 	movl   $0x1,0x8010ff20
80103d64:	00 00 00 
    lapic = 0;
80103d67:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
80103d6e:	00 00 00 
    ioapicid = 0;
80103d71:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
    return;
80103d78:	eb 44                	jmp    80103dbe <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d7d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d81:	84 c0                	test   %al,%al
80103d83:	74 39                	je     80103dbe <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d85:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d8c:	00 
80103d8d:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d94:	e8 12 fc ff ff       	call   801039ab <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d99:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103da0:	e8 dc fb ff ff       	call   80103981 <inb>
80103da5:	83 c8 01             	or     $0x1,%eax
80103da8:	0f b6 c0             	movzbl %al,%eax
80103dab:	89 44 24 04          	mov    %eax,0x4(%esp)
80103daf:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103db6:	e8 f0 fb ff ff       	call   801039ab <outb>
80103dbb:	eb 01                	jmp    80103dbe <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103dbd:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103dbe:	c9                   	leave  
80103dbf:	c3                   	ret    

80103dc0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103dc0:	55                   	push   %ebp
80103dc1:	89 e5                	mov    %esp,%ebp
80103dc3:	83 ec 08             	sub    $0x8,%esp
80103dc6:	8b 55 08             	mov    0x8(%ebp),%edx
80103dc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dcc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103dd0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103dd3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103dd7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ddb:	ee                   	out    %al,(%dx)
}
80103ddc:	c9                   	leave  
80103ddd:	c3                   	ret    

80103dde <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103dde:	55                   	push   %ebp
80103ddf:	89 e5                	mov    %esp,%ebp
80103de1:	83 ec 0c             	sub    $0xc,%esp
80103de4:	8b 45 08             	mov    0x8(%ebp),%eax
80103de7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103deb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103def:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103df5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103df9:	0f b6 c0             	movzbl %al,%eax
80103dfc:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e00:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e07:	e8 b4 ff ff ff       	call   80103dc0 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103e0c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e10:	66 c1 e8 08          	shr    $0x8,%ax
80103e14:	0f b6 c0             	movzbl %al,%eax
80103e17:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e1b:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e22:	e8 99 ff ff ff       	call   80103dc0 <outb>
}
80103e27:	c9                   	leave  
80103e28:	c3                   	ret    

80103e29 <picenable>:

void
picenable(int irq)
{
80103e29:	55                   	push   %ebp
80103e2a:	89 e5                	mov    %esp,%ebp
80103e2c:	53                   	push   %ebx
80103e2d:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e30:	8b 45 08             	mov    0x8(%ebp),%eax
80103e33:	ba 01 00 00 00       	mov    $0x1,%edx
80103e38:	89 d3                	mov    %edx,%ebx
80103e3a:	89 c1                	mov    %eax,%ecx
80103e3c:	d3 e3                	shl    %cl,%ebx
80103e3e:	89 d8                	mov    %ebx,%eax
80103e40:	89 c2                	mov    %eax,%edx
80103e42:	f7 d2                	not    %edx
80103e44:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e4b:	21 d0                	and    %edx,%eax
80103e4d:	0f b7 c0             	movzwl %ax,%eax
80103e50:	89 04 24             	mov    %eax,(%esp)
80103e53:	e8 86 ff ff ff       	call   80103dde <picsetmask>
}
80103e58:	83 c4 04             	add    $0x4,%esp
80103e5b:	5b                   	pop    %ebx
80103e5c:	5d                   	pop    %ebp
80103e5d:	c3                   	ret    

80103e5e <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e5e:	55                   	push   %ebp
80103e5f:	89 e5                	mov    %esp,%ebp
80103e61:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e64:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e6b:	00 
80103e6c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e73:	e8 48 ff ff ff       	call   80103dc0 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e78:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e7f:	00 
80103e80:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e87:	e8 34 ff ff ff       	call   80103dc0 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e8c:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e93:	00 
80103e94:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e9b:	e8 20 ff ff ff       	call   80103dc0 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103ea0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103ea7:	00 
80103ea8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eaf:	e8 0c ff ff ff       	call   80103dc0 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103eb4:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103ebb:	00 
80103ebc:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ec3:	e8 f8 fe ff ff       	call   80103dc0 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103ec8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ecf:	00 
80103ed0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ed7:	e8 e4 fe ff ff       	call   80103dc0 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103edc:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ee3:	00 
80103ee4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103eeb:	e8 d0 fe ff ff       	call   80103dc0 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103ef0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103ef7:	00 
80103ef8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eff:	e8 bc fe ff ff       	call   80103dc0 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f04:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103f0b:	00 
80103f0c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f13:	e8 a8 fe ff ff       	call   80103dc0 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f18:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f1f:	00 
80103f20:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f27:	e8 94 fe ff ff       	call   80103dc0 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f2c:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f33:	00 
80103f34:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f3b:	e8 80 fe ff ff       	call   80103dc0 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f40:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f47:	00 
80103f48:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f4f:	e8 6c fe ff ff       	call   80103dc0 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f54:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f5b:	00 
80103f5c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f63:	e8 58 fe ff ff       	call   80103dc0 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f68:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f6f:	00 
80103f70:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f77:	e8 44 fe ff ff       	call   80103dc0 <outb>

  if(irqmask != 0xFFFF)
80103f7c:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f83:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f87:	74 12                	je     80103f9b <picinit+0x13d>
    picsetmask(irqmask);
80103f89:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f90:	0f b7 c0             	movzwl %ax,%eax
80103f93:	89 04 24             	mov    %eax,(%esp)
80103f96:	e8 43 fe ff ff       	call   80103dde <picsetmask>
}
80103f9b:	c9                   	leave  
80103f9c:	c3                   	ret    
80103f9d:	00 00                	add    %al,(%eax)
	...

80103fa0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fa0:	55                   	push   %ebp
80103fa1:	89 e5                	mov    %esp,%ebp
80103fa3:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103fa6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fad:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fb0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fb9:	8b 10                	mov    (%eax),%edx
80103fbb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbe:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fc0:	e8 bf d2 ff ff       	call   80101284 <filealloc>
80103fc5:	8b 55 08             	mov    0x8(%ebp),%edx
80103fc8:	89 02                	mov    %eax,(%edx)
80103fca:	8b 45 08             	mov    0x8(%ebp),%eax
80103fcd:	8b 00                	mov    (%eax),%eax
80103fcf:	85 c0                	test   %eax,%eax
80103fd1:	0f 84 c8 00 00 00    	je     8010409f <pipealloc+0xff>
80103fd7:	e8 a8 d2 ff ff       	call   80101284 <filealloc>
80103fdc:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fdf:	89 02                	mov    %eax,(%edx)
80103fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe4:	8b 00                	mov    (%eax),%eax
80103fe6:	85 c0                	test   %eax,%eax
80103fe8:	0f 84 b1 00 00 00    	je     8010409f <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103fee:	e8 74 ee ff ff       	call   80102e67 <kalloc>
80103ff3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ff6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ffa:	0f 84 9e 00 00 00    	je     8010409e <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80104000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104003:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010400a:	00 00 00 
  p->writeopen = 1;
8010400d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104010:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104017:	00 00 00 
  p->nwrite = 0;
8010401a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401d:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104024:	00 00 00 
  p->nread = 0;
80104027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402a:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104031:	00 00 00 
  initlock(&p->lock, "pipe");
80104034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104037:	c7 44 24 04 f8 89 10 	movl   $0x801089f8,0x4(%esp)
8010403e:	80 
8010403f:	89 04 24             	mov    %eax,(%esp)
80104042:	e8 57 10 00 00       	call   8010509e <initlock>
  (*f0)->type = FD_PIPE;
80104047:	8b 45 08             	mov    0x8(%ebp),%eax
8010404a:	8b 00                	mov    (%eax),%eax
8010404c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104052:	8b 45 08             	mov    0x8(%ebp),%eax
80104055:	8b 00                	mov    (%eax),%eax
80104057:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010405b:	8b 45 08             	mov    0x8(%ebp),%eax
8010405e:	8b 00                	mov    (%eax),%eax
80104060:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104064:	8b 45 08             	mov    0x8(%ebp),%eax
80104067:	8b 00                	mov    (%eax),%eax
80104069:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010406c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010406f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104072:	8b 00                	mov    (%eax),%eax
80104074:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010407a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010407d:	8b 00                	mov    (%eax),%eax
8010407f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104083:	8b 45 0c             	mov    0xc(%ebp),%eax
80104086:	8b 00                	mov    (%eax),%eax
80104088:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010408c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408f:	8b 00                	mov    (%eax),%eax
80104091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104094:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104097:	b8 00 00 00 00       	mov    $0x0,%eax
8010409c:	eb 43                	jmp    801040e1 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010409e:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010409f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040a3:	74 0b                	je     801040b0 <pipealloc+0x110>
    kfree((char*)p);
801040a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a8:	89 04 24             	mov    %eax,(%esp)
801040ab:	e8 1e ed ff ff       	call   80102dce <kfree>
  if(*f0)
801040b0:	8b 45 08             	mov    0x8(%ebp),%eax
801040b3:	8b 00                	mov    (%eax),%eax
801040b5:	85 c0                	test   %eax,%eax
801040b7:	74 0d                	je     801040c6 <pipealloc+0x126>
    fileclose(*f0);
801040b9:	8b 45 08             	mov    0x8(%ebp),%eax
801040bc:	8b 00                	mov    (%eax),%eax
801040be:	89 04 24             	mov    %eax,(%esp)
801040c1:	e8 66 d2 ff ff       	call   8010132c <fileclose>
  if(*f1)
801040c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c9:	8b 00                	mov    (%eax),%eax
801040cb:	85 c0                	test   %eax,%eax
801040cd:	74 0d                	je     801040dc <pipealloc+0x13c>
    fileclose(*f1);
801040cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801040d2:	8b 00                	mov    (%eax),%eax
801040d4:	89 04 24             	mov    %eax,(%esp)
801040d7:	e8 50 d2 ff ff       	call   8010132c <fileclose>
  return -1;
801040dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040e1:	c9                   	leave  
801040e2:	c3                   	ret    

801040e3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040e3:	55                   	push   %ebp
801040e4:	89 e5                	mov    %esp,%ebp
801040e6:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801040e9:	8b 45 08             	mov    0x8(%ebp),%eax
801040ec:	89 04 24             	mov    %eax,(%esp)
801040ef:	e8 cb 0f 00 00       	call   801050bf <acquire>
  if(writable){
801040f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801040f8:	74 1f                	je     80104119 <pipeclose+0x36>
    p->writeopen = 0;
801040fa:	8b 45 08             	mov    0x8(%ebp),%eax
801040fd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104104:	00 00 00 
    wakeup(&p->nread);
80104107:	8b 45 08             	mov    0x8(%ebp),%eax
8010410a:	05 34 02 00 00       	add    $0x234,%eax
8010410f:	89 04 24             	mov    %eax,(%esp)
80104112:	e8 9f 0d 00 00       	call   80104eb6 <wakeup>
80104117:	eb 1d                	jmp    80104136 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104119:	8b 45 08             	mov    0x8(%ebp),%eax
8010411c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104123:	00 00 00 
    wakeup(&p->nwrite);
80104126:	8b 45 08             	mov    0x8(%ebp),%eax
80104129:	05 38 02 00 00       	add    $0x238,%eax
8010412e:	89 04 24             	mov    %eax,(%esp)
80104131:	e8 80 0d 00 00       	call   80104eb6 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104136:	8b 45 08             	mov    0x8(%ebp),%eax
80104139:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010413f:	85 c0                	test   %eax,%eax
80104141:	75 25                	jne    80104168 <pipeclose+0x85>
80104143:	8b 45 08             	mov    0x8(%ebp),%eax
80104146:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010414c:	85 c0                	test   %eax,%eax
8010414e:	75 18                	jne    80104168 <pipeclose+0x85>
    release(&p->lock);
80104150:	8b 45 08             	mov    0x8(%ebp),%eax
80104153:	89 04 24             	mov    %eax,(%esp)
80104156:	e8 c6 0f 00 00       	call   80105121 <release>
    kfree((char*)p);
8010415b:	8b 45 08             	mov    0x8(%ebp),%eax
8010415e:	89 04 24             	mov    %eax,(%esp)
80104161:	e8 68 ec ff ff       	call   80102dce <kfree>
80104166:	eb 0b                	jmp    80104173 <pipeclose+0x90>
  } else
    release(&p->lock);
80104168:	8b 45 08             	mov    0x8(%ebp),%eax
8010416b:	89 04 24             	mov    %eax,(%esp)
8010416e:	e8 ae 0f 00 00       	call   80105121 <release>
}
80104173:	c9                   	leave  
80104174:	c3                   	ret    

80104175 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104175:	55                   	push   %ebp
80104176:	89 e5                	mov    %esp,%ebp
80104178:	53                   	push   %ebx
80104179:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010417c:	8b 45 08             	mov    0x8(%ebp),%eax
8010417f:	89 04 24             	mov    %eax,(%esp)
80104182:	e8 38 0f 00 00       	call   801050bf <acquire>
  for(i = 0; i < n; i++){
80104187:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010418e:	e9 a6 00 00 00       	jmp    80104239 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104193:	8b 45 08             	mov    0x8(%ebp),%eax
80104196:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010419c:	85 c0                	test   %eax,%eax
8010419e:	74 0d                	je     801041ad <pipewrite+0x38>
801041a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041a6:	8b 40 24             	mov    0x24(%eax),%eax
801041a9:	85 c0                	test   %eax,%eax
801041ab:	74 15                	je     801041c2 <pipewrite+0x4d>
        release(&p->lock);
801041ad:	8b 45 08             	mov    0x8(%ebp),%eax
801041b0:	89 04 24             	mov    %eax,(%esp)
801041b3:	e8 69 0f 00 00       	call   80105121 <release>
        return -1;
801041b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041bd:	e9 9d 00 00 00       	jmp    8010425f <pipewrite+0xea>
      }
      wakeup(&p->nread);
801041c2:	8b 45 08             	mov    0x8(%ebp),%eax
801041c5:	05 34 02 00 00       	add    $0x234,%eax
801041ca:	89 04 24             	mov    %eax,(%esp)
801041cd:	e8 e4 0c 00 00       	call   80104eb6 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041d2:	8b 45 08             	mov    0x8(%ebp),%eax
801041d5:	8b 55 08             	mov    0x8(%ebp),%edx
801041d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801041de:	89 44 24 04          	mov    %eax,0x4(%esp)
801041e2:	89 14 24             	mov    %edx,(%esp)
801041e5:	e8 f0 0b 00 00       	call   80104dda <sleep>
801041ea:	eb 01                	jmp    801041ed <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041ec:	90                   	nop
801041ed:	8b 45 08             	mov    0x8(%ebp),%eax
801041f0:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041f6:	8b 45 08             	mov    0x8(%ebp),%eax
801041f9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041ff:	05 00 02 00 00       	add    $0x200,%eax
80104204:	39 c2                	cmp    %eax,%edx
80104206:	74 8b                	je     80104193 <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104208:	8b 45 08             	mov    0x8(%ebp),%eax
8010420b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104211:	89 c3                	mov    %eax,%ebx
80104213:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104219:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010421c:	03 55 0c             	add    0xc(%ebp),%edx
8010421f:	0f b6 0a             	movzbl (%edx),%ecx
80104222:	8b 55 08             	mov    0x8(%ebp),%edx
80104225:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104229:	8d 50 01             	lea    0x1(%eax),%edx
8010422c:	8b 45 08             	mov    0x8(%ebp),%eax
8010422f:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104235:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010423c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010423f:	7c ab                	jl     801041ec <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104241:	8b 45 08             	mov    0x8(%ebp),%eax
80104244:	05 34 02 00 00       	add    $0x234,%eax
80104249:	89 04 24             	mov    %eax,(%esp)
8010424c:	e8 65 0c 00 00       	call   80104eb6 <wakeup>
  release(&p->lock);
80104251:	8b 45 08             	mov    0x8(%ebp),%eax
80104254:	89 04 24             	mov    %eax,(%esp)
80104257:	e8 c5 0e 00 00       	call   80105121 <release>
  return n;
8010425c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010425f:	83 c4 24             	add    $0x24,%esp
80104262:	5b                   	pop    %ebx
80104263:	5d                   	pop    %ebp
80104264:	c3                   	ret    

80104265 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104265:	55                   	push   %ebp
80104266:	89 e5                	mov    %esp,%ebp
80104268:	53                   	push   %ebx
80104269:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010426c:	8b 45 08             	mov    0x8(%ebp),%eax
8010426f:	89 04 24             	mov    %eax,(%esp)
80104272:	e8 48 0e 00 00       	call   801050bf <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104277:	eb 3a                	jmp    801042b3 <piperead+0x4e>
    if(proc->killed){
80104279:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010427f:	8b 40 24             	mov    0x24(%eax),%eax
80104282:	85 c0                	test   %eax,%eax
80104284:	74 15                	je     8010429b <piperead+0x36>
      release(&p->lock);
80104286:	8b 45 08             	mov    0x8(%ebp),%eax
80104289:	89 04 24             	mov    %eax,(%esp)
8010428c:	e8 90 0e 00 00       	call   80105121 <release>
      return -1;
80104291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104296:	e9 b6 00 00 00       	jmp    80104351 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010429b:	8b 45 08             	mov    0x8(%ebp),%eax
8010429e:	8b 55 08             	mov    0x8(%ebp),%edx
801042a1:	81 c2 34 02 00 00    	add    $0x234,%edx
801042a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801042ab:	89 14 24             	mov    %edx,(%esp)
801042ae:	e8 27 0b 00 00       	call   80104dda <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042b3:	8b 45 08             	mov    0x8(%ebp),%eax
801042b6:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042bc:	8b 45 08             	mov    0x8(%ebp),%eax
801042bf:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042c5:	39 c2                	cmp    %eax,%edx
801042c7:	75 0d                	jne    801042d6 <piperead+0x71>
801042c9:	8b 45 08             	mov    0x8(%ebp),%eax
801042cc:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042d2:	85 c0                	test   %eax,%eax
801042d4:	75 a3                	jne    80104279 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042dd:	eb 49                	jmp    80104328 <piperead+0xc3>
    if(p->nread == p->nwrite)
801042df:	8b 45 08             	mov    0x8(%ebp),%eax
801042e2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042e8:	8b 45 08             	mov    0x8(%ebp),%eax
801042eb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042f1:	39 c2                	cmp    %eax,%edx
801042f3:	74 3d                	je     80104332 <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f8:	89 c2                	mov    %eax,%edx
801042fa:	03 55 0c             	add    0xc(%ebp),%edx
801042fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104300:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104306:	89 c3                	mov    %eax,%ebx
80104308:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
8010430e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104311:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80104316:	88 0a                	mov    %cl,(%edx)
80104318:	8d 50 01             	lea    0x1(%eax),%edx
8010431b:	8b 45 08             	mov    0x8(%ebp),%eax
8010431e:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104324:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010432e:	7c af                	jl     801042df <piperead+0x7a>
80104330:	eb 01                	jmp    80104333 <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
80104332:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104333:	8b 45 08             	mov    0x8(%ebp),%eax
80104336:	05 38 02 00 00       	add    $0x238,%eax
8010433b:	89 04 24             	mov    %eax,(%esp)
8010433e:	e8 73 0b 00 00       	call   80104eb6 <wakeup>
  release(&p->lock);
80104343:	8b 45 08             	mov    0x8(%ebp),%eax
80104346:	89 04 24             	mov    %eax,(%esp)
80104349:	e8 d3 0d 00 00       	call   80105121 <release>
  return i;
8010434e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104351:	83 c4 24             	add    $0x24,%esp
80104354:	5b                   	pop    %ebx
80104355:	5d                   	pop    %ebp
80104356:	c3                   	ret    
	...

80104358 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104358:	55                   	push   %ebp
80104359:	89 e5                	mov    %esp,%ebp
8010435b:	53                   	push   %ebx
8010435c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010435f:	9c                   	pushf  
80104360:	5b                   	pop    %ebx
80104361:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104364:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104367:	83 c4 10             	add    $0x10,%esp
8010436a:	5b                   	pop    %ebx
8010436b:	5d                   	pop    %ebp
8010436c:	c3                   	ret    

8010436d <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010436d:	55                   	push   %ebp
8010436e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104370:	fb                   	sti    
}
80104371:	5d                   	pop    %ebp
80104372:	c3                   	ret    

80104373 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104373:	55                   	push   %ebp
80104374:	89 e5                	mov    %esp,%ebp
80104376:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104379:	c7 44 24 04 fd 89 10 	movl   $0x801089fd,0x4(%esp)
80104380:	80 
80104381:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104388:	e8 11 0d 00 00       	call   8010509e <initlock>
}
8010438d:	c9                   	leave  
8010438e:	c3                   	ret    

8010438f <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010438f:	55                   	push   %ebp
80104390:	89 e5                	mov    %esp,%ebp
80104392:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104395:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010439c:	e8 1e 0d 00 00       	call   801050bf <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a1:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
801043a8:	eb 11                	jmp    801043bb <allocproc+0x2c>
    if(p->state == UNUSED)
801043aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ad:	8b 40 0c             	mov    0xc(%eax),%eax
801043b0:	85 c0                	test   %eax,%eax
801043b2:	74 26                	je     801043da <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043b4:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801043bb:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
801043c2:	72 e6                	jb     801043aa <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801043c4:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801043cb:	e8 51 0d 00 00       	call   80105121 <release>
  return 0;
801043d0:	b8 00 00 00 00       	mov    $0x0,%eax
801043d5:	e9 b5 00 00 00       	jmp    8010448f <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801043da:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043de:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043e5:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801043ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ed:	89 42 10             	mov    %eax,0x10(%edx)
801043f0:	83 c0 01             	add    $0x1,%eax
801043f3:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
801043f8:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801043ff:	e8 1d 0d 00 00       	call   80105121 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104404:	e8 5e ea ff ff       	call   80102e67 <kalloc>
80104409:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010440c:	89 42 08             	mov    %eax,0x8(%edx)
8010440f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104412:	8b 40 08             	mov    0x8(%eax),%eax
80104415:	85 c0                	test   %eax,%eax
80104417:	75 11                	jne    8010442a <allocproc+0x9b>
    p->state = UNUSED;
80104419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104423:	b8 00 00 00 00       	mov    $0x0,%eax
80104428:	eb 65                	jmp    8010448f <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
8010442a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442d:	8b 40 08             	mov    0x8(%eax),%eax
80104430:	05 00 10 00 00       	add    $0x1000,%eax
80104435:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104438:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010443c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104442:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104445:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104449:	ba c4 67 10 80       	mov    $0x801067c4,%edx
8010444e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104451:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104453:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010445d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104463:	8b 40 1c             	mov    0x1c(%eax),%eax
80104466:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010446d:	00 
8010446e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104475:	00 
80104476:	89 04 24             	mov    %eax,(%esp)
80104479:	e8 90 0e 00 00       	call   8010530e <memset>
  p->context->eip = (uint)forkret;
8010447e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104481:	8b 40 1c             	mov    0x1c(%eax),%eax
80104484:	ba ae 4d 10 80       	mov    $0x80104dae,%edx
80104489:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010448c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010448f:	c9                   	leave  
80104490:	c3                   	ret    

80104491 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104491:	55                   	push   %ebp
80104492:	89 e5                	mov    %esp,%ebp
80104494:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104497:	e8 f3 fe ff ff       	call   8010438f <allocproc>
8010449c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010449f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a2:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm(kalloc)) == 0)
801044a7:	c7 04 24 67 2e 10 80 	movl   $0x80102e67,(%esp)
801044ae:	e8 2e 3a 00 00       	call   80107ee1 <setupkvm>
801044b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044b6:	89 42 04             	mov    %eax,0x4(%edx)
801044b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bc:	8b 40 04             	mov    0x4(%eax),%eax
801044bf:	85 c0                	test   %eax,%eax
801044c1:	75 0c                	jne    801044cf <userinit+0x3e>
    panic("userinit: out of memory?");
801044c3:	c7 04 24 04 8a 10 80 	movl   $0x80108a04,(%esp)
801044ca:	e8 6e c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044cf:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d7:	8b 40 04             	mov    0x4(%eax),%eax
801044da:	89 54 24 08          	mov    %edx,0x8(%esp)
801044de:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801044e5:	80 
801044e6:	89 04 24             	mov    %eax,(%esp)
801044e9:	e8 4b 3c 00 00       	call   80108139 <inituvm>
  p->sz = PGSIZE;
801044ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f1:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fa:	8b 40 18             	mov    0x18(%eax),%eax
801044fd:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104504:	00 
80104505:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010450c:	00 
8010450d:	89 04 24             	mov    %eax,(%esp)
80104510:	e8 f9 0d 00 00       	call   8010530e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104518:	8b 40 18             	mov    0x18(%eax),%eax
8010451b:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104524:	8b 40 18             	mov    0x18(%eax),%eax
80104527:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010452d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104530:	8b 40 18             	mov    0x18(%eax),%eax
80104533:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104536:	8b 52 18             	mov    0x18(%edx),%edx
80104539:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010453d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104544:	8b 40 18             	mov    0x18(%eax),%eax
80104547:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010454a:	8b 52 18             	mov    0x18(%edx),%edx
8010454d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104551:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104558:	8b 40 18             	mov    0x18(%eax),%eax
8010455b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104565:	8b 40 18             	mov    0x18(%eax),%eax
80104568:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010456f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104572:	8b 40 18             	mov    0x18(%eax),%eax
80104575:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010457c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457f:	83 c0 6c             	add    $0x6c,%eax
80104582:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104589:	00 
8010458a:	c7 44 24 04 1d 8a 10 	movl   $0x80108a1d,0x4(%esp)
80104591:	80 
80104592:	89 04 24             	mov    %eax,(%esp)
80104595:	e8 a4 0f 00 00       	call   8010553e <safestrcpy>
  p->cwd = namei("/");
8010459a:	c7 04 24 26 8a 10 80 	movl   $0x80108a26,(%esp)
801045a1:	e8 cc e1 ff ff       	call   80102772 <namei>
801045a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045a9:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801045ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045af:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045b6:	c9                   	leave  
801045b7:	c3                   	ret    

801045b8 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045b8:	55                   	push   %ebp
801045b9:	89 e5                	mov    %esp,%ebp
801045bb:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045c4:	8b 00                	mov    (%eax),%eax
801045c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045cd:	7e 34                	jle    80104603 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045cf:	8b 45 08             	mov    0x8(%ebp),%eax
801045d2:	89 c2                	mov    %eax,%edx
801045d4:	03 55 f4             	add    -0xc(%ebp),%edx
801045d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045dd:	8b 40 04             	mov    0x4(%eax),%eax
801045e0:	89 54 24 08          	mov    %edx,0x8(%esp)
801045e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045e7:	89 54 24 04          	mov    %edx,0x4(%esp)
801045eb:	89 04 24             	mov    %eax,(%esp)
801045ee:	e8 c0 3c 00 00       	call   801082b3 <allocuvm>
801045f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045fa:	75 41                	jne    8010463d <growproc+0x85>
      return -1;
801045fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104601:	eb 58                	jmp    8010465b <growproc+0xa3>
  } else if(n < 0){
80104603:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104607:	79 34                	jns    8010463d <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104609:	8b 45 08             	mov    0x8(%ebp),%eax
8010460c:	89 c2                	mov    %eax,%edx
8010460e:	03 55 f4             	add    -0xc(%ebp),%edx
80104611:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104617:	8b 40 04             	mov    0x4(%eax),%eax
8010461a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010461e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104621:	89 54 24 04          	mov    %edx,0x4(%esp)
80104625:	89 04 24             	mov    %eax,(%esp)
80104628:	e8 60 3d 00 00       	call   8010838d <deallocuvm>
8010462d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104630:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104634:	75 07                	jne    8010463d <growproc+0x85>
      return -1;
80104636:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010463b:	eb 1e                	jmp    8010465b <growproc+0xa3>
  }
  proc->sz = sz;
8010463d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104643:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104646:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104648:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010464e:	89 04 24             	mov    %eax,(%esp)
80104651:	e8 7c 39 00 00       	call   80107fd2 <switchuvm>
  return 0;
80104656:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010465b:	c9                   	leave  
8010465c:	c3                   	ret    

8010465d <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010465d:	55                   	push   %ebp
8010465e:	89 e5                	mov    %esp,%ebp
80104660:	57                   	push   %edi
80104661:	56                   	push   %esi
80104662:	53                   	push   %ebx
80104663:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104666:	e8 24 fd ff ff       	call   8010438f <allocproc>
8010466b:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010466e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104672:	75 0a                	jne    8010467e <fork+0x21>
    return -1;
80104674:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104679:	e9 6c 01 00 00       	jmp    801047ea <fork+0x18d>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010467e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104684:	8b 10                	mov    (%eax),%edx
80104686:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010468c:	8b 40 04             	mov    0x4(%eax),%eax
8010468f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104693:	89 04 24             	mov    %eax,(%esp)
80104696:	e8 82 3e 00 00       	call   8010851d <copyuvm>
8010469b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010469e:	89 42 04             	mov    %eax,0x4(%edx)
801046a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a4:	8b 40 04             	mov    0x4(%eax),%eax
801046a7:	85 c0                	test   %eax,%eax
801046a9:	75 2c                	jne    801046d7 <fork+0x7a>
    kfree(np->kstack);
801046ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ae:	8b 40 08             	mov    0x8(%eax),%eax
801046b1:	89 04 24             	mov    %eax,(%esp)
801046b4:	e8 15 e7 ff ff       	call   80102dce <kfree>
    np->kstack = 0;
801046b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046bc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046d2:	e9 13 01 00 00       	jmp    801047ea <fork+0x18d>
  }
  np->sz = proc->sz;
801046d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046dd:	8b 10                	mov    (%eax),%edx
801046df:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e2:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046e4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ee:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f4:	8b 50 18             	mov    0x18(%eax),%edx
801046f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fd:	8b 40 18             	mov    0x18(%eax),%eax
80104700:	89 c3                	mov    %eax,%ebx
80104702:	b8 13 00 00 00       	mov    $0x13,%eax
80104707:	89 d7                	mov    %edx,%edi
80104709:	89 de                	mov    %ebx,%esi
8010470b:	89 c1                	mov    %eax,%ecx
8010470d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010470f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104712:	8b 40 18             	mov    0x18(%eax),%eax
80104715:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010471c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104723:	eb 3d                	jmp    80104762 <fork+0x105>
    if(proc->ofile[i])
80104725:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010472e:	83 c2 08             	add    $0x8,%edx
80104731:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104735:	85 c0                	test   %eax,%eax
80104737:	74 25                	je     8010475e <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104739:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104742:	83 c2 08             	add    $0x8,%edx
80104745:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104749:	89 04 24             	mov    %eax,(%esp)
8010474c:	e8 93 cb ff ff       	call   801012e4 <filedup>
80104751:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104754:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104757:	83 c1 08             	add    $0x8,%ecx
8010475a:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010475e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104762:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104766:	7e bd                	jle    80104725 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104768:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010476e:	8b 40 68             	mov    0x68(%eax),%eax
80104771:	89 04 24             	mov    %eax,(%esp)
80104774:	e8 25 d4 ff ff       	call   80101b9e <idup>
80104779:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010477c:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
8010477f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104782:	8b 40 10             	mov    0x10(%eax),%eax
80104785:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
80104788:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104792:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104798:	8d 50 6c             	lea    0x6c(%eax),%edx
8010479b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479e:	83 c0 6c             	add    $0x6c,%eax
801047a1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801047a8:	00 
801047a9:	89 54 24 04          	mov    %edx,0x4(%esp)
801047ad:	89 04 24             	mov    %eax,(%esp)
801047b0:	e8 89 0d 00 00       	call   8010553e <safestrcpy>
  acquire(&tickslock);
801047b5:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801047bc:	e8 fe 08 00 00       	call   801050bf <acquire>
  np->ctime = ticks;
801047c1:	a1 c0 29 11 80       	mov    0x801129c0,%eax
801047c6:	89 c2                	mov    %eax,%edx
801047c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047cb:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&tickslock);
801047ce:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801047d5:	e8 47 09 00 00       	call   80105121 <release>
  np->rtime = 0;
801047da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047dd:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
801047e4:	00 00 00 
  return pid;
801047e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047ea:	83 c4 2c             	add    $0x2c,%esp
801047ed:	5b                   	pop    %ebx
801047ee:	5e                   	pop    %esi
801047ef:	5f                   	pop    %edi
801047f0:	5d                   	pop    %ebp
801047f1:	c3                   	ret    

801047f2 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047f2:	55                   	push   %ebp
801047f3:	89 e5                	mov    %esp,%ebp
801047f5:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801047f8:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047ff:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104804:	39 c2                	cmp    %eax,%edx
80104806:	75 0c                	jne    80104814 <exit+0x22>
    panic("init exiting");
80104808:	c7 04 24 28 8a 10 80 	movl   $0x80108a28,(%esp)
8010480f:	e8 29 bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104814:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010481b:	eb 44                	jmp    80104861 <exit+0x6f>
    if(proc->ofile[fd]){
8010481d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104823:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104826:	83 c2 08             	add    $0x8,%edx
80104829:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010482d:	85 c0                	test   %eax,%eax
8010482f:	74 2c                	je     8010485d <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104831:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104837:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010483a:	83 c2 08             	add    $0x8,%edx
8010483d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104841:	89 04 24             	mov    %eax,(%esp)
80104844:	e8 e3 ca ff ff       	call   8010132c <fileclose>
      proc->ofile[fd] = 0;
80104849:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010484f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104852:	83 c2 08             	add    $0x8,%edx
80104855:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010485c:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010485d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104861:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104865:	7e b6                	jle    8010481d <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
80104867:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486d:	8b 40 68             	mov    0x68(%eax),%eax
80104870:	89 04 24             	mov    %eax,(%esp)
80104873:	e8 0b d5 ff ff       	call   80101d83 <iput>
  proc->cwd = 0;
80104878:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010487e:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104885:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010488c:	e8 2e 08 00 00       	call   801050bf <acquire>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104891:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104897:	8b 40 14             	mov    0x14(%eax),%eax
8010489a:	89 04 24             	mov    %eax,(%esp)
8010489d:	e8 d3 05 00 00       	call   80104e75 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048a2:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
801048a9:	eb 3b                	jmp    801048e6 <exit+0xf4>
    if(p->parent == proc){
801048ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ae:	8b 50 14             	mov    0x14(%eax),%edx
801048b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b7:	39 c2                	cmp    %eax,%edx
801048b9:	75 24                	jne    801048df <exit+0xed>
      p->parent = initproc;
801048bb:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801048c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c4:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ca:	8b 40 0c             	mov    0xc(%eax),%eax
801048cd:	83 f8 05             	cmp    $0x5,%eax
801048d0:	75 0d                	jne    801048df <exit+0xed>
        wakeup1(initproc);
801048d2:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048d7:	89 04 24             	mov    %eax,(%esp)
801048da:	e8 96 05 00 00       	call   80104e75 <wakeup1>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048df:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801048e6:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
801048ed:	72 bc                	jb     801048ab <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  acquire(&tickslock);
801048ef:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801048f6:	e8 c4 07 00 00       	call   801050bf <acquire>
  proc->etime = ticks;
801048fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104901:	8b 15 c0 29 11 80    	mov    0x801129c0,%edx
80104907:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  release(&tickslock);
8010490d:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80104914:	e8 08 08 00 00       	call   80105121 <release>
  proc->state = ZOMBIE;
80104919:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010491f:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104926:	e8 9f 03 00 00       	call   80104cca <sched>
  panic("zombie exit");
8010492b:	c7 04 24 35 8a 10 80 	movl   $0x80108a35,(%esp)
80104932:	e8 06 bc ff ff       	call   8010053d <panic>

80104937 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104937:	55                   	push   %ebp
80104938:	89 e5                	mov    %esp,%ebp
8010493a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010493d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104944:	e8 76 07 00 00       	call   801050bf <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104949:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104950:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104957:	e9 9d 00 00 00       	jmp    801049f9 <wait+0xc2>
      if(p->parent != proc)
8010495c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495f:	8b 50 14             	mov    0x14(%eax),%edx
80104962:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104968:	39 c2                	cmp    %eax,%edx
8010496a:	0f 85 81 00 00 00    	jne    801049f1 <wait+0xba>
        continue;
      havekids = 1;
80104970:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497a:	8b 40 0c             	mov    0xc(%eax),%eax
8010497d:	83 f8 05             	cmp    $0x5,%eax
80104980:	75 70                	jne    801049f2 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104985:	8b 40 10             	mov    0x10(%eax),%eax
80104988:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010498b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498e:	8b 40 08             	mov    0x8(%eax),%eax
80104991:	89 04 24             	mov    %eax,(%esp)
80104994:	e8 35 e4 ff ff       	call   80102dce <kfree>
        p->kstack = 0;
80104999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801049a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a6:	8b 40 04             	mov    0x4(%eax),%eax
801049a9:	89 04 24             	mov    %eax,(%esp)
801049ac:	e8 98 3a 00 00       	call   80108449 <freevm>
        p->state = UNUSED;
801049b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801049bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049be:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d2:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d9:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801049e0:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801049e7:	e8 35 07 00 00       	call   80105121 <release>
        return pid;
801049ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049ef:	eb 56                	jmp    80104a47 <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801049f1:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049f2:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801049f9:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
80104a00:	0f 82 56 ff ff ff    	jb     8010495c <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104a06:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104a0a:	74 0d                	je     80104a19 <wait+0xe2>
80104a0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a12:	8b 40 24             	mov    0x24(%eax),%eax
80104a15:	85 c0                	test   %eax,%eax
80104a17:	74 13                	je     80104a2c <wait+0xf5>
      release(&ptable.lock);
80104a19:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104a20:	e8 fc 06 00 00       	call   80105121 <release>
      return -1;
80104a25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a2a:	eb 1b                	jmp    80104a47 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104a2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a32:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104a39:	80 
80104a3a:	89 04 24             	mov    %eax,(%esp)
80104a3d:	e8 98 03 00 00       	call   80104dda <sleep>
  }
80104a42:	e9 02 ff ff ff       	jmp    80104949 <wait+0x12>
}
80104a47:	c9                   	leave  
80104a48:	c3                   	ret    

80104a49 <wait2>:

int
wait2(int *wtime, int *rtime)
{
80104a49:	55                   	push   %ebp
80104a4a:	89 e5                	mov    %esp,%ebp
80104a4c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a4f:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104a56:	e8 64 06 00 00       	call   801050bf <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a5b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a62:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104a69:	e9 d0 00 00 00       	jmp    80104b3e <wait2+0xf5>
      if(p->parent != proc)
80104a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a71:	8b 50 14             	mov    0x14(%eax),%edx
80104a74:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a7a:	39 c2                	cmp    %eax,%edx
80104a7c:	0f 85 b4 00 00 00    	jne    80104b36 <wait2+0xed>
        continue;
      havekids = 1;
80104a82:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8c:	8b 40 0c             	mov    0xc(%eax),%eax
80104a8f:	83 f8 05             	cmp    $0x5,%eax
80104a92:	0f 85 9f 00 00 00    	jne    80104b37 <wait2+0xee>
	*rtime = p->rtime;
80104a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9b:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aa4:	89 10                	mov    %edx,(%eax)
	*wtime = p->etime - p->ctime - p->rtime;
80104aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa9:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab2:	8b 40 7c             	mov    0x7c(%eax),%eax
80104ab5:	29 c2                	sub    %eax,%edx
80104ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aba:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104ac0:	29 c2                	sub    %eax,%edx
80104ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ac5:	89 10                	mov    %edx,(%eax)
	// Found one.
        pid = p->pid;
80104ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aca:	8b 40 10             	mov    0x10(%eax),%eax
80104acd:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad3:	8b 40 08             	mov    0x8(%eax),%eax
80104ad6:	89 04 24             	mov    %eax,(%esp)
80104ad9:	e8 f0 e2 ff ff       	call   80102dce <kfree>
        p->kstack = 0;
80104ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aeb:	8b 40 04             	mov    0x4(%eax),%eax
80104aee:	89 04 24             	mov    %eax,(%esp)
80104af1:	e8 53 39 00 00       	call   80108449 <freevm>
        p->state = UNUSED;
80104af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b03:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b17:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1e:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104b25:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104b2c:	e8 f0 05 00 00       	call   80105121 <release>
        return pid;
80104b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b34:	eb 56                	jmp    80104b8c <wait2+0x143>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104b36:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b37:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104b3e:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
80104b45:	0f 82 23 ff ff ff    	jb     80104a6e <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b4f:	74 0d                	je     80104b5e <wait2+0x115>
80104b51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b57:	8b 40 24             	mov    0x24(%eax),%eax
80104b5a:	85 c0                	test   %eax,%eax
80104b5c:	74 13                	je     80104b71 <wait2+0x128>
      release(&ptable.lock);
80104b5e:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104b65:	e8 b7 05 00 00       	call   80105121 <release>
      return -1;
80104b6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b6f:	eb 1b                	jmp    80104b8c <wait2+0x143>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b77:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104b7e:	80 
80104b7f:	89 04 24             	mov    %eax,(%esp)
80104b82:	e8 53 02 00 00       	call   80104dda <sleep>
  }
80104b87:	e9 cf fe ff ff       	jmp    80104a5b <wait2+0x12>
  
  
  return proc->pid;
}
80104b8c:	c9                   	leave  
80104b8d:	c3                   	ret    

80104b8e <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104b8e:	55                   	push   %ebp
80104b8f:	89 e5                	mov    %esp,%ebp
80104b91:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104b94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b9a:	8b 40 18             	mov    0x18(%eax),%eax
80104b9d:	8b 40 44             	mov    0x44(%eax),%eax
80104ba0:	89 c2                	mov    %eax,%edx
80104ba2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba8:	8b 40 04             	mov    0x4(%eax),%eax
80104bab:	89 54 24 04          	mov    %edx,0x4(%esp)
80104baf:	89 04 24             	mov    %eax,(%esp)
80104bb2:	e8 77 3a 00 00       	call   8010862e <uva2ka>
80104bb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104bba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bc0:	8b 40 18             	mov    0x18(%eax),%eax
80104bc3:	8b 40 44             	mov    0x44(%eax),%eax
80104bc6:	25 ff 0f 00 00       	and    $0xfff,%eax
80104bcb:	85 c0                	test   %eax,%eax
80104bcd:	75 0c                	jne    80104bdb <register_handler+0x4d>
    panic("esp_offset == 0");
80104bcf:	c7 04 24 41 8a 10 80 	movl   $0x80108a41,(%esp)
80104bd6:	e8 62 b9 ff ff       	call   8010053d <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
80104bdb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104be1:	8b 40 18             	mov    0x18(%eax),%eax
80104be4:	8b 40 44             	mov    0x44(%eax),%eax
80104be7:	83 e8 04             	sub    $0x4,%eax
80104bea:	25 ff 0f 00 00       	and    $0xfff,%eax
80104bef:	03 45 f4             	add    -0xc(%ebp),%eax
          = proc->tf->eip;
80104bf2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104bf9:	8b 52 18             	mov    0x18(%edx),%edx
80104bfc:	8b 52 38             	mov    0x38(%edx),%edx
80104bff:	89 10                	mov    %edx,(%eax)
  proc->tf->esp -= 4;
80104c01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c07:	8b 40 18             	mov    0x18(%eax),%eax
80104c0a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c11:	8b 52 18             	mov    0x18(%edx),%edx
80104c14:	8b 52 44             	mov    0x44(%edx),%edx
80104c17:	83 ea 04             	sub    $0x4,%edx
80104c1a:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104c1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c23:	8b 40 18             	mov    0x18(%eax),%eax
80104c26:	8b 55 08             	mov    0x8(%ebp),%edx
80104c29:	89 50 38             	mov    %edx,0x38(%eax)
}
80104c2c:	c9                   	leave  
80104c2d:	c3                   	ret    

80104c2e <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c2e:	55                   	push   %ebp
80104c2f:	89 e5                	mov    %esp,%ebp
80104c31:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c34:	e8 34 f7 ff ff       	call   8010436d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c39:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104c40:	e8 7a 04 00 00       	call   801050bf <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c45:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104c4c:	eb 62                	jmp    80104cb0 <scheduler+0x82>
      if(p->state != RUNNABLE)
80104c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c51:	8b 40 0c             	mov    0xc(%eax),%eax
80104c54:	83 f8 03             	cmp    $0x3,%eax
80104c57:	75 4f                	jne    80104ca8 <scheduler+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5c:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
    /*  acquire(&tickslock);
      int time = ticks;
      release(&tickslock);
      */
      switchuvm(p);
80104c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c65:	89 04 24             	mov    %eax,(%esp)
80104c68:	e8 65 33 00 00       	call   80107fd2 <switchuvm>
      p->state = RUNNING;
80104c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c70:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104c77:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c7d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c80:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c87:	83 c2 04             	add    $0x4,%edx
80104c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c8e:	89 14 24             	mov    %edx,(%esp)
80104c91:	e8 1e 09 00 00       	call   801055b4 <swtch>
      switchkvm();
80104c96:	e8 1a 33 00 00       	call   80107fb5 <switchkvm>
      time = ticks - time;
      release(&tickslock);
      p->rtime += time; */
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104c9b:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104ca2:	00 00 00 00 
80104ca6:	eb 01                	jmp    80104ca9 <scheduler+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104ca8:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ca9:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104cb0:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
80104cb7:	72 95                	jb     80104c4e <scheduler+0x20>
      p->rtime += time; */
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104cb9:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104cc0:	e8 5c 04 00 00       	call   80105121 <release>

  }
80104cc5:	e9 6a ff ff ff       	jmp    80104c34 <scheduler+0x6>

80104cca <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104cca:	55                   	push   %ebp
80104ccb:	89 e5                	mov    %esp,%ebp
80104ccd:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104cd0:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104cd7:	e8 01 05 00 00       	call   801051dd <holding>
80104cdc:	85 c0                	test   %eax,%eax
80104cde:	75 0c                	jne    80104cec <sched+0x22>
    panic("sched ptable.lock");
80104ce0:	c7 04 24 51 8a 10 80 	movl   $0x80108a51,(%esp)
80104ce7:	e8 51 b8 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104cec:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cf2:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104cf8:	83 f8 01             	cmp    $0x1,%eax
80104cfb:	74 0c                	je     80104d09 <sched+0x3f>
    panic("sched locks");
80104cfd:	c7 04 24 63 8a 10 80 	movl   $0x80108a63,(%esp)
80104d04:	e8 34 b8 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104d09:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d0f:	8b 40 0c             	mov    0xc(%eax),%eax
80104d12:	83 f8 04             	cmp    $0x4,%eax
80104d15:	75 0c                	jne    80104d23 <sched+0x59>
    panic("sched running");
80104d17:	c7 04 24 6f 8a 10 80 	movl   $0x80108a6f,(%esp)
80104d1e:	e8 1a b8 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104d23:	e8 30 f6 ff ff       	call   80104358 <readeflags>
80104d28:	25 00 02 00 00       	and    $0x200,%eax
80104d2d:	85 c0                	test   %eax,%eax
80104d2f:	74 0c                	je     80104d3d <sched+0x73>
    panic("sched interruptible");
80104d31:	c7 04 24 7d 8a 10 80 	movl   $0x80108a7d,(%esp)
80104d38:	e8 00 b8 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104d3d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d43:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104d49:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104d4c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d52:	8b 40 04             	mov    0x4(%eax),%eax
80104d55:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d5c:	83 c2 1c             	add    $0x1c,%edx
80104d5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d63:	89 14 24             	mov    %edx,(%esp)
80104d66:	e8 49 08 00 00       	call   801055b4 <swtch>
  cpu->intena = intena;
80104d6b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d74:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104d7a:	c9                   	leave  
80104d7b:	c3                   	ret    

80104d7c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d7c:	55                   	push   %ebp
80104d7d:	89 e5                	mov    %esp,%ebp
80104d7f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104d82:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d89:	e8 31 03 00 00       	call   801050bf <acquire>
  proc->state = RUNNABLE;
80104d8e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d94:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d9b:	e8 2a ff ff ff       	call   80104cca <sched>
  release(&ptable.lock);
80104da0:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104da7:	e8 75 03 00 00       	call   80105121 <release>
}
80104dac:	c9                   	leave  
80104dad:	c3                   	ret    

80104dae <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104dae:	55                   	push   %ebp
80104daf:	89 e5                	mov    %esp,%ebp
80104db1:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104db4:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104dbb:	e8 61 03 00 00       	call   80105121 <release>

  if (first) {
80104dc0:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104dc5:	85 c0                	test   %eax,%eax
80104dc7:	74 0f                	je     80104dd8 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104dc9:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104dd0:	00 00 00 
    initlog();
80104dd3:	e8 a0 e5 ff ff       	call   80103378 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104dd8:	c9                   	leave  
80104dd9:	c3                   	ret    

80104dda <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104dda:	55                   	push   %ebp
80104ddb:	89 e5                	mov    %esp,%ebp
80104ddd:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104de0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104de6:	85 c0                	test   %eax,%eax
80104de8:	75 0c                	jne    80104df6 <sleep+0x1c>
    panic("sleep");
80104dea:	c7 04 24 91 8a 10 80 	movl   $0x80108a91,(%esp)
80104df1:	e8 47 b7 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104df6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104dfa:	75 0c                	jne    80104e08 <sleep+0x2e>
    panic("sleep without lk");
80104dfc:	c7 04 24 97 8a 10 80 	movl   $0x80108a97,(%esp)
80104e03:	e8 35 b7 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e08:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104e0f:	74 17                	je     80104e28 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e11:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e18:	e8 a2 02 00 00       	call   801050bf <acquire>
    release(lk);
80104e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e20:	89 04 24             	mov    %eax,(%esp)
80104e23:	e8 f9 02 00 00       	call   80105121 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104e28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e2e:	8b 55 08             	mov    0x8(%ebp),%edx
80104e31:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104e34:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e3a:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104e41:	e8 84 fe ff ff       	call   80104cca <sched>

  // Tidy up.
  proc->chan = 0;
80104e46:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e4c:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e53:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104e5a:	74 17                	je     80104e73 <sleep+0x99>
    release(&ptable.lock);
80104e5c:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e63:	e8 b9 02 00 00       	call   80105121 <release>
    acquire(lk);
80104e68:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e6b:	89 04 24             	mov    %eax,(%esp)
80104e6e:	e8 4c 02 00 00       	call   801050bf <acquire>
  }
}
80104e73:	c9                   	leave  
80104e74:	c3                   	ret    

80104e75 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e75:	55                   	push   %ebp
80104e76:	89 e5                	mov    %esp,%ebp
80104e78:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e7b:	c7 45 fc 74 ff 10 80 	movl   $0x8010ff74,-0x4(%ebp)
80104e82:	eb 27                	jmp    80104eab <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104e84:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e87:	8b 40 0c             	mov    0xc(%eax),%eax
80104e8a:	83 f8 02             	cmp    $0x2,%eax
80104e8d:	75 15                	jne    80104ea4 <wakeup1+0x2f>
80104e8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e92:	8b 40 20             	mov    0x20(%eax),%eax
80104e95:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e98:	75 0a                	jne    80104ea4 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e9d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ea4:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80104eab:	81 7d fc 74 21 11 80 	cmpl   $0x80112174,-0x4(%ebp)
80104eb2:	72 d0                	jb     80104e84 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104eb4:	c9                   	leave  
80104eb5:	c3                   	ret    

80104eb6 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104eb6:	55                   	push   %ebp
80104eb7:	89 e5                	mov    %esp,%ebp
80104eb9:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104ebc:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ec3:	e8 f7 01 00 00       	call   801050bf <acquire>
  wakeup1(chan);
80104ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80104ecb:	89 04 24             	mov    %eax,(%esp)
80104ece:	e8 a2 ff ff ff       	call   80104e75 <wakeup1>
  release(&ptable.lock);
80104ed3:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104eda:	e8 42 02 00 00       	call   80105121 <release>
}
80104edf:	c9                   	leave  
80104ee0:	c3                   	ret    

80104ee1 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ee1:	55                   	push   %ebp
80104ee2:	89 e5                	mov    %esp,%ebp
80104ee4:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104ee7:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104eee:	e8 cc 01 00 00       	call   801050bf <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ef3:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104efa:	eb 44                	jmp    80104f40 <kill+0x5f>
    if(p->pid == pid){
80104efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eff:	8b 40 10             	mov    0x10(%eax),%eax
80104f02:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f05:	75 32                	jne    80104f39 <kill+0x58>
      p->killed = 1;
80104f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f0a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f14:	8b 40 0c             	mov    0xc(%eax),%eax
80104f17:	83 f8 02             	cmp    $0x2,%eax
80104f1a:	75 0a                	jne    80104f26 <kill+0x45>
        p->state = RUNNABLE;
80104f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f1f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f26:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f2d:	e8 ef 01 00 00       	call   80105121 <release>
      return 0;
80104f32:	b8 00 00 00 00       	mov    $0x0,%eax
80104f37:	eb 21                	jmp    80104f5a <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f39:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104f40:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
80104f47:	72 b3                	jb     80104efc <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104f49:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f50:	e8 cc 01 00 00       	call   80105121 <release>
  return -1;
80104f55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f5a:	c9                   	leave  
80104f5b:	c3                   	ret    

80104f5c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f5c:	55                   	push   %ebp
80104f5d:	89 e5                	mov    %esp,%ebp
80104f5f:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f62:	c7 45 f0 74 ff 10 80 	movl   $0x8010ff74,-0x10(%ebp)
80104f69:	e9 db 00 00 00       	jmp    80105049 <procdump+0xed>
    if(p->state == UNUSED)
80104f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f71:	8b 40 0c             	mov    0xc(%eax),%eax
80104f74:	85 c0                	test   %eax,%eax
80104f76:	0f 84 c5 00 00 00    	je     80105041 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f7f:	8b 40 0c             	mov    0xc(%eax),%eax
80104f82:	83 f8 05             	cmp    $0x5,%eax
80104f85:	77 23                	ja     80104faa <procdump+0x4e>
80104f87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f8a:	8b 40 0c             	mov    0xc(%eax),%eax
80104f8d:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104f94:	85 c0                	test   %eax,%eax
80104f96:	74 12                	je     80104faa <procdump+0x4e>
      state = states[p->state];
80104f98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f9b:	8b 40 0c             	mov    0xc(%eax),%eax
80104f9e:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104fa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104fa8:	eb 07                	jmp    80104fb1 <procdump+0x55>
    else
      state = "???";
80104faa:	c7 45 ec a8 8a 10 80 	movl   $0x80108aa8,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104fb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb4:	8d 50 6c             	lea    0x6c(%eax),%edx
80104fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fba:	8b 40 10             	mov    0x10(%eax),%eax
80104fbd:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104fc1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fc4:	89 54 24 08          	mov    %edx,0x8(%esp)
80104fc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fcc:	c7 04 24 ac 8a 10 80 	movl   $0x80108aac,(%esp)
80104fd3:	e8 c9 b3 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80104fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fdb:	8b 40 0c             	mov    0xc(%eax),%eax
80104fde:	83 f8 02             	cmp    $0x2,%eax
80104fe1:	75 50                	jne    80105033 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe6:	8b 40 1c             	mov    0x1c(%eax),%eax
80104fe9:	8b 40 0c             	mov    0xc(%eax),%eax
80104fec:	83 c0 08             	add    $0x8,%eax
80104fef:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104ff2:	89 54 24 04          	mov    %edx,0x4(%esp)
80104ff6:	89 04 24             	mov    %eax,(%esp)
80104ff9:	e8 72 01 00 00       	call   80105170 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104ffe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105005:	eb 1b                	jmp    80105022 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80105007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010500e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105012:	c7 04 24 b5 8a 10 80 	movl   $0x80108ab5,(%esp)
80105019:	e8 83 b3 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010501e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105022:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105026:	7f 0b                	jg     80105033 <procdump+0xd7>
80105028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010502b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010502f:	85 c0                	test   %eax,%eax
80105031:	75 d4                	jne    80105007 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105033:	c7 04 24 b9 8a 10 80 	movl   $0x80108ab9,(%esp)
8010503a:	e8 62 b3 ff ff       	call   801003a1 <cprintf>
8010503f:	eb 01                	jmp    80105042 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105041:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105042:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
80105049:	81 7d f0 74 21 11 80 	cmpl   $0x80112174,-0x10(%ebp)
80105050:	0f 82 18 ff ff ff    	jb     80104f6e <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105056:	c9                   	leave  
80105057:	c3                   	ret    

80105058 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105058:	55                   	push   %ebp
80105059:	89 e5                	mov    %esp,%ebp
8010505b:	53                   	push   %ebx
8010505c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010505f:	9c                   	pushf  
80105060:	5b                   	pop    %ebx
80105061:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105064:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105067:	83 c4 10             	add    $0x10,%esp
8010506a:	5b                   	pop    %ebx
8010506b:	5d                   	pop    %ebp
8010506c:	c3                   	ret    

8010506d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010506d:	55                   	push   %ebp
8010506e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105070:	fa                   	cli    
}
80105071:	5d                   	pop    %ebp
80105072:	c3                   	ret    

80105073 <sti>:

static inline void
sti(void)
{
80105073:	55                   	push   %ebp
80105074:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105076:	fb                   	sti    
}
80105077:	5d                   	pop    %ebp
80105078:	c3                   	ret    

80105079 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105079:	55                   	push   %ebp
8010507a:	89 e5                	mov    %esp,%ebp
8010507c:	53                   	push   %ebx
8010507d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105080:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105083:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80105086:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105089:	89 c3                	mov    %eax,%ebx
8010508b:	89 d8                	mov    %ebx,%eax
8010508d:	f0 87 02             	lock xchg %eax,(%edx)
80105090:	89 c3                	mov    %eax,%ebx
80105092:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105095:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105098:	83 c4 10             	add    $0x10,%esp
8010509b:	5b                   	pop    %ebx
8010509c:	5d                   	pop    %ebp
8010509d:	c3                   	ret    

8010509e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010509e:	55                   	push   %ebp
8010509f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801050a1:	8b 45 08             	mov    0x8(%ebp),%eax
801050a4:	8b 55 0c             	mov    0xc(%ebp),%edx
801050a7:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801050aa:	8b 45 08             	mov    0x8(%ebp),%eax
801050ad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801050b3:	8b 45 08             	mov    0x8(%ebp),%eax
801050b6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801050bd:	5d                   	pop    %ebp
801050be:	c3                   	ret    

801050bf <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801050bf:	55                   	push   %ebp
801050c0:	89 e5                	mov    %esp,%ebp
801050c2:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801050c5:	e8 3d 01 00 00       	call   80105207 <pushcli>
  if(holding(lk))
801050ca:	8b 45 08             	mov    0x8(%ebp),%eax
801050cd:	89 04 24             	mov    %eax,(%esp)
801050d0:	e8 08 01 00 00       	call   801051dd <holding>
801050d5:	85 c0                	test   %eax,%eax
801050d7:	74 0c                	je     801050e5 <acquire+0x26>
    panic("acquire");
801050d9:	c7 04 24 e5 8a 10 80 	movl   $0x80108ae5,(%esp)
801050e0:	e8 58 b4 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801050e5:	90                   	nop
801050e6:	8b 45 08             	mov    0x8(%ebp),%eax
801050e9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801050f0:	00 
801050f1:	89 04 24             	mov    %eax,(%esp)
801050f4:	e8 80 ff ff ff       	call   80105079 <xchg>
801050f9:	85 c0                	test   %eax,%eax
801050fb:	75 e9                	jne    801050e6 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801050fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105100:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105107:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010510a:	8b 45 08             	mov    0x8(%ebp),%eax
8010510d:	83 c0 0c             	add    $0xc,%eax
80105110:	89 44 24 04          	mov    %eax,0x4(%esp)
80105114:	8d 45 08             	lea    0x8(%ebp),%eax
80105117:	89 04 24             	mov    %eax,(%esp)
8010511a:	e8 51 00 00 00       	call   80105170 <getcallerpcs>
}
8010511f:	c9                   	leave  
80105120:	c3                   	ret    

80105121 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105121:	55                   	push   %ebp
80105122:	89 e5                	mov    %esp,%ebp
80105124:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105127:	8b 45 08             	mov    0x8(%ebp),%eax
8010512a:	89 04 24             	mov    %eax,(%esp)
8010512d:	e8 ab 00 00 00       	call   801051dd <holding>
80105132:	85 c0                	test   %eax,%eax
80105134:	75 0c                	jne    80105142 <release+0x21>
    panic("release");
80105136:	c7 04 24 ed 8a 10 80 	movl   $0x80108aed,(%esp)
8010513d:	e8 fb b3 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80105142:	8b 45 08             	mov    0x8(%ebp),%eax
80105145:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010514c:	8b 45 08             	mov    0x8(%ebp),%eax
8010514f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105156:	8b 45 08             	mov    0x8(%ebp),%eax
80105159:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105160:	00 
80105161:	89 04 24             	mov    %eax,(%esp)
80105164:	e8 10 ff ff ff       	call   80105079 <xchg>

  popcli();
80105169:	e8 e1 00 00 00       	call   8010524f <popcli>
}
8010516e:	c9                   	leave  
8010516f:	c3                   	ret    

80105170 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105170:	55                   	push   %ebp
80105171:	89 e5                	mov    %esp,%ebp
80105173:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105176:	8b 45 08             	mov    0x8(%ebp),%eax
80105179:	83 e8 08             	sub    $0x8,%eax
8010517c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010517f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105186:	eb 32                	jmp    801051ba <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105188:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010518c:	74 47                	je     801051d5 <getcallerpcs+0x65>
8010518e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105195:	76 3e                	jbe    801051d5 <getcallerpcs+0x65>
80105197:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010519b:	74 38                	je     801051d5 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010519d:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051a0:	c1 e0 02             	shl    $0x2,%eax
801051a3:	03 45 0c             	add    0xc(%ebp),%eax
801051a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051a9:	8b 52 04             	mov    0x4(%edx),%edx
801051ac:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
801051ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051b1:	8b 00                	mov    (%eax),%eax
801051b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801051b6:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051ba:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051be:	7e c8                	jle    80105188 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051c0:	eb 13                	jmp    801051d5 <getcallerpcs+0x65>
    pcs[i] = 0;
801051c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051c5:	c1 e0 02             	shl    $0x2,%eax
801051c8:	03 45 0c             	add    0xc(%ebp),%eax
801051cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801051d1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051d5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051d9:	7e e7                	jle    801051c2 <getcallerpcs+0x52>
    pcs[i] = 0;
}
801051db:	c9                   	leave  
801051dc:	c3                   	ret    

801051dd <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801051dd:	55                   	push   %ebp
801051de:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801051e0:	8b 45 08             	mov    0x8(%ebp),%eax
801051e3:	8b 00                	mov    (%eax),%eax
801051e5:	85 c0                	test   %eax,%eax
801051e7:	74 17                	je     80105200 <holding+0x23>
801051e9:	8b 45 08             	mov    0x8(%ebp),%eax
801051ec:	8b 50 08             	mov    0x8(%eax),%edx
801051ef:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051f5:	39 c2                	cmp    %eax,%edx
801051f7:	75 07                	jne    80105200 <holding+0x23>
801051f9:	b8 01 00 00 00       	mov    $0x1,%eax
801051fe:	eb 05                	jmp    80105205 <holding+0x28>
80105200:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105205:	5d                   	pop    %ebp
80105206:	c3                   	ret    

80105207 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105207:	55                   	push   %ebp
80105208:	89 e5                	mov    %esp,%ebp
8010520a:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010520d:	e8 46 fe ff ff       	call   80105058 <readeflags>
80105212:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105215:	e8 53 fe ff ff       	call   8010506d <cli>
  if(cpu->ncli++ == 0)
8010521a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105220:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105226:	85 d2                	test   %edx,%edx
80105228:	0f 94 c1             	sete   %cl
8010522b:	83 c2 01             	add    $0x1,%edx
8010522e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105234:	84 c9                	test   %cl,%cl
80105236:	74 15                	je     8010524d <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105238:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010523e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105241:	81 e2 00 02 00 00    	and    $0x200,%edx
80105247:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010524d:	c9                   	leave  
8010524e:	c3                   	ret    

8010524f <popcli>:

void
popcli(void)
{
8010524f:	55                   	push   %ebp
80105250:	89 e5                	mov    %esp,%ebp
80105252:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105255:	e8 fe fd ff ff       	call   80105058 <readeflags>
8010525a:	25 00 02 00 00       	and    $0x200,%eax
8010525f:	85 c0                	test   %eax,%eax
80105261:	74 0c                	je     8010526f <popcli+0x20>
    panic("popcli - interruptible");
80105263:	c7 04 24 f5 8a 10 80 	movl   $0x80108af5,(%esp)
8010526a:	e8 ce b2 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
8010526f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105275:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010527b:	83 ea 01             	sub    $0x1,%edx
8010527e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105284:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010528a:	85 c0                	test   %eax,%eax
8010528c:	79 0c                	jns    8010529a <popcli+0x4b>
    panic("popcli");
8010528e:	c7 04 24 0c 8b 10 80 	movl   $0x80108b0c,(%esp)
80105295:	e8 a3 b2 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010529a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052a0:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801052a6:	85 c0                	test   %eax,%eax
801052a8:	75 15                	jne    801052bf <popcli+0x70>
801052aa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052b0:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801052b6:	85 c0                	test   %eax,%eax
801052b8:	74 05                	je     801052bf <popcli+0x70>
    sti();
801052ba:	e8 b4 fd ff ff       	call   80105073 <sti>
}
801052bf:	c9                   	leave  
801052c0:	c3                   	ret    
801052c1:	00 00                	add    %al,(%eax)
	...

801052c4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801052c4:	55                   	push   %ebp
801052c5:	89 e5                	mov    %esp,%ebp
801052c7:	57                   	push   %edi
801052c8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801052c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052cc:	8b 55 10             	mov    0x10(%ebp),%edx
801052cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d2:	89 cb                	mov    %ecx,%ebx
801052d4:	89 df                	mov    %ebx,%edi
801052d6:	89 d1                	mov    %edx,%ecx
801052d8:	fc                   	cld    
801052d9:	f3 aa                	rep stos %al,%es:(%edi)
801052db:	89 ca                	mov    %ecx,%edx
801052dd:	89 fb                	mov    %edi,%ebx
801052df:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052e2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801052e5:	5b                   	pop    %ebx
801052e6:	5f                   	pop    %edi
801052e7:	5d                   	pop    %ebp
801052e8:	c3                   	ret    

801052e9 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801052e9:	55                   	push   %ebp
801052ea:	89 e5                	mov    %esp,%ebp
801052ec:	57                   	push   %edi
801052ed:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052f1:	8b 55 10             	mov    0x10(%ebp),%edx
801052f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f7:	89 cb                	mov    %ecx,%ebx
801052f9:	89 df                	mov    %ebx,%edi
801052fb:	89 d1                	mov    %edx,%ecx
801052fd:	fc                   	cld    
801052fe:	f3 ab                	rep stos %eax,%es:(%edi)
80105300:	89 ca                	mov    %ecx,%edx
80105302:	89 fb                	mov    %edi,%ebx
80105304:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105307:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010530a:	5b                   	pop    %ebx
8010530b:	5f                   	pop    %edi
8010530c:	5d                   	pop    %ebp
8010530d:	c3                   	ret    

8010530e <memset>:
#include "x86.h"
#include "string.h"

void*
memset(void *dst, int c, uint n)
{
8010530e:	55                   	push   %ebp
8010530f:	89 e5                	mov    %esp,%ebp
80105311:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105314:	8b 45 08             	mov    0x8(%ebp),%eax
80105317:	83 e0 03             	and    $0x3,%eax
8010531a:	85 c0                	test   %eax,%eax
8010531c:	75 49                	jne    80105367 <memset+0x59>
8010531e:	8b 45 10             	mov    0x10(%ebp),%eax
80105321:	83 e0 03             	and    $0x3,%eax
80105324:	85 c0                	test   %eax,%eax
80105326:	75 3f                	jne    80105367 <memset+0x59>
    c &= 0xFF;
80105328:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010532f:	8b 45 10             	mov    0x10(%ebp),%eax
80105332:	c1 e8 02             	shr    $0x2,%eax
80105335:	89 c2                	mov    %eax,%edx
80105337:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533a:	89 c1                	mov    %eax,%ecx
8010533c:	c1 e1 18             	shl    $0x18,%ecx
8010533f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105342:	c1 e0 10             	shl    $0x10,%eax
80105345:	09 c1                	or     %eax,%ecx
80105347:	8b 45 0c             	mov    0xc(%ebp),%eax
8010534a:	c1 e0 08             	shl    $0x8,%eax
8010534d:	09 c8                	or     %ecx,%eax
8010534f:	0b 45 0c             	or     0xc(%ebp),%eax
80105352:	89 54 24 08          	mov    %edx,0x8(%esp)
80105356:	89 44 24 04          	mov    %eax,0x4(%esp)
8010535a:	8b 45 08             	mov    0x8(%ebp),%eax
8010535d:	89 04 24             	mov    %eax,(%esp)
80105360:	e8 84 ff ff ff       	call   801052e9 <stosl>
80105365:	eb 19                	jmp    80105380 <memset+0x72>
  } else
    stosb(dst, c, n);
80105367:	8b 45 10             	mov    0x10(%ebp),%eax
8010536a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010536e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105371:	89 44 24 04          	mov    %eax,0x4(%esp)
80105375:	8b 45 08             	mov    0x8(%ebp),%eax
80105378:	89 04 24             	mov    %eax,(%esp)
8010537b:	e8 44 ff ff ff       	call   801052c4 <stosb>
  return dst;
80105380:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105383:	c9                   	leave  
80105384:	c3                   	ret    

80105385 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105385:	55                   	push   %ebp
80105386:	89 e5                	mov    %esp,%ebp
80105388:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010538b:	8b 45 08             	mov    0x8(%ebp),%eax
8010538e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105391:	8b 45 0c             	mov    0xc(%ebp),%eax
80105394:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105397:	eb 32                	jmp    801053cb <memcmp+0x46>
    if(*s1 != *s2)
80105399:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010539c:	0f b6 10             	movzbl (%eax),%edx
8010539f:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053a2:	0f b6 00             	movzbl (%eax),%eax
801053a5:	38 c2                	cmp    %al,%dl
801053a7:	74 1a                	je     801053c3 <memcmp+0x3e>
      return *s1 - *s2;
801053a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053ac:	0f b6 00             	movzbl (%eax),%eax
801053af:	0f b6 d0             	movzbl %al,%edx
801053b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053b5:	0f b6 00             	movzbl (%eax),%eax
801053b8:	0f b6 c0             	movzbl %al,%eax
801053bb:	89 d1                	mov    %edx,%ecx
801053bd:	29 c1                	sub    %eax,%ecx
801053bf:	89 c8                	mov    %ecx,%eax
801053c1:	eb 1c                	jmp    801053df <memcmp+0x5a>
    s1++, s2++;
801053c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053c7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801053cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053cf:	0f 95 c0             	setne  %al
801053d2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053d6:	84 c0                	test   %al,%al
801053d8:	75 bf                	jne    80105399 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801053da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053df:	c9                   	leave  
801053e0:	c3                   	ret    

801053e1 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053e1:	55                   	push   %ebp
801053e2:	89 e5                	mov    %esp,%ebp
801053e4:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801053e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801053ed:	8b 45 08             	mov    0x8(%ebp),%eax
801053f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801053f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053f6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053f9:	73 54                	jae    8010544f <memmove+0x6e>
801053fb:	8b 45 10             	mov    0x10(%ebp),%eax
801053fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105401:	01 d0                	add    %edx,%eax
80105403:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105406:	76 47                	jbe    8010544f <memmove+0x6e>
    s += n;
80105408:	8b 45 10             	mov    0x10(%ebp),%eax
8010540b:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010540e:	8b 45 10             	mov    0x10(%ebp),%eax
80105411:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105414:	eb 13                	jmp    80105429 <memmove+0x48>
      *--d = *--s;
80105416:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010541a:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010541e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105421:	0f b6 10             	movzbl (%eax),%edx
80105424:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105427:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105429:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010542d:	0f 95 c0             	setne  %al
80105430:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105434:	84 c0                	test   %al,%al
80105436:	75 de                	jne    80105416 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105438:	eb 25                	jmp    8010545f <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010543a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010543d:	0f b6 10             	movzbl (%eax),%edx
80105440:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105443:	88 10                	mov    %dl,(%eax)
80105445:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105449:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010544d:	eb 01                	jmp    80105450 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010544f:	90                   	nop
80105450:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105454:	0f 95 c0             	setne  %al
80105457:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010545b:	84 c0                	test   %al,%al
8010545d:	75 db                	jne    8010543a <memmove+0x59>
      *d++ = *s++;

  return dst;
8010545f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105462:	c9                   	leave  
80105463:	c3                   	ret    

80105464 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105464:	55                   	push   %ebp
80105465:	89 e5                	mov    %esp,%ebp
80105467:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010546a:	8b 45 10             	mov    0x10(%ebp),%eax
8010546d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105471:	8b 45 0c             	mov    0xc(%ebp),%eax
80105474:	89 44 24 04          	mov    %eax,0x4(%esp)
80105478:	8b 45 08             	mov    0x8(%ebp),%eax
8010547b:	89 04 24             	mov    %eax,(%esp)
8010547e:	e8 5e ff ff ff       	call   801053e1 <memmove>
}
80105483:	c9                   	leave  
80105484:	c3                   	ret    

80105485 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105485:	55                   	push   %ebp
80105486:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105488:	eb 0c                	jmp    80105496 <strncmp+0x11>
    n--, p++, q++;
8010548a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010548e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105492:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105496:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010549a:	74 1a                	je     801054b6 <strncmp+0x31>
8010549c:	8b 45 08             	mov    0x8(%ebp),%eax
8010549f:	0f b6 00             	movzbl (%eax),%eax
801054a2:	84 c0                	test   %al,%al
801054a4:	74 10                	je     801054b6 <strncmp+0x31>
801054a6:	8b 45 08             	mov    0x8(%ebp),%eax
801054a9:	0f b6 10             	movzbl (%eax),%edx
801054ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801054af:	0f b6 00             	movzbl (%eax),%eax
801054b2:	38 c2                	cmp    %al,%dl
801054b4:	74 d4                	je     8010548a <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
801054b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054ba:	75 07                	jne    801054c3 <strncmp+0x3e>
    return 0;
801054bc:	b8 00 00 00 00       	mov    $0x0,%eax
801054c1:	eb 18                	jmp    801054db <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
801054c3:	8b 45 08             	mov    0x8(%ebp),%eax
801054c6:	0f b6 00             	movzbl (%eax),%eax
801054c9:	0f b6 d0             	movzbl %al,%edx
801054cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801054cf:	0f b6 00             	movzbl (%eax),%eax
801054d2:	0f b6 c0             	movzbl %al,%eax
801054d5:	89 d1                	mov    %edx,%ecx
801054d7:	29 c1                	sub    %eax,%ecx
801054d9:	89 c8                	mov    %ecx,%eax
}
801054db:	5d                   	pop    %ebp
801054dc:	c3                   	ret    

801054dd <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801054dd:	55                   	push   %ebp
801054de:	89 e5                	mov    %esp,%ebp
801054e0:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054e3:	8b 45 08             	mov    0x8(%ebp),%eax
801054e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801054e9:	90                   	nop
801054ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054ee:	0f 9f c0             	setg   %al
801054f1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054f5:	84 c0                	test   %al,%al
801054f7:	74 30                	je     80105529 <strncpy+0x4c>
801054f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801054fc:	0f b6 10             	movzbl (%eax),%edx
801054ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105502:	88 10                	mov    %dl,(%eax)
80105504:	8b 45 08             	mov    0x8(%ebp),%eax
80105507:	0f b6 00             	movzbl (%eax),%eax
8010550a:	84 c0                	test   %al,%al
8010550c:	0f 95 c0             	setne  %al
8010550f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105513:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105517:	84 c0                	test   %al,%al
80105519:	75 cf                	jne    801054ea <strncpy+0xd>
    ;
  while(n-- > 0)
8010551b:	eb 0c                	jmp    80105529 <strncpy+0x4c>
    *s++ = 0;
8010551d:	8b 45 08             	mov    0x8(%ebp),%eax
80105520:	c6 00 00             	movb   $0x0,(%eax)
80105523:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105527:	eb 01                	jmp    8010552a <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105529:	90                   	nop
8010552a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010552e:	0f 9f c0             	setg   %al
80105531:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105535:	84 c0                	test   %al,%al
80105537:	75 e4                	jne    8010551d <strncpy+0x40>
    *s++ = 0;
  return os;
80105539:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010553c:	c9                   	leave  
8010553d:	c3                   	ret    

8010553e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010553e:	55                   	push   %ebp
8010553f:	89 e5                	mov    %esp,%ebp
80105541:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105544:	8b 45 08             	mov    0x8(%ebp),%eax
80105547:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010554a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010554e:	7f 05                	jg     80105555 <safestrcpy+0x17>
    return os;
80105550:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105553:	eb 35                	jmp    8010558a <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105555:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105559:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010555d:	7e 22                	jle    80105581 <safestrcpy+0x43>
8010555f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105562:	0f b6 10             	movzbl (%eax),%edx
80105565:	8b 45 08             	mov    0x8(%ebp),%eax
80105568:	88 10                	mov    %dl,(%eax)
8010556a:	8b 45 08             	mov    0x8(%ebp),%eax
8010556d:	0f b6 00             	movzbl (%eax),%eax
80105570:	84 c0                	test   %al,%al
80105572:	0f 95 c0             	setne  %al
80105575:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105579:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010557d:	84 c0                	test   %al,%al
8010557f:	75 d4                	jne    80105555 <safestrcpy+0x17>
    ;
  *s = 0;
80105581:	8b 45 08             	mov    0x8(%ebp),%eax
80105584:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105587:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010558a:	c9                   	leave  
8010558b:	c3                   	ret    

8010558c <strlen>:

int
strlen(const char *s)
{
8010558c:	55                   	push   %ebp
8010558d:	89 e5                	mov    %esp,%ebp
8010558f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105592:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105599:	eb 04                	jmp    8010559f <strlen+0x13>
8010559b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010559f:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055a2:	03 45 08             	add    0x8(%ebp),%eax
801055a5:	0f b6 00             	movzbl (%eax),%eax
801055a8:	84 c0                	test   %al,%al
801055aa:	75 ef                	jne    8010559b <strlen+0xf>
    ;
  return n;
801055ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055af:	c9                   	leave  
801055b0:	c3                   	ret    
801055b1:	00 00                	add    %al,(%eax)
	...

801055b4 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
801055b4:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801055b8:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801055bc:	55                   	push   %ebp
  pushl %ebx
801055bd:	53                   	push   %ebx
  pushl %esi
801055be:	56                   	push   %esi
  pushl %edi
801055bf:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801055c0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801055c2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801055c4:	5f                   	pop    %edi
  popl %esi
801055c5:	5e                   	pop    %esi
  popl %ebx
801055c6:	5b                   	pop    %ebx
  popl %ebp
801055c7:	5d                   	pop    %ebp
  ret
801055c8:	c3                   	ret    
801055c9:	00 00                	add    %al,(%eax)
	...

801055cc <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
801055cc:	55                   	push   %ebp
801055cd:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
801055cf:	8b 45 08             	mov    0x8(%ebp),%eax
801055d2:	8b 00                	mov    (%eax),%eax
801055d4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801055d7:	76 0f                	jbe    801055e8 <fetchint+0x1c>
801055d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055dc:	8d 50 04             	lea    0x4(%eax),%edx
801055df:	8b 45 08             	mov    0x8(%ebp),%eax
801055e2:	8b 00                	mov    (%eax),%eax
801055e4:	39 c2                	cmp    %eax,%edx
801055e6:	76 07                	jbe    801055ef <fetchint+0x23>
    return -1;
801055e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ed:	eb 0f                	jmp    801055fe <fetchint+0x32>
  *ip = *(int*)(addr);
801055ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f2:	8b 10                	mov    (%eax),%edx
801055f4:	8b 45 10             	mov    0x10(%ebp),%eax
801055f7:	89 10                	mov    %edx,(%eax)
  return 0;
801055f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055fe:	5d                   	pop    %ebp
801055ff:	c3                   	ret    

80105600 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
80105600:	55                   	push   %ebp
80105601:	89 e5                	mov    %esp,%ebp
80105603:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
80105606:	8b 45 08             	mov    0x8(%ebp),%eax
80105609:	8b 00                	mov    (%eax),%eax
8010560b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010560e:	77 07                	ja     80105617 <fetchstr+0x17>
    return -1;
80105610:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105615:	eb 45                	jmp    8010565c <fetchstr+0x5c>
  *pp = (char*)addr;
80105617:	8b 55 0c             	mov    0xc(%ebp),%edx
8010561a:	8b 45 10             	mov    0x10(%ebp),%eax
8010561d:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
8010561f:	8b 45 08             	mov    0x8(%ebp),%eax
80105622:	8b 00                	mov    (%eax),%eax
80105624:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105627:	8b 45 10             	mov    0x10(%ebp),%eax
8010562a:	8b 00                	mov    (%eax),%eax
8010562c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010562f:	eb 1e                	jmp    8010564f <fetchstr+0x4f>
    if(*s == 0)
80105631:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105634:	0f b6 00             	movzbl (%eax),%eax
80105637:	84 c0                	test   %al,%al
80105639:	75 10                	jne    8010564b <fetchstr+0x4b>
      return s - *pp;
8010563b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010563e:	8b 45 10             	mov    0x10(%ebp),%eax
80105641:	8b 00                	mov    (%eax),%eax
80105643:	89 d1                	mov    %edx,%ecx
80105645:	29 c1                	sub    %eax,%ecx
80105647:	89 c8                	mov    %ecx,%eax
80105649:	eb 11                	jmp    8010565c <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
8010564b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010564f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105652:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105655:	72 da                	jb     80105631 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
80105657:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010565c:	c9                   	leave  
8010565d:	c3                   	ret    

8010565e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010565e:	55                   	push   %ebp
8010565f:	89 e5                	mov    %esp,%ebp
80105661:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
80105664:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010566a:	8b 40 18             	mov    0x18(%eax),%eax
8010566d:	8b 50 44             	mov    0x44(%eax),%edx
80105670:	8b 45 08             	mov    0x8(%ebp),%eax
80105673:	c1 e0 02             	shl    $0x2,%eax
80105676:	01 d0                	add    %edx,%eax
80105678:	8d 48 04             	lea    0x4(%eax),%ecx
8010567b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105681:	8b 55 0c             	mov    0xc(%ebp),%edx
80105684:	89 54 24 08          	mov    %edx,0x8(%esp)
80105688:	89 4c 24 04          	mov    %ecx,0x4(%esp)
8010568c:	89 04 24             	mov    %eax,(%esp)
8010568f:	e8 38 ff ff ff       	call   801055cc <fetchint>
}
80105694:	c9                   	leave  
80105695:	c3                   	ret    

80105696 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105696:	55                   	push   %ebp
80105697:	89 e5                	mov    %esp,%ebp
80105699:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010569c:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010569f:	89 44 24 04          	mov    %eax,0x4(%esp)
801056a3:	8b 45 08             	mov    0x8(%ebp),%eax
801056a6:	89 04 24             	mov    %eax,(%esp)
801056a9:	e8 b0 ff ff ff       	call   8010565e <argint>
801056ae:	85 c0                	test   %eax,%eax
801056b0:	79 07                	jns    801056b9 <argptr+0x23>
    return -1;
801056b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056b7:	eb 3d                	jmp    801056f6 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801056b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056bc:	89 c2                	mov    %eax,%edx
801056be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c4:	8b 00                	mov    (%eax),%eax
801056c6:	39 c2                	cmp    %eax,%edx
801056c8:	73 16                	jae    801056e0 <argptr+0x4a>
801056ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056cd:	89 c2                	mov    %eax,%edx
801056cf:	8b 45 10             	mov    0x10(%ebp),%eax
801056d2:	01 c2                	add    %eax,%edx
801056d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056da:	8b 00                	mov    (%eax),%eax
801056dc:	39 c2                	cmp    %eax,%edx
801056de:	76 07                	jbe    801056e7 <argptr+0x51>
    return -1;
801056e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056e5:	eb 0f                	jmp    801056f6 <argptr+0x60>
  *pp = (char*)i;
801056e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056ea:	89 c2                	mov    %eax,%edx
801056ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801056ef:	89 10                	mov    %edx,(%eax)
  return 0;
801056f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056f6:	c9                   	leave  
801056f7:	c3                   	ret    

801056f8 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801056f8:	55                   	push   %ebp
801056f9:	89 e5                	mov    %esp,%ebp
801056fb:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
801056fe:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105701:	89 44 24 04          	mov    %eax,0x4(%esp)
80105705:	8b 45 08             	mov    0x8(%ebp),%eax
80105708:	89 04 24             	mov    %eax,(%esp)
8010570b:	e8 4e ff ff ff       	call   8010565e <argint>
80105710:	85 c0                	test   %eax,%eax
80105712:	79 07                	jns    8010571b <argstr+0x23>
    return -1;
80105714:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105719:	eb 1e                	jmp    80105739 <argstr+0x41>
  return fetchstr(proc, addr, pp);
8010571b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010571e:	89 c2                	mov    %eax,%edx
80105720:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105726:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105729:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010572d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105731:	89 04 24             	mov    %eax,(%esp)
80105734:	e8 c7 fe ff ff       	call   80105600 <fetchstr>
}
80105739:	c9                   	leave  
8010573a:	c3                   	ret    

8010573b <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010573b:	55                   	push   %ebp
8010573c:	89 e5                	mov    %esp,%ebp
8010573e:	53                   	push   %ebx
8010573f:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105742:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105748:	8b 40 18             	mov    0x18(%eax),%eax
8010574b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010574e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
80105751:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105755:	78 2e                	js     80105785 <syscall+0x4a>
80105757:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010575b:	7f 28                	jg     80105785 <syscall+0x4a>
8010575d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105760:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105767:	85 c0                	test   %eax,%eax
80105769:	74 1a                	je     80105785 <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
8010576b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105771:	8b 58 18             	mov    0x18(%eax),%ebx
80105774:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105777:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010577e:	ff d0                	call   *%eax
80105780:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105783:	eb 73                	jmp    801057f8 <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
80105785:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105789:	7e 30                	jle    801057bb <syscall+0x80>
8010578b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010578e:	83 f8 16             	cmp    $0x16,%eax
80105791:	77 28                	ja     801057bb <syscall+0x80>
80105793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105796:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010579d:	85 c0                	test   %eax,%eax
8010579f:	74 1a                	je     801057bb <syscall+0x80>
    proc->tf->eax = syscalls[num]();
801057a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057a7:	8b 58 18             	mov    0x18(%eax),%ebx
801057aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ad:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801057b4:	ff d0                	call   *%eax
801057b6:	89 43 1c             	mov    %eax,0x1c(%ebx)
801057b9:	eb 3d                	jmp    801057f8 <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801057bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057c1:	8d 48 6c             	lea    0x6c(%eax),%ecx
801057c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801057ca:	8b 40 10             	mov    0x10(%eax),%eax
801057cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
801057d4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801057d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801057dc:	c7 04 24 13 8b 10 80 	movl   $0x80108b13,(%esp)
801057e3:	e8 b9 ab ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801057e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057ee:	8b 40 18             	mov    0x18(%eax),%eax
801057f1:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801057f8:	83 c4 24             	add    $0x24,%esp
801057fb:	5b                   	pop    %ebx
801057fc:	5d                   	pop    %ebp
801057fd:	c3                   	ret    
	...

80105800 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105800:	55                   	push   %ebp
80105801:	89 e5                	mov    %esp,%ebp
80105803:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105806:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105809:	89 44 24 04          	mov    %eax,0x4(%esp)
8010580d:	8b 45 08             	mov    0x8(%ebp),%eax
80105810:	89 04 24             	mov    %eax,(%esp)
80105813:	e8 46 fe ff ff       	call   8010565e <argint>
80105818:	85 c0                	test   %eax,%eax
8010581a:	79 07                	jns    80105823 <argfd+0x23>
    return -1;
8010581c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105821:	eb 50                	jmp    80105873 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105823:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105826:	85 c0                	test   %eax,%eax
80105828:	78 21                	js     8010584b <argfd+0x4b>
8010582a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010582d:	83 f8 0f             	cmp    $0xf,%eax
80105830:	7f 19                	jg     8010584b <argfd+0x4b>
80105832:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105838:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010583b:	83 c2 08             	add    $0x8,%edx
8010583e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105842:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105845:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105849:	75 07                	jne    80105852 <argfd+0x52>
    return -1;
8010584b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105850:	eb 21                	jmp    80105873 <argfd+0x73>
  if(pfd)
80105852:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105856:	74 08                	je     80105860 <argfd+0x60>
    *pfd = fd;
80105858:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010585b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010585e:	89 10                	mov    %edx,(%eax)
  if(pf)
80105860:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105864:	74 08                	je     8010586e <argfd+0x6e>
    *pf = f;
80105866:	8b 45 10             	mov    0x10(%ebp),%eax
80105869:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010586c:	89 10                	mov    %edx,(%eax)
  return 0;
8010586e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105873:	c9                   	leave  
80105874:	c3                   	ret    

80105875 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105875:	55                   	push   %ebp
80105876:	89 e5                	mov    %esp,%ebp
80105878:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010587b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105882:	eb 30                	jmp    801058b4 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105884:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010588a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010588d:	83 c2 08             	add    $0x8,%edx
80105890:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105894:	85 c0                	test   %eax,%eax
80105896:	75 18                	jne    801058b0 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105898:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010589e:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058a1:	8d 4a 08             	lea    0x8(%edx),%ecx
801058a4:	8b 55 08             	mov    0x8(%ebp),%edx
801058a7:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801058ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058ae:	eb 0f                	jmp    801058bf <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801058b0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801058b4:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801058b8:	7e ca                	jle    80105884 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801058ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058bf:	c9                   	leave  
801058c0:	c3                   	ret    

801058c1 <sys_dup>:

int
sys_dup(void)
{
801058c1:	55                   	push   %ebp
801058c2:	89 e5                	mov    %esp,%ebp
801058c4:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801058c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058ca:	89 44 24 08          	mov    %eax,0x8(%esp)
801058ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058d5:	00 
801058d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058dd:	e8 1e ff ff ff       	call   80105800 <argfd>
801058e2:	85 c0                	test   %eax,%eax
801058e4:	79 07                	jns    801058ed <sys_dup+0x2c>
    return -1;
801058e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058eb:	eb 29                	jmp    80105916 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801058ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f0:	89 04 24             	mov    %eax,(%esp)
801058f3:	e8 7d ff ff ff       	call   80105875 <fdalloc>
801058f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058ff:	79 07                	jns    80105908 <sys_dup+0x47>
    return -1;
80105901:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105906:	eb 0e                	jmp    80105916 <sys_dup+0x55>
  filedup(f);
80105908:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010590b:	89 04 24             	mov    %eax,(%esp)
8010590e:	e8 d1 b9 ff ff       	call   801012e4 <filedup>
  return fd;
80105913:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105916:	c9                   	leave  
80105917:	c3                   	ret    

80105918 <sys_read>:

int
sys_read(void)
{
80105918:	55                   	push   %ebp
80105919:	89 e5                	mov    %esp,%ebp
8010591b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010591e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105921:	89 44 24 08          	mov    %eax,0x8(%esp)
80105925:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010592c:	00 
8010592d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105934:	e8 c7 fe ff ff       	call   80105800 <argfd>
80105939:	85 c0                	test   %eax,%eax
8010593b:	78 35                	js     80105972 <sys_read+0x5a>
8010593d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105940:	89 44 24 04          	mov    %eax,0x4(%esp)
80105944:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010594b:	e8 0e fd ff ff       	call   8010565e <argint>
80105950:	85 c0                	test   %eax,%eax
80105952:	78 1e                	js     80105972 <sys_read+0x5a>
80105954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105957:	89 44 24 08          	mov    %eax,0x8(%esp)
8010595b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010595e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105962:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105969:	e8 28 fd ff ff       	call   80105696 <argptr>
8010596e:	85 c0                	test   %eax,%eax
80105970:	79 07                	jns    80105979 <sys_read+0x61>
    return -1;
80105972:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105977:	eb 19                	jmp    80105992 <sys_read+0x7a>
  return fileread(f, p, n);
80105979:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010597c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010597f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105982:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105986:	89 54 24 04          	mov    %edx,0x4(%esp)
8010598a:	89 04 24             	mov    %eax,(%esp)
8010598d:	e8 bf ba ff ff       	call   80101451 <fileread>
}
80105992:	c9                   	leave  
80105993:	c3                   	ret    

80105994 <sys_write>:

int
sys_write(void)
{
80105994:	55                   	push   %ebp
80105995:	89 e5                	mov    %esp,%ebp
80105997:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010599a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010599d:	89 44 24 08          	mov    %eax,0x8(%esp)
801059a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801059a8:	00 
801059a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059b0:	e8 4b fe ff ff       	call   80105800 <argfd>
801059b5:	85 c0                	test   %eax,%eax
801059b7:	78 35                	js     801059ee <sys_write+0x5a>
801059b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801059c0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801059c7:	e8 92 fc ff ff       	call   8010565e <argint>
801059cc:	85 c0                	test   %eax,%eax
801059ce:	78 1e                	js     801059ee <sys_write+0x5a>
801059d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d3:	89 44 24 08          	mov    %eax,0x8(%esp)
801059d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059da:	89 44 24 04          	mov    %eax,0x4(%esp)
801059de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059e5:	e8 ac fc ff ff       	call   80105696 <argptr>
801059ea:	85 c0                	test   %eax,%eax
801059ec:	79 07                	jns    801059f5 <sys_write+0x61>
    return -1;
801059ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f3:	eb 19                	jmp    80105a0e <sys_write+0x7a>
  return filewrite(f, p, n);
801059f5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059f8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fe:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a02:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a06:	89 04 24             	mov    %eax,(%esp)
80105a09:	e8 ff ba ff ff       	call   8010150d <filewrite>
}
80105a0e:	c9                   	leave  
80105a0f:	c3                   	ret    

80105a10 <sys_close>:

int
sys_close(void)
{
80105a10:	55                   	push   %ebp
80105a11:	89 e5                	mov    %esp,%ebp
80105a13:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105a16:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a19:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a20:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a2b:	e8 d0 fd ff ff       	call   80105800 <argfd>
80105a30:	85 c0                	test   %eax,%eax
80105a32:	79 07                	jns    80105a3b <sys_close+0x2b>
    return -1;
80105a34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a39:	eb 24                	jmp    80105a5f <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105a3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a44:	83 c2 08             	add    $0x8,%edx
80105a47:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105a4e:	00 
  fileclose(f);
80105a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a52:	89 04 24             	mov    %eax,(%esp)
80105a55:	e8 d2 b8 ff ff       	call   8010132c <fileclose>
  return 0;
80105a5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a5f:	c9                   	leave  
80105a60:	c3                   	ret    

80105a61 <sys_fstat>:

int
sys_fstat(void)
{
80105a61:	55                   	push   %ebp
80105a62:	89 e5                	mov    %esp,%ebp
80105a64:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105a67:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a6e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a75:	00 
80105a76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a7d:	e8 7e fd ff ff       	call   80105800 <argfd>
80105a82:	85 c0                	test   %eax,%eax
80105a84:	78 1f                	js     80105aa5 <sys_fstat+0x44>
80105a86:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105a8d:	00 
80105a8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a91:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a9c:	e8 f5 fb ff ff       	call   80105696 <argptr>
80105aa1:	85 c0                	test   %eax,%eax
80105aa3:	79 07                	jns    80105aac <sys_fstat+0x4b>
    return -1;
80105aa5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aaa:	eb 12                	jmp    80105abe <sys_fstat+0x5d>
  return filestat(f, st);
80105aac:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab2:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ab6:	89 04 24             	mov    %eax,(%esp)
80105ab9:	e8 44 b9 ff ff       	call   80101402 <filestat>
}
80105abe:	c9                   	leave  
80105abf:	c3                   	ret    

80105ac0 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ac0:	55                   	push   %ebp
80105ac1:	89 e5                	mov    %esp,%ebp
80105ac3:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105ac6:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105acd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ad4:	e8 1f fc ff ff       	call   801056f8 <argstr>
80105ad9:	85 c0                	test   %eax,%eax
80105adb:	78 17                	js     80105af4 <sys_link+0x34>
80105add:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105ae0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ae4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105aeb:	e8 08 fc ff ff       	call   801056f8 <argstr>
80105af0:	85 c0                	test   %eax,%eax
80105af2:	79 0a                	jns    80105afe <sys_link+0x3e>
    return -1;
80105af4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af9:	e9 3c 01 00 00       	jmp    80105c3a <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80105afe:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105b01:	89 04 24             	mov    %eax,(%esp)
80105b04:	e8 69 cc ff ff       	call   80102772 <namei>
80105b09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b10:	75 0a                	jne    80105b1c <sys_link+0x5c>
    return -1;
80105b12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b17:	e9 1e 01 00 00       	jmp    80105c3a <sys_link+0x17a>

  begin_trans();
80105b1c:	e8 64 da ff ff       	call   80103585 <begin_trans>

  ilock(ip);
80105b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b24:	89 04 24             	mov    %eax,(%esp)
80105b27:	e8 a4 c0 ff ff       	call   80101bd0 <ilock>
  if(ip->type == T_DIR){
80105b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b33:	66 83 f8 01          	cmp    $0x1,%ax
80105b37:	75 1a                	jne    80105b53 <sys_link+0x93>
    iunlockput(ip);
80105b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b3c:	89 04 24             	mov    %eax,(%esp)
80105b3f:	e8 10 c3 ff ff       	call   80101e54 <iunlockput>
    commit_trans();
80105b44:	e8 85 da ff ff       	call   801035ce <commit_trans>
    return -1;
80105b49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b4e:	e9 e7 00 00 00       	jmp    80105c3a <sys_link+0x17a>
  }

  ip->nlink++;
80105b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b56:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b5a:	8d 50 01             	lea    0x1(%eax),%edx
80105b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b60:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b67:	89 04 24             	mov    %eax,(%esp)
80105b6a:	e8 a5 be ff ff       	call   80101a14 <iupdate>
  iunlock(ip);
80105b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b72:	89 04 24             	mov    %eax,(%esp)
80105b75:	e8 a4 c1 ff ff       	call   80101d1e <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105b7a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105b7d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105b80:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b84:	89 04 24             	mov    %eax,(%esp)
80105b87:	e8 08 cc ff ff       	call   80102794 <nameiparent>
80105b8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b8f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b93:	74 68                	je     80105bfd <sys_link+0x13d>
    goto bad;
  ilock(dp);
80105b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b98:	89 04 24             	mov    %eax,(%esp)
80105b9b:	e8 30 c0 ff ff       	call   80101bd0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba3:	8b 10                	mov    (%eax),%edx
80105ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba8:	8b 00                	mov    (%eax),%eax
80105baa:	39 c2                	cmp    %eax,%edx
80105bac:	75 20                	jne    80105bce <sys_link+0x10e>
80105bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb1:	8b 40 04             	mov    0x4(%eax),%eax
80105bb4:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bb8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105bbb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc2:	89 04 24             	mov    %eax,(%esp)
80105bc5:	e8 e7 c8 ff ff       	call   801024b1 <dirlink>
80105bca:	85 c0                	test   %eax,%eax
80105bcc:	79 0d                	jns    80105bdb <sys_link+0x11b>
    iunlockput(dp);
80105bce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd1:	89 04 24             	mov    %eax,(%esp)
80105bd4:	e8 7b c2 ff ff       	call   80101e54 <iunlockput>
    goto bad;
80105bd9:	eb 23                	jmp    80105bfe <sys_link+0x13e>
  }
  iunlockput(dp);
80105bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bde:	89 04 24             	mov    %eax,(%esp)
80105be1:	e8 6e c2 ff ff       	call   80101e54 <iunlockput>
  iput(ip);
80105be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be9:	89 04 24             	mov    %eax,(%esp)
80105bec:	e8 92 c1 ff ff       	call   80101d83 <iput>

  commit_trans();
80105bf1:	e8 d8 d9 ff ff       	call   801035ce <commit_trans>

  return 0;
80105bf6:	b8 00 00 00 00       	mov    $0x0,%eax
80105bfb:	eb 3d                	jmp    80105c3a <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105bfd:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80105bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c01:	89 04 24             	mov    %eax,(%esp)
80105c04:	e8 c7 bf ff ff       	call   80101bd0 <ilock>
  ip->nlink--;
80105c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c10:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c16:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c1d:	89 04 24             	mov    %eax,(%esp)
80105c20:	e8 ef bd ff ff       	call   80101a14 <iupdate>
  iunlockput(ip);
80105c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c28:	89 04 24             	mov    %eax,(%esp)
80105c2b:	e8 24 c2 ff ff       	call   80101e54 <iunlockput>
  commit_trans();
80105c30:	e8 99 d9 ff ff       	call   801035ce <commit_trans>
  return -1;
80105c35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c3a:	c9                   	leave  
80105c3b:	c3                   	ret    

80105c3c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105c3c:	55                   	push   %ebp
80105c3d:	89 e5                	mov    %esp,%ebp
80105c3f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c42:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105c49:	eb 4b                	jmp    80105c96 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105c55:	00 
80105c56:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c5a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105c5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c61:	8b 45 08             	mov    0x8(%ebp),%eax
80105c64:	89 04 24             	mov    %eax,(%esp)
80105c67:	e8 5a c4 ff ff       	call   801020c6 <readi>
80105c6c:	83 f8 10             	cmp    $0x10,%eax
80105c6f:	74 0c                	je     80105c7d <isdirempty+0x41>
      panic("isdirempty: readi");
80105c71:	c7 04 24 2f 8b 10 80 	movl   $0x80108b2f,(%esp)
80105c78:	e8 c0 a8 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105c7d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105c81:	66 85 c0             	test   %ax,%ax
80105c84:	74 07                	je     80105c8d <isdirempty+0x51>
      return 0;
80105c86:	b8 00 00 00 00       	mov    $0x0,%eax
80105c8b:	eb 1b                	jmp    80105ca8 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c90:	83 c0 10             	add    $0x10,%eax
80105c93:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c99:	8b 45 08             	mov    0x8(%ebp),%eax
80105c9c:	8b 40 18             	mov    0x18(%eax),%eax
80105c9f:	39 c2                	cmp    %eax,%edx
80105ca1:	72 a8                	jb     80105c4b <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105ca3:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ca8:	c9                   	leave  
80105ca9:	c3                   	ret    

80105caa <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105caa:	55                   	push   %ebp
80105cab:	89 e5                	mov    %esp,%ebp
80105cad:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105cb0:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cbe:	e8 35 fa ff ff       	call   801056f8 <argstr>
80105cc3:	85 c0                	test   %eax,%eax
80105cc5:	79 0a                	jns    80105cd1 <sys_unlink+0x27>
    return -1;
80105cc7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ccc:	e9 aa 01 00 00       	jmp    80105e7b <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105cd1:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105cd4:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105cd7:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cdb:	89 04 24             	mov    %eax,(%esp)
80105cde:	e8 b1 ca ff ff       	call   80102794 <nameiparent>
80105ce3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ce6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cea:	75 0a                	jne    80105cf6 <sys_unlink+0x4c>
    return -1;
80105cec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf1:	e9 85 01 00 00       	jmp    80105e7b <sys_unlink+0x1d1>

  begin_trans();
80105cf6:	e8 8a d8 ff ff       	call   80103585 <begin_trans>

  ilock(dp);
80105cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cfe:	89 04 24             	mov    %eax,(%esp)
80105d01:	e8 ca be ff ff       	call   80101bd0 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105d06:	c7 44 24 04 41 8b 10 	movl   $0x80108b41,0x4(%esp)
80105d0d:	80 
80105d0e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d11:	89 04 24             	mov    %eax,(%esp)
80105d14:	e8 ae c6 ff ff       	call   801023c7 <namecmp>
80105d19:	85 c0                	test   %eax,%eax
80105d1b:	0f 84 45 01 00 00    	je     80105e66 <sys_unlink+0x1bc>
80105d21:	c7 44 24 04 43 8b 10 	movl   $0x80108b43,0x4(%esp)
80105d28:	80 
80105d29:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d2c:	89 04 24             	mov    %eax,(%esp)
80105d2f:	e8 93 c6 ff ff       	call   801023c7 <namecmp>
80105d34:	85 c0                	test   %eax,%eax
80105d36:	0f 84 2a 01 00 00    	je     80105e66 <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105d3c:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105d3f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d43:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d46:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4d:	89 04 24             	mov    %eax,(%esp)
80105d50:	e8 94 c6 ff ff       	call   801023e9 <dirlookup>
80105d55:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d5c:	0f 84 03 01 00 00    	je     80105e65 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80105d62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d65:	89 04 24             	mov    %eax,(%esp)
80105d68:	e8 63 be ff ff       	call   80101bd0 <ilock>

  if(ip->nlink < 1)
80105d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d70:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d74:	66 85 c0             	test   %ax,%ax
80105d77:	7f 0c                	jg     80105d85 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80105d79:	c7 04 24 46 8b 10 80 	movl   $0x80108b46,(%esp)
80105d80:	e8 b8 a7 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d88:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d8c:	66 83 f8 01          	cmp    $0x1,%ax
80105d90:	75 1f                	jne    80105db1 <sys_unlink+0x107>
80105d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d95:	89 04 24             	mov    %eax,(%esp)
80105d98:	e8 9f fe ff ff       	call   80105c3c <isdirempty>
80105d9d:	85 c0                	test   %eax,%eax
80105d9f:	75 10                	jne    80105db1 <sys_unlink+0x107>
    iunlockput(ip);
80105da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105da4:	89 04 24             	mov    %eax,(%esp)
80105da7:	e8 a8 c0 ff ff       	call   80101e54 <iunlockput>
    goto bad;
80105dac:	e9 b5 00 00 00       	jmp    80105e66 <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105db1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105db8:	00 
80105db9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105dc0:	00 
80105dc1:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105dc4:	89 04 24             	mov    %eax,(%esp)
80105dc7:	e8 42 f5 ff ff       	call   8010530e <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105dcc:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105dcf:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105dd6:	00 
80105dd7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ddb:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105dde:	89 44 24 04          	mov    %eax,0x4(%esp)
80105de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de5:	89 04 24             	mov    %eax,(%esp)
80105de8:	e8 44 c4 ff ff       	call   80102231 <writei>
80105ded:	83 f8 10             	cmp    $0x10,%eax
80105df0:	74 0c                	je     80105dfe <sys_unlink+0x154>
    panic("unlink: writei");
80105df2:	c7 04 24 58 8b 10 80 	movl   $0x80108b58,(%esp)
80105df9:	e8 3f a7 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e01:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e05:	66 83 f8 01          	cmp    $0x1,%ax
80105e09:	75 1c                	jne    80105e27 <sys_unlink+0x17d>
    dp->nlink--;
80105e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e12:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e18:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1f:	89 04 24             	mov    %eax,(%esp)
80105e22:	e8 ed bb ff ff       	call   80101a14 <iupdate>
  }
  iunlockput(dp);
80105e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2a:	89 04 24             	mov    %eax,(%esp)
80105e2d:	e8 22 c0 ff ff       	call   80101e54 <iunlockput>

  ip->nlink--;
80105e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e35:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e39:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e3f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e46:	89 04 24             	mov    %eax,(%esp)
80105e49:	e8 c6 bb ff ff       	call   80101a14 <iupdate>
  iunlockput(ip);
80105e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e51:	89 04 24             	mov    %eax,(%esp)
80105e54:	e8 fb bf ff ff       	call   80101e54 <iunlockput>

  commit_trans();
80105e59:	e8 70 d7 ff ff       	call   801035ce <commit_trans>

  return 0;
80105e5e:	b8 00 00 00 00       	mov    $0x0,%eax
80105e63:	eb 16                	jmp    80105e7b <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105e65:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80105e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e69:	89 04 24             	mov    %eax,(%esp)
80105e6c:	e8 e3 bf ff ff       	call   80101e54 <iunlockput>
  commit_trans();
80105e71:	e8 58 d7 ff ff       	call   801035ce <commit_trans>
  return -1;
80105e76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e7b:	c9                   	leave  
80105e7c:	c3                   	ret    

80105e7d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105e7d:	55                   	push   %ebp
80105e7e:	89 e5                	mov    %esp,%ebp
80105e80:	83 ec 48             	sub    $0x48,%esp
80105e83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105e86:	8b 55 10             	mov    0x10(%ebp),%edx
80105e89:	8b 45 14             	mov    0x14(%ebp),%eax
80105e8c:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105e90:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105e94:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105e98:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80105ea2:	89 04 24             	mov    %eax,(%esp)
80105ea5:	e8 ea c8 ff ff       	call   80102794 <nameiparent>
80105eaa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ead:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105eb1:	75 0a                	jne    80105ebd <create+0x40>
    return 0;
80105eb3:	b8 00 00 00 00       	mov    $0x0,%eax
80105eb8:	e9 7e 01 00 00       	jmp    8010603b <create+0x1be>
  ilock(dp);
80105ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec0:	89 04 24             	mov    %eax,(%esp)
80105ec3:	e8 08 bd ff ff       	call   80101bd0 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105ec8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ecb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ecf:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ed2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed9:	89 04 24             	mov    %eax,(%esp)
80105edc:	e8 08 c5 ff ff       	call   801023e9 <dirlookup>
80105ee1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ee4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ee8:	74 47                	je     80105f31 <create+0xb4>
    iunlockput(dp);
80105eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eed:	89 04 24             	mov    %eax,(%esp)
80105ef0:	e8 5f bf ff ff       	call   80101e54 <iunlockput>
    ilock(ip);
80105ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef8:	89 04 24             	mov    %eax,(%esp)
80105efb:	e8 d0 bc ff ff       	call   80101bd0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105f00:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105f05:	75 15                	jne    80105f1c <create+0x9f>
80105f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f0e:	66 83 f8 02          	cmp    $0x2,%ax
80105f12:	75 08                	jne    80105f1c <create+0x9f>
      return ip;
80105f14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f17:	e9 1f 01 00 00       	jmp    8010603b <create+0x1be>
    iunlockput(ip);
80105f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1f:	89 04 24             	mov    %eax,(%esp)
80105f22:	e8 2d bf ff ff       	call   80101e54 <iunlockput>
    return 0;
80105f27:	b8 00 00 00 00       	mov    $0x0,%eax
80105f2c:	e9 0a 01 00 00       	jmp    8010603b <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105f31:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f38:	8b 00                	mov    (%eax),%eax
80105f3a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f3e:	89 04 24             	mov    %eax,(%esp)
80105f41:	e8 f1 b9 ff ff       	call   80101937 <ialloc>
80105f46:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f4d:	75 0c                	jne    80105f5b <create+0xde>
    panic("create: ialloc");
80105f4f:	c7 04 24 67 8b 10 80 	movl   $0x80108b67,(%esp)
80105f56:	e8 e2 a5 ff ff       	call   8010053d <panic>

  ilock(ip);
80105f5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5e:	89 04 24             	mov    %eax,(%esp)
80105f61:	e8 6a bc ff ff       	call   80101bd0 <ilock>
  ip->major = major;
80105f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f69:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105f6d:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105f71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f74:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105f78:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f7f:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f88:	89 04 24             	mov    %eax,(%esp)
80105f8b:	e8 84 ba ff ff       	call   80101a14 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105f90:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105f95:	75 6a                	jne    80106001 <create+0x184>
    dp->nlink++;  // for ".."
80105f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f9a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f9e:	8d 50 01             	lea    0x1(%eax),%edx
80105fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa4:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fab:	89 04 24             	mov    %eax,(%esp)
80105fae:	e8 61 ba ff ff       	call   80101a14 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb6:	8b 40 04             	mov    0x4(%eax),%eax
80105fb9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fbd:	c7 44 24 04 41 8b 10 	movl   $0x80108b41,0x4(%esp)
80105fc4:	80 
80105fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc8:	89 04 24             	mov    %eax,(%esp)
80105fcb:	e8 e1 c4 ff ff       	call   801024b1 <dirlink>
80105fd0:	85 c0                	test   %eax,%eax
80105fd2:	78 21                	js     80105ff5 <create+0x178>
80105fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd7:	8b 40 04             	mov    0x4(%eax),%eax
80105fda:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fde:	c7 44 24 04 43 8b 10 	movl   $0x80108b43,0x4(%esp)
80105fe5:	80 
80105fe6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe9:	89 04 24             	mov    %eax,(%esp)
80105fec:	e8 c0 c4 ff ff       	call   801024b1 <dirlink>
80105ff1:	85 c0                	test   %eax,%eax
80105ff3:	79 0c                	jns    80106001 <create+0x184>
      panic("create dots");
80105ff5:	c7 04 24 76 8b 10 80 	movl   $0x80108b76,(%esp)
80105ffc:	e8 3c a5 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106001:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106004:	8b 40 04             	mov    0x4(%eax),%eax
80106007:	89 44 24 08          	mov    %eax,0x8(%esp)
8010600b:	8d 45 de             	lea    -0x22(%ebp),%eax
8010600e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106012:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106015:	89 04 24             	mov    %eax,(%esp)
80106018:	e8 94 c4 ff ff       	call   801024b1 <dirlink>
8010601d:	85 c0                	test   %eax,%eax
8010601f:	79 0c                	jns    8010602d <create+0x1b0>
    panic("create: dirlink");
80106021:	c7 04 24 82 8b 10 80 	movl   $0x80108b82,(%esp)
80106028:	e8 10 a5 ff ff       	call   8010053d <panic>

  iunlockput(dp);
8010602d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106030:	89 04 24             	mov    %eax,(%esp)
80106033:	e8 1c be ff ff       	call   80101e54 <iunlockput>

  return ip;
80106038:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010603b:	c9                   	leave  
8010603c:	c3                   	ret    

8010603d <sys_open>:

int
sys_open(void)
{
8010603d:	55                   	push   %ebp
8010603e:	89 e5                	mov    %esp,%ebp
80106040:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106043:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106046:	89 44 24 04          	mov    %eax,0x4(%esp)
8010604a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106051:	e8 a2 f6 ff ff       	call   801056f8 <argstr>
80106056:	85 c0                	test   %eax,%eax
80106058:	78 17                	js     80106071 <sys_open+0x34>
8010605a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010605d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106061:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106068:	e8 f1 f5 ff ff       	call   8010565e <argint>
8010606d:	85 c0                	test   %eax,%eax
8010606f:	79 0a                	jns    8010607b <sys_open+0x3e>
    return -1;
80106071:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106076:	e9 46 01 00 00       	jmp    801061c1 <sys_open+0x184>
  if(omode & O_CREATE){
8010607b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010607e:	25 00 02 00 00       	and    $0x200,%eax
80106083:	85 c0                	test   %eax,%eax
80106085:	74 40                	je     801060c7 <sys_open+0x8a>
    begin_trans();
80106087:	e8 f9 d4 ff ff       	call   80103585 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
8010608c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010608f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106096:	00 
80106097:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010609e:	00 
8010609f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801060a6:	00 
801060a7:	89 04 24             	mov    %eax,(%esp)
801060aa:	e8 ce fd ff ff       	call   80105e7d <create>
801060af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
801060b2:	e8 17 d5 ff ff       	call   801035ce <commit_trans>
    if(ip == 0)
801060b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060bb:	75 5c                	jne    80106119 <sys_open+0xdc>
      return -1;
801060bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c2:	e9 fa 00 00 00       	jmp    801061c1 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
801060c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060ca:	89 04 24             	mov    %eax,(%esp)
801060cd:	e8 a0 c6 ff ff       	call   80102772 <namei>
801060d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060d9:	75 0a                	jne    801060e5 <sys_open+0xa8>
      return -1;
801060db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e0:	e9 dc 00 00 00       	jmp    801061c1 <sys_open+0x184>
    ilock(ip);
801060e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e8:	89 04 24             	mov    %eax,(%esp)
801060eb:	e8 e0 ba ff ff       	call   80101bd0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801060f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060f7:	66 83 f8 01          	cmp    $0x1,%ax
801060fb:	75 1c                	jne    80106119 <sys_open+0xdc>
801060fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106100:	85 c0                	test   %eax,%eax
80106102:	74 15                	je     80106119 <sys_open+0xdc>
      iunlockput(ip);
80106104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106107:	89 04 24             	mov    %eax,(%esp)
8010610a:	e8 45 bd ff ff       	call   80101e54 <iunlockput>
      return -1;
8010610f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106114:	e9 a8 00 00 00       	jmp    801061c1 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106119:	e8 66 b1 ff ff       	call   80101284 <filealloc>
8010611e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106121:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106125:	74 14                	je     8010613b <sys_open+0xfe>
80106127:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010612a:	89 04 24             	mov    %eax,(%esp)
8010612d:	e8 43 f7 ff ff       	call   80105875 <fdalloc>
80106132:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106135:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106139:	79 23                	jns    8010615e <sys_open+0x121>
    if(f)
8010613b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010613f:	74 0b                	je     8010614c <sys_open+0x10f>
      fileclose(f);
80106141:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106144:	89 04 24             	mov    %eax,(%esp)
80106147:	e8 e0 b1 ff ff       	call   8010132c <fileclose>
    iunlockput(ip);
8010614c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010614f:	89 04 24             	mov    %eax,(%esp)
80106152:	e8 fd bc ff ff       	call   80101e54 <iunlockput>
    return -1;
80106157:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010615c:	eb 63                	jmp    801061c1 <sys_open+0x184>
  }
  iunlock(ip);
8010615e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106161:	89 04 24             	mov    %eax,(%esp)
80106164:	e8 b5 bb ff ff       	call   80101d1e <iunlock>

  f->type = FD_INODE;
80106169:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010616c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106172:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106175:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106178:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010617b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106185:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106188:	83 e0 01             	and    $0x1,%eax
8010618b:	85 c0                	test   %eax,%eax
8010618d:	0f 94 c2             	sete   %dl
80106190:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106193:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106196:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106199:	83 e0 01             	and    $0x1,%eax
8010619c:	84 c0                	test   %al,%al
8010619e:	75 0a                	jne    801061aa <sys_open+0x16d>
801061a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061a3:	83 e0 02             	and    $0x2,%eax
801061a6:	85 c0                	test   %eax,%eax
801061a8:	74 07                	je     801061b1 <sys_open+0x174>
801061aa:	b8 01 00 00 00       	mov    $0x1,%eax
801061af:	eb 05                	jmp    801061b6 <sys_open+0x179>
801061b1:	b8 00 00 00 00       	mov    $0x0,%eax
801061b6:	89 c2                	mov    %eax,%edx
801061b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061bb:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801061be:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801061c1:	c9                   	leave  
801061c2:	c3                   	ret    

801061c3 <sys_mkdir>:

int
sys_mkdir(void)
{
801061c3:	55                   	push   %ebp
801061c4:	89 e5                	mov    %esp,%ebp
801061c6:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
801061c9:	e8 b7 d3 ff ff       	call   80103585 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801061ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801061d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061dc:	e8 17 f5 ff ff       	call   801056f8 <argstr>
801061e1:	85 c0                	test   %eax,%eax
801061e3:	78 2c                	js     80106211 <sys_mkdir+0x4e>
801061e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801061ef:	00 
801061f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801061f7:	00 
801061f8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801061ff:	00 
80106200:	89 04 24             	mov    %eax,(%esp)
80106203:	e8 75 fc ff ff       	call   80105e7d <create>
80106208:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010620b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010620f:	75 0c                	jne    8010621d <sys_mkdir+0x5a>
    commit_trans();
80106211:	e8 b8 d3 ff ff       	call   801035ce <commit_trans>
    return -1;
80106216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621b:	eb 15                	jmp    80106232 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010621d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106220:	89 04 24             	mov    %eax,(%esp)
80106223:	e8 2c bc ff ff       	call   80101e54 <iunlockput>
  commit_trans();
80106228:	e8 a1 d3 ff ff       	call   801035ce <commit_trans>
  return 0;
8010622d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106232:	c9                   	leave  
80106233:	c3                   	ret    

80106234 <sys_mknod>:

int
sys_mknod(void)
{
80106234:	55                   	push   %ebp
80106235:	89 e5                	mov    %esp,%ebp
80106237:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
8010623a:	e8 46 d3 ff ff       	call   80103585 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
8010623f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106242:	89 44 24 04          	mov    %eax,0x4(%esp)
80106246:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010624d:	e8 a6 f4 ff ff       	call   801056f8 <argstr>
80106252:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106255:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106259:	78 5e                	js     801062b9 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010625b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010625e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106262:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106269:	e8 f0 f3 ff ff       	call   8010565e <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
8010626e:	85 c0                	test   %eax,%eax
80106270:	78 47                	js     801062b9 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106272:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106275:	89 44 24 04          	mov    %eax,0x4(%esp)
80106279:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106280:	e8 d9 f3 ff ff       	call   8010565e <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106285:	85 c0                	test   %eax,%eax
80106287:	78 30                	js     801062b9 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106289:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010628c:	0f bf c8             	movswl %ax,%ecx
8010628f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106292:	0f bf d0             	movswl %ax,%edx
80106295:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106298:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010629c:	89 54 24 08          	mov    %edx,0x8(%esp)
801062a0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801062a7:	00 
801062a8:	89 04 24             	mov    %eax,(%esp)
801062ab:	e8 cd fb ff ff       	call   80105e7d <create>
801062b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062b7:	75 0c                	jne    801062c5 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
801062b9:	e8 10 d3 ff ff       	call   801035ce <commit_trans>
    return -1;
801062be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c3:	eb 15                	jmp    801062da <sys_mknod+0xa6>
  }
  iunlockput(ip);
801062c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062c8:	89 04 24             	mov    %eax,(%esp)
801062cb:	e8 84 bb ff ff       	call   80101e54 <iunlockput>
  commit_trans();
801062d0:	e8 f9 d2 ff ff       	call   801035ce <commit_trans>
  return 0;
801062d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062da:	c9                   	leave  
801062db:	c3                   	ret    

801062dc <sys_chdir>:

int
sys_chdir(void)
{
801062dc:	55                   	push   %ebp
801062dd:	89 e5                	mov    %esp,%ebp
801062df:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
801062e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801062e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062f0:	e8 03 f4 ff ff       	call   801056f8 <argstr>
801062f5:	85 c0                	test   %eax,%eax
801062f7:	78 14                	js     8010630d <sys_chdir+0x31>
801062f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062fc:	89 04 24             	mov    %eax,(%esp)
801062ff:	e8 6e c4 ff ff       	call   80102772 <namei>
80106304:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106307:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010630b:	75 07                	jne    80106314 <sys_chdir+0x38>
    return -1;
8010630d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106312:	eb 57                	jmp    8010636b <sys_chdir+0x8f>
  ilock(ip);
80106314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106317:	89 04 24             	mov    %eax,(%esp)
8010631a:	e8 b1 b8 ff ff       	call   80101bd0 <ilock>
  if(ip->type != T_DIR){
8010631f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106322:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106326:	66 83 f8 01          	cmp    $0x1,%ax
8010632a:	74 12                	je     8010633e <sys_chdir+0x62>
    iunlockput(ip);
8010632c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632f:	89 04 24             	mov    %eax,(%esp)
80106332:	e8 1d bb ff ff       	call   80101e54 <iunlockput>
    return -1;
80106337:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010633c:	eb 2d                	jmp    8010636b <sys_chdir+0x8f>
  }
  iunlock(ip);
8010633e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106341:	89 04 24             	mov    %eax,(%esp)
80106344:	e8 d5 b9 ff ff       	call   80101d1e <iunlock>
  iput(proc->cwd);
80106349:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010634f:	8b 40 68             	mov    0x68(%eax),%eax
80106352:	89 04 24             	mov    %eax,(%esp)
80106355:	e8 29 ba ff ff       	call   80101d83 <iput>
  proc->cwd = ip;
8010635a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106360:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106363:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106366:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010636b:	c9                   	leave  
8010636c:	c3                   	ret    

8010636d <sys_exec>:

int
sys_exec(void)
{
8010636d:	55                   	push   %ebp
8010636e:	89 e5                	mov    %esp,%ebp
80106370:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106376:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106379:	89 44 24 04          	mov    %eax,0x4(%esp)
8010637d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106384:	e8 6f f3 ff ff       	call   801056f8 <argstr>
80106389:	85 c0                	test   %eax,%eax
8010638b:	78 1a                	js     801063a7 <sys_exec+0x3a>
8010638d:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106393:	89 44 24 04          	mov    %eax,0x4(%esp)
80106397:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010639e:	e8 bb f2 ff ff       	call   8010565e <argint>
801063a3:	85 c0                	test   %eax,%eax
801063a5:	79 0a                	jns    801063b1 <sys_exec+0x44>
    return -1;
801063a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ac:	e9 e2 00 00 00       	jmp    80106493 <sys_exec+0x126>
  }
  memset(argv, 0, sizeof(argv));
801063b1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801063b8:	00 
801063b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801063c0:	00 
801063c1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063c7:	89 04 24             	mov    %eax,(%esp)
801063ca:	e8 3f ef ff ff       	call   8010530e <memset>
  for(i=0;; i++){
801063cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801063d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d9:	83 f8 1f             	cmp    $0x1f,%eax
801063dc:	76 0a                	jbe    801063e8 <sys_exec+0x7b>
      return -1;
801063de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063e3:	e9 ab 00 00 00       	jmp    80106493 <sys_exec+0x126>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
801063e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063eb:	c1 e0 02             	shl    $0x2,%eax
801063ee:	89 c2                	mov    %eax,%edx
801063f0:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801063f6:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801063f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063ff:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
80106405:	89 54 24 08          	mov    %edx,0x8(%esp)
80106409:	89 4c 24 04          	mov    %ecx,0x4(%esp)
8010640d:	89 04 24             	mov    %eax,(%esp)
80106410:	e8 b7 f1 ff ff       	call   801055cc <fetchint>
80106415:	85 c0                	test   %eax,%eax
80106417:	79 07                	jns    80106420 <sys_exec+0xb3>
      return -1;
80106419:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010641e:	eb 73                	jmp    80106493 <sys_exec+0x126>
    if(uarg == 0){
80106420:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106426:	85 c0                	test   %eax,%eax
80106428:	75 26                	jne    80106450 <sys_exec+0xe3>
      argv[i] = 0;
8010642a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106434:	00 00 00 00 
      break;
80106438:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106439:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010643c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106442:	89 54 24 04          	mov    %edx,0x4(%esp)
80106446:	89 04 24             	mov    %eax,(%esp)
80106449:	e8 16 aa ff ff       	call   80100e64 <exec>
8010644e:	eb 43                	jmp    80106493 <sys_exec+0x126>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
80106450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106453:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010645a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106460:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80106463:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106469:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010646f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106473:	89 54 24 04          	mov    %edx,0x4(%esp)
80106477:	89 04 24             	mov    %eax,(%esp)
8010647a:	e8 81 f1 ff ff       	call   80105600 <fetchstr>
8010647f:	85 c0                	test   %eax,%eax
80106481:	79 07                	jns    8010648a <sys_exec+0x11d>
      return -1;
80106483:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106488:	eb 09                	jmp    80106493 <sys_exec+0x126>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010648a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
8010648e:	e9 43 ff ff ff       	jmp    801063d6 <sys_exec+0x69>
  return exec(path, argv);
}
80106493:	c9                   	leave  
80106494:	c3                   	ret    

80106495 <sys_pipe>:

int
sys_pipe(void)
{
80106495:	55                   	push   %ebp
80106496:	89 e5                	mov    %esp,%ebp
80106498:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010649b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801064a2:	00 
801064a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801064aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064b1:	e8 e0 f1 ff ff       	call   80105696 <argptr>
801064b6:	85 c0                	test   %eax,%eax
801064b8:	79 0a                	jns    801064c4 <sys_pipe+0x2f>
    return -1;
801064ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064bf:	e9 9b 00 00 00       	jmp    8010655f <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801064c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801064c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801064cb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064ce:	89 04 24             	mov    %eax,(%esp)
801064d1:	e8 ca da ff ff       	call   80103fa0 <pipealloc>
801064d6:	85 c0                	test   %eax,%eax
801064d8:	79 07                	jns    801064e1 <sys_pipe+0x4c>
    return -1;
801064da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064df:	eb 7e                	jmp    8010655f <sys_pipe+0xca>
  fd0 = -1;
801064e1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801064e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064eb:	89 04 24             	mov    %eax,(%esp)
801064ee:	e8 82 f3 ff ff       	call   80105875 <fdalloc>
801064f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064fa:	78 14                	js     80106510 <sys_pipe+0x7b>
801064fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ff:	89 04 24             	mov    %eax,(%esp)
80106502:	e8 6e f3 ff ff       	call   80105875 <fdalloc>
80106507:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010650a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010650e:	79 37                	jns    80106547 <sys_pipe+0xb2>
    if(fd0 >= 0)
80106510:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106514:	78 14                	js     8010652a <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106516:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010651c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010651f:	83 c2 08             	add    $0x8,%edx
80106522:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106529:	00 
    fileclose(rf);
8010652a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010652d:	89 04 24             	mov    %eax,(%esp)
80106530:	e8 f7 ad ff ff       	call   8010132c <fileclose>
    fileclose(wf);
80106535:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106538:	89 04 24             	mov    %eax,(%esp)
8010653b:	e8 ec ad ff ff       	call   8010132c <fileclose>
    return -1;
80106540:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106545:	eb 18                	jmp    8010655f <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106547:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010654a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010654d:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010654f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106552:	8d 50 04             	lea    0x4(%eax),%edx
80106555:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106558:	89 02                	mov    %eax,(%edx)
  return 0;
8010655a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010655f:	c9                   	leave  
80106560:	c3                   	ret    
80106561:	00 00                	add    %al,(%eax)
	...

80106564 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106564:	55                   	push   %ebp
80106565:	89 e5                	mov    %esp,%ebp
80106567:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010656a:	e8 ee e0 ff ff       	call   8010465d <fork>
}
8010656f:	c9                   	leave  
80106570:	c3                   	ret    

80106571 <sys_exit>:

int
sys_exit(void)
{
80106571:	55                   	push   %ebp
80106572:	89 e5                	mov    %esp,%ebp
80106574:	83 ec 08             	sub    $0x8,%esp
  exit();
80106577:	e8 76 e2 ff ff       	call   801047f2 <exit>
  return 0;  // not reached
8010657c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106581:	c9                   	leave  
80106582:	c3                   	ret    

80106583 <sys_wait>:

int
sys_wait(void)
{
80106583:	55                   	push   %ebp
80106584:	89 e5                	mov    %esp,%ebp
80106586:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106589:	e8 a9 e3 ff ff       	call   80104937 <wait>
}
8010658e:	c9                   	leave  
8010658f:	c3                   	ret    

80106590 <sys_wait2>:

int
sys_wait2(void)
{
80106590:	55                   	push   %ebp
80106591:	89 e5                	mov    %esp,%ebp
80106593:	83 ec 28             	sub    $0x28,%esp
  char *rtime=0;
80106596:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  char *wtime=0;
8010659d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  argptr(1,&rtime,sizeof(rtime));
801065a4:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801065ab:	00 
801065ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065af:	89 44 24 04          	mov    %eax,0x4(%esp)
801065b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065ba:	e8 d7 f0 ff ff       	call   80105696 <argptr>
  argptr(0,&wtime,sizeof(wtime));
801065bf:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801065c6:	00 
801065c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801065ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065d5:	e8 bc f0 ff ff       	call   80105696 <argptr>
  return wait2((int*)wtime, (int*)rtime);
801065da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065e0:	89 54 24 04          	mov    %edx,0x4(%esp)
801065e4:	89 04 24             	mov    %eax,(%esp)
801065e7:	e8 5d e4 ff ff       	call   80104a49 <wait2>
}
801065ec:	c9                   	leave  
801065ed:	c3                   	ret    

801065ee <sys_kill>:

int
sys_kill(void)
{
801065ee:	55                   	push   %ebp
801065ef:	89 e5                	mov    %esp,%ebp
801065f1:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801065f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801065fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106602:	e8 57 f0 ff ff       	call   8010565e <argint>
80106607:	85 c0                	test   %eax,%eax
80106609:	79 07                	jns    80106612 <sys_kill+0x24>
    return -1;
8010660b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106610:	eb 0b                	jmp    8010661d <sys_kill+0x2f>
  return kill(pid);
80106612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106615:	89 04 24             	mov    %eax,(%esp)
80106618:	e8 c4 e8 ff ff       	call   80104ee1 <kill>
}
8010661d:	c9                   	leave  
8010661e:	c3                   	ret    

8010661f <sys_getpid>:

int
sys_getpid(void)
{
8010661f:	55                   	push   %ebp
80106620:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106622:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106628:	8b 40 10             	mov    0x10(%eax),%eax
}
8010662b:	5d                   	pop    %ebp
8010662c:	c3                   	ret    

8010662d <sys_sbrk>:

int
sys_sbrk(void)
{
8010662d:	55                   	push   %ebp
8010662e:	89 e5                	mov    %esp,%ebp
80106630:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106633:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106636:	89 44 24 04          	mov    %eax,0x4(%esp)
8010663a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106641:	e8 18 f0 ff ff       	call   8010565e <argint>
80106646:	85 c0                	test   %eax,%eax
80106648:	79 07                	jns    80106651 <sys_sbrk+0x24>
    return -1;
8010664a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010664f:	eb 24                	jmp    80106675 <sys_sbrk+0x48>
  addr = proc->sz;
80106651:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106657:	8b 00                	mov    (%eax),%eax
80106659:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010665c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010665f:	89 04 24             	mov    %eax,(%esp)
80106662:	e8 51 df ff ff       	call   801045b8 <growproc>
80106667:	85 c0                	test   %eax,%eax
80106669:	79 07                	jns    80106672 <sys_sbrk+0x45>
    return -1;
8010666b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106670:	eb 03                	jmp    80106675 <sys_sbrk+0x48>
  return addr;
80106672:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106675:	c9                   	leave  
80106676:	c3                   	ret    

80106677 <sys_sleep>:

int
sys_sleep(void)
{
80106677:	55                   	push   %ebp
80106678:	89 e5                	mov    %esp,%ebp
8010667a:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010667d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106680:	89 44 24 04          	mov    %eax,0x4(%esp)
80106684:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010668b:	e8 ce ef ff ff       	call   8010565e <argint>
80106690:	85 c0                	test   %eax,%eax
80106692:	79 07                	jns    8010669b <sys_sleep+0x24>
    return -1;
80106694:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106699:	eb 6c                	jmp    80106707 <sys_sleep+0x90>
  acquire(&tickslock);
8010669b:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801066a2:	e8 18 ea ff ff       	call   801050bf <acquire>
  ticks0 = ticks;
801066a7:	a1 c0 29 11 80       	mov    0x801129c0,%eax
801066ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801066af:	eb 34                	jmp    801066e5 <sys_sleep+0x6e>
    if(proc->killed){
801066b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066b7:	8b 40 24             	mov    0x24(%eax),%eax
801066ba:	85 c0                	test   %eax,%eax
801066bc:	74 13                	je     801066d1 <sys_sleep+0x5a>
      release(&tickslock);
801066be:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801066c5:	e8 57 ea ff ff       	call   80105121 <release>
      return -1;
801066ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066cf:	eb 36                	jmp    80106707 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801066d1:	c7 44 24 04 80 21 11 	movl   $0x80112180,0x4(%esp)
801066d8:	80 
801066d9:	c7 04 24 c0 29 11 80 	movl   $0x801129c0,(%esp)
801066e0:	e8 f5 e6 ff ff       	call   80104dda <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801066e5:	a1 c0 29 11 80       	mov    0x801129c0,%eax
801066ea:	89 c2                	mov    %eax,%edx
801066ec:	2b 55 f4             	sub    -0xc(%ebp),%edx
801066ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066f2:	39 c2                	cmp    %eax,%edx
801066f4:	72 bb                	jb     801066b1 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801066f6:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801066fd:	e8 1f ea ff ff       	call   80105121 <release>
  return 0;
80106702:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106707:	c9                   	leave  
80106708:	c3                   	ret    

80106709 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106709:	55                   	push   %ebp
8010670a:	89 e5                	mov    %esp,%ebp
8010670c:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
8010670f:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106716:	e8 a4 e9 ff ff       	call   801050bf <acquire>
  xticks = ticks;
8010671b:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80106720:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106723:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
8010672a:	e8 f2 e9 ff ff       	call   80105121 <release>
  return xticks;
8010672f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106732:	c9                   	leave  
80106733:	c3                   	ret    

80106734 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106734:	55                   	push   %ebp
80106735:	89 e5                	mov    %esp,%ebp
80106737:	83 ec 08             	sub    $0x8,%esp
8010673a:	8b 55 08             	mov    0x8(%ebp),%edx
8010673d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106740:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106744:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106747:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010674b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010674f:	ee                   	out    %al,(%dx)
}
80106750:	c9                   	leave  
80106751:	c3                   	ret    

80106752 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106752:	55                   	push   %ebp
80106753:	89 e5                	mov    %esp,%ebp
80106755:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106758:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010675f:	00 
80106760:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106767:	e8 c8 ff ff ff       	call   80106734 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010676c:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106773:	00 
80106774:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010677b:	e8 b4 ff ff ff       	call   80106734 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106780:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106787:	00 
80106788:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010678f:	e8 a0 ff ff ff       	call   80106734 <outb>
  picenable(IRQ_TIMER);
80106794:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010679b:	e8 89 d6 ff ff       	call   80103e29 <picenable>
}
801067a0:	c9                   	leave  
801067a1:	c3                   	ret    
	...

801067a4 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801067a4:	1e                   	push   %ds
  pushl %es
801067a5:	06                   	push   %es
  pushl %fs
801067a6:	0f a0                	push   %fs
  pushl %gs
801067a8:	0f a8                	push   %gs
  pushal
801067aa:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801067ab:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801067af:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801067b1:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801067b3:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801067b7:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801067b9:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801067bb:	54                   	push   %esp
  call trap
801067bc:	e8 de 01 00 00       	call   8010699f <trap>
  addl $4, %esp
801067c1:	83 c4 04             	add    $0x4,%esp

801067c4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801067c4:	61                   	popa   
  popl %gs
801067c5:	0f a9                	pop    %gs
  popl %fs
801067c7:	0f a1                	pop    %fs
  popl %es
801067c9:	07                   	pop    %es
  popl %ds
801067ca:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801067cb:	83 c4 08             	add    $0x8,%esp
  iret
801067ce:	cf                   	iret   
	...

801067d0 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801067d0:	55                   	push   %ebp
801067d1:	89 e5                	mov    %esp,%ebp
801067d3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801067d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801067d9:	83 e8 01             	sub    $0x1,%eax
801067dc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801067e0:	8b 45 08             	mov    0x8(%ebp),%eax
801067e3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801067e7:	8b 45 08             	mov    0x8(%ebp),%eax
801067ea:	c1 e8 10             	shr    $0x10,%eax
801067ed:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801067f1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801067f4:	0f 01 18             	lidtl  (%eax)
}
801067f7:	c9                   	leave  
801067f8:	c3                   	ret    

801067f9 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801067f9:	55                   	push   %ebp
801067fa:	89 e5                	mov    %esp,%ebp
801067fc:	53                   	push   %ebx
801067fd:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106800:	0f 20 d3             	mov    %cr2,%ebx
80106803:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106806:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106809:	83 c4 10             	add    $0x10,%esp
8010680c:	5b                   	pop    %ebx
8010680d:	5d                   	pop    %ebp
8010680e:	c3                   	ret    

8010680f <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010680f:	55                   	push   %ebp
80106810:	89 e5                	mov    %esp,%ebp
80106812:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106815:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010681c:	e9 c3 00 00 00       	jmp    801068e4 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106824:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
8010682b:	89 c2                	mov    %eax,%edx
8010682d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106830:	66 89 14 c5 c0 21 11 	mov    %dx,-0x7feede40(,%eax,8)
80106837:	80 
80106838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010683b:	66 c7 04 c5 c2 21 11 	movw   $0x8,-0x7feede3e(,%eax,8)
80106842:	80 08 00 
80106845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106848:	0f b6 14 c5 c4 21 11 	movzbl -0x7feede3c(,%eax,8),%edx
8010684f:	80 
80106850:	83 e2 e0             	and    $0xffffffe0,%edx
80106853:	88 14 c5 c4 21 11 80 	mov    %dl,-0x7feede3c(,%eax,8)
8010685a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685d:	0f b6 14 c5 c4 21 11 	movzbl -0x7feede3c(,%eax,8),%edx
80106864:	80 
80106865:	83 e2 1f             	and    $0x1f,%edx
80106868:	88 14 c5 c4 21 11 80 	mov    %dl,-0x7feede3c(,%eax,8)
8010686f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106872:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
80106879:	80 
8010687a:	83 e2 f0             	and    $0xfffffff0,%edx
8010687d:	83 ca 0e             	or     $0xe,%edx
80106880:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
80106887:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010688a:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
80106891:	80 
80106892:	83 e2 ef             	and    $0xffffffef,%edx
80106895:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
8010689c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689f:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
801068a6:	80 
801068a7:	83 e2 9f             	and    $0xffffff9f,%edx
801068aa:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
801068b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068b4:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
801068bb:	80 
801068bc:	83 ca 80             	or     $0xffffff80,%edx
801068bf:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
801068c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068c9:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
801068d0:	c1 e8 10             	shr    $0x10,%eax
801068d3:	89 c2                	mov    %eax,%edx
801068d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d8:	66 89 14 c5 c6 21 11 	mov    %dx,-0x7feede3a(,%eax,8)
801068df:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801068e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801068e4:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801068eb:	0f 8e 30 ff ff ff    	jle    80106821 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801068f1:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
801068f6:	66 a3 c0 23 11 80    	mov    %ax,0x801123c0
801068fc:	66 c7 05 c2 23 11 80 	movw   $0x8,0x801123c2
80106903:	08 00 
80106905:	0f b6 05 c4 23 11 80 	movzbl 0x801123c4,%eax
8010690c:	83 e0 e0             	and    $0xffffffe0,%eax
8010690f:	a2 c4 23 11 80       	mov    %al,0x801123c4
80106914:	0f b6 05 c4 23 11 80 	movzbl 0x801123c4,%eax
8010691b:	83 e0 1f             	and    $0x1f,%eax
8010691e:	a2 c4 23 11 80       	mov    %al,0x801123c4
80106923:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
8010692a:	83 c8 0f             	or     $0xf,%eax
8010692d:	a2 c5 23 11 80       	mov    %al,0x801123c5
80106932:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
80106939:	83 e0 ef             	and    $0xffffffef,%eax
8010693c:	a2 c5 23 11 80       	mov    %al,0x801123c5
80106941:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
80106948:	83 c8 60             	or     $0x60,%eax
8010694b:	a2 c5 23 11 80       	mov    %al,0x801123c5
80106950:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
80106957:	83 c8 80             	or     $0xffffff80,%eax
8010695a:	a2 c5 23 11 80       	mov    %al,0x801123c5
8010695f:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
80106964:	c1 e8 10             	shr    $0x10,%eax
80106967:	66 a3 c6 23 11 80    	mov    %ax,0x801123c6
  
  initlock(&tickslock, "time");
8010696d:	c7 44 24 04 94 8b 10 	movl   $0x80108b94,0x4(%esp)
80106974:	80 
80106975:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
8010697c:	e8 1d e7 ff ff       	call   8010509e <initlock>
}
80106981:	c9                   	leave  
80106982:	c3                   	ret    

80106983 <idtinit>:

void
idtinit(void)
{
80106983:	55                   	push   %ebp
80106984:	89 e5                	mov    %esp,%ebp
80106986:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106989:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106990:	00 
80106991:	c7 04 24 c0 21 11 80 	movl   $0x801121c0,(%esp)
80106998:	e8 33 fe ff ff       	call   801067d0 <lidt>
}
8010699d:	c9                   	leave  
8010699e:	c3                   	ret    

8010699f <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010699f:	55                   	push   %ebp
801069a0:	89 e5                	mov    %esp,%ebp
801069a2:	57                   	push   %edi
801069a3:	56                   	push   %esi
801069a4:	53                   	push   %ebx
801069a5:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
801069a8:	8b 45 08             	mov    0x8(%ebp),%eax
801069ab:	8b 40 30             	mov    0x30(%eax),%eax
801069ae:	83 f8 40             	cmp    $0x40,%eax
801069b1:	75 3e                	jne    801069f1 <trap+0x52>
    if(proc->killed)
801069b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069b9:	8b 40 24             	mov    0x24(%eax),%eax
801069bc:	85 c0                	test   %eax,%eax
801069be:	74 05                	je     801069c5 <trap+0x26>
      exit();
801069c0:	e8 2d de ff ff       	call   801047f2 <exit>
    proc->tf = tf;
801069c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069cb:	8b 55 08             	mov    0x8(%ebp),%edx
801069ce:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801069d1:	e8 65 ed ff ff       	call   8010573b <syscall>
    if(proc->killed)
801069d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069dc:	8b 40 24             	mov    0x24(%eax),%eax
801069df:	85 c0                	test   %eax,%eax
801069e1:	0f 84 53 02 00 00    	je     80106c3a <trap+0x29b>
      exit();
801069e7:	e8 06 de ff ff       	call   801047f2 <exit>
    return;
801069ec:	e9 49 02 00 00       	jmp    80106c3a <trap+0x29b>
  }

  switch(tf->trapno){
801069f1:	8b 45 08             	mov    0x8(%ebp),%eax
801069f4:	8b 40 30             	mov    0x30(%eax),%eax
801069f7:	83 e8 20             	sub    $0x20,%eax
801069fa:	83 f8 1f             	cmp    $0x1f,%eax
801069fd:	0f 87 db 00 00 00    	ja     80106ade <trap+0x13f>
80106a03:	8b 04 85 3c 8c 10 80 	mov    -0x7fef73c4(,%eax,4),%eax
80106a0a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106a0c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a12:	0f b6 00             	movzbl (%eax),%eax
80106a15:	84 c0                	test   %al,%al
80106a17:	75 50                	jne    80106a69 <trap+0xca>
      acquire(&tickslock);
80106a19:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106a20:	e8 9a e6 ff ff       	call   801050bf <acquire>
      ticks++;
80106a25:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80106a2a:	83 c0 01             	add    $0x1,%eax
80106a2d:	a3 c0 29 11 80       	mov    %eax,0x801129c0
      if(proc)
80106a32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a38:	85 c0                	test   %eax,%eax
80106a3a:	74 15                	je     80106a51 <trap+0xb2>
	proc->rtime++;
80106a3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a42:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80106a48:	83 c2 01             	add    $0x1,%edx
80106a4b:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
      wakeup(&ticks);
80106a51:	c7 04 24 c0 29 11 80 	movl   $0x801129c0,(%esp)
80106a58:	e8 59 e4 ff ff       	call   80104eb6 <wakeup>
      release(&tickslock);
80106a5d:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106a64:	e8 b8 e6 ff ff       	call   80105121 <release>
    }
    lapiceoi();
80106a69:	e8 e3 c7 ff ff       	call   80103251 <lapiceoi>
    break;
80106a6e:	e9 41 01 00 00       	jmp    80106bb4 <trap+0x215>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106a73:	e8 e1 bf ff ff       	call   80102a59 <ideintr>
    lapiceoi();
80106a78:	e8 d4 c7 ff ff       	call   80103251 <lapiceoi>
    break;
80106a7d:	e9 32 01 00 00       	jmp    80106bb4 <trap+0x215>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106a82:	e8 a8 c5 ff ff       	call   8010302f <kbdintr>
    lapiceoi();
80106a87:	e8 c5 c7 ff ff       	call   80103251 <lapiceoi>
    break;
80106a8c:	e9 23 01 00 00       	jmp    80106bb4 <trap+0x215>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106a91:	e8 aa 03 00 00       	call   80106e40 <uartintr>
    lapiceoi();
80106a96:	e8 b6 c7 ff ff       	call   80103251 <lapiceoi>
    break;
80106a9b:	e9 14 01 00 00       	jmp    80106bb4 <trap+0x215>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106aa0:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106aa3:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106aad:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106ab0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ab6:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ab9:	0f b6 c0             	movzbl %al,%eax
80106abc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106ac0:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ac8:	c7 04 24 9c 8b 10 80 	movl   $0x80108b9c,(%esp)
80106acf:	e8 cd 98 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106ad4:	e8 78 c7 ff ff       	call   80103251 <lapiceoi>
    break;
80106ad9:	e9 d6 00 00 00       	jmp    80106bb4 <trap+0x215>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106ade:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ae4:	85 c0                	test   %eax,%eax
80106ae6:	74 11                	je     80106af9 <trap+0x15a>
80106ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80106aeb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106aef:	0f b7 c0             	movzwl %ax,%eax
80106af2:	83 e0 03             	and    $0x3,%eax
80106af5:	85 c0                	test   %eax,%eax
80106af7:	75 46                	jne    80106b3f <trap+0x1a0>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106af9:	e8 fb fc ff ff       	call   801067f9 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106afe:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b01:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106b04:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106b0b:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b0e:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106b11:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b14:	8b 52 30             	mov    0x30(%edx),%edx
80106b17:	89 44 24 10          	mov    %eax,0x10(%esp)
80106b1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106b1f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106b23:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b27:	c7 04 24 c0 8b 10 80 	movl   $0x80108bc0,(%esp)
80106b2e:	e8 6e 98 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106b33:	c7 04 24 f2 8b 10 80 	movl   $0x80108bf2,(%esp)
80106b3a:	e8 fe 99 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b3f:	e8 b5 fc ff ff       	call   801067f9 <rcr2>
80106b44:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b46:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b49:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b4c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b52:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b55:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b58:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b5b:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b5e:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b61:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b6a:	83 c0 6c             	add    $0x6c,%eax
80106b6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106b70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b76:	8b 40 10             	mov    0x10(%eax),%eax
80106b79:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106b7d:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106b81:	89 74 24 14          	mov    %esi,0x14(%esp)
80106b85:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106b89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106b8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106b90:	89 54 24 08          	mov    %edx,0x8(%esp)
80106b94:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b98:	c7 04 24 f8 8b 10 80 	movl   $0x80108bf8,(%esp)
80106b9f:	e8 fd 97 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106ba4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106baa:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106bb1:	eb 01                	jmp    80106bb4 <trap+0x215>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106bb3:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106bb4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bba:	85 c0                	test   %eax,%eax
80106bbc:	74 24                	je     80106be2 <trap+0x243>
80106bbe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bc4:	8b 40 24             	mov    0x24(%eax),%eax
80106bc7:	85 c0                	test   %eax,%eax
80106bc9:	74 17                	je     80106be2 <trap+0x243>
80106bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80106bce:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bd2:	0f b7 c0             	movzwl %ax,%eax
80106bd5:	83 e0 03             	and    $0x3,%eax
80106bd8:	83 f8 03             	cmp    $0x3,%eax
80106bdb:	75 05                	jne    80106be2 <trap+0x243>
    exit();
80106bdd:	e8 10 dc ff ff       	call   801047f2 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106be2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106be8:	85 c0                	test   %eax,%eax
80106bea:	74 1e                	je     80106c0a <trap+0x26b>
80106bec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bf2:	8b 40 0c             	mov    0xc(%eax),%eax
80106bf5:	83 f8 04             	cmp    $0x4,%eax
80106bf8:	75 10                	jne    80106c0a <trap+0x26b>
80106bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80106bfd:	8b 40 30             	mov    0x30(%eax),%eax
80106c00:	83 f8 20             	cmp    $0x20,%eax
80106c03:	75 05                	jne    80106c0a <trap+0x26b>
    yield();
80106c05:	e8 72 e1 ff ff       	call   80104d7c <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106c0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c10:	85 c0                	test   %eax,%eax
80106c12:	74 27                	je     80106c3b <trap+0x29c>
80106c14:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c1a:	8b 40 24             	mov    0x24(%eax),%eax
80106c1d:	85 c0                	test   %eax,%eax
80106c1f:	74 1a                	je     80106c3b <trap+0x29c>
80106c21:	8b 45 08             	mov    0x8(%ebp),%eax
80106c24:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c28:	0f b7 c0             	movzwl %ax,%eax
80106c2b:	83 e0 03             	and    $0x3,%eax
80106c2e:	83 f8 03             	cmp    $0x3,%eax
80106c31:	75 08                	jne    80106c3b <trap+0x29c>
    exit();
80106c33:	e8 ba db ff ff       	call   801047f2 <exit>
80106c38:	eb 01                	jmp    80106c3b <trap+0x29c>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106c3a:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106c3b:	83 c4 3c             	add    $0x3c,%esp
80106c3e:	5b                   	pop    %ebx
80106c3f:	5e                   	pop    %esi
80106c40:	5f                   	pop    %edi
80106c41:	5d                   	pop    %ebp
80106c42:	c3                   	ret    
	...

80106c44 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106c44:	55                   	push   %ebp
80106c45:	89 e5                	mov    %esp,%ebp
80106c47:	53                   	push   %ebx
80106c48:	83 ec 14             	sub    $0x14,%esp
80106c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c4e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106c52:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106c56:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106c5a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106c5e:	ec                   	in     (%dx),%al
80106c5f:	89 c3                	mov    %eax,%ebx
80106c61:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106c64:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106c68:	83 c4 14             	add    $0x14,%esp
80106c6b:	5b                   	pop    %ebx
80106c6c:	5d                   	pop    %ebp
80106c6d:	c3                   	ret    

80106c6e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c6e:	55                   	push   %ebp
80106c6f:	89 e5                	mov    %esp,%ebp
80106c71:	83 ec 08             	sub    $0x8,%esp
80106c74:	8b 55 08             	mov    0x8(%ebp),%edx
80106c77:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c7a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c7e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c81:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c85:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c89:	ee                   	out    %al,(%dx)
}
80106c8a:	c9                   	leave  
80106c8b:	c3                   	ret    

80106c8c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c8c:	55                   	push   %ebp
80106c8d:	89 e5                	mov    %esp,%ebp
80106c8f:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c92:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c99:	00 
80106c9a:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106ca1:	e8 c8 ff ff ff       	call   80106c6e <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106ca6:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106cad:	00 
80106cae:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106cb5:	e8 b4 ff ff ff       	call   80106c6e <outb>
  outb(COM1+0, 115200/9600);
80106cba:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106cc1:	00 
80106cc2:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cc9:	e8 a0 ff ff ff       	call   80106c6e <outb>
  outb(COM1+1, 0);
80106cce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106cd5:	00 
80106cd6:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106cdd:	e8 8c ff ff ff       	call   80106c6e <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106ce2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106ce9:	00 
80106cea:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106cf1:	e8 78 ff ff ff       	call   80106c6e <outb>
  outb(COM1+4, 0);
80106cf6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106cfd:	00 
80106cfe:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106d05:	e8 64 ff ff ff       	call   80106c6e <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106d0a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106d11:	00 
80106d12:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106d19:	e8 50 ff ff ff       	call   80106c6e <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106d1e:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d25:	e8 1a ff ff ff       	call   80106c44 <inb>
80106d2a:	3c ff                	cmp    $0xff,%al
80106d2c:	74 6c                	je     80106d9a <uartinit+0x10e>
    return;
  uart = 1;
80106d2e:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106d35:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106d38:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106d3f:	e8 00 ff ff ff       	call   80106c44 <inb>
  inb(COM1+0);
80106d44:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d4b:	e8 f4 fe ff ff       	call   80106c44 <inb>
  picenable(IRQ_COM1);
80106d50:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d57:	e8 cd d0 ff ff       	call   80103e29 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106d5c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d63:	00 
80106d64:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d6b:	e8 6e bf ff ff       	call   80102cde <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d70:	c7 45 f4 bc 8c 10 80 	movl   $0x80108cbc,-0xc(%ebp)
80106d77:	eb 15                	jmp    80106d8e <uartinit+0x102>
    uartputc(*p);
80106d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d7c:	0f b6 00             	movzbl (%eax),%eax
80106d7f:	0f be c0             	movsbl %al,%eax
80106d82:	89 04 24             	mov    %eax,(%esp)
80106d85:	e8 13 00 00 00       	call   80106d9d <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d8a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d91:	0f b6 00             	movzbl (%eax),%eax
80106d94:	84 c0                	test   %al,%al
80106d96:	75 e1                	jne    80106d79 <uartinit+0xed>
80106d98:	eb 01                	jmp    80106d9b <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106d9a:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106d9b:	c9                   	leave  
80106d9c:	c3                   	ret    

80106d9d <uartputc>:

void
uartputc(int c)
{
80106d9d:	55                   	push   %ebp
80106d9e:	89 e5                	mov    %esp,%ebp
80106da0:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106da3:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106da8:	85 c0                	test   %eax,%eax
80106daa:	74 4d                	je     80106df9 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106dac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106db3:	eb 10                	jmp    80106dc5 <uartputc+0x28>
    microdelay(10);
80106db5:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106dbc:	e8 b5 c4 ff ff       	call   80103276 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106dc1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106dc5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106dc9:	7f 16                	jg     80106de1 <uartputc+0x44>
80106dcb:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106dd2:	e8 6d fe ff ff       	call   80106c44 <inb>
80106dd7:	0f b6 c0             	movzbl %al,%eax
80106dda:	83 e0 20             	and    $0x20,%eax
80106ddd:	85 c0                	test   %eax,%eax
80106ddf:	74 d4                	je     80106db5 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106de1:	8b 45 08             	mov    0x8(%ebp),%eax
80106de4:	0f b6 c0             	movzbl %al,%eax
80106de7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106deb:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106df2:	e8 77 fe ff ff       	call   80106c6e <outb>
80106df7:	eb 01                	jmp    80106dfa <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106df9:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106dfa:	c9                   	leave  
80106dfb:	c3                   	ret    

80106dfc <uartgetc>:

static int
uartgetc(void)
{
80106dfc:	55                   	push   %ebp
80106dfd:	89 e5                	mov    %esp,%ebp
80106dff:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106e02:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106e07:	85 c0                	test   %eax,%eax
80106e09:	75 07                	jne    80106e12 <uartgetc+0x16>
    return -1;
80106e0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e10:	eb 2c                	jmp    80106e3e <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106e12:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e19:	e8 26 fe ff ff       	call   80106c44 <inb>
80106e1e:	0f b6 c0             	movzbl %al,%eax
80106e21:	83 e0 01             	and    $0x1,%eax
80106e24:	85 c0                	test   %eax,%eax
80106e26:	75 07                	jne    80106e2f <uartgetc+0x33>
    return -1;
80106e28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e2d:	eb 0f                	jmp    80106e3e <uartgetc+0x42>
  return inb(COM1+0);
80106e2f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e36:	e8 09 fe ff ff       	call   80106c44 <inb>
80106e3b:	0f b6 c0             	movzbl %al,%eax
}
80106e3e:	c9                   	leave  
80106e3f:	c3                   	ret    

80106e40 <uartintr>:

void
uartintr(void)
{
80106e40:	55                   	push   %ebp
80106e41:	89 e5                	mov    %esp,%ebp
80106e43:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106e46:	c7 04 24 fc 6d 10 80 	movl   $0x80106dfc,(%esp)
80106e4d:	e8 7c 9a ff ff       	call   801008ce <consoleintr>
}
80106e52:	c9                   	leave  
80106e53:	c3                   	ret    

80106e54 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106e54:	6a 00                	push   $0x0
  pushl $0
80106e56:	6a 00                	push   $0x0
  jmp alltraps
80106e58:	e9 47 f9 ff ff       	jmp    801067a4 <alltraps>

80106e5d <vector1>:
.globl vector1
vector1:
  pushl $0
80106e5d:	6a 00                	push   $0x0
  pushl $1
80106e5f:	6a 01                	push   $0x1
  jmp alltraps
80106e61:	e9 3e f9 ff ff       	jmp    801067a4 <alltraps>

80106e66 <vector2>:
.globl vector2
vector2:
  pushl $0
80106e66:	6a 00                	push   $0x0
  pushl $2
80106e68:	6a 02                	push   $0x2
  jmp alltraps
80106e6a:	e9 35 f9 ff ff       	jmp    801067a4 <alltraps>

80106e6f <vector3>:
.globl vector3
vector3:
  pushl $0
80106e6f:	6a 00                	push   $0x0
  pushl $3
80106e71:	6a 03                	push   $0x3
  jmp alltraps
80106e73:	e9 2c f9 ff ff       	jmp    801067a4 <alltraps>

80106e78 <vector4>:
.globl vector4
vector4:
  pushl $0
80106e78:	6a 00                	push   $0x0
  pushl $4
80106e7a:	6a 04                	push   $0x4
  jmp alltraps
80106e7c:	e9 23 f9 ff ff       	jmp    801067a4 <alltraps>

80106e81 <vector5>:
.globl vector5
vector5:
  pushl $0
80106e81:	6a 00                	push   $0x0
  pushl $5
80106e83:	6a 05                	push   $0x5
  jmp alltraps
80106e85:	e9 1a f9 ff ff       	jmp    801067a4 <alltraps>

80106e8a <vector6>:
.globl vector6
vector6:
  pushl $0
80106e8a:	6a 00                	push   $0x0
  pushl $6
80106e8c:	6a 06                	push   $0x6
  jmp alltraps
80106e8e:	e9 11 f9 ff ff       	jmp    801067a4 <alltraps>

80106e93 <vector7>:
.globl vector7
vector7:
  pushl $0
80106e93:	6a 00                	push   $0x0
  pushl $7
80106e95:	6a 07                	push   $0x7
  jmp alltraps
80106e97:	e9 08 f9 ff ff       	jmp    801067a4 <alltraps>

80106e9c <vector8>:
.globl vector8
vector8:
  pushl $8
80106e9c:	6a 08                	push   $0x8
  jmp alltraps
80106e9e:	e9 01 f9 ff ff       	jmp    801067a4 <alltraps>

80106ea3 <vector9>:
.globl vector9
vector9:
  pushl $0
80106ea3:	6a 00                	push   $0x0
  pushl $9
80106ea5:	6a 09                	push   $0x9
  jmp alltraps
80106ea7:	e9 f8 f8 ff ff       	jmp    801067a4 <alltraps>

80106eac <vector10>:
.globl vector10
vector10:
  pushl $10
80106eac:	6a 0a                	push   $0xa
  jmp alltraps
80106eae:	e9 f1 f8 ff ff       	jmp    801067a4 <alltraps>

80106eb3 <vector11>:
.globl vector11
vector11:
  pushl $11
80106eb3:	6a 0b                	push   $0xb
  jmp alltraps
80106eb5:	e9 ea f8 ff ff       	jmp    801067a4 <alltraps>

80106eba <vector12>:
.globl vector12
vector12:
  pushl $12
80106eba:	6a 0c                	push   $0xc
  jmp alltraps
80106ebc:	e9 e3 f8 ff ff       	jmp    801067a4 <alltraps>

80106ec1 <vector13>:
.globl vector13
vector13:
  pushl $13
80106ec1:	6a 0d                	push   $0xd
  jmp alltraps
80106ec3:	e9 dc f8 ff ff       	jmp    801067a4 <alltraps>

80106ec8 <vector14>:
.globl vector14
vector14:
  pushl $14
80106ec8:	6a 0e                	push   $0xe
  jmp alltraps
80106eca:	e9 d5 f8 ff ff       	jmp    801067a4 <alltraps>

80106ecf <vector15>:
.globl vector15
vector15:
  pushl $0
80106ecf:	6a 00                	push   $0x0
  pushl $15
80106ed1:	6a 0f                	push   $0xf
  jmp alltraps
80106ed3:	e9 cc f8 ff ff       	jmp    801067a4 <alltraps>

80106ed8 <vector16>:
.globl vector16
vector16:
  pushl $0
80106ed8:	6a 00                	push   $0x0
  pushl $16
80106eda:	6a 10                	push   $0x10
  jmp alltraps
80106edc:	e9 c3 f8 ff ff       	jmp    801067a4 <alltraps>

80106ee1 <vector17>:
.globl vector17
vector17:
  pushl $17
80106ee1:	6a 11                	push   $0x11
  jmp alltraps
80106ee3:	e9 bc f8 ff ff       	jmp    801067a4 <alltraps>

80106ee8 <vector18>:
.globl vector18
vector18:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $18
80106eea:	6a 12                	push   $0x12
  jmp alltraps
80106eec:	e9 b3 f8 ff ff       	jmp    801067a4 <alltraps>

80106ef1 <vector19>:
.globl vector19
vector19:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $19
80106ef3:	6a 13                	push   $0x13
  jmp alltraps
80106ef5:	e9 aa f8 ff ff       	jmp    801067a4 <alltraps>

80106efa <vector20>:
.globl vector20
vector20:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $20
80106efc:	6a 14                	push   $0x14
  jmp alltraps
80106efe:	e9 a1 f8 ff ff       	jmp    801067a4 <alltraps>

80106f03 <vector21>:
.globl vector21
vector21:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $21
80106f05:	6a 15                	push   $0x15
  jmp alltraps
80106f07:	e9 98 f8 ff ff       	jmp    801067a4 <alltraps>

80106f0c <vector22>:
.globl vector22
vector22:
  pushl $0
80106f0c:	6a 00                	push   $0x0
  pushl $22
80106f0e:	6a 16                	push   $0x16
  jmp alltraps
80106f10:	e9 8f f8 ff ff       	jmp    801067a4 <alltraps>

80106f15 <vector23>:
.globl vector23
vector23:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $23
80106f17:	6a 17                	push   $0x17
  jmp alltraps
80106f19:	e9 86 f8 ff ff       	jmp    801067a4 <alltraps>

80106f1e <vector24>:
.globl vector24
vector24:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $24
80106f20:	6a 18                	push   $0x18
  jmp alltraps
80106f22:	e9 7d f8 ff ff       	jmp    801067a4 <alltraps>

80106f27 <vector25>:
.globl vector25
vector25:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $25
80106f29:	6a 19                	push   $0x19
  jmp alltraps
80106f2b:	e9 74 f8 ff ff       	jmp    801067a4 <alltraps>

80106f30 <vector26>:
.globl vector26
vector26:
  pushl $0
80106f30:	6a 00                	push   $0x0
  pushl $26
80106f32:	6a 1a                	push   $0x1a
  jmp alltraps
80106f34:	e9 6b f8 ff ff       	jmp    801067a4 <alltraps>

80106f39 <vector27>:
.globl vector27
vector27:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $27
80106f3b:	6a 1b                	push   $0x1b
  jmp alltraps
80106f3d:	e9 62 f8 ff ff       	jmp    801067a4 <alltraps>

80106f42 <vector28>:
.globl vector28
vector28:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $28
80106f44:	6a 1c                	push   $0x1c
  jmp alltraps
80106f46:	e9 59 f8 ff ff       	jmp    801067a4 <alltraps>

80106f4b <vector29>:
.globl vector29
vector29:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $29
80106f4d:	6a 1d                	push   $0x1d
  jmp alltraps
80106f4f:	e9 50 f8 ff ff       	jmp    801067a4 <alltraps>

80106f54 <vector30>:
.globl vector30
vector30:
  pushl $0
80106f54:	6a 00                	push   $0x0
  pushl $30
80106f56:	6a 1e                	push   $0x1e
  jmp alltraps
80106f58:	e9 47 f8 ff ff       	jmp    801067a4 <alltraps>

80106f5d <vector31>:
.globl vector31
vector31:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $31
80106f5f:	6a 1f                	push   $0x1f
  jmp alltraps
80106f61:	e9 3e f8 ff ff       	jmp    801067a4 <alltraps>

80106f66 <vector32>:
.globl vector32
vector32:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $32
80106f68:	6a 20                	push   $0x20
  jmp alltraps
80106f6a:	e9 35 f8 ff ff       	jmp    801067a4 <alltraps>

80106f6f <vector33>:
.globl vector33
vector33:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $33
80106f71:	6a 21                	push   $0x21
  jmp alltraps
80106f73:	e9 2c f8 ff ff       	jmp    801067a4 <alltraps>

80106f78 <vector34>:
.globl vector34
vector34:
  pushl $0
80106f78:	6a 00                	push   $0x0
  pushl $34
80106f7a:	6a 22                	push   $0x22
  jmp alltraps
80106f7c:	e9 23 f8 ff ff       	jmp    801067a4 <alltraps>

80106f81 <vector35>:
.globl vector35
vector35:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $35
80106f83:	6a 23                	push   $0x23
  jmp alltraps
80106f85:	e9 1a f8 ff ff       	jmp    801067a4 <alltraps>

80106f8a <vector36>:
.globl vector36
vector36:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $36
80106f8c:	6a 24                	push   $0x24
  jmp alltraps
80106f8e:	e9 11 f8 ff ff       	jmp    801067a4 <alltraps>

80106f93 <vector37>:
.globl vector37
vector37:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $37
80106f95:	6a 25                	push   $0x25
  jmp alltraps
80106f97:	e9 08 f8 ff ff       	jmp    801067a4 <alltraps>

80106f9c <vector38>:
.globl vector38
vector38:
  pushl $0
80106f9c:	6a 00                	push   $0x0
  pushl $38
80106f9e:	6a 26                	push   $0x26
  jmp alltraps
80106fa0:	e9 ff f7 ff ff       	jmp    801067a4 <alltraps>

80106fa5 <vector39>:
.globl vector39
vector39:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $39
80106fa7:	6a 27                	push   $0x27
  jmp alltraps
80106fa9:	e9 f6 f7 ff ff       	jmp    801067a4 <alltraps>

80106fae <vector40>:
.globl vector40
vector40:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $40
80106fb0:	6a 28                	push   $0x28
  jmp alltraps
80106fb2:	e9 ed f7 ff ff       	jmp    801067a4 <alltraps>

80106fb7 <vector41>:
.globl vector41
vector41:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $41
80106fb9:	6a 29                	push   $0x29
  jmp alltraps
80106fbb:	e9 e4 f7 ff ff       	jmp    801067a4 <alltraps>

80106fc0 <vector42>:
.globl vector42
vector42:
  pushl $0
80106fc0:	6a 00                	push   $0x0
  pushl $42
80106fc2:	6a 2a                	push   $0x2a
  jmp alltraps
80106fc4:	e9 db f7 ff ff       	jmp    801067a4 <alltraps>

80106fc9 <vector43>:
.globl vector43
vector43:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $43
80106fcb:	6a 2b                	push   $0x2b
  jmp alltraps
80106fcd:	e9 d2 f7 ff ff       	jmp    801067a4 <alltraps>

80106fd2 <vector44>:
.globl vector44
vector44:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $44
80106fd4:	6a 2c                	push   $0x2c
  jmp alltraps
80106fd6:	e9 c9 f7 ff ff       	jmp    801067a4 <alltraps>

80106fdb <vector45>:
.globl vector45
vector45:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $45
80106fdd:	6a 2d                	push   $0x2d
  jmp alltraps
80106fdf:	e9 c0 f7 ff ff       	jmp    801067a4 <alltraps>

80106fe4 <vector46>:
.globl vector46
vector46:
  pushl $0
80106fe4:	6a 00                	push   $0x0
  pushl $46
80106fe6:	6a 2e                	push   $0x2e
  jmp alltraps
80106fe8:	e9 b7 f7 ff ff       	jmp    801067a4 <alltraps>

80106fed <vector47>:
.globl vector47
vector47:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $47
80106fef:	6a 2f                	push   $0x2f
  jmp alltraps
80106ff1:	e9 ae f7 ff ff       	jmp    801067a4 <alltraps>

80106ff6 <vector48>:
.globl vector48
vector48:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $48
80106ff8:	6a 30                	push   $0x30
  jmp alltraps
80106ffa:	e9 a5 f7 ff ff       	jmp    801067a4 <alltraps>

80106fff <vector49>:
.globl vector49
vector49:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $49
80107001:	6a 31                	push   $0x31
  jmp alltraps
80107003:	e9 9c f7 ff ff       	jmp    801067a4 <alltraps>

80107008 <vector50>:
.globl vector50
vector50:
  pushl $0
80107008:	6a 00                	push   $0x0
  pushl $50
8010700a:	6a 32                	push   $0x32
  jmp alltraps
8010700c:	e9 93 f7 ff ff       	jmp    801067a4 <alltraps>

80107011 <vector51>:
.globl vector51
vector51:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $51
80107013:	6a 33                	push   $0x33
  jmp alltraps
80107015:	e9 8a f7 ff ff       	jmp    801067a4 <alltraps>

8010701a <vector52>:
.globl vector52
vector52:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $52
8010701c:	6a 34                	push   $0x34
  jmp alltraps
8010701e:	e9 81 f7 ff ff       	jmp    801067a4 <alltraps>

80107023 <vector53>:
.globl vector53
vector53:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $53
80107025:	6a 35                	push   $0x35
  jmp alltraps
80107027:	e9 78 f7 ff ff       	jmp    801067a4 <alltraps>

8010702c <vector54>:
.globl vector54
vector54:
  pushl $0
8010702c:	6a 00                	push   $0x0
  pushl $54
8010702e:	6a 36                	push   $0x36
  jmp alltraps
80107030:	e9 6f f7 ff ff       	jmp    801067a4 <alltraps>

80107035 <vector55>:
.globl vector55
vector55:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $55
80107037:	6a 37                	push   $0x37
  jmp alltraps
80107039:	e9 66 f7 ff ff       	jmp    801067a4 <alltraps>

8010703e <vector56>:
.globl vector56
vector56:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $56
80107040:	6a 38                	push   $0x38
  jmp alltraps
80107042:	e9 5d f7 ff ff       	jmp    801067a4 <alltraps>

80107047 <vector57>:
.globl vector57
vector57:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $57
80107049:	6a 39                	push   $0x39
  jmp alltraps
8010704b:	e9 54 f7 ff ff       	jmp    801067a4 <alltraps>

80107050 <vector58>:
.globl vector58
vector58:
  pushl $0
80107050:	6a 00                	push   $0x0
  pushl $58
80107052:	6a 3a                	push   $0x3a
  jmp alltraps
80107054:	e9 4b f7 ff ff       	jmp    801067a4 <alltraps>

80107059 <vector59>:
.globl vector59
vector59:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $59
8010705b:	6a 3b                	push   $0x3b
  jmp alltraps
8010705d:	e9 42 f7 ff ff       	jmp    801067a4 <alltraps>

80107062 <vector60>:
.globl vector60
vector60:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $60
80107064:	6a 3c                	push   $0x3c
  jmp alltraps
80107066:	e9 39 f7 ff ff       	jmp    801067a4 <alltraps>

8010706b <vector61>:
.globl vector61
vector61:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $61
8010706d:	6a 3d                	push   $0x3d
  jmp alltraps
8010706f:	e9 30 f7 ff ff       	jmp    801067a4 <alltraps>

80107074 <vector62>:
.globl vector62
vector62:
  pushl $0
80107074:	6a 00                	push   $0x0
  pushl $62
80107076:	6a 3e                	push   $0x3e
  jmp alltraps
80107078:	e9 27 f7 ff ff       	jmp    801067a4 <alltraps>

8010707d <vector63>:
.globl vector63
vector63:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $63
8010707f:	6a 3f                	push   $0x3f
  jmp alltraps
80107081:	e9 1e f7 ff ff       	jmp    801067a4 <alltraps>

80107086 <vector64>:
.globl vector64
vector64:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $64
80107088:	6a 40                	push   $0x40
  jmp alltraps
8010708a:	e9 15 f7 ff ff       	jmp    801067a4 <alltraps>

8010708f <vector65>:
.globl vector65
vector65:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $65
80107091:	6a 41                	push   $0x41
  jmp alltraps
80107093:	e9 0c f7 ff ff       	jmp    801067a4 <alltraps>

80107098 <vector66>:
.globl vector66
vector66:
  pushl $0
80107098:	6a 00                	push   $0x0
  pushl $66
8010709a:	6a 42                	push   $0x42
  jmp alltraps
8010709c:	e9 03 f7 ff ff       	jmp    801067a4 <alltraps>

801070a1 <vector67>:
.globl vector67
vector67:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $67
801070a3:	6a 43                	push   $0x43
  jmp alltraps
801070a5:	e9 fa f6 ff ff       	jmp    801067a4 <alltraps>

801070aa <vector68>:
.globl vector68
vector68:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $68
801070ac:	6a 44                	push   $0x44
  jmp alltraps
801070ae:	e9 f1 f6 ff ff       	jmp    801067a4 <alltraps>

801070b3 <vector69>:
.globl vector69
vector69:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $69
801070b5:	6a 45                	push   $0x45
  jmp alltraps
801070b7:	e9 e8 f6 ff ff       	jmp    801067a4 <alltraps>

801070bc <vector70>:
.globl vector70
vector70:
  pushl $0
801070bc:	6a 00                	push   $0x0
  pushl $70
801070be:	6a 46                	push   $0x46
  jmp alltraps
801070c0:	e9 df f6 ff ff       	jmp    801067a4 <alltraps>

801070c5 <vector71>:
.globl vector71
vector71:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $71
801070c7:	6a 47                	push   $0x47
  jmp alltraps
801070c9:	e9 d6 f6 ff ff       	jmp    801067a4 <alltraps>

801070ce <vector72>:
.globl vector72
vector72:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $72
801070d0:	6a 48                	push   $0x48
  jmp alltraps
801070d2:	e9 cd f6 ff ff       	jmp    801067a4 <alltraps>

801070d7 <vector73>:
.globl vector73
vector73:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $73
801070d9:	6a 49                	push   $0x49
  jmp alltraps
801070db:	e9 c4 f6 ff ff       	jmp    801067a4 <alltraps>

801070e0 <vector74>:
.globl vector74
vector74:
  pushl $0
801070e0:	6a 00                	push   $0x0
  pushl $74
801070e2:	6a 4a                	push   $0x4a
  jmp alltraps
801070e4:	e9 bb f6 ff ff       	jmp    801067a4 <alltraps>

801070e9 <vector75>:
.globl vector75
vector75:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $75
801070eb:	6a 4b                	push   $0x4b
  jmp alltraps
801070ed:	e9 b2 f6 ff ff       	jmp    801067a4 <alltraps>

801070f2 <vector76>:
.globl vector76
vector76:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $76
801070f4:	6a 4c                	push   $0x4c
  jmp alltraps
801070f6:	e9 a9 f6 ff ff       	jmp    801067a4 <alltraps>

801070fb <vector77>:
.globl vector77
vector77:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $77
801070fd:	6a 4d                	push   $0x4d
  jmp alltraps
801070ff:	e9 a0 f6 ff ff       	jmp    801067a4 <alltraps>

80107104 <vector78>:
.globl vector78
vector78:
  pushl $0
80107104:	6a 00                	push   $0x0
  pushl $78
80107106:	6a 4e                	push   $0x4e
  jmp alltraps
80107108:	e9 97 f6 ff ff       	jmp    801067a4 <alltraps>

8010710d <vector79>:
.globl vector79
vector79:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $79
8010710f:	6a 4f                	push   $0x4f
  jmp alltraps
80107111:	e9 8e f6 ff ff       	jmp    801067a4 <alltraps>

80107116 <vector80>:
.globl vector80
vector80:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $80
80107118:	6a 50                	push   $0x50
  jmp alltraps
8010711a:	e9 85 f6 ff ff       	jmp    801067a4 <alltraps>

8010711f <vector81>:
.globl vector81
vector81:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $81
80107121:	6a 51                	push   $0x51
  jmp alltraps
80107123:	e9 7c f6 ff ff       	jmp    801067a4 <alltraps>

80107128 <vector82>:
.globl vector82
vector82:
  pushl $0
80107128:	6a 00                	push   $0x0
  pushl $82
8010712a:	6a 52                	push   $0x52
  jmp alltraps
8010712c:	e9 73 f6 ff ff       	jmp    801067a4 <alltraps>

80107131 <vector83>:
.globl vector83
vector83:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $83
80107133:	6a 53                	push   $0x53
  jmp alltraps
80107135:	e9 6a f6 ff ff       	jmp    801067a4 <alltraps>

8010713a <vector84>:
.globl vector84
vector84:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $84
8010713c:	6a 54                	push   $0x54
  jmp alltraps
8010713e:	e9 61 f6 ff ff       	jmp    801067a4 <alltraps>

80107143 <vector85>:
.globl vector85
vector85:
  pushl $0
80107143:	6a 00                	push   $0x0
  pushl $85
80107145:	6a 55                	push   $0x55
  jmp alltraps
80107147:	e9 58 f6 ff ff       	jmp    801067a4 <alltraps>

8010714c <vector86>:
.globl vector86
vector86:
  pushl $0
8010714c:	6a 00                	push   $0x0
  pushl $86
8010714e:	6a 56                	push   $0x56
  jmp alltraps
80107150:	e9 4f f6 ff ff       	jmp    801067a4 <alltraps>

80107155 <vector87>:
.globl vector87
vector87:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $87
80107157:	6a 57                	push   $0x57
  jmp alltraps
80107159:	e9 46 f6 ff ff       	jmp    801067a4 <alltraps>

8010715e <vector88>:
.globl vector88
vector88:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $88
80107160:	6a 58                	push   $0x58
  jmp alltraps
80107162:	e9 3d f6 ff ff       	jmp    801067a4 <alltraps>

80107167 <vector89>:
.globl vector89
vector89:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $89
80107169:	6a 59                	push   $0x59
  jmp alltraps
8010716b:	e9 34 f6 ff ff       	jmp    801067a4 <alltraps>

80107170 <vector90>:
.globl vector90
vector90:
  pushl $0
80107170:	6a 00                	push   $0x0
  pushl $90
80107172:	6a 5a                	push   $0x5a
  jmp alltraps
80107174:	e9 2b f6 ff ff       	jmp    801067a4 <alltraps>

80107179 <vector91>:
.globl vector91
vector91:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $91
8010717b:	6a 5b                	push   $0x5b
  jmp alltraps
8010717d:	e9 22 f6 ff ff       	jmp    801067a4 <alltraps>

80107182 <vector92>:
.globl vector92
vector92:
  pushl $0
80107182:	6a 00                	push   $0x0
  pushl $92
80107184:	6a 5c                	push   $0x5c
  jmp alltraps
80107186:	e9 19 f6 ff ff       	jmp    801067a4 <alltraps>

8010718b <vector93>:
.globl vector93
vector93:
  pushl $0
8010718b:	6a 00                	push   $0x0
  pushl $93
8010718d:	6a 5d                	push   $0x5d
  jmp alltraps
8010718f:	e9 10 f6 ff ff       	jmp    801067a4 <alltraps>

80107194 <vector94>:
.globl vector94
vector94:
  pushl $0
80107194:	6a 00                	push   $0x0
  pushl $94
80107196:	6a 5e                	push   $0x5e
  jmp alltraps
80107198:	e9 07 f6 ff ff       	jmp    801067a4 <alltraps>

8010719d <vector95>:
.globl vector95
vector95:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $95
8010719f:	6a 5f                	push   $0x5f
  jmp alltraps
801071a1:	e9 fe f5 ff ff       	jmp    801067a4 <alltraps>

801071a6 <vector96>:
.globl vector96
vector96:
  pushl $0
801071a6:	6a 00                	push   $0x0
  pushl $96
801071a8:	6a 60                	push   $0x60
  jmp alltraps
801071aa:	e9 f5 f5 ff ff       	jmp    801067a4 <alltraps>

801071af <vector97>:
.globl vector97
vector97:
  pushl $0
801071af:	6a 00                	push   $0x0
  pushl $97
801071b1:	6a 61                	push   $0x61
  jmp alltraps
801071b3:	e9 ec f5 ff ff       	jmp    801067a4 <alltraps>

801071b8 <vector98>:
.globl vector98
vector98:
  pushl $0
801071b8:	6a 00                	push   $0x0
  pushl $98
801071ba:	6a 62                	push   $0x62
  jmp alltraps
801071bc:	e9 e3 f5 ff ff       	jmp    801067a4 <alltraps>

801071c1 <vector99>:
.globl vector99
vector99:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $99
801071c3:	6a 63                	push   $0x63
  jmp alltraps
801071c5:	e9 da f5 ff ff       	jmp    801067a4 <alltraps>

801071ca <vector100>:
.globl vector100
vector100:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $100
801071cc:	6a 64                	push   $0x64
  jmp alltraps
801071ce:	e9 d1 f5 ff ff       	jmp    801067a4 <alltraps>

801071d3 <vector101>:
.globl vector101
vector101:
  pushl $0
801071d3:	6a 00                	push   $0x0
  pushl $101
801071d5:	6a 65                	push   $0x65
  jmp alltraps
801071d7:	e9 c8 f5 ff ff       	jmp    801067a4 <alltraps>

801071dc <vector102>:
.globl vector102
vector102:
  pushl $0
801071dc:	6a 00                	push   $0x0
  pushl $102
801071de:	6a 66                	push   $0x66
  jmp alltraps
801071e0:	e9 bf f5 ff ff       	jmp    801067a4 <alltraps>

801071e5 <vector103>:
.globl vector103
vector103:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $103
801071e7:	6a 67                	push   $0x67
  jmp alltraps
801071e9:	e9 b6 f5 ff ff       	jmp    801067a4 <alltraps>

801071ee <vector104>:
.globl vector104
vector104:
  pushl $0
801071ee:	6a 00                	push   $0x0
  pushl $104
801071f0:	6a 68                	push   $0x68
  jmp alltraps
801071f2:	e9 ad f5 ff ff       	jmp    801067a4 <alltraps>

801071f7 <vector105>:
.globl vector105
vector105:
  pushl $0
801071f7:	6a 00                	push   $0x0
  pushl $105
801071f9:	6a 69                	push   $0x69
  jmp alltraps
801071fb:	e9 a4 f5 ff ff       	jmp    801067a4 <alltraps>

80107200 <vector106>:
.globl vector106
vector106:
  pushl $0
80107200:	6a 00                	push   $0x0
  pushl $106
80107202:	6a 6a                	push   $0x6a
  jmp alltraps
80107204:	e9 9b f5 ff ff       	jmp    801067a4 <alltraps>

80107209 <vector107>:
.globl vector107
vector107:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $107
8010720b:	6a 6b                	push   $0x6b
  jmp alltraps
8010720d:	e9 92 f5 ff ff       	jmp    801067a4 <alltraps>

80107212 <vector108>:
.globl vector108
vector108:
  pushl $0
80107212:	6a 00                	push   $0x0
  pushl $108
80107214:	6a 6c                	push   $0x6c
  jmp alltraps
80107216:	e9 89 f5 ff ff       	jmp    801067a4 <alltraps>

8010721b <vector109>:
.globl vector109
vector109:
  pushl $0
8010721b:	6a 00                	push   $0x0
  pushl $109
8010721d:	6a 6d                	push   $0x6d
  jmp alltraps
8010721f:	e9 80 f5 ff ff       	jmp    801067a4 <alltraps>

80107224 <vector110>:
.globl vector110
vector110:
  pushl $0
80107224:	6a 00                	push   $0x0
  pushl $110
80107226:	6a 6e                	push   $0x6e
  jmp alltraps
80107228:	e9 77 f5 ff ff       	jmp    801067a4 <alltraps>

8010722d <vector111>:
.globl vector111
vector111:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $111
8010722f:	6a 6f                	push   $0x6f
  jmp alltraps
80107231:	e9 6e f5 ff ff       	jmp    801067a4 <alltraps>

80107236 <vector112>:
.globl vector112
vector112:
  pushl $0
80107236:	6a 00                	push   $0x0
  pushl $112
80107238:	6a 70                	push   $0x70
  jmp alltraps
8010723a:	e9 65 f5 ff ff       	jmp    801067a4 <alltraps>

8010723f <vector113>:
.globl vector113
vector113:
  pushl $0
8010723f:	6a 00                	push   $0x0
  pushl $113
80107241:	6a 71                	push   $0x71
  jmp alltraps
80107243:	e9 5c f5 ff ff       	jmp    801067a4 <alltraps>

80107248 <vector114>:
.globl vector114
vector114:
  pushl $0
80107248:	6a 00                	push   $0x0
  pushl $114
8010724a:	6a 72                	push   $0x72
  jmp alltraps
8010724c:	e9 53 f5 ff ff       	jmp    801067a4 <alltraps>

80107251 <vector115>:
.globl vector115
vector115:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $115
80107253:	6a 73                	push   $0x73
  jmp alltraps
80107255:	e9 4a f5 ff ff       	jmp    801067a4 <alltraps>

8010725a <vector116>:
.globl vector116
vector116:
  pushl $0
8010725a:	6a 00                	push   $0x0
  pushl $116
8010725c:	6a 74                	push   $0x74
  jmp alltraps
8010725e:	e9 41 f5 ff ff       	jmp    801067a4 <alltraps>

80107263 <vector117>:
.globl vector117
vector117:
  pushl $0
80107263:	6a 00                	push   $0x0
  pushl $117
80107265:	6a 75                	push   $0x75
  jmp alltraps
80107267:	e9 38 f5 ff ff       	jmp    801067a4 <alltraps>

8010726c <vector118>:
.globl vector118
vector118:
  pushl $0
8010726c:	6a 00                	push   $0x0
  pushl $118
8010726e:	6a 76                	push   $0x76
  jmp alltraps
80107270:	e9 2f f5 ff ff       	jmp    801067a4 <alltraps>

80107275 <vector119>:
.globl vector119
vector119:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $119
80107277:	6a 77                	push   $0x77
  jmp alltraps
80107279:	e9 26 f5 ff ff       	jmp    801067a4 <alltraps>

8010727e <vector120>:
.globl vector120
vector120:
  pushl $0
8010727e:	6a 00                	push   $0x0
  pushl $120
80107280:	6a 78                	push   $0x78
  jmp alltraps
80107282:	e9 1d f5 ff ff       	jmp    801067a4 <alltraps>

80107287 <vector121>:
.globl vector121
vector121:
  pushl $0
80107287:	6a 00                	push   $0x0
  pushl $121
80107289:	6a 79                	push   $0x79
  jmp alltraps
8010728b:	e9 14 f5 ff ff       	jmp    801067a4 <alltraps>

80107290 <vector122>:
.globl vector122
vector122:
  pushl $0
80107290:	6a 00                	push   $0x0
  pushl $122
80107292:	6a 7a                	push   $0x7a
  jmp alltraps
80107294:	e9 0b f5 ff ff       	jmp    801067a4 <alltraps>

80107299 <vector123>:
.globl vector123
vector123:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $123
8010729b:	6a 7b                	push   $0x7b
  jmp alltraps
8010729d:	e9 02 f5 ff ff       	jmp    801067a4 <alltraps>

801072a2 <vector124>:
.globl vector124
vector124:
  pushl $0
801072a2:	6a 00                	push   $0x0
  pushl $124
801072a4:	6a 7c                	push   $0x7c
  jmp alltraps
801072a6:	e9 f9 f4 ff ff       	jmp    801067a4 <alltraps>

801072ab <vector125>:
.globl vector125
vector125:
  pushl $0
801072ab:	6a 00                	push   $0x0
  pushl $125
801072ad:	6a 7d                	push   $0x7d
  jmp alltraps
801072af:	e9 f0 f4 ff ff       	jmp    801067a4 <alltraps>

801072b4 <vector126>:
.globl vector126
vector126:
  pushl $0
801072b4:	6a 00                	push   $0x0
  pushl $126
801072b6:	6a 7e                	push   $0x7e
  jmp alltraps
801072b8:	e9 e7 f4 ff ff       	jmp    801067a4 <alltraps>

801072bd <vector127>:
.globl vector127
vector127:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $127
801072bf:	6a 7f                	push   $0x7f
  jmp alltraps
801072c1:	e9 de f4 ff ff       	jmp    801067a4 <alltraps>

801072c6 <vector128>:
.globl vector128
vector128:
  pushl $0
801072c6:	6a 00                	push   $0x0
  pushl $128
801072c8:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801072cd:	e9 d2 f4 ff ff       	jmp    801067a4 <alltraps>

801072d2 <vector129>:
.globl vector129
vector129:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $129
801072d4:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801072d9:	e9 c6 f4 ff ff       	jmp    801067a4 <alltraps>

801072de <vector130>:
.globl vector130
vector130:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $130
801072e0:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801072e5:	e9 ba f4 ff ff       	jmp    801067a4 <alltraps>

801072ea <vector131>:
.globl vector131
vector131:
  pushl $0
801072ea:	6a 00                	push   $0x0
  pushl $131
801072ec:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801072f1:	e9 ae f4 ff ff       	jmp    801067a4 <alltraps>

801072f6 <vector132>:
.globl vector132
vector132:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $132
801072f8:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801072fd:	e9 a2 f4 ff ff       	jmp    801067a4 <alltraps>

80107302 <vector133>:
.globl vector133
vector133:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $133
80107304:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107309:	e9 96 f4 ff ff       	jmp    801067a4 <alltraps>

8010730e <vector134>:
.globl vector134
vector134:
  pushl $0
8010730e:	6a 00                	push   $0x0
  pushl $134
80107310:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107315:	e9 8a f4 ff ff       	jmp    801067a4 <alltraps>

8010731a <vector135>:
.globl vector135
vector135:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $135
8010731c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107321:	e9 7e f4 ff ff       	jmp    801067a4 <alltraps>

80107326 <vector136>:
.globl vector136
vector136:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $136
80107328:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010732d:	e9 72 f4 ff ff       	jmp    801067a4 <alltraps>

80107332 <vector137>:
.globl vector137
vector137:
  pushl $0
80107332:	6a 00                	push   $0x0
  pushl $137
80107334:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107339:	e9 66 f4 ff ff       	jmp    801067a4 <alltraps>

8010733e <vector138>:
.globl vector138
vector138:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $138
80107340:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107345:	e9 5a f4 ff ff       	jmp    801067a4 <alltraps>

8010734a <vector139>:
.globl vector139
vector139:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $139
8010734c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107351:	e9 4e f4 ff ff       	jmp    801067a4 <alltraps>

80107356 <vector140>:
.globl vector140
vector140:
  pushl $0
80107356:	6a 00                	push   $0x0
  pushl $140
80107358:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010735d:	e9 42 f4 ff ff       	jmp    801067a4 <alltraps>

80107362 <vector141>:
.globl vector141
vector141:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $141
80107364:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107369:	e9 36 f4 ff ff       	jmp    801067a4 <alltraps>

8010736e <vector142>:
.globl vector142
vector142:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $142
80107370:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107375:	e9 2a f4 ff ff       	jmp    801067a4 <alltraps>

8010737a <vector143>:
.globl vector143
vector143:
  pushl $0
8010737a:	6a 00                	push   $0x0
  pushl $143
8010737c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107381:	e9 1e f4 ff ff       	jmp    801067a4 <alltraps>

80107386 <vector144>:
.globl vector144
vector144:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $144
80107388:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010738d:	e9 12 f4 ff ff       	jmp    801067a4 <alltraps>

80107392 <vector145>:
.globl vector145
vector145:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $145
80107394:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107399:	e9 06 f4 ff ff       	jmp    801067a4 <alltraps>

8010739e <vector146>:
.globl vector146
vector146:
  pushl $0
8010739e:	6a 00                	push   $0x0
  pushl $146
801073a0:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801073a5:	e9 fa f3 ff ff       	jmp    801067a4 <alltraps>

801073aa <vector147>:
.globl vector147
vector147:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $147
801073ac:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801073b1:	e9 ee f3 ff ff       	jmp    801067a4 <alltraps>

801073b6 <vector148>:
.globl vector148
vector148:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $148
801073b8:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801073bd:	e9 e2 f3 ff ff       	jmp    801067a4 <alltraps>

801073c2 <vector149>:
.globl vector149
vector149:
  pushl $0
801073c2:	6a 00                	push   $0x0
  pushl $149
801073c4:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801073c9:	e9 d6 f3 ff ff       	jmp    801067a4 <alltraps>

801073ce <vector150>:
.globl vector150
vector150:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $150
801073d0:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801073d5:	e9 ca f3 ff ff       	jmp    801067a4 <alltraps>

801073da <vector151>:
.globl vector151
vector151:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $151
801073dc:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801073e1:	e9 be f3 ff ff       	jmp    801067a4 <alltraps>

801073e6 <vector152>:
.globl vector152
vector152:
  pushl $0
801073e6:	6a 00                	push   $0x0
  pushl $152
801073e8:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801073ed:	e9 b2 f3 ff ff       	jmp    801067a4 <alltraps>

801073f2 <vector153>:
.globl vector153
vector153:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $153
801073f4:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801073f9:	e9 a6 f3 ff ff       	jmp    801067a4 <alltraps>

801073fe <vector154>:
.globl vector154
vector154:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $154
80107400:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107405:	e9 9a f3 ff ff       	jmp    801067a4 <alltraps>

8010740a <vector155>:
.globl vector155
vector155:
  pushl $0
8010740a:	6a 00                	push   $0x0
  pushl $155
8010740c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107411:	e9 8e f3 ff ff       	jmp    801067a4 <alltraps>

80107416 <vector156>:
.globl vector156
vector156:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $156
80107418:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010741d:	e9 82 f3 ff ff       	jmp    801067a4 <alltraps>

80107422 <vector157>:
.globl vector157
vector157:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $157
80107424:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107429:	e9 76 f3 ff ff       	jmp    801067a4 <alltraps>

8010742e <vector158>:
.globl vector158
vector158:
  pushl $0
8010742e:	6a 00                	push   $0x0
  pushl $158
80107430:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107435:	e9 6a f3 ff ff       	jmp    801067a4 <alltraps>

8010743a <vector159>:
.globl vector159
vector159:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $159
8010743c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107441:	e9 5e f3 ff ff       	jmp    801067a4 <alltraps>

80107446 <vector160>:
.globl vector160
vector160:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $160
80107448:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010744d:	e9 52 f3 ff ff       	jmp    801067a4 <alltraps>

80107452 <vector161>:
.globl vector161
vector161:
  pushl $0
80107452:	6a 00                	push   $0x0
  pushl $161
80107454:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107459:	e9 46 f3 ff ff       	jmp    801067a4 <alltraps>

8010745e <vector162>:
.globl vector162
vector162:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $162
80107460:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107465:	e9 3a f3 ff ff       	jmp    801067a4 <alltraps>

8010746a <vector163>:
.globl vector163
vector163:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $163
8010746c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107471:	e9 2e f3 ff ff       	jmp    801067a4 <alltraps>

80107476 <vector164>:
.globl vector164
vector164:
  pushl $0
80107476:	6a 00                	push   $0x0
  pushl $164
80107478:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010747d:	e9 22 f3 ff ff       	jmp    801067a4 <alltraps>

80107482 <vector165>:
.globl vector165
vector165:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $165
80107484:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107489:	e9 16 f3 ff ff       	jmp    801067a4 <alltraps>

8010748e <vector166>:
.globl vector166
vector166:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $166
80107490:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107495:	e9 0a f3 ff ff       	jmp    801067a4 <alltraps>

8010749a <vector167>:
.globl vector167
vector167:
  pushl $0
8010749a:	6a 00                	push   $0x0
  pushl $167
8010749c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801074a1:	e9 fe f2 ff ff       	jmp    801067a4 <alltraps>

801074a6 <vector168>:
.globl vector168
vector168:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $168
801074a8:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801074ad:	e9 f2 f2 ff ff       	jmp    801067a4 <alltraps>

801074b2 <vector169>:
.globl vector169
vector169:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $169
801074b4:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801074b9:	e9 e6 f2 ff ff       	jmp    801067a4 <alltraps>

801074be <vector170>:
.globl vector170
vector170:
  pushl $0
801074be:	6a 00                	push   $0x0
  pushl $170
801074c0:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801074c5:	e9 da f2 ff ff       	jmp    801067a4 <alltraps>

801074ca <vector171>:
.globl vector171
vector171:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $171
801074cc:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801074d1:	e9 ce f2 ff ff       	jmp    801067a4 <alltraps>

801074d6 <vector172>:
.globl vector172
vector172:
  pushl $0
801074d6:	6a 00                	push   $0x0
  pushl $172
801074d8:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801074dd:	e9 c2 f2 ff ff       	jmp    801067a4 <alltraps>

801074e2 <vector173>:
.globl vector173
vector173:
  pushl $0
801074e2:	6a 00                	push   $0x0
  pushl $173
801074e4:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801074e9:	e9 b6 f2 ff ff       	jmp    801067a4 <alltraps>

801074ee <vector174>:
.globl vector174
vector174:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $174
801074f0:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801074f5:	e9 aa f2 ff ff       	jmp    801067a4 <alltraps>

801074fa <vector175>:
.globl vector175
vector175:
  pushl $0
801074fa:	6a 00                	push   $0x0
  pushl $175
801074fc:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107501:	e9 9e f2 ff ff       	jmp    801067a4 <alltraps>

80107506 <vector176>:
.globl vector176
vector176:
  pushl $0
80107506:	6a 00                	push   $0x0
  pushl $176
80107508:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010750d:	e9 92 f2 ff ff       	jmp    801067a4 <alltraps>

80107512 <vector177>:
.globl vector177
vector177:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $177
80107514:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107519:	e9 86 f2 ff ff       	jmp    801067a4 <alltraps>

8010751e <vector178>:
.globl vector178
vector178:
  pushl $0
8010751e:	6a 00                	push   $0x0
  pushl $178
80107520:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107525:	e9 7a f2 ff ff       	jmp    801067a4 <alltraps>

8010752a <vector179>:
.globl vector179
vector179:
  pushl $0
8010752a:	6a 00                	push   $0x0
  pushl $179
8010752c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107531:	e9 6e f2 ff ff       	jmp    801067a4 <alltraps>

80107536 <vector180>:
.globl vector180
vector180:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $180
80107538:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010753d:	e9 62 f2 ff ff       	jmp    801067a4 <alltraps>

80107542 <vector181>:
.globl vector181
vector181:
  pushl $0
80107542:	6a 00                	push   $0x0
  pushl $181
80107544:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107549:	e9 56 f2 ff ff       	jmp    801067a4 <alltraps>

8010754e <vector182>:
.globl vector182
vector182:
  pushl $0
8010754e:	6a 00                	push   $0x0
  pushl $182
80107550:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107555:	e9 4a f2 ff ff       	jmp    801067a4 <alltraps>

8010755a <vector183>:
.globl vector183
vector183:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $183
8010755c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107561:	e9 3e f2 ff ff       	jmp    801067a4 <alltraps>

80107566 <vector184>:
.globl vector184
vector184:
  pushl $0
80107566:	6a 00                	push   $0x0
  pushl $184
80107568:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010756d:	e9 32 f2 ff ff       	jmp    801067a4 <alltraps>

80107572 <vector185>:
.globl vector185
vector185:
  pushl $0
80107572:	6a 00                	push   $0x0
  pushl $185
80107574:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107579:	e9 26 f2 ff ff       	jmp    801067a4 <alltraps>

8010757e <vector186>:
.globl vector186
vector186:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $186
80107580:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107585:	e9 1a f2 ff ff       	jmp    801067a4 <alltraps>

8010758a <vector187>:
.globl vector187
vector187:
  pushl $0
8010758a:	6a 00                	push   $0x0
  pushl $187
8010758c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107591:	e9 0e f2 ff ff       	jmp    801067a4 <alltraps>

80107596 <vector188>:
.globl vector188
vector188:
  pushl $0
80107596:	6a 00                	push   $0x0
  pushl $188
80107598:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010759d:	e9 02 f2 ff ff       	jmp    801067a4 <alltraps>

801075a2 <vector189>:
.globl vector189
vector189:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $189
801075a4:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801075a9:	e9 f6 f1 ff ff       	jmp    801067a4 <alltraps>

801075ae <vector190>:
.globl vector190
vector190:
  pushl $0
801075ae:	6a 00                	push   $0x0
  pushl $190
801075b0:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801075b5:	e9 ea f1 ff ff       	jmp    801067a4 <alltraps>

801075ba <vector191>:
.globl vector191
vector191:
  pushl $0
801075ba:	6a 00                	push   $0x0
  pushl $191
801075bc:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801075c1:	e9 de f1 ff ff       	jmp    801067a4 <alltraps>

801075c6 <vector192>:
.globl vector192
vector192:
  pushl $0
801075c6:	6a 00                	push   $0x0
  pushl $192
801075c8:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801075cd:	e9 d2 f1 ff ff       	jmp    801067a4 <alltraps>

801075d2 <vector193>:
.globl vector193
vector193:
  pushl $0
801075d2:	6a 00                	push   $0x0
  pushl $193
801075d4:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801075d9:	e9 c6 f1 ff ff       	jmp    801067a4 <alltraps>

801075de <vector194>:
.globl vector194
vector194:
  pushl $0
801075de:	6a 00                	push   $0x0
  pushl $194
801075e0:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801075e5:	e9 ba f1 ff ff       	jmp    801067a4 <alltraps>

801075ea <vector195>:
.globl vector195
vector195:
  pushl $0
801075ea:	6a 00                	push   $0x0
  pushl $195
801075ec:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801075f1:	e9 ae f1 ff ff       	jmp    801067a4 <alltraps>

801075f6 <vector196>:
.globl vector196
vector196:
  pushl $0
801075f6:	6a 00                	push   $0x0
  pushl $196
801075f8:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801075fd:	e9 a2 f1 ff ff       	jmp    801067a4 <alltraps>

80107602 <vector197>:
.globl vector197
vector197:
  pushl $0
80107602:	6a 00                	push   $0x0
  pushl $197
80107604:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107609:	e9 96 f1 ff ff       	jmp    801067a4 <alltraps>

8010760e <vector198>:
.globl vector198
vector198:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $198
80107610:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107615:	e9 8a f1 ff ff       	jmp    801067a4 <alltraps>

8010761a <vector199>:
.globl vector199
vector199:
  pushl $0
8010761a:	6a 00                	push   $0x0
  pushl $199
8010761c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107621:	e9 7e f1 ff ff       	jmp    801067a4 <alltraps>

80107626 <vector200>:
.globl vector200
vector200:
  pushl $0
80107626:	6a 00                	push   $0x0
  pushl $200
80107628:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010762d:	e9 72 f1 ff ff       	jmp    801067a4 <alltraps>

80107632 <vector201>:
.globl vector201
vector201:
  pushl $0
80107632:	6a 00                	push   $0x0
  pushl $201
80107634:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107639:	e9 66 f1 ff ff       	jmp    801067a4 <alltraps>

8010763e <vector202>:
.globl vector202
vector202:
  pushl $0
8010763e:	6a 00                	push   $0x0
  pushl $202
80107640:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107645:	e9 5a f1 ff ff       	jmp    801067a4 <alltraps>

8010764a <vector203>:
.globl vector203
vector203:
  pushl $0
8010764a:	6a 00                	push   $0x0
  pushl $203
8010764c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107651:	e9 4e f1 ff ff       	jmp    801067a4 <alltraps>

80107656 <vector204>:
.globl vector204
vector204:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $204
80107658:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010765d:	e9 42 f1 ff ff       	jmp    801067a4 <alltraps>

80107662 <vector205>:
.globl vector205
vector205:
  pushl $0
80107662:	6a 00                	push   $0x0
  pushl $205
80107664:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107669:	e9 36 f1 ff ff       	jmp    801067a4 <alltraps>

8010766e <vector206>:
.globl vector206
vector206:
  pushl $0
8010766e:	6a 00                	push   $0x0
  pushl $206
80107670:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107675:	e9 2a f1 ff ff       	jmp    801067a4 <alltraps>

8010767a <vector207>:
.globl vector207
vector207:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $207
8010767c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107681:	e9 1e f1 ff ff       	jmp    801067a4 <alltraps>

80107686 <vector208>:
.globl vector208
vector208:
  pushl $0
80107686:	6a 00                	push   $0x0
  pushl $208
80107688:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010768d:	e9 12 f1 ff ff       	jmp    801067a4 <alltraps>

80107692 <vector209>:
.globl vector209
vector209:
  pushl $0
80107692:	6a 00                	push   $0x0
  pushl $209
80107694:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107699:	e9 06 f1 ff ff       	jmp    801067a4 <alltraps>

8010769e <vector210>:
.globl vector210
vector210:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $210
801076a0:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801076a5:	e9 fa f0 ff ff       	jmp    801067a4 <alltraps>

801076aa <vector211>:
.globl vector211
vector211:
  pushl $0
801076aa:	6a 00                	push   $0x0
  pushl $211
801076ac:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801076b1:	e9 ee f0 ff ff       	jmp    801067a4 <alltraps>

801076b6 <vector212>:
.globl vector212
vector212:
  pushl $0
801076b6:	6a 00                	push   $0x0
  pushl $212
801076b8:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801076bd:	e9 e2 f0 ff ff       	jmp    801067a4 <alltraps>

801076c2 <vector213>:
.globl vector213
vector213:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $213
801076c4:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801076c9:	e9 d6 f0 ff ff       	jmp    801067a4 <alltraps>

801076ce <vector214>:
.globl vector214
vector214:
  pushl $0
801076ce:	6a 00                	push   $0x0
  pushl $214
801076d0:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801076d5:	e9 ca f0 ff ff       	jmp    801067a4 <alltraps>

801076da <vector215>:
.globl vector215
vector215:
  pushl $0
801076da:	6a 00                	push   $0x0
  pushl $215
801076dc:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801076e1:	e9 be f0 ff ff       	jmp    801067a4 <alltraps>

801076e6 <vector216>:
.globl vector216
vector216:
  pushl $0
801076e6:	6a 00                	push   $0x0
  pushl $216
801076e8:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801076ed:	e9 b2 f0 ff ff       	jmp    801067a4 <alltraps>

801076f2 <vector217>:
.globl vector217
vector217:
  pushl $0
801076f2:	6a 00                	push   $0x0
  pushl $217
801076f4:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801076f9:	e9 a6 f0 ff ff       	jmp    801067a4 <alltraps>

801076fe <vector218>:
.globl vector218
vector218:
  pushl $0
801076fe:	6a 00                	push   $0x0
  pushl $218
80107700:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107705:	e9 9a f0 ff ff       	jmp    801067a4 <alltraps>

8010770a <vector219>:
.globl vector219
vector219:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $219
8010770c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107711:	e9 8e f0 ff ff       	jmp    801067a4 <alltraps>

80107716 <vector220>:
.globl vector220
vector220:
  pushl $0
80107716:	6a 00                	push   $0x0
  pushl $220
80107718:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010771d:	e9 82 f0 ff ff       	jmp    801067a4 <alltraps>

80107722 <vector221>:
.globl vector221
vector221:
  pushl $0
80107722:	6a 00                	push   $0x0
  pushl $221
80107724:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107729:	e9 76 f0 ff ff       	jmp    801067a4 <alltraps>

8010772e <vector222>:
.globl vector222
vector222:
  pushl $0
8010772e:	6a 00                	push   $0x0
  pushl $222
80107730:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107735:	e9 6a f0 ff ff       	jmp    801067a4 <alltraps>

8010773a <vector223>:
.globl vector223
vector223:
  pushl $0
8010773a:	6a 00                	push   $0x0
  pushl $223
8010773c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107741:	e9 5e f0 ff ff       	jmp    801067a4 <alltraps>

80107746 <vector224>:
.globl vector224
vector224:
  pushl $0
80107746:	6a 00                	push   $0x0
  pushl $224
80107748:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010774d:	e9 52 f0 ff ff       	jmp    801067a4 <alltraps>

80107752 <vector225>:
.globl vector225
vector225:
  pushl $0
80107752:	6a 00                	push   $0x0
  pushl $225
80107754:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107759:	e9 46 f0 ff ff       	jmp    801067a4 <alltraps>

8010775e <vector226>:
.globl vector226
vector226:
  pushl $0
8010775e:	6a 00                	push   $0x0
  pushl $226
80107760:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107765:	e9 3a f0 ff ff       	jmp    801067a4 <alltraps>

8010776a <vector227>:
.globl vector227
vector227:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $227
8010776c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107771:	e9 2e f0 ff ff       	jmp    801067a4 <alltraps>

80107776 <vector228>:
.globl vector228
vector228:
  pushl $0
80107776:	6a 00                	push   $0x0
  pushl $228
80107778:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010777d:	e9 22 f0 ff ff       	jmp    801067a4 <alltraps>

80107782 <vector229>:
.globl vector229
vector229:
  pushl $0
80107782:	6a 00                	push   $0x0
  pushl $229
80107784:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107789:	e9 16 f0 ff ff       	jmp    801067a4 <alltraps>

8010778e <vector230>:
.globl vector230
vector230:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $230
80107790:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107795:	e9 0a f0 ff ff       	jmp    801067a4 <alltraps>

8010779a <vector231>:
.globl vector231
vector231:
  pushl $0
8010779a:	6a 00                	push   $0x0
  pushl $231
8010779c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801077a1:	e9 fe ef ff ff       	jmp    801067a4 <alltraps>

801077a6 <vector232>:
.globl vector232
vector232:
  pushl $0
801077a6:	6a 00                	push   $0x0
  pushl $232
801077a8:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801077ad:	e9 f2 ef ff ff       	jmp    801067a4 <alltraps>

801077b2 <vector233>:
.globl vector233
vector233:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $233
801077b4:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801077b9:	e9 e6 ef ff ff       	jmp    801067a4 <alltraps>

801077be <vector234>:
.globl vector234
vector234:
  pushl $0
801077be:	6a 00                	push   $0x0
  pushl $234
801077c0:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801077c5:	e9 da ef ff ff       	jmp    801067a4 <alltraps>

801077ca <vector235>:
.globl vector235
vector235:
  pushl $0
801077ca:	6a 00                	push   $0x0
  pushl $235
801077cc:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801077d1:	e9 ce ef ff ff       	jmp    801067a4 <alltraps>

801077d6 <vector236>:
.globl vector236
vector236:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $236
801077d8:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801077dd:	e9 c2 ef ff ff       	jmp    801067a4 <alltraps>

801077e2 <vector237>:
.globl vector237
vector237:
  pushl $0
801077e2:	6a 00                	push   $0x0
  pushl $237
801077e4:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801077e9:	e9 b6 ef ff ff       	jmp    801067a4 <alltraps>

801077ee <vector238>:
.globl vector238
vector238:
  pushl $0
801077ee:	6a 00                	push   $0x0
  pushl $238
801077f0:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801077f5:	e9 aa ef ff ff       	jmp    801067a4 <alltraps>

801077fa <vector239>:
.globl vector239
vector239:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $239
801077fc:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107801:	e9 9e ef ff ff       	jmp    801067a4 <alltraps>

80107806 <vector240>:
.globl vector240
vector240:
  pushl $0
80107806:	6a 00                	push   $0x0
  pushl $240
80107808:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010780d:	e9 92 ef ff ff       	jmp    801067a4 <alltraps>

80107812 <vector241>:
.globl vector241
vector241:
  pushl $0
80107812:	6a 00                	push   $0x0
  pushl $241
80107814:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107819:	e9 86 ef ff ff       	jmp    801067a4 <alltraps>

8010781e <vector242>:
.globl vector242
vector242:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $242
80107820:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107825:	e9 7a ef ff ff       	jmp    801067a4 <alltraps>

8010782a <vector243>:
.globl vector243
vector243:
  pushl $0
8010782a:	6a 00                	push   $0x0
  pushl $243
8010782c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107831:	e9 6e ef ff ff       	jmp    801067a4 <alltraps>

80107836 <vector244>:
.globl vector244
vector244:
  pushl $0
80107836:	6a 00                	push   $0x0
  pushl $244
80107838:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010783d:	e9 62 ef ff ff       	jmp    801067a4 <alltraps>

80107842 <vector245>:
.globl vector245
vector245:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $245
80107844:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107849:	e9 56 ef ff ff       	jmp    801067a4 <alltraps>

8010784e <vector246>:
.globl vector246
vector246:
  pushl $0
8010784e:	6a 00                	push   $0x0
  pushl $246
80107850:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107855:	e9 4a ef ff ff       	jmp    801067a4 <alltraps>

8010785a <vector247>:
.globl vector247
vector247:
  pushl $0
8010785a:	6a 00                	push   $0x0
  pushl $247
8010785c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107861:	e9 3e ef ff ff       	jmp    801067a4 <alltraps>

80107866 <vector248>:
.globl vector248
vector248:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $248
80107868:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010786d:	e9 32 ef ff ff       	jmp    801067a4 <alltraps>

80107872 <vector249>:
.globl vector249
vector249:
  pushl $0
80107872:	6a 00                	push   $0x0
  pushl $249
80107874:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107879:	e9 26 ef ff ff       	jmp    801067a4 <alltraps>

8010787e <vector250>:
.globl vector250
vector250:
  pushl $0
8010787e:	6a 00                	push   $0x0
  pushl $250
80107880:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107885:	e9 1a ef ff ff       	jmp    801067a4 <alltraps>

8010788a <vector251>:
.globl vector251
vector251:
  pushl $0
8010788a:	6a 00                	push   $0x0
  pushl $251
8010788c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107891:	e9 0e ef ff ff       	jmp    801067a4 <alltraps>

80107896 <vector252>:
.globl vector252
vector252:
  pushl $0
80107896:	6a 00                	push   $0x0
  pushl $252
80107898:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010789d:	e9 02 ef ff ff       	jmp    801067a4 <alltraps>

801078a2 <vector253>:
.globl vector253
vector253:
  pushl $0
801078a2:	6a 00                	push   $0x0
  pushl $253
801078a4:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801078a9:	e9 f6 ee ff ff       	jmp    801067a4 <alltraps>

801078ae <vector254>:
.globl vector254
vector254:
  pushl $0
801078ae:	6a 00                	push   $0x0
  pushl $254
801078b0:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801078b5:	e9 ea ee ff ff       	jmp    801067a4 <alltraps>

801078ba <vector255>:
.globl vector255
vector255:
  pushl $0
801078ba:	6a 00                	push   $0x0
  pushl $255
801078bc:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801078c1:	e9 de ee ff ff       	jmp    801067a4 <alltraps>
	...

801078c8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801078c8:	55                   	push   %ebp
801078c9:	89 e5                	mov    %esp,%ebp
801078cb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801078ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801078d1:	83 e8 01             	sub    $0x1,%eax
801078d4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801078d8:	8b 45 08             	mov    0x8(%ebp),%eax
801078db:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801078df:	8b 45 08             	mov    0x8(%ebp),%eax
801078e2:	c1 e8 10             	shr    $0x10,%eax
801078e5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801078e9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801078ec:	0f 01 10             	lgdtl  (%eax)
}
801078ef:	c9                   	leave  
801078f0:	c3                   	ret    

801078f1 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801078f1:	55                   	push   %ebp
801078f2:	89 e5                	mov    %esp,%ebp
801078f4:	83 ec 04             	sub    $0x4,%esp
801078f7:	8b 45 08             	mov    0x8(%ebp),%eax
801078fa:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801078fe:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107902:	0f 00 d8             	ltr    %ax
}
80107905:	c9                   	leave  
80107906:	c3                   	ret    

80107907 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107907:	55                   	push   %ebp
80107908:	89 e5                	mov    %esp,%ebp
8010790a:	83 ec 04             	sub    $0x4,%esp
8010790d:	8b 45 08             	mov    0x8(%ebp),%eax
80107910:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107914:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107918:	8e e8                	mov    %eax,%gs
}
8010791a:	c9                   	leave  
8010791b:	c3                   	ret    

8010791c <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010791c:	55                   	push   %ebp
8010791d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010791f:	8b 45 08             	mov    0x8(%ebp),%eax
80107922:	0f 22 d8             	mov    %eax,%cr3
}
80107925:	5d                   	pop    %ebp
80107926:	c3                   	ret    

80107927 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107927:	55                   	push   %ebp
80107928:	89 e5                	mov    %esp,%ebp
8010792a:	8b 45 08             	mov    0x8(%ebp),%eax
8010792d:	05 00 00 00 80       	add    $0x80000000,%eax
80107932:	5d                   	pop    %ebp
80107933:	c3                   	ret    

80107934 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107934:	55                   	push   %ebp
80107935:	89 e5                	mov    %esp,%ebp
80107937:	8b 45 08             	mov    0x8(%ebp),%eax
8010793a:	05 00 00 00 80       	add    $0x80000000,%eax
8010793f:	5d                   	pop    %ebp
80107940:	c3                   	ret    

80107941 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107941:	55                   	push   %ebp
80107942:	89 e5                	mov    %esp,%ebp
80107944:	53                   	push   %ebx
80107945:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107948:	e8 a8 b8 ff ff       	call   801031f5 <cpunum>
8010794d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107953:	05 40 f9 10 80       	add    $0x8010f940,%eax
80107958:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010795b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795e:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107967:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010796d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107970:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107977:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010797b:	83 e2 f0             	and    $0xfffffff0,%edx
8010797e:	83 ca 0a             	or     $0xa,%edx
80107981:	88 50 7d             	mov    %dl,0x7d(%eax)
80107984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107987:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010798b:	83 ca 10             	or     $0x10,%edx
8010798e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107994:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107998:	83 e2 9f             	and    $0xffffff9f,%edx
8010799b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010799e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a1:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801079a5:	83 ca 80             	or     $0xffffff80,%edx
801079a8:	88 50 7d             	mov    %dl,0x7d(%eax)
801079ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ae:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079b2:	83 ca 0f             	or     $0xf,%edx
801079b5:	88 50 7e             	mov    %dl,0x7e(%eax)
801079b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079bf:	83 e2 ef             	and    $0xffffffef,%edx
801079c2:	88 50 7e             	mov    %dl,0x7e(%eax)
801079c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c8:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079cc:	83 e2 df             	and    $0xffffffdf,%edx
801079cf:	88 50 7e             	mov    %dl,0x7e(%eax)
801079d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079d9:	83 ca 40             	or     $0x40,%edx
801079dc:	88 50 7e             	mov    %dl,0x7e(%eax)
801079df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079e6:	83 ca 80             	or     $0xffffff80,%edx
801079e9:	88 50 7e             	mov    %dl,0x7e(%eax)
801079ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ef:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801079f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f6:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801079fd:	ff ff 
801079ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a02:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107a09:	00 00 
80107a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a18:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a1f:	83 e2 f0             	and    $0xfffffff0,%edx
80107a22:	83 ca 02             	or     $0x2,%edx
80107a25:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a35:	83 ca 10             	or     $0x10,%edx
80107a38:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a41:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a48:	83 e2 9f             	and    $0xffffff9f,%edx
80107a4b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a54:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a5b:	83 ca 80             	or     $0xffffff80,%edx
80107a5e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a67:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a6e:	83 ca 0f             	or     $0xf,%edx
80107a71:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a81:	83 e2 ef             	and    $0xffffffef,%edx
80107a84:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a94:	83 e2 df             	and    $0xffffffdf,%edx
80107a97:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107aa7:	83 ca 40             	or     $0x40,%edx
80107aaa:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107aba:	83 ca 80             	or     $0xffffff80,%edx
80107abd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac6:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107ad7:	ff ff 
80107ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adc:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107ae3:	00 00 
80107ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae8:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107af9:	83 e2 f0             	and    $0xfffffff0,%edx
80107afc:	83 ca 0a             	or     $0xa,%edx
80107aff:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b08:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b0f:	83 ca 10             	or     $0x10,%edx
80107b12:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b22:	83 ca 60             	or     $0x60,%edx
80107b25:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b35:	83 ca 80             	or     $0xffffff80,%edx
80107b38:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b41:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b48:	83 ca 0f             	or     $0xf,%edx
80107b4b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b54:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b5b:	83 e2 ef             	and    $0xffffffef,%edx
80107b5e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b67:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b6e:	83 e2 df             	and    $0xffffffdf,%edx
80107b71:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b81:	83 ca 40             	or     $0x40,%edx
80107b84:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b94:	83 ca 80             	or     $0xffffff80,%edx
80107b97:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba0:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107baa:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107bb1:	ff ff 
80107bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb6:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107bbd:	00 00 
80107bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc2:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcc:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bd3:	83 e2 f0             	and    $0xfffffff0,%edx
80107bd6:	83 ca 02             	or     $0x2,%edx
80107bd9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be2:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107be9:	83 ca 10             	or     $0x10,%edx
80107bec:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bfc:	83 ca 60             	or     $0x60,%edx
80107bff:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c08:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c0f:	83 ca 80             	or     $0xffffff80,%edx
80107c12:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c22:	83 ca 0f             	or     $0xf,%edx
80107c25:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c35:	83 e2 ef             	and    $0xffffffef,%edx
80107c38:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c41:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c48:	83 e2 df             	and    $0xffffffdf,%edx
80107c4b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c54:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c5b:	83 ca 40             	or     $0x40,%edx
80107c5e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c67:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c6e:	83 ca 80             	or     $0xffffff80,%edx
80107c71:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7a:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c84:	05 b4 00 00 00       	add    $0xb4,%eax
80107c89:	89 c3                	mov    %eax,%ebx
80107c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8e:	05 b4 00 00 00       	add    $0xb4,%eax
80107c93:	c1 e8 10             	shr    $0x10,%eax
80107c96:	89 c1                	mov    %eax,%ecx
80107c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9b:	05 b4 00 00 00       	add    $0xb4,%eax
80107ca0:	c1 e8 18             	shr    $0x18,%eax
80107ca3:	89 c2                	mov    %eax,%edx
80107ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca8:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107caf:	00 00 
80107cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb4:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbe:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc7:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107cce:	83 e1 f0             	and    $0xfffffff0,%ecx
80107cd1:	83 c9 02             	or     $0x2,%ecx
80107cd4:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdd:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107ce4:	83 c9 10             	or     $0x10,%ecx
80107ce7:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf0:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107cf7:	83 e1 9f             	and    $0xffffff9f,%ecx
80107cfa:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d03:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107d0a:	83 c9 80             	or     $0xffffff80,%ecx
80107d0d:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d16:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d1d:	83 e1 f0             	and    $0xfffffff0,%ecx
80107d20:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d29:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d30:	83 e1 ef             	and    $0xffffffef,%ecx
80107d33:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3c:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d43:	83 e1 df             	and    $0xffffffdf,%ecx
80107d46:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4f:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d56:	83 c9 40             	or     $0x40,%ecx
80107d59:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d62:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d69:	83 c9 80             	or     $0xffffff80,%ecx
80107d6c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d75:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7e:	83 c0 70             	add    $0x70,%eax
80107d81:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107d88:	00 
80107d89:	89 04 24             	mov    %eax,(%esp)
80107d8c:	e8 37 fb ff ff       	call   801078c8 <lgdt>
  loadgs(SEG_KCPU << 3);
80107d91:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107d98:	e8 6a fb ff ff       	call   80107907 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da0:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107da6:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107dad:	00 00 00 00 
}
80107db1:	83 c4 24             	add    $0x24,%esp
80107db4:	5b                   	pop    %ebx
80107db5:	5d                   	pop    %ebp
80107db6:	c3                   	ret    

80107db7 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107db7:	55                   	push   %ebp
80107db8:	89 e5                	mov    %esp,%ebp
80107dba:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dc0:	c1 e8 16             	shr    $0x16,%eax
80107dc3:	c1 e0 02             	shl    $0x2,%eax
80107dc6:	03 45 08             	add    0x8(%ebp),%eax
80107dc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107dcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dcf:	8b 00                	mov    (%eax),%eax
80107dd1:	83 e0 01             	and    $0x1,%eax
80107dd4:	84 c0                	test   %al,%al
80107dd6:	74 17                	je     80107def <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107dd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ddb:	8b 00                	mov    (%eax),%eax
80107ddd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107de2:	89 04 24             	mov    %eax,(%esp)
80107de5:	e8 4a fb ff ff       	call   80107934 <p2v>
80107dea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107ded:	eb 4b                	jmp    80107e3a <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107def:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107df3:	74 0e                	je     80107e03 <walkpgdir+0x4c>
80107df5:	e8 6d b0 ff ff       	call   80102e67 <kalloc>
80107dfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107dfd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e01:	75 07                	jne    80107e0a <walkpgdir+0x53>
      return 0;
80107e03:	b8 00 00 00 00       	mov    $0x0,%eax
80107e08:	eb 41                	jmp    80107e4b <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107e0a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e11:	00 
80107e12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e19:	00 
80107e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1d:	89 04 24             	mov    %eax,(%esp)
80107e20:	e8 e9 d4 ff ff       	call   8010530e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e28:	89 04 24             	mov    %eax,(%esp)
80107e2b:	e8 f7 fa ff ff       	call   80107927 <v2p>
80107e30:	89 c2                	mov    %eax,%edx
80107e32:	83 ca 07             	or     $0x7,%edx
80107e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e38:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e3d:	c1 e8 0c             	shr    $0xc,%eax
80107e40:	25 ff 03 00 00       	and    $0x3ff,%eax
80107e45:	c1 e0 02             	shl    $0x2,%eax
80107e48:	03 45 f4             	add    -0xc(%ebp),%eax
}
80107e4b:	c9                   	leave  
80107e4c:	c3                   	ret    

80107e4d <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107e4d:	55                   	push   %ebp
80107e4e:	89 e5                	mov    %esp,%ebp
80107e50:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107e53:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e56:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e61:	03 45 10             	add    0x10(%ebp),%eax
80107e64:	83 e8 01             	sub    $0x1,%eax
80107e67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e6f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107e76:	00 
80107e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80107e81:	89 04 24             	mov    %eax,(%esp)
80107e84:	e8 2e ff ff ff       	call   80107db7 <walkpgdir>
80107e89:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e8c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e90:	75 07                	jne    80107e99 <mappages+0x4c>
      return -1;
80107e92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e97:	eb 46                	jmp    80107edf <mappages+0x92>
    if(*pte & PTE_P)
80107e99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e9c:	8b 00                	mov    (%eax),%eax
80107e9e:	83 e0 01             	and    $0x1,%eax
80107ea1:	84 c0                	test   %al,%al
80107ea3:	74 0c                	je     80107eb1 <mappages+0x64>
      panic("remap");
80107ea5:	c7 04 24 c4 8c 10 80 	movl   $0x80108cc4,(%esp)
80107eac:	e8 8c 86 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80107eb1:	8b 45 18             	mov    0x18(%ebp),%eax
80107eb4:	0b 45 14             	or     0x14(%ebp),%eax
80107eb7:	89 c2                	mov    %eax,%edx
80107eb9:	83 ca 01             	or     $0x1,%edx
80107ebc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ebf:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107ec7:	74 10                	je     80107ed9 <mappages+0x8c>
      break;
    a += PGSIZE;
80107ec9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107ed0:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107ed7:	eb 96                	jmp    80107e6f <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107ed9:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107eda:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107edf:	c9                   	leave  
80107ee0:	c3                   	ret    

80107ee1 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80107ee1:	55                   	push   %ebp
80107ee2:	89 e5                	mov    %esp,%ebp
80107ee4:	53                   	push   %ebx
80107ee5:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107ee8:	e8 7a af ff ff       	call   80102e67 <kalloc>
80107eed:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ef0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ef4:	75 0a                	jne    80107f00 <setupkvm+0x1f>
    return 0;
80107ef6:	b8 00 00 00 00       	mov    $0x0,%eax
80107efb:	e9 98 00 00 00       	jmp    80107f98 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107f00:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f07:	00 
80107f08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f0f:	00 
80107f10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f13:	89 04 24             	mov    %eax,(%esp)
80107f16:	e8 f3 d3 ff ff       	call   8010530e <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107f1b:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107f22:	e8 0d fa ff ff       	call   80107934 <p2v>
80107f27:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107f2c:	76 0c                	jbe    80107f3a <setupkvm+0x59>
    panic("PHYSTOP too high");
80107f2e:	c7 04 24 ca 8c 10 80 	movl   $0x80108cca,(%esp)
80107f35:	e8 03 86 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f3a:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107f41:	eb 49                	jmp    80107f8c <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80107f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107f46:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107f4c:	8b 50 04             	mov    0x4(%eax),%edx
80107f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f52:	8b 58 08             	mov    0x8(%eax),%ebx
80107f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f58:	8b 40 04             	mov    0x4(%eax),%eax
80107f5b:	29 c3                	sub    %eax,%ebx
80107f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f60:	8b 00                	mov    (%eax),%eax
80107f62:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107f66:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107f6a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f75:	89 04 24             	mov    %eax,(%esp)
80107f78:	e8 d0 fe ff ff       	call   80107e4d <mappages>
80107f7d:	85 c0                	test   %eax,%eax
80107f7f:	79 07                	jns    80107f88 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107f81:	b8 00 00 00 00       	mov    $0x0,%eax
80107f86:	eb 10                	jmp    80107f98 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f88:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107f8c:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107f93:	72 ae                	jb     80107f43 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107f98:	83 c4 34             	add    $0x34,%esp
80107f9b:	5b                   	pop    %ebx
80107f9c:	5d                   	pop    %ebp
80107f9d:	c3                   	ret    

80107f9e <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107f9e:	55                   	push   %ebp
80107f9f:	89 e5                	mov    %esp,%ebp
80107fa1:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107fa4:	e8 38 ff ff ff       	call   80107ee1 <setupkvm>
80107fa9:	a3 18 2a 11 80       	mov    %eax,0x80112a18
  switchkvm();
80107fae:	e8 02 00 00 00       	call   80107fb5 <switchkvm>
}
80107fb3:	c9                   	leave  
80107fb4:	c3                   	ret    

80107fb5 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107fb5:	55                   	push   %ebp
80107fb6:	89 e5                	mov    %esp,%ebp
80107fb8:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107fbb:	a1 18 2a 11 80       	mov    0x80112a18,%eax
80107fc0:	89 04 24             	mov    %eax,(%esp)
80107fc3:	e8 5f f9 ff ff       	call   80107927 <v2p>
80107fc8:	89 04 24             	mov    %eax,(%esp)
80107fcb:	e8 4c f9 ff ff       	call   8010791c <lcr3>
}
80107fd0:	c9                   	leave  
80107fd1:	c3                   	ret    

80107fd2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107fd2:	55                   	push   %ebp
80107fd3:	89 e5                	mov    %esp,%ebp
80107fd5:	53                   	push   %ebx
80107fd6:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107fd9:	e8 29 d2 ff ff       	call   80105207 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107fde:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107fe4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107feb:	83 c2 08             	add    $0x8,%edx
80107fee:	89 d3                	mov    %edx,%ebx
80107ff0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ff7:	83 c2 08             	add    $0x8,%edx
80107ffa:	c1 ea 10             	shr    $0x10,%edx
80107ffd:	89 d1                	mov    %edx,%ecx
80107fff:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108006:	83 c2 08             	add    $0x8,%edx
80108009:	c1 ea 18             	shr    $0x18,%edx
8010800c:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108013:	67 00 
80108015:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
8010801c:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108022:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108029:	83 e1 f0             	and    $0xfffffff0,%ecx
8010802c:	83 c9 09             	or     $0x9,%ecx
8010802f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108035:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010803c:	83 c9 10             	or     $0x10,%ecx
8010803f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108045:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010804c:	83 e1 9f             	and    $0xffffff9f,%ecx
8010804f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108055:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010805c:	83 c9 80             	or     $0xffffff80,%ecx
8010805f:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108065:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010806c:	83 e1 f0             	and    $0xfffffff0,%ecx
8010806f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108075:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010807c:	83 e1 ef             	and    $0xffffffef,%ecx
8010807f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108085:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010808c:	83 e1 df             	and    $0xffffffdf,%ecx
8010808f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108095:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
8010809c:	83 c9 40             	or     $0x40,%ecx
8010809f:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801080a5:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801080ac:	83 e1 7f             	and    $0x7f,%ecx
801080af:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801080b5:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801080bb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080c1:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801080c8:	83 e2 ef             	and    $0xffffffef,%edx
801080cb:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801080d1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080d7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801080dd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080e3:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801080ea:	8b 52 08             	mov    0x8(%edx),%edx
801080ed:	81 c2 00 10 00 00    	add    $0x1000,%edx
801080f3:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801080f6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801080fd:	e8 ef f7 ff ff       	call   801078f1 <ltr>
  if(p->pgdir == 0)
80108102:	8b 45 08             	mov    0x8(%ebp),%eax
80108105:	8b 40 04             	mov    0x4(%eax),%eax
80108108:	85 c0                	test   %eax,%eax
8010810a:	75 0c                	jne    80108118 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
8010810c:	c7 04 24 db 8c 10 80 	movl   $0x80108cdb,(%esp)
80108113:	e8 25 84 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108118:	8b 45 08             	mov    0x8(%ebp),%eax
8010811b:	8b 40 04             	mov    0x4(%eax),%eax
8010811e:	89 04 24             	mov    %eax,(%esp)
80108121:	e8 01 f8 ff ff       	call   80107927 <v2p>
80108126:	89 04 24             	mov    %eax,(%esp)
80108129:	e8 ee f7 ff ff       	call   8010791c <lcr3>
  popcli();
8010812e:	e8 1c d1 ff ff       	call   8010524f <popcli>
}
80108133:	83 c4 14             	add    $0x14,%esp
80108136:	5b                   	pop    %ebx
80108137:	5d                   	pop    %ebp
80108138:	c3                   	ret    

80108139 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108139:	55                   	push   %ebp
8010813a:	89 e5                	mov    %esp,%ebp
8010813c:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010813f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108146:	76 0c                	jbe    80108154 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108148:	c7 04 24 ef 8c 10 80 	movl   $0x80108cef,(%esp)
8010814f:	e8 e9 83 ff ff       	call   8010053d <panic>
  mem = kalloc();
80108154:	e8 0e ad ff ff       	call   80102e67 <kalloc>
80108159:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010815c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108163:	00 
80108164:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010816b:	00 
8010816c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816f:	89 04 24             	mov    %eax,(%esp)
80108172:	e8 97 d1 ff ff       	call   8010530e <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817a:	89 04 24             	mov    %eax,(%esp)
8010817d:	e8 a5 f7 ff ff       	call   80107927 <v2p>
80108182:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108189:	00 
8010818a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010818e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108195:	00 
80108196:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010819d:	00 
8010819e:	8b 45 08             	mov    0x8(%ebp),%eax
801081a1:	89 04 24             	mov    %eax,(%esp)
801081a4:	e8 a4 fc ff ff       	call   80107e4d <mappages>
  memmove(mem, init, sz);
801081a9:	8b 45 10             	mov    0x10(%ebp),%eax
801081ac:	89 44 24 08          	mov    %eax,0x8(%esp)
801081b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801081b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801081b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ba:	89 04 24             	mov    %eax,(%esp)
801081bd:	e8 1f d2 ff ff       	call   801053e1 <memmove>
}
801081c2:	c9                   	leave  
801081c3:	c3                   	ret    

801081c4 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801081c4:	55                   	push   %ebp
801081c5:	89 e5                	mov    %esp,%ebp
801081c7:	53                   	push   %ebx
801081c8:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801081cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801081ce:	25 ff 0f 00 00       	and    $0xfff,%eax
801081d3:	85 c0                	test   %eax,%eax
801081d5:	74 0c                	je     801081e3 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801081d7:	c7 04 24 0c 8d 10 80 	movl   $0x80108d0c,(%esp)
801081de:	e8 5a 83 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
801081e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081ea:	e9 ad 00 00 00       	jmp    8010829c <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801081ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f2:	8b 55 0c             	mov    0xc(%ebp),%edx
801081f5:	01 d0                	add    %edx,%eax
801081f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081fe:	00 
801081ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80108203:	8b 45 08             	mov    0x8(%ebp),%eax
80108206:	89 04 24             	mov    %eax,(%esp)
80108209:	e8 a9 fb ff ff       	call   80107db7 <walkpgdir>
8010820e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108211:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108215:	75 0c                	jne    80108223 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108217:	c7 04 24 2f 8d 10 80 	movl   $0x80108d2f,(%esp)
8010821e:	e8 1a 83 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108223:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108226:	8b 00                	mov    (%eax),%eax
80108228:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010822d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108233:	8b 55 18             	mov    0x18(%ebp),%edx
80108236:	89 d1                	mov    %edx,%ecx
80108238:	29 c1                	sub    %eax,%ecx
8010823a:	89 c8                	mov    %ecx,%eax
8010823c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108241:	77 11                	ja     80108254 <loaduvm+0x90>
      n = sz - i;
80108243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108246:	8b 55 18             	mov    0x18(%ebp),%edx
80108249:	89 d1                	mov    %edx,%ecx
8010824b:	29 c1                	sub    %eax,%ecx
8010824d:	89 c8                	mov    %ecx,%eax
8010824f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108252:	eb 07                	jmp    8010825b <loaduvm+0x97>
    else
      n = PGSIZE;
80108254:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010825b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825e:	8b 55 14             	mov    0x14(%ebp),%edx
80108261:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108264:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108267:	89 04 24             	mov    %eax,(%esp)
8010826a:	e8 c5 f6 ff ff       	call   80107934 <p2v>
8010826f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108272:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108276:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010827a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010827e:	8b 45 10             	mov    0x10(%ebp),%eax
80108281:	89 04 24             	mov    %eax,(%esp)
80108284:	e8 3d 9e ff ff       	call   801020c6 <readi>
80108289:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010828c:	74 07                	je     80108295 <loaduvm+0xd1>
      return -1;
8010828e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108293:	eb 18                	jmp    801082ad <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108295:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010829c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010829f:	3b 45 18             	cmp    0x18(%ebp),%eax
801082a2:	0f 82 47 ff ff ff    	jb     801081ef <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801082a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082ad:	83 c4 24             	add    $0x24,%esp
801082b0:	5b                   	pop    %ebx
801082b1:	5d                   	pop    %ebp
801082b2:	c3                   	ret    

801082b3 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801082b3:	55                   	push   %ebp
801082b4:	89 e5                	mov    %esp,%ebp
801082b6:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801082b9:	8b 45 10             	mov    0x10(%ebp),%eax
801082bc:	85 c0                	test   %eax,%eax
801082be:	79 0a                	jns    801082ca <allocuvm+0x17>
    return 0;
801082c0:	b8 00 00 00 00       	mov    $0x0,%eax
801082c5:	e9 c1 00 00 00       	jmp    8010838b <allocuvm+0xd8>
  if(newsz < oldsz)
801082ca:	8b 45 10             	mov    0x10(%ebp),%eax
801082cd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082d0:	73 08                	jae    801082da <allocuvm+0x27>
    return oldsz;
801082d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801082d5:	e9 b1 00 00 00       	jmp    8010838b <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801082da:	8b 45 0c             	mov    0xc(%ebp),%eax
801082dd:	05 ff 0f 00 00       	add    $0xfff,%eax
801082e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801082ea:	e9 8d 00 00 00       	jmp    8010837c <allocuvm+0xc9>
    mem = kalloc();
801082ef:	e8 73 ab ff ff       	call   80102e67 <kalloc>
801082f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801082f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082fb:	75 2c                	jne    80108329 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801082fd:	c7 04 24 4d 8d 10 80 	movl   $0x80108d4d,(%esp)
80108304:	e8 98 80 ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108309:	8b 45 0c             	mov    0xc(%ebp),%eax
8010830c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108310:	8b 45 10             	mov    0x10(%ebp),%eax
80108313:	89 44 24 04          	mov    %eax,0x4(%esp)
80108317:	8b 45 08             	mov    0x8(%ebp),%eax
8010831a:	89 04 24             	mov    %eax,(%esp)
8010831d:	e8 6b 00 00 00       	call   8010838d <deallocuvm>
      return 0;
80108322:	b8 00 00 00 00       	mov    $0x0,%eax
80108327:	eb 62                	jmp    8010838b <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108329:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108330:	00 
80108331:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108338:	00 
80108339:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010833c:	89 04 24             	mov    %eax,(%esp)
8010833f:	e8 ca cf ff ff       	call   8010530e <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108344:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108347:	89 04 24             	mov    %eax,(%esp)
8010834a:	e8 d8 f5 ff ff       	call   80107927 <v2p>
8010834f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108352:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108359:	00 
8010835a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010835e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108365:	00 
80108366:	89 54 24 04          	mov    %edx,0x4(%esp)
8010836a:	8b 45 08             	mov    0x8(%ebp),%eax
8010836d:	89 04 24             	mov    %eax,(%esp)
80108370:	e8 d8 fa ff ff       	call   80107e4d <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108375:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010837c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837f:	3b 45 10             	cmp    0x10(%ebp),%eax
80108382:	0f 82 67 ff ff ff    	jb     801082ef <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108388:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010838b:	c9                   	leave  
8010838c:	c3                   	ret    

8010838d <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010838d:	55                   	push   %ebp
8010838e:	89 e5                	mov    %esp,%ebp
80108390:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108393:	8b 45 10             	mov    0x10(%ebp),%eax
80108396:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108399:	72 08                	jb     801083a3 <deallocuvm+0x16>
    return oldsz;
8010839b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010839e:	e9 a4 00 00 00       	jmp    80108447 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801083a3:	8b 45 10             	mov    0x10(%ebp),%eax
801083a6:	05 ff 0f 00 00       	add    $0xfff,%eax
801083ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801083b3:	e9 80 00 00 00       	jmp    80108438 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801083b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083c2:	00 
801083c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801083c7:	8b 45 08             	mov    0x8(%ebp),%eax
801083ca:	89 04 24             	mov    %eax,(%esp)
801083cd:	e8 e5 f9 ff ff       	call   80107db7 <walkpgdir>
801083d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801083d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083d9:	75 09                	jne    801083e4 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801083db:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801083e2:	eb 4d                	jmp    80108431 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801083e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083e7:	8b 00                	mov    (%eax),%eax
801083e9:	83 e0 01             	and    $0x1,%eax
801083ec:	84 c0                	test   %al,%al
801083ee:	74 41                	je     80108431 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801083f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083f3:	8b 00                	mov    (%eax),%eax
801083f5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801083fd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108401:	75 0c                	jne    8010840f <deallocuvm+0x82>
        panic("kfree");
80108403:	c7 04 24 65 8d 10 80 	movl   $0x80108d65,(%esp)
8010840a:	e8 2e 81 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
8010840f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108412:	89 04 24             	mov    %eax,(%esp)
80108415:	e8 1a f5 ff ff       	call   80107934 <p2v>
8010841a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010841d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108420:	89 04 24             	mov    %eax,(%esp)
80108423:	e8 a6 a9 ff ff       	call   80102dce <kfree>
      *pte = 0;
80108428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010842b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108431:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010843b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010843e:	0f 82 74 ff ff ff    	jb     801083b8 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108444:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108447:	c9                   	leave  
80108448:	c3                   	ret    

80108449 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108449:	55                   	push   %ebp
8010844a:	89 e5                	mov    %esp,%ebp
8010844c:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010844f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108453:	75 0c                	jne    80108461 <freevm+0x18>
    panic("freevm: no pgdir");
80108455:	c7 04 24 6b 8d 10 80 	movl   $0x80108d6b,(%esp)
8010845c:	e8 dc 80 ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108461:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108468:	00 
80108469:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108470:	80 
80108471:	8b 45 08             	mov    0x8(%ebp),%eax
80108474:	89 04 24             	mov    %eax,(%esp)
80108477:	e8 11 ff ff ff       	call   8010838d <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010847c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108483:	eb 3c                	jmp    801084c1 <freevm+0x78>
    if(pgdir[i] & PTE_P){
80108485:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108488:	c1 e0 02             	shl    $0x2,%eax
8010848b:	03 45 08             	add    0x8(%ebp),%eax
8010848e:	8b 00                	mov    (%eax),%eax
80108490:	83 e0 01             	and    $0x1,%eax
80108493:	84 c0                	test   %al,%al
80108495:	74 26                	je     801084bd <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108497:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849a:	c1 e0 02             	shl    $0x2,%eax
8010849d:	03 45 08             	add    0x8(%ebp),%eax
801084a0:	8b 00                	mov    (%eax),%eax
801084a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084a7:	89 04 24             	mov    %eax,(%esp)
801084aa:	e8 85 f4 ff ff       	call   80107934 <p2v>
801084af:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801084b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084b5:	89 04 24             	mov    %eax,(%esp)
801084b8:	e8 11 a9 ff ff       	call   80102dce <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801084bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084c1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801084c8:	76 bb                	jbe    80108485 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801084ca:	8b 45 08             	mov    0x8(%ebp),%eax
801084cd:	89 04 24             	mov    %eax,(%esp)
801084d0:	e8 f9 a8 ff ff       	call   80102dce <kfree>
}
801084d5:	c9                   	leave  
801084d6:	c3                   	ret    

801084d7 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801084d7:	55                   	push   %ebp
801084d8:	89 e5                	mov    %esp,%ebp
801084da:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801084dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084e4:	00 
801084e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801084e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801084ec:	8b 45 08             	mov    0x8(%ebp),%eax
801084ef:	89 04 24             	mov    %eax,(%esp)
801084f2:	e8 c0 f8 ff ff       	call   80107db7 <walkpgdir>
801084f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801084fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801084fe:	75 0c                	jne    8010850c <clearpteu+0x35>
    panic("clearpteu");
80108500:	c7 04 24 7c 8d 10 80 	movl   $0x80108d7c,(%esp)
80108507:	e8 31 80 ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
8010850c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850f:	8b 00                	mov    (%eax),%eax
80108511:	89 c2                	mov    %eax,%edx
80108513:	83 e2 fb             	and    $0xfffffffb,%edx
80108516:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108519:	89 10                	mov    %edx,(%eax)
}
8010851b:	c9                   	leave  
8010851c:	c3                   	ret    

8010851d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010851d:	55                   	push   %ebp
8010851e:	89 e5                	mov    %esp,%ebp
80108520:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
80108523:	e8 b9 f9 ff ff       	call   80107ee1 <setupkvm>
80108528:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010852b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010852f:	75 0a                	jne    8010853b <copyuvm+0x1e>
    return 0;
80108531:	b8 00 00 00 00       	mov    $0x0,%eax
80108536:	e9 f1 00 00 00       	jmp    8010862c <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
8010853b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108542:	e9 c0 00 00 00       	jmp    80108607 <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108551:	00 
80108552:	89 44 24 04          	mov    %eax,0x4(%esp)
80108556:	8b 45 08             	mov    0x8(%ebp),%eax
80108559:	89 04 24             	mov    %eax,(%esp)
8010855c:	e8 56 f8 ff ff       	call   80107db7 <walkpgdir>
80108561:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108564:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108568:	75 0c                	jne    80108576 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
8010856a:	c7 04 24 86 8d 10 80 	movl   $0x80108d86,(%esp)
80108571:	e8 c7 7f ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
80108576:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108579:	8b 00                	mov    (%eax),%eax
8010857b:	83 e0 01             	and    $0x1,%eax
8010857e:	85 c0                	test   %eax,%eax
80108580:	75 0c                	jne    8010858e <copyuvm+0x71>
      panic("copyuvm: page not present");
80108582:	c7 04 24 a0 8d 10 80 	movl   $0x80108da0,(%esp)
80108589:	e8 af 7f ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
8010858e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108591:	8b 00                	mov    (%eax),%eax
80108593:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108598:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
8010859b:	e8 c7 a8 ff ff       	call   80102e67 <kalloc>
801085a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801085a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801085a7:	74 6f                	je     80108618 <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801085a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085ac:	89 04 24             	mov    %eax,(%esp)
801085af:	e8 80 f3 ff ff       	call   80107934 <p2v>
801085b4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085bb:	00 
801085bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801085c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801085c3:	89 04 24             	mov    %eax,(%esp)
801085c6:	e8 16 ce ff ff       	call   801053e1 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
801085cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801085ce:	89 04 24             	mov    %eax,(%esp)
801085d1:	e8 51 f3 ff ff       	call   80107927 <v2p>
801085d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801085d9:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801085e0:	00 
801085e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
801085e5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085ec:	00 
801085ed:	89 54 24 04          	mov    %edx,0x4(%esp)
801085f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085f4:	89 04 24             	mov    %eax,(%esp)
801085f7:	e8 51 f8 ff ff       	call   80107e4d <mappages>
801085fc:	85 c0                	test   %eax,%eax
801085fe:	78 1b                	js     8010861b <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108600:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010860d:	0f 82 34 ff ff ff    	jb     80108547 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
80108613:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108616:	eb 14                	jmp    8010862c <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108618:	90                   	nop
80108619:	eb 01                	jmp    8010861c <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
8010861b:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010861c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010861f:	89 04 24             	mov    %eax,(%esp)
80108622:	e8 22 fe ff ff       	call   80108449 <freevm>
  return 0;
80108627:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010862c:	c9                   	leave  
8010862d:	c3                   	ret    

8010862e <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010862e:	55                   	push   %ebp
8010862f:	89 e5                	mov    %esp,%ebp
80108631:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108634:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010863b:	00 
8010863c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010863f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108643:	8b 45 08             	mov    0x8(%ebp),%eax
80108646:	89 04 24             	mov    %eax,(%esp)
80108649:	e8 69 f7 ff ff       	call   80107db7 <walkpgdir>
8010864e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108654:	8b 00                	mov    (%eax),%eax
80108656:	83 e0 01             	and    $0x1,%eax
80108659:	85 c0                	test   %eax,%eax
8010865b:	75 07                	jne    80108664 <uva2ka+0x36>
    return 0;
8010865d:	b8 00 00 00 00       	mov    $0x0,%eax
80108662:	eb 25                	jmp    80108689 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108667:	8b 00                	mov    (%eax),%eax
80108669:	83 e0 04             	and    $0x4,%eax
8010866c:	85 c0                	test   %eax,%eax
8010866e:	75 07                	jne    80108677 <uva2ka+0x49>
    return 0;
80108670:	b8 00 00 00 00       	mov    $0x0,%eax
80108675:	eb 12                	jmp    80108689 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867a:	8b 00                	mov    (%eax),%eax
8010867c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108681:	89 04 24             	mov    %eax,(%esp)
80108684:	e8 ab f2 ff ff       	call   80107934 <p2v>
}
80108689:	c9                   	leave  
8010868a:	c3                   	ret    

8010868b <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010868b:	55                   	push   %ebp
8010868c:	89 e5                	mov    %esp,%ebp
8010868e:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108691:	8b 45 10             	mov    0x10(%ebp),%eax
80108694:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108697:	e9 8b 00 00 00       	jmp    80108727 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
8010869c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010869f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801086a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801086ae:	8b 45 08             	mov    0x8(%ebp),%eax
801086b1:	89 04 24             	mov    %eax,(%esp)
801086b4:	e8 75 ff ff ff       	call   8010862e <uva2ka>
801086b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801086bc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801086c0:	75 07                	jne    801086c9 <copyout+0x3e>
      return -1;
801086c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801086c7:	eb 6d                	jmp    80108736 <copyout+0xab>
    n = PGSIZE - (va - va0);
801086c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801086cc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801086cf:	89 d1                	mov    %edx,%ecx
801086d1:	29 c1                	sub    %eax,%ecx
801086d3:	89 c8                	mov    %ecx,%eax
801086d5:	05 00 10 00 00       	add    $0x1000,%eax
801086da:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801086dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086e0:	3b 45 14             	cmp    0x14(%ebp),%eax
801086e3:	76 06                	jbe    801086eb <copyout+0x60>
      n = len;
801086e5:	8b 45 14             	mov    0x14(%ebp),%eax
801086e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801086eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086ee:	8b 55 0c             	mov    0xc(%ebp),%edx
801086f1:	89 d1                	mov    %edx,%ecx
801086f3:	29 c1                	sub    %eax,%ecx
801086f5:	89 c8                	mov    %ecx,%eax
801086f7:	03 45 e8             	add    -0x18(%ebp),%eax
801086fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086fd:	89 54 24 08          	mov    %edx,0x8(%esp)
80108701:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108704:	89 54 24 04          	mov    %edx,0x4(%esp)
80108708:	89 04 24             	mov    %eax,(%esp)
8010870b:	e8 d1 cc ff ff       	call   801053e1 <memmove>
    len -= n;
80108710:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108713:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108716:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108719:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010871c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010871f:	05 00 10 00 00       	add    $0x1000,%eax
80108724:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108727:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010872b:	0f 85 6b ff ff ff    	jne    8010869c <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108731:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108736:	c9                   	leave  
80108737:	c3                   	ret    
