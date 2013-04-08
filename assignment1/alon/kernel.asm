
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
8010002d:	b8 17 37 10 80       	mov    $0x80103717,%eax
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
8010003a:	c7 44 24 04 54 88 10 	movl   $0x80108854,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 38 51 00 00       	call   80105186 <initlock>

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
801000bd:	e8 e5 50 00 00       	call   801051a7 <acquire>

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
80100104:	e8 00 51 00 00       	call   80105209 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 1a 4d 00 00       	call   80104e3e <sleep>
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
8010017c:	e8 88 50 00 00       	call   80105209 <release>
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
80100198:	c7 04 24 5b 88 10 80 	movl   $0x8010885b,(%esp)
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
801001d3:	e8 ec 28 00 00       	call   80102ac4 <iderw>
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
801001ef:	c7 04 24 6c 88 10 80 	movl   $0x8010886c,(%esp)
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
80100210:	e8 af 28 00 00       	call   80102ac4 <iderw>
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
80100229:	c7 04 24 73 88 10 80 	movl   $0x80108873,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 66 4f 00 00       	call   801051a7 <acquire>

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
8010029d:	e8 78 4c 00 00       	call   80104f1a <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 5b 4f 00 00       	call   80105209 <release>
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
80100390:	e8 0a 04 00 00       	call   8010079f <consputc>
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
801003bc:	e8 e6 4d 00 00       	call   801051a7 <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 7a 88 10 80 	movl   $0x8010887a,(%esp)
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
801003f2:	e8 a8 03 00 00       	call   8010079f <consputc>
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
801004af:	c7 45 ec 83 88 10 80 	movl   $0x80108883,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 d6 02 00 00       	call   8010079f <consputc>
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
801004e3:	e8 b7 02 00 00       	call   8010079f <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 a9 02 00 00       	call   8010079f <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 9e 02 00 00       	call   8010079f <consputc>
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
80100536:	e8 ce 4c 00 00       	call   80105209 <release>
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
80100562:	c7 04 24 8a 88 10 80 	movl   $0x8010888a,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 99 88 10 80 	movl   $0x80108899,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 c1 4c 00 00       	call   80105258 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 9b 88 10 80 	movl   $0x8010889b,(%esp)
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
80100626:	75 30                	jne    80100658 <cgaputc+0x8b>
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
80100656:	eb 6f                	jmp    801006c7 <cgaputc+0xfa>
  else if(c == BACKSPACE){
80100658:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065f:	75 0c                	jne    8010066d <cgaputc+0xa0>
    if(pos > 0) --pos;
80100661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100665:	7e 60                	jle    801006c7 <cgaputc+0xfa>
80100667:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010066b:	eb 5a                	jmp    801006c7 <cgaputc+0xfa>
  }
  else if(c == KEY_LF){
8010066d:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
80100674:	75 1c                	jne    80100692 <cgaputc+0xc5>
    if(input.e + input.a > input.w) --pos;
80100676:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010067c:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100681:	01 c2                	add    %eax,%edx
80100683:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100688:	39 c2                	cmp    %eax,%edx
8010068a:	76 3b                	jbe    801006c7 <cgaputc+0xfa>
8010068c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100690:	eb 35                	jmp    801006c7 <cgaputc+0xfa>
  }
  else if(c == KEY_RT){
80100692:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
80100699:	75 0f                	jne    801006aa <cgaputc+0xdd>
    if(input.a < 0) ++pos;
8010069b:	a1 60 de 10 80       	mov    0x8010de60,%eax
801006a0:	85 c0                	test   %eax,%eax
801006a2:	79 23                	jns    801006c7 <cgaputc+0xfa>
801006a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801006a8:	eb 1d                	jmp    801006c7 <cgaputc+0xfa>
  }
  else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006aa:	a1 00 90 10 80       	mov    0x80109000,%eax
801006af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006b2:	01 d2                	add    %edx,%edx
801006b4:	01 c2                	add    %eax,%edx
801006b6:	8b 45 08             	mov    0x8(%ebp),%eax
801006b9:	66 25 ff 00          	and    $0xff,%ax
801006bd:	80 cc 07             	or     $0x7,%ah
801006c0:	66 89 02             	mov    %ax,(%edx)
801006c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
801006c7:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006ce:	7e 53                	jle    80100723 <cgaputc+0x156>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006d0:	a1 00 90 10 80       	mov    0x80109000,%eax
801006d5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006db:	a1 00 90 10 80       	mov    0x80109000,%eax
801006e0:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006e7:	00 
801006e8:	89 54 24 04          	mov    %edx,0x4(%esp)
801006ec:	89 04 24             	mov    %eax,(%esp)
801006ef:	e8 d5 4d 00 00       	call   801054c9 <memmove>
    pos -= 80;
801006f4:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006f8:	b8 80 07 00 00       	mov    $0x780,%eax
801006fd:	2b 45 f4             	sub    -0xc(%ebp),%eax
80100700:	01 c0                	add    %eax,%eax
80100702:	8b 15 00 90 10 80    	mov    0x80109000,%edx
80100708:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010070b:	01 c9                	add    %ecx,%ecx
8010070d:	01 ca                	add    %ecx,%edx
8010070f:	89 44 24 08          	mov    %eax,0x8(%esp)
80100713:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010071a:	00 
8010071b:	89 14 24             	mov    %edx,(%esp)
8010071e:	e8 d3 4c 00 00       	call   801053f6 <memset>
  }
  
  outb(CRTPORT, 14);
80100723:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
8010072a:	00 
8010072b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100732:	e8 a3 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
80100737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073a:	c1 f8 08             	sar    $0x8,%eax
8010073d:	0f b6 c0             	movzbl %al,%eax
80100740:	89 44 24 04          	mov    %eax,0x4(%esp)
80100744:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010074b:	e8 8a fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
80100750:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100757:	00 
80100758:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010075f:	e8 76 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
80100764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100767:	0f b6 c0             	movzbl %al,%eax
8010076a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010076e:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100775:	e8 60 fb ff ff       	call   801002da <outb>
  if(c != KEY_LF && c != KEY_RT)
8010077a:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
80100781:	74 1a                	je     8010079d <cgaputc+0x1d0>
80100783:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
8010078a:	74 11                	je     8010079d <cgaputc+0x1d0>
    crt[pos] = ' ' | 0x0700;
8010078c:	a1 00 90 10 80       	mov    0x80109000,%eax
80100791:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100794:	01 d2                	add    %edx,%edx
80100796:	01 d0                	add    %edx,%eax
80100798:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010079d:	c9                   	leave  
8010079e:	c3                   	ret    

8010079f <consputc>:

void
consputc(int c)
{
8010079f:	55                   	push   %ebp
801007a0:	89 e5                	mov    %esp,%ebp
801007a2:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
801007a5:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
801007aa:	85 c0                	test   %eax,%eax
801007ac:	74 07                	je     801007b5 <consputc+0x16>
    cli();
801007ae:	e8 45 fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
801007b3:	eb fe                	jmp    801007b3 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007b5:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007bc:	75 26                	jne    801007e4 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007be:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007c5:	e8 ef 66 00 00       	call   80106eb9 <uartputc>
801007ca:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801007d1:	e8 e3 66 00 00       	call   80106eb9 <uartputc>
801007d6:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007dd:	e8 d7 66 00 00       	call   80106eb9 <uartputc>
801007e2:	eb 0b                	jmp    801007ef <consputc+0x50>
  }
  else if (c == KEY_RT){
    uartputc(0x601);
  }*/
  else
    uartputc(c);
801007e4:	8b 45 08             	mov    0x8(%ebp),%eax
801007e7:	89 04 24             	mov    %eax,(%esp)
801007ea:	e8 ca 66 00 00       	call   80106eb9 <uartputc>
  cgaputc(c);
801007ef:	8b 45 08             	mov    0x8(%ebp),%eax
801007f2:	89 04 24             	mov    %eax,(%esp)
801007f5:	e8 d3 fd ff ff       	call   801005cd <cgaputc>
}
801007fa:	c9                   	leave  
801007fb:	c3                   	ret    

801007fc <shiftRightBuf>:

#define C(x)  ((x)-'@')  // Control-x

void
shiftRightBuf(int e, int k)
{
801007fc:	55                   	push   %ebp
801007fd:	89 e5                	mov    %esp,%ebp
801007ff:	83 ec 10             	sub    $0x10,%esp
  int j=0;
80100802:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(;j < k;e--,j++){
80100809:	eb 21                	jmp    8010082c <shiftRightBuf+0x30>
    input.buf[e] = input.buf[e-1];
8010080b:	8b 45 08             	mov    0x8(%ebp),%eax
8010080e:	83 e8 01             	sub    $0x1,%eax
80100811:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100818:	8b 55 08             	mov    0x8(%ebp),%edx
8010081b:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
80100821:	88 42 04             	mov    %al,0x4(%edx)

void
shiftRightBuf(int e, int k)
{
  int j=0;
  for(;j < k;e--,j++){
80100824:	83 6d 08 01          	subl   $0x1,0x8(%ebp)
80100828:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010082c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010082f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80100832:	7c d7                	jl     8010080b <shiftRightBuf+0xf>
    input.buf[e] = input.buf[e-1];
  }
}
80100834:	c9                   	leave  
80100835:	c3                   	ret    

80100836 <shiftLeftBuf>:

void
shiftLeftBuf(int e, int k)
{
80100836:	55                   	push   %ebp
80100837:	89 e5                	mov    %esp,%ebp
80100839:	83 ec 10             	sub    $0x10,%esp
  int i = e+k;
8010083c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010083f:	8b 55 08             	mov    0x8(%ebp),%edx
80100842:	01 d0                	add    %edx,%eax
80100844:	89 45 fc             	mov    %eax,-0x4(%ebp)
  int j=0;
80100847:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(;j < (-1)*k ;i++,j++){
8010084e:	eb 21                	jmp    80100871 <shiftLeftBuf+0x3b>
    input.buf[i] = input.buf[i+1];
80100850:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100853:	83 c0 01             	add    $0x1,%eax
80100856:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
8010085d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80100860:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
80100866:	88 42 04             	mov    %al,0x4(%edx)
void
shiftLeftBuf(int e, int k)
{
  int i = e+k;
  int j=0;
  for(;j < (-1)*k ;i++,j++){
80100869:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010086d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80100871:	8b 45 0c             	mov    0xc(%ebp),%eax
80100874:	f7 d8                	neg    %eax
80100876:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80100879:	7f d5                	jg     80100850 <shiftLeftBuf+0x1a>
    input.buf[i] = input.buf[i+1];
  }
  input.buf[e] = ' ';
8010087b:	8b 45 08             	mov    0x8(%ebp),%eax
8010087e:	05 d0 dd 10 80       	add    $0x8010ddd0,%eax
80100883:	c6 40 04 20          	movb   $0x20,0x4(%eax)
}
80100887:	c9                   	leave  
80100888:	c3                   	ret    

80100889 <consoleintr>:

void
consoleintr(int (*getc)(void))
{
80100889:	55                   	push   %ebp
8010088a:	89 e5                	mov    %esp,%ebp
8010088c:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
8010088f:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100896:	e8 0c 49 00 00       	call   801051a7 <acquire>
  while((c = getc()) >= 0){
8010089b:	e9 74 03 00 00       	jmp    80100c14 <consoleintr+0x38b>
    switch(c){
801008a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801008a3:	83 f8 15             	cmp    $0x15,%eax
801008a6:	74 59                	je     80100901 <consoleintr+0x78>
801008a8:	83 f8 15             	cmp    $0x15,%eax
801008ab:	7f 0f                	jg     801008bc <consoleintr+0x33>
801008ad:	83 f8 08             	cmp    $0x8,%eax
801008b0:	74 7e                	je     80100930 <consoleintr+0xa7>
801008b2:	83 f8 10             	cmp    $0x10,%eax
801008b5:	74 25                	je     801008dc <consoleintr+0x53>
801008b7:	e9 cc 01 00 00       	jmp    80100a88 <consoleintr+0x1ff>
801008bc:	3d e4 00 00 00       	cmp    $0xe4,%eax
801008c1:	0f 84 4d 01 00 00    	je     80100a14 <consoleintr+0x18b>
801008c7:	3d e5 00 00 00       	cmp    $0xe5,%eax
801008cc:	0f 84 7a 01 00 00    	je     80100a4c <consoleintr+0x1c3>
801008d2:	83 f8 7f             	cmp    $0x7f,%eax
801008d5:	74 59                	je     80100930 <consoleintr+0xa7>
801008d7:	e9 ac 01 00 00       	jmp    80100a88 <consoleintr+0x1ff>
    case C('P'):  // Process listing.
      procdump();
801008dc:	e8 df 46 00 00       	call   80104fc0 <procdump>
      break;
801008e1:	e9 2e 03 00 00       	jmp    80100c14 <consoleintr+0x38b>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008e6:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008eb:	83 e8 01             	sub    $0x1,%eax
801008ee:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
801008f3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801008fa:	e8 a0 fe ff ff       	call   8010079f <consputc>
801008ff:	eb 01                	jmp    80100902 <consoleintr+0x79>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100901:	90                   	nop
80100902:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100908:	a1 58 de 10 80       	mov    0x8010de58,%eax
8010090d:	39 c2                	cmp    %eax,%edx
8010090f:	0f 84 f2 02 00 00    	je     80100c07 <consoleintr+0x37e>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100915:	a1 5c de 10 80       	mov    0x8010de5c,%eax
8010091a:	83 e8 01             	sub    $0x1,%eax
8010091d:	83 e0 7f             	and    $0x7f,%eax
80100920:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100927:	3c 0a                	cmp    $0xa,%al
80100929:	75 bb                	jne    801008e6 <consoleintr+0x5d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010092b:	e9 d7 02 00 00       	jmp    80100c07 <consoleintr+0x37e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100930:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100936:	a1 58 de 10 80       	mov    0x8010de58,%eax
8010093b:	39 c2                	cmp    %eax,%edx
8010093d:	0f 84 c7 02 00 00    	je     80100c0a <consoleintr+0x381>
	if(input.a<0)
80100943:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100948:	85 c0                	test   %eax,%eax
8010094a:	0f 89 a6 00 00 00    	jns    801009f6 <consoleintr+0x16d>
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
80100950:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100955:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010095b:	83 ea 01             	sub    $0x1,%edx
8010095e:	83 e2 7f             	and    $0x7f,%edx
80100961:	89 44 24 04          	mov    %eax,0x4(%esp)
80100965:	89 14 24             	mov    %edx,(%esp)
80100968:	e8 c9 fe ff ff       	call   80100836 <shiftLeftBuf>
	    int i = input.e+input.a-1;
8010096d:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100973:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100978:	01 d0                	add    %edx,%eax
8010097a:	83 e8 01             	sub    $0x1,%eax
8010097d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    consputc(KEY_LF);
80100980:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100987:	e8 13 fe ff ff       	call   8010079f <consputc>
	    for(;i<input.e;i++){
8010098c:	eb 28                	jmp    801009b6 <consoleintr+0x12d>
	      consputc(input.buf[i%INPUT_BUF]);
8010098e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100991:	89 c2                	mov    %eax,%edx
80100993:	c1 fa 1f             	sar    $0x1f,%edx
80100996:	c1 ea 19             	shr    $0x19,%edx
80100999:	01 d0                	add    %edx,%eax
8010099b:	83 e0 7f             	and    $0x7f,%eax
8010099e:	29 d0                	sub    %edx,%eax
801009a0:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
801009a7:	0f be c0             	movsbl %al,%eax
801009aa:	89 04 24             	mov    %eax,(%esp)
801009ad:	e8 ed fd ff ff       	call   8010079f <consputc>
	if(input.a<0)
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);
	    int i = input.e+input.a-1;
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
801009b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801009b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801009b9:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801009be:	39 c2                	cmp    %eax,%edx
801009c0:	72 cc                	jb     8010098e <consoleintr+0x105>
	      consputc(input.buf[i%INPUT_BUF]);
	    }
	    i = input.e+input.a;
801009c2:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801009c8:	a1 60 de 10 80       	mov    0x8010de60,%eax
801009cd:	01 d0                	add    %edx,%eax
801009cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    for(;i<input.e+1;i++){
801009d2:	eb 10                	jmp    801009e4 <consoleintr+0x15b>
	      consputc(KEY_LF);
801009d4:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
801009db:	e8 bf fd ff ff       	call   8010079f <consputc>
	    consputc(KEY_LF);
	    for(;i<input.e;i++){
	      consputc(input.buf[i%INPUT_BUF]);
	    }
	    i = input.e+input.a;
	    for(;i<input.e+1;i++){
801009e0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801009e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801009e7:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801009ed:	83 c2 01             	add    $0x1,%edx
801009f0:	39 d0                	cmp    %edx,%eax
801009f2:	72 e0                	jb     801009d4 <consoleintr+0x14b>
801009f4:	eb 0c                	jmp    80100a02 <consoleintr+0x179>
	      consputc(KEY_LF);
	    }
	}
	else
	{
	  consputc(BACKSPACE);
801009f6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801009fd:	e8 9d fd ff ff       	call   8010079f <consputc>
	}
	input.e--;
80100a02:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a07:	83 e8 01             	sub    $0x1,%eax
80100a0a:	a3 5c de 10 80       	mov    %eax,0x8010de5c
      }
      break;
80100a0f:	e9 f6 01 00 00       	jmp    80100c0a <consoleintr+0x381>
    case KEY_LF: //LEFT KEY
     if(input.e+input.a> input.w)
80100a14:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a1a:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a1f:	01 c2                	add    %eax,%edx
80100a21:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100a26:	39 c2                	cmp    %eax,%edx
80100a28:	0f 86 df 01 00 00    	jbe    80100c0d <consoleintr+0x384>
      {
        consputc(KEY_LF);
80100a2e:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a35:	e8 65 fd ff ff       	call   8010079f <consputc>
	input.a--;
80100a3a:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a3f:	83 e8 01             	sub    $0x1,%eax
80100a42:	a3 60 de 10 80       	mov    %eax,0x8010de60
      }
      break;
80100a47:	e9 c1 01 00 00       	jmp    80100c0d <consoleintr+0x384>
    case KEY_RT: //RIGHT KEY
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
80100a4c:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a51:	85 c0                	test   %eax,%eax
80100a53:	0f 89 b7 01 00 00    	jns    80100c10 <consoleintr+0x387>
80100a59:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a5e:	83 e0 7f             	and    $0x7f,%eax
80100a61:	83 f8 7e             	cmp    $0x7e,%eax
80100a64:	0f 87 a6 01 00 00    	ja     80100c10 <consoleintr+0x387>
      {
        consputc(KEY_RT);
80100a6a:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100a71:	e8 29 fd ff ff       	call   8010079f <consputc>
	input.a++;
80100a76:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a7b:	83 c0 01             	add    $0x1,%eax
80100a7e:	a3 60 de 10 80       	mov    %eax,0x8010de60
      }
      break;
80100a83:	e9 88 01 00 00       	jmp    80100c10 <consoleintr+0x387>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
80100a88:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a8c:	0f 84 81 01 00 00    	je     80100c13 <consoleintr+0x38a>
80100a92:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a98:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100a9d:	89 d1                	mov    %edx,%ecx
80100a9f:	29 c1                	sub    %eax,%ecx
80100aa1:	89 c8                	mov    %ecx,%eax
80100aa3:	83 f8 7f             	cmp    $0x7f,%eax
80100aa6:	0f 87 67 01 00 00    	ja     80100c13 <consoleintr+0x38a>
      {
	c = (c == '\r') ? '\n' : c;
80100aac:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
80100ab0:	74 05                	je     80100ab7 <consoleintr+0x22e>
80100ab2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100ab5:	eb 05                	jmp    80100abc <consoleintr+0x233>
80100ab7:	b8 0a 00 00 00       	mov    $0xa,%eax
80100abc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(c != '\n' && input.a < 0)
80100abf:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100ac3:	0f 84 d8 00 00 00    	je     80100ba1 <consoleintr+0x318>
80100ac9:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100ace:	85 c0                	test   %eax,%eax
80100ad0:	0f 89 cb 00 00 00    	jns    80100ba1 <consoleintr+0x318>
	{
	    int k = (-1)*input.a;
80100ad6:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100adb:	f7 d8                	neg    %eax
80100add:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    shiftRightBuf((input.e) % INPUT_BUF,k);
80100ae0:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100ae5:	89 c2                	mov    %eax,%edx
80100ae7:	83 e2 7f             	and    $0x7f,%edx
80100aea:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100aed:	89 44 24 04          	mov    %eax,0x4(%esp)
80100af1:	89 14 24             	mov    %edx,(%esp)
80100af4:	e8 03 fd ff ff       	call   801007fc <shiftRightBuf>
	    input.buf[(input.e-k) % INPUT_BUF] = c;
80100af9:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100aff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b02:	89 d1                	mov    %edx,%ecx
80100b04:	29 c1                	sub    %eax,%ecx
80100b06:	89 c8                	mov    %ecx,%eax
80100b08:	89 c2                	mov    %eax,%edx
80100b0a:	83 e2 7f             	and    $0x7f,%edx
80100b0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100b10:	88 82 d4 dd 10 80    	mov    %al,-0x7fef222c(%edx)
	    
	    int i = input.e-k;
80100b16:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100b1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b1f:	89 d1                	mov    %edx,%ecx
80100b21:	29 c1                	sub    %eax,%ecx
80100b23:	89 c8                	mov    %ecx,%eax
80100b25:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e+1;i++)
80100b28:	eb 28                	jmp    80100b52 <consoleintr+0x2c9>
	      consputc(input.buf[i%INPUT_BUF]);
80100b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b2d:	89 c2                	mov    %eax,%edx
80100b2f:	c1 fa 1f             	sar    $0x1f,%edx
80100b32:	c1 ea 19             	shr    $0x19,%edx
80100b35:	01 d0                	add    %edx,%eax
80100b37:	83 e0 7f             	and    $0x7f,%eax
80100b3a:	29 d0                	sub    %edx,%eax
80100b3c:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100b43:	0f be c0             	movsbl %al,%eax
80100b46:	89 04 24             	mov    %eax,(%esp)
80100b49:	e8 51 fc ff ff       	call   8010079f <consputc>
	    int k = (-1)*input.a;
	    shiftRightBuf((input.e) % INPUT_BUF,k);
	    input.buf[(input.e-k) % INPUT_BUF] = c;
	    
	    int i = input.e-k;
	    for(;i<input.e+1;i++)
80100b4e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b55:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100b5b:	83 c2 01             	add    $0x1,%edx
80100b5e:	39 d0                	cmp    %edx,%eax
80100b60:	72 c8                	jb     80100b2a <consoleintr+0x2a1>
	      consputc(input.buf[i%INPUT_BUF]);
	    
	    i = input.e-k;
80100b62:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100b68:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b6b:	89 d1                	mov    %edx,%ecx
80100b6d:	29 c1                	sub    %eax,%ecx
80100b6f:	89 c8                	mov    %ecx,%eax
80100b71:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e;i++)
80100b74:	eb 10                	jmp    80100b86 <consoleintr+0x2fd>
	      consputc(KEY_LF);
80100b76:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100b7d:	e8 1d fc ff ff       	call   8010079f <consputc>
	    int i = input.e-k;
	    for(;i<input.e+1;i++)
	      consputc(input.buf[i%INPUT_BUF]);
	    
	    i = input.e-k;
	    for(;i<input.e;i++)
80100b82:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100b86:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b89:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b8e:	39 c2                	cmp    %eax,%edx
80100b90:	72 e4                	jb     80100b76 <consoleintr+0x2ed>
	      consputc(KEY_LF);
	
	    input.e++;
80100b92:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b97:	83 c0 01             	add    $0x1,%eax
80100b9a:	a3 5c de 10 80       	mov    %eax,0x8010de5c
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
      {
	c = (c == '\r') ? '\n' : c;
	if(c != '\n' && input.a < 0)
	{
80100b9f:	eb 26                	jmp    80100bc7 <consoleintr+0x33e>
	      consputc(KEY_LF);
	
	    input.e++;
	}
	else {
	  input.buf[input.e++ % INPUT_BUF] = c;
80100ba1:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100ba6:	89 c1                	mov    %eax,%ecx
80100ba8:	83 e1 7f             	and    $0x7f,%ecx
80100bab:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100bae:	88 91 d4 dd 10 80    	mov    %dl,-0x7fef222c(%ecx)
80100bb4:	83 c0 01             	add    $0x1,%eax
80100bb7:	a3 5c de 10 80       	mov    %eax,0x8010de5c
          consputc(c);
80100bbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100bbf:	89 04 24             	mov    %eax,(%esp)
80100bc2:	e8 d8 fb ff ff       	call   8010079f <consputc>
	}
	if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF)
80100bc7:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100bcb:	74 18                	je     80100be5 <consoleintr+0x35c>
80100bcd:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100bd1:	74 12                	je     80100be5 <consoleintr+0x35c>
80100bd3:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bd8:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100bde:	83 ea 80             	sub    $0xffffff80,%edx
80100be1:	39 d0                	cmp    %edx,%eax
80100be3:	75 2e                	jne    80100c13 <consoleintr+0x38a>
	{
          input.a = 0;
80100be5:	c7 05 60 de 10 80 00 	movl   $0x0,0x8010de60
80100bec:	00 00 00 
	  input.w = input.e;
80100bef:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bf4:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
80100bf9:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100c00:	e8 15 43 00 00       	call   80104f1a <wakeup>
        }
      }
      break;
80100c05:	eb 0c                	jmp    80100c13 <consoleintr+0x38a>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100c07:	90                   	nop
80100c08:	eb 0a                	jmp    80100c14 <consoleintr+0x38b>
	{
	  consputc(BACKSPACE);
	}
	input.e--;
      }
      break;
80100c0a:	90                   	nop
80100c0b:	eb 07                	jmp    80100c14 <consoleintr+0x38b>
     if(input.e+input.a> input.w)
      {
        consputc(KEY_LF);
	input.a--;
      }
      break;
80100c0d:	90                   	nop
80100c0e:	eb 04                	jmp    80100c14 <consoleintr+0x38b>
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
      {
        consputc(KEY_RT);
	input.a++;
      }
      break;
80100c10:	90                   	nop
80100c11:	eb 01                	jmp    80100c14 <consoleintr+0x38b>
          input.a = 0;
	  input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
80100c13:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100c14:	8b 45 08             	mov    0x8(%ebp),%eax
80100c17:	ff d0                	call   *%eax
80100c19:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100c1c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100c20:	0f 89 7a fc ff ff    	jns    801008a0 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100c26:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c2d:	e8 d7 45 00 00       	call   80105209 <release>
}
80100c32:	c9                   	leave  
80100c33:	c3                   	ret    

80100c34 <consoleread>:


int
consoleread(struct inode *ip, char *dst, int n)
{
80100c34:	55                   	push   %ebp
80100c35:	89 e5                	mov    %esp,%ebp
80100c37:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100c3a:	8b 45 08             	mov    0x8(%ebp),%eax
80100c3d:	89 04 24             	mov    %eax,(%esp)
80100c40:	e8 81 10 00 00       	call   80101cc6 <iunlock>
  target = n;
80100c45:	8b 45 10             	mov    0x10(%ebp),%eax
80100c48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100c4b:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c52:	e8 50 45 00 00       	call   801051a7 <acquire>
  while(n > 0){
80100c57:	e9 a8 00 00 00       	jmp    80100d04 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
80100c5c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c62:	8b 40 24             	mov    0x24(%eax),%eax
80100c65:	85 c0                	test   %eax,%eax
80100c67:	74 21                	je     80100c8a <consoleread+0x56>
        release(&input.lock);
80100c69:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c70:	e8 94 45 00 00       	call   80105209 <release>
        ilock(ip);
80100c75:	8b 45 08             	mov    0x8(%ebp),%eax
80100c78:	89 04 24             	mov    %eax,(%esp)
80100c7b:	e8 f8 0e 00 00       	call   80101b78 <ilock>
        return -1;
80100c80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c85:	e9 a9 00 00 00       	jmp    80100d33 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
80100c8a:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
80100c91:	80 
80100c92:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100c99:	e8 a0 41 00 00       	call   80104e3e <sleep>
80100c9e:	eb 01                	jmp    80100ca1 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100ca0:	90                   	nop
80100ca1:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100ca7:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100cac:	39 c2                	cmp    %eax,%edx
80100cae:	74 ac                	je     80100c5c <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100cb0:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100cb5:	89 c2                	mov    %eax,%edx
80100cb7:	83 e2 7f             	and    $0x7f,%edx
80100cba:	0f b6 92 d4 dd 10 80 	movzbl -0x7fef222c(%edx),%edx
80100cc1:	0f be d2             	movsbl %dl,%edx
80100cc4:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100cc7:	83 c0 01             	add    $0x1,%eax
80100cca:	a3 54 de 10 80       	mov    %eax,0x8010de54
    if(c == C('D')){  // EOF
80100ccf:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100cd3:	75 17                	jne    80100cec <consoleread+0xb8>
      if(n < target){
80100cd5:	8b 45 10             	mov    0x10(%ebp),%eax
80100cd8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100cdb:	73 2f                	jae    80100d0c <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100cdd:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100ce2:	83 e8 01             	sub    $0x1,%eax
80100ce5:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
80100cea:	eb 20                	jmp    80100d0c <consoleread+0xd8>
    }
    *dst++ = c;
80100cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100cef:	89 c2                	mov    %eax,%edx
80100cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80100cf4:	88 10                	mov    %dl,(%eax)
80100cf6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
80100cfa:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100cfe:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100d02:	74 0b                	je     80100d0f <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100d04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100d08:	7f 96                	jg     80100ca0 <consoleread+0x6c>
80100d0a:	eb 04                	jmp    80100d10 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100d0c:	90                   	nop
80100d0d:	eb 01                	jmp    80100d10 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100d0f:	90                   	nop
  }
  release(&input.lock);
80100d10:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100d17:	e8 ed 44 00 00       	call   80105209 <release>
  ilock(ip);
80100d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80100d1f:	89 04 24             	mov    %eax,(%esp)
80100d22:	e8 51 0e 00 00       	call   80101b78 <ilock>

  return target - n;
80100d27:	8b 45 10             	mov    0x10(%ebp),%eax
80100d2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d2d:	89 d1                	mov    %edx,%ecx
80100d2f:	29 c1                	sub    %eax,%ecx
80100d31:	89 c8                	mov    %ecx,%eax
}
80100d33:	c9                   	leave  
80100d34:	c3                   	ret    

80100d35 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100d35:	55                   	push   %ebp
80100d36:	89 e5                	mov    %esp,%ebp
80100d38:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80100d3e:	89 04 24             	mov    %eax,(%esp)
80100d41:	e8 80 0f 00 00       	call   80101cc6 <iunlock>
  acquire(&cons.lock);
80100d46:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d4d:	e8 55 44 00 00       	call   801051a7 <acquire>
  for(i = 0; i < n; i++)
80100d52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100d59:	eb 1d                	jmp    80100d78 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d5e:	03 45 0c             	add    0xc(%ebp),%eax
80100d61:	0f b6 00             	movzbl (%eax),%eax
80100d64:	0f be c0             	movsbl %al,%eax
80100d67:	25 ff 00 00 00       	and    $0xff,%eax
80100d6c:	89 04 24             	mov    %eax,(%esp)
80100d6f:	e8 2b fa ff ff       	call   8010079f <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100d74:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d7b:	3b 45 10             	cmp    0x10(%ebp),%eax
80100d7e:	7c db                	jl     80100d5b <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100d80:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d87:	e8 7d 44 00 00       	call   80105209 <release>
  ilock(ip);
80100d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80100d8f:	89 04 24             	mov    %eax,(%esp)
80100d92:	e8 e1 0d 00 00       	call   80101b78 <ilock>

  return n;
80100d97:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100d9a:	c9                   	leave  
80100d9b:	c3                   	ret    

80100d9c <consoleinit>:

void
consoleinit(void)
{
80100d9c:	55                   	push   %ebp
80100d9d:	89 e5                	mov    %esp,%ebp
80100d9f:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100da2:	c7 44 24 04 9f 88 10 	movl   $0x8010889f,0x4(%esp)
80100da9:	80 
80100daa:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100db1:	e8 d0 43 00 00       	call   80105186 <initlock>
  initlock(&input.lock, "input");
80100db6:	c7 44 24 04 a7 88 10 	movl   $0x801088a7,0x4(%esp)
80100dbd:	80 
80100dbe:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100dc5:	e8 bc 43 00 00       	call   80105186 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100dca:	c7 05 2c e8 10 80 35 	movl   $0x80100d35,0x8010e82c
80100dd1:	0d 10 80 
  devsw[CONSOLE].read = consoleread;
80100dd4:	c7 05 28 e8 10 80 34 	movl   $0x80100c34,0x8010e828
80100ddb:	0c 10 80 
  cons.locking = 1;
80100dde:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100de5:	00 00 00 

  picenable(IRQ_KBD);
80100de8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100def:	e8 dd 2f 00 00       	call   80103dd1 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100df4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100dfb:	00 
80100dfc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e03:	e8 7e 1e 00 00       	call   80102c86 <ioapicenable>
}
80100e08:	c9                   	leave  
80100e09:	c3                   	ret    
	...

80100e0c <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100e0c:	55                   	push   %ebp
80100e0d:	89 e5                	mov    %esp,%ebp
80100e0f:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100e15:	8b 45 08             	mov    0x8(%ebp),%eax
80100e18:	89 04 24             	mov    %eax,(%esp)
80100e1b:	e8 fa 18 00 00       	call   8010271a <namei>
80100e20:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100e23:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100e27:	75 0a                	jne    80100e33 <exec+0x27>
    return -1;
80100e29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e2e:	e9 da 03 00 00       	jmp    8010120d <exec+0x401>
  ilock(ip);
80100e33:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e36:	89 04 24             	mov    %eax,(%esp)
80100e39:	e8 3a 0d 00 00       	call   80101b78 <ilock>
  pgdir = 0;
80100e3e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100e45:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100e4c:	00 
80100e4d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100e54:	00 
80100e55:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100e5b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e5f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e62:	89 04 24             	mov    %eax,(%esp)
80100e65:	e8 04 12 00 00       	call   8010206e <readi>
80100e6a:	83 f8 33             	cmp    $0x33,%eax
80100e6d:	0f 86 54 03 00 00    	jbe    801011c7 <exec+0x3bb>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100e73:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100e79:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100e7e:	0f 85 46 03 00 00    	jne    801011ca <exec+0x3be>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100e84:	c7 04 24 0f 2e 10 80 	movl   $0x80102e0f,(%esp)
80100e8b:	e8 6d 71 00 00       	call   80107ffd <setupkvm>
80100e90:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100e93:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100e97:	0f 84 30 03 00 00    	je     801011cd <exec+0x3c1>
    goto bad;

  // Load program into memory.
  sz = 0;
80100e9d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ea4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100eab:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100eb1:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100eb4:	e9 c5 00 00 00       	jmp    80100f7e <exec+0x172>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100eb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ebc:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100ec3:	00 
80100ec4:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ec8:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100ece:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ed2:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ed5:	89 04 24             	mov    %eax,(%esp)
80100ed8:	e8 91 11 00 00       	call   8010206e <readi>
80100edd:	83 f8 20             	cmp    $0x20,%eax
80100ee0:	0f 85 ea 02 00 00    	jne    801011d0 <exec+0x3c4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ee6:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100eec:	83 f8 01             	cmp    $0x1,%eax
80100eef:	75 7f                	jne    80100f70 <exec+0x164>
      continue;
    if(ph.memsz < ph.filesz)
80100ef1:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100ef7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100efd:	39 c2                	cmp    %eax,%edx
80100eff:	0f 82 ce 02 00 00    	jb     801011d3 <exec+0x3c7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100f05:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100f0b:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100f11:	01 d0                	add    %edx,%eax
80100f13:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f17:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f1e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f21:	89 04 24             	mov    %eax,(%esp)
80100f24:	e8 a6 74 00 00       	call   801083cf <allocuvm>
80100f29:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f2c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f30:	0f 84 a0 02 00 00    	je     801011d6 <exec+0x3ca>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100f36:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100f3c:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100f42:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100f48:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100f4c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100f50:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100f53:	89 54 24 08          	mov    %edx,0x8(%esp)
80100f57:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f5b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f5e:	89 04 24             	mov    %eax,(%esp)
80100f61:	e8 7a 73 00 00       	call   801082e0 <loaduvm>
80100f66:	85 c0                	test   %eax,%eax
80100f68:	0f 88 6b 02 00 00    	js     801011d9 <exec+0x3cd>
80100f6e:	eb 01                	jmp    80100f71 <exec+0x165>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100f70:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100f71:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100f75:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100f78:	83 c0 20             	add    $0x20,%eax
80100f7b:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100f7e:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100f85:	0f b7 c0             	movzwl %ax,%eax
80100f88:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100f8b:	0f 8f 28 ff ff ff    	jg     80100eb9 <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100f91:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f94:	89 04 24             	mov    %eax,(%esp)
80100f97:	e8 60 0e 00 00       	call   80101dfc <iunlockput>
  ip = 0;
80100f9c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100fa3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fa6:	05 ff 0f 00 00       	add    $0xfff,%eax
80100fab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100fb0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100fb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fb6:	05 00 20 00 00       	add    $0x2000,%eax
80100fbb:	89 44 24 08          	mov    %eax,0x8(%esp)
80100fbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fc6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fc9:	89 04 24             	mov    %eax,(%esp)
80100fcc:	e8 fe 73 00 00       	call   801083cf <allocuvm>
80100fd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100fd4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100fd8:	0f 84 fe 01 00 00    	je     801011dc <exec+0x3d0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100fde:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fe1:	2d 00 20 00 00       	sub    $0x2000,%eax
80100fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fed:	89 04 24             	mov    %eax,(%esp)
80100ff0:	e8 fe 75 00 00       	call   801085f3 <clearpteu>
  sp = sz;
80100ff5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ff8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100ffb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101002:	e9 81 00 00 00       	jmp    80101088 <exec+0x27c>
    if(argc >= MAXARG)
80101007:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
8010100b:	0f 87 ce 01 00 00    	ja     801011df <exec+0x3d3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101011:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101014:	c1 e0 02             	shl    $0x2,%eax
80101017:	03 45 0c             	add    0xc(%ebp),%eax
8010101a:	8b 00                	mov    (%eax),%eax
8010101c:	89 04 24             	mov    %eax,(%esp)
8010101f:	e8 50 46 00 00       	call   80105674 <strlen>
80101024:	f7 d0                	not    %eax
80101026:	03 45 dc             	add    -0x24(%ebp),%eax
80101029:	83 e0 fc             	and    $0xfffffffc,%eax
8010102c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
8010102f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101032:	c1 e0 02             	shl    $0x2,%eax
80101035:	03 45 0c             	add    0xc(%ebp),%eax
80101038:	8b 00                	mov    (%eax),%eax
8010103a:	89 04 24             	mov    %eax,(%esp)
8010103d:	e8 32 46 00 00       	call   80105674 <strlen>
80101042:	83 c0 01             	add    $0x1,%eax
80101045:	89 c2                	mov    %eax,%edx
80101047:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010104a:	c1 e0 02             	shl    $0x2,%eax
8010104d:	03 45 0c             	add    0xc(%ebp),%eax
80101050:	8b 00                	mov    (%eax),%eax
80101052:	89 54 24 0c          	mov    %edx,0xc(%esp)
80101056:	89 44 24 08          	mov    %eax,0x8(%esp)
8010105a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010105d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101061:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101064:	89 04 24             	mov    %eax,(%esp)
80101067:	e8 3b 77 00 00       	call   801087a7 <copyout>
8010106c:	85 c0                	test   %eax,%eax
8010106e:	0f 88 6e 01 00 00    	js     801011e2 <exec+0x3d6>
      goto bad;
    ustack[3+argc] = sp;
80101074:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101077:	8d 50 03             	lea    0x3(%eax),%edx
8010107a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010107d:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80101084:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101088:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010108b:	c1 e0 02             	shl    $0x2,%eax
8010108e:	03 45 0c             	add    0xc(%ebp),%eax
80101091:	8b 00                	mov    (%eax),%eax
80101093:	85 c0                	test   %eax,%eax
80101095:	0f 85 6c ff ff ff    	jne    80101007 <exec+0x1fb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
8010109b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010109e:	83 c0 03             	add    $0x3,%eax
801010a1:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
801010a8:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
801010ac:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
801010b3:	ff ff ff 
  ustack[1] = argc;
801010b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010b9:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
801010bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010c2:	83 c0 01             	add    $0x1,%eax
801010c5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801010cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010cf:	29 d0                	sub    %edx,%eax
801010d1:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
801010d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010da:	83 c0 04             	add    $0x4,%eax
801010dd:	c1 e0 02             	shl    $0x2,%eax
801010e0:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
801010e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010e6:	83 c0 04             	add    $0x4,%eax
801010e9:	c1 e0 02             	shl    $0x2,%eax
801010ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
801010f0:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
801010f6:	89 44 24 08          	mov    %eax,0x8(%esp)
801010fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80101101:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101104:	89 04 24             	mov    %eax,(%esp)
80101107:	e8 9b 76 00 00       	call   801087a7 <copyout>
8010110c:	85 c0                	test   %eax,%eax
8010110e:	0f 88 d1 00 00 00    	js     801011e5 <exec+0x3d9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101114:	8b 45 08             	mov    0x8(%ebp),%eax
80101117:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010111a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010111d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101120:	eb 17                	jmp    80101139 <exec+0x32d>
    if(*s == '/')
80101122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101125:	0f b6 00             	movzbl (%eax),%eax
80101128:	3c 2f                	cmp    $0x2f,%al
8010112a:	75 09                	jne    80101135 <exec+0x329>
      last = s+1;
8010112c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010112f:	83 c0 01             	add    $0x1,%eax
80101132:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101135:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010113c:	0f b6 00             	movzbl (%eax),%eax
8010113f:	84 c0                	test   %al,%al
80101141:	75 df                	jne    80101122 <exec+0x316>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80101143:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101149:	8d 50 6c             	lea    0x6c(%eax),%edx
8010114c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101153:	00 
80101154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101157:	89 44 24 04          	mov    %eax,0x4(%esp)
8010115b:	89 14 24             	mov    %edx,(%esp)
8010115e:	e8 c3 44 00 00       	call   80105626 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80101163:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101169:	8b 40 04             	mov    0x4(%eax),%eax
8010116c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
8010116f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101175:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101178:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
8010117b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101181:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101184:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80101186:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010118c:	8b 40 18             	mov    0x18(%eax),%eax
8010118f:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80101195:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80101198:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010119e:	8b 40 18             	mov    0x18(%eax),%eax
801011a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
801011a4:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
801011a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011ad:	89 04 24             	mov    %eax,(%esp)
801011b0:	e8 39 6f 00 00       	call   801080ee <switchuvm>
  freevm(oldpgdir);
801011b5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801011b8:	89 04 24             	mov    %eax,(%esp)
801011bb:	e8 a5 73 00 00       	call   80108565 <freevm>
  return 0;
801011c0:	b8 00 00 00 00       	mov    $0x0,%eax
801011c5:	eb 46                	jmp    8010120d <exec+0x401>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
801011c7:	90                   	nop
801011c8:	eb 1c                	jmp    801011e6 <exec+0x3da>
  if(elf.magic != ELF_MAGIC)
    goto bad;
801011ca:	90                   	nop
801011cb:	eb 19                	jmp    801011e6 <exec+0x3da>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
801011cd:	90                   	nop
801011ce:	eb 16                	jmp    801011e6 <exec+0x3da>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
801011d0:	90                   	nop
801011d1:	eb 13                	jmp    801011e6 <exec+0x3da>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
801011d3:	90                   	nop
801011d4:	eb 10                	jmp    801011e6 <exec+0x3da>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
801011d6:	90                   	nop
801011d7:	eb 0d                	jmp    801011e6 <exec+0x3da>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
801011d9:	90                   	nop
801011da:	eb 0a                	jmp    801011e6 <exec+0x3da>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
801011dc:	90                   	nop
801011dd:	eb 07                	jmp    801011e6 <exec+0x3da>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
801011df:	90                   	nop
801011e0:	eb 04                	jmp    801011e6 <exec+0x3da>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
801011e2:	90                   	nop
801011e3:	eb 01                	jmp    801011e6 <exec+0x3da>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
801011e5:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
801011e6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801011ea:	74 0b                	je     801011f7 <exec+0x3eb>
    freevm(pgdir);
801011ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801011ef:	89 04 24             	mov    %eax,(%esp)
801011f2:	e8 6e 73 00 00       	call   80108565 <freevm>
  if(ip)
801011f7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801011fb:	74 0b                	je     80101208 <exec+0x3fc>
    iunlockput(ip);
801011fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101200:	89 04 24             	mov    %eax,(%esp)
80101203:	e8 f4 0b 00 00       	call   80101dfc <iunlockput>
  return -1;
80101208:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010120d:	c9                   	leave  
8010120e:	c3                   	ret    
	...

80101210 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101210:	55                   	push   %ebp
80101211:	89 e5                	mov    %esp,%ebp
80101213:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80101216:	c7 44 24 04 ad 88 10 	movl   $0x801088ad,0x4(%esp)
8010121d:	80 
8010121e:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101225:	e8 5c 3f 00 00       	call   80105186 <initlock>
}
8010122a:	c9                   	leave  
8010122b:	c3                   	ret    

8010122c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
8010122c:	55                   	push   %ebp
8010122d:	89 e5                	mov    %esp,%ebp
8010122f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80101232:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101239:	e8 69 3f 00 00       	call   801051a7 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010123e:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
80101245:	eb 29                	jmp    80101270 <filealloc+0x44>
    if(f->ref == 0){
80101247:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010124a:	8b 40 04             	mov    0x4(%eax),%eax
8010124d:	85 c0                	test   %eax,%eax
8010124f:	75 1b                	jne    8010126c <filealloc+0x40>
      f->ref = 1;
80101251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101254:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010125b:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101262:	e8 a2 3f 00 00       	call   80105209 <release>
      return f;
80101267:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010126a:	eb 1e                	jmp    8010128a <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010126c:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101270:	81 7d f4 14 e8 10 80 	cmpl   $0x8010e814,-0xc(%ebp)
80101277:	72 ce                	jb     80101247 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101279:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101280:	e8 84 3f 00 00       	call   80105209 <release>
  return 0;
80101285:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010128a:	c9                   	leave  
8010128b:	c3                   	ret    

8010128c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010128c:	55                   	push   %ebp
8010128d:	89 e5                	mov    %esp,%ebp
8010128f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101292:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101299:	e8 09 3f 00 00       	call   801051a7 <acquire>
  if(f->ref < 1)
8010129e:	8b 45 08             	mov    0x8(%ebp),%eax
801012a1:	8b 40 04             	mov    0x4(%eax),%eax
801012a4:	85 c0                	test   %eax,%eax
801012a6:	7f 0c                	jg     801012b4 <filedup+0x28>
    panic("filedup");
801012a8:	c7 04 24 b4 88 10 80 	movl   $0x801088b4,(%esp)
801012af:	e8 89 f2 ff ff       	call   8010053d <panic>
  f->ref++;
801012b4:	8b 45 08             	mov    0x8(%ebp),%eax
801012b7:	8b 40 04             	mov    0x4(%eax),%eax
801012ba:	8d 50 01             	lea    0x1(%eax),%edx
801012bd:	8b 45 08             	mov    0x8(%ebp),%eax
801012c0:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801012c3:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012ca:	e8 3a 3f 00 00       	call   80105209 <release>
  return f;
801012cf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801012d2:	c9                   	leave  
801012d3:	c3                   	ret    

801012d4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801012d4:	55                   	push   %ebp
801012d5:	89 e5                	mov    %esp,%ebp
801012d7:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
801012da:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012e1:	e8 c1 3e 00 00       	call   801051a7 <acquire>
  if(f->ref < 1)
801012e6:	8b 45 08             	mov    0x8(%ebp),%eax
801012e9:	8b 40 04             	mov    0x4(%eax),%eax
801012ec:	85 c0                	test   %eax,%eax
801012ee:	7f 0c                	jg     801012fc <fileclose+0x28>
    panic("fileclose");
801012f0:	c7 04 24 bc 88 10 80 	movl   $0x801088bc,(%esp)
801012f7:	e8 41 f2 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
801012fc:	8b 45 08             	mov    0x8(%ebp),%eax
801012ff:	8b 40 04             	mov    0x4(%eax),%eax
80101302:	8d 50 ff             	lea    -0x1(%eax),%edx
80101305:	8b 45 08             	mov    0x8(%ebp),%eax
80101308:	89 50 04             	mov    %edx,0x4(%eax)
8010130b:	8b 45 08             	mov    0x8(%ebp),%eax
8010130e:	8b 40 04             	mov    0x4(%eax),%eax
80101311:	85 c0                	test   %eax,%eax
80101313:	7e 11                	jle    80101326 <fileclose+0x52>
    release(&ftable.lock);
80101315:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010131c:	e8 e8 3e 00 00       	call   80105209 <release>
    return;
80101321:	e9 82 00 00 00       	jmp    801013a8 <fileclose+0xd4>
  }
  ff = *f;
80101326:	8b 45 08             	mov    0x8(%ebp),%eax
80101329:	8b 10                	mov    (%eax),%edx
8010132b:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010132e:	8b 50 04             	mov    0x4(%eax),%edx
80101331:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101334:	8b 50 08             	mov    0x8(%eax),%edx
80101337:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010133a:	8b 50 0c             	mov    0xc(%eax),%edx
8010133d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101340:	8b 50 10             	mov    0x10(%eax),%edx
80101343:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101346:	8b 40 14             	mov    0x14(%eax),%eax
80101349:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010134c:	8b 45 08             	mov    0x8(%ebp),%eax
8010134f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101356:	8b 45 08             	mov    0x8(%ebp),%eax
80101359:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010135f:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101366:	e8 9e 3e 00 00       	call   80105209 <release>
  
  if(ff.type == FD_PIPE)
8010136b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010136e:	83 f8 01             	cmp    $0x1,%eax
80101371:	75 18                	jne    8010138b <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101373:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101377:	0f be d0             	movsbl %al,%edx
8010137a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010137d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101381:	89 04 24             	mov    %eax,(%esp)
80101384:	e8 02 2d 00 00       	call   8010408b <pipeclose>
80101389:	eb 1d                	jmp    801013a8 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
8010138b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010138e:	83 f8 02             	cmp    $0x2,%eax
80101391:	75 15                	jne    801013a8 <fileclose+0xd4>
    begin_trans();
80101393:	e8 95 21 00 00       	call   8010352d <begin_trans>
    iput(ff.ip);
80101398:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010139b:	89 04 24             	mov    %eax,(%esp)
8010139e:	e8 88 09 00 00       	call   80101d2b <iput>
    commit_trans();
801013a3:	e8 ce 21 00 00       	call   80103576 <commit_trans>
  }
}
801013a8:	c9                   	leave  
801013a9:	c3                   	ret    

801013aa <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801013aa:	55                   	push   %ebp
801013ab:	89 e5                	mov    %esp,%ebp
801013ad:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801013b0:	8b 45 08             	mov    0x8(%ebp),%eax
801013b3:	8b 00                	mov    (%eax),%eax
801013b5:	83 f8 02             	cmp    $0x2,%eax
801013b8:	75 38                	jne    801013f2 <filestat+0x48>
    ilock(f->ip);
801013ba:	8b 45 08             	mov    0x8(%ebp),%eax
801013bd:	8b 40 10             	mov    0x10(%eax),%eax
801013c0:	89 04 24             	mov    %eax,(%esp)
801013c3:	e8 b0 07 00 00       	call   80101b78 <ilock>
    stati(f->ip, st);
801013c8:	8b 45 08             	mov    0x8(%ebp),%eax
801013cb:	8b 40 10             	mov    0x10(%eax),%eax
801013ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801013d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801013d5:	89 04 24             	mov    %eax,(%esp)
801013d8:	e8 4c 0c 00 00       	call   80102029 <stati>
    iunlock(f->ip);
801013dd:	8b 45 08             	mov    0x8(%ebp),%eax
801013e0:	8b 40 10             	mov    0x10(%eax),%eax
801013e3:	89 04 24             	mov    %eax,(%esp)
801013e6:	e8 db 08 00 00       	call   80101cc6 <iunlock>
    return 0;
801013eb:	b8 00 00 00 00       	mov    $0x0,%eax
801013f0:	eb 05                	jmp    801013f7 <filestat+0x4d>
  }
  return -1;
801013f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801013f7:	c9                   	leave  
801013f8:	c3                   	ret    

801013f9 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801013f9:	55                   	push   %ebp
801013fa:	89 e5                	mov    %esp,%ebp
801013fc:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801013ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101402:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101406:	84 c0                	test   %al,%al
80101408:	75 0a                	jne    80101414 <fileread+0x1b>
    return -1;
8010140a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010140f:	e9 9f 00 00 00       	jmp    801014b3 <fileread+0xba>
  if(f->type == FD_PIPE)
80101414:	8b 45 08             	mov    0x8(%ebp),%eax
80101417:	8b 00                	mov    (%eax),%eax
80101419:	83 f8 01             	cmp    $0x1,%eax
8010141c:	75 1e                	jne    8010143c <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010141e:	8b 45 08             	mov    0x8(%ebp),%eax
80101421:	8b 40 0c             	mov    0xc(%eax),%eax
80101424:	8b 55 10             	mov    0x10(%ebp),%edx
80101427:	89 54 24 08          	mov    %edx,0x8(%esp)
8010142b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010142e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101432:	89 04 24             	mov    %eax,(%esp)
80101435:	e8 d3 2d 00 00       	call   8010420d <piperead>
8010143a:	eb 77                	jmp    801014b3 <fileread+0xba>
  if(f->type == FD_INODE){
8010143c:	8b 45 08             	mov    0x8(%ebp),%eax
8010143f:	8b 00                	mov    (%eax),%eax
80101441:	83 f8 02             	cmp    $0x2,%eax
80101444:	75 61                	jne    801014a7 <fileread+0xae>
    ilock(f->ip);
80101446:	8b 45 08             	mov    0x8(%ebp),%eax
80101449:	8b 40 10             	mov    0x10(%eax),%eax
8010144c:	89 04 24             	mov    %eax,(%esp)
8010144f:	e8 24 07 00 00       	call   80101b78 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101454:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101457:	8b 45 08             	mov    0x8(%ebp),%eax
8010145a:	8b 50 14             	mov    0x14(%eax),%edx
8010145d:	8b 45 08             	mov    0x8(%ebp),%eax
80101460:	8b 40 10             	mov    0x10(%eax),%eax
80101463:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101467:	89 54 24 08          	mov    %edx,0x8(%esp)
8010146b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010146e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101472:	89 04 24             	mov    %eax,(%esp)
80101475:	e8 f4 0b 00 00       	call   8010206e <readi>
8010147a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010147d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101481:	7e 11                	jle    80101494 <fileread+0x9b>
      f->off += r;
80101483:	8b 45 08             	mov    0x8(%ebp),%eax
80101486:	8b 50 14             	mov    0x14(%eax),%edx
80101489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148c:	01 c2                	add    %eax,%edx
8010148e:	8b 45 08             	mov    0x8(%ebp),%eax
80101491:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101494:	8b 45 08             	mov    0x8(%ebp),%eax
80101497:	8b 40 10             	mov    0x10(%eax),%eax
8010149a:	89 04 24             	mov    %eax,(%esp)
8010149d:	e8 24 08 00 00       	call   80101cc6 <iunlock>
    return r;
801014a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a5:	eb 0c                	jmp    801014b3 <fileread+0xba>
  }
  panic("fileread");
801014a7:	c7 04 24 c6 88 10 80 	movl   $0x801088c6,(%esp)
801014ae:	e8 8a f0 ff ff       	call   8010053d <panic>
}
801014b3:	c9                   	leave  
801014b4:	c3                   	ret    

801014b5 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801014b5:	55                   	push   %ebp
801014b6:	89 e5                	mov    %esp,%ebp
801014b8:	53                   	push   %ebx
801014b9:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801014bc:	8b 45 08             	mov    0x8(%ebp),%eax
801014bf:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801014c3:	84 c0                	test   %al,%al
801014c5:	75 0a                	jne    801014d1 <filewrite+0x1c>
    return -1;
801014c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014cc:	e9 23 01 00 00       	jmp    801015f4 <filewrite+0x13f>
  if(f->type == FD_PIPE)
801014d1:	8b 45 08             	mov    0x8(%ebp),%eax
801014d4:	8b 00                	mov    (%eax),%eax
801014d6:	83 f8 01             	cmp    $0x1,%eax
801014d9:	75 21                	jne    801014fc <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801014db:	8b 45 08             	mov    0x8(%ebp),%eax
801014de:	8b 40 0c             	mov    0xc(%eax),%eax
801014e1:	8b 55 10             	mov    0x10(%ebp),%edx
801014e4:	89 54 24 08          	mov    %edx,0x8(%esp)
801014e8:	8b 55 0c             	mov    0xc(%ebp),%edx
801014eb:	89 54 24 04          	mov    %edx,0x4(%esp)
801014ef:	89 04 24             	mov    %eax,(%esp)
801014f2:	e8 26 2c 00 00       	call   8010411d <pipewrite>
801014f7:	e9 f8 00 00 00       	jmp    801015f4 <filewrite+0x13f>
  if(f->type == FD_INODE){
801014fc:	8b 45 08             	mov    0x8(%ebp),%eax
801014ff:	8b 00                	mov    (%eax),%eax
80101501:	83 f8 02             	cmp    $0x2,%eax
80101504:	0f 85 de 00 00 00    	jne    801015e8 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010150a:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101511:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101518:	e9 a8 00 00 00       	jmp    801015c5 <filewrite+0x110>
      int n1 = n - i;
8010151d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101520:	8b 55 10             	mov    0x10(%ebp),%edx
80101523:	89 d1                	mov    %edx,%ecx
80101525:	29 c1                	sub    %eax,%ecx
80101527:	89 c8                	mov    %ecx,%eax
80101529:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010152c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101532:	7e 06                	jle    8010153a <filewrite+0x85>
        n1 = max;
80101534:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101537:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
8010153a:	e8 ee 1f 00 00       	call   8010352d <begin_trans>
      ilock(f->ip);
8010153f:	8b 45 08             	mov    0x8(%ebp),%eax
80101542:	8b 40 10             	mov    0x10(%eax),%eax
80101545:	89 04 24             	mov    %eax,(%esp)
80101548:	e8 2b 06 00 00       	call   80101b78 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010154d:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101550:	8b 45 08             	mov    0x8(%ebp),%eax
80101553:	8b 48 14             	mov    0x14(%eax),%ecx
80101556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101559:	89 c2                	mov    %eax,%edx
8010155b:	03 55 0c             	add    0xc(%ebp),%edx
8010155e:	8b 45 08             	mov    0x8(%ebp),%eax
80101561:	8b 40 10             	mov    0x10(%eax),%eax
80101564:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80101568:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010156c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101570:	89 04 24             	mov    %eax,(%esp)
80101573:	e8 61 0c 00 00       	call   801021d9 <writei>
80101578:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010157b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010157f:	7e 11                	jle    80101592 <filewrite+0xdd>
        f->off += r;
80101581:	8b 45 08             	mov    0x8(%ebp),%eax
80101584:	8b 50 14             	mov    0x14(%eax),%edx
80101587:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010158a:	01 c2                	add    %eax,%edx
8010158c:	8b 45 08             	mov    0x8(%ebp),%eax
8010158f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101592:	8b 45 08             	mov    0x8(%ebp),%eax
80101595:	8b 40 10             	mov    0x10(%eax),%eax
80101598:	89 04 24             	mov    %eax,(%esp)
8010159b:	e8 26 07 00 00       	call   80101cc6 <iunlock>
      commit_trans();
801015a0:	e8 d1 1f 00 00       	call   80103576 <commit_trans>

      if(r < 0)
801015a5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801015a9:	78 28                	js     801015d3 <filewrite+0x11e>
        break;
      if(r != n1)
801015ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015ae:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801015b1:	74 0c                	je     801015bf <filewrite+0x10a>
        panic("short filewrite");
801015b3:	c7 04 24 cf 88 10 80 	movl   $0x801088cf,(%esp)
801015ba:	e8 7e ef ff ff       	call   8010053d <panic>
      i += r;
801015bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015c2:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801015c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015c8:	3b 45 10             	cmp    0x10(%ebp),%eax
801015cb:	0f 8c 4c ff ff ff    	jl     8010151d <filewrite+0x68>
801015d1:	eb 01                	jmp    801015d4 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
801015d3:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801015d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015d7:	3b 45 10             	cmp    0x10(%ebp),%eax
801015da:	75 05                	jne    801015e1 <filewrite+0x12c>
801015dc:	8b 45 10             	mov    0x10(%ebp),%eax
801015df:	eb 05                	jmp    801015e6 <filewrite+0x131>
801015e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801015e6:	eb 0c                	jmp    801015f4 <filewrite+0x13f>
  }
  panic("filewrite");
801015e8:	c7 04 24 df 88 10 80 	movl   $0x801088df,(%esp)
801015ef:	e8 49 ef ff ff       	call   8010053d <panic>
}
801015f4:	83 c4 24             	add    $0x24,%esp
801015f7:	5b                   	pop    %ebx
801015f8:	5d                   	pop    %ebp
801015f9:	c3                   	ret    
	...

801015fc <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801015fc:	55                   	push   %ebp
801015fd:	89 e5                	mov    %esp,%ebp
801015ff:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101602:	8b 45 08             	mov    0x8(%ebp),%eax
80101605:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010160c:	00 
8010160d:	89 04 24             	mov    %eax,(%esp)
80101610:	e8 91 eb ff ff       	call   801001a6 <bread>
80101615:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161b:	83 c0 18             	add    $0x18,%eax
8010161e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101625:	00 
80101626:	89 44 24 04          	mov    %eax,0x4(%esp)
8010162a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010162d:	89 04 24             	mov    %eax,(%esp)
80101630:	e8 94 3e 00 00       	call   801054c9 <memmove>
  brelse(bp);
80101635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101638:	89 04 24             	mov    %eax,(%esp)
8010163b:	e8 d7 eb ff ff       	call   80100217 <brelse>
}
80101640:	c9                   	leave  
80101641:	c3                   	ret    

80101642 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101642:	55                   	push   %ebp
80101643:	89 e5                	mov    %esp,%ebp
80101645:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101648:	8b 55 0c             	mov    0xc(%ebp),%edx
8010164b:	8b 45 08             	mov    0x8(%ebp),%eax
8010164e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101652:	89 04 24             	mov    %eax,(%esp)
80101655:	e8 4c eb ff ff       	call   801001a6 <bread>
8010165a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010165d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101660:	83 c0 18             	add    $0x18,%eax
80101663:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010166a:	00 
8010166b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101672:	00 
80101673:	89 04 24             	mov    %eax,(%esp)
80101676:	e8 7b 3d 00 00       	call   801053f6 <memset>
  log_write(bp);
8010167b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010167e:	89 04 24             	mov    %eax,(%esp)
80101681:	e8 48 1f 00 00       	call   801035ce <log_write>
  brelse(bp);
80101686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101689:	89 04 24             	mov    %eax,(%esp)
8010168c:	e8 86 eb ff ff       	call   80100217 <brelse>
}
80101691:	c9                   	leave  
80101692:	c3                   	ret    

80101693 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101693:	55                   	push   %ebp
80101694:	89 e5                	mov    %esp,%ebp
80101696:	53                   	push   %ebx
80101697:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010169a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801016a1:	8b 45 08             	mov    0x8(%ebp),%eax
801016a4:	8d 55 d8             	lea    -0x28(%ebp),%edx
801016a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801016ab:	89 04 24             	mov    %eax,(%esp)
801016ae:	e8 49 ff ff ff       	call   801015fc <readsb>
  for(b = 0; b < sb.size; b += BPB){
801016b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801016ba:	e9 11 01 00 00       	jmp    801017d0 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801016bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801016c8:	85 c0                	test   %eax,%eax
801016ca:	0f 48 c2             	cmovs  %edx,%eax
801016cd:	c1 f8 0c             	sar    $0xc,%eax
801016d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801016d3:	c1 ea 03             	shr    $0x3,%edx
801016d6:	01 d0                	add    %edx,%eax
801016d8:	83 c0 03             	add    $0x3,%eax
801016db:	89 44 24 04          	mov    %eax,0x4(%esp)
801016df:	8b 45 08             	mov    0x8(%ebp),%eax
801016e2:	89 04 24             	mov    %eax,(%esp)
801016e5:	e8 bc ea ff ff       	call   801001a6 <bread>
801016ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801016ed:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801016f4:	e9 a7 00 00 00       	jmp    801017a0 <balloc+0x10d>
      m = 1 << (bi % 8);
801016f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016fc:	89 c2                	mov    %eax,%edx
801016fe:	c1 fa 1f             	sar    $0x1f,%edx
80101701:	c1 ea 1d             	shr    $0x1d,%edx
80101704:	01 d0                	add    %edx,%eax
80101706:	83 e0 07             	and    $0x7,%eax
80101709:	29 d0                	sub    %edx,%eax
8010170b:	ba 01 00 00 00       	mov    $0x1,%edx
80101710:	89 d3                	mov    %edx,%ebx
80101712:	89 c1                	mov    %eax,%ecx
80101714:	d3 e3                	shl    %cl,%ebx
80101716:	89 d8                	mov    %ebx,%eax
80101718:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010171b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171e:	8d 50 07             	lea    0x7(%eax),%edx
80101721:	85 c0                	test   %eax,%eax
80101723:	0f 48 c2             	cmovs  %edx,%eax
80101726:	c1 f8 03             	sar    $0x3,%eax
80101729:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010172c:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101731:	0f b6 c0             	movzbl %al,%eax
80101734:	23 45 e8             	and    -0x18(%ebp),%eax
80101737:	85 c0                	test   %eax,%eax
80101739:	75 61                	jne    8010179c <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
8010173b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010173e:	8d 50 07             	lea    0x7(%eax),%edx
80101741:	85 c0                	test   %eax,%eax
80101743:	0f 48 c2             	cmovs  %edx,%eax
80101746:	c1 f8 03             	sar    $0x3,%eax
80101749:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010174c:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101751:	89 d1                	mov    %edx,%ecx
80101753:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101756:	09 ca                	or     %ecx,%edx
80101758:	89 d1                	mov    %edx,%ecx
8010175a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010175d:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101761:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101764:	89 04 24             	mov    %eax,(%esp)
80101767:	e8 62 1e 00 00       	call   801035ce <log_write>
        brelse(bp);
8010176c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010176f:	89 04 24             	mov    %eax,(%esp)
80101772:	e8 a0 ea ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010177d:	01 c2                	add    %eax,%edx
8010177f:	8b 45 08             	mov    0x8(%ebp),%eax
80101782:	89 54 24 04          	mov    %edx,0x4(%esp)
80101786:	89 04 24             	mov    %eax,(%esp)
80101789:	e8 b4 fe ff ff       	call   80101642 <bzero>
        return b + bi;
8010178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101791:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101794:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
80101796:	83 c4 34             	add    $0x34,%esp
80101799:	5b                   	pop    %ebx
8010179a:	5d                   	pop    %ebp
8010179b:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010179c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801017a0:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801017a7:	7f 15                	jg     801017be <balloc+0x12b>
801017a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017af:	01 d0                	add    %edx,%eax
801017b1:	89 c2                	mov    %eax,%edx
801017b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801017b6:	39 c2                	cmp    %eax,%edx
801017b8:	0f 82 3b ff ff ff    	jb     801016f9 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801017be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017c1:	89 04 24             	mov    %eax,(%esp)
801017c4:	e8 4e ea ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801017c9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801017d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801017d6:	39 c2                	cmp    %eax,%edx
801017d8:	0f 82 e1 fe ff ff    	jb     801016bf <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801017de:	c7 04 24 e9 88 10 80 	movl   $0x801088e9,(%esp)
801017e5:	e8 53 ed ff ff       	call   8010053d <panic>

801017ea <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801017ea:	55                   	push   %ebp
801017eb:	89 e5                	mov    %esp,%ebp
801017ed:	53                   	push   %ebx
801017ee:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801017f1:	8d 45 dc             	lea    -0x24(%ebp),%eax
801017f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801017f8:	8b 45 08             	mov    0x8(%ebp),%eax
801017fb:	89 04 24             	mov    %eax,(%esp)
801017fe:	e8 f9 fd ff ff       	call   801015fc <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101803:	8b 45 0c             	mov    0xc(%ebp),%eax
80101806:	89 c2                	mov    %eax,%edx
80101808:	c1 ea 0c             	shr    $0xc,%edx
8010180b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010180e:	c1 e8 03             	shr    $0x3,%eax
80101811:	01 d0                	add    %edx,%eax
80101813:	8d 50 03             	lea    0x3(%eax),%edx
80101816:	8b 45 08             	mov    0x8(%ebp),%eax
80101819:	89 54 24 04          	mov    %edx,0x4(%esp)
8010181d:	89 04 24             	mov    %eax,(%esp)
80101820:	e8 81 e9 ff ff       	call   801001a6 <bread>
80101825:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101828:	8b 45 0c             	mov    0xc(%ebp),%eax
8010182b:	25 ff 0f 00 00       	and    $0xfff,%eax
80101830:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101833:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101836:	89 c2                	mov    %eax,%edx
80101838:	c1 fa 1f             	sar    $0x1f,%edx
8010183b:	c1 ea 1d             	shr    $0x1d,%edx
8010183e:	01 d0                	add    %edx,%eax
80101840:	83 e0 07             	and    $0x7,%eax
80101843:	29 d0                	sub    %edx,%eax
80101845:	ba 01 00 00 00       	mov    $0x1,%edx
8010184a:	89 d3                	mov    %edx,%ebx
8010184c:	89 c1                	mov    %eax,%ecx
8010184e:	d3 e3                	shl    %cl,%ebx
80101850:	89 d8                	mov    %ebx,%eax
80101852:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101855:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101858:	8d 50 07             	lea    0x7(%eax),%edx
8010185b:	85 c0                	test   %eax,%eax
8010185d:	0f 48 c2             	cmovs  %edx,%eax
80101860:	c1 f8 03             	sar    $0x3,%eax
80101863:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101866:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010186b:	0f b6 c0             	movzbl %al,%eax
8010186e:	23 45 ec             	and    -0x14(%ebp),%eax
80101871:	85 c0                	test   %eax,%eax
80101873:	75 0c                	jne    80101881 <bfree+0x97>
    panic("freeing free block");
80101875:	c7 04 24 ff 88 10 80 	movl   $0x801088ff,(%esp)
8010187c:	e8 bc ec ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
80101881:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101884:	8d 50 07             	lea    0x7(%eax),%edx
80101887:	85 c0                	test   %eax,%eax
80101889:	0f 48 c2             	cmovs  %edx,%eax
8010188c:	c1 f8 03             	sar    $0x3,%eax
8010188f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101892:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101897:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010189a:	f7 d1                	not    %ecx
8010189c:	21 ca                	and    %ecx,%edx
8010189e:	89 d1                	mov    %edx,%ecx
801018a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018a3:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801018a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018aa:	89 04 24             	mov    %eax,(%esp)
801018ad:	e8 1c 1d 00 00       	call   801035ce <log_write>
  brelse(bp);
801018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b5:	89 04 24             	mov    %eax,(%esp)
801018b8:	e8 5a e9 ff ff       	call   80100217 <brelse>
}
801018bd:	83 c4 34             	add    $0x34,%esp
801018c0:	5b                   	pop    %ebx
801018c1:	5d                   	pop    %ebp
801018c2:	c3                   	ret    

801018c3 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801018c3:	55                   	push   %ebp
801018c4:	89 e5                	mov    %esp,%ebp
801018c6:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801018c9:	c7 44 24 04 12 89 10 	movl   $0x80108912,0x4(%esp)
801018d0:	80 
801018d1:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801018d8:	e8 a9 38 00 00       	call   80105186 <initlock>
}
801018dd:	c9                   	leave  
801018de:	c3                   	ret    

801018df <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801018df:	55                   	push   %ebp
801018e0:	89 e5                	mov    %esp,%ebp
801018e2:	83 ec 48             	sub    $0x48,%esp
801018e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801018e8:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801018ec:	8b 45 08             	mov    0x8(%ebp),%eax
801018ef:	8d 55 dc             	lea    -0x24(%ebp),%edx
801018f2:	89 54 24 04          	mov    %edx,0x4(%esp)
801018f6:	89 04 24             	mov    %eax,(%esp)
801018f9:	e8 fe fc ff ff       	call   801015fc <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801018fe:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101905:	e9 98 00 00 00       	jmp    801019a2 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
8010190a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190d:	c1 e8 03             	shr    $0x3,%eax
80101910:	83 c0 02             	add    $0x2,%eax
80101913:	89 44 24 04          	mov    %eax,0x4(%esp)
80101917:	8b 45 08             	mov    0x8(%ebp),%eax
8010191a:	89 04 24             	mov    %eax,(%esp)
8010191d:	e8 84 e8 ff ff       	call   801001a6 <bread>
80101922:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101925:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101928:	8d 50 18             	lea    0x18(%eax),%edx
8010192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192e:	83 e0 07             	and    $0x7,%eax
80101931:	c1 e0 06             	shl    $0x6,%eax
80101934:	01 d0                	add    %edx,%eax
80101936:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101939:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010193c:	0f b7 00             	movzwl (%eax),%eax
8010193f:	66 85 c0             	test   %ax,%ax
80101942:	75 4f                	jne    80101993 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101944:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010194b:	00 
8010194c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101953:	00 
80101954:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101957:	89 04 24             	mov    %eax,(%esp)
8010195a:	e8 97 3a 00 00       	call   801053f6 <memset>
      dip->type = type;
8010195f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101962:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101966:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101969:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196c:	89 04 24             	mov    %eax,(%esp)
8010196f:	e8 5a 1c 00 00       	call   801035ce <log_write>
      brelse(bp);
80101974:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101977:	89 04 24             	mov    %eax,(%esp)
8010197a:	e8 98 e8 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101982:	89 44 24 04          	mov    %eax,0x4(%esp)
80101986:	8b 45 08             	mov    0x8(%ebp),%eax
80101989:	89 04 24             	mov    %eax,(%esp)
8010198c:	e8 e3 00 00 00       	call   80101a74 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101991:	c9                   	leave  
80101992:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
80101993:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101996:	89 04 24             	mov    %eax,(%esp)
80101999:	e8 79 e8 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010199e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801019a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801019a8:	39 c2                	cmp    %eax,%edx
801019aa:	0f 82 5a ff ff ff    	jb     8010190a <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801019b0:	c7 04 24 19 89 10 80 	movl   $0x80108919,(%esp)
801019b7:	e8 81 eb ff ff       	call   8010053d <panic>

801019bc <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801019bc:	55                   	push   %ebp
801019bd:	89 e5                	mov    %esp,%ebp
801019bf:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801019c2:	8b 45 08             	mov    0x8(%ebp),%eax
801019c5:	8b 40 04             	mov    0x4(%eax),%eax
801019c8:	c1 e8 03             	shr    $0x3,%eax
801019cb:	8d 50 02             	lea    0x2(%eax),%edx
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	8b 00                	mov    (%eax),%eax
801019d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801019d7:	89 04 24             	mov    %eax,(%esp)
801019da:	e8 c7 e7 ff ff       	call   801001a6 <bread>
801019df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801019e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e5:	8d 50 18             	lea    0x18(%eax),%edx
801019e8:	8b 45 08             	mov    0x8(%ebp),%eax
801019eb:	8b 40 04             	mov    0x4(%eax),%eax
801019ee:	83 e0 07             	and    $0x7,%eax
801019f1:	c1 e0 06             	shl    $0x6,%eax
801019f4:	01 d0                	add    %edx,%eax
801019f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801019f9:	8b 45 08             	mov    0x8(%ebp),%eax
801019fc:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a03:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101a06:	8b 45 08             	mov    0x8(%ebp),%eax
80101a09:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a10:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101a14:	8b 45 08             	mov    0x8(%ebp),%eax
80101a17:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a1e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101a22:	8b 45 08             	mov    0x8(%ebp),%eax
80101a25:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a2c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101a30:	8b 45 08             	mov    0x8(%ebp),%eax
80101a33:	8b 50 18             	mov    0x18(%eax),%edx
80101a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a39:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3f:	8d 50 1c             	lea    0x1c(%eax),%edx
80101a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a45:	83 c0 0c             	add    $0xc,%eax
80101a48:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a4f:	00 
80101a50:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a54:	89 04 24             	mov    %eax,(%esp)
80101a57:	e8 6d 3a 00 00       	call   801054c9 <memmove>
  log_write(bp);
80101a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5f:	89 04 24             	mov    %eax,(%esp)
80101a62:	e8 67 1b 00 00       	call   801035ce <log_write>
  brelse(bp);
80101a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6a:	89 04 24             	mov    %eax,(%esp)
80101a6d:	e8 a5 e7 ff ff       	call   80100217 <brelse>
}
80101a72:	c9                   	leave  
80101a73:	c3                   	ret    

80101a74 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a74:	55                   	push   %ebp
80101a75:	89 e5                	mov    %esp,%ebp
80101a77:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a7a:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a81:	e8 21 37 00 00       	call   801051a7 <acquire>

  // Is the inode already cached?
  empty = 0;
80101a86:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a8d:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
80101a94:	eb 59                	jmp    80101aef <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a99:	8b 40 08             	mov    0x8(%eax),%eax
80101a9c:	85 c0                	test   %eax,%eax
80101a9e:	7e 35                	jle    80101ad5 <iget+0x61>
80101aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa3:	8b 00                	mov    (%eax),%eax
80101aa5:	3b 45 08             	cmp    0x8(%ebp),%eax
80101aa8:	75 2b                	jne    80101ad5 <iget+0x61>
80101aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aad:	8b 40 04             	mov    0x4(%eax),%eax
80101ab0:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101ab3:	75 20                	jne    80101ad5 <iget+0x61>
      ip->ref++;
80101ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab8:	8b 40 08             	mov    0x8(%eax),%eax
80101abb:	8d 50 01             	lea    0x1(%eax),%edx
80101abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac1:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101ac4:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101acb:	e8 39 37 00 00       	call   80105209 <release>
      return ip;
80101ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad3:	eb 6f                	jmp    80101b44 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101ad5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101ad9:	75 10                	jne    80101aeb <iget+0x77>
80101adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ade:	8b 40 08             	mov    0x8(%eax),%eax
80101ae1:	85 c0                	test   %eax,%eax
80101ae3:	75 06                	jne    80101aeb <iget+0x77>
      empty = ip;
80101ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ae8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101aeb:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101aef:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
80101af6:	72 9e                	jb     80101a96 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101af8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101afc:	75 0c                	jne    80101b0a <iget+0x96>
    panic("iget: no inodes");
80101afe:	c7 04 24 2b 89 10 80 	movl   $0x8010892b,(%esp)
80101b05:	e8 33 ea ff ff       	call   8010053d <panic>

  ip = empty;
80101b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b13:	8b 55 08             	mov    0x8(%ebp),%edx
80101b16:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b1e:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b24:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b2e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101b35:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b3c:	e8 c8 36 00 00       	call   80105209 <release>

  return ip;
80101b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b44:	c9                   	leave  
80101b45:	c3                   	ret    

80101b46 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b46:	55                   	push   %ebp
80101b47:	89 e5                	mov    %esp,%ebp
80101b49:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101b4c:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b53:	e8 4f 36 00 00       	call   801051a7 <acquire>
  ip->ref++;
80101b58:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5b:	8b 40 08             	mov    0x8(%eax),%eax
80101b5e:	8d 50 01             	lea    0x1(%eax),%edx
80101b61:	8b 45 08             	mov    0x8(%ebp),%eax
80101b64:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b67:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b6e:	e8 96 36 00 00       	call   80105209 <release>
  return ip;
80101b73:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b76:	c9                   	leave  
80101b77:	c3                   	ret    

80101b78 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b78:	55                   	push   %ebp
80101b79:	89 e5                	mov    %esp,%ebp
80101b7b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b7e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b82:	74 0a                	je     80101b8e <ilock+0x16>
80101b84:	8b 45 08             	mov    0x8(%ebp),%eax
80101b87:	8b 40 08             	mov    0x8(%eax),%eax
80101b8a:	85 c0                	test   %eax,%eax
80101b8c:	7f 0c                	jg     80101b9a <ilock+0x22>
    panic("ilock");
80101b8e:	c7 04 24 3b 89 10 80 	movl   $0x8010893b,(%esp)
80101b95:	e8 a3 e9 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101b9a:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101ba1:	e8 01 36 00 00       	call   801051a7 <acquire>
  while(ip->flags & I_BUSY)
80101ba6:	eb 13                	jmp    80101bbb <ilock+0x43>
    sleep(ip, &icache.lock);
80101ba8:	c7 44 24 04 80 e8 10 	movl   $0x8010e880,0x4(%esp)
80101baf:	80 
80101bb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb3:	89 04 24             	mov    %eax,(%esp)
80101bb6:	e8 83 32 00 00       	call   80104e3e <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbe:	8b 40 0c             	mov    0xc(%eax),%eax
80101bc1:	83 e0 01             	and    $0x1,%eax
80101bc4:	84 c0                	test   %al,%al
80101bc6:	75 e0                	jne    80101ba8 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcb:	8b 40 0c             	mov    0xc(%eax),%eax
80101bce:	89 c2                	mov    %eax,%edx
80101bd0:	83 ca 01             	or     $0x1,%edx
80101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd6:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101bd9:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101be0:	e8 24 36 00 00       	call   80105209 <release>

  if(!(ip->flags & I_VALID)){
80101be5:	8b 45 08             	mov    0x8(%ebp),%eax
80101be8:	8b 40 0c             	mov    0xc(%eax),%eax
80101beb:	83 e0 02             	and    $0x2,%eax
80101bee:	85 c0                	test   %eax,%eax
80101bf0:	0f 85 ce 00 00 00    	jne    80101cc4 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf9:	8b 40 04             	mov    0x4(%eax),%eax
80101bfc:	c1 e8 03             	shr    $0x3,%eax
80101bff:	8d 50 02             	lea    0x2(%eax),%edx
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	8b 00                	mov    (%eax),%eax
80101c07:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c0b:	89 04 24             	mov    %eax,(%esp)
80101c0e:	e8 93 e5 ff ff       	call   801001a6 <bread>
80101c13:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c19:	8d 50 18             	lea    0x18(%eax),%edx
80101c1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1f:	8b 40 04             	mov    0x4(%eax),%eax
80101c22:	83 e0 07             	and    $0x7,%eax
80101c25:	c1 e0 06             	shl    $0x6,%eax
80101c28:	01 d0                	add    %edx,%eax
80101c2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101c2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c30:	0f b7 10             	movzwl (%eax),%edx
80101c33:	8b 45 08             	mov    0x8(%ebp),%eax
80101c36:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c3d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101c41:	8b 45 08             	mov    0x8(%ebp),%eax
80101c44:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101c48:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c4b:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c52:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101c56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c59:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c60:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101c64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c67:	8b 50 08             	mov    0x8(%eax),%edx
80101c6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6d:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c73:	8d 50 0c             	lea    0xc(%eax),%edx
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	83 c0 1c             	add    $0x1c,%eax
80101c7c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101c83:	00 
80101c84:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c88:	89 04 24             	mov    %eax,(%esp)
80101c8b:	e8 39 38 00 00       	call   801054c9 <memmove>
    brelse(bp);
80101c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c93:	89 04 24             	mov    %eax,(%esp)
80101c96:	e8 7c e5 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101c9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9e:	8b 40 0c             	mov    0xc(%eax),%eax
80101ca1:	89 c2                	mov    %eax,%edx
80101ca3:	83 ca 02             	or     $0x2,%edx
80101ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca9:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101cac:	8b 45 08             	mov    0x8(%ebp),%eax
80101caf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101cb3:	66 85 c0             	test   %ax,%ax
80101cb6:	75 0c                	jne    80101cc4 <ilock+0x14c>
      panic("ilock: no type");
80101cb8:	c7 04 24 41 89 10 80 	movl   $0x80108941,(%esp)
80101cbf:	e8 79 e8 ff ff       	call   8010053d <panic>
  }
}
80101cc4:	c9                   	leave  
80101cc5:	c3                   	ret    

80101cc6 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101cc6:	55                   	push   %ebp
80101cc7:	89 e5                	mov    %esp,%ebp
80101cc9:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101ccc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101cd0:	74 17                	je     80101ce9 <iunlock+0x23>
80101cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd5:	8b 40 0c             	mov    0xc(%eax),%eax
80101cd8:	83 e0 01             	and    $0x1,%eax
80101cdb:	85 c0                	test   %eax,%eax
80101cdd:	74 0a                	je     80101ce9 <iunlock+0x23>
80101cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce2:	8b 40 08             	mov    0x8(%eax),%eax
80101ce5:	85 c0                	test   %eax,%eax
80101ce7:	7f 0c                	jg     80101cf5 <iunlock+0x2f>
    panic("iunlock");
80101ce9:	c7 04 24 50 89 10 80 	movl   $0x80108950,(%esp)
80101cf0:	e8 48 e8 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101cf5:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101cfc:	e8 a6 34 00 00       	call   801051a7 <acquire>
  ip->flags &= ~I_BUSY;
80101d01:	8b 45 08             	mov    0x8(%ebp),%eax
80101d04:	8b 40 0c             	mov    0xc(%eax),%eax
80101d07:	89 c2                	mov    %eax,%edx
80101d09:	83 e2 fe             	and    $0xfffffffe,%edx
80101d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0f:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101d12:	8b 45 08             	mov    0x8(%ebp),%eax
80101d15:	89 04 24             	mov    %eax,(%esp)
80101d18:	e8 fd 31 00 00       	call   80104f1a <wakeup>
  release(&icache.lock);
80101d1d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d24:	e8 e0 34 00 00       	call   80105209 <release>
}
80101d29:	c9                   	leave  
80101d2a:	c3                   	ret    

80101d2b <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101d2b:	55                   	push   %ebp
80101d2c:	89 e5                	mov    %esp,%ebp
80101d2e:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101d31:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d38:	e8 6a 34 00 00       	call   801051a7 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101d3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d40:	8b 40 08             	mov    0x8(%eax),%eax
80101d43:	83 f8 01             	cmp    $0x1,%eax
80101d46:	0f 85 93 00 00 00    	jne    80101ddf <iput+0xb4>
80101d4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4f:	8b 40 0c             	mov    0xc(%eax),%eax
80101d52:	83 e0 02             	and    $0x2,%eax
80101d55:	85 c0                	test   %eax,%eax
80101d57:	0f 84 82 00 00 00    	je     80101ddf <iput+0xb4>
80101d5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d60:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101d64:	66 85 c0             	test   %ax,%ax
80101d67:	75 76                	jne    80101ddf <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101d69:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6c:	8b 40 0c             	mov    0xc(%eax),%eax
80101d6f:	83 e0 01             	and    $0x1,%eax
80101d72:	84 c0                	test   %al,%al
80101d74:	74 0c                	je     80101d82 <iput+0x57>
      panic("iput busy");
80101d76:	c7 04 24 58 89 10 80 	movl   $0x80108958,(%esp)
80101d7d:	e8 bb e7 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101d82:	8b 45 08             	mov    0x8(%ebp),%eax
80101d85:	8b 40 0c             	mov    0xc(%eax),%eax
80101d88:	89 c2                	mov    %eax,%edx
80101d8a:	83 ca 01             	or     $0x1,%edx
80101d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d90:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101d93:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d9a:	e8 6a 34 00 00       	call   80105209 <release>
    itrunc(ip);
80101d9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101da2:	89 04 24             	mov    %eax,(%esp)
80101da5:	e8 72 01 00 00       	call   80101f1c <itrunc>
    ip->type = 0;
80101daa:	8b 45 08             	mov    0x8(%ebp),%eax
80101dad:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101db3:	8b 45 08             	mov    0x8(%ebp),%eax
80101db6:	89 04 24             	mov    %eax,(%esp)
80101db9:	e8 fe fb ff ff       	call   801019bc <iupdate>
    acquire(&icache.lock);
80101dbe:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101dc5:	e8 dd 33 00 00       	call   801051a7 <acquire>
    ip->flags = 0;
80101dca:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	89 04 24             	mov    %eax,(%esp)
80101dda:	e8 3b 31 00 00       	call   80104f1a <wakeup>
  }
  ip->ref--;
80101ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80101de2:	8b 40 08             	mov    0x8(%eax),%eax
80101de5:	8d 50 ff             	lea    -0x1(%eax),%edx
80101de8:	8b 45 08             	mov    0x8(%ebp),%eax
80101deb:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101dee:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101df5:	e8 0f 34 00 00       	call   80105209 <release>
}
80101dfa:	c9                   	leave  
80101dfb:	c3                   	ret    

80101dfc <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101dfc:	55                   	push   %ebp
80101dfd:	89 e5                	mov    %esp,%ebp
80101dff:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101e02:	8b 45 08             	mov    0x8(%ebp),%eax
80101e05:	89 04 24             	mov    %eax,(%esp)
80101e08:	e8 b9 fe ff ff       	call   80101cc6 <iunlock>
  iput(ip);
80101e0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e10:	89 04 24             	mov    %eax,(%esp)
80101e13:	e8 13 ff ff ff       	call   80101d2b <iput>
}
80101e18:	c9                   	leave  
80101e19:	c3                   	ret    

80101e1a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101e1a:	55                   	push   %ebp
80101e1b:	89 e5                	mov    %esp,%ebp
80101e1d:	53                   	push   %ebx
80101e1e:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101e21:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101e25:	77 3e                	ja     80101e65 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101e27:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e2d:	83 c2 04             	add    $0x4,%edx
80101e30:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e34:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e3b:	75 20                	jne    80101e5d <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e40:	8b 00                	mov    (%eax),%eax
80101e42:	89 04 24             	mov    %eax,(%esp)
80101e45:	e8 49 f8 ff ff       	call   80101693 <balloc>
80101e4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e50:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e53:	8d 4a 04             	lea    0x4(%edx),%ecx
80101e56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e59:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e60:	e9 b1 00 00 00       	jmp    80101f16 <bmap+0xfc>
  }
  bn -= NDIRECT;
80101e65:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101e69:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e6d:	0f 87 97 00 00 00    	ja     80101f0a <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e73:	8b 45 08             	mov    0x8(%ebp),%eax
80101e76:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e79:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e7c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e80:	75 19                	jne    80101e9b <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e82:	8b 45 08             	mov    0x8(%ebp),%eax
80101e85:	8b 00                	mov    (%eax),%eax
80101e87:	89 04 24             	mov    %eax,(%esp)
80101e8a:	e8 04 f8 ff ff       	call   80101693 <balloc>
80101e8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e92:	8b 45 08             	mov    0x8(%ebp),%eax
80101e95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e98:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	8b 00                	mov    (%eax),%eax
80101ea0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ea3:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ea7:	89 04 24             	mov    %eax,(%esp)
80101eaa:	e8 f7 e2 ff ff       	call   801001a6 <bread>
80101eaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eb5:	83 c0 18             	add    $0x18,%eax
80101eb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebe:	c1 e0 02             	shl    $0x2,%eax
80101ec1:	03 45 ec             	add    -0x14(%ebp),%eax
80101ec4:	8b 00                	mov    (%eax),%eax
80101ec6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ec9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ecd:	75 2b                	jne    80101efa <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed2:	c1 e0 02             	shl    $0x2,%eax
80101ed5:	89 c3                	mov    %eax,%ebx
80101ed7:	03 5d ec             	add    -0x14(%ebp),%ebx
80101eda:	8b 45 08             	mov    0x8(%ebp),%eax
80101edd:	8b 00                	mov    (%eax),%eax
80101edf:	89 04 24             	mov    %eax,(%esp)
80101ee2:	e8 ac f7 ff ff       	call   80101693 <balloc>
80101ee7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eed:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ef2:	89 04 24             	mov    %eax,(%esp)
80101ef5:	e8 d4 16 00 00       	call   801035ce <log_write>
    }
    brelse(bp);
80101efa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101efd:	89 04 24             	mov    %eax,(%esp)
80101f00:	e8 12 e3 ff ff       	call   80100217 <brelse>
    return addr;
80101f05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f08:	eb 0c                	jmp    80101f16 <bmap+0xfc>
  }

  panic("bmap: out of range");
80101f0a:	c7 04 24 62 89 10 80 	movl   $0x80108962,(%esp)
80101f11:	e8 27 e6 ff ff       	call   8010053d <panic>
}
80101f16:	83 c4 24             	add    $0x24,%esp
80101f19:	5b                   	pop    %ebx
80101f1a:	5d                   	pop    %ebp
80101f1b:	c3                   	ret    

80101f1c <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f1c:	55                   	push   %ebp
80101f1d:	89 e5                	mov    %esp,%ebp
80101f1f:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f29:	eb 44                	jmp    80101f6f <itrunc+0x53>
    if(ip->addrs[i]){
80101f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f31:	83 c2 04             	add    $0x4,%edx
80101f34:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f38:	85 c0                	test   %eax,%eax
80101f3a:	74 2f                	je     80101f6b <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f42:	83 c2 04             	add    $0x4,%edx
80101f45:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101f49:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4c:	8b 00                	mov    (%eax),%eax
80101f4e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f52:	89 04 24             	mov    %eax,(%esp)
80101f55:	e8 90 f8 ff ff       	call   801017ea <bfree>
      ip->addrs[i] = 0;
80101f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f60:	83 c2 04             	add    $0x4,%edx
80101f63:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101f6a:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f6b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f6f:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f73:	7e b6                	jle    80101f2b <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101f75:	8b 45 08             	mov    0x8(%ebp),%eax
80101f78:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f7b:	85 c0                	test   %eax,%eax
80101f7d:	0f 84 8f 00 00 00    	je     80102012 <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f83:	8b 45 08             	mov    0x8(%ebp),%eax
80101f86:	8b 50 4c             	mov    0x4c(%eax),%edx
80101f89:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8c:	8b 00                	mov    (%eax),%eax
80101f8e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f92:	89 04 24             	mov    %eax,(%esp)
80101f95:	e8 0c e2 ff ff       	call   801001a6 <bread>
80101f9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fa0:	83 c0 18             	add    $0x18,%eax
80101fa3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101fa6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101fad:	eb 2f                	jmp    80101fde <itrunc+0xc2>
      if(a[j])
80101faf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fb2:	c1 e0 02             	shl    $0x2,%eax
80101fb5:	03 45 e8             	add    -0x18(%ebp),%eax
80101fb8:	8b 00                	mov    (%eax),%eax
80101fba:	85 c0                	test   %eax,%eax
80101fbc:	74 1c                	je     80101fda <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80101fbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fc1:	c1 e0 02             	shl    $0x2,%eax
80101fc4:	03 45 e8             	add    -0x18(%ebp),%eax
80101fc7:	8b 10                	mov    (%eax),%edx
80101fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fcc:	8b 00                	mov    (%eax),%eax
80101fce:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fd2:	89 04 24             	mov    %eax,(%esp)
80101fd5:	e8 10 f8 ff ff       	call   801017ea <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101fda:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101fde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe1:	83 f8 7f             	cmp    $0x7f,%eax
80101fe4:	76 c9                	jbe    80101faf <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101fe6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fe9:	89 04 24             	mov    %eax,(%esp)
80101fec:	e8 26 e2 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff4:	8b 50 4c             	mov    0x4c(%eax),%edx
80101ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffa:	8b 00                	mov    (%eax),%eax
80101ffc:	89 54 24 04          	mov    %edx,0x4(%esp)
80102000:	89 04 24             	mov    %eax,(%esp)
80102003:	e8 e2 f7 ff ff       	call   801017ea <bfree>
    ip->addrs[NDIRECT] = 0;
80102008:	8b 45 08             	mov    0x8(%ebp),%eax
8010200b:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80102012:	8b 45 08             	mov    0x8(%ebp),%eax
80102015:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
8010201c:	8b 45 08             	mov    0x8(%ebp),%eax
8010201f:	89 04 24             	mov    %eax,(%esp)
80102022:	e8 95 f9 ff ff       	call   801019bc <iupdate>
}
80102027:	c9                   	leave  
80102028:	c3                   	ret    

80102029 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80102029:	55                   	push   %ebp
8010202a:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
8010202c:	8b 45 08             	mov    0x8(%ebp),%eax
8010202f:	8b 00                	mov    (%eax),%eax
80102031:	89 c2                	mov    %eax,%edx
80102033:	8b 45 0c             	mov    0xc(%ebp),%eax
80102036:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102039:	8b 45 08             	mov    0x8(%ebp),%eax
8010203c:	8b 50 04             	mov    0x4(%eax),%edx
8010203f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102042:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102045:	8b 45 08             	mov    0x8(%ebp),%eax
80102048:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010204c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010204f:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80102059:	8b 45 0c             	mov    0xc(%ebp),%eax
8010205c:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102060:	8b 45 08             	mov    0x8(%ebp),%eax
80102063:	8b 50 18             	mov    0x18(%eax),%edx
80102066:	8b 45 0c             	mov    0xc(%ebp),%eax
80102069:	89 50 10             	mov    %edx,0x10(%eax)
}
8010206c:	5d                   	pop    %ebp
8010206d:	c3                   	ret    

8010206e <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
8010206e:	55                   	push   %ebp
8010206f:	89 e5                	mov    %esp,%ebp
80102071:	53                   	push   %ebx
80102072:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102075:	8b 45 08             	mov    0x8(%ebp),%eax
80102078:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010207c:	66 83 f8 03          	cmp    $0x3,%ax
80102080:	75 60                	jne    801020e2 <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80102082:	8b 45 08             	mov    0x8(%ebp),%eax
80102085:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102089:	66 85 c0             	test   %ax,%ax
8010208c:	78 20                	js     801020ae <readi+0x40>
8010208e:	8b 45 08             	mov    0x8(%ebp),%eax
80102091:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102095:	66 83 f8 09          	cmp    $0x9,%ax
80102099:	7f 13                	jg     801020ae <readi+0x40>
8010209b:	8b 45 08             	mov    0x8(%ebp),%eax
8010209e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020a2:	98                   	cwtl   
801020a3:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
801020aa:	85 c0                	test   %eax,%eax
801020ac:	75 0a                	jne    801020b8 <readi+0x4a>
      return -1;
801020ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b3:	e9 1b 01 00 00       	jmp    801021d3 <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
801020b8:	8b 45 08             	mov    0x8(%ebp),%eax
801020bb:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020bf:	98                   	cwtl   
801020c0:	8b 14 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%edx
801020c7:	8b 45 14             	mov    0x14(%ebp),%eax
801020ca:	89 44 24 08          	mov    %eax,0x8(%esp)
801020ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801020d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801020d5:	8b 45 08             	mov    0x8(%ebp),%eax
801020d8:	89 04 24             	mov    %eax,(%esp)
801020db:	ff d2                	call   *%edx
801020dd:	e9 f1 00 00 00       	jmp    801021d3 <readi+0x165>
  }

  if(off > ip->size || off + n < off)
801020e2:	8b 45 08             	mov    0x8(%ebp),%eax
801020e5:	8b 40 18             	mov    0x18(%eax),%eax
801020e8:	3b 45 10             	cmp    0x10(%ebp),%eax
801020eb:	72 0d                	jb     801020fa <readi+0x8c>
801020ed:	8b 45 14             	mov    0x14(%ebp),%eax
801020f0:	8b 55 10             	mov    0x10(%ebp),%edx
801020f3:	01 d0                	add    %edx,%eax
801020f5:	3b 45 10             	cmp    0x10(%ebp),%eax
801020f8:	73 0a                	jae    80102104 <readi+0x96>
    return -1;
801020fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020ff:	e9 cf 00 00 00       	jmp    801021d3 <readi+0x165>
  if(off + n > ip->size)
80102104:	8b 45 14             	mov    0x14(%ebp),%eax
80102107:	8b 55 10             	mov    0x10(%ebp),%edx
8010210a:	01 c2                	add    %eax,%edx
8010210c:	8b 45 08             	mov    0x8(%ebp),%eax
8010210f:	8b 40 18             	mov    0x18(%eax),%eax
80102112:	39 c2                	cmp    %eax,%edx
80102114:	76 0c                	jbe    80102122 <readi+0xb4>
    n = ip->size - off;
80102116:	8b 45 08             	mov    0x8(%ebp),%eax
80102119:	8b 40 18             	mov    0x18(%eax),%eax
8010211c:	2b 45 10             	sub    0x10(%ebp),%eax
8010211f:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102122:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102129:	e9 96 00 00 00       	jmp    801021c4 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010212e:	8b 45 10             	mov    0x10(%ebp),%eax
80102131:	c1 e8 09             	shr    $0x9,%eax
80102134:	89 44 24 04          	mov    %eax,0x4(%esp)
80102138:	8b 45 08             	mov    0x8(%ebp),%eax
8010213b:	89 04 24             	mov    %eax,(%esp)
8010213e:	e8 d7 fc ff ff       	call   80101e1a <bmap>
80102143:	8b 55 08             	mov    0x8(%ebp),%edx
80102146:	8b 12                	mov    (%edx),%edx
80102148:	89 44 24 04          	mov    %eax,0x4(%esp)
8010214c:	89 14 24             	mov    %edx,(%esp)
8010214f:	e8 52 e0 ff ff       	call   801001a6 <bread>
80102154:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102157:	8b 45 10             	mov    0x10(%ebp),%eax
8010215a:	89 c2                	mov    %eax,%edx
8010215c:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102162:	b8 00 02 00 00       	mov    $0x200,%eax
80102167:	89 c1                	mov    %eax,%ecx
80102169:	29 d1                	sub    %edx,%ecx
8010216b:	89 ca                	mov    %ecx,%edx
8010216d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102170:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102173:	89 cb                	mov    %ecx,%ebx
80102175:	29 c3                	sub    %eax,%ebx
80102177:	89 d8                	mov    %ebx,%eax
80102179:	39 c2                	cmp    %eax,%edx
8010217b:	0f 46 c2             	cmovbe %edx,%eax
8010217e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102181:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102184:	8d 50 18             	lea    0x18(%eax),%edx
80102187:	8b 45 10             	mov    0x10(%ebp),%eax
8010218a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010218f:	01 c2                	add    %eax,%edx
80102191:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102194:	89 44 24 08          	mov    %eax,0x8(%esp)
80102198:	89 54 24 04          	mov    %edx,0x4(%esp)
8010219c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010219f:	89 04 24             	mov    %eax,(%esp)
801021a2:	e8 22 33 00 00       	call   801054c9 <memmove>
    brelse(bp);
801021a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021aa:	89 04 24             	mov    %eax,(%esp)
801021ad:	e8 65 e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801021b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021b5:	01 45 f4             	add    %eax,-0xc(%ebp)
801021b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021bb:	01 45 10             	add    %eax,0x10(%ebp)
801021be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021c1:	01 45 0c             	add    %eax,0xc(%ebp)
801021c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021c7:	3b 45 14             	cmp    0x14(%ebp),%eax
801021ca:	0f 82 5e ff ff ff    	jb     8010212e <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801021d0:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021d3:	83 c4 24             	add    $0x24,%esp
801021d6:	5b                   	pop    %ebx
801021d7:	5d                   	pop    %ebp
801021d8:	c3                   	ret    

801021d9 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021d9:	55                   	push   %ebp
801021da:	89 e5                	mov    %esp,%ebp
801021dc:	53                   	push   %ebx
801021dd:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021e0:	8b 45 08             	mov    0x8(%ebp),%eax
801021e3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021e7:	66 83 f8 03          	cmp    $0x3,%ax
801021eb:	75 60                	jne    8010224d <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801021ed:	8b 45 08             	mov    0x8(%ebp),%eax
801021f0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021f4:	66 85 c0             	test   %ax,%ax
801021f7:	78 20                	js     80102219 <writei+0x40>
801021f9:	8b 45 08             	mov    0x8(%ebp),%eax
801021fc:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102200:	66 83 f8 09          	cmp    $0x9,%ax
80102204:	7f 13                	jg     80102219 <writei+0x40>
80102206:	8b 45 08             	mov    0x8(%ebp),%eax
80102209:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010220d:	98                   	cwtl   
8010220e:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
80102215:	85 c0                	test   %eax,%eax
80102217:	75 0a                	jne    80102223 <writei+0x4a>
      return -1;
80102219:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010221e:	e9 46 01 00 00       	jmp    80102369 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80102223:	8b 45 08             	mov    0x8(%ebp),%eax
80102226:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010222a:	98                   	cwtl   
8010222b:	8b 14 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%edx
80102232:	8b 45 14             	mov    0x14(%ebp),%eax
80102235:	89 44 24 08          	mov    %eax,0x8(%esp)
80102239:	8b 45 0c             	mov    0xc(%ebp),%eax
8010223c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102240:	8b 45 08             	mov    0x8(%ebp),%eax
80102243:	89 04 24             	mov    %eax,(%esp)
80102246:	ff d2                	call   *%edx
80102248:	e9 1c 01 00 00       	jmp    80102369 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
8010224d:	8b 45 08             	mov    0x8(%ebp),%eax
80102250:	8b 40 18             	mov    0x18(%eax),%eax
80102253:	3b 45 10             	cmp    0x10(%ebp),%eax
80102256:	72 0d                	jb     80102265 <writei+0x8c>
80102258:	8b 45 14             	mov    0x14(%ebp),%eax
8010225b:	8b 55 10             	mov    0x10(%ebp),%edx
8010225e:	01 d0                	add    %edx,%eax
80102260:	3b 45 10             	cmp    0x10(%ebp),%eax
80102263:	73 0a                	jae    8010226f <writei+0x96>
    return -1;
80102265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010226a:	e9 fa 00 00 00       	jmp    80102369 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
8010226f:	8b 45 14             	mov    0x14(%ebp),%eax
80102272:	8b 55 10             	mov    0x10(%ebp),%edx
80102275:	01 d0                	add    %edx,%eax
80102277:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010227c:	76 0a                	jbe    80102288 <writei+0xaf>
    return -1;
8010227e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102283:	e9 e1 00 00 00       	jmp    80102369 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102288:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010228f:	e9 a1 00 00 00       	jmp    80102335 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102294:	8b 45 10             	mov    0x10(%ebp),%eax
80102297:	c1 e8 09             	shr    $0x9,%eax
8010229a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010229e:	8b 45 08             	mov    0x8(%ebp),%eax
801022a1:	89 04 24             	mov    %eax,(%esp)
801022a4:	e8 71 fb ff ff       	call   80101e1a <bmap>
801022a9:	8b 55 08             	mov    0x8(%ebp),%edx
801022ac:	8b 12                	mov    (%edx),%edx
801022ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801022b2:	89 14 24             	mov    %edx,(%esp)
801022b5:	e8 ec de ff ff       	call   801001a6 <bread>
801022ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022bd:	8b 45 10             	mov    0x10(%ebp),%eax
801022c0:	89 c2                	mov    %eax,%edx
801022c2:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801022c8:	b8 00 02 00 00       	mov    $0x200,%eax
801022cd:	89 c1                	mov    %eax,%ecx
801022cf:	29 d1                	sub    %edx,%ecx
801022d1:	89 ca                	mov    %ecx,%edx
801022d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d6:	8b 4d 14             	mov    0x14(%ebp),%ecx
801022d9:	89 cb                	mov    %ecx,%ebx
801022db:	29 c3                	sub    %eax,%ebx
801022dd:	89 d8                	mov    %ebx,%eax
801022df:	39 c2                	cmp    %eax,%edx
801022e1:	0f 46 c2             	cmovbe %edx,%eax
801022e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022ea:	8d 50 18             	lea    0x18(%eax),%edx
801022ed:	8b 45 10             	mov    0x10(%ebp),%eax
801022f0:	25 ff 01 00 00       	and    $0x1ff,%eax
801022f5:	01 c2                	add    %eax,%edx
801022f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022fa:	89 44 24 08          	mov    %eax,0x8(%esp)
801022fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80102301:	89 44 24 04          	mov    %eax,0x4(%esp)
80102305:	89 14 24             	mov    %edx,(%esp)
80102308:	e8 bc 31 00 00       	call   801054c9 <memmove>
    log_write(bp);
8010230d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102310:	89 04 24             	mov    %eax,(%esp)
80102313:	e8 b6 12 00 00       	call   801035ce <log_write>
    brelse(bp);
80102318:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010231b:	89 04 24             	mov    %eax,(%esp)
8010231e:	e8 f4 de ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102323:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102326:	01 45 f4             	add    %eax,-0xc(%ebp)
80102329:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010232c:	01 45 10             	add    %eax,0x10(%ebp)
8010232f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102332:	01 45 0c             	add    %eax,0xc(%ebp)
80102335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102338:	3b 45 14             	cmp    0x14(%ebp),%eax
8010233b:	0f 82 53 ff ff ff    	jb     80102294 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102341:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102345:	74 1f                	je     80102366 <writei+0x18d>
80102347:	8b 45 08             	mov    0x8(%ebp),%eax
8010234a:	8b 40 18             	mov    0x18(%eax),%eax
8010234d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102350:	73 14                	jae    80102366 <writei+0x18d>
    ip->size = off;
80102352:	8b 45 08             	mov    0x8(%ebp),%eax
80102355:	8b 55 10             	mov    0x10(%ebp),%edx
80102358:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010235b:	8b 45 08             	mov    0x8(%ebp),%eax
8010235e:	89 04 24             	mov    %eax,(%esp)
80102361:	e8 56 f6 ff ff       	call   801019bc <iupdate>
  }
  return n;
80102366:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102369:	83 c4 24             	add    $0x24,%esp
8010236c:	5b                   	pop    %ebx
8010236d:	5d                   	pop    %ebp
8010236e:	c3                   	ret    

8010236f <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010236f:	55                   	push   %ebp
80102370:	89 e5                	mov    %esp,%ebp
80102372:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102375:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010237c:	00 
8010237d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102380:	89 44 24 04          	mov    %eax,0x4(%esp)
80102384:	8b 45 08             	mov    0x8(%ebp),%eax
80102387:	89 04 24             	mov    %eax,(%esp)
8010238a:	e8 de 31 00 00       	call   8010556d <strncmp>
}
8010238f:	c9                   	leave  
80102390:	c3                   	ret    

80102391 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102391:	55                   	push   %ebp
80102392:	89 e5                	mov    %esp,%ebp
80102394:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102397:	8b 45 08             	mov    0x8(%ebp),%eax
8010239a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010239e:	66 83 f8 01          	cmp    $0x1,%ax
801023a2:	74 0c                	je     801023b0 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801023a4:	c7 04 24 75 89 10 80 	movl   $0x80108975,(%esp)
801023ab:	e8 8d e1 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801023b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023b7:	e9 87 00 00 00       	jmp    80102443 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023bc:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801023c3:	00 
801023c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c7:	89 44 24 08          	mov    %eax,0x8(%esp)
801023cb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801023d2:	8b 45 08             	mov    0x8(%ebp),%eax
801023d5:	89 04 24             	mov    %eax,(%esp)
801023d8:	e8 91 fc ff ff       	call   8010206e <readi>
801023dd:	83 f8 10             	cmp    $0x10,%eax
801023e0:	74 0c                	je     801023ee <dirlookup+0x5d>
      panic("dirlink read");
801023e2:	c7 04 24 87 89 10 80 	movl   $0x80108987,(%esp)
801023e9:	e8 4f e1 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801023ee:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023f2:	66 85 c0             	test   %ax,%ax
801023f5:	74 47                	je     8010243e <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
801023f7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023fa:	83 c0 02             	add    $0x2,%eax
801023fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102401:	8b 45 0c             	mov    0xc(%ebp),%eax
80102404:	89 04 24             	mov    %eax,(%esp)
80102407:	e8 63 ff ff ff       	call   8010236f <namecmp>
8010240c:	85 c0                	test   %eax,%eax
8010240e:	75 2f                	jne    8010243f <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102410:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102414:	74 08                	je     8010241e <dirlookup+0x8d>
        *poff = off;
80102416:	8b 45 10             	mov    0x10(%ebp),%eax
80102419:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010241c:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010241e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102422:	0f b7 c0             	movzwl %ax,%eax
80102425:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102428:	8b 45 08             	mov    0x8(%ebp),%eax
8010242b:	8b 00                	mov    (%eax),%eax
8010242d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102430:	89 54 24 04          	mov    %edx,0x4(%esp)
80102434:	89 04 24             	mov    %eax,(%esp)
80102437:	e8 38 f6 ff ff       	call   80101a74 <iget>
8010243c:	eb 19                	jmp    80102457 <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010243e:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010243f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102443:	8b 45 08             	mov    0x8(%ebp),%eax
80102446:	8b 40 18             	mov    0x18(%eax),%eax
80102449:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010244c:	0f 87 6a ff ff ff    	ja     801023bc <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102452:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102457:	c9                   	leave  
80102458:	c3                   	ret    

80102459 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102459:	55                   	push   %ebp
8010245a:	89 e5                	mov    %esp,%ebp
8010245c:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010245f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102466:	00 
80102467:	8b 45 0c             	mov    0xc(%ebp),%eax
8010246a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010246e:	8b 45 08             	mov    0x8(%ebp),%eax
80102471:	89 04 24             	mov    %eax,(%esp)
80102474:	e8 18 ff ff ff       	call   80102391 <dirlookup>
80102479:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010247c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102480:	74 15                	je     80102497 <dirlink+0x3e>
    iput(ip);
80102482:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102485:	89 04 24             	mov    %eax,(%esp)
80102488:	e8 9e f8 ff ff       	call   80101d2b <iput>
    return -1;
8010248d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102492:	e9 b8 00 00 00       	jmp    8010254f <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102497:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010249e:	eb 44                	jmp    801024e4 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a3:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801024aa:	00 
801024ab:	89 44 24 08          	mov    %eax,0x8(%esp)
801024af:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801024b6:	8b 45 08             	mov    0x8(%ebp),%eax
801024b9:	89 04 24             	mov    %eax,(%esp)
801024bc:	e8 ad fb ff ff       	call   8010206e <readi>
801024c1:	83 f8 10             	cmp    $0x10,%eax
801024c4:	74 0c                	je     801024d2 <dirlink+0x79>
      panic("dirlink read");
801024c6:	c7 04 24 87 89 10 80 	movl   $0x80108987,(%esp)
801024cd:	e8 6b e0 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801024d2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801024d6:	66 85 c0             	test   %ax,%ax
801024d9:	74 18                	je     801024f3 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024de:	83 c0 10             	add    $0x10,%eax
801024e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801024e7:	8b 45 08             	mov    0x8(%ebp),%eax
801024ea:	8b 40 18             	mov    0x18(%eax),%eax
801024ed:	39 c2                	cmp    %eax,%edx
801024ef:	72 af                	jb     801024a0 <dirlink+0x47>
801024f1:	eb 01                	jmp    801024f4 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801024f3:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801024f4:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801024fb:	00 
801024fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801024ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80102503:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102506:	83 c0 02             	add    $0x2,%eax
80102509:	89 04 24             	mov    %eax,(%esp)
8010250c:	e8 b4 30 00 00       	call   801055c5 <strncpy>
  de.inum = inum;
80102511:	8b 45 10             	mov    0x10(%ebp),%eax
80102514:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010251b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102522:	00 
80102523:	89 44 24 08          	mov    %eax,0x8(%esp)
80102527:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010252a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010252e:	8b 45 08             	mov    0x8(%ebp),%eax
80102531:	89 04 24             	mov    %eax,(%esp)
80102534:	e8 a0 fc ff ff       	call   801021d9 <writei>
80102539:	83 f8 10             	cmp    $0x10,%eax
8010253c:	74 0c                	je     8010254a <dirlink+0xf1>
    panic("dirlink");
8010253e:	c7 04 24 94 89 10 80 	movl   $0x80108994,(%esp)
80102545:	e8 f3 df ff ff       	call   8010053d <panic>
  
  return 0;
8010254a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010254f:	c9                   	leave  
80102550:	c3                   	ret    

80102551 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102551:	55                   	push   %ebp
80102552:	89 e5                	mov    %esp,%ebp
80102554:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102557:	eb 04                	jmp    8010255d <skipelem+0xc>
    path++;
80102559:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010255d:	8b 45 08             	mov    0x8(%ebp),%eax
80102560:	0f b6 00             	movzbl (%eax),%eax
80102563:	3c 2f                	cmp    $0x2f,%al
80102565:	74 f2                	je     80102559 <skipelem+0x8>
    path++;
  if(*path == 0)
80102567:	8b 45 08             	mov    0x8(%ebp),%eax
8010256a:	0f b6 00             	movzbl (%eax),%eax
8010256d:	84 c0                	test   %al,%al
8010256f:	75 0a                	jne    8010257b <skipelem+0x2a>
    return 0;
80102571:	b8 00 00 00 00       	mov    $0x0,%eax
80102576:	e9 86 00 00 00       	jmp    80102601 <skipelem+0xb0>
  s = path;
8010257b:	8b 45 08             	mov    0x8(%ebp),%eax
8010257e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102581:	eb 04                	jmp    80102587 <skipelem+0x36>
    path++;
80102583:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102587:	8b 45 08             	mov    0x8(%ebp),%eax
8010258a:	0f b6 00             	movzbl (%eax),%eax
8010258d:	3c 2f                	cmp    $0x2f,%al
8010258f:	74 0a                	je     8010259b <skipelem+0x4a>
80102591:	8b 45 08             	mov    0x8(%ebp),%eax
80102594:	0f b6 00             	movzbl (%eax),%eax
80102597:	84 c0                	test   %al,%al
80102599:	75 e8                	jne    80102583 <skipelem+0x32>
    path++;
  len = path - s;
8010259b:	8b 55 08             	mov    0x8(%ebp),%edx
8010259e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025a1:	89 d1                	mov    %edx,%ecx
801025a3:	29 c1                	sub    %eax,%ecx
801025a5:	89 c8                	mov    %ecx,%eax
801025a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801025aa:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801025ae:	7e 1c                	jle    801025cc <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801025b0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801025b7:	00 
801025b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801025bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801025c2:	89 04 24             	mov    %eax,(%esp)
801025c5:	e8 ff 2e 00 00       	call   801054c9 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801025ca:	eb 28                	jmp    801025f4 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801025cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025cf:	89 44 24 08          	mov    %eax,0x8(%esp)
801025d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801025da:	8b 45 0c             	mov    0xc(%ebp),%eax
801025dd:	89 04 24             	mov    %eax,(%esp)
801025e0:	e8 e4 2e 00 00       	call   801054c9 <memmove>
    name[len] = 0;
801025e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025e8:	03 45 0c             	add    0xc(%ebp),%eax
801025eb:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801025ee:	eb 04                	jmp    801025f4 <skipelem+0xa3>
    path++;
801025f0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801025f4:	8b 45 08             	mov    0x8(%ebp),%eax
801025f7:	0f b6 00             	movzbl (%eax),%eax
801025fa:	3c 2f                	cmp    $0x2f,%al
801025fc:	74 f2                	je     801025f0 <skipelem+0x9f>
    path++;
  return path;
801025fe:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102601:	c9                   	leave  
80102602:	c3                   	ret    

80102603 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102603:	55                   	push   %ebp
80102604:	89 e5                	mov    %esp,%ebp
80102606:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102609:	8b 45 08             	mov    0x8(%ebp),%eax
8010260c:	0f b6 00             	movzbl (%eax),%eax
8010260f:	3c 2f                	cmp    $0x2f,%al
80102611:	75 1c                	jne    8010262f <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102613:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010261a:	00 
8010261b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102622:	e8 4d f4 ff ff       	call   80101a74 <iget>
80102627:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010262a:	e9 af 00 00 00       	jmp    801026de <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010262f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102635:	8b 40 68             	mov    0x68(%eax),%eax
80102638:	89 04 24             	mov    %eax,(%esp)
8010263b:	e8 06 f5 ff ff       	call   80101b46 <idup>
80102640:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102643:	e9 96 00 00 00       	jmp    801026de <namex+0xdb>
    ilock(ip);
80102648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010264b:	89 04 24             	mov    %eax,(%esp)
8010264e:	e8 25 f5 ff ff       	call   80101b78 <ilock>
    if(ip->type != T_DIR){
80102653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102656:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010265a:	66 83 f8 01          	cmp    $0x1,%ax
8010265e:	74 15                	je     80102675 <namex+0x72>
      iunlockput(ip);
80102660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102663:	89 04 24             	mov    %eax,(%esp)
80102666:	e8 91 f7 ff ff       	call   80101dfc <iunlockput>
      return 0;
8010266b:	b8 00 00 00 00       	mov    $0x0,%eax
80102670:	e9 a3 00 00 00       	jmp    80102718 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102675:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102679:	74 1d                	je     80102698 <namex+0x95>
8010267b:	8b 45 08             	mov    0x8(%ebp),%eax
8010267e:	0f b6 00             	movzbl (%eax),%eax
80102681:	84 c0                	test   %al,%al
80102683:	75 13                	jne    80102698 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102685:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102688:	89 04 24             	mov    %eax,(%esp)
8010268b:	e8 36 f6 ff ff       	call   80101cc6 <iunlock>
      return ip;
80102690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102693:	e9 80 00 00 00       	jmp    80102718 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102698:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010269f:	00 
801026a0:	8b 45 10             	mov    0x10(%ebp),%eax
801026a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801026a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026aa:	89 04 24             	mov    %eax,(%esp)
801026ad:	e8 df fc ff ff       	call   80102391 <dirlookup>
801026b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801026b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801026b9:	75 12                	jne    801026cd <namex+0xca>
      iunlockput(ip);
801026bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026be:	89 04 24             	mov    %eax,(%esp)
801026c1:	e8 36 f7 ff ff       	call   80101dfc <iunlockput>
      return 0;
801026c6:	b8 00 00 00 00       	mov    $0x0,%eax
801026cb:	eb 4b                	jmp    80102718 <namex+0x115>
    }
    iunlockput(ip);
801026cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d0:	89 04 24             	mov    %eax,(%esp)
801026d3:	e8 24 f7 ff ff       	call   80101dfc <iunlockput>
    ip = next;
801026d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801026de:	8b 45 10             	mov    0x10(%ebp),%eax
801026e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801026e5:	8b 45 08             	mov    0x8(%ebp),%eax
801026e8:	89 04 24             	mov    %eax,(%esp)
801026eb:	e8 61 fe ff ff       	call   80102551 <skipelem>
801026f0:	89 45 08             	mov    %eax,0x8(%ebp)
801026f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026f7:	0f 85 4b ff ff ff    	jne    80102648 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801026fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102701:	74 12                	je     80102715 <namex+0x112>
    iput(ip);
80102703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102706:	89 04 24             	mov    %eax,(%esp)
80102709:	e8 1d f6 ff ff       	call   80101d2b <iput>
    return 0;
8010270e:	b8 00 00 00 00       	mov    $0x0,%eax
80102713:	eb 03                	jmp    80102718 <namex+0x115>
  }
  return ip;
80102715:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102718:	c9                   	leave  
80102719:	c3                   	ret    

8010271a <namei>:

struct inode*
namei(char *path)
{
8010271a:	55                   	push   %ebp
8010271b:	89 e5                	mov    %esp,%ebp
8010271d:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102720:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102723:	89 44 24 08          	mov    %eax,0x8(%esp)
80102727:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010272e:	00 
8010272f:	8b 45 08             	mov    0x8(%ebp),%eax
80102732:	89 04 24             	mov    %eax,(%esp)
80102735:	e8 c9 fe ff ff       	call   80102603 <namex>
}
8010273a:	c9                   	leave  
8010273b:	c3                   	ret    

8010273c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010273c:	55                   	push   %ebp
8010273d:	89 e5                	mov    %esp,%ebp
8010273f:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102742:	8b 45 0c             	mov    0xc(%ebp),%eax
80102745:	89 44 24 08          	mov    %eax,0x8(%esp)
80102749:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102750:	00 
80102751:	8b 45 08             	mov    0x8(%ebp),%eax
80102754:	89 04 24             	mov    %eax,(%esp)
80102757:	e8 a7 fe ff ff       	call   80102603 <namex>
}
8010275c:	c9                   	leave  
8010275d:	c3                   	ret    
	...

80102760 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102760:	55                   	push   %ebp
80102761:	89 e5                	mov    %esp,%ebp
80102763:	53                   	push   %ebx
80102764:	83 ec 14             	sub    $0x14,%esp
80102767:	8b 45 08             	mov    0x8(%ebp),%eax
8010276a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010276e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102772:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102776:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010277a:	ec                   	in     (%dx),%al
8010277b:	89 c3                	mov    %eax,%ebx
8010277d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102780:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102784:	83 c4 14             	add    $0x14,%esp
80102787:	5b                   	pop    %ebx
80102788:	5d                   	pop    %ebp
80102789:	c3                   	ret    

8010278a <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010278a:	55                   	push   %ebp
8010278b:	89 e5                	mov    %esp,%ebp
8010278d:	57                   	push   %edi
8010278e:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010278f:	8b 55 08             	mov    0x8(%ebp),%edx
80102792:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102795:	8b 45 10             	mov    0x10(%ebp),%eax
80102798:	89 cb                	mov    %ecx,%ebx
8010279a:	89 df                	mov    %ebx,%edi
8010279c:	89 c1                	mov    %eax,%ecx
8010279e:	fc                   	cld    
8010279f:	f3 6d                	rep insl (%dx),%es:(%edi)
801027a1:	89 c8                	mov    %ecx,%eax
801027a3:	89 fb                	mov    %edi,%ebx
801027a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027a8:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801027ab:	5b                   	pop    %ebx
801027ac:	5f                   	pop    %edi
801027ad:	5d                   	pop    %ebp
801027ae:	c3                   	ret    

801027af <outb>:

static inline void
outb(ushort port, uchar data)
{
801027af:	55                   	push   %ebp
801027b0:	89 e5                	mov    %esp,%ebp
801027b2:	83 ec 08             	sub    $0x8,%esp
801027b5:	8b 55 08             	mov    0x8(%ebp),%edx
801027b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801027bb:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801027bf:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801027c2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801027c6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801027ca:	ee                   	out    %al,(%dx)
}
801027cb:	c9                   	leave  
801027cc:	c3                   	ret    

801027cd <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801027cd:	55                   	push   %ebp
801027ce:	89 e5                	mov    %esp,%ebp
801027d0:	56                   	push   %esi
801027d1:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801027d2:	8b 55 08             	mov    0x8(%ebp),%edx
801027d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027d8:	8b 45 10             	mov    0x10(%ebp),%eax
801027db:	89 cb                	mov    %ecx,%ebx
801027dd:	89 de                	mov    %ebx,%esi
801027df:	89 c1                	mov    %eax,%ecx
801027e1:	fc                   	cld    
801027e2:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801027e4:	89 c8                	mov    %ecx,%eax
801027e6:	89 f3                	mov    %esi,%ebx
801027e8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027eb:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801027ee:	5b                   	pop    %ebx
801027ef:	5e                   	pop    %esi
801027f0:	5d                   	pop    %ebp
801027f1:	c3                   	ret    

801027f2 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801027f2:	55                   	push   %ebp
801027f3:	89 e5                	mov    %esp,%ebp
801027f5:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801027f8:	90                   	nop
801027f9:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102800:	e8 5b ff ff ff       	call   80102760 <inb>
80102805:	0f b6 c0             	movzbl %al,%eax
80102808:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010280b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010280e:	25 c0 00 00 00       	and    $0xc0,%eax
80102813:	83 f8 40             	cmp    $0x40,%eax
80102816:	75 e1                	jne    801027f9 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102818:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010281c:	74 11                	je     8010282f <idewait+0x3d>
8010281e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102821:	83 e0 21             	and    $0x21,%eax
80102824:	85 c0                	test   %eax,%eax
80102826:	74 07                	je     8010282f <idewait+0x3d>
    return -1;
80102828:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010282d:	eb 05                	jmp    80102834 <idewait+0x42>
  return 0;
8010282f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102834:	c9                   	leave  
80102835:	c3                   	ret    

80102836 <ideinit>:

void
ideinit(void)
{
80102836:	55                   	push   %ebp
80102837:	89 e5                	mov    %esp,%ebp
80102839:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010283c:	c7 44 24 04 9c 89 10 	movl   $0x8010899c,0x4(%esp)
80102843:	80 
80102844:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010284b:	e8 36 29 00 00       	call   80105186 <initlock>
  picenable(IRQ_IDE);
80102850:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102857:	e8 75 15 00 00       	call   80103dd1 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
8010285c:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80102861:	83 e8 01             	sub    $0x1,%eax
80102864:	89 44 24 04          	mov    %eax,0x4(%esp)
80102868:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010286f:	e8 12 04 00 00       	call   80102c86 <ioapicenable>
  idewait(0);
80102874:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010287b:	e8 72 ff ff ff       	call   801027f2 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102880:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102887:	00 
80102888:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010288f:	e8 1b ff ff ff       	call   801027af <outb>
  for(i=0; i<1000; i++){
80102894:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010289b:	eb 20                	jmp    801028bd <ideinit+0x87>
    if(inb(0x1f7) != 0){
8010289d:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028a4:	e8 b7 fe ff ff       	call   80102760 <inb>
801028a9:	84 c0                	test   %al,%al
801028ab:	74 0c                	je     801028b9 <ideinit+0x83>
      havedisk1 = 1;
801028ad:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801028b4:	00 00 00 
      break;
801028b7:	eb 0d                	jmp    801028c6 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801028b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801028bd:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801028c4:	7e d7                	jle    8010289d <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801028c6:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801028cd:	00 
801028ce:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028d5:	e8 d5 fe ff ff       	call   801027af <outb>
}
801028da:	c9                   	leave  
801028db:	c3                   	ret    

801028dc <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801028dc:	55                   	push   %ebp
801028dd:	89 e5                	mov    %esp,%ebp
801028df:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801028e2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028e6:	75 0c                	jne    801028f4 <idestart+0x18>
    panic("idestart");
801028e8:	c7 04 24 a0 89 10 80 	movl   $0x801089a0,(%esp)
801028ef:	e8 49 dc ff ff       	call   8010053d <panic>

  idewait(0);
801028f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028fb:	e8 f2 fe ff ff       	call   801027f2 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102900:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102907:	00 
80102908:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010290f:	e8 9b fe ff ff       	call   801027af <outb>
  outb(0x1f2, 1);  // number of sectors
80102914:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010291b:	00 
8010291c:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102923:	e8 87 fe ff ff       	call   801027af <outb>
  outb(0x1f3, b->sector & 0xff);
80102928:	8b 45 08             	mov    0x8(%ebp),%eax
8010292b:	8b 40 08             	mov    0x8(%eax),%eax
8010292e:	0f b6 c0             	movzbl %al,%eax
80102931:	89 44 24 04          	mov    %eax,0x4(%esp)
80102935:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
8010293c:	e8 6e fe ff ff       	call   801027af <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102941:	8b 45 08             	mov    0x8(%ebp),%eax
80102944:	8b 40 08             	mov    0x8(%eax),%eax
80102947:	c1 e8 08             	shr    $0x8,%eax
8010294a:	0f b6 c0             	movzbl %al,%eax
8010294d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102951:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102958:	e8 52 fe ff ff       	call   801027af <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
8010295d:	8b 45 08             	mov    0x8(%ebp),%eax
80102960:	8b 40 08             	mov    0x8(%eax),%eax
80102963:	c1 e8 10             	shr    $0x10,%eax
80102966:	0f b6 c0             	movzbl %al,%eax
80102969:	89 44 24 04          	mov    %eax,0x4(%esp)
8010296d:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102974:	e8 36 fe ff ff       	call   801027af <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102979:	8b 45 08             	mov    0x8(%ebp),%eax
8010297c:	8b 40 04             	mov    0x4(%eax),%eax
8010297f:	83 e0 01             	and    $0x1,%eax
80102982:	89 c2                	mov    %eax,%edx
80102984:	c1 e2 04             	shl    $0x4,%edx
80102987:	8b 45 08             	mov    0x8(%ebp),%eax
8010298a:	8b 40 08             	mov    0x8(%eax),%eax
8010298d:	c1 e8 18             	shr    $0x18,%eax
80102990:	83 e0 0f             	and    $0xf,%eax
80102993:	09 d0                	or     %edx,%eax
80102995:	83 c8 e0             	or     $0xffffffe0,%eax
80102998:	0f b6 c0             	movzbl %al,%eax
8010299b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010299f:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801029a6:	e8 04 fe ff ff       	call   801027af <outb>
  if(b->flags & B_DIRTY){
801029ab:	8b 45 08             	mov    0x8(%ebp),%eax
801029ae:	8b 00                	mov    (%eax),%eax
801029b0:	83 e0 04             	and    $0x4,%eax
801029b3:	85 c0                	test   %eax,%eax
801029b5:	74 34                	je     801029eb <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801029b7:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801029be:	00 
801029bf:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801029c6:	e8 e4 fd ff ff       	call   801027af <outb>
    outsl(0x1f0, b->data, 512/4);
801029cb:	8b 45 08             	mov    0x8(%ebp),%eax
801029ce:	83 c0 18             	add    $0x18,%eax
801029d1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801029d8:	00 
801029d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801029dd:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801029e4:	e8 e4 fd ff ff       	call   801027cd <outsl>
801029e9:	eb 14                	jmp    801029ff <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801029eb:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801029f2:	00 
801029f3:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801029fa:	e8 b0 fd ff ff       	call   801027af <outb>
  }
}
801029ff:	c9                   	leave  
80102a00:	c3                   	ret    

80102a01 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a01:	55                   	push   %ebp
80102a02:	89 e5                	mov    %esp,%ebp
80102a04:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a07:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a0e:	e8 94 27 00 00       	call   801051a7 <acquire>
  if((b = idequeue) == 0){
80102a13:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a18:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a1f:	75 11                	jne    80102a32 <ideintr+0x31>
    release(&idelock);
80102a21:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a28:	e8 dc 27 00 00       	call   80105209 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102a2d:	e9 90 00 00 00       	jmp    80102ac2 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a35:	8b 40 14             	mov    0x14(%eax),%eax
80102a38:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a40:	8b 00                	mov    (%eax),%eax
80102a42:	83 e0 04             	and    $0x4,%eax
80102a45:	85 c0                	test   %eax,%eax
80102a47:	75 2e                	jne    80102a77 <ideintr+0x76>
80102a49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a50:	e8 9d fd ff ff       	call   801027f2 <idewait>
80102a55:	85 c0                	test   %eax,%eax
80102a57:	78 1e                	js     80102a77 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5c:	83 c0 18             	add    $0x18,%eax
80102a5f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a66:	00 
80102a67:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a6b:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a72:	e8 13 fd ff ff       	call   8010278a <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7a:	8b 00                	mov    (%eax),%eax
80102a7c:	89 c2                	mov    %eax,%edx
80102a7e:	83 ca 02             	or     $0x2,%edx
80102a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a84:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a89:	8b 00                	mov    (%eax),%eax
80102a8b:	89 c2                	mov    %eax,%edx
80102a8d:	83 e2 fb             	and    $0xfffffffb,%edx
80102a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a93:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a98:	89 04 24             	mov    %eax,(%esp)
80102a9b:	e8 7a 24 00 00       	call   80104f1a <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102aa0:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102aa5:	85 c0                	test   %eax,%eax
80102aa7:	74 0d                	je     80102ab6 <ideintr+0xb5>
    idestart(idequeue);
80102aa9:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102aae:	89 04 24             	mov    %eax,(%esp)
80102ab1:	e8 26 fe ff ff       	call   801028dc <idestart>

  release(&idelock);
80102ab6:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102abd:	e8 47 27 00 00       	call   80105209 <release>
}
80102ac2:	c9                   	leave  
80102ac3:	c3                   	ret    

80102ac4 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102ac4:	55                   	push   %ebp
80102ac5:	89 e5                	mov    %esp,%ebp
80102ac7:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102aca:	8b 45 08             	mov    0x8(%ebp),%eax
80102acd:	8b 00                	mov    (%eax),%eax
80102acf:	83 e0 01             	and    $0x1,%eax
80102ad2:	85 c0                	test   %eax,%eax
80102ad4:	75 0c                	jne    80102ae2 <iderw+0x1e>
    panic("iderw: buf not busy");
80102ad6:	c7 04 24 a9 89 10 80 	movl   $0x801089a9,(%esp)
80102add:	e8 5b da ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102ae2:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae5:	8b 00                	mov    (%eax),%eax
80102ae7:	83 e0 06             	and    $0x6,%eax
80102aea:	83 f8 02             	cmp    $0x2,%eax
80102aed:	75 0c                	jne    80102afb <iderw+0x37>
    panic("iderw: nothing to do");
80102aef:	c7 04 24 bd 89 10 80 	movl   $0x801089bd,(%esp)
80102af6:	e8 42 da ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102afb:	8b 45 08             	mov    0x8(%ebp),%eax
80102afe:	8b 40 04             	mov    0x4(%eax),%eax
80102b01:	85 c0                	test   %eax,%eax
80102b03:	74 15                	je     80102b1a <iderw+0x56>
80102b05:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102b0a:	85 c0                	test   %eax,%eax
80102b0c:	75 0c                	jne    80102b1a <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102b0e:	c7 04 24 d2 89 10 80 	movl   $0x801089d2,(%esp)
80102b15:	e8 23 da ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102b1a:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b21:	e8 81 26 00 00       	call   801051a7 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b26:	8b 45 08             	mov    0x8(%ebp),%eax
80102b29:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102b30:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102b37:	eb 0b                	jmp    80102b44 <iderw+0x80>
80102b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3c:	8b 00                	mov    (%eax),%eax
80102b3e:	83 c0 14             	add    $0x14,%eax
80102b41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b47:	8b 00                	mov    (%eax),%eax
80102b49:	85 c0                	test   %eax,%eax
80102b4b:	75 ec                	jne    80102b39 <iderw+0x75>
    ;
  *pp = b;
80102b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b50:	8b 55 08             	mov    0x8(%ebp),%edx
80102b53:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102b55:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102b5a:	3b 45 08             	cmp    0x8(%ebp),%eax
80102b5d:	75 22                	jne    80102b81 <iderw+0xbd>
    idestart(b);
80102b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b62:	89 04 24             	mov    %eax,(%esp)
80102b65:	e8 72 fd ff ff       	call   801028dc <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b6a:	eb 15                	jmp    80102b81 <iderw+0xbd>
    sleep(b, &idelock);
80102b6c:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102b73:	80 
80102b74:	8b 45 08             	mov    0x8(%ebp),%eax
80102b77:	89 04 24             	mov    %eax,(%esp)
80102b7a:	e8 bf 22 00 00       	call   80104e3e <sleep>
80102b7f:	eb 01                	jmp    80102b82 <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b81:	90                   	nop
80102b82:	8b 45 08             	mov    0x8(%ebp),%eax
80102b85:	8b 00                	mov    (%eax),%eax
80102b87:	83 e0 06             	and    $0x6,%eax
80102b8a:	83 f8 02             	cmp    $0x2,%eax
80102b8d:	75 dd                	jne    80102b6c <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102b8f:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b96:	e8 6e 26 00 00       	call   80105209 <release>
}
80102b9b:	c9                   	leave  
80102b9c:	c3                   	ret    
80102b9d:	00 00                	add    %al,(%eax)
	...

80102ba0 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102ba0:	55                   	push   %ebp
80102ba1:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102ba3:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102ba8:	8b 55 08             	mov    0x8(%ebp),%edx
80102bab:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bad:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bb2:	8b 40 10             	mov    0x10(%eax),%eax
}
80102bb5:	5d                   	pop    %ebp
80102bb6:	c3                   	ret    

80102bb7 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bb7:	55                   	push   %ebp
80102bb8:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bba:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bbf:	8b 55 08             	mov    0x8(%ebp),%edx
80102bc2:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102bc4:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bc9:	8b 55 0c             	mov    0xc(%ebp),%edx
80102bcc:	89 50 10             	mov    %edx,0x10(%eax)
}
80102bcf:	5d                   	pop    %ebp
80102bd0:	c3                   	ret    

80102bd1 <ioapicinit>:

void
ioapicinit(void)
{
80102bd1:	55                   	push   %ebp
80102bd2:	89 e5                	mov    %esp,%ebp
80102bd4:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102bd7:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102bdc:	85 c0                	test   %eax,%eax
80102bde:	0f 84 9f 00 00 00    	je     80102c83 <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102be4:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
80102beb:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102bee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102bf5:	e8 a6 ff ff ff       	call   80102ba0 <ioapicread>
80102bfa:	c1 e8 10             	shr    $0x10,%eax
80102bfd:	25 ff 00 00 00       	and    $0xff,%eax
80102c02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c0c:	e8 8f ff ff ff       	call   80102ba0 <ioapicread>
80102c11:	c1 e8 18             	shr    $0x18,%eax
80102c14:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c17:	0f b6 05 20 f9 10 80 	movzbl 0x8010f920,%eax
80102c1e:	0f b6 c0             	movzbl %al,%eax
80102c21:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c24:	74 0c                	je     80102c32 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c26:	c7 04 24 f0 89 10 80 	movl   $0x801089f0,(%esp)
80102c2d:	e8 6f d7 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c39:	eb 3e                	jmp    80102c79 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c3e:	83 c0 20             	add    $0x20,%eax
80102c41:	0d 00 00 01 00       	or     $0x10000,%eax
80102c46:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102c49:	83 c2 08             	add    $0x8,%edx
80102c4c:	01 d2                	add    %edx,%edx
80102c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c52:	89 14 24             	mov    %edx,(%esp)
80102c55:	e8 5d ff ff ff       	call   80102bb7 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c5d:	83 c0 08             	add    $0x8,%eax
80102c60:	01 c0                	add    %eax,%eax
80102c62:	83 c0 01             	add    $0x1,%eax
80102c65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102c6c:	00 
80102c6d:	89 04 24             	mov    %eax,(%esp)
80102c70:	e8 42 ff ff ff       	call   80102bb7 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c75:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c7c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c7f:	7e ba                	jle    80102c3b <ioapicinit+0x6a>
80102c81:	eb 01                	jmp    80102c84 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102c83:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102c84:	c9                   	leave  
80102c85:	c3                   	ret    

80102c86 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c86:	55                   	push   %ebp
80102c87:	89 e5                	mov    %esp,%ebp
80102c89:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102c8c:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102c91:	85 c0                	test   %eax,%eax
80102c93:	74 39                	je     80102cce <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c95:	8b 45 08             	mov    0x8(%ebp),%eax
80102c98:	83 c0 20             	add    $0x20,%eax
80102c9b:	8b 55 08             	mov    0x8(%ebp),%edx
80102c9e:	83 c2 08             	add    $0x8,%edx
80102ca1:	01 d2                	add    %edx,%edx
80102ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ca7:	89 14 24             	mov    %edx,(%esp)
80102caa:	e8 08 ff ff ff       	call   80102bb7 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102caf:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cb2:	c1 e0 18             	shl    $0x18,%eax
80102cb5:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb8:	83 c2 08             	add    $0x8,%edx
80102cbb:	01 d2                	add    %edx,%edx
80102cbd:	83 c2 01             	add    $0x1,%edx
80102cc0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cc4:	89 14 24             	mov    %edx,(%esp)
80102cc7:	e8 eb fe ff ff       	call   80102bb7 <ioapicwrite>
80102ccc:	eb 01                	jmp    80102ccf <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102cce:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102ccf:	c9                   	leave  
80102cd0:	c3                   	ret    
80102cd1:	00 00                	add    %al,(%eax)
	...

80102cd4 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102cd4:	55                   	push   %ebp
80102cd5:	89 e5                	mov    %esp,%ebp
80102cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80102cda:	05 00 00 00 80       	add    $0x80000000,%eax
80102cdf:	5d                   	pop    %ebp
80102ce0:	c3                   	ret    

80102ce1 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102ce1:	55                   	push   %ebp
80102ce2:	89 e5                	mov    %esp,%ebp
80102ce4:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102ce7:	c7 44 24 04 22 8a 10 	movl   $0x80108a22,0x4(%esp)
80102cee:	80 
80102cef:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102cf6:	e8 8b 24 00 00       	call   80105186 <initlock>
  kmem.use_lock = 0;
80102cfb:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
80102d02:	00 00 00 
  freerange(vstart, vend);
80102d05:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d08:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d0f:	89 04 24             	mov    %eax,(%esp)
80102d12:	e8 26 00 00 00       	call   80102d3d <freerange>
}
80102d17:	c9                   	leave  
80102d18:	c3                   	ret    

80102d19 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d19:	55                   	push   %ebp
80102d1a:	89 e5                	mov    %esp,%ebp
80102d1c:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d22:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d26:	8b 45 08             	mov    0x8(%ebp),%eax
80102d29:	89 04 24             	mov    %eax,(%esp)
80102d2c:	e8 0c 00 00 00       	call   80102d3d <freerange>
  kmem.use_lock = 1;
80102d31:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
80102d38:	00 00 00 
}
80102d3b:	c9                   	leave  
80102d3c:	c3                   	ret    

80102d3d <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d3d:	55                   	push   %ebp
80102d3e:	89 e5                	mov    %esp,%ebp
80102d40:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d43:	8b 45 08             	mov    0x8(%ebp),%eax
80102d46:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d53:	eb 12                	jmp    80102d67 <freerange+0x2a>
    kfree(p);
80102d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d58:	89 04 24             	mov    %eax,(%esp)
80102d5b:	e8 16 00 00 00       	call   80102d76 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d60:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d6a:	05 00 10 00 00       	add    $0x1000,%eax
80102d6f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102d72:	76 e1                	jbe    80102d55 <freerange+0x18>
    kfree(p);
}
80102d74:	c9                   	leave  
80102d75:	c3                   	ret    

80102d76 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d76:	55                   	push   %ebp
80102d77:	89 e5                	mov    %esp,%ebp
80102d79:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d7f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d84:	85 c0                	test   %eax,%eax
80102d86:	75 1b                	jne    80102da3 <kfree+0x2d>
80102d88:	81 7d 08 1c 2d 11 80 	cmpl   $0x80112d1c,0x8(%ebp)
80102d8f:	72 12                	jb     80102da3 <kfree+0x2d>
80102d91:	8b 45 08             	mov    0x8(%ebp),%eax
80102d94:	89 04 24             	mov    %eax,(%esp)
80102d97:	e8 38 ff ff ff       	call   80102cd4 <v2p>
80102d9c:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102da1:	76 0c                	jbe    80102daf <kfree+0x39>
    panic("kfree");
80102da3:	c7 04 24 27 8a 10 80 	movl   $0x80108a27,(%esp)
80102daa:	e8 8e d7 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102daf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102db6:	00 
80102db7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102dbe:	00 
80102dbf:	8b 45 08             	mov    0x8(%ebp),%eax
80102dc2:	89 04 24             	mov    %eax,(%esp)
80102dc5:	e8 2c 26 00 00       	call   801053f6 <memset>

  if(kmem.use_lock)
80102dca:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102dcf:	85 c0                	test   %eax,%eax
80102dd1:	74 0c                	je     80102ddf <kfree+0x69>
    acquire(&kmem.lock);
80102dd3:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102dda:	e8 c8 23 00 00       	call   801051a7 <acquire>
  r = (struct run*)v;
80102ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80102de2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102de5:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dee:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102df3:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102df8:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102dfd:	85 c0                	test   %eax,%eax
80102dff:	74 0c                	je     80102e0d <kfree+0x97>
    release(&kmem.lock);
80102e01:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e08:	e8 fc 23 00 00       	call   80105209 <release>
}
80102e0d:	c9                   	leave  
80102e0e:	c3                   	ret    

80102e0f <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e0f:	55                   	push   %ebp
80102e10:	89 e5                	mov    %esp,%ebp
80102e12:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102e15:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e1a:	85 c0                	test   %eax,%eax
80102e1c:	74 0c                	je     80102e2a <kalloc+0x1b>
    acquire(&kmem.lock);
80102e1e:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e25:	e8 7d 23 00 00       	call   801051a7 <acquire>
  r = kmem.freelist;
80102e2a:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102e2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e36:	74 0a                	je     80102e42 <kalloc+0x33>
    kmem.freelist = r->next;
80102e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e3b:	8b 00                	mov    (%eax),%eax
80102e3d:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e42:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e47:	85 c0                	test   %eax,%eax
80102e49:	74 0c                	je     80102e57 <kalloc+0x48>
    release(&kmem.lock);
80102e4b:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e52:	e8 b2 23 00 00       	call   80105209 <release>
  return (char*)r;
80102e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e5a:	c9                   	leave  
80102e5b:	c3                   	ret    

80102e5c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e5c:	55                   	push   %ebp
80102e5d:	89 e5                	mov    %esp,%ebp
80102e5f:	53                   	push   %ebx
80102e60:	83 ec 14             	sub    $0x14,%esp
80102e63:	8b 45 08             	mov    0x8(%ebp),%eax
80102e66:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e6a:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102e6e:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102e72:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102e76:	ec                   	in     (%dx),%al
80102e77:	89 c3                	mov    %eax,%ebx
80102e79:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102e7c:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102e80:	83 c4 14             	add    $0x14,%esp
80102e83:	5b                   	pop    %ebx
80102e84:	5d                   	pop    %ebp
80102e85:	c3                   	ret    

80102e86 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e86:	55                   	push   %ebp
80102e87:	89 e5                	mov    %esp,%ebp
80102e89:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e8c:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102e93:	e8 c4 ff ff ff       	call   80102e5c <inb>
80102e98:	0f b6 c0             	movzbl %al,%eax
80102e9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea1:	83 e0 01             	and    $0x1,%eax
80102ea4:	85 c0                	test   %eax,%eax
80102ea6:	75 0a                	jne    80102eb2 <kbdgetc+0x2c>
    return -1;
80102ea8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ead:	e9 23 01 00 00       	jmp    80102fd5 <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102eb2:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102eb9:	e8 9e ff ff ff       	call   80102e5c <inb>
80102ebe:	0f b6 c0             	movzbl %al,%eax
80102ec1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    
  if(data == 0xE0){
80102ec4:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102ecb:	75 17                	jne    80102ee4 <kbdgetc+0x5e>
    shift |= E0ESC;
80102ecd:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ed2:	83 c8 40             	or     $0x40,%eax
80102ed5:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102eda:	b8 00 00 00 00       	mov    $0x0,%eax
80102edf:	e9 f1 00 00 00       	jmp    80102fd5 <kbdgetc+0x14f>
  } else if(data & 0x80){
80102ee4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ee7:	25 80 00 00 00       	and    $0x80,%eax
80102eec:	85 c0                	test   %eax,%eax
80102eee:	74 45                	je     80102f35 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ef0:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ef5:	83 e0 40             	and    $0x40,%eax
80102ef8:	85 c0                	test   %eax,%eax
80102efa:	75 08                	jne    80102f04 <kbdgetc+0x7e>
80102efc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eff:	83 e0 7f             	and    $0x7f,%eax
80102f02:	eb 03                	jmp    80102f07 <kbdgetc+0x81>
80102f04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f07:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f0d:	05 20 90 10 80       	add    $0x80109020,%eax
80102f12:	0f b6 00             	movzbl (%eax),%eax
80102f15:	83 c8 40             	or     $0x40,%eax
80102f18:	0f b6 c0             	movzbl %al,%eax
80102f1b:	f7 d0                	not    %eax
80102f1d:	89 c2                	mov    %eax,%edx
80102f1f:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f24:	21 d0                	and    %edx,%eax
80102f26:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102f2b:	b8 00 00 00 00       	mov    $0x0,%eax
80102f30:	e9 a0 00 00 00       	jmp    80102fd5 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102f35:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f3a:	83 e0 40             	and    $0x40,%eax
80102f3d:	85 c0                	test   %eax,%eax
80102f3f:	74 14                	je     80102f55 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f41:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f48:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f4d:	83 e0 bf             	and    $0xffffffbf,%eax
80102f50:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102f55:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f58:	05 20 90 10 80       	add    $0x80109020,%eax
80102f5d:	0f b6 00             	movzbl (%eax),%eax
80102f60:	0f b6 d0             	movzbl %al,%edx
80102f63:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f68:	09 d0                	or     %edx,%eax
80102f6a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102f6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f72:	05 20 91 10 80       	add    $0x80109120,%eax
80102f77:	0f b6 00             	movzbl (%eax),%eax
80102f7a:	0f b6 d0             	movzbl %al,%edx
80102f7d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f82:	31 d0                	xor    %edx,%eax
80102f84:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f89:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f8e:	83 e0 03             	and    $0x3,%eax
80102f91:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
80102f98:	03 45 fc             	add    -0x4(%ebp),%eax
80102f9b:	0f b6 00             	movzbl (%eax),%eax
80102f9e:	0f b6 c0             	movzbl %al,%eax
80102fa1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102fa4:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fa9:	83 e0 08             	and    $0x8,%eax
80102fac:	85 c0                	test   %eax,%eax
80102fae:	74 22                	je     80102fd2 <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102fb0:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102fb4:	76 0c                	jbe    80102fc2 <kbdgetc+0x13c>
80102fb6:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102fba:	77 06                	ja     80102fc2 <kbdgetc+0x13c>
      c += 'A' - 'a';
80102fbc:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102fc0:	eb 10                	jmp    80102fd2 <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80102fc2:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102fc6:	76 0a                	jbe    80102fd2 <kbdgetc+0x14c>
80102fc8:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102fcc:	77 04                	ja     80102fd2 <kbdgetc+0x14c>
      c += 'a' - 'A';
80102fce:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102fd2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102fd5:	c9                   	leave  
80102fd6:	c3                   	ret    

80102fd7 <kbdintr>:

void
kbdintr(void)
{
80102fd7:	55                   	push   %ebp
80102fd8:	89 e5                	mov    %esp,%ebp
80102fda:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102fdd:	c7 04 24 86 2e 10 80 	movl   $0x80102e86,(%esp)
80102fe4:	e8 a0 d8 ff ff       	call   80100889 <consoleintr>
}
80102fe9:	c9                   	leave  
80102fea:	c3                   	ret    
	...

80102fec <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102fec:	55                   	push   %ebp
80102fed:	89 e5                	mov    %esp,%ebp
80102fef:	83 ec 08             	sub    $0x8,%esp
80102ff2:	8b 55 08             	mov    0x8(%ebp),%edx
80102ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ff8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102ffc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102fff:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103003:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103007:	ee                   	out    %al,(%dx)
}
80103008:	c9                   	leave  
80103009:	c3                   	ret    

8010300a <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010300a:	55                   	push   %ebp
8010300b:	89 e5                	mov    %esp,%ebp
8010300d:	53                   	push   %ebx
8010300e:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103011:	9c                   	pushf  
80103012:	5b                   	pop    %ebx
80103013:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80103016:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103019:	83 c4 10             	add    $0x10,%esp
8010301c:	5b                   	pop    %ebx
8010301d:	5d                   	pop    %ebp
8010301e:	c3                   	ret    

8010301f <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
8010301f:	55                   	push   %ebp
80103020:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103022:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103027:	8b 55 08             	mov    0x8(%ebp),%edx
8010302a:	c1 e2 02             	shl    $0x2,%edx
8010302d:	01 c2                	add    %eax,%edx
8010302f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103032:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103034:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103039:	83 c0 20             	add    $0x20,%eax
8010303c:	8b 00                	mov    (%eax),%eax
}
8010303e:	5d                   	pop    %ebp
8010303f:	c3                   	ret    

80103040 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80103040:	55                   	push   %ebp
80103041:	89 e5                	mov    %esp,%ebp
80103043:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80103046:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010304b:	85 c0                	test   %eax,%eax
8010304d:	0f 84 47 01 00 00    	je     8010319a <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103053:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
8010305a:	00 
8010305b:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80103062:	e8 b8 ff ff ff       	call   8010301f <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103067:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
8010306e:	00 
8010306f:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103076:	e8 a4 ff ff ff       	call   8010301f <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010307b:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80103082:	00 
80103083:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010308a:	e8 90 ff ff ff       	call   8010301f <lapicw>
  lapicw(TICR, 10000000); 
8010308f:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80103096:	00 
80103097:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
8010309e:	e8 7c ff ff ff       	call   8010301f <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030a3:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030aa:	00 
801030ab:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801030b2:	e8 68 ff ff ff       	call   8010301f <lapicw>
  lapicw(LINT1, MASKED);
801030b7:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030be:	00 
801030bf:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
801030c6:	e8 54 ff ff ff       	call   8010301f <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801030cb:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801030d0:	83 c0 30             	add    $0x30,%eax
801030d3:	8b 00                	mov    (%eax),%eax
801030d5:	c1 e8 10             	shr    $0x10,%eax
801030d8:	25 ff 00 00 00       	and    $0xff,%eax
801030dd:	83 f8 03             	cmp    $0x3,%eax
801030e0:	76 14                	jbe    801030f6 <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
801030e2:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030e9:	00 
801030ea:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801030f1:	e8 29 ff ff ff       	call   8010301f <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801030f6:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
801030fd:	00 
801030fe:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103105:	e8 15 ff ff ff       	call   8010301f <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010310a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103111:	00 
80103112:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103119:	e8 01 ff ff ff       	call   8010301f <lapicw>
  lapicw(ESR, 0);
8010311e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103125:	00 
80103126:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010312d:	e8 ed fe ff ff       	call   8010301f <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103132:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103139:	00 
8010313a:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103141:	e8 d9 fe ff ff       	call   8010301f <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103146:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010314d:	00 
8010314e:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103155:	e8 c5 fe ff ff       	call   8010301f <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010315a:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103161:	00 
80103162:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103169:	e8 b1 fe ff ff       	call   8010301f <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010316e:	90                   	nop
8010316f:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103174:	05 00 03 00 00       	add    $0x300,%eax
80103179:	8b 00                	mov    (%eax),%eax
8010317b:	25 00 10 00 00       	and    $0x1000,%eax
80103180:	85 c0                	test   %eax,%eax
80103182:	75 eb                	jne    8010316f <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103184:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010318b:	00 
8010318c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103193:	e8 87 fe ff ff       	call   8010301f <lapicw>
80103198:	eb 01                	jmp    8010319b <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
8010319a:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010319b:	c9                   	leave  
8010319c:	c3                   	ret    

8010319d <cpunum>:

int
cpunum(void)
{
8010319d:	55                   	push   %ebp
8010319e:	89 e5                	mov    %esp,%ebp
801031a0:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801031a3:	e8 62 fe ff ff       	call   8010300a <readeflags>
801031a8:	25 00 02 00 00       	and    $0x200,%eax
801031ad:	85 c0                	test   %eax,%eax
801031af:	74 29                	je     801031da <cpunum+0x3d>
    static int n;
    if(n++ == 0)
801031b1:	a1 40 b6 10 80       	mov    0x8010b640,%eax
801031b6:	85 c0                	test   %eax,%eax
801031b8:	0f 94 c2             	sete   %dl
801031bb:	83 c0 01             	add    $0x1,%eax
801031be:	a3 40 b6 10 80       	mov    %eax,0x8010b640
801031c3:	84 d2                	test   %dl,%dl
801031c5:	74 13                	je     801031da <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
801031c7:	8b 45 04             	mov    0x4(%ebp),%eax
801031ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801031ce:	c7 04 24 30 8a 10 80 	movl   $0x80108a30,(%esp)
801031d5:	e8 c7 d1 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
801031da:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031df:	85 c0                	test   %eax,%eax
801031e1:	74 0f                	je     801031f2 <cpunum+0x55>
    return lapic[ID]>>24;
801031e3:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031e8:	83 c0 20             	add    $0x20,%eax
801031eb:	8b 00                	mov    (%eax),%eax
801031ed:	c1 e8 18             	shr    $0x18,%eax
801031f0:	eb 05                	jmp    801031f7 <cpunum+0x5a>
  return 0;
801031f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801031f7:	c9                   	leave  
801031f8:	c3                   	ret    

801031f9 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801031f9:	55                   	push   %ebp
801031fa:	89 e5                	mov    %esp,%ebp
801031fc:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801031ff:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103204:	85 c0                	test   %eax,%eax
80103206:	74 14                	je     8010321c <lapiceoi+0x23>
    lapicw(EOI, 0);
80103208:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010320f:	00 
80103210:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103217:	e8 03 fe ff ff       	call   8010301f <lapicw>
}
8010321c:	c9                   	leave  
8010321d:	c3                   	ret    

8010321e <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010321e:	55                   	push   %ebp
8010321f:	89 e5                	mov    %esp,%ebp
}
80103221:	5d                   	pop    %ebp
80103222:	c3                   	ret    

80103223 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103223:	55                   	push   %ebp
80103224:	89 e5                	mov    %esp,%ebp
80103226:	83 ec 1c             	sub    $0x1c,%esp
80103229:	8b 45 08             	mov    0x8(%ebp),%eax
8010322c:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
8010322f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103236:	00 
80103237:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010323e:	e8 a9 fd ff ff       	call   80102fec <outb>
  outb(IO_RTC+1, 0x0A);
80103243:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010324a:	00 
8010324b:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103252:	e8 95 fd ff ff       	call   80102fec <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103257:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010325e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103261:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103266:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103269:	8d 50 02             	lea    0x2(%eax),%edx
8010326c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010326f:	c1 e8 04             	shr    $0x4,%eax
80103272:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103275:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103279:	c1 e0 18             	shl    $0x18,%eax
8010327c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103280:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103287:	e8 93 fd ff ff       	call   8010301f <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010328c:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103293:	00 
80103294:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010329b:	e8 7f fd ff ff       	call   8010301f <lapicw>
  microdelay(200);
801032a0:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032a7:	e8 72 ff ff ff       	call   8010321e <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801032ac:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801032b3:	00 
801032b4:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032bb:	e8 5f fd ff ff       	call   8010301f <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801032c0:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801032c7:	e8 52 ff ff ff       	call   8010321e <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801032cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801032d3:	eb 40                	jmp    80103315 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801032d5:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032d9:	c1 e0 18             	shl    $0x18,%eax
801032dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801032e0:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032e7:	e8 33 fd ff ff       	call   8010301f <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801032ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801032ef:	c1 e8 0c             	shr    $0xc,%eax
801032f2:	80 cc 06             	or     $0x6,%ah
801032f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801032f9:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103300:	e8 1a fd ff ff       	call   8010301f <lapicw>
    microdelay(200);
80103305:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010330c:	e8 0d ff ff ff       	call   8010321e <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103311:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103315:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103319:	7e ba                	jle    801032d5 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010331b:	c9                   	leave  
8010331c:	c3                   	ret    
8010331d:	00 00                	add    %al,(%eax)
	...

80103320 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103320:	55                   	push   %ebp
80103321:	89 e5                	mov    %esp,%ebp
80103323:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103326:	c7 44 24 04 5c 8a 10 	movl   $0x80108a5c,0x4(%esp)
8010332d:	80 
8010332e:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103335:	e8 4c 1e 00 00       	call   80105186 <initlock>
  readsb(ROOTDEV, &sb);
8010333a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010333d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103341:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103348:	e8 af e2 ff ff       	call   801015fc <readsb>
  log.start = sb.size - sb.nlog;
8010334d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103350:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103353:	89 d1                	mov    %edx,%ecx
80103355:	29 c1                	sub    %eax,%ecx
80103357:	89 c8                	mov    %ecx,%eax
80103359:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
8010335e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103361:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
80103366:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
8010336d:	00 00 00 
  recover_from_log();
80103370:	e8 97 01 00 00       	call   8010350c <recover_from_log>
}
80103375:	c9                   	leave  
80103376:	c3                   	ret    

80103377 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103377:	55                   	push   %ebp
80103378:	89 e5                	mov    %esp,%ebp
8010337a:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010337d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103384:	e9 89 00 00 00       	jmp    80103412 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103389:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
8010338e:	03 45 f4             	add    -0xc(%ebp),%eax
80103391:	83 c0 01             	add    $0x1,%eax
80103394:	89 c2                	mov    %eax,%edx
80103396:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
8010339b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010339f:	89 04 24             	mov    %eax,(%esp)
801033a2:	e8 ff cd ff ff       	call   801001a6 <bread>
801033a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801033aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033ad:	83 c0 10             	add    $0x10,%eax
801033b0:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
801033b7:	89 c2                	mov    %eax,%edx
801033b9:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801033be:	89 54 24 04          	mov    %edx,0x4(%esp)
801033c2:	89 04 24             	mov    %eax,(%esp)
801033c5:	e8 dc cd ff ff       	call   801001a6 <bread>
801033ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033d0:	8d 50 18             	lea    0x18(%eax),%edx
801033d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033d6:	83 c0 18             	add    $0x18,%eax
801033d9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801033e0:	00 
801033e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801033e5:	89 04 24             	mov    %eax,(%esp)
801033e8:	e8 dc 20 00 00       	call   801054c9 <memmove>
    bwrite(dbuf);  // write dst to disk
801033ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033f0:	89 04 24             	mov    %eax,(%esp)
801033f3:	e8 e5 cd ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801033f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033fb:	89 04 24             	mov    %eax,(%esp)
801033fe:	e8 14 ce ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103403:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103406:	89 04 24             	mov    %eax,(%esp)
80103409:	e8 09 ce ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010340e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103412:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103417:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010341a:	0f 8f 69 ff ff ff    	jg     80103389 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103420:	c9                   	leave  
80103421:	c3                   	ret    

80103422 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103422:	55                   	push   %ebp
80103423:	89 e5                	mov    %esp,%ebp
80103425:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103428:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
8010342d:	89 c2                	mov    %eax,%edx
8010342f:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103434:	89 54 24 04          	mov    %edx,0x4(%esp)
80103438:	89 04 24             	mov    %eax,(%esp)
8010343b:	e8 66 cd ff ff       	call   801001a6 <bread>
80103440:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103443:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103446:	83 c0 18             	add    $0x18,%eax
80103449:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010344c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010344f:	8b 00                	mov    (%eax),%eax
80103451:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
80103456:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010345d:	eb 1b                	jmp    8010347a <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
8010345f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103462:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103465:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103469:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010346c:	83 c2 10             	add    $0x10,%edx
8010346f:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103476:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010347a:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010347f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103482:	7f db                	jg     8010345f <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103484:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103487:	89 04 24             	mov    %eax,(%esp)
8010348a:	e8 88 cd ff ff       	call   80100217 <brelse>
}
8010348f:	c9                   	leave  
80103490:	c3                   	ret    

80103491 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103491:	55                   	push   %ebp
80103492:	89 e5                	mov    %esp,%ebp
80103494:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103497:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
8010349c:	89 c2                	mov    %eax,%edx
8010349e:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801034a3:	89 54 24 04          	mov    %edx,0x4(%esp)
801034a7:	89 04 24             	mov    %eax,(%esp)
801034aa:	e8 f7 cc ff ff       	call   801001a6 <bread>
801034af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b5:	83 c0 18             	add    $0x18,%eax
801034b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034bb:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
801034c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034c4:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034cd:	eb 1b                	jmp    801034ea <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801034cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034d2:	83 c0 10             	add    $0x10,%eax
801034d5:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
801034dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034df:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034e2:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034e6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034ea:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801034ef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034f2:	7f db                	jg     801034cf <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801034f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034f7:	89 04 24             	mov    %eax,(%esp)
801034fa:	e8 de cc ff ff       	call   801001dd <bwrite>
  brelse(buf);
801034ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103502:	89 04 24             	mov    %eax,(%esp)
80103505:	e8 0d cd ff ff       	call   80100217 <brelse>
}
8010350a:	c9                   	leave  
8010350b:	c3                   	ret    

8010350c <recover_from_log>:

static void
recover_from_log(void)
{
8010350c:	55                   	push   %ebp
8010350d:	89 e5                	mov    %esp,%ebp
8010350f:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103512:	e8 0b ff ff ff       	call   80103422 <read_head>
  install_trans(); // if committed, copy from log to disk
80103517:	e8 5b fe ff ff       	call   80103377 <install_trans>
  log.lh.n = 0;
8010351c:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
80103523:	00 00 00 
  write_head(); // clear the log
80103526:	e8 66 ff ff ff       	call   80103491 <write_head>
}
8010352b:	c9                   	leave  
8010352c:	c3                   	ret    

8010352d <begin_trans>:

void
begin_trans(void)
{
8010352d:	55                   	push   %ebp
8010352e:	89 e5                	mov    %esp,%ebp
80103530:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103533:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010353a:	e8 68 1c 00 00       	call   801051a7 <acquire>
  while (log.busy) {
8010353f:	eb 14                	jmp    80103555 <begin_trans+0x28>
    sleep(&log, &log.lock);
80103541:	c7 44 24 04 a0 f8 10 	movl   $0x8010f8a0,0x4(%esp)
80103548:	80 
80103549:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103550:	e8 e9 18 00 00       	call   80104e3e <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
80103555:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
8010355a:	85 c0                	test   %eax,%eax
8010355c:	75 e3                	jne    80103541 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
8010355e:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
80103565:	00 00 00 
  release(&log.lock);
80103568:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010356f:	e8 95 1c 00 00       	call   80105209 <release>
}
80103574:	c9                   	leave  
80103575:	c3                   	ret    

80103576 <commit_trans>:

void
commit_trans(void)
{
80103576:	55                   	push   %ebp
80103577:	89 e5                	mov    %esp,%ebp
80103579:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
8010357c:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103581:	85 c0                	test   %eax,%eax
80103583:	7e 19                	jle    8010359e <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
80103585:	e8 07 ff ff ff       	call   80103491 <write_head>
    install_trans(); // Now install writes to home locations
8010358a:	e8 e8 fd ff ff       	call   80103377 <install_trans>
    log.lh.n = 0; 
8010358f:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
80103596:	00 00 00 
    write_head();    // Erase the transaction from the log
80103599:	e8 f3 fe ff ff       	call   80103491 <write_head>
  }
  
  acquire(&log.lock);
8010359e:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035a5:	e8 fd 1b 00 00       	call   801051a7 <acquire>
  log.busy = 0;
801035aa:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
801035b1:	00 00 00 
  wakeup(&log);
801035b4:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035bb:	e8 5a 19 00 00       	call   80104f1a <wakeup>
  release(&log.lock);
801035c0:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035c7:	e8 3d 1c 00 00       	call   80105209 <release>
}
801035cc:	c9                   	leave  
801035cd:	c3                   	ret    

801035ce <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801035ce:	55                   	push   %ebp
801035cf:	89 e5                	mov    %esp,%ebp
801035d1:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801035d4:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035d9:	83 f8 09             	cmp    $0x9,%eax
801035dc:	7f 12                	jg     801035f0 <log_write+0x22>
801035de:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035e3:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
801035e9:	83 ea 01             	sub    $0x1,%edx
801035ec:	39 d0                	cmp    %edx,%eax
801035ee:	7c 0c                	jl     801035fc <log_write+0x2e>
    panic("too big a transaction");
801035f0:	c7 04 24 60 8a 10 80 	movl   $0x80108a60,(%esp)
801035f7:	e8 41 cf ff ff       	call   8010053d <panic>
  if (!log.busy)
801035fc:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103601:	85 c0                	test   %eax,%eax
80103603:	75 0c                	jne    80103611 <log_write+0x43>
    panic("write outside of trans");
80103605:	c7 04 24 76 8a 10 80 	movl   $0x80108a76,(%esp)
8010360c:	e8 2c cf ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
80103611:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103618:	eb 1d                	jmp    80103637 <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
8010361a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010361d:	83 c0 10             	add    $0x10,%eax
80103620:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
80103627:	89 c2                	mov    %eax,%edx
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 40 08             	mov    0x8(%eax),%eax
8010362f:	39 c2                	cmp    %eax,%edx
80103631:	74 10                	je     80103643 <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
80103633:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103637:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010363c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010363f:	7f d9                	jg     8010361a <log_write+0x4c>
80103641:	eb 01                	jmp    80103644 <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
80103643:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103644:	8b 45 08             	mov    0x8(%ebp),%eax
80103647:	8b 40 08             	mov    0x8(%eax),%eax
8010364a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010364d:	83 c2 10             	add    $0x10,%edx
80103650:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
80103657:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
8010365c:	03 45 f4             	add    -0xc(%ebp),%eax
8010365f:	83 c0 01             	add    $0x1,%eax
80103662:	89 c2                	mov    %eax,%edx
80103664:	8b 45 08             	mov    0x8(%ebp),%eax
80103667:	8b 40 04             	mov    0x4(%eax),%eax
8010366a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010366e:	89 04 24             	mov    %eax,(%esp)
80103671:	e8 30 cb ff ff       	call   801001a6 <bread>
80103676:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
80103679:	8b 45 08             	mov    0x8(%ebp),%eax
8010367c:	8d 50 18             	lea    0x18(%eax),%edx
8010367f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103682:	83 c0 18             	add    $0x18,%eax
80103685:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010368c:	00 
8010368d:	89 54 24 04          	mov    %edx,0x4(%esp)
80103691:	89 04 24             	mov    %eax,(%esp)
80103694:	e8 30 1e 00 00       	call   801054c9 <memmove>
  bwrite(lbuf);
80103699:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010369c:	89 04 24             	mov    %eax,(%esp)
8010369f:	e8 39 cb ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
801036a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036a7:	89 04 24             	mov    %eax,(%esp)
801036aa:	e8 68 cb ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
801036af:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801036b4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036b7:	75 0d                	jne    801036c6 <log_write+0xf8>
    log.lh.n++;
801036b9:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801036be:	83 c0 01             	add    $0x1,%eax
801036c1:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
801036c6:	8b 45 08             	mov    0x8(%ebp),%eax
801036c9:	8b 00                	mov    (%eax),%eax
801036cb:	89 c2                	mov    %eax,%edx
801036cd:	83 ca 04             	or     $0x4,%edx
801036d0:	8b 45 08             	mov    0x8(%ebp),%eax
801036d3:	89 10                	mov    %edx,(%eax)
}
801036d5:	c9                   	leave  
801036d6:	c3                   	ret    
	...

801036d8 <v2p>:
801036d8:	55                   	push   %ebp
801036d9:	89 e5                	mov    %esp,%ebp
801036db:	8b 45 08             	mov    0x8(%ebp),%eax
801036de:	05 00 00 00 80       	add    $0x80000000,%eax
801036e3:	5d                   	pop    %ebp
801036e4:	c3                   	ret    

801036e5 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801036e5:	55                   	push   %ebp
801036e6:	89 e5                	mov    %esp,%ebp
801036e8:	8b 45 08             	mov    0x8(%ebp),%eax
801036eb:	05 00 00 00 80       	add    $0x80000000,%eax
801036f0:	5d                   	pop    %ebp
801036f1:	c3                   	ret    

801036f2 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801036f2:	55                   	push   %ebp
801036f3:	89 e5                	mov    %esp,%ebp
801036f5:	53                   	push   %ebx
801036f6:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
801036f9:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801036fc:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
801036ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103702:	89 c3                	mov    %eax,%ebx
80103704:	89 d8                	mov    %ebx,%eax
80103706:	f0 87 02             	lock xchg %eax,(%edx)
80103709:	89 c3                	mov    %eax,%ebx
8010370b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010370e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103711:	83 c4 10             	add    $0x10,%esp
80103714:	5b                   	pop    %ebx
80103715:	5d                   	pop    %ebp
80103716:	c3                   	ret    

80103717 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103717:	55                   	push   %ebp
80103718:	89 e5                	mov    %esp,%ebp
8010371a:	83 e4 f0             	and    $0xfffffff0,%esp
8010371d:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103720:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103727:	80 
80103728:	c7 04 24 1c 2d 11 80 	movl   $0x80112d1c,(%esp)
8010372f:	e8 ad f5 ff ff       	call   80102ce1 <kinit1>
  kvmalloc();      // kernel page table
80103734:	e8 81 49 00 00       	call   801080ba <kvmalloc>
  mpinit();        // collect info about this machine
80103739:	e8 63 04 00 00       	call   80103ba1 <mpinit>
  lapicinit(mpbcpu());
8010373e:	e8 2e 02 00 00       	call   80103971 <mpbcpu>
80103743:	89 04 24             	mov    %eax,(%esp)
80103746:	e8 f5 f8 ff ff       	call   80103040 <lapicinit>
  seginit();       // set up segments
8010374b:	e8 0d 43 00 00       	call   80107a5d <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103750:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103756:	0f b6 00             	movzbl (%eax),%eax
80103759:	0f b6 c0             	movzbl %al,%eax
8010375c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103760:	c7 04 24 8d 8a 10 80 	movl   $0x80108a8d,(%esp)
80103767:	e8 35 cc ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
8010376c:	e8 95 06 00 00       	call   80103e06 <picinit>
  ioapicinit();    // another interrupt controller
80103771:	e8 5b f4 ff ff       	call   80102bd1 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103776:	e8 21 d6 ff ff       	call   80100d9c <consoleinit>
  uartinit();      // serial port
8010377b:	e8 28 36 00 00       	call   80106da8 <uartinit>
  pinit();         // process table
80103780:	e8 96 0b 00 00       	call   8010431b <pinit>
  tvinit();        // trap vectors
80103785:	e8 7d 31 00 00       	call   80106907 <tvinit>
  binit();         // buffer cache
8010378a:	e8 a5 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010378f:	e8 7c da ff ff       	call   80101210 <fileinit>
  iinit();         // inode cache
80103794:	e8 2a e1 ff ff       	call   801018c3 <iinit>
  ideinit();       // disk
80103799:	e8 98 f0 ff ff       	call   80102836 <ideinit>
  if(!ismp)
8010379e:	a1 24 f9 10 80       	mov    0x8010f924,%eax
801037a3:	85 c0                	test   %eax,%eax
801037a5:	75 05                	jne    801037ac <main+0x95>
    timerinit();   // uniprocessor timer
801037a7:	e8 9e 30 00 00       	call   8010684a <timerinit>
  startothers();   // start other processors
801037ac:	e8 87 00 00 00       	call   80103838 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037b1:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037b8:	8e 
801037b9:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801037c0:	e8 54 f5 ff ff       	call   80102d19 <kinit2>
  userinit();      // first user process
801037c5:	e8 6f 0c 00 00       	call   80104439 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801037ca:	e8 22 00 00 00       	call   801037f1 <mpmain>

801037cf <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801037cf:	55                   	push   %ebp
801037d0:	89 e5                	mov    %esp,%ebp
801037d2:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
801037d5:	e8 f7 48 00 00       	call   801080d1 <switchkvm>
  seginit();
801037da:	e8 7e 42 00 00       	call   80107a5d <seginit>
  lapicinit(cpunum());
801037df:	e8 b9 f9 ff ff       	call   8010319d <cpunum>
801037e4:	89 04 24             	mov    %eax,(%esp)
801037e7:	e8 54 f8 ff ff       	call   80103040 <lapicinit>
  mpmain();
801037ec:	e8 00 00 00 00       	call   801037f1 <mpmain>

801037f1 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801037f1:	55                   	push   %ebp
801037f2:	89 e5                	mov    %esp,%ebp
801037f4:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801037f7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037fd:	0f b6 00             	movzbl (%eax),%eax
80103800:	0f b6 c0             	movzbl %al,%eax
80103803:	89 44 24 04          	mov    %eax,0x4(%esp)
80103807:	c7 04 24 a4 8a 10 80 	movl   $0x80108aa4,(%esp)
8010380e:	e8 8e cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80103813:	e8 63 32 00 00       	call   80106a7b <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103818:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010381e:	05 a8 00 00 00       	add    $0xa8,%eax
80103823:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010382a:	00 
8010382b:	89 04 24             	mov    %eax,(%esp)
8010382e:	e8 bf fe ff ff       	call   801036f2 <xchg>
  scheduler();     // start running processes
80103833:	e8 ae 13 00 00       	call   80104be6 <scheduler>

80103838 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103838:	55                   	push   %ebp
80103839:	89 e5                	mov    %esp,%ebp
8010383b:	53                   	push   %ebx
8010383c:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010383f:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103846:	e8 9a fe ff ff       	call   801036e5 <p2v>
8010384b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010384e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103853:	89 44 24 08          	mov    %eax,0x8(%esp)
80103857:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
8010385e:	80 
8010385f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103862:	89 04 24             	mov    %eax,(%esp)
80103865:	e8 5f 1c 00 00       	call   801054c9 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010386a:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
80103871:	e9 86 00 00 00       	jmp    801038fc <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
80103876:	e8 22 f9 ff ff       	call   8010319d <cpunum>
8010387b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103881:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103886:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103889:	74 69                	je     801038f4 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010388b:	e8 7f f5 ff ff       	call   80102e0f <kalloc>
80103890:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103893:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103896:	83 e8 04             	sub    $0x4,%eax
80103899:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010389c:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038a2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a7:	83 e8 08             	sub    $0x8,%eax
801038aa:	c7 00 cf 37 10 80    	movl   $0x801037cf,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038b3:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038b6:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
801038bd:	e8 16 fe ff ff       	call   801036d8 <v2p>
801038c2:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801038c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c7:	89 04 24             	mov    %eax,(%esp)
801038ca:	e8 09 fe ff ff       	call   801036d8 <v2p>
801038cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038d2:	0f b6 12             	movzbl (%edx),%edx
801038d5:	0f b6 d2             	movzbl %dl,%edx
801038d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801038dc:	89 14 24             	mov    %edx,(%esp)
801038df:	e8 3f f9 ff ff       	call   80103223 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801038e4:	90                   	nop
801038e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038e8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801038ee:	85 c0                	test   %eax,%eax
801038f0:	74 f3                	je     801038e5 <startothers+0xad>
801038f2:	eb 01                	jmp    801038f5 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801038f4:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801038f5:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801038fc:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103901:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103907:	05 40 f9 10 80       	add    $0x8010f940,%eax
8010390c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010390f:	0f 87 61 ff ff ff    	ja     80103876 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103915:	83 c4 24             	add    $0x24,%esp
80103918:	5b                   	pop    %ebx
80103919:	5d                   	pop    %ebp
8010391a:	c3                   	ret    
	...

8010391c <p2v>:
8010391c:	55                   	push   %ebp
8010391d:	89 e5                	mov    %esp,%ebp
8010391f:	8b 45 08             	mov    0x8(%ebp),%eax
80103922:	05 00 00 00 80       	add    $0x80000000,%eax
80103927:	5d                   	pop    %ebp
80103928:	c3                   	ret    

80103929 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103929:	55                   	push   %ebp
8010392a:	89 e5                	mov    %esp,%ebp
8010392c:	53                   	push   %ebx
8010392d:	83 ec 14             	sub    $0x14,%esp
80103930:	8b 45 08             	mov    0x8(%ebp),%eax
80103933:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103937:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010393b:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010393f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80103943:	ec                   	in     (%dx),%al
80103944:	89 c3                	mov    %eax,%ebx
80103946:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103949:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
8010394d:	83 c4 14             	add    $0x14,%esp
80103950:	5b                   	pop    %ebx
80103951:	5d                   	pop    %ebp
80103952:	c3                   	ret    

80103953 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103953:	55                   	push   %ebp
80103954:	89 e5                	mov    %esp,%ebp
80103956:	83 ec 08             	sub    $0x8,%esp
80103959:	8b 55 08             	mov    0x8(%ebp),%edx
8010395c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010395f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103963:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103966:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010396a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010396e:	ee                   	out    %al,(%dx)
}
8010396f:	c9                   	leave  
80103970:	c3                   	ret    

80103971 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103971:	55                   	push   %ebp
80103972:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103974:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103979:	89 c2                	mov    %eax,%edx
8010397b:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
80103980:	89 d1                	mov    %edx,%ecx
80103982:	29 c1                	sub    %eax,%ecx
80103984:	89 c8                	mov    %ecx,%eax
80103986:	c1 f8 02             	sar    $0x2,%eax
80103989:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010398f:	5d                   	pop    %ebp
80103990:	c3                   	ret    

80103991 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103991:	55                   	push   %ebp
80103992:	89 e5                	mov    %esp,%ebp
80103994:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103997:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010399e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039a5:	eb 13                	jmp    801039ba <sum+0x29>
    sum += addr[i];
801039a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039aa:	03 45 08             	add    0x8(%ebp),%eax
801039ad:	0f b6 00             	movzbl (%eax),%eax
801039b0:	0f b6 c0             	movzbl %al,%eax
801039b3:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801039b6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801039ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039bd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801039c0:	7c e5                	jl     801039a7 <sum+0x16>
    sum += addr[i];
  return sum;
801039c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801039c5:	c9                   	leave  
801039c6:	c3                   	ret    

801039c7 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801039c7:	55                   	push   %ebp
801039c8:	89 e5                	mov    %esp,%ebp
801039ca:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801039cd:	8b 45 08             	mov    0x8(%ebp),%eax
801039d0:	89 04 24             	mov    %eax,(%esp)
801039d3:	e8 44 ff ff ff       	call   8010391c <p2v>
801039d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801039db:	8b 45 0c             	mov    0xc(%ebp),%eax
801039de:	03 45 f0             	add    -0x10(%ebp),%eax
801039e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801039e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039ea:	eb 3f                	jmp    80103a2b <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801039ec:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801039f3:	00 
801039f4:	c7 44 24 04 b8 8a 10 	movl   $0x80108ab8,0x4(%esp)
801039fb:	80 
801039fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ff:	89 04 24             	mov    %eax,(%esp)
80103a02:	e8 66 1a 00 00       	call   8010546d <memcmp>
80103a07:	85 c0                	test   %eax,%eax
80103a09:	75 1c                	jne    80103a27 <mpsearch1+0x60>
80103a0b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a12:	00 
80103a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a16:	89 04 24             	mov    %eax,(%esp)
80103a19:	e8 73 ff ff ff       	call   80103991 <sum>
80103a1e:	84 c0                	test   %al,%al
80103a20:	75 05                	jne    80103a27 <mpsearch1+0x60>
      return (struct mp*)p;
80103a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a25:	eb 11                	jmp    80103a38 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a27:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a31:	72 b9                	jb     801039ec <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a33:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a38:	c9                   	leave  
80103a39:	c3                   	ret    

80103a3a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a3a:	55                   	push   %ebp
80103a3b:	89 e5                	mov    %esp,%ebp
80103a3d:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a40:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a4a:	83 c0 0f             	add    $0xf,%eax
80103a4d:	0f b6 00             	movzbl (%eax),%eax
80103a50:	0f b6 c0             	movzbl %al,%eax
80103a53:	89 c2                	mov    %eax,%edx
80103a55:	c1 e2 08             	shl    $0x8,%edx
80103a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5b:	83 c0 0e             	add    $0xe,%eax
80103a5e:	0f b6 00             	movzbl (%eax),%eax
80103a61:	0f b6 c0             	movzbl %al,%eax
80103a64:	09 d0                	or     %edx,%eax
80103a66:	c1 e0 04             	shl    $0x4,%eax
80103a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a6c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a70:	74 21                	je     80103a93 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a72:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a79:	00 
80103a7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a7d:	89 04 24             	mov    %eax,(%esp)
80103a80:	e8 42 ff ff ff       	call   801039c7 <mpsearch1>
80103a85:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a88:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a8c:	74 50                	je     80103ade <mpsearch+0xa4>
      return mp;
80103a8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a91:	eb 5f                	jmp    80103af2 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a96:	83 c0 14             	add    $0x14,%eax
80103a99:	0f b6 00             	movzbl (%eax),%eax
80103a9c:	0f b6 c0             	movzbl %al,%eax
80103a9f:	89 c2                	mov    %eax,%edx
80103aa1:	c1 e2 08             	shl    $0x8,%edx
80103aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa7:	83 c0 13             	add    $0x13,%eax
80103aaa:	0f b6 00             	movzbl (%eax),%eax
80103aad:	0f b6 c0             	movzbl %al,%eax
80103ab0:	09 d0                	or     %edx,%eax
80103ab2:	c1 e0 0a             	shl    $0xa,%eax
80103ab5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103abb:	2d 00 04 00 00       	sub    $0x400,%eax
80103ac0:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ac7:	00 
80103ac8:	89 04 24             	mov    %eax,(%esp)
80103acb:	e8 f7 fe ff ff       	call   801039c7 <mpsearch1>
80103ad0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ad3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ad7:	74 05                	je     80103ade <mpsearch+0xa4>
      return mp;
80103ad9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103adc:	eb 14                	jmp    80103af2 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ade:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ae5:	00 
80103ae6:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103aed:	e8 d5 fe ff ff       	call   801039c7 <mpsearch1>
}
80103af2:	c9                   	leave  
80103af3:	c3                   	ret    

80103af4 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103af4:	55                   	push   %ebp
80103af5:	89 e5                	mov    %esp,%ebp
80103af7:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103afa:	e8 3b ff ff ff       	call   80103a3a <mpsearch>
80103aff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b06:	74 0a                	je     80103b12 <mpconfig+0x1e>
80103b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0b:	8b 40 04             	mov    0x4(%eax),%eax
80103b0e:	85 c0                	test   %eax,%eax
80103b10:	75 0a                	jne    80103b1c <mpconfig+0x28>
    return 0;
80103b12:	b8 00 00 00 00       	mov    $0x0,%eax
80103b17:	e9 83 00 00 00       	jmp    80103b9f <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b1f:	8b 40 04             	mov    0x4(%eax),%eax
80103b22:	89 04 24             	mov    %eax,(%esp)
80103b25:	e8 f2 fd ff ff       	call   8010391c <p2v>
80103b2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b2d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b34:	00 
80103b35:	c7 44 24 04 bd 8a 10 	movl   $0x80108abd,0x4(%esp)
80103b3c:	80 
80103b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b40:	89 04 24             	mov    %eax,(%esp)
80103b43:	e8 25 19 00 00       	call   8010546d <memcmp>
80103b48:	85 c0                	test   %eax,%eax
80103b4a:	74 07                	je     80103b53 <mpconfig+0x5f>
    return 0;
80103b4c:	b8 00 00 00 00       	mov    $0x0,%eax
80103b51:	eb 4c                	jmp    80103b9f <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b56:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b5a:	3c 01                	cmp    $0x1,%al
80103b5c:	74 12                	je     80103b70 <mpconfig+0x7c>
80103b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b61:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b65:	3c 04                	cmp    $0x4,%al
80103b67:	74 07                	je     80103b70 <mpconfig+0x7c>
    return 0;
80103b69:	b8 00 00 00 00       	mov    $0x0,%eax
80103b6e:	eb 2f                	jmp    80103b9f <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103b70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b73:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b77:	0f b7 c0             	movzwl %ax,%eax
80103b7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b81:	89 04 24             	mov    %eax,(%esp)
80103b84:	e8 08 fe ff ff       	call   80103991 <sum>
80103b89:	84 c0                	test   %al,%al
80103b8b:	74 07                	je     80103b94 <mpconfig+0xa0>
    return 0;
80103b8d:	b8 00 00 00 00       	mov    $0x0,%eax
80103b92:	eb 0b                	jmp    80103b9f <mpconfig+0xab>
  *pmp = mp;
80103b94:	8b 45 08             	mov    0x8(%ebp),%eax
80103b97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b9a:	89 10                	mov    %edx,(%eax)
  return conf;
80103b9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103b9f:	c9                   	leave  
80103ba0:	c3                   	ret    

80103ba1 <mpinit>:

void
mpinit(void)
{
80103ba1:	55                   	push   %ebp
80103ba2:	89 e5                	mov    %esp,%ebp
80103ba4:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103ba7:	c7 05 44 b6 10 80 40 	movl   $0x8010f940,0x8010b644
80103bae:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103bb1:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103bb4:	89 04 24             	mov    %eax,(%esp)
80103bb7:	e8 38 ff ff ff       	call   80103af4 <mpconfig>
80103bbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bbf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bc3:	0f 84 9c 01 00 00    	je     80103d65 <mpinit+0x1c4>
    return;
  ismp = 1;
80103bc9:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
80103bd0:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103bd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd6:	8b 40 24             	mov    0x24(%eax),%eax
80103bd9:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be1:	83 c0 2c             	add    $0x2c,%eax
80103be4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103be7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bea:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bee:	0f b7 c0             	movzwl %ax,%eax
80103bf1:	03 45 f0             	add    -0x10(%ebp),%eax
80103bf4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bf7:	e9 f4 00 00 00       	jmp    80103cf0 <mpinit+0x14f>
    switch(*p){
80103bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bff:	0f b6 00             	movzbl (%eax),%eax
80103c02:	0f b6 c0             	movzbl %al,%eax
80103c05:	83 f8 04             	cmp    $0x4,%eax
80103c08:	0f 87 bf 00 00 00    	ja     80103ccd <mpinit+0x12c>
80103c0e:	8b 04 85 00 8b 10 80 	mov    -0x7fef7500(,%eax,4),%eax
80103c15:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c20:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c24:	0f b6 d0             	movzbl %al,%edx
80103c27:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c2c:	39 c2                	cmp    %eax,%edx
80103c2e:	74 2d                	je     80103c5d <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c30:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c33:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c37:	0f b6 d0             	movzbl %al,%edx
80103c3a:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c3f:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c43:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c47:	c7 04 24 c2 8a 10 80 	movl   $0x80108ac2,(%esp)
80103c4e:	e8 4e c7 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103c53:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103c5a:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103c5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c60:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103c64:	0f b6 c0             	movzbl %al,%eax
80103c67:	83 e0 02             	and    $0x2,%eax
80103c6a:	85 c0                	test   %eax,%eax
80103c6c:	74 15                	je     80103c83 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103c6e:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c73:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c79:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103c7e:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103c83:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
80103c89:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c8e:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103c94:	81 c2 40 f9 10 80    	add    $0x8010f940,%edx
80103c9a:	88 02                	mov    %al,(%edx)
      ncpu++;
80103c9c:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103ca1:	83 c0 01             	add    $0x1,%eax
80103ca4:	a3 20 ff 10 80       	mov    %eax,0x8010ff20
      p += sizeof(struct mpproc);
80103ca9:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103cad:	eb 41                	jmp    80103cf0 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103cb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cb8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cbc:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
80103cc1:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cc5:	eb 29                	jmp    80103cf0 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cc7:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ccb:	eb 23                	jmp    80103cf0 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd0:	0f b6 00             	movzbl (%eax),%eax
80103cd3:	0f b6 c0             	movzbl %al,%eax
80103cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cda:	c7 04 24 e0 8a 10 80 	movl   $0x80108ae0,(%esp)
80103ce1:	e8 bb c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103ce6:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103ced:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cf6:	0f 82 00 ff ff ff    	jb     80103bfc <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103cfc:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80103d01:	85 c0                	test   %eax,%eax
80103d03:	75 1d                	jne    80103d22 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d05:	c7 05 20 ff 10 80 01 	movl   $0x1,0x8010ff20
80103d0c:	00 00 00 
    lapic = 0;
80103d0f:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
80103d16:	00 00 00 
    ioapicid = 0;
80103d19:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
    return;
80103d20:	eb 44                	jmp    80103d66 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d22:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d25:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d29:	84 c0                	test   %al,%al
80103d2b:	74 39                	je     80103d66 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d2d:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d34:	00 
80103d35:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d3c:	e8 12 fc ff ff       	call   80103953 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d41:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d48:	e8 dc fb ff ff       	call   80103929 <inb>
80103d4d:	83 c8 01             	or     $0x1,%eax
80103d50:	0f b6 c0             	movzbl %al,%eax
80103d53:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d57:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d5e:	e8 f0 fb ff ff       	call   80103953 <outb>
80103d63:	eb 01                	jmp    80103d66 <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103d65:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103d66:	c9                   	leave  
80103d67:	c3                   	ret    

80103d68 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d68:	55                   	push   %ebp
80103d69:	89 e5                	mov    %esp,%ebp
80103d6b:	83 ec 08             	sub    $0x8,%esp
80103d6e:	8b 55 08             	mov    0x8(%ebp),%edx
80103d71:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d74:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d78:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d7b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d7f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d83:	ee                   	out    %al,(%dx)
}
80103d84:	c9                   	leave  
80103d85:	c3                   	ret    

80103d86 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103d86:	55                   	push   %ebp
80103d87:	89 e5                	mov    %esp,%ebp
80103d89:	83 ec 0c             	sub    $0xc,%esp
80103d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103d93:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d97:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103d9d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103da1:	0f b6 c0             	movzbl %al,%eax
80103da4:	89 44 24 04          	mov    %eax,0x4(%esp)
80103da8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103daf:	e8 b4 ff ff ff       	call   80103d68 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103db4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103db8:	66 c1 e8 08          	shr    $0x8,%ax
80103dbc:	0f b6 c0             	movzbl %al,%eax
80103dbf:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dc3:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103dca:	e8 99 ff ff ff       	call   80103d68 <outb>
}
80103dcf:	c9                   	leave  
80103dd0:	c3                   	ret    

80103dd1 <picenable>:

void
picenable(int irq)
{
80103dd1:	55                   	push   %ebp
80103dd2:	89 e5                	mov    %esp,%ebp
80103dd4:	53                   	push   %ebx
80103dd5:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddb:	ba 01 00 00 00       	mov    $0x1,%edx
80103de0:	89 d3                	mov    %edx,%ebx
80103de2:	89 c1                	mov    %eax,%ecx
80103de4:	d3 e3                	shl    %cl,%ebx
80103de6:	89 d8                	mov    %ebx,%eax
80103de8:	89 c2                	mov    %eax,%edx
80103dea:	f7 d2                	not    %edx
80103dec:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103df3:	21 d0                	and    %edx,%eax
80103df5:	0f b7 c0             	movzwl %ax,%eax
80103df8:	89 04 24             	mov    %eax,(%esp)
80103dfb:	e8 86 ff ff ff       	call   80103d86 <picsetmask>
}
80103e00:	83 c4 04             	add    $0x4,%esp
80103e03:	5b                   	pop    %ebx
80103e04:	5d                   	pop    %ebp
80103e05:	c3                   	ret    

80103e06 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e06:	55                   	push   %ebp
80103e07:	89 e5                	mov    %esp,%ebp
80103e09:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e0c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e13:	00 
80103e14:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e1b:	e8 48 ff ff ff       	call   80103d68 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e20:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e27:	00 
80103e28:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e2f:	e8 34 ff ff ff       	call   80103d68 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e34:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e3b:	00 
80103e3c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e43:	e8 20 ff ff ff       	call   80103d68 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e48:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e4f:	00 
80103e50:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e57:	e8 0c ff ff ff       	call   80103d68 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e5c:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e63:	00 
80103e64:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e6b:	e8 f8 fe ff ff       	call   80103d68 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e70:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e77:	00 
80103e78:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e7f:	e8 e4 fe ff ff       	call   80103d68 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e84:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e8b:	00 
80103e8c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103e93:	e8 d0 fe ff ff       	call   80103d68 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103e98:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103e9f:	00 
80103ea0:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ea7:	e8 bc fe ff ff       	call   80103d68 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103eac:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103eb3:	00 
80103eb4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ebb:	e8 a8 fe ff ff       	call   80103d68 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103ec0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ec7:	00 
80103ec8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ecf:	e8 94 fe ff ff       	call   80103d68 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103ed4:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103edb:	00 
80103edc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ee3:	e8 80 fe ff ff       	call   80103d68 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ee8:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103eef:	00 
80103ef0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ef7:	e8 6c fe ff ff       	call   80103d68 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103efc:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f03:	00 
80103f04:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f0b:	e8 58 fe ff ff       	call   80103d68 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f10:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f17:	00 
80103f18:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f1f:	e8 44 fe ff ff       	call   80103d68 <outb>

  if(irqmask != 0xFFFF)
80103f24:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f2b:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f2f:	74 12                	je     80103f43 <picinit+0x13d>
    picsetmask(irqmask);
80103f31:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f38:	0f b7 c0             	movzwl %ax,%eax
80103f3b:	89 04 24             	mov    %eax,(%esp)
80103f3e:	e8 43 fe ff ff       	call   80103d86 <picsetmask>
}
80103f43:	c9                   	leave  
80103f44:	c3                   	ret    
80103f45:	00 00                	add    %al,(%eax)
	...

80103f48 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f48:	55                   	push   %ebp
80103f49:	89 e5                	mov    %esp,%ebp
80103f4b:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f4e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f55:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f58:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f61:	8b 10                	mov    (%eax),%edx
80103f63:	8b 45 08             	mov    0x8(%ebp),%eax
80103f66:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f68:	e8 bf d2 ff ff       	call   8010122c <filealloc>
80103f6d:	8b 55 08             	mov    0x8(%ebp),%edx
80103f70:	89 02                	mov    %eax,(%edx)
80103f72:	8b 45 08             	mov    0x8(%ebp),%eax
80103f75:	8b 00                	mov    (%eax),%eax
80103f77:	85 c0                	test   %eax,%eax
80103f79:	0f 84 c8 00 00 00    	je     80104047 <pipealloc+0xff>
80103f7f:	e8 a8 d2 ff ff       	call   8010122c <filealloc>
80103f84:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f87:	89 02                	mov    %eax,(%edx)
80103f89:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f8c:	8b 00                	mov    (%eax),%eax
80103f8e:	85 c0                	test   %eax,%eax
80103f90:	0f 84 b1 00 00 00    	je     80104047 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f96:	e8 74 ee ff ff       	call   80102e0f <kalloc>
80103f9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fa2:	0f 84 9e 00 00 00    	je     80104046 <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fab:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103fb2:	00 00 00 
  p->writeopen = 1;
80103fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb8:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103fbf:	00 00 00 
  p->nwrite = 0;
80103fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc5:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103fcc:	00 00 00 
  p->nread = 0;
80103fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd2:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103fd9:	00 00 00 
  initlock(&p->lock, "pipe");
80103fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdf:	c7 44 24 04 14 8b 10 	movl   $0x80108b14,0x4(%esp)
80103fe6:	80 
80103fe7:	89 04 24             	mov    %eax,(%esp)
80103fea:	e8 97 11 00 00       	call   80105186 <initlock>
  (*f0)->type = FD_PIPE;
80103fef:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff2:	8b 00                	mov    (%eax),%eax
80103ff4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffd:	8b 00                	mov    (%eax),%eax
80103fff:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104003:	8b 45 08             	mov    0x8(%ebp),%eax
80104006:	8b 00                	mov    (%eax),%eax
80104008:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010400c:	8b 45 08             	mov    0x8(%ebp),%eax
8010400f:	8b 00                	mov    (%eax),%eax
80104011:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104014:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104017:	8b 45 0c             	mov    0xc(%ebp),%eax
8010401a:	8b 00                	mov    (%eax),%eax
8010401c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104022:	8b 45 0c             	mov    0xc(%ebp),%eax
80104025:	8b 00                	mov    (%eax),%eax
80104027:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010402b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010402e:	8b 00                	mov    (%eax),%eax
80104030:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104034:	8b 45 0c             	mov    0xc(%ebp),%eax
80104037:	8b 00                	mov    (%eax),%eax
80104039:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010403c:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010403f:	b8 00 00 00 00       	mov    $0x0,%eax
80104044:	eb 43                	jmp    80104089 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104046:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104047:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010404b:	74 0b                	je     80104058 <pipealloc+0x110>
    kfree((char*)p);
8010404d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104050:	89 04 24             	mov    %eax,(%esp)
80104053:	e8 1e ed ff ff       	call   80102d76 <kfree>
  if(*f0)
80104058:	8b 45 08             	mov    0x8(%ebp),%eax
8010405b:	8b 00                	mov    (%eax),%eax
8010405d:	85 c0                	test   %eax,%eax
8010405f:	74 0d                	je     8010406e <pipealloc+0x126>
    fileclose(*f0);
80104061:	8b 45 08             	mov    0x8(%ebp),%eax
80104064:	8b 00                	mov    (%eax),%eax
80104066:	89 04 24             	mov    %eax,(%esp)
80104069:	e8 66 d2 ff ff       	call   801012d4 <fileclose>
  if(*f1)
8010406e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104071:	8b 00                	mov    (%eax),%eax
80104073:	85 c0                	test   %eax,%eax
80104075:	74 0d                	je     80104084 <pipealloc+0x13c>
    fileclose(*f1);
80104077:	8b 45 0c             	mov    0xc(%ebp),%eax
8010407a:	8b 00                	mov    (%eax),%eax
8010407c:	89 04 24             	mov    %eax,(%esp)
8010407f:	e8 50 d2 ff ff       	call   801012d4 <fileclose>
  return -1;
80104084:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104089:	c9                   	leave  
8010408a:	c3                   	ret    

8010408b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010408b:	55                   	push   %ebp
8010408c:	89 e5                	mov    %esp,%ebp
8010408e:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104091:	8b 45 08             	mov    0x8(%ebp),%eax
80104094:	89 04 24             	mov    %eax,(%esp)
80104097:	e8 0b 11 00 00       	call   801051a7 <acquire>
  if(writable){
8010409c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801040a0:	74 1f                	je     801040c1 <pipeclose+0x36>
    p->writeopen = 0;
801040a2:	8b 45 08             	mov    0x8(%ebp),%eax
801040a5:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801040ac:	00 00 00 
    wakeup(&p->nread);
801040af:	8b 45 08             	mov    0x8(%ebp),%eax
801040b2:	05 34 02 00 00       	add    $0x234,%eax
801040b7:	89 04 24             	mov    %eax,(%esp)
801040ba:	e8 5b 0e 00 00       	call   80104f1a <wakeup>
801040bf:	eb 1d                	jmp    801040de <pipeclose+0x53>
  } else {
    p->readopen = 0;
801040c1:	8b 45 08             	mov    0x8(%ebp),%eax
801040c4:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040cb:	00 00 00 
    wakeup(&p->nwrite);
801040ce:	8b 45 08             	mov    0x8(%ebp),%eax
801040d1:	05 38 02 00 00       	add    $0x238,%eax
801040d6:	89 04 24             	mov    %eax,(%esp)
801040d9:	e8 3c 0e 00 00       	call   80104f1a <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801040de:	8b 45 08             	mov    0x8(%ebp),%eax
801040e1:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040e7:	85 c0                	test   %eax,%eax
801040e9:	75 25                	jne    80104110 <pipeclose+0x85>
801040eb:	8b 45 08             	mov    0x8(%ebp),%eax
801040ee:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040f4:	85 c0                	test   %eax,%eax
801040f6:	75 18                	jne    80104110 <pipeclose+0x85>
    release(&p->lock);
801040f8:	8b 45 08             	mov    0x8(%ebp),%eax
801040fb:	89 04 24             	mov    %eax,(%esp)
801040fe:	e8 06 11 00 00       	call   80105209 <release>
    kfree((char*)p);
80104103:	8b 45 08             	mov    0x8(%ebp),%eax
80104106:	89 04 24             	mov    %eax,(%esp)
80104109:	e8 68 ec ff ff       	call   80102d76 <kfree>
8010410e:	eb 0b                	jmp    8010411b <pipeclose+0x90>
  } else
    release(&p->lock);
80104110:	8b 45 08             	mov    0x8(%ebp),%eax
80104113:	89 04 24             	mov    %eax,(%esp)
80104116:	e8 ee 10 00 00       	call   80105209 <release>
}
8010411b:	c9                   	leave  
8010411c:	c3                   	ret    

8010411d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010411d:	55                   	push   %ebp
8010411e:	89 e5                	mov    %esp,%ebp
80104120:	53                   	push   %ebx
80104121:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104124:	8b 45 08             	mov    0x8(%ebp),%eax
80104127:	89 04 24             	mov    %eax,(%esp)
8010412a:	e8 78 10 00 00       	call   801051a7 <acquire>
  for(i = 0; i < n; i++){
8010412f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104136:	e9 a6 00 00 00       	jmp    801041e1 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010413b:	8b 45 08             	mov    0x8(%ebp),%eax
8010413e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104144:	85 c0                	test   %eax,%eax
80104146:	74 0d                	je     80104155 <pipewrite+0x38>
80104148:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010414e:	8b 40 24             	mov    0x24(%eax),%eax
80104151:	85 c0                	test   %eax,%eax
80104153:	74 15                	je     8010416a <pipewrite+0x4d>
        release(&p->lock);
80104155:	8b 45 08             	mov    0x8(%ebp),%eax
80104158:	89 04 24             	mov    %eax,(%esp)
8010415b:	e8 a9 10 00 00       	call   80105209 <release>
        return -1;
80104160:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104165:	e9 9d 00 00 00       	jmp    80104207 <pipewrite+0xea>
      }
      wakeup(&p->nread);
8010416a:	8b 45 08             	mov    0x8(%ebp),%eax
8010416d:	05 34 02 00 00       	add    $0x234,%eax
80104172:	89 04 24             	mov    %eax,(%esp)
80104175:	e8 a0 0d 00 00       	call   80104f1a <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010417a:	8b 45 08             	mov    0x8(%ebp),%eax
8010417d:	8b 55 08             	mov    0x8(%ebp),%edx
80104180:	81 c2 38 02 00 00    	add    $0x238,%edx
80104186:	89 44 24 04          	mov    %eax,0x4(%esp)
8010418a:	89 14 24             	mov    %edx,(%esp)
8010418d:	e8 ac 0c 00 00       	call   80104e3e <sleep>
80104192:	eb 01                	jmp    80104195 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104194:	90                   	nop
80104195:	8b 45 08             	mov    0x8(%ebp),%eax
80104198:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010419e:	8b 45 08             	mov    0x8(%ebp),%eax
801041a1:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041a7:	05 00 02 00 00       	add    $0x200,%eax
801041ac:	39 c2                	cmp    %eax,%edx
801041ae:	74 8b                	je     8010413b <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801041b0:	8b 45 08             	mov    0x8(%ebp),%eax
801041b3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041b9:	89 c3                	mov    %eax,%ebx
801041bb:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801041c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041c4:	03 55 0c             	add    0xc(%ebp),%edx
801041c7:	0f b6 0a             	movzbl (%edx),%ecx
801041ca:	8b 55 08             	mov    0x8(%ebp),%edx
801041cd:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
801041d1:	8d 50 01             	lea    0x1(%eax),%edx
801041d4:	8b 45 08             	mov    0x8(%ebp),%eax
801041d7:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801041dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e4:	3b 45 10             	cmp    0x10(%ebp),%eax
801041e7:	7c ab                	jl     80104194 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801041e9:	8b 45 08             	mov    0x8(%ebp),%eax
801041ec:	05 34 02 00 00       	add    $0x234,%eax
801041f1:	89 04 24             	mov    %eax,(%esp)
801041f4:	e8 21 0d 00 00       	call   80104f1a <wakeup>
  release(&p->lock);
801041f9:	8b 45 08             	mov    0x8(%ebp),%eax
801041fc:	89 04 24             	mov    %eax,(%esp)
801041ff:	e8 05 10 00 00       	call   80105209 <release>
  return n;
80104204:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104207:	83 c4 24             	add    $0x24,%esp
8010420a:	5b                   	pop    %ebx
8010420b:	5d                   	pop    %ebp
8010420c:	c3                   	ret    

8010420d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010420d:	55                   	push   %ebp
8010420e:	89 e5                	mov    %esp,%ebp
80104210:	53                   	push   %ebx
80104211:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104214:	8b 45 08             	mov    0x8(%ebp),%eax
80104217:	89 04 24             	mov    %eax,(%esp)
8010421a:	e8 88 0f 00 00       	call   801051a7 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010421f:	eb 3a                	jmp    8010425b <piperead+0x4e>
    if(proc->killed){
80104221:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104227:	8b 40 24             	mov    0x24(%eax),%eax
8010422a:	85 c0                	test   %eax,%eax
8010422c:	74 15                	je     80104243 <piperead+0x36>
      release(&p->lock);
8010422e:	8b 45 08             	mov    0x8(%ebp),%eax
80104231:	89 04 24             	mov    %eax,(%esp)
80104234:	e8 d0 0f 00 00       	call   80105209 <release>
      return -1;
80104239:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010423e:	e9 b6 00 00 00       	jmp    801042f9 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104243:	8b 45 08             	mov    0x8(%ebp),%eax
80104246:	8b 55 08             	mov    0x8(%ebp),%edx
80104249:	81 c2 34 02 00 00    	add    $0x234,%edx
8010424f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104253:	89 14 24             	mov    %edx,(%esp)
80104256:	e8 e3 0b 00 00       	call   80104e3e <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010425b:	8b 45 08             	mov    0x8(%ebp),%eax
8010425e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104264:	8b 45 08             	mov    0x8(%ebp),%eax
80104267:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010426d:	39 c2                	cmp    %eax,%edx
8010426f:	75 0d                	jne    8010427e <piperead+0x71>
80104271:	8b 45 08             	mov    0x8(%ebp),%eax
80104274:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010427a:	85 c0                	test   %eax,%eax
8010427c:	75 a3                	jne    80104221 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010427e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104285:	eb 49                	jmp    801042d0 <piperead+0xc3>
    if(p->nread == p->nwrite)
80104287:	8b 45 08             	mov    0x8(%ebp),%eax
8010428a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104290:	8b 45 08             	mov    0x8(%ebp),%eax
80104293:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104299:	39 c2                	cmp    %eax,%edx
8010429b:	74 3d                	je     801042da <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010429d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a0:	89 c2                	mov    %eax,%edx
801042a2:	03 55 0c             	add    0xc(%ebp),%edx
801042a5:	8b 45 08             	mov    0x8(%ebp),%eax
801042a8:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042ae:	89 c3                	mov    %eax,%ebx
801042b0:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801042b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801042b9:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
801042be:	88 0a                	mov    %cl,(%edx)
801042c0:	8d 50 01             	lea    0x1(%eax),%edx
801042c3:	8b 45 08             	mov    0x8(%ebp),%eax
801042c6:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042cc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d3:	3b 45 10             	cmp    0x10(%ebp),%eax
801042d6:	7c af                	jl     80104287 <piperead+0x7a>
801042d8:	eb 01                	jmp    801042db <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
801042da:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801042db:	8b 45 08             	mov    0x8(%ebp),%eax
801042de:	05 38 02 00 00       	add    $0x238,%eax
801042e3:	89 04 24             	mov    %eax,(%esp)
801042e6:	e8 2f 0c 00 00       	call   80104f1a <wakeup>
  release(&p->lock);
801042eb:	8b 45 08             	mov    0x8(%ebp),%eax
801042ee:	89 04 24             	mov    %eax,(%esp)
801042f1:	e8 13 0f 00 00       	call   80105209 <release>
  return i;
801042f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042f9:	83 c4 24             	add    $0x24,%esp
801042fc:	5b                   	pop    %ebx
801042fd:	5d                   	pop    %ebp
801042fe:	c3                   	ret    
	...

80104300 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104300:	55                   	push   %ebp
80104301:	89 e5                	mov    %esp,%ebp
80104303:	53                   	push   %ebx
80104304:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104307:	9c                   	pushf  
80104308:	5b                   	pop    %ebx
80104309:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010430c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010430f:	83 c4 10             	add    $0x10,%esp
80104312:	5b                   	pop    %ebx
80104313:	5d                   	pop    %ebp
80104314:	c3                   	ret    

80104315 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104315:	55                   	push   %ebp
80104316:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104318:	fb                   	sti    
}
80104319:	5d                   	pop    %ebp
8010431a:	c3                   	ret    

8010431b <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);
void
pinit(void)
{
8010431b:	55                   	push   %ebp
8010431c:	89 e5                	mov    %esp,%ebp
8010431e:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104321:	c7 44 24 04 19 8b 10 	movl   $0x80108b19,0x4(%esp)
80104328:	80 
80104329:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104330:	e8 51 0e 00 00       	call   80105186 <initlock>
}
80104335:	c9                   	leave  
80104336:	c3                   	ret    

80104337 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104337:	55                   	push   %ebp
80104338:	89 e5                	mov    %esp,%ebp
8010433a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010433d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104344:	e8 5e 0e 00 00       	call   801051a7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104349:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104350:	eb 11                	jmp    80104363 <allocproc+0x2c>
    if(p->state == UNUSED)
80104352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104355:	8b 40 0c             	mov    0xc(%eax),%eax
80104358:	85 c0                	test   %eax,%eax
8010435a:	74 26                	je     80104382 <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010435c:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104363:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
8010436a:	72 e6                	jb     80104352 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010436c:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104373:	e8 91 0e 00 00       	call   80105209 <release>
  return 0;
80104378:	b8 00 00 00 00       	mov    $0x0,%eax
8010437d:	e9 b5 00 00 00       	jmp    80104437 <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104382:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104386:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010438d:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104392:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104395:	89 42 10             	mov    %eax,0x10(%edx)
80104398:	83 c0 01             	add    $0x1,%eax
8010439b:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
801043a0:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801043a7:	e8 5d 0e 00 00       	call   80105209 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043ac:	e8 5e ea ff ff       	call   80102e0f <kalloc>
801043b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043b4:	89 42 08             	mov    %eax,0x8(%edx)
801043b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ba:	8b 40 08             	mov    0x8(%eax),%eax
801043bd:	85 c0                	test   %eax,%eax
801043bf:	75 11                	jne    801043d2 <allocproc+0x9b>
    p->state = UNUSED;
801043c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043cb:	b8 00 00 00 00       	mov    $0x0,%eax
801043d0:	eb 65                	jmp    80104437 <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
801043d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d5:	8b 40 08             	mov    0x8(%eax),%eax
801043d8:	05 00 10 00 00       	add    $0x1000,%eax
801043dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043e0:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801043e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043ea:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801043ed:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801043f1:	ba bc 68 10 80       	mov    $0x801068bc,%edx
801043f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043f9:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801043fb:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801043ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104402:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104405:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010440e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104415:	00 
80104416:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010441d:	00 
8010441e:	89 04 24             	mov    %eax,(%esp)
80104421:	e8 d0 0f 00 00       	call   801053f6 <memset>
  p->context->eip = (uint)forkret;
80104426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104429:	8b 40 1c             	mov    0x1c(%eax),%eax
8010442c:	ba 12 4e 10 80       	mov    $0x80104e12,%edx
80104431:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104434:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104437:	c9                   	leave  
80104438:	c3                   	ret    

80104439 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104439:	55                   	push   %ebp
8010443a:	89 e5                	mov    %esp,%ebp
8010443c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010443f:	e8 f3 fe ff ff       	call   80104337 <allocproc>
80104444:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104447:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444a:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm(kalloc)) == 0)
8010444f:	c7 04 24 0f 2e 10 80 	movl   $0x80102e0f,(%esp)
80104456:	e8 a2 3b 00 00       	call   80107ffd <setupkvm>
8010445b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010445e:	89 42 04             	mov    %eax,0x4(%edx)
80104461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104464:	8b 40 04             	mov    0x4(%eax),%eax
80104467:	85 c0                	test   %eax,%eax
80104469:	75 0c                	jne    80104477 <userinit+0x3e>
    panic("userinit: out of memory?");
8010446b:	c7 04 24 20 8b 10 80 	movl   $0x80108b20,(%esp)
80104472:	e8 c6 c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104477:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010447c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447f:	8b 40 04             	mov    0x4(%eax),%eax
80104482:	89 54 24 08          	mov    %edx,0x8(%esp)
80104486:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
8010448d:	80 
8010448e:	89 04 24             	mov    %eax,(%esp)
80104491:	e8 bf 3d 00 00       	call   80108255 <inituvm>
  p->sz = PGSIZE;
80104496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104499:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010449f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a2:	8b 40 18             	mov    0x18(%eax),%eax
801044a5:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044ac:	00 
801044ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044b4:	00 
801044b5:	89 04 24             	mov    %eax,(%esp)
801044b8:	e8 39 0f 00 00       	call   801053f6 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c0:	8b 40 18             	mov    0x18(%eax),%eax
801044c3:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cc:	8b 40 18             	mov    0x18(%eax),%eax
801044cf:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d8:	8b 40 18             	mov    0x18(%eax),%eax
801044db:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044de:	8b 52 18             	mov    0x18(%edx),%edx
801044e1:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044e5:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801044e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ec:	8b 40 18             	mov    0x18(%eax),%eax
801044ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044f2:	8b 52 18             	mov    0x18(%edx),%edx
801044f5:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044f9:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801044fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104500:	8b 40 18             	mov    0x18(%eax),%eax
80104503:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010450a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450d:	8b 40 18             	mov    0x18(%eax),%eax
80104510:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451a:	8b 40 18             	mov    0x18(%eax),%eax
8010451d:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104527:	83 c0 6c             	add    $0x6c,%eax
8010452a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104531:	00 
80104532:	c7 44 24 04 39 8b 10 	movl   $0x80108b39,0x4(%esp)
80104539:	80 
8010453a:	89 04 24             	mov    %eax,(%esp)
8010453d:	e8 e4 10 00 00       	call   80105626 <safestrcpy>
  p->cwd = namei("/");
80104542:	c7 04 24 42 8b 10 80 	movl   $0x80108b42,(%esp)
80104549:	e8 cc e1 ff ff       	call   8010271a <namei>
8010454e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104551:	89 42 68             	mov    %eax,0x68(%edx)
  p->state = RUNNABLE;
80104554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104557:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
8010455e:	c9                   	leave  
8010455f:	c3                   	ret    

80104560 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104560:	55                   	push   %ebp
80104561:	89 e5                	mov    %esp,%ebp
80104563:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104566:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010456c:	8b 00                	mov    (%eax),%eax
8010456e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104571:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104575:	7e 34                	jle    801045ab <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104577:	8b 45 08             	mov    0x8(%ebp),%eax
8010457a:	89 c2                	mov    %eax,%edx
8010457c:	03 55 f4             	add    -0xc(%ebp),%edx
8010457f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104585:	8b 40 04             	mov    0x4(%eax),%eax
80104588:	89 54 24 08          	mov    %edx,0x8(%esp)
8010458c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010458f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104593:	89 04 24             	mov    %eax,(%esp)
80104596:	e8 34 3e 00 00       	call   801083cf <allocuvm>
8010459b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010459e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045a2:	75 41                	jne    801045e5 <growproc+0x85>
      return -1;
801045a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045a9:	eb 58                	jmp    80104603 <growproc+0xa3>
  } else if(n < 0){
801045ab:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045af:	79 34                	jns    801045e5 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801045b1:	8b 45 08             	mov    0x8(%ebp),%eax
801045b4:	89 c2                	mov    %eax,%edx
801045b6:	03 55 f4             	add    -0xc(%ebp),%edx
801045b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045bf:	8b 40 04             	mov    0x4(%eax),%eax
801045c2:	89 54 24 08          	mov    %edx,0x8(%esp)
801045c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045c9:	89 54 24 04          	mov    %edx,0x4(%esp)
801045cd:	89 04 24             	mov    %eax,(%esp)
801045d0:	e8 d4 3e 00 00       	call   801084a9 <deallocuvm>
801045d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045dc:	75 07                	jne    801045e5 <growproc+0x85>
      return -1;
801045de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045e3:	eb 1e                	jmp    80104603 <growproc+0xa3>
  }
  proc->sz = sz;
801045e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ee:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801045f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045f6:	89 04 24             	mov    %eax,(%esp)
801045f9:	e8 f0 3a 00 00       	call   801080ee <switchuvm>
  return 0;
801045fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104603:	c9                   	leave  
80104604:	c3                   	ret    

80104605 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104605:	55                   	push   %ebp
80104606:	89 e5                	mov    %esp,%ebp
80104608:	57                   	push   %edi
80104609:	56                   	push   %esi
8010460a:	53                   	push   %ebx
8010460b:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010460e:	e8 24 fd ff ff       	call   80104337 <allocproc>
80104613:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104616:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010461a:	75 0a                	jne    80104626 <fork+0x21>
    return -1;
8010461c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104621:	e9 6c 01 00 00       	jmp    80104792 <fork+0x18d>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104626:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010462c:	8b 10                	mov    (%eax),%edx
8010462e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104634:	8b 40 04             	mov    0x4(%eax),%eax
80104637:	89 54 24 04          	mov    %edx,0x4(%esp)
8010463b:	89 04 24             	mov    %eax,(%esp)
8010463e:	e8 f6 3f 00 00       	call   80108639 <copyuvm>
80104643:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104646:	89 42 04             	mov    %eax,0x4(%edx)
80104649:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010464c:	8b 40 04             	mov    0x4(%eax),%eax
8010464f:	85 c0                	test   %eax,%eax
80104651:	75 2c                	jne    8010467f <fork+0x7a>
    kfree(np->kstack);
80104653:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104656:	8b 40 08             	mov    0x8(%eax),%eax
80104659:	89 04 24             	mov    %eax,(%esp)
8010465c:	e8 15 e7 ff ff       	call   80102d76 <kfree>
    np->kstack = 0;
80104661:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104664:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010466b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010466e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104675:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010467a:	e9 13 01 00 00       	jmp    80104792 <fork+0x18d>
  }
  np->sz = proc->sz;
8010467f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104685:	8b 10                	mov    (%eax),%edx
80104687:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010468a:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
8010468c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104693:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104696:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104699:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010469c:	8b 50 18             	mov    0x18(%eax),%edx
8010469f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046a5:	8b 40 18             	mov    0x18(%eax),%eax
801046a8:	89 c3                	mov    %eax,%ebx
801046aa:	b8 13 00 00 00       	mov    $0x13,%eax
801046af:	89 d7                	mov    %edx,%edi
801046b1:	89 de                	mov    %ebx,%esi
801046b3:	89 c1                	mov    %eax,%ecx
801046b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ba:	8b 40 18             	mov    0x18(%eax),%eax
801046bd:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801046cb:	eb 3d                	jmp    8010470a <fork+0x105>
    if(proc->ofile[i])
801046cd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046d6:	83 c2 08             	add    $0x8,%edx
801046d9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046dd:	85 c0                	test   %eax,%eax
801046df:	74 25                	je     80104706 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801046e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046ea:	83 c2 08             	add    $0x8,%edx
801046ed:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046f1:	89 04 24             	mov    %eax,(%esp)
801046f4:	e8 93 cb ff ff       	call   8010128c <filedup>
801046f9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046fc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801046ff:	83 c1 08             	add    $0x8,%ecx
80104702:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104706:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010470a:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010470e:	7e bd                	jle    801046cd <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104710:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104716:	8b 40 68             	mov    0x68(%eax),%eax
80104719:	89 04 24             	mov    %eax,(%esp)
8010471c:	e8 25 d4 ff ff       	call   80101b46 <idup>
80104721:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104724:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
80104727:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010472a:	8b 40 10             	mov    0x10(%eax),%eax
8010472d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
80104730:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104733:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010473a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104740:	8d 50 6c             	lea    0x6c(%eax),%edx
80104743:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104746:	83 c0 6c             	add    $0x6c,%eax
80104749:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104750:	00 
80104751:	89 54 24 04          	mov    %edx,0x4(%esp)
80104755:	89 04 24             	mov    %eax,(%esp)
80104758:	e8 c9 0e 00 00       	call   80105626 <safestrcpy>
  acquire(&tickslock);
8010475d:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104764:	e8 3e 0a 00 00       	call   801051a7 <acquire>
  np->ctime = ticks;
80104769:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
8010476e:	89 c2                	mov    %eax,%edx
80104770:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104773:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&tickslock);
80104776:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
8010477d:	e8 87 0a 00 00       	call   80105209 <release>
  np->rtime = 0;
80104782:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104785:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
8010478c:	00 00 00 
    case _3Q:
      np->priority = HIGH;
      np->qvalue = 0;
      break;
  }
  return pid;
8010478f:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104792:	83 c4 2c             	add    $0x2c,%esp
80104795:	5b                   	pop    %ebx
80104796:	5e                   	pop    %esi
80104797:	5f                   	pop    %edi
80104798:	5d                   	pop    %ebp
80104799:	c3                   	ret    

8010479a <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010479a:	55                   	push   %ebp
8010479b:	89 e5                	mov    %esp,%ebp
8010479d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;
  
  if(proc == initproc)
801047a0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047a7:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801047ac:	39 c2                	cmp    %eax,%edx
801047ae:	75 0c                	jne    801047bc <exit+0x22>
    panic("init exiting");
801047b0:	c7 04 24 44 8b 10 80 	movl   $0x80108b44,(%esp)
801047b7:	e8 81 bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047bc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047c3:	eb 44                	jmp    80104809 <exit+0x6f>
    if(proc->ofile[fd]){
801047c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047ce:	83 c2 08             	add    $0x8,%edx
801047d1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047d5:	85 c0                	test   %eax,%eax
801047d7:	74 2c                	je     80104805 <exit+0x6b>
      fileclose(proc->ofile[fd]);
801047d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047e2:	83 c2 08             	add    $0x8,%edx
801047e5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047e9:	89 04 24             	mov    %eax,(%esp)
801047ec:	e8 e3 ca ff ff       	call   801012d4 <fileclose>
      proc->ofile[fd] = 0;
801047f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047fa:	83 c2 08             	add    $0x8,%edx
801047fd:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104804:	00 
  
  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104805:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104809:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010480d:	7e b6                	jle    801047c5 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
8010480f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104815:	8b 40 68             	mov    0x68(%eax),%eax
80104818:	89 04 24             	mov    %eax,(%esp)
8010481b:	e8 0b d5 ff ff       	call   80101d2b <iput>
  proc->cwd = 0;
80104820:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104826:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010482d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104834:	e8 6e 09 00 00       	call   801051a7 <acquire>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104839:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483f:	8b 40 14             	mov    0x14(%eax),%eax
80104842:	89 04 24             	mov    %eax,(%esp)
80104845:	e8 8f 06 00 00       	call   80104ed9 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010484a:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104851:	eb 3b                	jmp    8010488e <exit+0xf4>
    if(p->parent == proc){
80104853:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104856:	8b 50 14             	mov    0x14(%eax),%edx
80104859:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010485f:	39 c2                	cmp    %eax,%edx
80104861:	75 24                	jne    80104887 <exit+0xed>
      p->parent = initproc;
80104863:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010486c:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010486f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104872:	8b 40 0c             	mov    0xc(%eax),%eax
80104875:	83 f8 05             	cmp    $0x5,%eax
80104878:	75 0d                	jne    80104887 <exit+0xed>
        wakeup1(initproc);
8010487a:	a1 48 b6 10 80       	mov    0x8010b648,%eax
8010487f:	89 04 24             	mov    %eax,(%esp)
80104882:	e8 52 06 00 00       	call   80104ed9 <wakeup1>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104887:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
8010488e:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104895:	72 bc                	jb     80104853 <exit+0xb9>
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }
  // Jump into the scheduler, never to return.
  proc->priority = -1;
80104897:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010489d:	c7 80 8c 00 00 00 ff 	movl   $0xffffffff,0x8c(%eax)
801048a4:	ff ff ff 
  acquire(&tickslock);
801048a7:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801048ae:	e8 f4 08 00 00       	call   801051a7 <acquire>
  proc->etime = ticks;
801048b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b9:	8b 15 c0 2c 11 80    	mov    0x80112cc0,%edx
801048bf:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  release(&tickslock);
801048c5:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801048cc:	e8 38 09 00 00       	call   80105209 <release>
  proc->state = ZOMBIE;
801048d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d7:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048de:	e8 4b 04 00 00       	call   80104d2e <sched>
  panic("zombie exit");
801048e3:	c7 04 24 51 8b 10 80 	movl   $0x80108b51,(%esp)
801048ea:	e8 4e bc ff ff       	call   8010053d <panic>

801048ef <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801048ef:	55                   	push   %ebp
801048f0:	89 e5                	mov    %esp,%ebp
801048f2:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801048f5:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801048fc:	e8 a6 08 00 00       	call   801051a7 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104901:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104908:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
8010490f:	e9 9d 00 00 00       	jmp    801049b1 <wait+0xc2>
      if(p->parent != proc)
80104914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104917:	8b 50 14             	mov    0x14(%eax),%edx
8010491a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104920:	39 c2                	cmp    %eax,%edx
80104922:	0f 85 81 00 00 00    	jne    801049a9 <wait+0xba>
        continue;
      havekids = 1;
80104928:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010492f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104932:	8b 40 0c             	mov    0xc(%eax),%eax
80104935:	83 f8 05             	cmp    $0x5,%eax
80104938:	75 70                	jne    801049aa <wait+0xbb>
        // Found one.
        pid = p->pid;
8010493a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493d:	8b 40 10             	mov    0x10(%eax),%eax
80104940:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104946:	8b 40 08             	mov    0x8(%eax),%eax
80104949:	89 04 24             	mov    %eax,(%esp)
8010494c:	e8 25 e4 ff ff       	call   80102d76 <kfree>
        p->kstack = 0;
80104951:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104954:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010495b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495e:	8b 40 04             	mov    0x4(%eax),%eax
80104961:	89 04 24             	mov    %eax,(%esp)
80104964:	e8 fc 3b 00 00       	call   80108565 <freevm>
        p->state = UNUSED;
80104969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104976:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010497d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104980:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498a:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010498e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104991:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104998:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010499f:	e8 65 08 00 00       	call   80105209 <release>
        return pid;
801049a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049a7:	eb 56                	jmp    801049ff <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801049a9:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049aa:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801049b1:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
801049b8:	0f 82 56 ff ff ff    	jb     80104914 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049c2:	74 0d                	je     801049d1 <wait+0xe2>
801049c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ca:	8b 40 24             	mov    0x24(%eax),%eax
801049cd:	85 c0                	test   %eax,%eax
801049cf:	74 13                	je     801049e4 <wait+0xf5>
      release(&ptable.lock);
801049d1:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801049d8:	e8 2c 08 00 00       	call   80105209 <release>
      return -1;
801049dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049e2:	eb 1b                	jmp    801049ff <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801049e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ea:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
801049f1:	80 
801049f2:	89 04 24             	mov    %eax,(%esp)
801049f5:	e8 44 04 00 00       	call   80104e3e <sleep>
  }
801049fa:	e9 02 ff ff ff       	jmp    80104901 <wait+0x12>
}
801049ff:	c9                   	leave  
80104a00:	c3                   	ret    

80104a01 <wait2>:

int
wait2(int *wtime, int *rtime)
{
80104a01:	55                   	push   %ebp
80104a02:	89 e5                	mov    %esp,%ebp
80104a04:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a07:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104a0e:	e8 94 07 00 00       	call   801051a7 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a1a:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104a21:	e9 d0 00 00 00       	jmp    80104af6 <wait2+0xf5>
      if(p->parent != proc)
80104a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a29:	8b 50 14             	mov    0x14(%eax),%edx
80104a2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a32:	39 c2                	cmp    %eax,%edx
80104a34:	0f 85 b4 00 00 00    	jne    80104aee <wait2+0xed>
        continue;
      havekids = 1;
80104a3a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a44:	8b 40 0c             	mov    0xc(%eax),%eax
80104a47:	83 f8 05             	cmp    $0x5,%eax
80104a4a:	0f 85 9f 00 00 00    	jne    80104aef <wait2+0xee>
	*rtime = p->rtime;
80104a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a53:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104a59:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a5c:	89 10                	mov    %edx,(%eax)
	*wtime = p->etime - p->ctime - p->rtime;
80104a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a61:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a6a:	8b 40 7c             	mov    0x7c(%eax),%eax
80104a6d:	29 c2                	sub    %eax,%edx
80104a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a72:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104a78:	29 c2                	sub    %eax,%edx
80104a7a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a7d:	89 10                	mov    %edx,(%eax)
	// Found one.
        pid = p->pid;
80104a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a82:	8b 40 10             	mov    0x10(%eax),%eax
80104a85:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8b:	8b 40 08             	mov    0x8(%eax),%eax
80104a8e:	89 04 24             	mov    %eax,(%esp)
80104a91:	e8 e0 e2 ff ff       	call   80102d76 <kfree>
        p->kstack = 0;
80104a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a99:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa3:	8b 40 04             	mov    0x4(%eax),%eax
80104aa6:	89 04 24             	mov    %eax,(%esp)
80104aa9:	e8 b7 3a 00 00       	call   80108565 <freevm>
        p->state = UNUSED;
80104aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abb:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac5:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acf:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad6:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104add:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ae4:	e8 20 07 00 00       	call   80105209 <release>
        return pid;
80104ae9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aec:	eb 56                	jmp    80104b44 <wait2+0x143>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104aee:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aef:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104af6:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104afd:	0f 82 23 ff ff ff    	jb     80104a26 <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b03:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b07:	74 0d                	je     80104b16 <wait2+0x115>
80104b09:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b0f:	8b 40 24             	mov    0x24(%eax),%eax
80104b12:	85 c0                	test   %eax,%eax
80104b14:	74 13                	je     80104b29 <wait2+0x128>
      release(&ptable.lock);
80104b16:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104b1d:	e8 e7 06 00 00       	call   80105209 <release>
      return -1;
80104b22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b27:	eb 1b                	jmp    80104b44 <wait2+0x143>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b29:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b2f:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104b36:	80 
80104b37:	89 04 24             	mov    %eax,(%esp)
80104b3a:	e8 ff 02 00 00       	call   80104e3e <sleep>
  }
80104b3f:	e9 cf fe ff ff       	jmp    80104a13 <wait2+0x12>
  
  
  return proc->pid;
}
80104b44:	c9                   	leave  
80104b45:	c3                   	ret    

80104b46 <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104b46:	55                   	push   %ebp
80104b47:	89 e5                	mov    %esp,%ebp
80104b49:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104b4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b52:	8b 40 18             	mov    0x18(%eax),%eax
80104b55:	8b 40 44             	mov    0x44(%eax),%eax
80104b58:	89 c2                	mov    %eax,%edx
80104b5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b60:	8b 40 04             	mov    0x4(%eax),%eax
80104b63:	89 54 24 04          	mov    %edx,0x4(%esp)
80104b67:	89 04 24             	mov    %eax,(%esp)
80104b6a:	e8 db 3b 00 00       	call   8010874a <uva2ka>
80104b6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104b72:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b78:	8b 40 18             	mov    0x18(%eax),%eax
80104b7b:	8b 40 44             	mov    0x44(%eax),%eax
80104b7e:	25 ff 0f 00 00       	and    $0xfff,%eax
80104b83:	85 c0                	test   %eax,%eax
80104b85:	75 0c                	jne    80104b93 <register_handler+0x4d>
    panic("esp_offset == 0");
80104b87:	c7 04 24 5d 8b 10 80 	movl   $0x80108b5d,(%esp)
80104b8e:	e8 aa b9 ff ff       	call   8010053d <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
80104b93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b99:	8b 40 18             	mov    0x18(%eax),%eax
80104b9c:	8b 40 44             	mov    0x44(%eax),%eax
80104b9f:	83 e8 04             	sub    $0x4,%eax
80104ba2:	25 ff 0f 00 00       	and    $0xfff,%eax
80104ba7:	03 45 f4             	add    -0xc(%ebp),%eax
          = proc->tf->eip;
80104baa:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104bb1:	8b 52 18             	mov    0x18(%edx),%edx
80104bb4:	8b 52 38             	mov    0x38(%edx),%edx
80104bb7:	89 10                	mov    %edx,(%eax)
  proc->tf->esp -= 4;
80104bb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bbf:	8b 40 18             	mov    0x18(%eax),%eax
80104bc2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104bc9:	8b 52 18             	mov    0x18(%edx),%edx
80104bcc:	8b 52 44             	mov    0x44(%edx),%edx
80104bcf:	83 ea 04             	sub    $0x4,%edx
80104bd2:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104bd5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bdb:	8b 40 18             	mov    0x18(%eax),%eax
80104bde:	8b 55 08             	mov    0x8(%ebp),%edx
80104be1:	89 50 38             	mov    %edx,0x38(%eax)
}
80104be4:	c9                   	leave  
80104be5:	c3                   	ret    

80104be6 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104be6:	55                   	push   %ebp
80104be7:	89 e5                	mov    %esp,%ebp
80104be9:	83 ec 48             	sub    $0x48,%esp
  struct proc *p;
  struct proc *medium;
  struct proc *high;
  struct proc *head = 0;
80104bec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  struct proc *t = ptable.proc;
80104bf3:	c7 45 ec 74 ff 10 80 	movl   $0x8010ff74,-0x14(%ebp)
  uint grt_min;
  
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104bfa:	e8 16 f7 ff ff       	call   80104315 <sti>
    highflag = 0;
80104bff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    mediumflag = 0;
80104c06:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    lowflag = 0;
80104c0d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    frr_min = 0;
80104c14:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    grt_min = 0;
80104c1b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    
    if(head && p==head)
80104c22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c26:	74 17                	je     80104c3f <scheduler+0x59>
80104c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104c2e:	75 0f                	jne    80104c3f <scheduler+0x59>
      t = ++head;
80104c30:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
80104c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104c3d:	eb 0c                	jmp    80104c4b <scheduler+0x65>
    else if(head)
80104c3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c43:	74 06                	je     80104c4b <scheduler+0x65>
      t = head;
80104c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c48:	89 45 ec             	mov    %eax,-0x14(%ebp)
    
    acquire(&tickslock);
80104c4b:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104c52:	e8 50 05 00 00       	call   801051a7 <acquire>
    currentime = ticks;
80104c57:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
80104c5c:	89 45 d0             	mov    %eax,-0x30(%ebp)
    release(&tickslock);  
80104c5f:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80104c66:	e8 9e 05 00 00       	call   80105209 <release>
    int i=0;
80104c6b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    acquire(&ptable.lock); 
80104c72:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104c79:	e8 29 05 00 00       	call   801051a7 <acquire>
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104c7e:	e9 90 00 00 00       	jmp    80104d13 <scheduler+0x12d>
    {
      if(t >= &ptable.proc[NPROC])
80104c83:	81 7d ec 74 24 11 80 	cmpl   $0x80112474,-0x14(%ebp)
80104c8a:	72 07                	jb     80104c93 <scheduler+0xad>
	t = ptable.proc;
80104c8c:	c7 45 ec 74 ff 10 80 	movl   $0x8010ff74,-0x14(%ebp)
      if(t->state != RUNNABLE)
80104c93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c96:	8b 40 0c             	mov    0xc(%eax),%eax
80104c99:	83 f8 03             	cmp    $0x3,%eax
80104c9c:	74 09                	je     80104ca7 <scheduler+0xc1>
      {
	t++;
80104c9e:	81 45 ec 94 00 00 00 	addl   $0x94,-0x14(%ebp)
	continue;
80104ca5:	eb 68                	jmp    80104d0f <scheduler+0x129>
      }
      switch(SCHEDFLAG)
      {
	default:
	  p = t;
80104ca7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104caa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	  proc = p;
80104cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb0:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
	  switchuvm(p);
80104cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb9:	89 04 24             	mov    %eax,(%esp)
80104cbc:	e8 2d 34 00 00       	call   801080ee <switchuvm>
	  p->state = RUNNING;
80104cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc4:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	  p->quanta = QUANTA;
80104ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cce:	c7 80 88 00 00 00 05 	movl   $0x5,0x88(%eax)
80104cd5:	00 00 00 
	  swtch(&cpu->scheduler, proc->context);
80104cd8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cde:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ce1:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104ce8:	83 c2 04             	add    $0x4,%edx
80104ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cef:	89 14 24             	mov    %edx,(%esp)
80104cf2:	e8 a5 09 00 00       	call   8010569c <swtch>
	  switchkvm();
80104cf7:	e8 d5 33 00 00       	call   801080d1 <switchkvm>
	  // Process is done running for now.
	  // It should have changed its p->state before coming back.
	  proc = 0;
80104cfc:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104d03:	00 00 00 00 
	  break;
80104d07:	90                   	nop
	    lowflag = 1;
	    t->quanta = QUANTA;
	  }
	  break;
      }
      t++;
80104d08:	81 45 ec 94 00 00 00 	addl   $0x94,-0x14(%ebp)
    acquire(&tickslock);
    currentime = ticks;
    release(&tickslock);  
    int i=0;
    acquire(&ptable.lock); 
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104d0f:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80104d13:	83 7d e8 3f          	cmpl   $0x3f,-0x18(%ebp)
80104d17:	0f 8e 66 ff ff ff    	jle    80104c83 <scheduler+0x9d>
	// Process is done running for now.
	// It should have changed its p->state before coming back.
	proc = 0;
      }
    }
    release(&ptable.lock);
80104d1d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d24:	e8 e0 04 00 00       	call   80105209 <release>
    }
80104d29:	e9 cc fe ff ff       	jmp    80104bfa <scheduler+0x14>

80104d2e <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104d2e:	55                   	push   %ebp
80104d2f:	89 e5                	mov    %esp,%ebp
80104d31:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104d34:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d3b:	e8 85 05 00 00       	call   801052c5 <holding>
80104d40:	85 c0                	test   %eax,%eax
80104d42:	75 0c                	jne    80104d50 <sched+0x22>
    panic("sched ptable.lock");
80104d44:	c7 04 24 6d 8b 10 80 	movl   $0x80108b6d,(%esp)
80104d4b:	e8 ed b7 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104d50:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d56:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d5c:	83 f8 01             	cmp    $0x1,%eax
80104d5f:	74 0c                	je     80104d6d <sched+0x3f>
    panic("sched locks");
80104d61:	c7 04 24 7f 8b 10 80 	movl   $0x80108b7f,(%esp)
80104d68:	e8 d0 b7 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104d6d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d73:	8b 40 0c             	mov    0xc(%eax),%eax
80104d76:	83 f8 04             	cmp    $0x4,%eax
80104d79:	75 0c                	jne    80104d87 <sched+0x59>
    panic("sched running");
80104d7b:	c7 04 24 8b 8b 10 80 	movl   $0x80108b8b,(%esp)
80104d82:	e8 b6 b7 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104d87:	e8 74 f5 ff ff       	call   80104300 <readeflags>
80104d8c:	25 00 02 00 00       	and    $0x200,%eax
80104d91:	85 c0                	test   %eax,%eax
80104d93:	74 0c                	je     80104da1 <sched+0x73>
    panic("sched interruptible");
80104d95:	c7 04 24 99 8b 10 80 	movl   $0x80108b99,(%esp)
80104d9c:	e8 9c b7 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104da1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104da7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104dad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104db0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104db6:	8b 40 04             	mov    0x4(%eax),%eax
80104db9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104dc0:	83 c2 1c             	add    $0x1c,%edx
80104dc3:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dc7:	89 14 24             	mov    %edx,(%esp)
80104dca:	e8 cd 08 00 00       	call   8010569c <swtch>
  cpu->intena = intena;
80104dcf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104dd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dd8:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104dde:	c9                   	leave  
80104ddf:	c3                   	ret    

80104de0 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104de0:	55                   	push   %ebp
80104de1:	89 e5                	mov    %esp,%ebp
80104de3:	83 ec 18             	sub    $0x18,%esp
	proc->qvalue = ticks;
	release(&tickslock);
      }
      break;
  }
  acquire(&ptable.lock);  //DOC: yieldlock
80104de6:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ded:	e8 b5 03 00 00       	call   801051a7 <acquire>
  proc->state = RUNNABLE;
80104df2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104df8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104dff:	e8 2a ff ff ff       	call   80104d2e <sched>
  release(&ptable.lock);
80104e04:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e0b:	e8 f9 03 00 00       	call   80105209 <release>
  
}
80104e10:	c9                   	leave  
80104e11:	c3                   	ret    

80104e12 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e12:	55                   	push   %ebp
80104e13:	89 e5                	mov    %esp,%ebp
80104e15:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e18:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e1f:	e8 e5 03 00 00       	call   80105209 <release>

  if (first) {
80104e24:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104e29:	85 c0                	test   %eax,%eax
80104e2b:	74 0f                	je     80104e3c <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104e2d:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104e34:	00 00 00 
    initlog();
80104e37:	e8 e4 e4 ff ff       	call   80103320 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104e3c:	c9                   	leave  
80104e3d:	c3                   	ret    

80104e3e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e3e:	55                   	push   %ebp
80104e3f:	89 e5                	mov    %esp,%ebp
80104e41:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104e44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e4a:	85 c0                	test   %eax,%eax
80104e4c:	75 0c                	jne    80104e5a <sleep+0x1c>
    panic("sleep");
80104e4e:	c7 04 24 ad 8b 10 80 	movl   $0x80108bad,(%esp)
80104e55:	e8 e3 b6 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104e5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e5e:	75 0c                	jne    80104e6c <sleep+0x2e>
    panic("sleep without lk");
80104e60:	c7 04 24 b3 8b 10 80 	movl   $0x80108bb3,(%esp)
80104e67:	e8 d1 b6 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e6c:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104e73:	74 17                	je     80104e8c <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e75:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e7c:	e8 26 03 00 00       	call   801051a7 <acquire>
    release(lk);
80104e81:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e84:	89 04 24             	mov    %eax,(%esp)
80104e87:	e8 7d 03 00 00       	call   80105209 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104e8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e92:	8b 55 08             	mov    0x8(%ebp),%edx
80104e95:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104e98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e9e:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104ea5:	e8 84 fe ff ff       	call   80104d2e <sched>

  // Tidy up.
  proc->chan = 0;
80104eaa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eb0:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104eb7:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104ebe:	74 17                	je     80104ed7 <sleep+0x99>
    release(&ptable.lock);
80104ec0:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ec7:	e8 3d 03 00 00       	call   80105209 <release>
    acquire(lk);
80104ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ecf:	89 04 24             	mov    %eax,(%esp)
80104ed2:	e8 d0 02 00 00       	call   801051a7 <acquire>
  }
}
80104ed7:	c9                   	leave  
80104ed8:	c3                   	ret    

80104ed9 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ed9:	55                   	push   %ebp
80104eda:	89 e5                	mov    %esp,%ebp
80104edc:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104edf:	c7 45 fc 74 ff 10 80 	movl   $0x8010ff74,-0x4(%ebp)
80104ee6:	eb 27                	jmp    80104f0f <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104ee8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eeb:	8b 40 0c             	mov    0xc(%eax),%eax
80104eee:	83 f8 02             	cmp    $0x2,%eax
80104ef1:	75 15                	jne    80104f08 <wakeup1+0x2f>
80104ef3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ef6:	8b 40 20             	mov    0x20(%eax),%eax
80104ef9:	3b 45 08             	cmp    0x8(%ebp),%eax
80104efc:	75 0a                	jne    80104f08 <wakeup1+0x2f>
    {
      p->state = RUNNABLE;
80104efe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f01:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f08:	81 45 fc 94 00 00 00 	addl   $0x94,-0x4(%ebp)
80104f0f:	81 7d fc 74 24 11 80 	cmpl   $0x80112474,-0x4(%ebp)
80104f16:	72 d0                	jb     80104ee8 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
    {
      p->state = RUNNABLE;
    }
}
80104f18:	c9                   	leave  
80104f19:	c3                   	ret    

80104f1a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f1a:	55                   	push   %ebp
80104f1b:	89 e5                	mov    %esp,%ebp
80104f1d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104f20:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f27:	e8 7b 02 00 00       	call   801051a7 <acquire>
  wakeup1(chan);
80104f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2f:	89 04 24             	mov    %eax,(%esp)
80104f32:	e8 a2 ff ff ff       	call   80104ed9 <wakeup1>
  release(&ptable.lock);
80104f37:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f3e:	e8 c6 02 00 00       	call   80105209 <release>
}
80104f43:	c9                   	leave  
80104f44:	c3                   	ret    

80104f45 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f45:	55                   	push   %ebp
80104f46:	89 e5                	mov    %esp,%ebp
80104f48:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f4b:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f52:	e8 50 02 00 00       	call   801051a7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f57:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104f5e:	eb 44                	jmp    80104fa4 <kill+0x5f>
    if(p->pid == pid){
80104f60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f63:	8b 40 10             	mov    0x10(%eax),%eax
80104f66:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f69:	75 32                	jne    80104f9d <kill+0x58>
      p->killed = 1;
80104f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f6e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f78:	8b 40 0c             	mov    0xc(%eax),%eax
80104f7b:	83 f8 02             	cmp    $0x2,%eax
80104f7e:	75 0a                	jne    80104f8a <kill+0x45>
        p->state = RUNNABLE;
80104f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f83:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f8a:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f91:	e8 73 02 00 00       	call   80105209 <release>
      return 0;
80104f96:	b8 00 00 00 00       	mov    $0x0,%eax
80104f9b:	eb 21                	jmp    80104fbe <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f9d:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
80104fa4:	81 7d f4 74 24 11 80 	cmpl   $0x80112474,-0xc(%ebp)
80104fab:	72 b3                	jb     80104f60 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104fad:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104fb4:	e8 50 02 00 00       	call   80105209 <release>
  return -1;
80104fb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fbe:	c9                   	leave  
80104fbf:	c3                   	ret    

80104fc0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104fc0:	55                   	push   %ebp
80104fc1:	89 e5                	mov    %esp,%ebp
80104fc3:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fc6:	c7 45 f0 74 ff 10 80 	movl   $0x8010ff74,-0x10(%ebp)
80104fcd:	e9 db 00 00 00       	jmp    801050ad <procdump+0xed>
    if(p->state == UNUSED)
80104fd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd5:	8b 40 0c             	mov    0xc(%eax),%eax
80104fd8:	85 c0                	test   %eax,%eax
80104fda:	0f 84 c5 00 00 00    	je     801050a5 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe3:	8b 40 0c             	mov    0xc(%eax),%eax
80104fe6:	83 f8 05             	cmp    $0x5,%eax
80104fe9:	77 23                	ja     8010500e <procdump+0x4e>
80104feb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fee:	8b 40 0c             	mov    0xc(%eax),%eax
80104ff1:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104ff8:	85 c0                	test   %eax,%eax
80104ffa:	74 12                	je     8010500e <procdump+0x4e>
      state = states[p->state];
80104ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fff:	8b 40 0c             	mov    0xc(%eax),%eax
80105002:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80105009:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010500c:	eb 07                	jmp    80105015 <procdump+0x55>
    else
      state = "???";
8010500e:	c7 45 ec c4 8b 10 80 	movl   $0x80108bc4,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105015:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105018:	8d 50 6c             	lea    0x6c(%eax),%edx
8010501b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010501e:	8b 40 10             	mov    0x10(%eax),%eax
80105021:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105025:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105028:	89 54 24 08          	mov    %edx,0x8(%esp)
8010502c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105030:	c7 04 24 c8 8b 10 80 	movl   $0x80108bc8,(%esp)
80105037:	e8 65 b3 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
8010503c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010503f:	8b 40 0c             	mov    0xc(%eax),%eax
80105042:	83 f8 02             	cmp    $0x2,%eax
80105045:	75 50                	jne    80105097 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105047:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010504a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010504d:	8b 40 0c             	mov    0xc(%eax),%eax
80105050:	83 c0 08             	add    $0x8,%eax
80105053:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80105056:	89 54 24 04          	mov    %edx,0x4(%esp)
8010505a:	89 04 24             	mov    %eax,(%esp)
8010505d:	e8 f6 01 00 00       	call   80105258 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80105062:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105069:	eb 1b                	jmp    80105086 <procdump+0xc6>
        cprintf(" %p", pc[i]);
8010506b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010506e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105072:	89 44 24 04          	mov    %eax,0x4(%esp)
80105076:	c7 04 24 d1 8b 10 80 	movl   $0x80108bd1,(%esp)
8010507d:	e8 1f b3 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105082:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105086:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010508a:	7f 0b                	jg     80105097 <procdump+0xd7>
8010508c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010508f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105093:	85 c0                	test   %eax,%eax
80105095:	75 d4                	jne    8010506b <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105097:	c7 04 24 d5 8b 10 80 	movl   $0x80108bd5,(%esp)
8010509e:	e8 fe b2 ff ff       	call   801003a1 <cprintf>
801050a3:	eb 01                	jmp    801050a6 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
801050a5:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050a6:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
801050ad:	81 7d f0 74 24 11 80 	cmpl   $0x80112474,-0x10(%ebp)
801050b4:	0f 82 18 ff ff ff    	jb     80104fd2 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801050ba:	c9                   	leave  
801050bb:	c3                   	ret    

801050bc <nice>:

int
nice(void)
{
801050bc:	55                   	push   %ebp
801050bd:	89 e5                	mov    %esp,%ebp
  if(proc)
801050bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050c5:	85 c0                	test   %eax,%eax
801050c7:	74 70                	je     80105139 <nice+0x7d>
  {
    if(proc->priority == HIGH)
801050c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050cf:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801050d5:	83 f8 03             	cmp    $0x3,%eax
801050d8:	75 32                	jne    8010510c <nice+0x50>
    {
      proc->priority--;
801050da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050e0:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
801050e6:	83 ea 01             	sub    $0x1,%edx
801050e9:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      proc->qvalue = proc->ctime;
801050ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050f5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801050fc:	8b 52 7c             	mov    0x7c(%edx),%edx
801050ff:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
      return 0;
80105105:	b8 00 00 00 00       	mov    $0x0,%eax
8010510a:	eb 32                	jmp    8010513e <nice+0x82>
    }
    else if(proc->priority == MEDIUM)
8010510c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105112:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80105118:	83 f8 02             	cmp    $0x2,%eax
8010511b:	75 1c                	jne    80105139 <nice+0x7d>
    {
      proc->priority--;
8010511d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105123:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80105129:	83 ea 01             	sub    $0x1,%edx
8010512c:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      return 0;
80105132:	b8 00 00 00 00       	mov    $0x0,%eax
80105137:	eb 05                	jmp    8010513e <nice+0x82>
    }
    
  }
  return -1;
80105139:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010513e:	5d                   	pop    %ebp
8010513f:	c3                   	ret    

80105140 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105140:	55                   	push   %ebp
80105141:	89 e5                	mov    %esp,%ebp
80105143:	53                   	push   %ebx
80105144:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105147:	9c                   	pushf  
80105148:	5b                   	pop    %ebx
80105149:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010514c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010514f:	83 c4 10             	add    $0x10,%esp
80105152:	5b                   	pop    %ebx
80105153:	5d                   	pop    %ebp
80105154:	c3                   	ret    

80105155 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105155:	55                   	push   %ebp
80105156:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105158:	fa                   	cli    
}
80105159:	5d                   	pop    %ebp
8010515a:	c3                   	ret    

8010515b <sti>:

static inline void
sti(void)
{
8010515b:	55                   	push   %ebp
8010515c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010515e:	fb                   	sti    
}
8010515f:	5d                   	pop    %ebp
80105160:	c3                   	ret    

80105161 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105161:	55                   	push   %ebp
80105162:	89 e5                	mov    %esp,%ebp
80105164:	53                   	push   %ebx
80105165:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105168:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010516b:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
8010516e:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105171:	89 c3                	mov    %eax,%ebx
80105173:	89 d8                	mov    %ebx,%eax
80105175:	f0 87 02             	lock xchg %eax,(%edx)
80105178:	89 c3                	mov    %eax,%ebx
8010517a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010517d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105180:	83 c4 10             	add    $0x10,%esp
80105183:	5b                   	pop    %ebx
80105184:	5d                   	pop    %ebp
80105185:	c3                   	ret    

80105186 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105186:	55                   	push   %ebp
80105187:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105189:	8b 45 08             	mov    0x8(%ebp),%eax
8010518c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010518f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105192:	8b 45 08             	mov    0x8(%ebp),%eax
80105195:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010519b:	8b 45 08             	mov    0x8(%ebp),%eax
8010519e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801051a5:	5d                   	pop    %ebp
801051a6:	c3                   	ret    

801051a7 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801051a7:	55                   	push   %ebp
801051a8:	89 e5                	mov    %esp,%ebp
801051aa:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801051ad:	e8 3d 01 00 00       	call   801052ef <pushcli>
  if(holding(lk))
801051b2:	8b 45 08             	mov    0x8(%ebp),%eax
801051b5:	89 04 24             	mov    %eax,(%esp)
801051b8:	e8 08 01 00 00       	call   801052c5 <holding>
801051bd:	85 c0                	test   %eax,%eax
801051bf:	74 0c                	je     801051cd <acquire+0x26>
    panic("acquire");
801051c1:	c7 04 24 01 8c 10 80 	movl   $0x80108c01,(%esp)
801051c8:	e8 70 b3 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801051cd:	90                   	nop
801051ce:	8b 45 08             	mov    0x8(%ebp),%eax
801051d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801051d8:	00 
801051d9:	89 04 24             	mov    %eax,(%esp)
801051dc:	e8 80 ff ff ff       	call   80105161 <xchg>
801051e1:	85 c0                	test   %eax,%eax
801051e3:	75 e9                	jne    801051ce <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801051e5:	8b 45 08             	mov    0x8(%ebp),%eax
801051e8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801051ef:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801051f2:	8b 45 08             	mov    0x8(%ebp),%eax
801051f5:	83 c0 0c             	add    $0xc,%eax
801051f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801051fc:	8d 45 08             	lea    0x8(%ebp),%eax
801051ff:	89 04 24             	mov    %eax,(%esp)
80105202:	e8 51 00 00 00       	call   80105258 <getcallerpcs>
}
80105207:	c9                   	leave  
80105208:	c3                   	ret    

80105209 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105209:	55                   	push   %ebp
8010520a:	89 e5                	mov    %esp,%ebp
8010520c:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010520f:	8b 45 08             	mov    0x8(%ebp),%eax
80105212:	89 04 24             	mov    %eax,(%esp)
80105215:	e8 ab 00 00 00       	call   801052c5 <holding>
8010521a:	85 c0                	test   %eax,%eax
8010521c:	75 0c                	jne    8010522a <release+0x21>
    panic("release");
8010521e:	c7 04 24 09 8c 10 80 	movl   $0x80108c09,(%esp)
80105225:	e8 13 b3 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
8010522a:	8b 45 08             	mov    0x8(%ebp),%eax
8010522d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105234:	8b 45 08             	mov    0x8(%ebp),%eax
80105237:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010523e:	8b 45 08             	mov    0x8(%ebp),%eax
80105241:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105248:	00 
80105249:	89 04 24             	mov    %eax,(%esp)
8010524c:	e8 10 ff ff ff       	call   80105161 <xchg>

  popcli();
80105251:	e8 e1 00 00 00       	call   80105337 <popcli>
}
80105256:	c9                   	leave  
80105257:	c3                   	ret    

80105258 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105258:	55                   	push   %ebp
80105259:	89 e5                	mov    %esp,%ebp
8010525b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
8010525e:	8b 45 08             	mov    0x8(%ebp),%eax
80105261:	83 e8 08             	sub    $0x8,%eax
80105264:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105267:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010526e:	eb 32                	jmp    801052a2 <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105270:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105274:	74 47                	je     801052bd <getcallerpcs+0x65>
80105276:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010527d:	76 3e                	jbe    801052bd <getcallerpcs+0x65>
8010527f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105283:	74 38                	je     801052bd <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105285:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105288:	c1 e0 02             	shl    $0x2,%eax
8010528b:	03 45 0c             	add    0xc(%ebp),%eax
8010528e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105291:	8b 52 04             	mov    0x4(%edx),%edx
80105294:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80105296:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105299:	8b 00                	mov    (%eax),%eax
8010529b:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010529e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052a2:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052a6:	7e c8                	jle    80105270 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052a8:	eb 13                	jmp    801052bd <getcallerpcs+0x65>
    pcs[i] = 0;
801052aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052ad:	c1 e0 02             	shl    $0x2,%eax
801052b0:	03 45 0c             	add    0xc(%ebp),%eax
801052b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052b9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052bd:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052c1:	7e e7                	jle    801052aa <getcallerpcs+0x52>
    pcs[i] = 0;
}
801052c3:	c9                   	leave  
801052c4:	c3                   	ret    

801052c5 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801052c5:	55                   	push   %ebp
801052c6:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801052c8:	8b 45 08             	mov    0x8(%ebp),%eax
801052cb:	8b 00                	mov    (%eax),%eax
801052cd:	85 c0                	test   %eax,%eax
801052cf:	74 17                	je     801052e8 <holding+0x23>
801052d1:	8b 45 08             	mov    0x8(%ebp),%eax
801052d4:	8b 50 08             	mov    0x8(%eax),%edx
801052d7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052dd:	39 c2                	cmp    %eax,%edx
801052df:	75 07                	jne    801052e8 <holding+0x23>
801052e1:	b8 01 00 00 00       	mov    $0x1,%eax
801052e6:	eb 05                	jmp    801052ed <holding+0x28>
801052e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052ed:	5d                   	pop    %ebp
801052ee:	c3                   	ret    

801052ef <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801052ef:	55                   	push   %ebp
801052f0:	89 e5                	mov    %esp,%ebp
801052f2:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801052f5:	e8 46 fe ff ff       	call   80105140 <readeflags>
801052fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801052fd:	e8 53 fe ff ff       	call   80105155 <cli>
  if(cpu->ncli++ == 0)
80105302:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105308:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010530e:	85 d2                	test   %edx,%edx
80105310:	0f 94 c1             	sete   %cl
80105313:	83 c2 01             	add    $0x1,%edx
80105316:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010531c:	84 c9                	test   %cl,%cl
8010531e:	74 15                	je     80105335 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105320:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105326:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105329:	81 e2 00 02 00 00    	and    $0x200,%edx
8010532f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105335:	c9                   	leave  
80105336:	c3                   	ret    

80105337 <popcli>:

void
popcli(void)
{
80105337:	55                   	push   %ebp
80105338:	89 e5                	mov    %esp,%ebp
8010533a:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010533d:	e8 fe fd ff ff       	call   80105140 <readeflags>
80105342:	25 00 02 00 00       	and    $0x200,%eax
80105347:	85 c0                	test   %eax,%eax
80105349:	74 0c                	je     80105357 <popcli+0x20>
    panic("popcli - interruptible");
8010534b:	c7 04 24 11 8c 10 80 	movl   $0x80108c11,(%esp)
80105352:	e8 e6 b1 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
80105357:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010535d:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105363:	83 ea 01             	sub    $0x1,%edx
80105366:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010536c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105372:	85 c0                	test   %eax,%eax
80105374:	79 0c                	jns    80105382 <popcli+0x4b>
    panic("popcli");
80105376:	c7 04 24 28 8c 10 80 	movl   $0x80108c28,(%esp)
8010537d:	e8 bb b1 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105382:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105388:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010538e:	85 c0                	test   %eax,%eax
80105390:	75 15                	jne    801053a7 <popcli+0x70>
80105392:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105398:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010539e:	85 c0                	test   %eax,%eax
801053a0:	74 05                	je     801053a7 <popcli+0x70>
    sti();
801053a2:	e8 b4 fd ff ff       	call   8010515b <sti>
}
801053a7:	c9                   	leave  
801053a8:	c3                   	ret    
801053a9:	00 00                	add    %al,(%eax)
	...

801053ac <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801053ac:	55                   	push   %ebp
801053ad:	89 e5                	mov    %esp,%ebp
801053af:	57                   	push   %edi
801053b0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801053b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053b4:	8b 55 10             	mov    0x10(%ebp),%edx
801053b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ba:	89 cb                	mov    %ecx,%ebx
801053bc:	89 df                	mov    %ebx,%edi
801053be:	89 d1                	mov    %edx,%ecx
801053c0:	fc                   	cld    
801053c1:	f3 aa                	rep stos %al,%es:(%edi)
801053c3:	89 ca                	mov    %ecx,%edx
801053c5:	89 fb                	mov    %edi,%ebx
801053c7:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053ca:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053cd:	5b                   	pop    %ebx
801053ce:	5f                   	pop    %edi
801053cf:	5d                   	pop    %ebp
801053d0:	c3                   	ret    

801053d1 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801053d1:	55                   	push   %ebp
801053d2:	89 e5                	mov    %esp,%ebp
801053d4:	57                   	push   %edi
801053d5:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801053d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053d9:	8b 55 10             	mov    0x10(%ebp),%edx
801053dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801053df:	89 cb                	mov    %ecx,%ebx
801053e1:	89 df                	mov    %ebx,%edi
801053e3:	89 d1                	mov    %edx,%ecx
801053e5:	fc                   	cld    
801053e6:	f3 ab                	rep stos %eax,%es:(%edi)
801053e8:	89 ca                	mov    %ecx,%edx
801053ea:	89 fb                	mov    %edi,%ebx
801053ec:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053ef:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053f2:	5b                   	pop    %ebx
801053f3:	5f                   	pop    %edi
801053f4:	5d                   	pop    %ebp
801053f5:	c3                   	ret    

801053f6 <memset>:
#include "x86.h"
#include "string.h"

void*
memset(void *dst, int c, uint n)
{
801053f6:	55                   	push   %ebp
801053f7:	89 e5                	mov    %esp,%ebp
801053f9:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801053fc:	8b 45 08             	mov    0x8(%ebp),%eax
801053ff:	83 e0 03             	and    $0x3,%eax
80105402:	85 c0                	test   %eax,%eax
80105404:	75 49                	jne    8010544f <memset+0x59>
80105406:	8b 45 10             	mov    0x10(%ebp),%eax
80105409:	83 e0 03             	and    $0x3,%eax
8010540c:	85 c0                	test   %eax,%eax
8010540e:	75 3f                	jne    8010544f <memset+0x59>
    c &= 0xFF;
80105410:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105417:	8b 45 10             	mov    0x10(%ebp),%eax
8010541a:	c1 e8 02             	shr    $0x2,%eax
8010541d:	89 c2                	mov    %eax,%edx
8010541f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105422:	89 c1                	mov    %eax,%ecx
80105424:	c1 e1 18             	shl    $0x18,%ecx
80105427:	8b 45 0c             	mov    0xc(%ebp),%eax
8010542a:	c1 e0 10             	shl    $0x10,%eax
8010542d:	09 c1                	or     %eax,%ecx
8010542f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105432:	c1 e0 08             	shl    $0x8,%eax
80105435:	09 c8                	or     %ecx,%eax
80105437:	0b 45 0c             	or     0xc(%ebp),%eax
8010543a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010543e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105442:	8b 45 08             	mov    0x8(%ebp),%eax
80105445:	89 04 24             	mov    %eax,(%esp)
80105448:	e8 84 ff ff ff       	call   801053d1 <stosl>
8010544d:	eb 19                	jmp    80105468 <memset+0x72>
  } else
    stosb(dst, c, n);
8010544f:	8b 45 10             	mov    0x10(%ebp),%eax
80105452:	89 44 24 08          	mov    %eax,0x8(%esp)
80105456:	8b 45 0c             	mov    0xc(%ebp),%eax
80105459:	89 44 24 04          	mov    %eax,0x4(%esp)
8010545d:	8b 45 08             	mov    0x8(%ebp),%eax
80105460:	89 04 24             	mov    %eax,(%esp)
80105463:	e8 44 ff ff ff       	call   801053ac <stosb>
  return dst;
80105468:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010546b:	c9                   	leave  
8010546c:	c3                   	ret    

8010546d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010546d:	55                   	push   %ebp
8010546e:	89 e5                	mov    %esp,%ebp
80105470:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105473:	8b 45 08             	mov    0x8(%ebp),%eax
80105476:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105479:	8b 45 0c             	mov    0xc(%ebp),%eax
8010547c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010547f:	eb 32                	jmp    801054b3 <memcmp+0x46>
    if(*s1 != *s2)
80105481:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105484:	0f b6 10             	movzbl (%eax),%edx
80105487:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010548a:	0f b6 00             	movzbl (%eax),%eax
8010548d:	38 c2                	cmp    %al,%dl
8010548f:	74 1a                	je     801054ab <memcmp+0x3e>
      return *s1 - *s2;
80105491:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105494:	0f b6 00             	movzbl (%eax),%eax
80105497:	0f b6 d0             	movzbl %al,%edx
8010549a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010549d:	0f b6 00             	movzbl (%eax),%eax
801054a0:	0f b6 c0             	movzbl %al,%eax
801054a3:	89 d1                	mov    %edx,%ecx
801054a5:	29 c1                	sub    %eax,%ecx
801054a7:	89 c8                	mov    %ecx,%eax
801054a9:	eb 1c                	jmp    801054c7 <memcmp+0x5a>
    s1++, s2++;
801054ab:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054af:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801054b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054b7:	0f 95 c0             	setne  %al
801054ba:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054be:	84 c0                	test   %al,%al
801054c0:	75 bf                	jne    80105481 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801054c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054c7:	c9                   	leave  
801054c8:	c3                   	ret    

801054c9 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801054c9:	55                   	push   %ebp
801054ca:	89 e5                	mov    %esp,%ebp
801054cc:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801054cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801054d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801054d5:	8b 45 08             	mov    0x8(%ebp),%eax
801054d8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801054db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054e1:	73 54                	jae    80105537 <memmove+0x6e>
801054e3:	8b 45 10             	mov    0x10(%ebp),%eax
801054e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054e9:	01 d0                	add    %edx,%eax
801054eb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054ee:	76 47                	jbe    80105537 <memmove+0x6e>
    s += n;
801054f0:	8b 45 10             	mov    0x10(%ebp),%eax
801054f3:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801054f6:	8b 45 10             	mov    0x10(%ebp),%eax
801054f9:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801054fc:	eb 13                	jmp    80105511 <memmove+0x48>
      *--d = *--s;
801054fe:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105502:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105506:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105509:	0f b6 10             	movzbl (%eax),%edx
8010550c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010550f:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105511:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105515:	0f 95 c0             	setne  %al
80105518:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010551c:	84 c0                	test   %al,%al
8010551e:	75 de                	jne    801054fe <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105520:	eb 25                	jmp    80105547 <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105522:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105525:	0f b6 10             	movzbl (%eax),%edx
80105528:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010552b:	88 10                	mov    %dl,(%eax)
8010552d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105531:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105535:	eb 01                	jmp    80105538 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105537:	90                   	nop
80105538:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010553c:	0f 95 c0             	setne  %al
8010553f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105543:	84 c0                	test   %al,%al
80105545:	75 db                	jne    80105522 <memmove+0x59>
      *d++ = *s++;

  return dst;
80105547:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010554a:	c9                   	leave  
8010554b:	c3                   	ret    

8010554c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010554c:	55                   	push   %ebp
8010554d:	89 e5                	mov    %esp,%ebp
8010554f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105552:	8b 45 10             	mov    0x10(%ebp),%eax
80105555:	89 44 24 08          	mov    %eax,0x8(%esp)
80105559:	8b 45 0c             	mov    0xc(%ebp),%eax
8010555c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105560:	8b 45 08             	mov    0x8(%ebp),%eax
80105563:	89 04 24             	mov    %eax,(%esp)
80105566:	e8 5e ff ff ff       	call   801054c9 <memmove>
}
8010556b:	c9                   	leave  
8010556c:	c3                   	ret    

8010556d <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010556d:	55                   	push   %ebp
8010556e:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105570:	eb 0c                	jmp    8010557e <strncmp+0x11>
    n--, p++, q++;
80105572:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105576:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010557a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010557e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105582:	74 1a                	je     8010559e <strncmp+0x31>
80105584:	8b 45 08             	mov    0x8(%ebp),%eax
80105587:	0f b6 00             	movzbl (%eax),%eax
8010558a:	84 c0                	test   %al,%al
8010558c:	74 10                	je     8010559e <strncmp+0x31>
8010558e:	8b 45 08             	mov    0x8(%ebp),%eax
80105591:	0f b6 10             	movzbl (%eax),%edx
80105594:	8b 45 0c             	mov    0xc(%ebp),%eax
80105597:	0f b6 00             	movzbl (%eax),%eax
8010559a:	38 c2                	cmp    %al,%dl
8010559c:	74 d4                	je     80105572 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010559e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055a2:	75 07                	jne    801055ab <strncmp+0x3e>
    return 0;
801055a4:	b8 00 00 00 00       	mov    $0x0,%eax
801055a9:	eb 18                	jmp    801055c3 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
801055ab:	8b 45 08             	mov    0x8(%ebp),%eax
801055ae:	0f b6 00             	movzbl (%eax),%eax
801055b1:	0f b6 d0             	movzbl %al,%edx
801055b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b7:	0f b6 00             	movzbl (%eax),%eax
801055ba:	0f b6 c0             	movzbl %al,%eax
801055bd:	89 d1                	mov    %edx,%ecx
801055bf:	29 c1                	sub    %eax,%ecx
801055c1:	89 c8                	mov    %ecx,%eax
}
801055c3:	5d                   	pop    %ebp
801055c4:	c3                   	ret    

801055c5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801055c5:	55                   	push   %ebp
801055c6:	89 e5                	mov    %esp,%ebp
801055c8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801055cb:	8b 45 08             	mov    0x8(%ebp),%eax
801055ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801055d1:	90                   	nop
801055d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055d6:	0f 9f c0             	setg   %al
801055d9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055dd:	84 c0                	test   %al,%al
801055df:	74 30                	je     80105611 <strncpy+0x4c>
801055e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e4:	0f b6 10             	movzbl (%eax),%edx
801055e7:	8b 45 08             	mov    0x8(%ebp),%eax
801055ea:	88 10                	mov    %dl,(%eax)
801055ec:	8b 45 08             	mov    0x8(%ebp),%eax
801055ef:	0f b6 00             	movzbl (%eax),%eax
801055f2:	84 c0                	test   %al,%al
801055f4:	0f 95 c0             	setne  %al
801055f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801055fb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801055ff:	84 c0                	test   %al,%al
80105601:	75 cf                	jne    801055d2 <strncpy+0xd>
    ;
  while(n-- > 0)
80105603:	eb 0c                	jmp    80105611 <strncpy+0x4c>
    *s++ = 0;
80105605:	8b 45 08             	mov    0x8(%ebp),%eax
80105608:	c6 00 00             	movb   $0x0,(%eax)
8010560b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010560f:	eb 01                	jmp    80105612 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105611:	90                   	nop
80105612:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105616:	0f 9f c0             	setg   %al
80105619:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010561d:	84 c0                	test   %al,%al
8010561f:	75 e4                	jne    80105605 <strncpy+0x40>
    *s++ = 0;
  return os;
80105621:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105624:	c9                   	leave  
80105625:	c3                   	ret    

80105626 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105626:	55                   	push   %ebp
80105627:	89 e5                	mov    %esp,%ebp
80105629:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010562c:	8b 45 08             	mov    0x8(%ebp),%eax
8010562f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105632:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105636:	7f 05                	jg     8010563d <safestrcpy+0x17>
    return os;
80105638:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010563b:	eb 35                	jmp    80105672 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
8010563d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105641:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105645:	7e 22                	jle    80105669 <safestrcpy+0x43>
80105647:	8b 45 0c             	mov    0xc(%ebp),%eax
8010564a:	0f b6 10             	movzbl (%eax),%edx
8010564d:	8b 45 08             	mov    0x8(%ebp),%eax
80105650:	88 10                	mov    %dl,(%eax)
80105652:	8b 45 08             	mov    0x8(%ebp),%eax
80105655:	0f b6 00             	movzbl (%eax),%eax
80105658:	84 c0                	test   %al,%al
8010565a:	0f 95 c0             	setne  %al
8010565d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105661:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105665:	84 c0                	test   %al,%al
80105667:	75 d4                	jne    8010563d <safestrcpy+0x17>
    ;
  *s = 0;
80105669:	8b 45 08             	mov    0x8(%ebp),%eax
8010566c:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010566f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105672:	c9                   	leave  
80105673:	c3                   	ret    

80105674 <strlen>:

int
strlen(const char *s)
{
80105674:	55                   	push   %ebp
80105675:	89 e5                	mov    %esp,%ebp
80105677:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010567a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105681:	eb 04                	jmp    80105687 <strlen+0x13>
80105683:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105687:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010568a:	03 45 08             	add    0x8(%ebp),%eax
8010568d:	0f b6 00             	movzbl (%eax),%eax
80105690:	84 c0                	test   %al,%al
80105692:	75 ef                	jne    80105683 <strlen+0xf>
    ;
  return n;
80105694:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105697:	c9                   	leave  
80105698:	c3                   	ret    
80105699:	00 00                	add    %al,(%eax)
	...

8010569c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010569c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801056a0:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801056a4:	55                   	push   %ebp
  pushl %ebx
801056a5:	53                   	push   %ebx
  pushl %esi
801056a6:	56                   	push   %esi
  pushl %edi
801056a7:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801056a8:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801056aa:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801056ac:	5f                   	pop    %edi
  popl %esi
801056ad:	5e                   	pop    %esi
  popl %ebx
801056ae:	5b                   	pop    %ebx
  popl %ebp
801056af:	5d                   	pop    %ebp
  ret
801056b0:	c3                   	ret    
801056b1:	00 00                	add    %al,(%eax)
	...

801056b4 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
801056b4:	55                   	push   %ebp
801056b5:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
801056b7:	8b 45 08             	mov    0x8(%ebp),%eax
801056ba:	8b 00                	mov    (%eax),%eax
801056bc:	3b 45 0c             	cmp    0xc(%ebp),%eax
801056bf:	76 0f                	jbe    801056d0 <fetchint+0x1c>
801056c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801056c4:	8d 50 04             	lea    0x4(%eax),%edx
801056c7:	8b 45 08             	mov    0x8(%ebp),%eax
801056ca:	8b 00                	mov    (%eax),%eax
801056cc:	39 c2                	cmp    %eax,%edx
801056ce:	76 07                	jbe    801056d7 <fetchint+0x23>
    return -1;
801056d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056d5:	eb 0f                	jmp    801056e6 <fetchint+0x32>
  *ip = *(int*)(addr);
801056d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801056da:	8b 10                	mov    (%eax),%edx
801056dc:	8b 45 10             	mov    0x10(%ebp),%eax
801056df:	89 10                	mov    %edx,(%eax)
  return 0;
801056e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056e6:	5d                   	pop    %ebp
801056e7:	c3                   	ret    

801056e8 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
801056e8:	55                   	push   %ebp
801056e9:	89 e5                	mov    %esp,%ebp
801056eb:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
801056ee:	8b 45 08             	mov    0x8(%ebp),%eax
801056f1:	8b 00                	mov    (%eax),%eax
801056f3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801056f6:	77 07                	ja     801056ff <fetchstr+0x17>
    return -1;
801056f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056fd:	eb 45                	jmp    80105744 <fetchstr+0x5c>
  *pp = (char*)addr;
801056ff:	8b 55 0c             	mov    0xc(%ebp),%edx
80105702:	8b 45 10             	mov    0x10(%ebp),%eax
80105705:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
80105707:	8b 45 08             	mov    0x8(%ebp),%eax
8010570a:	8b 00                	mov    (%eax),%eax
8010570c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010570f:	8b 45 10             	mov    0x10(%ebp),%eax
80105712:	8b 00                	mov    (%eax),%eax
80105714:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105717:	eb 1e                	jmp    80105737 <fetchstr+0x4f>
    if(*s == 0)
80105719:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010571c:	0f b6 00             	movzbl (%eax),%eax
8010571f:	84 c0                	test   %al,%al
80105721:	75 10                	jne    80105733 <fetchstr+0x4b>
      return s - *pp;
80105723:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105726:	8b 45 10             	mov    0x10(%ebp),%eax
80105729:	8b 00                	mov    (%eax),%eax
8010572b:	89 d1                	mov    %edx,%ecx
8010572d:	29 c1                	sub    %eax,%ecx
8010572f:	89 c8                	mov    %ecx,%eax
80105731:	eb 11                	jmp    80105744 <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
80105733:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105737:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010573a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010573d:	72 da                	jb     80105719 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
8010573f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105744:	c9                   	leave  
80105745:	c3                   	ret    

80105746 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105746:	55                   	push   %ebp
80105747:	89 e5                	mov    %esp,%ebp
80105749:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
8010574c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105752:	8b 40 18             	mov    0x18(%eax),%eax
80105755:	8b 50 44             	mov    0x44(%eax),%edx
80105758:	8b 45 08             	mov    0x8(%ebp),%eax
8010575b:	c1 e0 02             	shl    $0x2,%eax
8010575e:	01 d0                	add    %edx,%eax
80105760:	8d 48 04             	lea    0x4(%eax),%ecx
80105763:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105769:	8b 55 0c             	mov    0xc(%ebp),%edx
8010576c:	89 54 24 08          	mov    %edx,0x8(%esp)
80105770:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80105774:	89 04 24             	mov    %eax,(%esp)
80105777:	e8 38 ff ff ff       	call   801056b4 <fetchint>
}
8010577c:	c9                   	leave  
8010577d:	c3                   	ret    

8010577e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010577e:	55                   	push   %ebp
8010577f:	89 e5                	mov    %esp,%ebp
80105781:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105784:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105787:	89 44 24 04          	mov    %eax,0x4(%esp)
8010578b:	8b 45 08             	mov    0x8(%ebp),%eax
8010578e:	89 04 24             	mov    %eax,(%esp)
80105791:	e8 b0 ff ff ff       	call   80105746 <argint>
80105796:	85 c0                	test   %eax,%eax
80105798:	79 07                	jns    801057a1 <argptr+0x23>
    return -1;
8010579a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010579f:	eb 3d                	jmp    801057de <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801057a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057a4:	89 c2                	mov    %eax,%edx
801057a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057ac:	8b 00                	mov    (%eax),%eax
801057ae:	39 c2                	cmp    %eax,%edx
801057b0:	73 16                	jae    801057c8 <argptr+0x4a>
801057b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057b5:	89 c2                	mov    %eax,%edx
801057b7:	8b 45 10             	mov    0x10(%ebp),%eax
801057ba:	01 c2                	add    %eax,%edx
801057bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057c2:	8b 00                	mov    (%eax),%eax
801057c4:	39 c2                	cmp    %eax,%edx
801057c6:	76 07                	jbe    801057cf <argptr+0x51>
    return -1;
801057c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057cd:	eb 0f                	jmp    801057de <argptr+0x60>
  *pp = (char*)i;
801057cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057d2:	89 c2                	mov    %eax,%edx
801057d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801057d7:	89 10                	mov    %edx,(%eax)
  return 0;
801057d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057de:	c9                   	leave  
801057df:	c3                   	ret    

801057e0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801057e0:	55                   	push   %ebp
801057e1:	89 e5                	mov    %esp,%ebp
801057e3:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
801057e6:	8d 45 fc             	lea    -0x4(%ebp),%eax
801057e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801057ed:	8b 45 08             	mov    0x8(%ebp),%eax
801057f0:	89 04 24             	mov    %eax,(%esp)
801057f3:	e8 4e ff ff ff       	call   80105746 <argint>
801057f8:	85 c0                	test   %eax,%eax
801057fa:	79 07                	jns    80105803 <argstr+0x23>
    return -1;
801057fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105801:	eb 1e                	jmp    80105821 <argstr+0x41>
  return fetchstr(proc, addr, pp);
80105803:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105806:	89 c2                	mov    %eax,%edx
80105808:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010580e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105811:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105815:	89 54 24 04          	mov    %edx,0x4(%esp)
80105819:	89 04 24             	mov    %eax,(%esp)
8010581c:	e8 c7 fe ff ff       	call   801056e8 <fetchstr>
}
80105821:	c9                   	leave  
80105822:	c3                   	ret    

80105823 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105823:	55                   	push   %ebp
80105824:	89 e5                	mov    %esp,%ebp
80105826:	53                   	push   %ebx
80105827:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
8010582a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105830:	8b 40 18             	mov    0x18(%eax),%eax
80105833:	8b 40 1c             	mov    0x1c(%eax),%eax
80105836:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
80105839:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010583d:	78 2e                	js     8010586d <syscall+0x4a>
8010583f:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105843:	7f 28                	jg     8010586d <syscall+0x4a>
80105845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105848:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010584f:	85 c0                	test   %eax,%eax
80105851:	74 1a                	je     8010586d <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
80105853:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105859:	8b 58 18             	mov    0x18(%eax),%ebx
8010585c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010585f:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105866:	ff d0                	call   *%eax
80105868:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010586b:	eb 73                	jmp    801058e0 <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
8010586d:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105871:	7e 30                	jle    801058a3 <syscall+0x80>
80105873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105876:	83 f8 17             	cmp    $0x17,%eax
80105879:	77 28                	ja     801058a3 <syscall+0x80>
8010587b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587e:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105885:	85 c0                	test   %eax,%eax
80105887:	74 1a                	je     801058a3 <syscall+0x80>
    proc->tf->eax = syscalls[num]();
80105889:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010588f:	8b 58 18             	mov    0x18(%eax),%ebx
80105892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105895:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010589c:	ff d0                	call   *%eax
8010589e:	89 43 1c             	mov    %eax,0x1c(%ebx)
801058a1:	eb 3d                	jmp    801058e0 <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801058a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058a9:	8d 48 6c             	lea    0x6c(%eax),%ecx
801058ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801058b2:	8b 40 10             	mov    0x10(%eax),%eax
801058b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
801058bc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801058c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801058c4:	c7 04 24 2f 8c 10 80 	movl   $0x80108c2f,(%esp)
801058cb:	e8 d1 aa ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801058d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058d6:	8b 40 18             	mov    0x18(%eax),%eax
801058d9:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801058e0:	83 c4 24             	add    $0x24,%esp
801058e3:	5b                   	pop    %ebx
801058e4:	5d                   	pop    %ebp
801058e5:	c3                   	ret    
	...

801058e8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801058e8:	55                   	push   %ebp
801058e9:	89 e5                	mov    %esp,%ebp
801058eb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801058ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801058f5:	8b 45 08             	mov    0x8(%ebp),%eax
801058f8:	89 04 24             	mov    %eax,(%esp)
801058fb:	e8 46 fe ff ff       	call   80105746 <argint>
80105900:	85 c0                	test   %eax,%eax
80105902:	79 07                	jns    8010590b <argfd+0x23>
    return -1;
80105904:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105909:	eb 50                	jmp    8010595b <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010590b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010590e:	85 c0                	test   %eax,%eax
80105910:	78 21                	js     80105933 <argfd+0x4b>
80105912:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105915:	83 f8 0f             	cmp    $0xf,%eax
80105918:	7f 19                	jg     80105933 <argfd+0x4b>
8010591a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105920:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105923:	83 c2 08             	add    $0x8,%edx
80105926:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010592a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010592d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105931:	75 07                	jne    8010593a <argfd+0x52>
    return -1;
80105933:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105938:	eb 21                	jmp    8010595b <argfd+0x73>
  if(pfd)
8010593a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010593e:	74 08                	je     80105948 <argfd+0x60>
    *pfd = fd;
80105940:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105943:	8b 45 0c             	mov    0xc(%ebp),%eax
80105946:	89 10                	mov    %edx,(%eax)
  if(pf)
80105948:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010594c:	74 08                	je     80105956 <argfd+0x6e>
    *pf = f;
8010594e:	8b 45 10             	mov    0x10(%ebp),%eax
80105951:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105954:	89 10                	mov    %edx,(%eax)
  return 0;
80105956:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010595b:	c9                   	leave  
8010595c:	c3                   	ret    

8010595d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010595d:	55                   	push   %ebp
8010595e:	89 e5                	mov    %esp,%ebp
80105960:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105963:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010596a:	eb 30                	jmp    8010599c <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010596c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105972:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105975:	83 c2 08             	add    $0x8,%edx
80105978:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010597c:	85 c0                	test   %eax,%eax
8010597e:	75 18                	jne    80105998 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105980:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105986:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105989:	8d 4a 08             	lea    0x8(%edx),%ecx
8010598c:	8b 55 08             	mov    0x8(%ebp),%edx
8010598f:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105993:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105996:	eb 0f                	jmp    801059a7 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105998:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010599c:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801059a0:	7e ca                	jle    8010596c <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801059a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059a7:	c9                   	leave  
801059a8:	c3                   	ret    

801059a9 <sys_dup>:

int
sys_dup(void)
{
801059a9:	55                   	push   %ebp
801059aa:	89 e5                	mov    %esp,%ebp
801059ac:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801059af:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059b2:	89 44 24 08          	mov    %eax,0x8(%esp)
801059b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801059bd:	00 
801059be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059c5:	e8 1e ff ff ff       	call   801058e8 <argfd>
801059ca:	85 c0                	test   %eax,%eax
801059cc:	79 07                	jns    801059d5 <sys_dup+0x2c>
    return -1;
801059ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d3:	eb 29                	jmp    801059fe <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801059d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d8:	89 04 24             	mov    %eax,(%esp)
801059db:	e8 7d ff ff ff       	call   8010595d <fdalloc>
801059e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059e7:	79 07                	jns    801059f0 <sys_dup+0x47>
    return -1;
801059e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ee:	eb 0e                	jmp    801059fe <sys_dup+0x55>
  filedup(f);
801059f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059f3:	89 04 24             	mov    %eax,(%esp)
801059f6:	e8 91 b8 ff ff       	call   8010128c <filedup>
  return fd;
801059fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801059fe:	c9                   	leave  
801059ff:	c3                   	ret    

80105a00 <sys_read>:

int
sys_read(void)
{
80105a00:	55                   	push   %ebp
80105a01:	89 e5                	mov    %esp,%ebp
80105a03:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a06:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a09:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a0d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a14:	00 
80105a15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a1c:	e8 c7 fe ff ff       	call   801058e8 <argfd>
80105a21:	85 c0                	test   %eax,%eax
80105a23:	78 35                	js     80105a5a <sys_read+0x5a>
80105a25:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a28:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a2c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105a33:	e8 0e fd ff ff       	call   80105746 <argint>
80105a38:	85 c0                	test   %eax,%eax
80105a3a:	78 1e                	js     80105a5a <sys_read+0x5a>
80105a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a3f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a43:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a46:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a4a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a51:	e8 28 fd ff ff       	call   8010577e <argptr>
80105a56:	85 c0                	test   %eax,%eax
80105a58:	79 07                	jns    80105a61 <sys_read+0x61>
    return -1;
80105a5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a5f:	eb 19                	jmp    80105a7a <sys_read+0x7a>
  return fileread(f, p, n);
80105a61:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a64:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a6e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a72:	89 04 24             	mov    %eax,(%esp)
80105a75:	e8 7f b9 ff ff       	call   801013f9 <fileread>
}
80105a7a:	c9                   	leave  
80105a7b:	c3                   	ret    

80105a7c <sys_write>:

int
sys_write(void)
{
80105a7c:	55                   	push   %ebp
80105a7d:	89 e5                	mov    %esp,%ebp
80105a7f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a82:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a85:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a90:	00 
80105a91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a98:	e8 4b fe ff ff       	call   801058e8 <argfd>
80105a9d:	85 c0                	test   %eax,%eax
80105a9f:	78 35                	js     80105ad6 <sys_write+0x5a>
80105aa1:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105aa8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105aaf:	e8 92 fc ff ff       	call   80105746 <argint>
80105ab4:	85 c0                	test   %eax,%eax
80105ab6:	78 1e                	js     80105ad6 <sys_write+0x5a>
80105ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abb:	89 44 24 08          	mov    %eax,0x8(%esp)
80105abf:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ac6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105acd:	e8 ac fc ff ff       	call   8010577e <argptr>
80105ad2:	85 c0                	test   %eax,%eax
80105ad4:	79 07                	jns    80105add <sys_write+0x61>
    return -1;
80105ad6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105adb:	eb 19                	jmp    80105af6 <sys_write+0x7a>
  return filewrite(f, p, n);
80105add:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ae0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105aea:	89 54 24 04          	mov    %edx,0x4(%esp)
80105aee:	89 04 24             	mov    %eax,(%esp)
80105af1:	e8 bf b9 ff ff       	call   801014b5 <filewrite>
}
80105af6:	c9                   	leave  
80105af7:	c3                   	ret    

80105af8 <sys_close>:

int
sys_close(void)
{
80105af8:	55                   	push   %ebp
80105af9:	89 e5                	mov    %esp,%ebp
80105afb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105afe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b01:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b05:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b08:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b0c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b13:	e8 d0 fd ff ff       	call   801058e8 <argfd>
80105b18:	85 c0                	test   %eax,%eax
80105b1a:	79 07                	jns    80105b23 <sys_close+0x2b>
    return -1;
80105b1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b21:	eb 24                	jmp    80105b47 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105b23:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b2c:	83 c2 08             	add    $0x8,%edx
80105b2f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b36:	00 
  fileclose(f);
80105b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b3a:	89 04 24             	mov    %eax,(%esp)
80105b3d:	e8 92 b7 ff ff       	call   801012d4 <fileclose>
  return 0;
80105b42:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b47:	c9                   	leave  
80105b48:	c3                   	ret    

80105b49 <sys_fstat>:

int
sys_fstat(void)
{
80105b49:	55                   	push   %ebp
80105b4a:	89 e5                	mov    %esp,%ebp
80105b4c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105b4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b52:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b5d:	00 
80105b5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b65:	e8 7e fd ff ff       	call   801058e8 <argfd>
80105b6a:	85 c0                	test   %eax,%eax
80105b6c:	78 1f                	js     80105b8d <sys_fstat+0x44>
80105b6e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105b75:	00 
80105b76:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b79:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b7d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b84:	e8 f5 fb ff ff       	call   8010577e <argptr>
80105b89:	85 c0                	test   %eax,%eax
80105b8b:	79 07                	jns    80105b94 <sys_fstat+0x4b>
    return -1;
80105b8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b92:	eb 12                	jmp    80105ba6 <sys_fstat+0x5d>
  return filestat(f, st);
80105b94:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b9e:	89 04 24             	mov    %eax,(%esp)
80105ba1:	e8 04 b8 ff ff       	call   801013aa <filestat>
}
80105ba6:	c9                   	leave  
80105ba7:	c3                   	ret    

80105ba8 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ba8:	55                   	push   %ebp
80105ba9:	89 e5                	mov    %esp,%ebp
80105bab:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105bae:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bbc:	e8 1f fc ff ff       	call   801057e0 <argstr>
80105bc1:	85 c0                	test   %eax,%eax
80105bc3:	78 17                	js     80105bdc <sys_link+0x34>
80105bc5:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bcc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105bd3:	e8 08 fc ff ff       	call   801057e0 <argstr>
80105bd8:	85 c0                	test   %eax,%eax
80105bda:	79 0a                	jns    80105be6 <sys_link+0x3e>
    return -1;
80105bdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be1:	e9 3c 01 00 00       	jmp    80105d22 <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80105be6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105be9:	89 04 24             	mov    %eax,(%esp)
80105bec:	e8 29 cb ff ff       	call   8010271a <namei>
80105bf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bf4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bf8:	75 0a                	jne    80105c04 <sys_link+0x5c>
    return -1;
80105bfa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bff:	e9 1e 01 00 00       	jmp    80105d22 <sys_link+0x17a>

  begin_trans();
80105c04:	e8 24 d9 ff ff       	call   8010352d <begin_trans>

  ilock(ip);
80105c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0c:	89 04 24             	mov    %eax,(%esp)
80105c0f:	e8 64 bf ff ff       	call   80101b78 <ilock>
  if(ip->type == T_DIR){
80105c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c17:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c1b:	66 83 f8 01          	cmp    $0x1,%ax
80105c1f:	75 1a                	jne    80105c3b <sys_link+0x93>
    iunlockput(ip);
80105c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c24:	89 04 24             	mov    %eax,(%esp)
80105c27:	e8 d0 c1 ff ff       	call   80101dfc <iunlockput>
    commit_trans();
80105c2c:	e8 45 d9 ff ff       	call   80103576 <commit_trans>
    return -1;
80105c31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c36:	e9 e7 00 00 00       	jmp    80105d22 <sys_link+0x17a>
  }

  ip->nlink++;
80105c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c42:	8d 50 01             	lea    0x1(%eax),%edx
80105c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c48:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4f:	89 04 24             	mov    %eax,(%esp)
80105c52:	e8 65 bd ff ff       	call   801019bc <iupdate>
  iunlock(ip);
80105c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5a:	89 04 24             	mov    %eax,(%esp)
80105c5d:	e8 64 c0 ff ff       	call   80101cc6 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105c62:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c65:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105c68:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c6c:	89 04 24             	mov    %eax,(%esp)
80105c6f:	e8 c8 ca ff ff       	call   8010273c <nameiparent>
80105c74:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c7b:	74 68                	je     80105ce5 <sys_link+0x13d>
    goto bad;
  ilock(dp);
80105c7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c80:	89 04 24             	mov    %eax,(%esp)
80105c83:	e8 f0 be ff ff       	call   80101b78 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105c88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8b:	8b 10                	mov    (%eax),%edx
80105c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c90:	8b 00                	mov    (%eax),%eax
80105c92:	39 c2                	cmp    %eax,%edx
80105c94:	75 20                	jne    80105cb6 <sys_link+0x10e>
80105c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c99:	8b 40 04             	mov    0x4(%eax),%eax
80105c9c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ca0:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105caa:	89 04 24             	mov    %eax,(%esp)
80105cad:	e8 a7 c7 ff ff       	call   80102459 <dirlink>
80105cb2:	85 c0                	test   %eax,%eax
80105cb4:	79 0d                	jns    80105cc3 <sys_link+0x11b>
    iunlockput(dp);
80105cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb9:	89 04 24             	mov    %eax,(%esp)
80105cbc:	e8 3b c1 ff ff       	call   80101dfc <iunlockput>
    goto bad;
80105cc1:	eb 23                	jmp    80105ce6 <sys_link+0x13e>
  }
  iunlockput(dp);
80105cc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc6:	89 04 24             	mov    %eax,(%esp)
80105cc9:	e8 2e c1 ff ff       	call   80101dfc <iunlockput>
  iput(ip);
80105cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cd1:	89 04 24             	mov    %eax,(%esp)
80105cd4:	e8 52 c0 ff ff       	call   80101d2b <iput>

  commit_trans();
80105cd9:	e8 98 d8 ff ff       	call   80103576 <commit_trans>

  return 0;
80105cde:	b8 00 00 00 00       	mov    $0x0,%eax
80105ce3:	eb 3d                	jmp    80105d22 <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105ce5:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80105ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce9:	89 04 24             	mov    %eax,(%esp)
80105cec:	e8 87 be ff ff       	call   80101b78 <ilock>
  ip->nlink--;
80105cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105cf8:	8d 50 ff             	lea    -0x1(%eax),%edx
80105cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cfe:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d05:	89 04 24             	mov    %eax,(%esp)
80105d08:	e8 af bc ff ff       	call   801019bc <iupdate>
  iunlockput(ip);
80105d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d10:	89 04 24             	mov    %eax,(%esp)
80105d13:	e8 e4 c0 ff ff       	call   80101dfc <iunlockput>
  commit_trans();
80105d18:	e8 59 d8 ff ff       	call   80103576 <commit_trans>
  return -1;
80105d1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d22:	c9                   	leave  
80105d23:	c3                   	ret    

80105d24 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105d24:	55                   	push   %ebp
80105d25:	89 e5                	mov    %esp,%ebp
80105d27:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d2a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105d31:	eb 4b                	jmp    80105d7e <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d36:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d3d:	00 
80105d3e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d42:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d45:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d49:	8b 45 08             	mov    0x8(%ebp),%eax
80105d4c:	89 04 24             	mov    %eax,(%esp)
80105d4f:	e8 1a c3 ff ff       	call   8010206e <readi>
80105d54:	83 f8 10             	cmp    $0x10,%eax
80105d57:	74 0c                	je     80105d65 <isdirempty+0x41>
      panic("isdirempty: readi");
80105d59:	c7 04 24 4b 8c 10 80 	movl   $0x80108c4b,(%esp)
80105d60:	e8 d8 a7 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105d65:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105d69:	66 85 c0             	test   %ax,%ax
80105d6c:	74 07                	je     80105d75 <isdirempty+0x51>
      return 0;
80105d6e:	b8 00 00 00 00       	mov    $0x0,%eax
80105d73:	eb 1b                	jmp    80105d90 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d78:	83 c0 10             	add    $0x10,%eax
80105d7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d81:	8b 45 08             	mov    0x8(%ebp),%eax
80105d84:	8b 40 18             	mov    0x18(%eax),%eax
80105d87:	39 c2                	cmp    %eax,%edx
80105d89:	72 a8                	jb     80105d33 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105d8b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105d90:	c9                   	leave  
80105d91:	c3                   	ret    

80105d92 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105d92:	55                   	push   %ebp
80105d93:	89 e5                	mov    %esp,%ebp
80105d95:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105d98:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105da6:	e8 35 fa ff ff       	call   801057e0 <argstr>
80105dab:	85 c0                	test   %eax,%eax
80105dad:	79 0a                	jns    80105db9 <sys_unlink+0x27>
    return -1;
80105daf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105db4:	e9 aa 01 00 00       	jmp    80105f63 <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105db9:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105dbc:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105dbf:	89 54 24 04          	mov    %edx,0x4(%esp)
80105dc3:	89 04 24             	mov    %eax,(%esp)
80105dc6:	e8 71 c9 ff ff       	call   8010273c <nameiparent>
80105dcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dd2:	75 0a                	jne    80105dde <sys_unlink+0x4c>
    return -1;
80105dd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd9:	e9 85 01 00 00       	jmp    80105f63 <sys_unlink+0x1d1>

  begin_trans();
80105dde:	e8 4a d7 ff ff       	call   8010352d <begin_trans>

  ilock(dp);
80105de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de6:	89 04 24             	mov    %eax,(%esp)
80105de9:	e8 8a bd ff ff       	call   80101b78 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105dee:	c7 44 24 04 5d 8c 10 	movl   $0x80108c5d,0x4(%esp)
80105df5:	80 
80105df6:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105df9:	89 04 24             	mov    %eax,(%esp)
80105dfc:	e8 6e c5 ff ff       	call   8010236f <namecmp>
80105e01:	85 c0                	test   %eax,%eax
80105e03:	0f 84 45 01 00 00    	je     80105f4e <sys_unlink+0x1bc>
80105e09:	c7 44 24 04 5f 8c 10 	movl   $0x80108c5f,0x4(%esp)
80105e10:	80 
80105e11:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e14:	89 04 24             	mov    %eax,(%esp)
80105e17:	e8 53 c5 ff ff       	call   8010236f <namecmp>
80105e1c:	85 c0                	test   %eax,%eax
80105e1e:	0f 84 2a 01 00 00    	je     80105f4e <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105e24:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105e27:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e2b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e35:	89 04 24             	mov    %eax,(%esp)
80105e38:	e8 54 c5 ff ff       	call   80102391 <dirlookup>
80105e3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e44:	0f 84 03 01 00 00    	je     80105f4d <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80105e4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4d:	89 04 24             	mov    %eax,(%esp)
80105e50:	e8 23 bd ff ff       	call   80101b78 <ilock>

  if(ip->nlink < 1)
80105e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e58:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e5c:	66 85 c0             	test   %ax,%ax
80105e5f:	7f 0c                	jg     80105e6d <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80105e61:	c7 04 24 62 8c 10 80 	movl   $0x80108c62,(%esp)
80105e68:	e8 d0 a6 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e70:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e74:	66 83 f8 01          	cmp    $0x1,%ax
80105e78:	75 1f                	jne    80105e99 <sys_unlink+0x107>
80105e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e7d:	89 04 24             	mov    %eax,(%esp)
80105e80:	e8 9f fe ff ff       	call   80105d24 <isdirempty>
80105e85:	85 c0                	test   %eax,%eax
80105e87:	75 10                	jne    80105e99 <sys_unlink+0x107>
    iunlockput(ip);
80105e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e8c:	89 04 24             	mov    %eax,(%esp)
80105e8f:	e8 68 bf ff ff       	call   80101dfc <iunlockput>
    goto bad;
80105e94:	e9 b5 00 00 00       	jmp    80105f4e <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105e99:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105ea0:	00 
80105ea1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ea8:	00 
80105ea9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105eac:	89 04 24             	mov    %eax,(%esp)
80105eaf:	e8 42 f5 ff ff       	call   801053f6 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105eb4:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105eb7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105ebe:	00 
80105ebf:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ec3:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ec6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ecd:	89 04 24             	mov    %eax,(%esp)
80105ed0:	e8 04 c3 ff ff       	call   801021d9 <writei>
80105ed5:	83 f8 10             	cmp    $0x10,%eax
80105ed8:	74 0c                	je     80105ee6 <sys_unlink+0x154>
    panic("unlink: writei");
80105eda:	c7 04 24 74 8c 10 80 	movl   $0x80108c74,(%esp)
80105ee1:	e8 57 a6 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105eed:	66 83 f8 01          	cmp    $0x1,%ax
80105ef1:	75 1c                	jne    80105f0f <sys_unlink+0x17d>
    dp->nlink--;
80105ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105efa:	8d 50 ff             	lea    -0x1(%eax),%edx
80105efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f00:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f07:	89 04 24             	mov    %eax,(%esp)
80105f0a:	e8 ad ba ff ff       	call   801019bc <iupdate>
  }
  iunlockput(dp);
80105f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f12:	89 04 24             	mov    %eax,(%esp)
80105f15:	e8 e2 be ff ff       	call   80101dfc <iunlockput>

  ip->nlink--;
80105f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f21:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f27:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105f2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f2e:	89 04 24             	mov    %eax,(%esp)
80105f31:	e8 86 ba ff ff       	call   801019bc <iupdate>
  iunlockput(ip);
80105f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f39:	89 04 24             	mov    %eax,(%esp)
80105f3c:	e8 bb be ff ff       	call   80101dfc <iunlockput>

  commit_trans();
80105f41:	e8 30 d6 ff ff       	call   80103576 <commit_trans>

  return 0;
80105f46:	b8 00 00 00 00       	mov    $0x0,%eax
80105f4b:	eb 16                	jmp    80105f63 <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105f4d:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80105f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f51:	89 04 24             	mov    %eax,(%esp)
80105f54:	e8 a3 be ff ff       	call   80101dfc <iunlockput>
  commit_trans();
80105f59:	e8 18 d6 ff ff       	call   80103576 <commit_trans>
  return -1;
80105f5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f63:	c9                   	leave  
80105f64:	c3                   	ret    

80105f65 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105f65:	55                   	push   %ebp
80105f66:	89 e5                	mov    %esp,%ebp
80105f68:	83 ec 48             	sub    $0x48,%esp
80105f6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105f6e:	8b 55 10             	mov    0x10(%ebp),%edx
80105f71:	8b 45 14             	mov    0x14(%ebp),%eax
80105f74:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105f78:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105f7c:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105f80:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f83:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f87:	8b 45 08             	mov    0x8(%ebp),%eax
80105f8a:	89 04 24             	mov    %eax,(%esp)
80105f8d:	e8 aa c7 ff ff       	call   8010273c <nameiparent>
80105f92:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f95:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f99:	75 0a                	jne    80105fa5 <create+0x40>
    return 0;
80105f9b:	b8 00 00 00 00       	mov    $0x0,%eax
80105fa0:	e9 7e 01 00 00       	jmp    80106123 <create+0x1be>
  ilock(dp);
80105fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa8:	89 04 24             	mov    %eax,(%esp)
80105fab:	e8 c8 bb ff ff       	call   80101b78 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105fb0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fb3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fb7:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fba:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc1:	89 04 24             	mov    %eax,(%esp)
80105fc4:	e8 c8 c3 ff ff       	call   80102391 <dirlookup>
80105fc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fcc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fd0:	74 47                	je     80106019 <create+0xb4>
    iunlockput(dp);
80105fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd5:	89 04 24             	mov    %eax,(%esp)
80105fd8:	e8 1f be ff ff       	call   80101dfc <iunlockput>
    ilock(ip);
80105fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe0:	89 04 24             	mov    %eax,(%esp)
80105fe3:	e8 90 bb ff ff       	call   80101b78 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105fe8:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105fed:	75 15                	jne    80106004 <create+0x9f>
80105fef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ff6:	66 83 f8 02          	cmp    $0x2,%ax
80105ffa:	75 08                	jne    80106004 <create+0x9f>
      return ip;
80105ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fff:	e9 1f 01 00 00       	jmp    80106123 <create+0x1be>
    iunlockput(ip);
80106004:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106007:	89 04 24             	mov    %eax,(%esp)
8010600a:	e8 ed bd ff ff       	call   80101dfc <iunlockput>
    return 0;
8010600f:	b8 00 00 00 00       	mov    $0x0,%eax
80106014:	e9 0a 01 00 00       	jmp    80106123 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106019:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010601d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106020:	8b 00                	mov    (%eax),%eax
80106022:	89 54 24 04          	mov    %edx,0x4(%esp)
80106026:	89 04 24             	mov    %eax,(%esp)
80106029:	e8 b1 b8 ff ff       	call   801018df <ialloc>
8010602e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106031:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106035:	75 0c                	jne    80106043 <create+0xde>
    panic("create: ialloc");
80106037:	c7 04 24 83 8c 10 80 	movl   $0x80108c83,(%esp)
8010603e:	e8 fa a4 ff ff       	call   8010053d <panic>

  ilock(ip);
80106043:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106046:	89 04 24             	mov    %eax,(%esp)
80106049:	e8 2a bb ff ff       	call   80101b78 <ilock>
  ip->major = major;
8010604e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106051:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106055:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106059:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605c:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106060:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106064:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106067:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
8010606d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106070:	89 04 24             	mov    %eax,(%esp)
80106073:	e8 44 b9 ff ff       	call   801019bc <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106078:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010607d:	75 6a                	jne    801060e9 <create+0x184>
    dp->nlink++;  // for ".."
8010607f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106082:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106086:	8d 50 01             	lea    0x1(%eax),%edx
80106089:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608c:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106090:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106093:	89 04 24             	mov    %eax,(%esp)
80106096:	e8 21 b9 ff ff       	call   801019bc <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010609b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609e:	8b 40 04             	mov    0x4(%eax),%eax
801060a1:	89 44 24 08          	mov    %eax,0x8(%esp)
801060a5:	c7 44 24 04 5d 8c 10 	movl   $0x80108c5d,0x4(%esp)
801060ac:	80 
801060ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b0:	89 04 24             	mov    %eax,(%esp)
801060b3:	e8 a1 c3 ff ff       	call   80102459 <dirlink>
801060b8:	85 c0                	test   %eax,%eax
801060ba:	78 21                	js     801060dd <create+0x178>
801060bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060bf:	8b 40 04             	mov    0x4(%eax),%eax
801060c2:	89 44 24 08          	mov    %eax,0x8(%esp)
801060c6:	c7 44 24 04 5f 8c 10 	movl   $0x80108c5f,0x4(%esp)
801060cd:	80 
801060ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d1:	89 04 24             	mov    %eax,(%esp)
801060d4:	e8 80 c3 ff ff       	call   80102459 <dirlink>
801060d9:	85 c0                	test   %eax,%eax
801060db:	79 0c                	jns    801060e9 <create+0x184>
      panic("create dots");
801060dd:	c7 04 24 92 8c 10 80 	movl   $0x80108c92,(%esp)
801060e4:	e8 54 a4 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801060e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ec:	8b 40 04             	mov    0x4(%eax),%eax
801060ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801060f3:	8d 45 de             	lea    -0x22(%ebp),%eax
801060f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801060fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060fd:	89 04 24             	mov    %eax,(%esp)
80106100:	e8 54 c3 ff ff       	call   80102459 <dirlink>
80106105:	85 c0                	test   %eax,%eax
80106107:	79 0c                	jns    80106115 <create+0x1b0>
    panic("create: dirlink");
80106109:	c7 04 24 9e 8c 10 80 	movl   $0x80108c9e,(%esp)
80106110:	e8 28 a4 ff ff       	call   8010053d <panic>

  iunlockput(dp);
80106115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106118:	89 04 24             	mov    %eax,(%esp)
8010611b:	e8 dc bc ff ff       	call   80101dfc <iunlockput>

  return ip;
80106120:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106123:	c9                   	leave  
80106124:	c3                   	ret    

80106125 <sys_open>:

int
sys_open(void)
{
80106125:	55                   	push   %ebp
80106126:	89 e5                	mov    %esp,%ebp
80106128:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010612b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010612e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106132:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106139:	e8 a2 f6 ff ff       	call   801057e0 <argstr>
8010613e:	85 c0                	test   %eax,%eax
80106140:	78 17                	js     80106159 <sys_open+0x34>
80106142:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106145:	89 44 24 04          	mov    %eax,0x4(%esp)
80106149:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106150:	e8 f1 f5 ff ff       	call   80105746 <argint>
80106155:	85 c0                	test   %eax,%eax
80106157:	79 0a                	jns    80106163 <sys_open+0x3e>
    return -1;
80106159:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010615e:	e9 46 01 00 00       	jmp    801062a9 <sys_open+0x184>
  if(omode & O_CREATE){
80106163:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106166:	25 00 02 00 00       	and    $0x200,%eax
8010616b:	85 c0                	test   %eax,%eax
8010616d:	74 40                	je     801061af <sys_open+0x8a>
    begin_trans();
8010616f:	e8 b9 d3 ff ff       	call   8010352d <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80106174:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106177:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010617e:	00 
8010617f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106186:	00 
80106187:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010618e:	00 
8010618f:	89 04 24             	mov    %eax,(%esp)
80106192:	e8 ce fd ff ff       	call   80105f65 <create>
80106197:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
8010619a:	e8 d7 d3 ff ff       	call   80103576 <commit_trans>
    if(ip == 0)
8010619f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061a3:	75 5c                	jne    80106201 <sys_open+0xdc>
      return -1;
801061a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061aa:	e9 fa 00 00 00       	jmp    801062a9 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
801061af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061b2:	89 04 24             	mov    %eax,(%esp)
801061b5:	e8 60 c5 ff ff       	call   8010271a <namei>
801061ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061c1:	75 0a                	jne    801061cd <sys_open+0xa8>
      return -1;
801061c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c8:	e9 dc 00 00 00       	jmp    801062a9 <sys_open+0x184>
    ilock(ip);
801061cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d0:	89 04 24             	mov    %eax,(%esp)
801061d3:	e8 a0 b9 ff ff       	call   80101b78 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801061d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061db:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061df:	66 83 f8 01          	cmp    $0x1,%ax
801061e3:	75 1c                	jne    80106201 <sys_open+0xdc>
801061e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061e8:	85 c0                	test   %eax,%eax
801061ea:	74 15                	je     80106201 <sys_open+0xdc>
      iunlockput(ip);
801061ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ef:	89 04 24             	mov    %eax,(%esp)
801061f2:	e8 05 bc ff ff       	call   80101dfc <iunlockput>
      return -1;
801061f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061fc:	e9 a8 00 00 00       	jmp    801062a9 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106201:	e8 26 b0 ff ff       	call   8010122c <filealloc>
80106206:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106209:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010620d:	74 14                	je     80106223 <sys_open+0xfe>
8010620f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106212:	89 04 24             	mov    %eax,(%esp)
80106215:	e8 43 f7 ff ff       	call   8010595d <fdalloc>
8010621a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010621d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106221:	79 23                	jns    80106246 <sys_open+0x121>
    if(f)
80106223:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106227:	74 0b                	je     80106234 <sys_open+0x10f>
      fileclose(f);
80106229:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010622c:	89 04 24             	mov    %eax,(%esp)
8010622f:	e8 a0 b0 ff ff       	call   801012d4 <fileclose>
    iunlockput(ip);
80106234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106237:	89 04 24             	mov    %eax,(%esp)
8010623a:	e8 bd bb ff ff       	call   80101dfc <iunlockput>
    return -1;
8010623f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106244:	eb 63                	jmp    801062a9 <sys_open+0x184>
  }
  iunlock(ip);
80106246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106249:	89 04 24             	mov    %eax,(%esp)
8010624c:	e8 75 ba ff ff       	call   80101cc6 <iunlock>

  f->type = FD_INODE;
80106251:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106254:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010625a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010625d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106260:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106263:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106266:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010626d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106270:	83 e0 01             	and    $0x1,%eax
80106273:	85 c0                	test   %eax,%eax
80106275:	0f 94 c2             	sete   %dl
80106278:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010627b:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010627e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106281:	83 e0 01             	and    $0x1,%eax
80106284:	84 c0                	test   %al,%al
80106286:	75 0a                	jne    80106292 <sys_open+0x16d>
80106288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010628b:	83 e0 02             	and    $0x2,%eax
8010628e:	85 c0                	test   %eax,%eax
80106290:	74 07                	je     80106299 <sys_open+0x174>
80106292:	b8 01 00 00 00       	mov    $0x1,%eax
80106297:	eb 05                	jmp    8010629e <sys_open+0x179>
80106299:	b8 00 00 00 00       	mov    $0x0,%eax
8010629e:	89 c2                	mov    %eax,%edx
801062a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062a3:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801062a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801062a9:	c9                   	leave  
801062aa:	c3                   	ret    

801062ab <sys_mkdir>:

int
sys_mkdir(void)
{
801062ab:	55                   	push   %ebp
801062ac:	89 e5                	mov    %esp,%ebp
801062ae:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
801062b1:	e8 77 d2 ff ff       	call   8010352d <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801062b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801062bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062c4:	e8 17 f5 ff ff       	call   801057e0 <argstr>
801062c9:	85 c0                	test   %eax,%eax
801062cb:	78 2c                	js     801062f9 <sys_mkdir+0x4e>
801062cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801062d7:	00 
801062d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801062df:	00 
801062e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801062e7:	00 
801062e8:	89 04 24             	mov    %eax,(%esp)
801062eb:	e8 75 fc ff ff       	call   80105f65 <create>
801062f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062f7:	75 0c                	jne    80106305 <sys_mkdir+0x5a>
    commit_trans();
801062f9:	e8 78 d2 ff ff       	call   80103576 <commit_trans>
    return -1;
801062fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106303:	eb 15                	jmp    8010631a <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106308:	89 04 24             	mov    %eax,(%esp)
8010630b:	e8 ec ba ff ff       	call   80101dfc <iunlockput>
  commit_trans();
80106310:	e8 61 d2 ff ff       	call   80103576 <commit_trans>
  return 0;
80106315:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010631a:	c9                   	leave  
8010631b:	c3                   	ret    

8010631c <sys_mknod>:

int
sys_mknod(void)
{
8010631c:	55                   	push   %ebp
8010631d:	89 e5                	mov    %esp,%ebp
8010631f:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80106322:	e8 06 d2 ff ff       	call   8010352d <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80106327:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010632a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010632e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106335:	e8 a6 f4 ff ff       	call   801057e0 <argstr>
8010633a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010633d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106341:	78 5e                	js     801063a1 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106343:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106346:	89 44 24 04          	mov    %eax,0x4(%esp)
8010634a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106351:	e8 f0 f3 ff ff       	call   80105746 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
80106356:	85 c0                	test   %eax,%eax
80106358:	78 47                	js     801063a1 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010635a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010635d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106361:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106368:	e8 d9 f3 ff ff       	call   80105746 <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010636d:	85 c0                	test   %eax,%eax
8010636f:	78 30                	js     801063a1 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106371:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106374:	0f bf c8             	movswl %ax,%ecx
80106377:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010637a:	0f bf d0             	movswl %ax,%edx
8010637d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106380:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106384:	89 54 24 08          	mov    %edx,0x8(%esp)
80106388:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010638f:	00 
80106390:	89 04 24             	mov    %eax,(%esp)
80106393:	e8 cd fb ff ff       	call   80105f65 <create>
80106398:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010639b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010639f:	75 0c                	jne    801063ad <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
801063a1:	e8 d0 d1 ff ff       	call   80103576 <commit_trans>
    return -1;
801063a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ab:	eb 15                	jmp    801063c2 <sys_mknod+0xa6>
  }
  iunlockput(ip);
801063ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b0:	89 04 24             	mov    %eax,(%esp)
801063b3:	e8 44 ba ff ff       	call   80101dfc <iunlockput>
  commit_trans();
801063b8:	e8 b9 d1 ff ff       	call   80103576 <commit_trans>
  return 0;
801063bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063c2:	c9                   	leave  
801063c3:	c3                   	ret    

801063c4 <sys_chdir>:

int
sys_chdir(void)
{
801063c4:	55                   	push   %ebp
801063c5:	89 e5                	mov    %esp,%ebp
801063c7:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
801063ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801063d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063d8:	e8 03 f4 ff ff       	call   801057e0 <argstr>
801063dd:	85 c0                	test   %eax,%eax
801063df:	78 14                	js     801063f5 <sys_chdir+0x31>
801063e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e4:	89 04 24             	mov    %eax,(%esp)
801063e7:	e8 2e c3 ff ff       	call   8010271a <namei>
801063ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063f3:	75 07                	jne    801063fc <sys_chdir+0x38>
    return -1;
801063f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063fa:	eb 57                	jmp    80106453 <sys_chdir+0x8f>
  ilock(ip);
801063fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063ff:	89 04 24             	mov    %eax,(%esp)
80106402:	e8 71 b7 ff ff       	call   80101b78 <ilock>
  if(ip->type != T_DIR){
80106407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010640e:	66 83 f8 01          	cmp    $0x1,%ax
80106412:	74 12                	je     80106426 <sys_chdir+0x62>
    iunlockput(ip);
80106414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106417:	89 04 24             	mov    %eax,(%esp)
8010641a:	e8 dd b9 ff ff       	call   80101dfc <iunlockput>
    return -1;
8010641f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106424:	eb 2d                	jmp    80106453 <sys_chdir+0x8f>
  }
  iunlock(ip);
80106426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106429:	89 04 24             	mov    %eax,(%esp)
8010642c:	e8 95 b8 ff ff       	call   80101cc6 <iunlock>
  iput(proc->cwd);
80106431:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106437:	8b 40 68             	mov    0x68(%eax),%eax
8010643a:	89 04 24             	mov    %eax,(%esp)
8010643d:	e8 e9 b8 ff ff       	call   80101d2b <iput>
  proc->cwd = ip;
80106442:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106448:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010644b:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010644e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106453:	c9                   	leave  
80106454:	c3                   	ret    

80106455 <sys_exec>:

int
sys_exec(void)
{
80106455:	55                   	push   %ebp
80106456:	89 e5                	mov    %esp,%ebp
80106458:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010645e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106461:	89 44 24 04          	mov    %eax,0x4(%esp)
80106465:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010646c:	e8 6f f3 ff ff       	call   801057e0 <argstr>
80106471:	85 c0                	test   %eax,%eax
80106473:	78 1a                	js     8010648f <sys_exec+0x3a>
80106475:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010647b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010647f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106486:	e8 bb f2 ff ff       	call   80105746 <argint>
8010648b:	85 c0                	test   %eax,%eax
8010648d:	79 0a                	jns    80106499 <sys_exec+0x44>
    return -1;
8010648f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106494:	e9 e2 00 00 00       	jmp    8010657b <sys_exec+0x126>
  }
  memset(argv, 0, sizeof(argv));
80106499:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801064a0:	00 
801064a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801064a8:	00 
801064a9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064af:	89 04 24             	mov    %eax,(%esp)
801064b2:	e8 3f ef ff ff       	call   801053f6 <memset>
  for(i=0;; i++){
801064b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801064be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c1:	83 f8 1f             	cmp    $0x1f,%eax
801064c4:	76 0a                	jbe    801064d0 <sys_exec+0x7b>
      return -1;
801064c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064cb:	e9 ab 00 00 00       	jmp    8010657b <sys_exec+0x126>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
801064d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d3:	c1 e0 02             	shl    $0x2,%eax
801064d6:	89 c2                	mov    %eax,%edx
801064d8:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801064de:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801064e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064e7:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
801064ed:	89 54 24 08          	mov    %edx,0x8(%esp)
801064f1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801064f5:	89 04 24             	mov    %eax,(%esp)
801064f8:	e8 b7 f1 ff ff       	call   801056b4 <fetchint>
801064fd:	85 c0                	test   %eax,%eax
801064ff:	79 07                	jns    80106508 <sys_exec+0xb3>
      return -1;
80106501:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106506:	eb 73                	jmp    8010657b <sys_exec+0x126>
    if(uarg == 0){
80106508:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010650e:	85 c0                	test   %eax,%eax
80106510:	75 26                	jne    80106538 <sys_exec+0xe3>
      argv[i] = 0;
80106512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106515:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010651c:	00 00 00 00 
      break;
80106520:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106521:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106524:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010652a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010652e:	89 04 24             	mov    %eax,(%esp)
80106531:	e8 d6 a8 ff ff       	call   80100e0c <exec>
80106536:	eb 43                	jmp    8010657b <sys_exec+0x126>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
80106538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010653b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106542:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106548:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
8010654b:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106551:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106557:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010655b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010655f:	89 04 24             	mov    %eax,(%esp)
80106562:	e8 81 f1 ff ff       	call   801056e8 <fetchstr>
80106567:	85 c0                	test   %eax,%eax
80106569:	79 07                	jns    80106572 <sys_exec+0x11d>
      return -1;
8010656b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106570:	eb 09                	jmp    8010657b <sys_exec+0x126>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106572:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
80106576:	e9 43 ff ff ff       	jmp    801064be <sys_exec+0x69>
  return exec(path, argv);
}
8010657b:	c9                   	leave  
8010657c:	c3                   	ret    

8010657d <sys_pipe>:

int
sys_pipe(void)
{
8010657d:	55                   	push   %ebp
8010657e:	89 e5                	mov    %esp,%ebp
80106580:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106583:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
8010658a:	00 
8010658b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010658e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106592:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106599:	e8 e0 f1 ff ff       	call   8010577e <argptr>
8010659e:	85 c0                	test   %eax,%eax
801065a0:	79 0a                	jns    801065ac <sys_pipe+0x2f>
    return -1;
801065a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a7:	e9 9b 00 00 00       	jmp    80106647 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801065ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065af:	89 44 24 04          	mov    %eax,0x4(%esp)
801065b3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801065b6:	89 04 24             	mov    %eax,(%esp)
801065b9:	e8 8a d9 ff ff       	call   80103f48 <pipealloc>
801065be:	85 c0                	test   %eax,%eax
801065c0:	79 07                	jns    801065c9 <sys_pipe+0x4c>
    return -1;
801065c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c7:	eb 7e                	jmp    80106647 <sys_pipe+0xca>
  fd0 = -1;
801065c9:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801065d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065d3:	89 04 24             	mov    %eax,(%esp)
801065d6:	e8 82 f3 ff ff       	call   8010595d <fdalloc>
801065db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065e2:	78 14                	js     801065f8 <sys_pipe+0x7b>
801065e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065e7:	89 04 24             	mov    %eax,(%esp)
801065ea:	e8 6e f3 ff ff       	call   8010595d <fdalloc>
801065ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065f6:	79 37                	jns    8010662f <sys_pipe+0xb2>
    if(fd0 >= 0)
801065f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065fc:	78 14                	js     80106612 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801065fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106604:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106607:	83 c2 08             	add    $0x8,%edx
8010660a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106611:	00 
    fileclose(rf);
80106612:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106615:	89 04 24             	mov    %eax,(%esp)
80106618:	e8 b7 ac ff ff       	call   801012d4 <fileclose>
    fileclose(wf);
8010661d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106620:	89 04 24             	mov    %eax,(%esp)
80106623:	e8 ac ac ff ff       	call   801012d4 <fileclose>
    return -1;
80106628:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010662d:	eb 18                	jmp    80106647 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010662f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106632:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106635:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106637:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010663a:	8d 50 04             	lea    0x4(%eax),%edx
8010663d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106640:	89 02                	mov    %eax,(%edx)
  return 0;
80106642:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106647:	c9                   	leave  
80106648:	c3                   	ret    
80106649:	00 00                	add    %al,(%eax)
	...

8010664c <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010664c:	55                   	push   %ebp
8010664d:	89 e5                	mov    %esp,%ebp
8010664f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106652:	e8 ae df ff ff       	call   80104605 <fork>
}
80106657:	c9                   	leave  
80106658:	c3                   	ret    

80106659 <sys_exit>:

int
sys_exit(void)
{
80106659:	55                   	push   %ebp
8010665a:	89 e5                	mov    %esp,%ebp
8010665c:	83 ec 08             	sub    $0x8,%esp
  exit();
8010665f:	e8 36 e1 ff ff       	call   8010479a <exit>
  return 0;  // not reached
80106664:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106669:	c9                   	leave  
8010666a:	c3                   	ret    

8010666b <sys_wait>:

int
sys_wait(void)
{
8010666b:	55                   	push   %ebp
8010666c:	89 e5                	mov    %esp,%ebp
8010666e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106671:	e8 79 e2 ff ff       	call   801048ef <wait>
}
80106676:	c9                   	leave  
80106677:	c3                   	ret    

80106678 <sys_wait2>:

int
sys_wait2(void)
{
80106678:	55                   	push   %ebp
80106679:	89 e5                	mov    %esp,%ebp
8010667b:	83 ec 28             	sub    $0x28,%esp
  char *rtime=0;
8010667e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  char *wtime=0;
80106685:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  argptr(1,&rtime,sizeof(rtime));
8010668c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106693:	00 
80106694:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106697:	89 44 24 04          	mov    %eax,0x4(%esp)
8010669b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801066a2:	e8 d7 f0 ff ff       	call   8010577e <argptr>
  argptr(0,&wtime,sizeof(wtime));
801066a7:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801066ae:	00 
801066af:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801066b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066bd:	e8 bc f0 ff ff       	call   8010577e <argptr>
  return wait2((int*)wtime, (int*)rtime);
801066c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066c8:	89 54 24 04          	mov    %edx,0x4(%esp)
801066cc:	89 04 24             	mov    %eax,(%esp)
801066cf:	e8 2d e3 ff ff       	call   80104a01 <wait2>
}
801066d4:	c9                   	leave  
801066d5:	c3                   	ret    

801066d6 <sys_nice>:

int
sys_nice(void)
{
801066d6:	55                   	push   %ebp
801066d7:	89 e5                	mov    %esp,%ebp
801066d9:	83 ec 08             	sub    $0x8,%esp
  return nice();
801066dc:	e8 db e9 ff ff       	call   801050bc <nice>
}
801066e1:	c9                   	leave  
801066e2:	c3                   	ret    

801066e3 <sys_kill>:
int
sys_kill(void)
{
801066e3:	55                   	push   %ebp
801066e4:	89 e5                	mov    %esp,%ebp
801066e6:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801066e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801066f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066f7:	e8 4a f0 ff ff       	call   80105746 <argint>
801066fc:	85 c0                	test   %eax,%eax
801066fe:	79 07                	jns    80106707 <sys_kill+0x24>
    return -1;
80106700:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106705:	eb 0b                	jmp    80106712 <sys_kill+0x2f>
  return kill(pid);
80106707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670a:	89 04 24             	mov    %eax,(%esp)
8010670d:	e8 33 e8 ff ff       	call   80104f45 <kill>
}
80106712:	c9                   	leave  
80106713:	c3                   	ret    

80106714 <sys_getpid>:

int
sys_getpid(void)
{
80106714:	55                   	push   %ebp
80106715:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106717:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010671d:	8b 40 10             	mov    0x10(%eax),%eax
}
80106720:	5d                   	pop    %ebp
80106721:	c3                   	ret    

80106722 <sys_sbrk>:

int
sys_sbrk(void)
{
80106722:	55                   	push   %ebp
80106723:	89 e5                	mov    %esp,%ebp
80106725:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106728:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010672b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010672f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106736:	e8 0b f0 ff ff       	call   80105746 <argint>
8010673b:	85 c0                	test   %eax,%eax
8010673d:	79 07                	jns    80106746 <sys_sbrk+0x24>
    return -1;
8010673f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106744:	eb 24                	jmp    8010676a <sys_sbrk+0x48>
  addr = proc->sz;
80106746:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010674c:	8b 00                	mov    (%eax),%eax
8010674e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106751:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106754:	89 04 24             	mov    %eax,(%esp)
80106757:	e8 04 de ff ff       	call   80104560 <growproc>
8010675c:	85 c0                	test   %eax,%eax
8010675e:	79 07                	jns    80106767 <sys_sbrk+0x45>
    return -1;
80106760:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106765:	eb 03                	jmp    8010676a <sys_sbrk+0x48>
  return addr;
80106767:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010676a:	c9                   	leave  
8010676b:	c3                   	ret    

8010676c <sys_sleep>:

int
sys_sleep(void)
{
8010676c:	55                   	push   %ebp
8010676d:	89 e5                	mov    %esp,%ebp
8010676f:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106772:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106775:	89 44 24 04          	mov    %eax,0x4(%esp)
80106779:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106780:	e8 c1 ef ff ff       	call   80105746 <argint>
80106785:	85 c0                	test   %eax,%eax
80106787:	79 07                	jns    80106790 <sys_sleep+0x24>
    return -1;
80106789:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010678e:	eb 6c                	jmp    801067fc <sys_sleep+0x90>
  acquire(&tickslock);
80106790:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106797:	e8 0b ea ff ff       	call   801051a7 <acquire>
  ticks0 = ticks;
8010679c:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
801067a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801067a4:	eb 34                	jmp    801067da <sys_sleep+0x6e>
    if(proc->killed){
801067a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067ac:	8b 40 24             	mov    0x24(%eax),%eax
801067af:	85 c0                	test   %eax,%eax
801067b1:	74 13                	je     801067c6 <sys_sleep+0x5a>
      release(&tickslock);
801067b3:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801067ba:	e8 4a ea ff ff       	call   80105209 <release>
      return -1;
801067bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067c4:	eb 36                	jmp    801067fc <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801067c6:	c7 44 24 04 80 24 11 	movl   $0x80112480,0x4(%esp)
801067cd:	80 
801067ce:	c7 04 24 c0 2c 11 80 	movl   $0x80112cc0,(%esp)
801067d5:	e8 64 e6 ff ff       	call   80104e3e <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801067da:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
801067df:	89 c2                	mov    %eax,%edx
801067e1:	2b 55 f4             	sub    -0xc(%ebp),%edx
801067e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067e7:	39 c2                	cmp    %eax,%edx
801067e9:	72 bb                	jb     801067a6 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801067eb:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
801067f2:	e8 12 ea ff ff       	call   80105209 <release>
  return 0;
801067f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067fc:	c9                   	leave  
801067fd:	c3                   	ret    

801067fe <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801067fe:	55                   	push   %ebp
801067ff:	89 e5                	mov    %esp,%ebp
80106801:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106804:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
8010680b:	e8 97 e9 ff ff       	call   801051a7 <acquire>
  xticks = ticks;
80106810:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
80106815:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106818:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
8010681f:	e8 e5 e9 ff ff       	call   80105209 <release>
  return xticks;
80106824:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106827:	c9                   	leave  
80106828:	c3                   	ret    
80106829:	00 00                	add    %al,(%eax)
	...

8010682c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010682c:	55                   	push   %ebp
8010682d:	89 e5                	mov    %esp,%ebp
8010682f:	83 ec 08             	sub    $0x8,%esp
80106832:	8b 55 08             	mov    0x8(%ebp),%edx
80106835:	8b 45 0c             	mov    0xc(%ebp),%eax
80106838:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010683c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010683f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106843:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106847:	ee                   	out    %al,(%dx)
}
80106848:	c9                   	leave  
80106849:	c3                   	ret    

8010684a <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010684a:	55                   	push   %ebp
8010684b:	89 e5                	mov    %esp,%ebp
8010684d:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106850:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106857:	00 
80106858:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
8010685f:	e8 c8 ff ff ff       	call   8010682c <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106864:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
8010686b:	00 
8010686c:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106873:	e8 b4 ff ff ff       	call   8010682c <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106878:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
8010687f:	00 
80106880:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106887:	e8 a0 ff ff ff       	call   8010682c <outb>
  picenable(IRQ_TIMER);
8010688c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106893:	e8 39 d5 ff ff       	call   80103dd1 <picenable>
}
80106898:	c9                   	leave  
80106899:	c3                   	ret    
	...

8010689c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010689c:	1e                   	push   %ds
  pushl %es
8010689d:	06                   	push   %es
  pushl %fs
8010689e:	0f a0                	push   %fs
  pushl %gs
801068a0:	0f a8                	push   %gs
  pushal
801068a2:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801068a3:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801068a7:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801068a9:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801068ab:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801068af:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801068b1:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801068b3:	54                   	push   %esp
  call trap
801068b4:	e8 de 01 00 00       	call   80106a97 <trap>
  addl $4, %esp
801068b9:	83 c4 04             	add    $0x4,%esp

801068bc <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801068bc:	61                   	popa   
  popl %gs
801068bd:	0f a9                	pop    %gs
  popl %fs
801068bf:	0f a1                	pop    %fs
  popl %es
801068c1:	07                   	pop    %es
  popl %ds
801068c2:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801068c3:	83 c4 08             	add    $0x8,%esp
  iret
801068c6:	cf                   	iret   
	...

801068c8 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801068c8:	55                   	push   %ebp
801068c9:	89 e5                	mov    %esp,%ebp
801068cb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801068ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801068d1:	83 e8 01             	sub    $0x1,%eax
801068d4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801068d8:	8b 45 08             	mov    0x8(%ebp),%eax
801068db:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801068df:	8b 45 08             	mov    0x8(%ebp),%eax
801068e2:	c1 e8 10             	shr    $0x10,%eax
801068e5:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801068e9:	8d 45 fa             	lea    -0x6(%ebp),%eax
801068ec:	0f 01 18             	lidtl  (%eax)
}
801068ef:	c9                   	leave  
801068f0:	c3                   	ret    

801068f1 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801068f1:	55                   	push   %ebp
801068f2:	89 e5                	mov    %esp,%ebp
801068f4:	53                   	push   %ebx
801068f5:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801068f8:	0f 20 d3             	mov    %cr2,%ebx
801068fb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
801068fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106901:	83 c4 10             	add    $0x10,%esp
80106904:	5b                   	pop    %ebx
80106905:	5d                   	pop    %ebp
80106906:	c3                   	ret    

80106907 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106907:	55                   	push   %ebp
80106908:	89 e5                	mov    %esp,%ebp
8010690a:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010690d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106914:	e9 c3 00 00 00       	jmp    801069dc <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010691c:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
80106923:	89 c2                	mov    %eax,%edx
80106925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106928:	66 89 14 c5 c0 24 11 	mov    %dx,-0x7feedb40(,%eax,8)
8010692f:	80 
80106930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106933:	66 c7 04 c5 c2 24 11 	movw   $0x8,-0x7feedb3e(,%eax,8)
8010693a:	80 08 00 
8010693d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106940:	0f b6 14 c5 c4 24 11 	movzbl -0x7feedb3c(,%eax,8),%edx
80106947:	80 
80106948:	83 e2 e0             	and    $0xffffffe0,%edx
8010694b:	88 14 c5 c4 24 11 80 	mov    %dl,-0x7feedb3c(,%eax,8)
80106952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106955:	0f b6 14 c5 c4 24 11 	movzbl -0x7feedb3c(,%eax,8),%edx
8010695c:	80 
8010695d:	83 e2 1f             	and    $0x1f,%edx
80106960:	88 14 c5 c4 24 11 80 	mov    %dl,-0x7feedb3c(,%eax,8)
80106967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010696a:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
80106971:	80 
80106972:	83 e2 f0             	and    $0xfffffff0,%edx
80106975:	83 ca 0e             	or     $0xe,%edx
80106978:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
8010697f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106982:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
80106989:	80 
8010698a:	83 e2 ef             	and    $0xffffffef,%edx
8010698d:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
80106994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106997:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
8010699e:	80 
8010699f:	83 e2 9f             	and    $0xffffff9f,%edx
801069a2:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
801069a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ac:	0f b6 14 c5 c5 24 11 	movzbl -0x7feedb3b(,%eax,8),%edx
801069b3:	80 
801069b4:	83 ca 80             	or     $0xffffff80,%edx
801069b7:	88 14 c5 c5 24 11 80 	mov    %dl,-0x7feedb3b(,%eax,8)
801069be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c1:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
801069c8:	c1 e8 10             	shr    $0x10,%eax
801069cb:	89 c2                	mov    %eax,%edx
801069cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d0:	66 89 14 c5 c6 24 11 	mov    %dx,-0x7feedb3a(,%eax,8)
801069d7:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801069d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069dc:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801069e3:	0f 8e 30 ff ff ff    	jle    80106919 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801069e9:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
801069ee:	66 a3 c0 26 11 80    	mov    %ax,0x801126c0
801069f4:	66 c7 05 c2 26 11 80 	movw   $0x8,0x801126c2
801069fb:	08 00 
801069fd:	0f b6 05 c4 26 11 80 	movzbl 0x801126c4,%eax
80106a04:	83 e0 e0             	and    $0xffffffe0,%eax
80106a07:	a2 c4 26 11 80       	mov    %al,0x801126c4
80106a0c:	0f b6 05 c4 26 11 80 	movzbl 0x801126c4,%eax
80106a13:	83 e0 1f             	and    $0x1f,%eax
80106a16:	a2 c4 26 11 80       	mov    %al,0x801126c4
80106a1b:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a22:	83 c8 0f             	or     $0xf,%eax
80106a25:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a2a:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a31:	83 e0 ef             	and    $0xffffffef,%eax
80106a34:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a39:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a40:	83 c8 60             	or     $0x60,%eax
80106a43:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a48:	0f b6 05 c5 26 11 80 	movzbl 0x801126c5,%eax
80106a4f:	83 c8 80             	or     $0xffffff80,%eax
80106a52:	a2 c5 26 11 80       	mov    %al,0x801126c5
80106a57:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106a5c:	c1 e8 10             	shr    $0x10,%eax
80106a5f:	66 a3 c6 26 11 80    	mov    %ax,0x801126c6
  
  initlock(&tickslock, "time");
80106a65:	c7 44 24 04 b0 8c 10 	movl   $0x80108cb0,0x4(%esp)
80106a6c:	80 
80106a6d:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106a74:	e8 0d e7 ff ff       	call   80105186 <initlock>
}
80106a79:	c9                   	leave  
80106a7a:	c3                   	ret    

80106a7b <idtinit>:

void
idtinit(void)
{
80106a7b:	55                   	push   %ebp
80106a7c:	89 e5                	mov    %esp,%ebp
80106a7e:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106a81:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106a88:	00 
80106a89:	c7 04 24 c0 24 11 80 	movl   $0x801124c0,(%esp)
80106a90:	e8 33 fe ff ff       	call   801068c8 <lidt>
}
80106a95:	c9                   	leave  
80106a96:	c3                   	ret    

80106a97 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106a97:	55                   	push   %ebp
80106a98:	89 e5                	mov    %esp,%ebp
80106a9a:	57                   	push   %edi
80106a9b:	56                   	push   %esi
80106a9c:	53                   	push   %ebx
80106a9d:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa3:	8b 40 30             	mov    0x30(%eax),%eax
80106aa6:	83 f8 40             	cmp    $0x40,%eax
80106aa9:	75 3e                	jne    80106ae9 <trap+0x52>
    if(proc->killed)
80106aab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ab1:	8b 40 24             	mov    0x24(%eax),%eax
80106ab4:	85 c0                	test   %eax,%eax
80106ab6:	74 05                	je     80106abd <trap+0x26>
      exit();
80106ab8:	e8 dd dc ff ff       	call   8010479a <exit>
    proc->tf = tf;
80106abd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ac3:	8b 55 08             	mov    0x8(%ebp),%edx
80106ac6:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106ac9:	e8 55 ed ff ff       	call   80105823 <syscall>
    if(proc->killed)
80106ace:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ad4:	8b 40 24             	mov    0x24(%eax),%eax
80106ad7:	85 c0                	test   %eax,%eax
80106ad9:	0f 84 78 02 00 00    	je     80106d57 <trap+0x2c0>
      exit();
80106adf:	e8 b6 dc ff ff       	call   8010479a <exit>
    return;
80106ae4:	e9 6e 02 00 00       	jmp    80106d57 <trap+0x2c0>
  }

  switch(tf->trapno){
80106ae9:	8b 45 08             	mov    0x8(%ebp),%eax
80106aec:	8b 40 30             	mov    0x30(%eax),%eax
80106aef:	83 e8 20             	sub    $0x20,%eax
80106af2:	83 f8 1f             	cmp    $0x1f,%eax
80106af5:	0f 87 f0 00 00 00    	ja     80106beb <trap+0x154>
80106afb:	8b 04 85 58 8d 10 80 	mov    -0x7fef72a8(,%eax,4),%eax
80106b02:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106b04:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b0a:	0f b6 00             	movzbl (%eax),%eax
80106b0d:	84 c0                	test   %al,%al
80106b0f:	75 65                	jne    80106b76 <trap+0xdf>
      acquire(&tickslock);
80106b11:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106b18:	e8 8a e6 ff ff       	call   801051a7 <acquire>
      ticks++;
80106b1d:	a1 c0 2c 11 80       	mov    0x80112cc0,%eax
80106b22:	83 c0 01             	add    $0x1,%eax
80106b25:	a3 c0 2c 11 80       	mov    %eax,0x80112cc0
      if(proc)
80106b2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b30:	85 c0                	test   %eax,%eax
80106b32:	74 2a                	je     80106b5e <trap+0xc7>
      {
	proc->rtime++;
80106b34:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b3a:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80106b40:	83 c2 01             	add    $0x1,%edx
80106b43:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
	proc->quanta--;
80106b49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b4f:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80106b55:	83 ea 01             	sub    $0x1,%edx
80106b58:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
      }
      wakeup(&ticks);
80106b5e:	c7 04 24 c0 2c 11 80 	movl   $0x80112cc0,(%esp)
80106b65:	e8 b0 e3 ff ff       	call   80104f1a <wakeup>
      release(&tickslock);
80106b6a:	c7 04 24 80 24 11 80 	movl   $0x80112480,(%esp)
80106b71:	e8 93 e6 ff ff       	call   80105209 <release>
    }
    lapiceoi();
80106b76:	e8 7e c6 ff ff       	call   801031f9 <lapiceoi>
    break;
80106b7b:	e9 41 01 00 00       	jmp    80106cc1 <trap+0x22a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106b80:	e8 7c be ff ff       	call   80102a01 <ideintr>
    lapiceoi();
80106b85:	e8 6f c6 ff ff       	call   801031f9 <lapiceoi>
    break;
80106b8a:	e9 32 01 00 00       	jmp    80106cc1 <trap+0x22a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106b8f:	e8 43 c4 ff ff       	call   80102fd7 <kbdintr>
    lapiceoi();
80106b94:	e8 60 c6 ff ff       	call   801031f9 <lapiceoi>
    break;
80106b99:	e9 23 01 00 00       	jmp    80106cc1 <trap+0x22a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106b9e:	e8 b9 03 00 00       	call   80106f5c <uartintr>
    lapiceoi();
80106ba3:	e8 51 c6 ff ff       	call   801031f9 <lapiceoi>
    break;
80106ba8:	e9 14 01 00 00       	jmp    80106cc1 <trap+0x22a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106bad:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bb0:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80106bb6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bba:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106bbd:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106bc3:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bc6:	0f b6 c0             	movzbl %al,%eax
80106bc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106bcd:	89 54 24 08          	mov    %edx,0x8(%esp)
80106bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bd5:	c7 04 24 b8 8c 10 80 	movl   $0x80108cb8,(%esp)
80106bdc:	e8 c0 97 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106be1:	e8 13 c6 ff ff       	call   801031f9 <lapiceoi>
    break;
80106be6:	e9 d6 00 00 00       	jmp    80106cc1 <trap+0x22a>
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106beb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bf1:	85 c0                	test   %eax,%eax
80106bf3:	74 11                	je     80106c06 <trap+0x16f>
80106bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80106bf8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bfc:	0f b7 c0             	movzwl %ax,%eax
80106bff:	83 e0 03             	and    $0x3,%eax
80106c02:	85 c0                	test   %eax,%eax
80106c04:	75 46                	jne    80106c4c <trap+0x1b5>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c06:	e8 e6 fc ff ff       	call   801068f1 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c0b:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c0e:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c11:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106c18:	0f b6 12             	movzbl (%edx),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c1b:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c1e:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c21:	8b 52 30             	mov    0x30(%edx),%edx
80106c24:	89 44 24 10          	mov    %eax,0x10(%esp)
80106c28:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106c2c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106c30:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c34:	c7 04 24 dc 8c 10 80 	movl   $0x80108cdc,(%esp)
80106c3b:	e8 61 97 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106c40:	c7 04 24 0e 8d 10 80 	movl   $0x80108d0e,(%esp)
80106c47:	e8 f1 98 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c4c:	e8 a0 fc ff ff       	call   801068f1 <rcr2>
80106c51:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c53:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c56:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c59:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c5f:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c62:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c65:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c68:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c6b:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c6e:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c77:	83 c0 6c             	add    $0x6c,%eax
80106c7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106c7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c83:	8b 40 10             	mov    0x10(%eax),%eax
80106c86:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106c8a:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106c8e:	89 74 24 14          	mov    %esi,0x14(%esp)
80106c92:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106c96:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c9a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106c9d:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ca1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ca5:	c7 04 24 14 8d 10 80 	movl   $0x80108d14,(%esp)
80106cac:	e8 f0 96 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106cb1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cb7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106cbe:	eb 01                	jmp    80106cc1 <trap+0x22a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106cc0:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106cc1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cc7:	85 c0                	test   %eax,%eax
80106cc9:	74 24                	je     80106cef <trap+0x258>
80106ccb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cd1:	8b 40 24             	mov    0x24(%eax),%eax
80106cd4:	85 c0                	test   %eax,%eax
80106cd6:	74 17                	je     80106cef <trap+0x258>
80106cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80106cdb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cdf:	0f b7 c0             	movzwl %ax,%eax
80106ce2:	83 e0 03             	and    $0x3,%eax
80106ce5:	83 f8 03             	cmp    $0x3,%eax
80106ce8:	75 05                	jne    80106cef <trap+0x258>
    exit();
80106cea:	e8 ab da ff ff       	call   8010479a <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER && proc->quanta <= 0)
80106cef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cf5:	85 c0                	test   %eax,%eax
80106cf7:	74 2e                	je     80106d27 <trap+0x290>
80106cf9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cff:	8b 40 0c             	mov    0xc(%eax),%eax
80106d02:	83 f8 04             	cmp    $0x4,%eax
80106d05:	75 20                	jne    80106d27 <trap+0x290>
80106d07:	8b 45 08             	mov    0x8(%ebp),%eax
80106d0a:	8b 40 30             	mov    0x30(%eax),%eax
80106d0d:	83 f8 20             	cmp    $0x20,%eax
80106d10:	75 15                	jne    80106d27 <trap+0x290>
80106d12:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d18:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80106d1e:	85 c0                	test   %eax,%eax
80106d20:	7f 05                	jg     80106d27 <trap+0x290>
    yield();
80106d22:	e8 b9 e0 ff ff       	call   80104de0 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d27:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d2d:	85 c0                	test   %eax,%eax
80106d2f:	74 27                	je     80106d58 <trap+0x2c1>
80106d31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d37:	8b 40 24             	mov    0x24(%eax),%eax
80106d3a:	85 c0                	test   %eax,%eax
80106d3c:	74 1a                	je     80106d58 <trap+0x2c1>
80106d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80106d41:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d45:	0f b7 c0             	movzwl %ax,%eax
80106d48:	83 e0 03             	and    $0x3,%eax
80106d4b:	83 f8 03             	cmp    $0x3,%eax
80106d4e:	75 08                	jne    80106d58 <trap+0x2c1>
    exit();
80106d50:	e8 45 da ff ff       	call   8010479a <exit>
80106d55:	eb 01                	jmp    80106d58 <trap+0x2c1>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106d57:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106d58:	83 c4 3c             	add    $0x3c,%esp
80106d5b:	5b                   	pop    %ebx
80106d5c:	5e                   	pop    %esi
80106d5d:	5f                   	pop    %edi
80106d5e:	5d                   	pop    %ebp
80106d5f:	c3                   	ret    

80106d60 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106d60:	55                   	push   %ebp
80106d61:	89 e5                	mov    %esp,%ebp
80106d63:	53                   	push   %ebx
80106d64:	83 ec 14             	sub    $0x14,%esp
80106d67:	8b 45 08             	mov    0x8(%ebp),%eax
80106d6a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106d6e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106d72:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106d76:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106d7a:	ec                   	in     (%dx),%al
80106d7b:	89 c3                	mov    %eax,%ebx
80106d7d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106d80:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106d84:	83 c4 14             	add    $0x14,%esp
80106d87:	5b                   	pop    %ebx
80106d88:	5d                   	pop    %ebp
80106d89:	c3                   	ret    

80106d8a <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106d8a:	55                   	push   %ebp
80106d8b:	89 e5                	mov    %esp,%ebp
80106d8d:	83 ec 08             	sub    $0x8,%esp
80106d90:	8b 55 08             	mov    0x8(%ebp),%edx
80106d93:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d96:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106d9a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106d9d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106da1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106da5:	ee                   	out    %al,(%dx)
}
80106da6:	c9                   	leave  
80106da7:	c3                   	ret    

80106da8 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106da8:	55                   	push   %ebp
80106da9:	89 e5                	mov    %esp,%ebp
80106dab:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106dae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106db5:	00 
80106db6:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106dbd:	e8 c8 ff ff ff       	call   80106d8a <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106dc2:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106dc9:	00 
80106dca:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106dd1:	e8 b4 ff ff ff       	call   80106d8a <outb>
  outb(COM1+0, 115200/9600);
80106dd6:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106ddd:	00 
80106dde:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106de5:	e8 a0 ff ff ff       	call   80106d8a <outb>
  outb(COM1+1, 0);
80106dea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106df1:	00 
80106df2:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106df9:	e8 8c ff ff ff       	call   80106d8a <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106dfe:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106e05:	00 
80106e06:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106e0d:	e8 78 ff ff ff       	call   80106d8a <outb>
  outb(COM1+4, 0);
80106e12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e19:	00 
80106e1a:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106e21:	e8 64 ff ff ff       	call   80106d8a <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106e26:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106e2d:	00 
80106e2e:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e35:	e8 50 ff ff ff       	call   80106d8a <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e3a:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e41:	e8 1a ff ff ff       	call   80106d60 <inb>
80106e46:	3c ff                	cmp    $0xff,%al
80106e48:	74 6c                	je     80106eb6 <uartinit+0x10e>
    return;
  uart = 1;
80106e4a:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106e51:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e54:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106e5b:	e8 00 ff ff ff       	call   80106d60 <inb>
  inb(COM1+0);
80106e60:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e67:	e8 f4 fe ff ff       	call   80106d60 <inb>
  picenable(IRQ_COM1);
80106e6c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e73:	e8 59 cf ff ff       	call   80103dd1 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106e78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e7f:	00 
80106e80:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e87:	e8 fa bd ff ff       	call   80102c86 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e8c:	c7 45 f4 d8 8d 10 80 	movl   $0x80108dd8,-0xc(%ebp)
80106e93:	eb 15                	jmp    80106eaa <uartinit+0x102>
    uartputc(*p);
80106e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e98:	0f b6 00             	movzbl (%eax),%eax
80106e9b:	0f be c0             	movsbl %al,%eax
80106e9e:	89 04 24             	mov    %eax,(%esp)
80106ea1:	e8 13 00 00 00       	call   80106eb9 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ea6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ead:	0f b6 00             	movzbl (%eax),%eax
80106eb0:	84 c0                	test   %al,%al
80106eb2:	75 e1                	jne    80106e95 <uartinit+0xed>
80106eb4:	eb 01                	jmp    80106eb7 <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106eb6:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106eb7:	c9                   	leave  
80106eb8:	c3                   	ret    

80106eb9 <uartputc>:

void
uartputc(int c)
{
80106eb9:	55                   	push   %ebp
80106eba:	89 e5                	mov    %esp,%ebp
80106ebc:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106ebf:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106ec4:	85 c0                	test   %eax,%eax
80106ec6:	74 4d                	je     80106f15 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ec8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ecf:	eb 10                	jmp    80106ee1 <uartputc+0x28>
    microdelay(10);
80106ed1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106ed8:	e8 41 c3 ff ff       	call   8010321e <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106edd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ee1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106ee5:	7f 16                	jg     80106efd <uartputc+0x44>
80106ee7:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106eee:	e8 6d fe ff ff       	call   80106d60 <inb>
80106ef3:	0f b6 c0             	movzbl %al,%eax
80106ef6:	83 e0 20             	and    $0x20,%eax
80106ef9:	85 c0                	test   %eax,%eax
80106efb:	74 d4                	je     80106ed1 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106efd:	8b 45 08             	mov    0x8(%ebp),%eax
80106f00:	0f b6 c0             	movzbl %al,%eax
80106f03:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f07:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f0e:	e8 77 fe ff ff       	call   80106d8a <outb>
80106f13:	eb 01                	jmp    80106f16 <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106f15:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106f16:	c9                   	leave  
80106f17:	c3                   	ret    

80106f18 <uartgetc>:

static int
uartgetc(void)
{
80106f18:	55                   	push   %ebp
80106f19:	89 e5                	mov    %esp,%ebp
80106f1b:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106f1e:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106f23:	85 c0                	test   %eax,%eax
80106f25:	75 07                	jne    80106f2e <uartgetc+0x16>
    return -1;
80106f27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f2c:	eb 2c                	jmp    80106f5a <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106f2e:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f35:	e8 26 fe ff ff       	call   80106d60 <inb>
80106f3a:	0f b6 c0             	movzbl %al,%eax
80106f3d:	83 e0 01             	and    $0x1,%eax
80106f40:	85 c0                	test   %eax,%eax
80106f42:	75 07                	jne    80106f4b <uartgetc+0x33>
    return -1;
80106f44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f49:	eb 0f                	jmp    80106f5a <uartgetc+0x42>
  return inb(COM1+0);
80106f4b:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f52:	e8 09 fe ff ff       	call   80106d60 <inb>
80106f57:	0f b6 c0             	movzbl %al,%eax
}
80106f5a:	c9                   	leave  
80106f5b:	c3                   	ret    

80106f5c <uartintr>:

void
uartintr(void)
{
80106f5c:	55                   	push   %ebp
80106f5d:	89 e5                	mov    %esp,%ebp
80106f5f:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106f62:	c7 04 24 18 6f 10 80 	movl   $0x80106f18,(%esp)
80106f69:	e8 1b 99 ff ff       	call   80100889 <consoleintr>
}
80106f6e:	c9                   	leave  
80106f6f:	c3                   	ret    

80106f70 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f70:	6a 00                	push   $0x0
  pushl $0
80106f72:	6a 00                	push   $0x0
  jmp alltraps
80106f74:	e9 23 f9 ff ff       	jmp    8010689c <alltraps>

80106f79 <vector1>:
.globl vector1
vector1:
  pushl $0
80106f79:	6a 00                	push   $0x0
  pushl $1
80106f7b:	6a 01                	push   $0x1
  jmp alltraps
80106f7d:	e9 1a f9 ff ff       	jmp    8010689c <alltraps>

80106f82 <vector2>:
.globl vector2
vector2:
  pushl $0
80106f82:	6a 00                	push   $0x0
  pushl $2
80106f84:	6a 02                	push   $0x2
  jmp alltraps
80106f86:	e9 11 f9 ff ff       	jmp    8010689c <alltraps>

80106f8b <vector3>:
.globl vector3
vector3:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $3
80106f8d:	6a 03                	push   $0x3
  jmp alltraps
80106f8f:	e9 08 f9 ff ff       	jmp    8010689c <alltraps>

80106f94 <vector4>:
.globl vector4
vector4:
  pushl $0
80106f94:	6a 00                	push   $0x0
  pushl $4
80106f96:	6a 04                	push   $0x4
  jmp alltraps
80106f98:	e9 ff f8 ff ff       	jmp    8010689c <alltraps>

80106f9d <vector5>:
.globl vector5
vector5:
  pushl $0
80106f9d:	6a 00                	push   $0x0
  pushl $5
80106f9f:	6a 05                	push   $0x5
  jmp alltraps
80106fa1:	e9 f6 f8 ff ff       	jmp    8010689c <alltraps>

80106fa6 <vector6>:
.globl vector6
vector6:
  pushl $0
80106fa6:	6a 00                	push   $0x0
  pushl $6
80106fa8:	6a 06                	push   $0x6
  jmp alltraps
80106faa:	e9 ed f8 ff ff       	jmp    8010689c <alltraps>

80106faf <vector7>:
.globl vector7
vector7:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $7
80106fb1:	6a 07                	push   $0x7
  jmp alltraps
80106fb3:	e9 e4 f8 ff ff       	jmp    8010689c <alltraps>

80106fb8 <vector8>:
.globl vector8
vector8:
  pushl $8
80106fb8:	6a 08                	push   $0x8
  jmp alltraps
80106fba:	e9 dd f8 ff ff       	jmp    8010689c <alltraps>

80106fbf <vector9>:
.globl vector9
vector9:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $9
80106fc1:	6a 09                	push   $0x9
  jmp alltraps
80106fc3:	e9 d4 f8 ff ff       	jmp    8010689c <alltraps>

80106fc8 <vector10>:
.globl vector10
vector10:
  pushl $10
80106fc8:	6a 0a                	push   $0xa
  jmp alltraps
80106fca:	e9 cd f8 ff ff       	jmp    8010689c <alltraps>

80106fcf <vector11>:
.globl vector11
vector11:
  pushl $11
80106fcf:	6a 0b                	push   $0xb
  jmp alltraps
80106fd1:	e9 c6 f8 ff ff       	jmp    8010689c <alltraps>

80106fd6 <vector12>:
.globl vector12
vector12:
  pushl $12
80106fd6:	6a 0c                	push   $0xc
  jmp alltraps
80106fd8:	e9 bf f8 ff ff       	jmp    8010689c <alltraps>

80106fdd <vector13>:
.globl vector13
vector13:
  pushl $13
80106fdd:	6a 0d                	push   $0xd
  jmp alltraps
80106fdf:	e9 b8 f8 ff ff       	jmp    8010689c <alltraps>

80106fe4 <vector14>:
.globl vector14
vector14:
  pushl $14
80106fe4:	6a 0e                	push   $0xe
  jmp alltraps
80106fe6:	e9 b1 f8 ff ff       	jmp    8010689c <alltraps>

80106feb <vector15>:
.globl vector15
vector15:
  pushl $0
80106feb:	6a 00                	push   $0x0
  pushl $15
80106fed:	6a 0f                	push   $0xf
  jmp alltraps
80106fef:	e9 a8 f8 ff ff       	jmp    8010689c <alltraps>

80106ff4 <vector16>:
.globl vector16
vector16:
  pushl $0
80106ff4:	6a 00                	push   $0x0
  pushl $16
80106ff6:	6a 10                	push   $0x10
  jmp alltraps
80106ff8:	e9 9f f8 ff ff       	jmp    8010689c <alltraps>

80106ffd <vector17>:
.globl vector17
vector17:
  pushl $17
80106ffd:	6a 11                	push   $0x11
  jmp alltraps
80106fff:	e9 98 f8 ff ff       	jmp    8010689c <alltraps>

80107004 <vector18>:
.globl vector18
vector18:
  pushl $0
80107004:	6a 00                	push   $0x0
  pushl $18
80107006:	6a 12                	push   $0x12
  jmp alltraps
80107008:	e9 8f f8 ff ff       	jmp    8010689c <alltraps>

8010700d <vector19>:
.globl vector19
vector19:
  pushl $0
8010700d:	6a 00                	push   $0x0
  pushl $19
8010700f:	6a 13                	push   $0x13
  jmp alltraps
80107011:	e9 86 f8 ff ff       	jmp    8010689c <alltraps>

80107016 <vector20>:
.globl vector20
vector20:
  pushl $0
80107016:	6a 00                	push   $0x0
  pushl $20
80107018:	6a 14                	push   $0x14
  jmp alltraps
8010701a:	e9 7d f8 ff ff       	jmp    8010689c <alltraps>

8010701f <vector21>:
.globl vector21
vector21:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $21
80107021:	6a 15                	push   $0x15
  jmp alltraps
80107023:	e9 74 f8 ff ff       	jmp    8010689c <alltraps>

80107028 <vector22>:
.globl vector22
vector22:
  pushl $0
80107028:	6a 00                	push   $0x0
  pushl $22
8010702a:	6a 16                	push   $0x16
  jmp alltraps
8010702c:	e9 6b f8 ff ff       	jmp    8010689c <alltraps>

80107031 <vector23>:
.globl vector23
vector23:
  pushl $0
80107031:	6a 00                	push   $0x0
  pushl $23
80107033:	6a 17                	push   $0x17
  jmp alltraps
80107035:	e9 62 f8 ff ff       	jmp    8010689c <alltraps>

8010703a <vector24>:
.globl vector24
vector24:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $24
8010703c:	6a 18                	push   $0x18
  jmp alltraps
8010703e:	e9 59 f8 ff ff       	jmp    8010689c <alltraps>

80107043 <vector25>:
.globl vector25
vector25:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $25
80107045:	6a 19                	push   $0x19
  jmp alltraps
80107047:	e9 50 f8 ff ff       	jmp    8010689c <alltraps>

8010704c <vector26>:
.globl vector26
vector26:
  pushl $0
8010704c:	6a 00                	push   $0x0
  pushl $26
8010704e:	6a 1a                	push   $0x1a
  jmp alltraps
80107050:	e9 47 f8 ff ff       	jmp    8010689c <alltraps>

80107055 <vector27>:
.globl vector27
vector27:
  pushl $0
80107055:	6a 00                	push   $0x0
  pushl $27
80107057:	6a 1b                	push   $0x1b
  jmp alltraps
80107059:	e9 3e f8 ff ff       	jmp    8010689c <alltraps>

8010705e <vector28>:
.globl vector28
vector28:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $28
80107060:	6a 1c                	push   $0x1c
  jmp alltraps
80107062:	e9 35 f8 ff ff       	jmp    8010689c <alltraps>

80107067 <vector29>:
.globl vector29
vector29:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $29
80107069:	6a 1d                	push   $0x1d
  jmp alltraps
8010706b:	e9 2c f8 ff ff       	jmp    8010689c <alltraps>

80107070 <vector30>:
.globl vector30
vector30:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $30
80107072:	6a 1e                	push   $0x1e
  jmp alltraps
80107074:	e9 23 f8 ff ff       	jmp    8010689c <alltraps>

80107079 <vector31>:
.globl vector31
vector31:
  pushl $0
80107079:	6a 00                	push   $0x0
  pushl $31
8010707b:	6a 1f                	push   $0x1f
  jmp alltraps
8010707d:	e9 1a f8 ff ff       	jmp    8010689c <alltraps>

80107082 <vector32>:
.globl vector32
vector32:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $32
80107084:	6a 20                	push   $0x20
  jmp alltraps
80107086:	e9 11 f8 ff ff       	jmp    8010689c <alltraps>

8010708b <vector33>:
.globl vector33
vector33:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $33
8010708d:	6a 21                	push   $0x21
  jmp alltraps
8010708f:	e9 08 f8 ff ff       	jmp    8010689c <alltraps>

80107094 <vector34>:
.globl vector34
vector34:
  pushl $0
80107094:	6a 00                	push   $0x0
  pushl $34
80107096:	6a 22                	push   $0x22
  jmp alltraps
80107098:	e9 ff f7 ff ff       	jmp    8010689c <alltraps>

8010709d <vector35>:
.globl vector35
vector35:
  pushl $0
8010709d:	6a 00                	push   $0x0
  pushl $35
8010709f:	6a 23                	push   $0x23
  jmp alltraps
801070a1:	e9 f6 f7 ff ff       	jmp    8010689c <alltraps>

801070a6 <vector36>:
.globl vector36
vector36:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $36
801070a8:	6a 24                	push   $0x24
  jmp alltraps
801070aa:	e9 ed f7 ff ff       	jmp    8010689c <alltraps>

801070af <vector37>:
.globl vector37
vector37:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $37
801070b1:	6a 25                	push   $0x25
  jmp alltraps
801070b3:	e9 e4 f7 ff ff       	jmp    8010689c <alltraps>

801070b8 <vector38>:
.globl vector38
vector38:
  pushl $0
801070b8:	6a 00                	push   $0x0
  pushl $38
801070ba:	6a 26                	push   $0x26
  jmp alltraps
801070bc:	e9 db f7 ff ff       	jmp    8010689c <alltraps>

801070c1 <vector39>:
.globl vector39
vector39:
  pushl $0
801070c1:	6a 00                	push   $0x0
  pushl $39
801070c3:	6a 27                	push   $0x27
  jmp alltraps
801070c5:	e9 d2 f7 ff ff       	jmp    8010689c <alltraps>

801070ca <vector40>:
.globl vector40
vector40:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $40
801070cc:	6a 28                	push   $0x28
  jmp alltraps
801070ce:	e9 c9 f7 ff ff       	jmp    8010689c <alltraps>

801070d3 <vector41>:
.globl vector41
vector41:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $41
801070d5:	6a 29                	push   $0x29
  jmp alltraps
801070d7:	e9 c0 f7 ff ff       	jmp    8010689c <alltraps>

801070dc <vector42>:
.globl vector42
vector42:
  pushl $0
801070dc:	6a 00                	push   $0x0
  pushl $42
801070de:	6a 2a                	push   $0x2a
  jmp alltraps
801070e0:	e9 b7 f7 ff ff       	jmp    8010689c <alltraps>

801070e5 <vector43>:
.globl vector43
vector43:
  pushl $0
801070e5:	6a 00                	push   $0x0
  pushl $43
801070e7:	6a 2b                	push   $0x2b
  jmp alltraps
801070e9:	e9 ae f7 ff ff       	jmp    8010689c <alltraps>

801070ee <vector44>:
.globl vector44
vector44:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $44
801070f0:	6a 2c                	push   $0x2c
  jmp alltraps
801070f2:	e9 a5 f7 ff ff       	jmp    8010689c <alltraps>

801070f7 <vector45>:
.globl vector45
vector45:
  pushl $0
801070f7:	6a 00                	push   $0x0
  pushl $45
801070f9:	6a 2d                	push   $0x2d
  jmp alltraps
801070fb:	e9 9c f7 ff ff       	jmp    8010689c <alltraps>

80107100 <vector46>:
.globl vector46
vector46:
  pushl $0
80107100:	6a 00                	push   $0x0
  pushl $46
80107102:	6a 2e                	push   $0x2e
  jmp alltraps
80107104:	e9 93 f7 ff ff       	jmp    8010689c <alltraps>

80107109 <vector47>:
.globl vector47
vector47:
  pushl $0
80107109:	6a 00                	push   $0x0
  pushl $47
8010710b:	6a 2f                	push   $0x2f
  jmp alltraps
8010710d:	e9 8a f7 ff ff       	jmp    8010689c <alltraps>

80107112 <vector48>:
.globl vector48
vector48:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $48
80107114:	6a 30                	push   $0x30
  jmp alltraps
80107116:	e9 81 f7 ff ff       	jmp    8010689c <alltraps>

8010711b <vector49>:
.globl vector49
vector49:
  pushl $0
8010711b:	6a 00                	push   $0x0
  pushl $49
8010711d:	6a 31                	push   $0x31
  jmp alltraps
8010711f:	e9 78 f7 ff ff       	jmp    8010689c <alltraps>

80107124 <vector50>:
.globl vector50
vector50:
  pushl $0
80107124:	6a 00                	push   $0x0
  pushl $50
80107126:	6a 32                	push   $0x32
  jmp alltraps
80107128:	e9 6f f7 ff ff       	jmp    8010689c <alltraps>

8010712d <vector51>:
.globl vector51
vector51:
  pushl $0
8010712d:	6a 00                	push   $0x0
  pushl $51
8010712f:	6a 33                	push   $0x33
  jmp alltraps
80107131:	e9 66 f7 ff ff       	jmp    8010689c <alltraps>

80107136 <vector52>:
.globl vector52
vector52:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $52
80107138:	6a 34                	push   $0x34
  jmp alltraps
8010713a:	e9 5d f7 ff ff       	jmp    8010689c <alltraps>

8010713f <vector53>:
.globl vector53
vector53:
  pushl $0
8010713f:	6a 00                	push   $0x0
  pushl $53
80107141:	6a 35                	push   $0x35
  jmp alltraps
80107143:	e9 54 f7 ff ff       	jmp    8010689c <alltraps>

80107148 <vector54>:
.globl vector54
vector54:
  pushl $0
80107148:	6a 00                	push   $0x0
  pushl $54
8010714a:	6a 36                	push   $0x36
  jmp alltraps
8010714c:	e9 4b f7 ff ff       	jmp    8010689c <alltraps>

80107151 <vector55>:
.globl vector55
vector55:
  pushl $0
80107151:	6a 00                	push   $0x0
  pushl $55
80107153:	6a 37                	push   $0x37
  jmp alltraps
80107155:	e9 42 f7 ff ff       	jmp    8010689c <alltraps>

8010715a <vector56>:
.globl vector56
vector56:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $56
8010715c:	6a 38                	push   $0x38
  jmp alltraps
8010715e:	e9 39 f7 ff ff       	jmp    8010689c <alltraps>

80107163 <vector57>:
.globl vector57
vector57:
  pushl $0
80107163:	6a 00                	push   $0x0
  pushl $57
80107165:	6a 39                	push   $0x39
  jmp alltraps
80107167:	e9 30 f7 ff ff       	jmp    8010689c <alltraps>

8010716c <vector58>:
.globl vector58
vector58:
  pushl $0
8010716c:	6a 00                	push   $0x0
  pushl $58
8010716e:	6a 3a                	push   $0x3a
  jmp alltraps
80107170:	e9 27 f7 ff ff       	jmp    8010689c <alltraps>

80107175 <vector59>:
.globl vector59
vector59:
  pushl $0
80107175:	6a 00                	push   $0x0
  pushl $59
80107177:	6a 3b                	push   $0x3b
  jmp alltraps
80107179:	e9 1e f7 ff ff       	jmp    8010689c <alltraps>

8010717e <vector60>:
.globl vector60
vector60:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $60
80107180:	6a 3c                	push   $0x3c
  jmp alltraps
80107182:	e9 15 f7 ff ff       	jmp    8010689c <alltraps>

80107187 <vector61>:
.globl vector61
vector61:
  pushl $0
80107187:	6a 00                	push   $0x0
  pushl $61
80107189:	6a 3d                	push   $0x3d
  jmp alltraps
8010718b:	e9 0c f7 ff ff       	jmp    8010689c <alltraps>

80107190 <vector62>:
.globl vector62
vector62:
  pushl $0
80107190:	6a 00                	push   $0x0
  pushl $62
80107192:	6a 3e                	push   $0x3e
  jmp alltraps
80107194:	e9 03 f7 ff ff       	jmp    8010689c <alltraps>

80107199 <vector63>:
.globl vector63
vector63:
  pushl $0
80107199:	6a 00                	push   $0x0
  pushl $63
8010719b:	6a 3f                	push   $0x3f
  jmp alltraps
8010719d:	e9 fa f6 ff ff       	jmp    8010689c <alltraps>

801071a2 <vector64>:
.globl vector64
vector64:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $64
801071a4:	6a 40                	push   $0x40
  jmp alltraps
801071a6:	e9 f1 f6 ff ff       	jmp    8010689c <alltraps>

801071ab <vector65>:
.globl vector65
vector65:
  pushl $0
801071ab:	6a 00                	push   $0x0
  pushl $65
801071ad:	6a 41                	push   $0x41
  jmp alltraps
801071af:	e9 e8 f6 ff ff       	jmp    8010689c <alltraps>

801071b4 <vector66>:
.globl vector66
vector66:
  pushl $0
801071b4:	6a 00                	push   $0x0
  pushl $66
801071b6:	6a 42                	push   $0x42
  jmp alltraps
801071b8:	e9 df f6 ff ff       	jmp    8010689c <alltraps>

801071bd <vector67>:
.globl vector67
vector67:
  pushl $0
801071bd:	6a 00                	push   $0x0
  pushl $67
801071bf:	6a 43                	push   $0x43
  jmp alltraps
801071c1:	e9 d6 f6 ff ff       	jmp    8010689c <alltraps>

801071c6 <vector68>:
.globl vector68
vector68:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $68
801071c8:	6a 44                	push   $0x44
  jmp alltraps
801071ca:	e9 cd f6 ff ff       	jmp    8010689c <alltraps>

801071cf <vector69>:
.globl vector69
vector69:
  pushl $0
801071cf:	6a 00                	push   $0x0
  pushl $69
801071d1:	6a 45                	push   $0x45
  jmp alltraps
801071d3:	e9 c4 f6 ff ff       	jmp    8010689c <alltraps>

801071d8 <vector70>:
.globl vector70
vector70:
  pushl $0
801071d8:	6a 00                	push   $0x0
  pushl $70
801071da:	6a 46                	push   $0x46
  jmp alltraps
801071dc:	e9 bb f6 ff ff       	jmp    8010689c <alltraps>

801071e1 <vector71>:
.globl vector71
vector71:
  pushl $0
801071e1:	6a 00                	push   $0x0
  pushl $71
801071e3:	6a 47                	push   $0x47
  jmp alltraps
801071e5:	e9 b2 f6 ff ff       	jmp    8010689c <alltraps>

801071ea <vector72>:
.globl vector72
vector72:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $72
801071ec:	6a 48                	push   $0x48
  jmp alltraps
801071ee:	e9 a9 f6 ff ff       	jmp    8010689c <alltraps>

801071f3 <vector73>:
.globl vector73
vector73:
  pushl $0
801071f3:	6a 00                	push   $0x0
  pushl $73
801071f5:	6a 49                	push   $0x49
  jmp alltraps
801071f7:	e9 a0 f6 ff ff       	jmp    8010689c <alltraps>

801071fc <vector74>:
.globl vector74
vector74:
  pushl $0
801071fc:	6a 00                	push   $0x0
  pushl $74
801071fe:	6a 4a                	push   $0x4a
  jmp alltraps
80107200:	e9 97 f6 ff ff       	jmp    8010689c <alltraps>

80107205 <vector75>:
.globl vector75
vector75:
  pushl $0
80107205:	6a 00                	push   $0x0
  pushl $75
80107207:	6a 4b                	push   $0x4b
  jmp alltraps
80107209:	e9 8e f6 ff ff       	jmp    8010689c <alltraps>

8010720e <vector76>:
.globl vector76
vector76:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $76
80107210:	6a 4c                	push   $0x4c
  jmp alltraps
80107212:	e9 85 f6 ff ff       	jmp    8010689c <alltraps>

80107217 <vector77>:
.globl vector77
vector77:
  pushl $0
80107217:	6a 00                	push   $0x0
  pushl $77
80107219:	6a 4d                	push   $0x4d
  jmp alltraps
8010721b:	e9 7c f6 ff ff       	jmp    8010689c <alltraps>

80107220 <vector78>:
.globl vector78
vector78:
  pushl $0
80107220:	6a 00                	push   $0x0
  pushl $78
80107222:	6a 4e                	push   $0x4e
  jmp alltraps
80107224:	e9 73 f6 ff ff       	jmp    8010689c <alltraps>

80107229 <vector79>:
.globl vector79
vector79:
  pushl $0
80107229:	6a 00                	push   $0x0
  pushl $79
8010722b:	6a 4f                	push   $0x4f
  jmp alltraps
8010722d:	e9 6a f6 ff ff       	jmp    8010689c <alltraps>

80107232 <vector80>:
.globl vector80
vector80:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $80
80107234:	6a 50                	push   $0x50
  jmp alltraps
80107236:	e9 61 f6 ff ff       	jmp    8010689c <alltraps>

8010723b <vector81>:
.globl vector81
vector81:
  pushl $0
8010723b:	6a 00                	push   $0x0
  pushl $81
8010723d:	6a 51                	push   $0x51
  jmp alltraps
8010723f:	e9 58 f6 ff ff       	jmp    8010689c <alltraps>

80107244 <vector82>:
.globl vector82
vector82:
  pushl $0
80107244:	6a 00                	push   $0x0
  pushl $82
80107246:	6a 52                	push   $0x52
  jmp alltraps
80107248:	e9 4f f6 ff ff       	jmp    8010689c <alltraps>

8010724d <vector83>:
.globl vector83
vector83:
  pushl $0
8010724d:	6a 00                	push   $0x0
  pushl $83
8010724f:	6a 53                	push   $0x53
  jmp alltraps
80107251:	e9 46 f6 ff ff       	jmp    8010689c <alltraps>

80107256 <vector84>:
.globl vector84
vector84:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $84
80107258:	6a 54                	push   $0x54
  jmp alltraps
8010725a:	e9 3d f6 ff ff       	jmp    8010689c <alltraps>

8010725f <vector85>:
.globl vector85
vector85:
  pushl $0
8010725f:	6a 00                	push   $0x0
  pushl $85
80107261:	6a 55                	push   $0x55
  jmp alltraps
80107263:	e9 34 f6 ff ff       	jmp    8010689c <alltraps>

80107268 <vector86>:
.globl vector86
vector86:
  pushl $0
80107268:	6a 00                	push   $0x0
  pushl $86
8010726a:	6a 56                	push   $0x56
  jmp alltraps
8010726c:	e9 2b f6 ff ff       	jmp    8010689c <alltraps>

80107271 <vector87>:
.globl vector87
vector87:
  pushl $0
80107271:	6a 00                	push   $0x0
  pushl $87
80107273:	6a 57                	push   $0x57
  jmp alltraps
80107275:	e9 22 f6 ff ff       	jmp    8010689c <alltraps>

8010727a <vector88>:
.globl vector88
vector88:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $88
8010727c:	6a 58                	push   $0x58
  jmp alltraps
8010727e:	e9 19 f6 ff ff       	jmp    8010689c <alltraps>

80107283 <vector89>:
.globl vector89
vector89:
  pushl $0
80107283:	6a 00                	push   $0x0
  pushl $89
80107285:	6a 59                	push   $0x59
  jmp alltraps
80107287:	e9 10 f6 ff ff       	jmp    8010689c <alltraps>

8010728c <vector90>:
.globl vector90
vector90:
  pushl $0
8010728c:	6a 00                	push   $0x0
  pushl $90
8010728e:	6a 5a                	push   $0x5a
  jmp alltraps
80107290:	e9 07 f6 ff ff       	jmp    8010689c <alltraps>

80107295 <vector91>:
.globl vector91
vector91:
  pushl $0
80107295:	6a 00                	push   $0x0
  pushl $91
80107297:	6a 5b                	push   $0x5b
  jmp alltraps
80107299:	e9 fe f5 ff ff       	jmp    8010689c <alltraps>

8010729e <vector92>:
.globl vector92
vector92:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $92
801072a0:	6a 5c                	push   $0x5c
  jmp alltraps
801072a2:	e9 f5 f5 ff ff       	jmp    8010689c <alltraps>

801072a7 <vector93>:
.globl vector93
vector93:
  pushl $0
801072a7:	6a 00                	push   $0x0
  pushl $93
801072a9:	6a 5d                	push   $0x5d
  jmp alltraps
801072ab:	e9 ec f5 ff ff       	jmp    8010689c <alltraps>

801072b0 <vector94>:
.globl vector94
vector94:
  pushl $0
801072b0:	6a 00                	push   $0x0
  pushl $94
801072b2:	6a 5e                	push   $0x5e
  jmp alltraps
801072b4:	e9 e3 f5 ff ff       	jmp    8010689c <alltraps>

801072b9 <vector95>:
.globl vector95
vector95:
  pushl $0
801072b9:	6a 00                	push   $0x0
  pushl $95
801072bb:	6a 5f                	push   $0x5f
  jmp alltraps
801072bd:	e9 da f5 ff ff       	jmp    8010689c <alltraps>

801072c2 <vector96>:
.globl vector96
vector96:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $96
801072c4:	6a 60                	push   $0x60
  jmp alltraps
801072c6:	e9 d1 f5 ff ff       	jmp    8010689c <alltraps>

801072cb <vector97>:
.globl vector97
vector97:
  pushl $0
801072cb:	6a 00                	push   $0x0
  pushl $97
801072cd:	6a 61                	push   $0x61
  jmp alltraps
801072cf:	e9 c8 f5 ff ff       	jmp    8010689c <alltraps>

801072d4 <vector98>:
.globl vector98
vector98:
  pushl $0
801072d4:	6a 00                	push   $0x0
  pushl $98
801072d6:	6a 62                	push   $0x62
  jmp alltraps
801072d8:	e9 bf f5 ff ff       	jmp    8010689c <alltraps>

801072dd <vector99>:
.globl vector99
vector99:
  pushl $0
801072dd:	6a 00                	push   $0x0
  pushl $99
801072df:	6a 63                	push   $0x63
  jmp alltraps
801072e1:	e9 b6 f5 ff ff       	jmp    8010689c <alltraps>

801072e6 <vector100>:
.globl vector100
vector100:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $100
801072e8:	6a 64                	push   $0x64
  jmp alltraps
801072ea:	e9 ad f5 ff ff       	jmp    8010689c <alltraps>

801072ef <vector101>:
.globl vector101
vector101:
  pushl $0
801072ef:	6a 00                	push   $0x0
  pushl $101
801072f1:	6a 65                	push   $0x65
  jmp alltraps
801072f3:	e9 a4 f5 ff ff       	jmp    8010689c <alltraps>

801072f8 <vector102>:
.globl vector102
vector102:
  pushl $0
801072f8:	6a 00                	push   $0x0
  pushl $102
801072fa:	6a 66                	push   $0x66
  jmp alltraps
801072fc:	e9 9b f5 ff ff       	jmp    8010689c <alltraps>

80107301 <vector103>:
.globl vector103
vector103:
  pushl $0
80107301:	6a 00                	push   $0x0
  pushl $103
80107303:	6a 67                	push   $0x67
  jmp alltraps
80107305:	e9 92 f5 ff ff       	jmp    8010689c <alltraps>

8010730a <vector104>:
.globl vector104
vector104:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $104
8010730c:	6a 68                	push   $0x68
  jmp alltraps
8010730e:	e9 89 f5 ff ff       	jmp    8010689c <alltraps>

80107313 <vector105>:
.globl vector105
vector105:
  pushl $0
80107313:	6a 00                	push   $0x0
  pushl $105
80107315:	6a 69                	push   $0x69
  jmp alltraps
80107317:	e9 80 f5 ff ff       	jmp    8010689c <alltraps>

8010731c <vector106>:
.globl vector106
vector106:
  pushl $0
8010731c:	6a 00                	push   $0x0
  pushl $106
8010731e:	6a 6a                	push   $0x6a
  jmp alltraps
80107320:	e9 77 f5 ff ff       	jmp    8010689c <alltraps>

80107325 <vector107>:
.globl vector107
vector107:
  pushl $0
80107325:	6a 00                	push   $0x0
  pushl $107
80107327:	6a 6b                	push   $0x6b
  jmp alltraps
80107329:	e9 6e f5 ff ff       	jmp    8010689c <alltraps>

8010732e <vector108>:
.globl vector108
vector108:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $108
80107330:	6a 6c                	push   $0x6c
  jmp alltraps
80107332:	e9 65 f5 ff ff       	jmp    8010689c <alltraps>

80107337 <vector109>:
.globl vector109
vector109:
  pushl $0
80107337:	6a 00                	push   $0x0
  pushl $109
80107339:	6a 6d                	push   $0x6d
  jmp alltraps
8010733b:	e9 5c f5 ff ff       	jmp    8010689c <alltraps>

80107340 <vector110>:
.globl vector110
vector110:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $110
80107342:	6a 6e                	push   $0x6e
  jmp alltraps
80107344:	e9 53 f5 ff ff       	jmp    8010689c <alltraps>

80107349 <vector111>:
.globl vector111
vector111:
  pushl $0
80107349:	6a 00                	push   $0x0
  pushl $111
8010734b:	6a 6f                	push   $0x6f
  jmp alltraps
8010734d:	e9 4a f5 ff ff       	jmp    8010689c <alltraps>

80107352 <vector112>:
.globl vector112
vector112:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $112
80107354:	6a 70                	push   $0x70
  jmp alltraps
80107356:	e9 41 f5 ff ff       	jmp    8010689c <alltraps>

8010735b <vector113>:
.globl vector113
vector113:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $113
8010735d:	6a 71                	push   $0x71
  jmp alltraps
8010735f:	e9 38 f5 ff ff       	jmp    8010689c <alltraps>

80107364 <vector114>:
.globl vector114
vector114:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $114
80107366:	6a 72                	push   $0x72
  jmp alltraps
80107368:	e9 2f f5 ff ff       	jmp    8010689c <alltraps>

8010736d <vector115>:
.globl vector115
vector115:
  pushl $0
8010736d:	6a 00                	push   $0x0
  pushl $115
8010736f:	6a 73                	push   $0x73
  jmp alltraps
80107371:	e9 26 f5 ff ff       	jmp    8010689c <alltraps>

80107376 <vector116>:
.globl vector116
vector116:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $116
80107378:	6a 74                	push   $0x74
  jmp alltraps
8010737a:	e9 1d f5 ff ff       	jmp    8010689c <alltraps>

8010737f <vector117>:
.globl vector117
vector117:
  pushl $0
8010737f:	6a 00                	push   $0x0
  pushl $117
80107381:	6a 75                	push   $0x75
  jmp alltraps
80107383:	e9 14 f5 ff ff       	jmp    8010689c <alltraps>

80107388 <vector118>:
.globl vector118
vector118:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $118
8010738a:	6a 76                	push   $0x76
  jmp alltraps
8010738c:	e9 0b f5 ff ff       	jmp    8010689c <alltraps>

80107391 <vector119>:
.globl vector119
vector119:
  pushl $0
80107391:	6a 00                	push   $0x0
  pushl $119
80107393:	6a 77                	push   $0x77
  jmp alltraps
80107395:	e9 02 f5 ff ff       	jmp    8010689c <alltraps>

8010739a <vector120>:
.globl vector120
vector120:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $120
8010739c:	6a 78                	push   $0x78
  jmp alltraps
8010739e:	e9 f9 f4 ff ff       	jmp    8010689c <alltraps>

801073a3 <vector121>:
.globl vector121
vector121:
  pushl $0
801073a3:	6a 00                	push   $0x0
  pushl $121
801073a5:	6a 79                	push   $0x79
  jmp alltraps
801073a7:	e9 f0 f4 ff ff       	jmp    8010689c <alltraps>

801073ac <vector122>:
.globl vector122
vector122:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $122
801073ae:	6a 7a                	push   $0x7a
  jmp alltraps
801073b0:	e9 e7 f4 ff ff       	jmp    8010689c <alltraps>

801073b5 <vector123>:
.globl vector123
vector123:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $123
801073b7:	6a 7b                	push   $0x7b
  jmp alltraps
801073b9:	e9 de f4 ff ff       	jmp    8010689c <alltraps>

801073be <vector124>:
.globl vector124
vector124:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $124
801073c0:	6a 7c                	push   $0x7c
  jmp alltraps
801073c2:	e9 d5 f4 ff ff       	jmp    8010689c <alltraps>

801073c7 <vector125>:
.globl vector125
vector125:
  pushl $0
801073c7:	6a 00                	push   $0x0
  pushl $125
801073c9:	6a 7d                	push   $0x7d
  jmp alltraps
801073cb:	e9 cc f4 ff ff       	jmp    8010689c <alltraps>

801073d0 <vector126>:
.globl vector126
vector126:
  pushl $0
801073d0:	6a 00                	push   $0x0
  pushl $126
801073d2:	6a 7e                	push   $0x7e
  jmp alltraps
801073d4:	e9 c3 f4 ff ff       	jmp    8010689c <alltraps>

801073d9 <vector127>:
.globl vector127
vector127:
  pushl $0
801073d9:	6a 00                	push   $0x0
  pushl $127
801073db:	6a 7f                	push   $0x7f
  jmp alltraps
801073dd:	e9 ba f4 ff ff       	jmp    8010689c <alltraps>

801073e2 <vector128>:
.globl vector128
vector128:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $128
801073e4:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801073e9:	e9 ae f4 ff ff       	jmp    8010689c <alltraps>

801073ee <vector129>:
.globl vector129
vector129:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $129
801073f0:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801073f5:	e9 a2 f4 ff ff       	jmp    8010689c <alltraps>

801073fa <vector130>:
.globl vector130
vector130:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $130
801073fc:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107401:	e9 96 f4 ff ff       	jmp    8010689c <alltraps>

80107406 <vector131>:
.globl vector131
vector131:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $131
80107408:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010740d:	e9 8a f4 ff ff       	jmp    8010689c <alltraps>

80107412 <vector132>:
.globl vector132
vector132:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $132
80107414:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107419:	e9 7e f4 ff ff       	jmp    8010689c <alltraps>

8010741e <vector133>:
.globl vector133
vector133:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $133
80107420:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107425:	e9 72 f4 ff ff       	jmp    8010689c <alltraps>

8010742a <vector134>:
.globl vector134
vector134:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $134
8010742c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107431:	e9 66 f4 ff ff       	jmp    8010689c <alltraps>

80107436 <vector135>:
.globl vector135
vector135:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $135
80107438:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010743d:	e9 5a f4 ff ff       	jmp    8010689c <alltraps>

80107442 <vector136>:
.globl vector136
vector136:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $136
80107444:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107449:	e9 4e f4 ff ff       	jmp    8010689c <alltraps>

8010744e <vector137>:
.globl vector137
vector137:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $137
80107450:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107455:	e9 42 f4 ff ff       	jmp    8010689c <alltraps>

8010745a <vector138>:
.globl vector138
vector138:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $138
8010745c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107461:	e9 36 f4 ff ff       	jmp    8010689c <alltraps>

80107466 <vector139>:
.globl vector139
vector139:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $139
80107468:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010746d:	e9 2a f4 ff ff       	jmp    8010689c <alltraps>

80107472 <vector140>:
.globl vector140
vector140:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $140
80107474:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107479:	e9 1e f4 ff ff       	jmp    8010689c <alltraps>

8010747e <vector141>:
.globl vector141
vector141:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $141
80107480:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107485:	e9 12 f4 ff ff       	jmp    8010689c <alltraps>

8010748a <vector142>:
.globl vector142
vector142:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $142
8010748c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107491:	e9 06 f4 ff ff       	jmp    8010689c <alltraps>

80107496 <vector143>:
.globl vector143
vector143:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $143
80107498:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010749d:	e9 fa f3 ff ff       	jmp    8010689c <alltraps>

801074a2 <vector144>:
.globl vector144
vector144:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $144
801074a4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801074a9:	e9 ee f3 ff ff       	jmp    8010689c <alltraps>

801074ae <vector145>:
.globl vector145
vector145:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $145
801074b0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801074b5:	e9 e2 f3 ff ff       	jmp    8010689c <alltraps>

801074ba <vector146>:
.globl vector146
vector146:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $146
801074bc:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801074c1:	e9 d6 f3 ff ff       	jmp    8010689c <alltraps>

801074c6 <vector147>:
.globl vector147
vector147:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $147
801074c8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801074cd:	e9 ca f3 ff ff       	jmp    8010689c <alltraps>

801074d2 <vector148>:
.globl vector148
vector148:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $148
801074d4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801074d9:	e9 be f3 ff ff       	jmp    8010689c <alltraps>

801074de <vector149>:
.globl vector149
vector149:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $149
801074e0:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801074e5:	e9 b2 f3 ff ff       	jmp    8010689c <alltraps>

801074ea <vector150>:
.globl vector150
vector150:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $150
801074ec:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801074f1:	e9 a6 f3 ff ff       	jmp    8010689c <alltraps>

801074f6 <vector151>:
.globl vector151
vector151:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $151
801074f8:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801074fd:	e9 9a f3 ff ff       	jmp    8010689c <alltraps>

80107502 <vector152>:
.globl vector152
vector152:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $152
80107504:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107509:	e9 8e f3 ff ff       	jmp    8010689c <alltraps>

8010750e <vector153>:
.globl vector153
vector153:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $153
80107510:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107515:	e9 82 f3 ff ff       	jmp    8010689c <alltraps>

8010751a <vector154>:
.globl vector154
vector154:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $154
8010751c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107521:	e9 76 f3 ff ff       	jmp    8010689c <alltraps>

80107526 <vector155>:
.globl vector155
vector155:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $155
80107528:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010752d:	e9 6a f3 ff ff       	jmp    8010689c <alltraps>

80107532 <vector156>:
.globl vector156
vector156:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $156
80107534:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107539:	e9 5e f3 ff ff       	jmp    8010689c <alltraps>

8010753e <vector157>:
.globl vector157
vector157:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $157
80107540:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107545:	e9 52 f3 ff ff       	jmp    8010689c <alltraps>

8010754a <vector158>:
.globl vector158
vector158:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $158
8010754c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107551:	e9 46 f3 ff ff       	jmp    8010689c <alltraps>

80107556 <vector159>:
.globl vector159
vector159:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $159
80107558:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010755d:	e9 3a f3 ff ff       	jmp    8010689c <alltraps>

80107562 <vector160>:
.globl vector160
vector160:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $160
80107564:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107569:	e9 2e f3 ff ff       	jmp    8010689c <alltraps>

8010756e <vector161>:
.globl vector161
vector161:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $161
80107570:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107575:	e9 22 f3 ff ff       	jmp    8010689c <alltraps>

8010757a <vector162>:
.globl vector162
vector162:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $162
8010757c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107581:	e9 16 f3 ff ff       	jmp    8010689c <alltraps>

80107586 <vector163>:
.globl vector163
vector163:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $163
80107588:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010758d:	e9 0a f3 ff ff       	jmp    8010689c <alltraps>

80107592 <vector164>:
.globl vector164
vector164:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $164
80107594:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107599:	e9 fe f2 ff ff       	jmp    8010689c <alltraps>

8010759e <vector165>:
.globl vector165
vector165:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $165
801075a0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801075a5:	e9 f2 f2 ff ff       	jmp    8010689c <alltraps>

801075aa <vector166>:
.globl vector166
vector166:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $166
801075ac:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801075b1:	e9 e6 f2 ff ff       	jmp    8010689c <alltraps>

801075b6 <vector167>:
.globl vector167
vector167:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $167
801075b8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801075bd:	e9 da f2 ff ff       	jmp    8010689c <alltraps>

801075c2 <vector168>:
.globl vector168
vector168:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $168
801075c4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801075c9:	e9 ce f2 ff ff       	jmp    8010689c <alltraps>

801075ce <vector169>:
.globl vector169
vector169:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $169
801075d0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801075d5:	e9 c2 f2 ff ff       	jmp    8010689c <alltraps>

801075da <vector170>:
.globl vector170
vector170:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $170
801075dc:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801075e1:	e9 b6 f2 ff ff       	jmp    8010689c <alltraps>

801075e6 <vector171>:
.globl vector171
vector171:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $171
801075e8:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801075ed:	e9 aa f2 ff ff       	jmp    8010689c <alltraps>

801075f2 <vector172>:
.globl vector172
vector172:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $172
801075f4:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801075f9:	e9 9e f2 ff ff       	jmp    8010689c <alltraps>

801075fe <vector173>:
.globl vector173
vector173:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $173
80107600:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107605:	e9 92 f2 ff ff       	jmp    8010689c <alltraps>

8010760a <vector174>:
.globl vector174
vector174:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $174
8010760c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107611:	e9 86 f2 ff ff       	jmp    8010689c <alltraps>

80107616 <vector175>:
.globl vector175
vector175:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $175
80107618:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010761d:	e9 7a f2 ff ff       	jmp    8010689c <alltraps>

80107622 <vector176>:
.globl vector176
vector176:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $176
80107624:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107629:	e9 6e f2 ff ff       	jmp    8010689c <alltraps>

8010762e <vector177>:
.globl vector177
vector177:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $177
80107630:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107635:	e9 62 f2 ff ff       	jmp    8010689c <alltraps>

8010763a <vector178>:
.globl vector178
vector178:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $178
8010763c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107641:	e9 56 f2 ff ff       	jmp    8010689c <alltraps>

80107646 <vector179>:
.globl vector179
vector179:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $179
80107648:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010764d:	e9 4a f2 ff ff       	jmp    8010689c <alltraps>

80107652 <vector180>:
.globl vector180
vector180:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $180
80107654:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107659:	e9 3e f2 ff ff       	jmp    8010689c <alltraps>

8010765e <vector181>:
.globl vector181
vector181:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $181
80107660:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107665:	e9 32 f2 ff ff       	jmp    8010689c <alltraps>

8010766a <vector182>:
.globl vector182
vector182:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $182
8010766c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107671:	e9 26 f2 ff ff       	jmp    8010689c <alltraps>

80107676 <vector183>:
.globl vector183
vector183:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $183
80107678:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010767d:	e9 1a f2 ff ff       	jmp    8010689c <alltraps>

80107682 <vector184>:
.globl vector184
vector184:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $184
80107684:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107689:	e9 0e f2 ff ff       	jmp    8010689c <alltraps>

8010768e <vector185>:
.globl vector185
vector185:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $185
80107690:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107695:	e9 02 f2 ff ff       	jmp    8010689c <alltraps>

8010769a <vector186>:
.globl vector186
vector186:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $186
8010769c:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801076a1:	e9 f6 f1 ff ff       	jmp    8010689c <alltraps>

801076a6 <vector187>:
.globl vector187
vector187:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $187
801076a8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801076ad:	e9 ea f1 ff ff       	jmp    8010689c <alltraps>

801076b2 <vector188>:
.globl vector188
vector188:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $188
801076b4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801076b9:	e9 de f1 ff ff       	jmp    8010689c <alltraps>

801076be <vector189>:
.globl vector189
vector189:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $189
801076c0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801076c5:	e9 d2 f1 ff ff       	jmp    8010689c <alltraps>

801076ca <vector190>:
.globl vector190
vector190:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $190
801076cc:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801076d1:	e9 c6 f1 ff ff       	jmp    8010689c <alltraps>

801076d6 <vector191>:
.globl vector191
vector191:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $191
801076d8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801076dd:	e9 ba f1 ff ff       	jmp    8010689c <alltraps>

801076e2 <vector192>:
.globl vector192
vector192:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $192
801076e4:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801076e9:	e9 ae f1 ff ff       	jmp    8010689c <alltraps>

801076ee <vector193>:
.globl vector193
vector193:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $193
801076f0:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801076f5:	e9 a2 f1 ff ff       	jmp    8010689c <alltraps>

801076fa <vector194>:
.globl vector194
vector194:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $194
801076fc:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107701:	e9 96 f1 ff ff       	jmp    8010689c <alltraps>

80107706 <vector195>:
.globl vector195
vector195:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $195
80107708:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010770d:	e9 8a f1 ff ff       	jmp    8010689c <alltraps>

80107712 <vector196>:
.globl vector196
vector196:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $196
80107714:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107719:	e9 7e f1 ff ff       	jmp    8010689c <alltraps>

8010771e <vector197>:
.globl vector197
vector197:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $197
80107720:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107725:	e9 72 f1 ff ff       	jmp    8010689c <alltraps>

8010772a <vector198>:
.globl vector198
vector198:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $198
8010772c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107731:	e9 66 f1 ff ff       	jmp    8010689c <alltraps>

80107736 <vector199>:
.globl vector199
vector199:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $199
80107738:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010773d:	e9 5a f1 ff ff       	jmp    8010689c <alltraps>

80107742 <vector200>:
.globl vector200
vector200:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $200
80107744:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107749:	e9 4e f1 ff ff       	jmp    8010689c <alltraps>

8010774e <vector201>:
.globl vector201
vector201:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $201
80107750:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107755:	e9 42 f1 ff ff       	jmp    8010689c <alltraps>

8010775a <vector202>:
.globl vector202
vector202:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $202
8010775c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107761:	e9 36 f1 ff ff       	jmp    8010689c <alltraps>

80107766 <vector203>:
.globl vector203
vector203:
  pushl $0
80107766:	6a 00                	push   $0x0
  pushl $203
80107768:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010776d:	e9 2a f1 ff ff       	jmp    8010689c <alltraps>

80107772 <vector204>:
.globl vector204
vector204:
  pushl $0
80107772:	6a 00                	push   $0x0
  pushl $204
80107774:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107779:	e9 1e f1 ff ff       	jmp    8010689c <alltraps>

8010777e <vector205>:
.globl vector205
vector205:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $205
80107780:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107785:	e9 12 f1 ff ff       	jmp    8010689c <alltraps>

8010778a <vector206>:
.globl vector206
vector206:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $206
8010778c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107791:	e9 06 f1 ff ff       	jmp    8010689c <alltraps>

80107796 <vector207>:
.globl vector207
vector207:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $207
80107798:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010779d:	e9 fa f0 ff ff       	jmp    8010689c <alltraps>

801077a2 <vector208>:
.globl vector208
vector208:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $208
801077a4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801077a9:	e9 ee f0 ff ff       	jmp    8010689c <alltraps>

801077ae <vector209>:
.globl vector209
vector209:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $209
801077b0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801077b5:	e9 e2 f0 ff ff       	jmp    8010689c <alltraps>

801077ba <vector210>:
.globl vector210
vector210:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $210
801077bc:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801077c1:	e9 d6 f0 ff ff       	jmp    8010689c <alltraps>

801077c6 <vector211>:
.globl vector211
vector211:
  pushl $0
801077c6:	6a 00                	push   $0x0
  pushl $211
801077c8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801077cd:	e9 ca f0 ff ff       	jmp    8010689c <alltraps>

801077d2 <vector212>:
.globl vector212
vector212:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $212
801077d4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801077d9:	e9 be f0 ff ff       	jmp    8010689c <alltraps>

801077de <vector213>:
.globl vector213
vector213:
  pushl $0
801077de:	6a 00                	push   $0x0
  pushl $213
801077e0:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801077e5:	e9 b2 f0 ff ff       	jmp    8010689c <alltraps>

801077ea <vector214>:
.globl vector214
vector214:
  pushl $0
801077ea:	6a 00                	push   $0x0
  pushl $214
801077ec:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801077f1:	e9 a6 f0 ff ff       	jmp    8010689c <alltraps>

801077f6 <vector215>:
.globl vector215
vector215:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $215
801077f8:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801077fd:	e9 9a f0 ff ff       	jmp    8010689c <alltraps>

80107802 <vector216>:
.globl vector216
vector216:
  pushl $0
80107802:	6a 00                	push   $0x0
  pushl $216
80107804:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107809:	e9 8e f0 ff ff       	jmp    8010689c <alltraps>

8010780e <vector217>:
.globl vector217
vector217:
  pushl $0
8010780e:	6a 00                	push   $0x0
  pushl $217
80107810:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107815:	e9 82 f0 ff ff       	jmp    8010689c <alltraps>

8010781a <vector218>:
.globl vector218
vector218:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $218
8010781c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107821:	e9 76 f0 ff ff       	jmp    8010689c <alltraps>

80107826 <vector219>:
.globl vector219
vector219:
  pushl $0
80107826:	6a 00                	push   $0x0
  pushl $219
80107828:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010782d:	e9 6a f0 ff ff       	jmp    8010689c <alltraps>

80107832 <vector220>:
.globl vector220
vector220:
  pushl $0
80107832:	6a 00                	push   $0x0
  pushl $220
80107834:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107839:	e9 5e f0 ff ff       	jmp    8010689c <alltraps>

8010783e <vector221>:
.globl vector221
vector221:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $221
80107840:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107845:	e9 52 f0 ff ff       	jmp    8010689c <alltraps>

8010784a <vector222>:
.globl vector222
vector222:
  pushl $0
8010784a:	6a 00                	push   $0x0
  pushl $222
8010784c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107851:	e9 46 f0 ff ff       	jmp    8010689c <alltraps>

80107856 <vector223>:
.globl vector223
vector223:
  pushl $0
80107856:	6a 00                	push   $0x0
  pushl $223
80107858:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010785d:	e9 3a f0 ff ff       	jmp    8010689c <alltraps>

80107862 <vector224>:
.globl vector224
vector224:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $224
80107864:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107869:	e9 2e f0 ff ff       	jmp    8010689c <alltraps>

8010786e <vector225>:
.globl vector225
vector225:
  pushl $0
8010786e:	6a 00                	push   $0x0
  pushl $225
80107870:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107875:	e9 22 f0 ff ff       	jmp    8010689c <alltraps>

8010787a <vector226>:
.globl vector226
vector226:
  pushl $0
8010787a:	6a 00                	push   $0x0
  pushl $226
8010787c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107881:	e9 16 f0 ff ff       	jmp    8010689c <alltraps>

80107886 <vector227>:
.globl vector227
vector227:
  pushl $0
80107886:	6a 00                	push   $0x0
  pushl $227
80107888:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010788d:	e9 0a f0 ff ff       	jmp    8010689c <alltraps>

80107892 <vector228>:
.globl vector228
vector228:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $228
80107894:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107899:	e9 fe ef ff ff       	jmp    8010689c <alltraps>

8010789e <vector229>:
.globl vector229
vector229:
  pushl $0
8010789e:	6a 00                	push   $0x0
  pushl $229
801078a0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801078a5:	e9 f2 ef ff ff       	jmp    8010689c <alltraps>

801078aa <vector230>:
.globl vector230
vector230:
  pushl $0
801078aa:	6a 00                	push   $0x0
  pushl $230
801078ac:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801078b1:	e9 e6 ef ff ff       	jmp    8010689c <alltraps>

801078b6 <vector231>:
.globl vector231
vector231:
  pushl $0
801078b6:	6a 00                	push   $0x0
  pushl $231
801078b8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801078bd:	e9 da ef ff ff       	jmp    8010689c <alltraps>

801078c2 <vector232>:
.globl vector232
vector232:
  pushl $0
801078c2:	6a 00                	push   $0x0
  pushl $232
801078c4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801078c9:	e9 ce ef ff ff       	jmp    8010689c <alltraps>

801078ce <vector233>:
.globl vector233
vector233:
  pushl $0
801078ce:	6a 00                	push   $0x0
  pushl $233
801078d0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801078d5:	e9 c2 ef ff ff       	jmp    8010689c <alltraps>

801078da <vector234>:
.globl vector234
vector234:
  pushl $0
801078da:	6a 00                	push   $0x0
  pushl $234
801078dc:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801078e1:	e9 b6 ef ff ff       	jmp    8010689c <alltraps>

801078e6 <vector235>:
.globl vector235
vector235:
  pushl $0
801078e6:	6a 00                	push   $0x0
  pushl $235
801078e8:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801078ed:	e9 aa ef ff ff       	jmp    8010689c <alltraps>

801078f2 <vector236>:
.globl vector236
vector236:
  pushl $0
801078f2:	6a 00                	push   $0x0
  pushl $236
801078f4:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801078f9:	e9 9e ef ff ff       	jmp    8010689c <alltraps>

801078fe <vector237>:
.globl vector237
vector237:
  pushl $0
801078fe:	6a 00                	push   $0x0
  pushl $237
80107900:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107905:	e9 92 ef ff ff       	jmp    8010689c <alltraps>

8010790a <vector238>:
.globl vector238
vector238:
  pushl $0
8010790a:	6a 00                	push   $0x0
  pushl $238
8010790c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107911:	e9 86 ef ff ff       	jmp    8010689c <alltraps>

80107916 <vector239>:
.globl vector239
vector239:
  pushl $0
80107916:	6a 00                	push   $0x0
  pushl $239
80107918:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010791d:	e9 7a ef ff ff       	jmp    8010689c <alltraps>

80107922 <vector240>:
.globl vector240
vector240:
  pushl $0
80107922:	6a 00                	push   $0x0
  pushl $240
80107924:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107929:	e9 6e ef ff ff       	jmp    8010689c <alltraps>

8010792e <vector241>:
.globl vector241
vector241:
  pushl $0
8010792e:	6a 00                	push   $0x0
  pushl $241
80107930:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107935:	e9 62 ef ff ff       	jmp    8010689c <alltraps>

8010793a <vector242>:
.globl vector242
vector242:
  pushl $0
8010793a:	6a 00                	push   $0x0
  pushl $242
8010793c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107941:	e9 56 ef ff ff       	jmp    8010689c <alltraps>

80107946 <vector243>:
.globl vector243
vector243:
  pushl $0
80107946:	6a 00                	push   $0x0
  pushl $243
80107948:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010794d:	e9 4a ef ff ff       	jmp    8010689c <alltraps>

80107952 <vector244>:
.globl vector244
vector244:
  pushl $0
80107952:	6a 00                	push   $0x0
  pushl $244
80107954:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107959:	e9 3e ef ff ff       	jmp    8010689c <alltraps>

8010795e <vector245>:
.globl vector245
vector245:
  pushl $0
8010795e:	6a 00                	push   $0x0
  pushl $245
80107960:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107965:	e9 32 ef ff ff       	jmp    8010689c <alltraps>

8010796a <vector246>:
.globl vector246
vector246:
  pushl $0
8010796a:	6a 00                	push   $0x0
  pushl $246
8010796c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107971:	e9 26 ef ff ff       	jmp    8010689c <alltraps>

80107976 <vector247>:
.globl vector247
vector247:
  pushl $0
80107976:	6a 00                	push   $0x0
  pushl $247
80107978:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010797d:	e9 1a ef ff ff       	jmp    8010689c <alltraps>

80107982 <vector248>:
.globl vector248
vector248:
  pushl $0
80107982:	6a 00                	push   $0x0
  pushl $248
80107984:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107989:	e9 0e ef ff ff       	jmp    8010689c <alltraps>

8010798e <vector249>:
.globl vector249
vector249:
  pushl $0
8010798e:	6a 00                	push   $0x0
  pushl $249
80107990:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107995:	e9 02 ef ff ff       	jmp    8010689c <alltraps>

8010799a <vector250>:
.globl vector250
vector250:
  pushl $0
8010799a:	6a 00                	push   $0x0
  pushl $250
8010799c:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801079a1:	e9 f6 ee ff ff       	jmp    8010689c <alltraps>

801079a6 <vector251>:
.globl vector251
vector251:
  pushl $0
801079a6:	6a 00                	push   $0x0
  pushl $251
801079a8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801079ad:	e9 ea ee ff ff       	jmp    8010689c <alltraps>

801079b2 <vector252>:
.globl vector252
vector252:
  pushl $0
801079b2:	6a 00                	push   $0x0
  pushl $252
801079b4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801079b9:	e9 de ee ff ff       	jmp    8010689c <alltraps>

801079be <vector253>:
.globl vector253
vector253:
  pushl $0
801079be:	6a 00                	push   $0x0
  pushl $253
801079c0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801079c5:	e9 d2 ee ff ff       	jmp    8010689c <alltraps>

801079ca <vector254>:
.globl vector254
vector254:
  pushl $0
801079ca:	6a 00                	push   $0x0
  pushl $254
801079cc:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801079d1:	e9 c6 ee ff ff       	jmp    8010689c <alltraps>

801079d6 <vector255>:
.globl vector255
vector255:
  pushl $0
801079d6:	6a 00                	push   $0x0
  pushl $255
801079d8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801079dd:	e9 ba ee ff ff       	jmp    8010689c <alltraps>
	...

801079e4 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801079e4:	55                   	push   %ebp
801079e5:	89 e5                	mov    %esp,%ebp
801079e7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801079ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801079ed:	83 e8 01             	sub    $0x1,%eax
801079f0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801079f4:	8b 45 08             	mov    0x8(%ebp),%eax
801079f7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801079fb:	8b 45 08             	mov    0x8(%ebp),%eax
801079fe:	c1 e8 10             	shr    $0x10,%eax
80107a01:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107a05:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107a08:	0f 01 10             	lgdtl  (%eax)
}
80107a0b:	c9                   	leave  
80107a0c:	c3                   	ret    

80107a0d <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107a0d:	55                   	push   %ebp
80107a0e:	89 e5                	mov    %esp,%ebp
80107a10:	83 ec 04             	sub    $0x4,%esp
80107a13:	8b 45 08             	mov    0x8(%ebp),%eax
80107a16:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107a1a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a1e:	0f 00 d8             	ltr    %ax
}
80107a21:	c9                   	leave  
80107a22:	c3                   	ret    

80107a23 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107a23:	55                   	push   %ebp
80107a24:	89 e5                	mov    %esp,%ebp
80107a26:	83 ec 04             	sub    $0x4,%esp
80107a29:	8b 45 08             	mov    0x8(%ebp),%eax
80107a2c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107a30:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a34:	8e e8                	mov    %eax,%gs
}
80107a36:	c9                   	leave  
80107a37:	c3                   	ret    

80107a38 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107a38:	55                   	push   %ebp
80107a39:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a3b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a3e:	0f 22 d8             	mov    %eax,%cr3
}
80107a41:	5d                   	pop    %ebp
80107a42:	c3                   	ret    

80107a43 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107a43:	55                   	push   %ebp
80107a44:	89 e5                	mov    %esp,%ebp
80107a46:	8b 45 08             	mov    0x8(%ebp),%eax
80107a49:	05 00 00 00 80       	add    $0x80000000,%eax
80107a4e:	5d                   	pop    %ebp
80107a4f:	c3                   	ret    

80107a50 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107a50:	55                   	push   %ebp
80107a51:	89 e5                	mov    %esp,%ebp
80107a53:	8b 45 08             	mov    0x8(%ebp),%eax
80107a56:	05 00 00 00 80       	add    $0x80000000,%eax
80107a5b:	5d                   	pop    %ebp
80107a5c:	c3                   	ret    

80107a5d <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a5d:	55                   	push   %ebp
80107a5e:	89 e5                	mov    %esp,%ebp
80107a60:	53                   	push   %ebx
80107a61:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107a64:	e8 34 b7 ff ff       	call   8010319d <cpunum>
80107a69:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107a6f:	05 40 f9 10 80       	add    $0x8010f940,%eax
80107a74:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7a:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a83:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8c:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a93:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a97:	83 e2 f0             	and    $0xfffffff0,%edx
80107a9a:	83 ca 0a             	or     $0xa,%edx
80107a9d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107aa7:	83 ca 10             	or     $0x10,%edx
80107aaa:	88 50 7d             	mov    %dl,0x7d(%eax)
80107aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ab4:	83 e2 9f             	and    $0xffffff9f,%edx
80107ab7:	88 50 7d             	mov    %dl,0x7d(%eax)
80107aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ac1:	83 ca 80             	or     $0xffffff80,%edx
80107ac4:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aca:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ace:	83 ca 0f             	or     $0xf,%edx
80107ad1:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107adb:	83 e2 ef             	and    $0xffffffef,%edx
80107ade:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ae8:	83 e2 df             	and    $0xffffffdf,%edx
80107aeb:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107af5:	83 ca 40             	or     $0x40,%edx
80107af8:	88 50 7e             	mov    %dl,0x7e(%eax)
80107afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afe:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107b02:	83 ca 80             	or     $0xffffff80,%edx
80107b05:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0b:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b12:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b19:	ff ff 
80107b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1e:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b25:	00 00 
80107b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2a:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b34:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b3b:	83 e2 f0             	and    $0xfffffff0,%edx
80107b3e:	83 ca 02             	or     $0x2,%edx
80107b41:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b51:	83 ca 10             	or     $0x10,%edx
80107b54:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b64:	83 e2 9f             	and    $0xffffff9f,%edx
80107b67:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b70:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b77:	83 ca 80             	or     $0xffffff80,%edx
80107b7a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b83:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b8a:	83 ca 0f             	or     $0xf,%edx
80107b8d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b96:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b9d:	83 e2 ef             	and    $0xffffffef,%edx
80107ba0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bb0:	83 e2 df             	and    $0xffffffdf,%edx
80107bb3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bc3:	83 ca 40             	or     $0x40,%edx
80107bc6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bcf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bd6:	83 ca 80             	or     $0xffffff80,%edx
80107bd9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be2:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bec:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107bf3:	ff ff 
80107bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf8:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107bff:	00 00 
80107c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c04:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c15:	83 e2 f0             	and    $0xfffffff0,%edx
80107c18:	83 ca 0a             	or     $0xa,%edx
80107c1b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c24:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c2b:	83 ca 10             	or     $0x10,%edx
80107c2e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c37:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c3e:	83 ca 60             	or     $0x60,%edx
80107c41:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c51:	83 ca 80             	or     $0xffffff80,%edx
80107c54:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c64:	83 ca 0f             	or     $0xf,%edx
80107c67:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c70:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c77:	83 e2 ef             	and    $0xffffffef,%edx
80107c7a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c83:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c8a:	83 e2 df             	and    $0xffffffdf,%edx
80107c8d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c96:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c9d:	83 ca 40             	or     $0x40,%edx
80107ca0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107cb0:	83 ca 80             	or     $0xffffff80,%edx
80107cb3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbc:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc6:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107ccd:	ff ff 
80107ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd2:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107cd9:	00 00 
80107cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cde:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce8:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cef:	83 e2 f0             	and    $0xfffffff0,%edx
80107cf2:	83 ca 02             	or     $0x2,%edx
80107cf5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfe:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d05:	83 ca 10             	or     $0x10,%edx
80107d08:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d11:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d18:	83 ca 60             	or     $0x60,%edx
80107d1b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d24:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d2b:	83 ca 80             	or     $0xffffff80,%edx
80107d2e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d37:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d3e:	83 ca 0f             	or     $0xf,%edx
80107d41:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d51:	83 e2 ef             	and    $0xffffffef,%edx
80107d54:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d64:	83 e2 df             	and    $0xffffffdf,%edx
80107d67:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d70:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d77:	83 ca 40             	or     $0x40,%edx
80107d7a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d83:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d8a:	83 ca 80             	or     $0xffffff80,%edx
80107d8d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d96:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da0:	05 b4 00 00 00       	add    $0xb4,%eax
80107da5:	89 c3                	mov    %eax,%ebx
80107da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107daa:	05 b4 00 00 00       	add    $0xb4,%eax
80107daf:	c1 e8 10             	shr    $0x10,%eax
80107db2:	89 c1                	mov    %eax,%ecx
80107db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db7:	05 b4 00 00 00       	add    $0xb4,%eax
80107dbc:	c1 e8 18             	shr    $0x18,%eax
80107dbf:	89 c2                	mov    %eax,%edx
80107dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc4:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107dcb:	00 00 
80107dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd0:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dda:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de3:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107dea:	83 e1 f0             	and    $0xfffffff0,%ecx
80107ded:	83 c9 02             	or     $0x2,%ecx
80107df0:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df9:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e00:	83 c9 10             	or     $0x10,%ecx
80107e03:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0c:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e13:	83 e1 9f             	and    $0xffffff9f,%ecx
80107e16:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1f:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e26:	83 c9 80             	or     $0xffffff80,%ecx
80107e29:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e32:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e39:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e3c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e45:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e4c:	83 e1 ef             	and    $0xffffffef,%ecx
80107e4f:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e58:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e5f:	83 e1 df             	and    $0xffffffdf,%ecx
80107e62:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6b:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e72:	83 c9 40             	or     $0x40,%ecx
80107e75:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e85:	83 c9 80             	or     $0xffffff80,%ecx
80107e88:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e91:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9a:	83 c0 70             	add    $0x70,%eax
80107e9d:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107ea4:	00 
80107ea5:	89 04 24             	mov    %eax,(%esp)
80107ea8:	e8 37 fb ff ff       	call   801079e4 <lgdt>
  loadgs(SEG_KCPU << 3);
80107ead:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107eb4:	e8 6a fb ff ff       	call   80107a23 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebc:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107ec2:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107ec9:	00 00 00 00 
}
80107ecd:	83 c4 24             	add    $0x24,%esp
80107ed0:	5b                   	pop    %ebx
80107ed1:	5d                   	pop    %ebp
80107ed2:	c3                   	ret    

80107ed3 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107ed3:	55                   	push   %ebp
80107ed4:	89 e5                	mov    %esp,%ebp
80107ed6:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107edc:	c1 e8 16             	shr    $0x16,%eax
80107edf:	c1 e0 02             	shl    $0x2,%eax
80107ee2:	03 45 08             	add    0x8(%ebp),%eax
80107ee5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eeb:	8b 00                	mov    (%eax),%eax
80107eed:	83 e0 01             	and    $0x1,%eax
80107ef0:	84 c0                	test   %al,%al
80107ef2:	74 17                	je     80107f0b <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107ef4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ef7:	8b 00                	mov    (%eax),%eax
80107ef9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107efe:	89 04 24             	mov    %eax,(%esp)
80107f01:	e8 4a fb ff ff       	call   80107a50 <p2v>
80107f06:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f09:	eb 4b                	jmp    80107f56 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107f0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107f0f:	74 0e                	je     80107f1f <walkpgdir+0x4c>
80107f11:	e8 f9 ae ff ff       	call   80102e0f <kalloc>
80107f16:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f19:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f1d:	75 07                	jne    80107f26 <walkpgdir+0x53>
      return 0;
80107f1f:	b8 00 00 00 00       	mov    $0x0,%eax
80107f24:	eb 41                	jmp    80107f67 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f26:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f2d:	00 
80107f2e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f35:	00 
80107f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f39:	89 04 24             	mov    %eax,(%esp)
80107f3c:	e8 b5 d4 ff ff       	call   801053f6 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f44:	89 04 24             	mov    %eax,(%esp)
80107f47:	e8 f7 fa ff ff       	call   80107a43 <v2p>
80107f4c:	89 c2                	mov    %eax,%edx
80107f4e:	83 ca 07             	or     $0x7,%edx
80107f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f54:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f56:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f59:	c1 e8 0c             	shr    $0xc,%eax
80107f5c:	25 ff 03 00 00       	and    $0x3ff,%eax
80107f61:	c1 e0 02             	shl    $0x2,%eax
80107f64:	03 45 f4             	add    -0xc(%ebp),%eax
}
80107f67:	c9                   	leave  
80107f68:	c3                   	ret    

80107f69 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107f69:	55                   	push   %ebp
80107f6a:	89 e5                	mov    %esp,%ebp
80107f6c:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f7d:	03 45 10             	add    0x10(%ebp),%eax
80107f80:	83 e8 01             	sub    $0x1,%eax
80107f83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f88:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f8b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107f92:	00 
80107f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f96:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f9d:	89 04 24             	mov    %eax,(%esp)
80107fa0:	e8 2e ff ff ff       	call   80107ed3 <walkpgdir>
80107fa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fa8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fac:	75 07                	jne    80107fb5 <mappages+0x4c>
      return -1;
80107fae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fb3:	eb 46                	jmp    80107ffb <mappages+0x92>
    if(*pte & PTE_P)
80107fb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fb8:	8b 00                	mov    (%eax),%eax
80107fba:	83 e0 01             	and    $0x1,%eax
80107fbd:	84 c0                	test   %al,%al
80107fbf:	74 0c                	je     80107fcd <mappages+0x64>
      panic("remap");
80107fc1:	c7 04 24 e0 8d 10 80 	movl   $0x80108de0,(%esp)
80107fc8:	e8 70 85 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80107fcd:	8b 45 18             	mov    0x18(%ebp),%eax
80107fd0:	0b 45 14             	or     0x14(%ebp),%eax
80107fd3:	89 c2                	mov    %eax,%edx
80107fd5:	83 ca 01             	or     $0x1,%edx
80107fd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fdb:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107fe3:	74 10                	je     80107ff5 <mappages+0x8c>
      break;
    a += PGSIZE;
80107fe5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107fec:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107ff3:	eb 96                	jmp    80107f8b <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107ff5:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107ff6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ffb:	c9                   	leave  
80107ffc:	c3                   	ret    

80107ffd <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80107ffd:	55                   	push   %ebp
80107ffe:	89 e5                	mov    %esp,%ebp
80108000:	53                   	push   %ebx
80108001:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108004:	e8 06 ae ff ff       	call   80102e0f <kalloc>
80108009:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010800c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108010:	75 0a                	jne    8010801c <setupkvm+0x1f>
    return 0;
80108012:	b8 00 00 00 00       	mov    $0x0,%eax
80108017:	e9 98 00 00 00       	jmp    801080b4 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
8010801c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108023:	00 
80108024:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010802b:	00 
8010802c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010802f:	89 04 24             	mov    %eax,(%esp)
80108032:	e8 bf d3 ff ff       	call   801053f6 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108037:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
8010803e:	e8 0d fa ff ff       	call   80107a50 <p2v>
80108043:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108048:	76 0c                	jbe    80108056 <setupkvm+0x59>
    panic("PHYSTOP too high");
8010804a:	c7 04 24 e6 8d 10 80 	movl   $0x80108de6,(%esp)
80108051:	e8 e7 84 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108056:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
8010805d:	eb 49                	jmp    801080a8 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
8010805f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108062:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108065:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108068:	8b 50 04             	mov    0x4(%eax),%edx
8010806b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806e:	8b 58 08             	mov    0x8(%eax),%ebx
80108071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108074:	8b 40 04             	mov    0x4(%eax),%eax
80108077:	29 c3                	sub    %eax,%ebx
80108079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807c:	8b 00                	mov    (%eax),%eax
8010807e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108082:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108086:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010808a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010808e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108091:	89 04 24             	mov    %eax,(%esp)
80108094:	e8 d0 fe ff ff       	call   80107f69 <mappages>
80108099:	85 c0                	test   %eax,%eax
8010809b:	79 07                	jns    801080a4 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
8010809d:	b8 00 00 00 00       	mov    $0x0,%eax
801080a2:	eb 10                	jmp    801080b4 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801080a4:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801080a8:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
801080af:	72 ae                	jb     8010805f <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801080b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801080b4:	83 c4 34             	add    $0x34,%esp
801080b7:	5b                   	pop    %ebx
801080b8:	5d                   	pop    %ebp
801080b9:	c3                   	ret    

801080ba <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801080ba:	55                   	push   %ebp
801080bb:	89 e5                	mov    %esp,%ebp
801080bd:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801080c0:	e8 38 ff ff ff       	call   80107ffd <setupkvm>
801080c5:	a3 18 2d 11 80       	mov    %eax,0x80112d18
  switchkvm();
801080ca:	e8 02 00 00 00       	call   801080d1 <switchkvm>
}
801080cf:	c9                   	leave  
801080d0:	c3                   	ret    

801080d1 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801080d1:	55                   	push   %ebp
801080d2:	89 e5                	mov    %esp,%ebp
801080d4:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801080d7:	a1 18 2d 11 80       	mov    0x80112d18,%eax
801080dc:	89 04 24             	mov    %eax,(%esp)
801080df:	e8 5f f9 ff ff       	call   80107a43 <v2p>
801080e4:	89 04 24             	mov    %eax,(%esp)
801080e7:	e8 4c f9 ff ff       	call   80107a38 <lcr3>
}
801080ec:	c9                   	leave  
801080ed:	c3                   	ret    

801080ee <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801080ee:	55                   	push   %ebp
801080ef:	89 e5                	mov    %esp,%ebp
801080f1:	53                   	push   %ebx
801080f2:	83 ec 14             	sub    $0x14,%esp
  pushcli();
801080f5:	e8 f5 d1 ff ff       	call   801052ef <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801080fa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108100:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108107:	83 c2 08             	add    $0x8,%edx
8010810a:	89 d3                	mov    %edx,%ebx
8010810c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108113:	83 c2 08             	add    $0x8,%edx
80108116:	c1 ea 10             	shr    $0x10,%edx
80108119:	89 d1                	mov    %edx,%ecx
8010811b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108122:	83 c2 08             	add    $0x8,%edx
80108125:	c1 ea 18             	shr    $0x18,%edx
80108128:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010812f:	67 00 
80108131:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108138:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
8010813e:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108145:	83 e1 f0             	and    $0xfffffff0,%ecx
80108148:	83 c9 09             	or     $0x9,%ecx
8010814b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108151:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108158:	83 c9 10             	or     $0x10,%ecx
8010815b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108161:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108168:	83 e1 9f             	and    $0xffffff9f,%ecx
8010816b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108171:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108178:	83 c9 80             	or     $0xffffff80,%ecx
8010817b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108181:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108188:	83 e1 f0             	and    $0xfffffff0,%ecx
8010818b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108191:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108198:	83 e1 ef             	and    $0xffffffef,%ecx
8010819b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081a1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081a8:	83 e1 df             	and    $0xffffffdf,%ecx
801081ab:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081b1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081b8:	83 c9 40             	or     $0x40,%ecx
801081bb:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081c1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081c8:	83 e1 7f             	and    $0x7f,%ecx
801081cb:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081d1:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801081d7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081dd:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801081e4:	83 e2 ef             	and    $0xffffffef,%edx
801081e7:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801081ed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081f3:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801081f9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081ff:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108206:	8b 52 08             	mov    0x8(%edx),%edx
80108209:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010820f:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108212:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108219:	e8 ef f7 ff ff       	call   80107a0d <ltr>
  if(p->pgdir == 0)
8010821e:	8b 45 08             	mov    0x8(%ebp),%eax
80108221:	8b 40 04             	mov    0x4(%eax),%eax
80108224:	85 c0                	test   %eax,%eax
80108226:	75 0c                	jne    80108234 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108228:	c7 04 24 f7 8d 10 80 	movl   $0x80108df7,(%esp)
8010822f:	e8 09 83 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108234:	8b 45 08             	mov    0x8(%ebp),%eax
80108237:	8b 40 04             	mov    0x4(%eax),%eax
8010823a:	89 04 24             	mov    %eax,(%esp)
8010823d:	e8 01 f8 ff ff       	call   80107a43 <v2p>
80108242:	89 04 24             	mov    %eax,(%esp)
80108245:	e8 ee f7 ff ff       	call   80107a38 <lcr3>
  popcli();
8010824a:	e8 e8 d0 ff ff       	call   80105337 <popcli>
}
8010824f:	83 c4 14             	add    $0x14,%esp
80108252:	5b                   	pop    %ebx
80108253:	5d                   	pop    %ebp
80108254:	c3                   	ret    

80108255 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108255:	55                   	push   %ebp
80108256:	89 e5                	mov    %esp,%ebp
80108258:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010825b:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108262:	76 0c                	jbe    80108270 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108264:	c7 04 24 0b 8e 10 80 	movl   $0x80108e0b,(%esp)
8010826b:	e8 cd 82 ff ff       	call   8010053d <panic>
  mem = kalloc();
80108270:	e8 9a ab ff ff       	call   80102e0f <kalloc>
80108275:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108278:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010827f:	00 
80108280:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108287:	00 
80108288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010828b:	89 04 24             	mov    %eax,(%esp)
8010828e:	e8 63 d1 ff ff       	call   801053f6 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108296:	89 04 24             	mov    %eax,(%esp)
80108299:	e8 a5 f7 ff ff       	call   80107a43 <v2p>
8010829e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801082a5:	00 
801082a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
801082aa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082b1:	00 
801082b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082b9:	00 
801082ba:	8b 45 08             	mov    0x8(%ebp),%eax
801082bd:	89 04 24             	mov    %eax,(%esp)
801082c0:	e8 a4 fc ff ff       	call   80107f69 <mappages>
  memmove(mem, init, sz);
801082c5:	8b 45 10             	mov    0x10(%ebp),%eax
801082c8:	89 44 24 08          	mov    %eax,0x8(%esp)
801082cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801082cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801082d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d6:	89 04 24             	mov    %eax,(%esp)
801082d9:	e8 eb d1 ff ff       	call   801054c9 <memmove>
}
801082de:	c9                   	leave  
801082df:	c3                   	ret    

801082e0 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801082e0:	55                   	push   %ebp
801082e1:	89 e5                	mov    %esp,%ebp
801082e3:	53                   	push   %ebx
801082e4:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801082e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801082ea:	25 ff 0f 00 00       	and    $0xfff,%eax
801082ef:	85 c0                	test   %eax,%eax
801082f1:	74 0c                	je     801082ff <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801082f3:	c7 04 24 28 8e 10 80 	movl   $0x80108e28,(%esp)
801082fa:	e8 3e 82 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
801082ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108306:	e9 ad 00 00 00       	jmp    801083b8 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010830b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108311:	01 d0                	add    %edx,%eax
80108313:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010831a:	00 
8010831b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010831f:	8b 45 08             	mov    0x8(%ebp),%eax
80108322:	89 04 24             	mov    %eax,(%esp)
80108325:	e8 a9 fb ff ff       	call   80107ed3 <walkpgdir>
8010832a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010832d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108331:	75 0c                	jne    8010833f <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108333:	c7 04 24 4b 8e 10 80 	movl   $0x80108e4b,(%esp)
8010833a:	e8 fe 81 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
8010833f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108342:	8b 00                	mov    (%eax),%eax
80108344:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108349:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010834c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010834f:	8b 55 18             	mov    0x18(%ebp),%edx
80108352:	89 d1                	mov    %edx,%ecx
80108354:	29 c1                	sub    %eax,%ecx
80108356:	89 c8                	mov    %ecx,%eax
80108358:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010835d:	77 11                	ja     80108370 <loaduvm+0x90>
      n = sz - i;
8010835f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108362:	8b 55 18             	mov    0x18(%ebp),%edx
80108365:	89 d1                	mov    %edx,%ecx
80108367:	29 c1                	sub    %eax,%ecx
80108369:	89 c8                	mov    %ecx,%eax
8010836b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010836e:	eb 07                	jmp    80108377 <loaduvm+0x97>
    else
      n = PGSIZE;
80108370:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837a:	8b 55 14             	mov    0x14(%ebp),%edx
8010837d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108380:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108383:	89 04 24             	mov    %eax,(%esp)
80108386:	e8 c5 f6 ff ff       	call   80107a50 <p2v>
8010838b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010838e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108392:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108396:	89 44 24 04          	mov    %eax,0x4(%esp)
8010839a:	8b 45 10             	mov    0x10(%ebp),%eax
8010839d:	89 04 24             	mov    %eax,(%esp)
801083a0:	e8 c9 9c ff ff       	call   8010206e <readi>
801083a5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801083a8:	74 07                	je     801083b1 <loaduvm+0xd1>
      return -1;
801083aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083af:	eb 18                	jmp    801083c9 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801083b1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083bb:	3b 45 18             	cmp    0x18(%ebp),%eax
801083be:	0f 82 47 ff ff ff    	jb     8010830b <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801083c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083c9:	83 c4 24             	add    $0x24,%esp
801083cc:	5b                   	pop    %ebx
801083cd:	5d                   	pop    %ebp
801083ce:	c3                   	ret    

801083cf <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083cf:	55                   	push   %ebp
801083d0:	89 e5                	mov    %esp,%ebp
801083d2:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801083d5:	8b 45 10             	mov    0x10(%ebp),%eax
801083d8:	85 c0                	test   %eax,%eax
801083da:	79 0a                	jns    801083e6 <allocuvm+0x17>
    return 0;
801083dc:	b8 00 00 00 00       	mov    $0x0,%eax
801083e1:	e9 c1 00 00 00       	jmp    801084a7 <allocuvm+0xd8>
  if(newsz < oldsz)
801083e6:	8b 45 10             	mov    0x10(%ebp),%eax
801083e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083ec:	73 08                	jae    801083f6 <allocuvm+0x27>
    return oldsz;
801083ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801083f1:	e9 b1 00 00 00       	jmp    801084a7 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801083f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801083f9:	05 ff 0f 00 00       	add    $0xfff,%eax
801083fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108403:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108406:	e9 8d 00 00 00       	jmp    80108498 <allocuvm+0xc9>
    mem = kalloc();
8010840b:	e8 ff a9 ff ff       	call   80102e0f <kalloc>
80108410:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108413:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108417:	75 2c                	jne    80108445 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108419:	c7 04 24 69 8e 10 80 	movl   $0x80108e69,(%esp)
80108420:	e8 7c 7f ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108425:	8b 45 0c             	mov    0xc(%ebp),%eax
80108428:	89 44 24 08          	mov    %eax,0x8(%esp)
8010842c:	8b 45 10             	mov    0x10(%ebp),%eax
8010842f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108433:	8b 45 08             	mov    0x8(%ebp),%eax
80108436:	89 04 24             	mov    %eax,(%esp)
80108439:	e8 6b 00 00 00       	call   801084a9 <deallocuvm>
      return 0;
8010843e:	b8 00 00 00 00       	mov    $0x0,%eax
80108443:	eb 62                	jmp    801084a7 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108445:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010844c:	00 
8010844d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108454:	00 
80108455:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108458:	89 04 24             	mov    %eax,(%esp)
8010845b:	e8 96 cf ff ff       	call   801053f6 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108460:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108463:	89 04 24             	mov    %eax,(%esp)
80108466:	e8 d8 f5 ff ff       	call   80107a43 <v2p>
8010846b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010846e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108475:	00 
80108476:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010847a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108481:	00 
80108482:	89 54 24 04          	mov    %edx,0x4(%esp)
80108486:	8b 45 08             	mov    0x8(%ebp),%eax
80108489:	89 04 24             	mov    %eax,(%esp)
8010848c:	e8 d8 fa ff ff       	call   80107f69 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108491:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010849e:	0f 82 67 ff ff ff    	jb     8010840b <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801084a4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801084a7:	c9                   	leave  
801084a8:	c3                   	ret    

801084a9 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801084a9:	55                   	push   %ebp
801084aa:	89 e5                	mov    %esp,%ebp
801084ac:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801084af:	8b 45 10             	mov    0x10(%ebp),%eax
801084b2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084b5:	72 08                	jb     801084bf <deallocuvm+0x16>
    return oldsz;
801084b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801084ba:	e9 a4 00 00 00       	jmp    80108563 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801084bf:	8b 45 10             	mov    0x10(%ebp),%eax
801084c2:	05 ff 0f 00 00       	add    $0xfff,%eax
801084c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801084cf:	e9 80 00 00 00       	jmp    80108554 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801084d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084de:	00 
801084df:	89 44 24 04          	mov    %eax,0x4(%esp)
801084e3:	8b 45 08             	mov    0x8(%ebp),%eax
801084e6:	89 04 24             	mov    %eax,(%esp)
801084e9:	e8 e5 f9 ff ff       	call   80107ed3 <walkpgdir>
801084ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801084f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084f5:	75 09                	jne    80108500 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801084f7:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801084fe:	eb 4d                	jmp    8010854d <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108503:	8b 00                	mov    (%eax),%eax
80108505:	83 e0 01             	and    $0x1,%eax
80108508:	84 c0                	test   %al,%al
8010850a:	74 41                	je     8010854d <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
8010850c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010850f:	8b 00                	mov    (%eax),%eax
80108511:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108516:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108519:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010851d:	75 0c                	jne    8010852b <deallocuvm+0x82>
        panic("kfree");
8010851f:	c7 04 24 81 8e 10 80 	movl   $0x80108e81,(%esp)
80108526:	e8 12 80 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
8010852b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010852e:	89 04 24             	mov    %eax,(%esp)
80108531:	e8 1a f5 ff ff       	call   80107a50 <p2v>
80108536:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108539:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010853c:	89 04 24             	mov    %eax,(%esp)
8010853f:	e8 32 a8 ff ff       	call   80102d76 <kfree>
      *pte = 0;
80108544:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108547:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010854d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108557:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010855a:	0f 82 74 ff ff ff    	jb     801084d4 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108560:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108563:	c9                   	leave  
80108564:	c3                   	ret    

80108565 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108565:	55                   	push   %ebp
80108566:	89 e5                	mov    %esp,%ebp
80108568:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010856b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010856f:	75 0c                	jne    8010857d <freevm+0x18>
    panic("freevm: no pgdir");
80108571:	c7 04 24 87 8e 10 80 	movl   $0x80108e87,(%esp)
80108578:	e8 c0 7f ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010857d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108584:	00 
80108585:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010858c:	80 
8010858d:	8b 45 08             	mov    0x8(%ebp),%eax
80108590:	89 04 24             	mov    %eax,(%esp)
80108593:	e8 11 ff ff ff       	call   801084a9 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108598:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010859f:	eb 3c                	jmp    801085dd <freevm+0x78>
    if(pgdir[i] & PTE_P){
801085a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a4:	c1 e0 02             	shl    $0x2,%eax
801085a7:	03 45 08             	add    0x8(%ebp),%eax
801085aa:	8b 00                	mov    (%eax),%eax
801085ac:	83 e0 01             	and    $0x1,%eax
801085af:	84 c0                	test   %al,%al
801085b1:	74 26                	je     801085d9 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801085b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b6:	c1 e0 02             	shl    $0x2,%eax
801085b9:	03 45 08             	add    0x8(%ebp),%eax
801085bc:	8b 00                	mov    (%eax),%eax
801085be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085c3:	89 04 24             	mov    %eax,(%esp)
801085c6:	e8 85 f4 ff ff       	call   80107a50 <p2v>
801085cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801085ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085d1:	89 04 24             	mov    %eax,(%esp)
801085d4:	e8 9d a7 ff ff       	call   80102d76 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801085d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085dd:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801085e4:	76 bb                	jbe    801085a1 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801085e6:	8b 45 08             	mov    0x8(%ebp),%eax
801085e9:	89 04 24             	mov    %eax,(%esp)
801085ec:	e8 85 a7 ff ff       	call   80102d76 <kfree>
}
801085f1:	c9                   	leave  
801085f2:	c3                   	ret    

801085f3 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801085f3:	55                   	push   %ebp
801085f4:	89 e5                	mov    %esp,%ebp
801085f6:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801085f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108600:	00 
80108601:	8b 45 0c             	mov    0xc(%ebp),%eax
80108604:	89 44 24 04          	mov    %eax,0x4(%esp)
80108608:	8b 45 08             	mov    0x8(%ebp),%eax
8010860b:	89 04 24             	mov    %eax,(%esp)
8010860e:	e8 c0 f8 ff ff       	call   80107ed3 <walkpgdir>
80108613:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108616:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010861a:	75 0c                	jne    80108628 <clearpteu+0x35>
    panic("clearpteu");
8010861c:	c7 04 24 98 8e 10 80 	movl   $0x80108e98,(%esp)
80108623:	e8 15 7f ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80108628:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862b:	8b 00                	mov    (%eax),%eax
8010862d:	89 c2                	mov    %eax,%edx
8010862f:	83 e2 fb             	and    $0xfffffffb,%edx
80108632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108635:	89 10                	mov    %edx,(%eax)
}
80108637:	c9                   	leave  
80108638:	c3                   	ret    

80108639 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108639:	55                   	push   %ebp
8010863a:	89 e5                	mov    %esp,%ebp
8010863c:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
8010863f:	e8 b9 f9 ff ff       	call   80107ffd <setupkvm>
80108644:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108647:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010864b:	75 0a                	jne    80108657 <copyuvm+0x1e>
    return 0;
8010864d:	b8 00 00 00 00       	mov    $0x0,%eax
80108652:	e9 f1 00 00 00       	jmp    80108748 <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
80108657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010865e:	e9 c0 00 00 00       	jmp    80108723 <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108663:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108666:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010866d:	00 
8010866e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108672:	8b 45 08             	mov    0x8(%ebp),%eax
80108675:	89 04 24             	mov    %eax,(%esp)
80108678:	e8 56 f8 ff ff       	call   80107ed3 <walkpgdir>
8010867d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108680:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108684:	75 0c                	jne    80108692 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108686:	c7 04 24 a2 8e 10 80 	movl   $0x80108ea2,(%esp)
8010868d:	e8 ab 7e ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
80108692:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108695:	8b 00                	mov    (%eax),%eax
80108697:	83 e0 01             	and    $0x1,%eax
8010869a:	85 c0                	test   %eax,%eax
8010869c:	75 0c                	jne    801086aa <copyuvm+0x71>
      panic("copyuvm: page not present");
8010869e:	c7 04 24 bc 8e 10 80 	movl   $0x80108ebc,(%esp)
801086a5:	e8 93 7e ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801086aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086ad:	8b 00                	mov    (%eax),%eax
801086af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086b4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
801086b7:	e8 53 a7 ff ff       	call   80102e0f <kalloc>
801086bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801086bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801086c3:	74 6f                	je     80108734 <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801086c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086c8:	89 04 24             	mov    %eax,(%esp)
801086cb:	e8 80 f3 ff ff       	call   80107a50 <p2v>
801086d0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086d7:	00 
801086d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801086dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801086df:	89 04 24             	mov    %eax,(%esp)
801086e2:	e8 e2 cd ff ff       	call   801054c9 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
801086e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801086ea:	89 04 24             	mov    %eax,(%esp)
801086ed:	e8 51 f3 ff ff       	call   80107a43 <v2p>
801086f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086f5:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801086fc:	00 
801086fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108701:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108708:	00 
80108709:	89 54 24 04          	mov    %edx,0x4(%esp)
8010870d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108710:	89 04 24             	mov    %eax,(%esp)
80108713:	e8 51 f8 ff ff       	call   80107f69 <mappages>
80108718:	85 c0                	test   %eax,%eax
8010871a:	78 1b                	js     80108737 <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010871c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108726:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108729:	0f 82 34 ff ff ff    	jb     80108663 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
8010872f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108732:	eb 14                	jmp    80108748 <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108734:	90                   	nop
80108735:	eb 01                	jmp    80108738 <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
80108737:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108738:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010873b:	89 04 24             	mov    %eax,(%esp)
8010873e:	e8 22 fe ff ff       	call   80108565 <freevm>
  return 0;
80108743:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108748:	c9                   	leave  
80108749:	c3                   	ret    

8010874a <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010874a:	55                   	push   %ebp
8010874b:	89 e5                	mov    %esp,%ebp
8010874d:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108750:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108757:	00 
80108758:	8b 45 0c             	mov    0xc(%ebp),%eax
8010875b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010875f:	8b 45 08             	mov    0x8(%ebp),%eax
80108762:	89 04 24             	mov    %eax,(%esp)
80108765:	e8 69 f7 ff ff       	call   80107ed3 <walkpgdir>
8010876a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010876d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108770:	8b 00                	mov    (%eax),%eax
80108772:	83 e0 01             	and    $0x1,%eax
80108775:	85 c0                	test   %eax,%eax
80108777:	75 07                	jne    80108780 <uva2ka+0x36>
    return 0;
80108779:	b8 00 00 00 00       	mov    $0x0,%eax
8010877e:	eb 25                	jmp    801087a5 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108783:	8b 00                	mov    (%eax),%eax
80108785:	83 e0 04             	and    $0x4,%eax
80108788:	85 c0                	test   %eax,%eax
8010878a:	75 07                	jne    80108793 <uva2ka+0x49>
    return 0;
8010878c:	b8 00 00 00 00       	mov    $0x0,%eax
80108791:	eb 12                	jmp    801087a5 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108796:	8b 00                	mov    (%eax),%eax
80108798:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010879d:	89 04 24             	mov    %eax,(%esp)
801087a0:	e8 ab f2 ff ff       	call   80107a50 <p2v>
}
801087a5:	c9                   	leave  
801087a6:	c3                   	ret    

801087a7 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801087a7:	55                   	push   %ebp
801087a8:	89 e5                	mov    %esp,%ebp
801087aa:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801087ad:	8b 45 10             	mov    0x10(%ebp),%eax
801087b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801087b3:	e9 8b 00 00 00       	jmp    80108843 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
801087b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801087bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801087c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801087ca:	8b 45 08             	mov    0x8(%ebp),%eax
801087cd:	89 04 24             	mov    %eax,(%esp)
801087d0:	e8 75 ff ff ff       	call   8010874a <uva2ka>
801087d5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801087d8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801087dc:	75 07                	jne    801087e5 <copyout+0x3e>
      return -1;
801087de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801087e3:	eb 6d                	jmp    80108852 <copyout+0xab>
    n = PGSIZE - (va - va0);
801087e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801087e8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801087eb:	89 d1                	mov    %edx,%ecx
801087ed:	29 c1                	sub    %eax,%ecx
801087ef:	89 c8                	mov    %ecx,%eax
801087f1:	05 00 10 00 00       	add    $0x1000,%eax
801087f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801087f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087fc:	3b 45 14             	cmp    0x14(%ebp),%eax
801087ff:	76 06                	jbe    80108807 <copyout+0x60>
      n = len;
80108801:	8b 45 14             	mov    0x14(%ebp),%eax
80108804:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108807:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010880a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010880d:	89 d1                	mov    %edx,%ecx
8010880f:	29 c1                	sub    %eax,%ecx
80108811:	89 c8                	mov    %ecx,%eax
80108813:	03 45 e8             	add    -0x18(%ebp),%eax
80108816:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108819:	89 54 24 08          	mov    %edx,0x8(%esp)
8010881d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108820:	89 54 24 04          	mov    %edx,0x4(%esp)
80108824:	89 04 24             	mov    %eax,(%esp)
80108827:	e8 9d cc ff ff       	call   801054c9 <memmove>
    len -= n;
8010882c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010882f:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108832:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108835:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108838:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010883b:	05 00 10 00 00       	add    $0x1000,%eax
80108840:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108843:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108847:	0f 85 6b ff ff ff    	jne    801087b8 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010884d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108852:	c9                   	leave  
80108853:	c3                   	ret    
