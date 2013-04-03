
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
8010002d:	b8 5b 37 10 80       	mov    $0x8010375b,%eax
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
8010003a:	c7 44 24 04 74 87 10 	movl   $0x80108774,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 ac 50 00 00       	call   801050fa <initlock>

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
801000bd:	e8 59 50 00 00       	call   8010511b <acquire>

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
80100104:	e8 74 50 00 00       	call   8010517d <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 11 4d 00 00       	call   80104e35 <sleep>
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
8010017c:	e8 fc 4f 00 00       	call   8010517d <release>
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
80100198:	c7 04 24 7b 87 10 80 	movl   $0x8010877b,(%esp)
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
801001d3:	e8 30 29 00 00       	call   80102b08 <iderw>
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
801001ef:	c7 04 24 8c 87 10 80 	movl   $0x8010878c,(%esp)
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
80100210:	e8 f3 28 00 00       	call   80102b08 <iderw>
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
80100229:	c7 04 24 93 87 10 80 	movl   $0x80108793,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 da 4e 00 00       	call   8010511b <acquire>

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
8010029d:	e8 6f 4c 00 00       	call   80104f11 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 cf 4e 00 00       	call   8010517d <release>
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
801003bc:	e8 5a 4d 00 00       	call   8010511b <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 9a 87 10 80 	movl   $0x8010879a,(%esp)
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
801004af:	c7 45 ec a3 87 10 80 	movl   $0x801087a3,-0x14(%ebp)
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
80100536:	e8 42 4c 00 00       	call   8010517d <release>
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
80100562:	c7 04 24 aa 87 10 80 	movl   $0x801087aa,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 b9 87 10 80 	movl   $0x801087b9,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 35 4c 00 00       	call   801051cc <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 bb 87 10 80 	movl   $0x801087bb,(%esp)
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
8010072b:	e8 0d 4d 00 00       	call   8010543d <memmove>
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
8010075a:	e8 0b 4c 00 00       	call   8010536a <memset>
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
80100801:	e8 d3 65 00 00       	call   80106dd9 <uartputc>
80100806:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010080d:	e8 c7 65 00 00       	call   80106dd9 <uartputc>
80100812:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100819:	e8 bb 65 00 00       	call   80106dd9 <uartputc>
8010081e:	eb 0b                	jmp    8010082b <consputc+0x50>
  }
  else if (c == KEY_RT){
    uartputc(0x601);
  }*/
  else
    uartputc(c);
80100820:	8b 45 08             	mov    0x8(%ebp),%eax
80100823:	89 04 24             	mov    %eax,(%esp)
80100826:	e8 ae 65 00 00       	call   80106dd9 <uartputc>
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
801008db:	e8 3b 48 00 00       	call   8010511b <acquire>
  while((c = getc()) >= 0){
801008e0:	e9 74 03 00 00       	jmp    80100c59 <consoleintr+0x38b>
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
801008fc:	e9 b5 01 00 00       	jmp    80100ab6 <consoleintr+0x1e8>
80100901:	3d e4 00 00 00       	cmp    $0xe4,%eax
80100906:	0f 84 40 01 00 00    	je     80100a4c <consoleintr+0x17e>
8010090c:	3d e5 00 00 00       	cmp    $0xe5,%eax
80100911:	0f 84 63 01 00 00    	je     80100a7a <consoleintr+0x1ac>
80100917:	83 f8 7f             	cmp    $0x7f,%eax
8010091a:	74 59                	je     80100975 <consoleintr+0xa7>
8010091c:	e9 95 01 00 00       	jmp    80100ab6 <consoleintr+0x1e8>
    case C('P'):  // Process listing.
      procdump();
80100921:	e8 91 46 00 00       	call   80104fb7 <procdump>
      break;
80100926:	e9 2e 03 00 00       	jmp    80100c59 <consoleintr+0x38b>
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
80100954:	0f 84 f2 02 00 00    	je     80100c4c <consoleintr+0x37e>
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
80100970:	e9 d7 02 00 00       	jmp    80100c4c <consoleintr+0x37e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100975:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010097b:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100980:	39 c2                	cmp    %eax,%edx
80100982:	0f 84 c7 02 00 00    	je     80100c4f <consoleintr+0x381>
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
80100a47:	e9 03 02 00 00       	jmp    80100c4f <consoleintr+0x381>
    case KEY_LF: //LEFT KEY
     if(input.e % INPUT_BUF > 0)
80100a4c:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a51:	83 e0 7f             	and    $0x7f,%eax
80100a54:	85 c0                	test   %eax,%eax
80100a56:	0f 84 f6 01 00 00    	je     80100c52 <consoleintr+0x384>
      {
        input.a--;
80100a5c:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a61:	83 e8 01             	sub    $0x1,%eax
80100a64:	a3 60 de 10 80       	mov    %eax,0x8010de60
        consputc(KEY_LF);
80100a69:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a70:	e8 66 fd ff ff       	call   801007db <consputc>
      }
      break;
80100a75:	e9 d8 01 00 00       	jmp    80100c52 <consoleintr+0x384>
    case KEY_RT: //RIGHT KEY
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
80100a7a:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a7f:	85 c0                	test   %eax,%eax
80100a81:	0f 89 ce 01 00 00    	jns    80100c55 <consoleintr+0x387>
80100a87:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a8c:	83 e0 7f             	and    $0x7f,%eax
80100a8f:	83 f8 7e             	cmp    $0x7e,%eax
80100a92:	0f 87 bd 01 00 00    	ja     80100c55 <consoleintr+0x387>
      {
        input.a++;
80100a98:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a9d:	83 c0 01             	add    $0x1,%eax
80100aa0:	a3 60 de 10 80       	mov    %eax,0x8010de60
        consputc(KEY_RT);
80100aa5:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100aac:	e8 2a fd ff ff       	call   801007db <consputc>
      }
      break;
80100ab1:	e9 9f 01 00 00       	jmp    80100c55 <consoleintr+0x387>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
80100ab6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100aba:	0f 84 98 01 00 00    	je     80100c58 <consoleintr+0x38a>
80100ac0:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100ac6:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100acb:	89 d1                	mov    %edx,%ecx
80100acd:	29 c1                	sub    %eax,%ecx
80100acf:	89 c8                	mov    %ecx,%eax
80100ad1:	83 f8 7f             	cmp    $0x7f,%eax
80100ad4:	0f 87 7e 01 00 00    	ja     80100c58 <consoleintr+0x38a>
      {
	c = (c == '\r') ? '\n' : c;
80100ada:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
80100ade:	74 05                	je     80100ae5 <consoleintr+0x217>
80100ae0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100ae3:	eb 05                	jmp    80100aea <consoleintr+0x21c>
80100ae5:	b8 0a 00 00 00       	mov    $0xa,%eax
80100aea:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(c != '\n' && input.a < 0)
80100aed:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100af1:	0f 84 ef 00 00 00    	je     80100be6 <consoleintr+0x318>
80100af7:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100afc:	85 c0                	test   %eax,%eax
80100afe:	0f 89 e2 00 00 00    	jns    80100be6 <consoleintr+0x318>
	{
	    int j = (INPUT_BUF-(input.e-input.w));
80100b04:	8b 15 58 de 10 80    	mov    0x8010de58,%edx
80100b0a:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b0f:	89 d1                	mov    %edx,%ecx
80100b11:	29 c1                	sub    %eax,%ecx
80100b13:	89 c8                	mov    %ecx,%eax
80100b15:	83 e8 80             	sub    $0xffffff80,%eax
80100b18:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    int k = ((-1)*input.a > j) ? j : (-1)*input.a;
80100b1b:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100b20:	89 c2                	mov    %eax,%edx
80100b22:	f7 da                	neg    %edx
80100b24:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b27:	39 c2                	cmp    %eax,%edx
80100b29:	0f 4e c2             	cmovle %edx,%eax
80100b2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	    shiftRightBuf((input.e-1) % INPUT_BUF,k);
80100b2f:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b34:	83 e8 01             	sub    $0x1,%eax
80100b37:	89 c2                	mov    %eax,%edx
80100b39:	83 e2 7f             	and    $0x7f,%edx
80100b3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b43:	89 14 24             	mov    %edx,(%esp)
80100b46:	e8 ed fc ff ff       	call   80100838 <shiftRightBuf>
	    input.buf[(input.e-k) % INPUT_BUF] = c;
80100b4b:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100b51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b54:	89 d1                	mov    %edx,%ecx
80100b56:	29 c1                	sub    %eax,%ecx
80100b58:	89 c8                	mov    %ecx,%eax
80100b5a:	89 c2                	mov    %eax,%edx
80100b5c:	83 e2 7f             	and    $0x7f,%edx
80100b5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100b62:	88 82 d4 dd 10 80    	mov    %al,-0x7fef222c(%edx)
	    int i = input.e-k;
80100b68:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100b6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100b71:	89 d1                	mov    %edx,%ecx
80100b73:	29 c1                	sub    %eax,%ecx
80100b75:	89 c8                	mov    %ecx,%eax
80100b77:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    
	    for(;i<input.e+1;i++){
80100b7a:	eb 1b                	jmp    80100b97 <consoleintr+0x2c9>
	      consputc(input.buf[i]);
80100b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b7f:	05 d0 dd 10 80       	add    $0x8010ddd0,%eax
80100b84:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80100b88:	0f be c0             	movsbl %al,%eax
80100b8b:	89 04 24             	mov    %eax,(%esp)
80100b8e:	e8 48 fc ff ff       	call   801007db <consputc>
	    int k = ((-1)*input.a > j) ? j : (-1)*input.a;
	    shiftRightBuf((input.e-1) % INPUT_BUF,k);
	    input.buf[(input.e-k) % INPUT_BUF] = c;
	    int i = input.e-k;
	    
	    for(;i<input.e+1;i++){
80100b93:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b9a:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100ba0:	83 c2 01             	add    $0x1,%edx
80100ba3:	39 d0                	cmp    %edx,%eax
80100ba5:	72 d5                	jb     80100b7c <consoleintr+0x2ae>
	      consputc(input.buf[i]);
	    }
	    i = input.e-k;
80100ba7:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100bad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100bb0:	89 d1                	mov    %edx,%ecx
80100bb2:	29 c1                	sub    %eax,%ecx
80100bb4:	89 c8                	mov    %ecx,%eax
80100bb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e;i++){
80100bb9:	eb 10                	jmp    80100bcb <consoleintr+0x2fd>
	      consputc(KEY_LF);
80100bbb:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100bc2:	e8 14 fc ff ff       	call   801007db <consputc>
	    
	    for(;i<input.e+1;i++){
	      consputc(input.buf[i]);
	    }
	    i = input.e-k;
	    for(;i<input.e;i++){
80100bc7:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100bcb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100bce:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bd3:	39 c2                	cmp    %eax,%edx
80100bd5:	72 e4                	jb     80100bbb <consoleintr+0x2ed>
	      consputc(KEY_LF);
	    }
	    input.e++;
80100bd7:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bdc:	83 c0 01             	add    $0x1,%eax
80100bdf:	a3 5c de 10 80       	mov    %eax,0x8010de5c
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
      {
	c = (c == '\r') ? '\n' : c;
	if(c != '\n' && input.a < 0)
	{
80100be4:	eb 26                	jmp    80100c0c <consoleintr+0x33e>
	      consputc(KEY_LF);
	    }
	    input.e++;
	}
	else {
	  input.buf[input.e++ % INPUT_BUF] = c;
80100be6:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100beb:	89 c1                	mov    %eax,%ecx
80100bed:	83 e1 7f             	and    $0x7f,%ecx
80100bf0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100bf3:	88 91 d4 dd 10 80    	mov    %dl,-0x7fef222c(%ecx)
80100bf9:	83 c0 01             	add    $0x1,%eax
80100bfc:	a3 5c de 10 80       	mov    %eax,0x8010de5c
          consputc(c);
80100c01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100c04:	89 04 24             	mov    %eax,(%esp)
80100c07:	e8 cf fb ff ff       	call   801007db <consputc>
	}
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100c0c:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100c10:	74 18                	je     80100c2a <consoleintr+0x35c>
80100c12:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100c16:	74 12                	je     80100c2a <consoleintr+0x35c>
80100c18:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100c1d:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100c23:	83 ea 80             	sub    $0xffffff80,%edx
80100c26:	39 d0                	cmp    %edx,%eax
80100c28:	75 2e                	jne    80100c58 <consoleintr+0x38a>
          input.a = 0;
80100c2a:	c7 05 60 de 10 80 00 	movl   $0x0,0x8010de60
80100c31:	00 00 00 
	  input.w = input.e;
80100c34:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100c39:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
80100c3e:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100c45:	e8 c7 42 00 00       	call   80104f11 <wakeup>
        }
      }
      break;
80100c4a:	eb 0c                	jmp    80100c58 <consoleintr+0x38a>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100c4c:	90                   	nop
80100c4d:	eb 0a                	jmp    80100c59 <consoleintr+0x38b>
	{
	  consputc(BACKSPACE);
	}
	input.e--;
      }
      break;
80100c4f:	90                   	nop
80100c50:	eb 07                	jmp    80100c59 <consoleintr+0x38b>
     if(input.e % INPUT_BUF > 0)
      {
        input.a--;
        consputc(KEY_LF);
      }
      break;
80100c52:	90                   	nop
80100c53:	eb 04                	jmp    80100c59 <consoleintr+0x38b>
      if(input.a < 0 && input.e % INPUT_BUF < INPUT_BUF-1)
      {
        input.a++;
        consputc(KEY_RT);
      }
      break;
80100c55:	90                   	nop
80100c56:	eb 01                	jmp    80100c59 <consoleintr+0x38b>
          input.a = 0;
	  input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
80100c58:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100c59:	8b 45 08             	mov    0x8(%ebp),%eax
80100c5c:	ff d0                	call   *%eax
80100c5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100c61:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100c65:	0f 89 7a fc ff ff    	jns    801008e5 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100c6b:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c72:	e8 06 45 00 00       	call   8010517d <release>
}
80100c77:	c9                   	leave  
80100c78:	c3                   	ret    

80100c79 <consoleread>:


int
consoleread(struct inode *ip, char *dst, int n)
{
80100c79:	55                   	push   %ebp
80100c7a:	89 e5                	mov    %esp,%ebp
80100c7c:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80100c82:	89 04 24             	mov    %eax,(%esp)
80100c85:	e8 80 10 00 00       	call   80101d0a <iunlock>
  target = n;
80100c8a:	8b 45 10             	mov    0x10(%ebp),%eax
80100c8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100c90:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c97:	e8 7f 44 00 00       	call   8010511b <acquire>
  while(n > 0){
80100c9c:	e9 a8 00 00 00       	jmp    80100d49 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
80100ca1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ca7:	8b 40 24             	mov    0x24(%eax),%eax
80100caa:	85 c0                	test   %eax,%eax
80100cac:	74 21                	je     80100ccf <consoleread+0x56>
        release(&input.lock);
80100cae:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100cb5:	e8 c3 44 00 00       	call   8010517d <release>
        ilock(ip);
80100cba:	8b 45 08             	mov    0x8(%ebp),%eax
80100cbd:	89 04 24             	mov    %eax,(%esp)
80100cc0:	e8 f7 0e 00 00       	call   80101bbc <ilock>
        return -1;
80100cc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100cca:	e9 a9 00 00 00       	jmp    80100d78 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
80100ccf:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
80100cd6:	80 
80100cd7:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100cde:	e8 52 41 00 00       	call   80104e35 <sleep>
80100ce3:	eb 01                	jmp    80100ce6 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100ce5:	90                   	nop
80100ce6:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100cec:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100cf1:	39 c2                	cmp    %eax,%edx
80100cf3:	74 ac                	je     80100ca1 <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100cf5:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100cfa:	89 c2                	mov    %eax,%edx
80100cfc:	83 e2 7f             	and    $0x7f,%edx
80100cff:	0f b6 92 d4 dd 10 80 	movzbl -0x7fef222c(%edx),%edx
80100d06:	0f be d2             	movsbl %dl,%edx
80100d09:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100d0c:	83 c0 01             	add    $0x1,%eax
80100d0f:	a3 54 de 10 80       	mov    %eax,0x8010de54
    if(c == C('D')){  // EOF
80100d14:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100d18:	75 17                	jne    80100d31 <consoleread+0xb8>
      if(n < target){
80100d1a:	8b 45 10             	mov    0x10(%ebp),%eax
80100d1d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100d20:	73 2f                	jae    80100d51 <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100d22:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100d27:	83 e8 01             	sub    $0x1,%eax
80100d2a:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
80100d2f:	eb 20                	jmp    80100d51 <consoleread+0xd8>
    }
    *dst++ = c;
80100d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100d34:	89 c2                	mov    %eax,%edx
80100d36:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d39:	88 10                	mov    %dl,(%eax)
80100d3b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
80100d3f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100d43:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100d47:	74 0b                	je     80100d54 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100d49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100d4d:	7f 96                	jg     80100ce5 <consoleread+0x6c>
80100d4f:	eb 04                	jmp    80100d55 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100d51:	90                   	nop
80100d52:	eb 01                	jmp    80100d55 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100d54:	90                   	nop
  }
  release(&input.lock);
80100d55:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100d5c:	e8 1c 44 00 00       	call   8010517d <release>
  ilock(ip);
80100d61:	8b 45 08             	mov    0x8(%ebp),%eax
80100d64:	89 04 24             	mov    %eax,(%esp)
80100d67:	e8 50 0e 00 00       	call   80101bbc <ilock>

  return target - n;
80100d6c:	8b 45 10             	mov    0x10(%ebp),%eax
80100d6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100d72:	89 d1                	mov    %edx,%ecx
80100d74:	29 c1                	sub    %eax,%ecx
80100d76:	89 c8                	mov    %ecx,%eax
}
80100d78:	c9                   	leave  
80100d79:	c3                   	ret    

80100d7a <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100d7a:	55                   	push   %ebp
80100d7b:	89 e5                	mov    %esp,%ebp
80100d7d:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100d80:	8b 45 08             	mov    0x8(%ebp),%eax
80100d83:	89 04 24             	mov    %eax,(%esp)
80100d86:	e8 7f 0f 00 00       	call   80101d0a <iunlock>
  acquire(&cons.lock);
80100d8b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d92:	e8 84 43 00 00       	call   8010511b <acquire>
  for(i = 0; i < n; i++)
80100d97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100d9e:	eb 1d                	jmp    80100dbd <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100da3:	03 45 0c             	add    0xc(%ebp),%eax
80100da6:	0f b6 00             	movzbl (%eax),%eax
80100da9:	0f be c0             	movsbl %al,%eax
80100dac:	25 ff 00 00 00       	and    $0xff,%eax
80100db1:	89 04 24             	mov    %eax,(%esp)
80100db4:	e8 22 fa ff ff       	call   801007db <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100db9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100dc0:	3b 45 10             	cmp    0x10(%ebp),%eax
80100dc3:	7c db                	jl     80100da0 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100dc5:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100dcc:	e8 ac 43 00 00       	call   8010517d <release>
  ilock(ip);
80100dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80100dd4:	89 04 24             	mov    %eax,(%esp)
80100dd7:	e8 e0 0d 00 00       	call   80101bbc <ilock>

  return n;
80100ddc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ddf:	c9                   	leave  
80100de0:	c3                   	ret    

80100de1 <consoleinit>:

void
consoleinit(void)
{
80100de1:	55                   	push   %ebp
80100de2:	89 e5                	mov    %esp,%ebp
80100de4:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100de7:	c7 44 24 04 bf 87 10 	movl   $0x801087bf,0x4(%esp)
80100dee:	80 
80100def:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100df6:	e8 ff 42 00 00       	call   801050fa <initlock>
  initlock(&input.lock, "input");
80100dfb:	c7 44 24 04 c7 87 10 	movl   $0x801087c7,0x4(%esp)
80100e02:	80 
80100e03:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100e0a:	e8 eb 42 00 00       	call   801050fa <initlock>

  devsw[CONSOLE].write = consolewrite;
80100e0f:	c7 05 2c e8 10 80 7a 	movl   $0x80100d7a,0x8010e82c
80100e16:	0d 10 80 
  devsw[CONSOLE].read = consoleread;
80100e19:	c7 05 28 e8 10 80 79 	movl   $0x80100c79,0x8010e828
80100e20:	0c 10 80 
  cons.locking = 1;
80100e23:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100e2a:	00 00 00 

  picenable(IRQ_KBD);
80100e2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e34:	e8 dc 2f 00 00       	call   80103e15 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100e39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100e40:	00 
80100e41:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100e48:	e8 7d 1e 00 00       	call   80102cca <ioapicenable>
}
80100e4d:	c9                   	leave  
80100e4e:	c3                   	ret    
	...

80100e50 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100e50:	55                   	push   %ebp
80100e51:	89 e5                	mov    %esp,%ebp
80100e53:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100e59:	8b 45 08             	mov    0x8(%ebp),%eax
80100e5c:	89 04 24             	mov    %eax,(%esp)
80100e5f:	e8 fa 18 00 00       	call   8010275e <namei>
80100e64:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100e67:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100e6b:	75 0a                	jne    80100e77 <exec+0x27>
    return -1;
80100e6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e72:	e9 da 03 00 00       	jmp    80101251 <exec+0x401>
  ilock(ip);
80100e77:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e7a:	89 04 24             	mov    %eax,(%esp)
80100e7d:	e8 3a 0d 00 00       	call   80101bbc <ilock>
  pgdir = 0;
80100e82:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100e89:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100e90:	00 
80100e91:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100e98:	00 
80100e99:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100e9f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ea3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ea6:	89 04 24             	mov    %eax,(%esp)
80100ea9:	e8 04 12 00 00       	call   801020b2 <readi>
80100eae:	83 f8 33             	cmp    $0x33,%eax
80100eb1:	0f 86 54 03 00 00    	jbe    8010120b <exec+0x3bb>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100eb7:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100ebd:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100ec2:	0f 85 46 03 00 00    	jne    8010120e <exec+0x3be>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100ec8:	c7 04 24 53 2e 10 80 	movl   $0x80102e53,(%esp)
80100ecf:	e8 49 70 00 00       	call   80107f1d <setupkvm>
80100ed4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ed7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100edb:	0f 84 30 03 00 00    	je     80101211 <exec+0x3c1>
    goto bad;

  // Load program into memory.
  sz = 0;
80100ee1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ee8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100eef:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100ef5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ef8:	e9 c5 00 00 00       	jmp    80100fc2 <exec+0x172>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100efd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100f00:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100f07:	00 
80100f08:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f0c:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100f12:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f16:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f19:	89 04 24             	mov    %eax,(%esp)
80100f1c:	e8 91 11 00 00       	call   801020b2 <readi>
80100f21:	83 f8 20             	cmp    $0x20,%eax
80100f24:	0f 85 ea 02 00 00    	jne    80101214 <exec+0x3c4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100f2a:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100f30:	83 f8 01             	cmp    $0x1,%eax
80100f33:	75 7f                	jne    80100fb4 <exec+0x164>
      continue;
    if(ph.memsz < ph.filesz)
80100f35:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100f3b:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100f41:	39 c2                	cmp    %eax,%edx
80100f43:	0f 82 ce 02 00 00    	jb     80101217 <exec+0x3c7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100f49:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100f4f:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100f55:	01 d0                	add    %edx,%eax
80100f57:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f65:	89 04 24             	mov    %eax,(%esp)
80100f68:	e8 82 73 00 00       	call   801082ef <allocuvm>
80100f6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100f70:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100f74:	0f 84 a0 02 00 00    	je     8010121a <exec+0x3ca>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100f7a:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100f80:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100f86:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100f8c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100f90:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100f94:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100f97:	89 54 24 08          	mov    %edx,0x8(%esp)
80100f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f9f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fa2:	89 04 24             	mov    %eax,(%esp)
80100fa5:	e8 56 72 00 00       	call   80108200 <loaduvm>
80100faa:	85 c0                	test   %eax,%eax
80100fac:	0f 88 6b 02 00 00    	js     8010121d <exec+0x3cd>
80100fb2:	eb 01                	jmp    80100fb5 <exec+0x165>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100fb4:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100fb5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100fb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100fbc:	83 c0 20             	add    $0x20,%eax
80100fbf:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100fc2:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100fc9:	0f b7 c0             	movzwl %ax,%eax
80100fcc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100fcf:	0f 8f 28 ff ff ff    	jg     80100efd <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100fd5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100fd8:	89 04 24             	mov    %eax,(%esp)
80100fdb:	e8 60 0e 00 00       	call   80101e40 <iunlockput>
  ip = 0;
80100fe0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100fe7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fea:	05 ff 0f 00 00       	add    $0xfff,%eax
80100fef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ff4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ff7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ffa:	05 00 20 00 00       	add    $0x2000,%eax
80100fff:	89 44 24 08          	mov    %eax,0x8(%esp)
80101003:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101006:	89 44 24 04          	mov    %eax,0x4(%esp)
8010100a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010100d:	89 04 24             	mov    %eax,(%esp)
80101010:	e8 da 72 00 00       	call   801082ef <allocuvm>
80101015:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101018:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010101c:	0f 84 fe 01 00 00    	je     80101220 <exec+0x3d0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80101022:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101025:	2d 00 20 00 00       	sub    $0x2000,%eax
8010102a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010102e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101031:	89 04 24             	mov    %eax,(%esp)
80101034:	e8 da 74 00 00       	call   80108513 <clearpteu>
  sp = sz;
80101039:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010103c:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
8010103f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101046:	e9 81 00 00 00       	jmp    801010cc <exec+0x27c>
    if(argc >= MAXARG)
8010104b:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
8010104f:	0f 87 ce 01 00 00    	ja     80101223 <exec+0x3d3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80101055:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101058:	c1 e0 02             	shl    $0x2,%eax
8010105b:	03 45 0c             	add    0xc(%ebp),%eax
8010105e:	8b 00                	mov    (%eax),%eax
80101060:	89 04 24             	mov    %eax,(%esp)
80101063:	e8 80 45 00 00       	call   801055e8 <strlen>
80101068:	f7 d0                	not    %eax
8010106a:	03 45 dc             	add    -0x24(%ebp),%eax
8010106d:	83 e0 fc             	and    $0xfffffffc,%eax
80101070:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80101073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101076:	c1 e0 02             	shl    $0x2,%eax
80101079:	03 45 0c             	add    0xc(%ebp),%eax
8010107c:	8b 00                	mov    (%eax),%eax
8010107e:	89 04 24             	mov    %eax,(%esp)
80101081:	e8 62 45 00 00       	call   801055e8 <strlen>
80101086:	83 c0 01             	add    $0x1,%eax
80101089:	89 c2                	mov    %eax,%edx
8010108b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010108e:	c1 e0 02             	shl    $0x2,%eax
80101091:	03 45 0c             	add    0xc(%ebp),%eax
80101094:	8b 00                	mov    (%eax),%eax
80101096:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010109a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010109e:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801010a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801010a8:	89 04 24             	mov    %eax,(%esp)
801010ab:	e8 17 76 00 00       	call   801086c7 <copyout>
801010b0:	85 c0                	test   %eax,%eax
801010b2:	0f 88 6e 01 00 00    	js     80101226 <exec+0x3d6>
      goto bad;
    ustack[3+argc] = sp;
801010b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010bb:	8d 50 03             	lea    0x3(%eax),%edx
801010be:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010c1:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
801010c8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801010cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010cf:	c1 e0 02             	shl    $0x2,%eax
801010d2:	03 45 0c             	add    0xc(%ebp),%eax
801010d5:	8b 00                	mov    (%eax),%eax
801010d7:	85 c0                	test   %eax,%eax
801010d9:	0f 85 6c ff ff ff    	jne    8010104b <exec+0x1fb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
801010df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010e2:	83 c0 03             	add    $0x3,%eax
801010e5:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
801010ec:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
801010f0:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
801010f7:	ff ff ff 
  ustack[1] = argc;
801010fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010fd:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80101103:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101106:	83 c0 01             	add    $0x1,%eax
80101109:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101110:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101113:	29 d0                	sub    %edx,%eax
80101115:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
8010111b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010111e:	83 c0 04             	add    $0x4,%eax
80101121:	c1 e0 02             	shl    $0x2,%eax
80101124:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80101127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010112a:	83 c0 04             	add    $0x4,%eax
8010112d:	c1 e0 02             	shl    $0x2,%eax
80101130:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101134:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
8010113a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010113e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101141:	89 44 24 04          	mov    %eax,0x4(%esp)
80101145:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101148:	89 04 24             	mov    %eax,(%esp)
8010114b:	e8 77 75 00 00       	call   801086c7 <copyout>
80101150:	85 c0                	test   %eax,%eax
80101152:	0f 88 d1 00 00 00    	js     80101229 <exec+0x3d9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101158:	8b 45 08             	mov    0x8(%ebp),%eax
8010115b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010115e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101161:	89 45 f0             	mov    %eax,-0x10(%ebp)
80101164:	eb 17                	jmp    8010117d <exec+0x32d>
    if(*s == '/')
80101166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101169:	0f b6 00             	movzbl (%eax),%eax
8010116c:	3c 2f                	cmp    $0x2f,%al
8010116e:	75 09                	jne    80101179 <exec+0x329>
      last = s+1;
80101170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101173:	83 c0 01             	add    $0x1,%eax
80101176:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101179:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010117d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101180:	0f b6 00             	movzbl (%eax),%eax
80101183:	84 c0                	test   %al,%al
80101185:	75 df                	jne    80101166 <exec+0x316>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80101187:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010118d:	8d 50 6c             	lea    0x6c(%eax),%edx
80101190:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101197:	00 
80101198:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010119b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010119f:	89 14 24             	mov    %edx,(%esp)
801011a2:	e8 f3 43 00 00       	call   8010559a <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
801011a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011ad:	8b 40 04             	mov    0x4(%eax),%eax
801011b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
801011b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801011bc:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
801011bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011c5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801011c8:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
801011ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011d0:	8b 40 18             	mov    0x18(%eax),%eax
801011d3:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
801011d9:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
801011dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011e2:	8b 40 18             	mov    0x18(%eax),%eax
801011e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
801011e8:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
801011eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801011f1:	89 04 24             	mov    %eax,(%esp)
801011f4:	e8 15 6e 00 00       	call   8010800e <switchuvm>
  freevm(oldpgdir);
801011f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801011fc:	89 04 24             	mov    %eax,(%esp)
801011ff:	e8 81 72 00 00       	call   80108485 <freevm>
  return 0;
80101204:	b8 00 00 00 00       	mov    $0x0,%eax
80101209:	eb 46                	jmp    80101251 <exec+0x401>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
8010120b:	90                   	nop
8010120c:	eb 1c                	jmp    8010122a <exec+0x3da>
  if(elf.magic != ELF_MAGIC)
    goto bad;
8010120e:	90                   	nop
8010120f:	eb 19                	jmp    8010122a <exec+0x3da>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
80101211:	90                   	nop
80101212:	eb 16                	jmp    8010122a <exec+0x3da>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80101214:	90                   	nop
80101215:	eb 13                	jmp    8010122a <exec+0x3da>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80101217:	90                   	nop
80101218:	eb 10                	jmp    8010122a <exec+0x3da>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
8010121a:	90                   	nop
8010121b:	eb 0d                	jmp    8010122a <exec+0x3da>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
8010121d:	90                   	nop
8010121e:	eb 0a                	jmp    8010122a <exec+0x3da>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80101220:	90                   	nop
80101221:	eb 07                	jmp    8010122a <exec+0x3da>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80101223:	90                   	nop
80101224:	eb 04                	jmp    8010122a <exec+0x3da>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80101226:	90                   	nop
80101227:	eb 01                	jmp    8010122a <exec+0x3da>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80101229:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
8010122a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010122e:	74 0b                	je     8010123b <exec+0x3eb>
    freevm(pgdir);
80101230:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101233:	89 04 24             	mov    %eax,(%esp)
80101236:	e8 4a 72 00 00       	call   80108485 <freevm>
  if(ip)
8010123b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010123f:	74 0b                	je     8010124c <exec+0x3fc>
    iunlockput(ip);
80101241:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101244:	89 04 24             	mov    %eax,(%esp)
80101247:	e8 f4 0b 00 00       	call   80101e40 <iunlockput>
  return -1;
8010124c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101251:	c9                   	leave  
80101252:	c3                   	ret    
	...

80101254 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101254:	55                   	push   %ebp
80101255:	89 e5                	mov    %esp,%ebp
80101257:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
8010125a:	c7 44 24 04 cd 87 10 	movl   $0x801087cd,0x4(%esp)
80101261:	80 
80101262:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101269:	e8 8c 3e 00 00       	call   801050fa <initlock>
}
8010126e:	c9                   	leave  
8010126f:	c3                   	ret    

80101270 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101270:	55                   	push   %ebp
80101271:	89 e5                	mov    %esp,%ebp
80101273:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80101276:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010127d:	e8 99 3e 00 00       	call   8010511b <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101282:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
80101289:	eb 29                	jmp    801012b4 <filealloc+0x44>
    if(f->ref == 0){
8010128b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010128e:	8b 40 04             	mov    0x4(%eax),%eax
80101291:	85 c0                	test   %eax,%eax
80101293:	75 1b                	jne    801012b0 <filealloc+0x40>
      f->ref = 1;
80101295:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101298:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010129f:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012a6:	e8 d2 3e 00 00       	call   8010517d <release>
      return f;
801012ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ae:	eb 1e                	jmp    801012ce <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801012b0:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801012b4:	81 7d f4 14 e8 10 80 	cmpl   $0x8010e814,-0xc(%ebp)
801012bb:	72 ce                	jb     8010128b <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801012bd:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012c4:	e8 b4 3e 00 00       	call   8010517d <release>
  return 0;
801012c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801012ce:	c9                   	leave  
801012cf:	c3                   	ret    

801012d0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801012d0:	55                   	push   %ebp
801012d1:	89 e5                	mov    %esp,%ebp
801012d3:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
801012d6:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012dd:	e8 39 3e 00 00       	call   8010511b <acquire>
  if(f->ref < 1)
801012e2:	8b 45 08             	mov    0x8(%ebp),%eax
801012e5:	8b 40 04             	mov    0x4(%eax),%eax
801012e8:	85 c0                	test   %eax,%eax
801012ea:	7f 0c                	jg     801012f8 <filedup+0x28>
    panic("filedup");
801012ec:	c7 04 24 d4 87 10 80 	movl   $0x801087d4,(%esp)
801012f3:	e8 45 f2 ff ff       	call   8010053d <panic>
  f->ref++;
801012f8:	8b 45 08             	mov    0x8(%ebp),%eax
801012fb:	8b 40 04             	mov    0x4(%eax),%eax
801012fe:	8d 50 01             	lea    0x1(%eax),%edx
80101301:	8b 45 08             	mov    0x8(%ebp),%eax
80101304:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101307:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010130e:	e8 6a 3e 00 00       	call   8010517d <release>
  return f;
80101313:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101316:	c9                   	leave  
80101317:	c3                   	ret    

80101318 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101318:	55                   	push   %ebp
80101319:	89 e5                	mov    %esp,%ebp
8010131b:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
8010131e:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101325:	e8 f1 3d 00 00       	call   8010511b <acquire>
  if(f->ref < 1)
8010132a:	8b 45 08             	mov    0x8(%ebp),%eax
8010132d:	8b 40 04             	mov    0x4(%eax),%eax
80101330:	85 c0                	test   %eax,%eax
80101332:	7f 0c                	jg     80101340 <fileclose+0x28>
    panic("fileclose");
80101334:	c7 04 24 dc 87 10 80 	movl   $0x801087dc,(%esp)
8010133b:	e8 fd f1 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80101340:	8b 45 08             	mov    0x8(%ebp),%eax
80101343:	8b 40 04             	mov    0x4(%eax),%eax
80101346:	8d 50 ff             	lea    -0x1(%eax),%edx
80101349:	8b 45 08             	mov    0x8(%ebp),%eax
8010134c:	89 50 04             	mov    %edx,0x4(%eax)
8010134f:	8b 45 08             	mov    0x8(%ebp),%eax
80101352:	8b 40 04             	mov    0x4(%eax),%eax
80101355:	85 c0                	test   %eax,%eax
80101357:	7e 11                	jle    8010136a <fileclose+0x52>
    release(&ftable.lock);
80101359:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101360:	e8 18 3e 00 00       	call   8010517d <release>
    return;
80101365:	e9 82 00 00 00       	jmp    801013ec <fileclose+0xd4>
  }
  ff = *f;
8010136a:	8b 45 08             	mov    0x8(%ebp),%eax
8010136d:	8b 10                	mov    (%eax),%edx
8010136f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101372:	8b 50 04             	mov    0x4(%eax),%edx
80101375:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101378:	8b 50 08             	mov    0x8(%eax),%edx
8010137b:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010137e:	8b 50 0c             	mov    0xc(%eax),%edx
80101381:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101384:	8b 50 10             	mov    0x10(%eax),%edx
80101387:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010138a:	8b 40 14             	mov    0x14(%eax),%eax
8010138d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101390:	8b 45 08             	mov    0x8(%ebp),%eax
80101393:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010139a:	8b 45 08             	mov    0x8(%ebp),%eax
8010139d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801013a3:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801013aa:	e8 ce 3d 00 00       	call   8010517d <release>
  
  if(ff.type == FD_PIPE)
801013af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013b2:	83 f8 01             	cmp    $0x1,%eax
801013b5:	75 18                	jne    801013cf <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
801013b7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801013bb:	0f be d0             	movsbl %al,%edx
801013be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013c1:	89 54 24 04          	mov    %edx,0x4(%esp)
801013c5:	89 04 24             	mov    %eax,(%esp)
801013c8:	e8 02 2d 00 00       	call   801040cf <pipeclose>
801013cd:	eb 1d                	jmp    801013ec <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801013cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013d2:	83 f8 02             	cmp    $0x2,%eax
801013d5:	75 15                	jne    801013ec <fileclose+0xd4>
    begin_trans();
801013d7:	e8 95 21 00 00       	call   80103571 <begin_trans>
    iput(ff.ip);
801013dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013df:	89 04 24             	mov    %eax,(%esp)
801013e2:	e8 88 09 00 00       	call   80101d6f <iput>
    commit_trans();
801013e7:	e8 ce 21 00 00       	call   801035ba <commit_trans>
  }
}
801013ec:	c9                   	leave  
801013ed:	c3                   	ret    

801013ee <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801013ee:	55                   	push   %ebp
801013ef:	89 e5                	mov    %esp,%ebp
801013f1:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801013f4:	8b 45 08             	mov    0x8(%ebp),%eax
801013f7:	8b 00                	mov    (%eax),%eax
801013f9:	83 f8 02             	cmp    $0x2,%eax
801013fc:	75 38                	jne    80101436 <filestat+0x48>
    ilock(f->ip);
801013fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101401:	8b 40 10             	mov    0x10(%eax),%eax
80101404:	89 04 24             	mov    %eax,(%esp)
80101407:	e8 b0 07 00 00       	call   80101bbc <ilock>
    stati(f->ip, st);
8010140c:	8b 45 08             	mov    0x8(%ebp),%eax
8010140f:	8b 40 10             	mov    0x10(%eax),%eax
80101412:	8b 55 0c             	mov    0xc(%ebp),%edx
80101415:	89 54 24 04          	mov    %edx,0x4(%esp)
80101419:	89 04 24             	mov    %eax,(%esp)
8010141c:	e8 4c 0c 00 00       	call   8010206d <stati>
    iunlock(f->ip);
80101421:	8b 45 08             	mov    0x8(%ebp),%eax
80101424:	8b 40 10             	mov    0x10(%eax),%eax
80101427:	89 04 24             	mov    %eax,(%esp)
8010142a:	e8 db 08 00 00       	call   80101d0a <iunlock>
    return 0;
8010142f:	b8 00 00 00 00       	mov    $0x0,%eax
80101434:	eb 05                	jmp    8010143b <filestat+0x4d>
  }
  return -1;
80101436:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010143b:	c9                   	leave  
8010143c:	c3                   	ret    

8010143d <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010143d:	55                   	push   %ebp
8010143e:	89 e5                	mov    %esp,%ebp
80101440:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101443:	8b 45 08             	mov    0x8(%ebp),%eax
80101446:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010144a:	84 c0                	test   %al,%al
8010144c:	75 0a                	jne    80101458 <fileread+0x1b>
    return -1;
8010144e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101453:	e9 9f 00 00 00       	jmp    801014f7 <fileread+0xba>
  if(f->type == FD_PIPE)
80101458:	8b 45 08             	mov    0x8(%ebp),%eax
8010145b:	8b 00                	mov    (%eax),%eax
8010145d:	83 f8 01             	cmp    $0x1,%eax
80101460:	75 1e                	jne    80101480 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101462:	8b 45 08             	mov    0x8(%ebp),%eax
80101465:	8b 40 0c             	mov    0xc(%eax),%eax
80101468:	8b 55 10             	mov    0x10(%ebp),%edx
8010146b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010146f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101472:	89 54 24 04          	mov    %edx,0x4(%esp)
80101476:	89 04 24             	mov    %eax,(%esp)
80101479:	e8 d3 2d 00 00       	call   80104251 <piperead>
8010147e:	eb 77                	jmp    801014f7 <fileread+0xba>
  if(f->type == FD_INODE){
80101480:	8b 45 08             	mov    0x8(%ebp),%eax
80101483:	8b 00                	mov    (%eax),%eax
80101485:	83 f8 02             	cmp    $0x2,%eax
80101488:	75 61                	jne    801014eb <fileread+0xae>
    ilock(f->ip);
8010148a:	8b 45 08             	mov    0x8(%ebp),%eax
8010148d:	8b 40 10             	mov    0x10(%eax),%eax
80101490:	89 04 24             	mov    %eax,(%esp)
80101493:	e8 24 07 00 00       	call   80101bbc <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101498:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010149b:	8b 45 08             	mov    0x8(%ebp),%eax
8010149e:	8b 50 14             	mov    0x14(%eax),%edx
801014a1:	8b 45 08             	mov    0x8(%ebp),%eax
801014a4:	8b 40 10             	mov    0x10(%eax),%eax
801014a7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801014ab:	89 54 24 08          	mov    %edx,0x8(%esp)
801014af:	8b 55 0c             	mov    0xc(%ebp),%edx
801014b2:	89 54 24 04          	mov    %edx,0x4(%esp)
801014b6:	89 04 24             	mov    %eax,(%esp)
801014b9:	e8 f4 0b 00 00       	call   801020b2 <readi>
801014be:	89 45 f4             	mov    %eax,-0xc(%ebp)
801014c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801014c5:	7e 11                	jle    801014d8 <fileread+0x9b>
      f->off += r;
801014c7:	8b 45 08             	mov    0x8(%ebp),%eax
801014ca:	8b 50 14             	mov    0x14(%eax),%edx
801014cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d0:	01 c2                	add    %eax,%edx
801014d2:	8b 45 08             	mov    0x8(%ebp),%eax
801014d5:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801014d8:	8b 45 08             	mov    0x8(%ebp),%eax
801014db:	8b 40 10             	mov    0x10(%eax),%eax
801014de:	89 04 24             	mov    %eax,(%esp)
801014e1:	e8 24 08 00 00       	call   80101d0a <iunlock>
    return r;
801014e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014e9:	eb 0c                	jmp    801014f7 <fileread+0xba>
  }
  panic("fileread");
801014eb:	c7 04 24 e6 87 10 80 	movl   $0x801087e6,(%esp)
801014f2:	e8 46 f0 ff ff       	call   8010053d <panic>
}
801014f7:	c9                   	leave  
801014f8:	c3                   	ret    

801014f9 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801014f9:	55                   	push   %ebp
801014fa:	89 e5                	mov    %esp,%ebp
801014fc:	53                   	push   %ebx
801014fd:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101500:	8b 45 08             	mov    0x8(%ebp),%eax
80101503:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101507:	84 c0                	test   %al,%al
80101509:	75 0a                	jne    80101515 <filewrite+0x1c>
    return -1;
8010150b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101510:	e9 23 01 00 00       	jmp    80101638 <filewrite+0x13f>
  if(f->type == FD_PIPE)
80101515:	8b 45 08             	mov    0x8(%ebp),%eax
80101518:	8b 00                	mov    (%eax),%eax
8010151a:	83 f8 01             	cmp    $0x1,%eax
8010151d:	75 21                	jne    80101540 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
8010151f:	8b 45 08             	mov    0x8(%ebp),%eax
80101522:	8b 40 0c             	mov    0xc(%eax),%eax
80101525:	8b 55 10             	mov    0x10(%ebp),%edx
80101528:	89 54 24 08          	mov    %edx,0x8(%esp)
8010152c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010152f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101533:	89 04 24             	mov    %eax,(%esp)
80101536:	e8 26 2c 00 00       	call   80104161 <pipewrite>
8010153b:	e9 f8 00 00 00       	jmp    80101638 <filewrite+0x13f>
  if(f->type == FD_INODE){
80101540:	8b 45 08             	mov    0x8(%ebp),%eax
80101543:	8b 00                	mov    (%eax),%eax
80101545:	83 f8 02             	cmp    $0x2,%eax
80101548:	0f 85 de 00 00 00    	jne    8010162c <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010154e:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101555:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010155c:	e9 a8 00 00 00       	jmp    80101609 <filewrite+0x110>
      int n1 = n - i;
80101561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101564:	8b 55 10             	mov    0x10(%ebp),%edx
80101567:	89 d1                	mov    %edx,%ecx
80101569:	29 c1                	sub    %eax,%ecx
8010156b:	89 c8                	mov    %ecx,%eax
8010156d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101570:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101573:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101576:	7e 06                	jle    8010157e <filewrite+0x85>
        n1 = max;
80101578:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010157b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
8010157e:	e8 ee 1f 00 00       	call   80103571 <begin_trans>
      ilock(f->ip);
80101583:	8b 45 08             	mov    0x8(%ebp),%eax
80101586:	8b 40 10             	mov    0x10(%eax),%eax
80101589:	89 04 24             	mov    %eax,(%esp)
8010158c:	e8 2b 06 00 00       	call   80101bbc <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101591:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101594:	8b 45 08             	mov    0x8(%ebp),%eax
80101597:	8b 48 14             	mov    0x14(%eax),%ecx
8010159a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159d:	89 c2                	mov    %eax,%edx
8010159f:	03 55 0c             	add    0xc(%ebp),%edx
801015a2:	8b 45 08             	mov    0x8(%ebp),%eax
801015a5:	8b 40 10             	mov    0x10(%eax),%eax
801015a8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801015ac:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801015b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801015b4:	89 04 24             	mov    %eax,(%esp)
801015b7:	e8 61 0c 00 00       	call   8010221d <writei>
801015bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
801015bf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801015c3:	7e 11                	jle    801015d6 <filewrite+0xdd>
        f->off += r;
801015c5:	8b 45 08             	mov    0x8(%ebp),%eax
801015c8:	8b 50 14             	mov    0x14(%eax),%edx
801015cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015ce:	01 c2                	add    %eax,%edx
801015d0:	8b 45 08             	mov    0x8(%ebp),%eax
801015d3:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801015d6:	8b 45 08             	mov    0x8(%ebp),%eax
801015d9:	8b 40 10             	mov    0x10(%eax),%eax
801015dc:	89 04 24             	mov    %eax,(%esp)
801015df:	e8 26 07 00 00       	call   80101d0a <iunlock>
      commit_trans();
801015e4:	e8 d1 1f 00 00       	call   801035ba <commit_trans>

      if(r < 0)
801015e9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801015ed:	78 28                	js     80101617 <filewrite+0x11e>
        break;
      if(r != n1)
801015ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801015f2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801015f5:	74 0c                	je     80101603 <filewrite+0x10a>
        panic("short filewrite");
801015f7:	c7 04 24 ef 87 10 80 	movl   $0x801087ef,(%esp)
801015fe:	e8 3a ef ff ff       	call   8010053d <panic>
      i += r;
80101603:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101606:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010160c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010160f:	0f 8c 4c ff ff ff    	jl     80101561 <filewrite+0x68>
80101615:	eb 01                	jmp    80101618 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
80101617:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010161e:	75 05                	jne    80101625 <filewrite+0x12c>
80101620:	8b 45 10             	mov    0x10(%ebp),%eax
80101623:	eb 05                	jmp    8010162a <filewrite+0x131>
80101625:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010162a:	eb 0c                	jmp    80101638 <filewrite+0x13f>
  }
  panic("filewrite");
8010162c:	c7 04 24 ff 87 10 80 	movl   $0x801087ff,(%esp)
80101633:	e8 05 ef ff ff       	call   8010053d <panic>
}
80101638:	83 c4 24             	add    $0x24,%esp
8010163b:	5b                   	pop    %ebx
8010163c:	5d                   	pop    %ebp
8010163d:	c3                   	ret    
	...

80101640 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101640:	55                   	push   %ebp
80101641:	89 e5                	mov    %esp,%ebp
80101643:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101646:	8b 45 08             	mov    0x8(%ebp),%eax
80101649:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101650:	00 
80101651:	89 04 24             	mov    %eax,(%esp)
80101654:	e8 4d eb ff ff       	call   801001a6 <bread>
80101659:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010165c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010165f:	83 c0 18             	add    $0x18,%eax
80101662:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101669:	00 
8010166a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010166e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101671:	89 04 24             	mov    %eax,(%esp)
80101674:	e8 c4 3d 00 00       	call   8010543d <memmove>
  brelse(bp);
80101679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010167c:	89 04 24             	mov    %eax,(%esp)
8010167f:	e8 93 eb ff ff       	call   80100217 <brelse>
}
80101684:	c9                   	leave  
80101685:	c3                   	ret    

80101686 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101686:	55                   	push   %ebp
80101687:	89 e5                	mov    %esp,%ebp
80101689:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010168c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010168f:	8b 45 08             	mov    0x8(%ebp),%eax
80101692:	89 54 24 04          	mov    %edx,0x4(%esp)
80101696:	89 04 24             	mov    %eax,(%esp)
80101699:	e8 08 eb ff ff       	call   801001a6 <bread>
8010169e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801016a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016a4:	83 c0 18             	add    $0x18,%eax
801016a7:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801016ae:	00 
801016af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801016b6:	00 
801016b7:	89 04 24             	mov    %eax,(%esp)
801016ba:	e8 ab 3c 00 00       	call   8010536a <memset>
  log_write(bp);
801016bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016c2:	89 04 24             	mov    %eax,(%esp)
801016c5:	e8 48 1f 00 00       	call   80103612 <log_write>
  brelse(bp);
801016ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016cd:	89 04 24             	mov    %eax,(%esp)
801016d0:	e8 42 eb ff ff       	call   80100217 <brelse>
}
801016d5:	c9                   	leave  
801016d6:	c3                   	ret    

801016d7 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801016d7:	55                   	push   %ebp
801016d8:	89 e5                	mov    %esp,%ebp
801016da:	53                   	push   %ebx
801016db:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801016de:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801016e5:	8b 45 08             	mov    0x8(%ebp),%eax
801016e8:	8d 55 d8             	lea    -0x28(%ebp),%edx
801016eb:	89 54 24 04          	mov    %edx,0x4(%esp)
801016ef:	89 04 24             	mov    %eax,(%esp)
801016f2:	e8 49 ff ff ff       	call   80101640 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801016f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801016fe:	e9 11 01 00 00       	jmp    80101814 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101706:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010170c:	85 c0                	test   %eax,%eax
8010170e:	0f 48 c2             	cmovs  %edx,%eax
80101711:	c1 f8 0c             	sar    $0xc,%eax
80101714:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101717:	c1 ea 03             	shr    $0x3,%edx
8010171a:	01 d0                	add    %edx,%eax
8010171c:	83 c0 03             	add    $0x3,%eax
8010171f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101723:	8b 45 08             	mov    0x8(%ebp),%eax
80101726:	89 04 24             	mov    %eax,(%esp)
80101729:	e8 78 ea ff ff       	call   801001a6 <bread>
8010172e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101731:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101738:	e9 a7 00 00 00       	jmp    801017e4 <balloc+0x10d>
      m = 1 << (bi % 8);
8010173d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101740:	89 c2                	mov    %eax,%edx
80101742:	c1 fa 1f             	sar    $0x1f,%edx
80101745:	c1 ea 1d             	shr    $0x1d,%edx
80101748:	01 d0                	add    %edx,%eax
8010174a:	83 e0 07             	and    $0x7,%eax
8010174d:	29 d0                	sub    %edx,%eax
8010174f:	ba 01 00 00 00       	mov    $0x1,%edx
80101754:	89 d3                	mov    %edx,%ebx
80101756:	89 c1                	mov    %eax,%ecx
80101758:	d3 e3                	shl    %cl,%ebx
8010175a:	89 d8                	mov    %ebx,%eax
8010175c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010175f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101762:	8d 50 07             	lea    0x7(%eax),%edx
80101765:	85 c0                	test   %eax,%eax
80101767:	0f 48 c2             	cmovs  %edx,%eax
8010176a:	c1 f8 03             	sar    $0x3,%eax
8010176d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101770:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101775:	0f b6 c0             	movzbl %al,%eax
80101778:	23 45 e8             	and    -0x18(%ebp),%eax
8010177b:	85 c0                	test   %eax,%eax
8010177d:	75 61                	jne    801017e0 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
8010177f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101782:	8d 50 07             	lea    0x7(%eax),%edx
80101785:	85 c0                	test   %eax,%eax
80101787:	0f 48 c2             	cmovs  %edx,%eax
8010178a:	c1 f8 03             	sar    $0x3,%eax
8010178d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101790:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101795:	89 d1                	mov    %edx,%ecx
80101797:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010179a:	09 ca                	or     %ecx,%edx
8010179c:	89 d1                	mov    %edx,%ecx
8010179e:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017a1:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801017a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 62 1e 00 00       	call   80103612 <log_write>
        brelse(bp);
801017b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017b3:	89 04 24             	mov    %eax,(%esp)
801017b6:	e8 5c ea ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
801017bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017c1:	01 c2                	add    %eax,%edx
801017c3:	8b 45 08             	mov    0x8(%ebp),%eax
801017c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801017ca:	89 04 24             	mov    %eax,(%esp)
801017cd:	e8 b4 fe ff ff       	call   80101686 <bzero>
        return b + bi;
801017d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017d8:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
801017da:	83 c4 34             	add    $0x34,%esp
801017dd:	5b                   	pop    %ebx
801017de:	5d                   	pop    %ebp
801017df:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801017e0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801017e4:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801017eb:	7f 15                	jg     80101802 <balloc+0x12b>
801017ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017f3:	01 d0                	add    %edx,%eax
801017f5:	89 c2                	mov    %eax,%edx
801017f7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801017fa:	39 c2                	cmp    %eax,%edx
801017fc:	0f 82 3b ff ff ff    	jb     8010173d <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101802:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101805:	89 04 24             	mov    %eax,(%esp)
80101808:	e8 0a ea ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
8010180d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101814:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101817:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010181a:	39 c2                	cmp    %eax,%edx
8010181c:	0f 82 e1 fe ff ff    	jb     80101703 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101822:	c7 04 24 09 88 10 80 	movl   $0x80108809,(%esp)
80101829:	e8 0f ed ff ff       	call   8010053d <panic>

8010182e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010182e:	55                   	push   %ebp
8010182f:	89 e5                	mov    %esp,%ebp
80101831:	53                   	push   %ebx
80101832:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101835:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101838:	89 44 24 04          	mov    %eax,0x4(%esp)
8010183c:	8b 45 08             	mov    0x8(%ebp),%eax
8010183f:	89 04 24             	mov    %eax,(%esp)
80101842:	e8 f9 fd ff ff       	call   80101640 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101847:	8b 45 0c             	mov    0xc(%ebp),%eax
8010184a:	89 c2                	mov    %eax,%edx
8010184c:	c1 ea 0c             	shr    $0xc,%edx
8010184f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101852:	c1 e8 03             	shr    $0x3,%eax
80101855:	01 d0                	add    %edx,%eax
80101857:	8d 50 03             	lea    0x3(%eax),%edx
8010185a:	8b 45 08             	mov    0x8(%ebp),%eax
8010185d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101861:	89 04 24             	mov    %eax,(%esp)
80101864:	e8 3d e9 ff ff       	call   801001a6 <bread>
80101869:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010186c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010186f:	25 ff 0f 00 00       	and    $0xfff,%eax
80101874:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187a:	89 c2                	mov    %eax,%edx
8010187c:	c1 fa 1f             	sar    $0x1f,%edx
8010187f:	c1 ea 1d             	shr    $0x1d,%edx
80101882:	01 d0                	add    %edx,%eax
80101884:	83 e0 07             	and    $0x7,%eax
80101887:	29 d0                	sub    %edx,%eax
80101889:	ba 01 00 00 00       	mov    $0x1,%edx
8010188e:	89 d3                	mov    %edx,%ebx
80101890:	89 c1                	mov    %eax,%ecx
80101892:	d3 e3                	shl    %cl,%ebx
80101894:	89 d8                	mov    %ebx,%eax
80101896:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101899:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189c:	8d 50 07             	lea    0x7(%eax),%edx
8010189f:	85 c0                	test   %eax,%eax
801018a1:	0f 48 c2             	cmovs  %edx,%eax
801018a4:	c1 f8 03             	sar    $0x3,%eax
801018a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018aa:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801018af:	0f b6 c0             	movzbl %al,%eax
801018b2:	23 45 ec             	and    -0x14(%ebp),%eax
801018b5:	85 c0                	test   %eax,%eax
801018b7:	75 0c                	jne    801018c5 <bfree+0x97>
    panic("freeing free block");
801018b9:	c7 04 24 1f 88 10 80 	movl   $0x8010881f,(%esp)
801018c0:	e8 78 ec ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
801018c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c8:	8d 50 07             	lea    0x7(%eax),%edx
801018cb:	85 c0                	test   %eax,%eax
801018cd:	0f 48 c2             	cmovs  %edx,%eax
801018d0:	c1 f8 03             	sar    $0x3,%eax
801018d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018d6:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801018db:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801018de:	f7 d1                	not    %ecx
801018e0:	21 ca                	and    %ecx,%edx
801018e2:	89 d1                	mov    %edx,%ecx
801018e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018e7:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801018eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ee:	89 04 24             	mov    %eax,(%esp)
801018f1:	e8 1c 1d 00 00       	call   80103612 <log_write>
  brelse(bp);
801018f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f9:	89 04 24             	mov    %eax,(%esp)
801018fc:	e8 16 e9 ff ff       	call   80100217 <brelse>
}
80101901:	83 c4 34             	add    $0x34,%esp
80101904:	5b                   	pop    %ebx
80101905:	5d                   	pop    %ebp
80101906:	c3                   	ret    

80101907 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101907:	55                   	push   %ebp
80101908:	89 e5                	mov    %esp,%ebp
8010190a:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
8010190d:	c7 44 24 04 32 88 10 	movl   $0x80108832,0x4(%esp)
80101914:	80 
80101915:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
8010191c:	e8 d9 37 00 00       	call   801050fa <initlock>
}
80101921:	c9                   	leave  
80101922:	c3                   	ret    

80101923 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101923:	55                   	push   %ebp
80101924:	89 e5                	mov    %esp,%ebp
80101926:	83 ec 48             	sub    $0x48,%esp
80101929:	8b 45 0c             	mov    0xc(%ebp),%eax
8010192c:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101930:	8b 45 08             	mov    0x8(%ebp),%eax
80101933:	8d 55 dc             	lea    -0x24(%ebp),%edx
80101936:	89 54 24 04          	mov    %edx,0x4(%esp)
8010193a:	89 04 24             	mov    %eax,(%esp)
8010193d:	e8 fe fc ff ff       	call   80101640 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
80101942:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101949:	e9 98 00 00 00       	jmp    801019e6 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
8010194e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101951:	c1 e8 03             	shr    $0x3,%eax
80101954:	83 c0 02             	add    $0x2,%eax
80101957:	89 44 24 04          	mov    %eax,0x4(%esp)
8010195b:	8b 45 08             	mov    0x8(%ebp),%eax
8010195e:	89 04 24             	mov    %eax,(%esp)
80101961:	e8 40 e8 ff ff       	call   801001a6 <bread>
80101966:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101969:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196c:	8d 50 18             	lea    0x18(%eax),%edx
8010196f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101972:	83 e0 07             	and    $0x7,%eax
80101975:	c1 e0 06             	shl    $0x6,%eax
80101978:	01 d0                	add    %edx,%eax
8010197a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010197d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101980:	0f b7 00             	movzwl (%eax),%eax
80101983:	66 85 c0             	test   %ax,%ax
80101986:	75 4f                	jne    801019d7 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101988:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010198f:	00 
80101990:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101997:	00 
80101998:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010199b:	89 04 24             	mov    %eax,(%esp)
8010199e:	e8 c7 39 00 00       	call   8010536a <memset>
      dip->type = type;
801019a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801019a6:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801019aa:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801019ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b0:	89 04 24             	mov    %eax,(%esp)
801019b3:	e8 5a 1c 00 00       	call   80103612 <log_write>
      brelse(bp);
801019b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bb:	89 04 24             	mov    %eax,(%esp)
801019be:	e8 54 e8 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
801019c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801019ca:	8b 45 08             	mov    0x8(%ebp),%eax
801019cd:	89 04 24             	mov    %eax,(%esp)
801019d0:	e8 e3 00 00 00       	call   80101ab8 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
801019d5:	c9                   	leave  
801019d6:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801019d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019da:	89 04 24             	mov    %eax,(%esp)
801019dd:	e8 35 e8 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801019e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801019e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801019e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801019ec:	39 c2                	cmp    %eax,%edx
801019ee:	0f 82 5a ff ff ff    	jb     8010194e <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801019f4:	c7 04 24 39 88 10 80 	movl   $0x80108839,(%esp)
801019fb:	e8 3d eb ff ff       	call   8010053d <panic>

80101a00 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101a00:	55                   	push   %ebp
80101a01:	89 e5                	mov    %esp,%ebp
80101a03:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101a06:	8b 45 08             	mov    0x8(%ebp),%eax
80101a09:	8b 40 04             	mov    0x4(%eax),%eax
80101a0c:	c1 e8 03             	shr    $0x3,%eax
80101a0f:	8d 50 02             	lea    0x2(%eax),%edx
80101a12:	8b 45 08             	mov    0x8(%ebp),%eax
80101a15:	8b 00                	mov    (%eax),%eax
80101a17:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a1b:	89 04 24             	mov    %eax,(%esp)
80101a1e:	e8 83 e7 ff ff       	call   801001a6 <bread>
80101a23:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a29:	8d 50 18             	lea    0x18(%eax),%edx
80101a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2f:	8b 40 04             	mov    0x4(%eax),%eax
80101a32:	83 e0 07             	and    $0x7,%eax
80101a35:	c1 e0 06             	shl    $0x6,%eax
80101a38:	01 d0                	add    %edx,%eax
80101a3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a40:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a47:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101a4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4d:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a54:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101a58:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5b:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a62:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101a66:	8b 45 08             	mov    0x8(%ebp),%eax
80101a69:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a70:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101a74:	8b 45 08             	mov    0x8(%ebp),%eax
80101a77:	8b 50 18             	mov    0x18(%eax),%edx
80101a7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7d:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	8d 50 1c             	lea    0x1c(%eax),%edx
80101a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a89:	83 c0 0c             	add    $0xc,%eax
80101a8c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a93:	00 
80101a94:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a98:	89 04 24             	mov    %eax,(%esp)
80101a9b:	e8 9d 39 00 00       	call   8010543d <memmove>
  log_write(bp);
80101aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa3:	89 04 24             	mov    %eax,(%esp)
80101aa6:	e8 67 1b 00 00       	call   80103612 <log_write>
  brelse(bp);
80101aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aae:	89 04 24             	mov    %eax,(%esp)
80101ab1:	e8 61 e7 ff ff       	call   80100217 <brelse>
}
80101ab6:	c9                   	leave  
80101ab7:	c3                   	ret    

80101ab8 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101ab8:	55                   	push   %ebp
80101ab9:	89 e5                	mov    %esp,%ebp
80101abb:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101abe:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101ac5:	e8 51 36 00 00       	call   8010511b <acquire>

  // Is the inode already cached?
  empty = 0;
80101aca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101ad1:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
80101ad8:	eb 59                	jmp    80101b33 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101add:	8b 40 08             	mov    0x8(%eax),%eax
80101ae0:	85 c0                	test   %eax,%eax
80101ae2:	7e 35                	jle    80101b19 <iget+0x61>
80101ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ae7:	8b 00                	mov    (%eax),%eax
80101ae9:	3b 45 08             	cmp    0x8(%ebp),%eax
80101aec:	75 2b                	jne    80101b19 <iget+0x61>
80101aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af1:	8b 40 04             	mov    0x4(%eax),%eax
80101af4:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101af7:	75 20                	jne    80101b19 <iget+0x61>
      ip->ref++;
80101af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101afc:	8b 40 08             	mov    0x8(%eax),%eax
80101aff:	8d 50 01             	lea    0x1(%eax),%edx
80101b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b05:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101b08:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b0f:	e8 69 36 00 00       	call   8010517d <release>
      return ip;
80101b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b17:	eb 6f                	jmp    80101b88 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101b19:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b1d:	75 10                	jne    80101b2f <iget+0x77>
80101b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b22:	8b 40 08             	mov    0x8(%eax),%eax
80101b25:	85 c0                	test   %eax,%eax
80101b27:	75 06                	jne    80101b2f <iget+0x77>
      empty = ip;
80101b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b2c:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101b2f:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101b33:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
80101b3a:	72 9e                	jb     80101ada <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101b3c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101b40:	75 0c                	jne    80101b4e <iget+0x96>
    panic("iget: no inodes");
80101b42:	c7 04 24 4b 88 10 80 	movl   $0x8010884b,(%esp)
80101b49:	e8 ef e9 ff ff       	call   8010053d <panic>

  ip = empty;
80101b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b51:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b57:	8b 55 08             	mov    0x8(%ebp),%edx
80101b5a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b5f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b62:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b68:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b72:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101b79:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b80:	e8 f8 35 00 00       	call   8010517d <release>

  return ip;
80101b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b88:	c9                   	leave  
80101b89:	c3                   	ret    

80101b8a <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b8a:	55                   	push   %ebp
80101b8b:	89 e5                	mov    %esp,%ebp
80101b8d:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101b90:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b97:	e8 7f 35 00 00       	call   8010511b <acquire>
  ip->ref++;
80101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9f:	8b 40 08             	mov    0x8(%eax),%eax
80101ba2:	8d 50 01             	lea    0x1(%eax),%edx
80101ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba8:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bab:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101bb2:	e8 c6 35 00 00       	call   8010517d <release>
  return ip;
80101bb7:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101bba:	c9                   	leave  
80101bbb:	c3                   	ret    

80101bbc <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101bbc:	55                   	push   %ebp
80101bbd:	89 e5                	mov    %esp,%ebp
80101bbf:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101bc2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bc6:	74 0a                	je     80101bd2 <ilock+0x16>
80101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcb:	8b 40 08             	mov    0x8(%eax),%eax
80101bce:	85 c0                	test   %eax,%eax
80101bd0:	7f 0c                	jg     80101bde <ilock+0x22>
    panic("ilock");
80101bd2:	c7 04 24 5b 88 10 80 	movl   $0x8010885b,(%esp)
80101bd9:	e8 5f e9 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101bde:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101be5:	e8 31 35 00 00       	call   8010511b <acquire>
  while(ip->flags & I_BUSY)
80101bea:	eb 13                	jmp    80101bff <ilock+0x43>
    sleep(ip, &icache.lock);
80101bec:	c7 44 24 04 80 e8 10 	movl   $0x8010e880,0x4(%esp)
80101bf3:	80 
80101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf7:	89 04 24             	mov    %eax,(%esp)
80101bfa:	e8 36 32 00 00       	call   80104e35 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101bff:	8b 45 08             	mov    0x8(%ebp),%eax
80101c02:	8b 40 0c             	mov    0xc(%eax),%eax
80101c05:	83 e0 01             	and    $0x1,%eax
80101c08:	84 c0                	test   %al,%al
80101c0a:	75 e0                	jne    80101bec <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0f:	8b 40 0c             	mov    0xc(%eax),%eax
80101c12:	89 c2                	mov    %eax,%edx
80101c14:	83 ca 01             	or     $0x1,%edx
80101c17:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1a:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101c1d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101c24:	e8 54 35 00 00       	call   8010517d <release>

  if(!(ip->flags & I_VALID)){
80101c29:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2c:	8b 40 0c             	mov    0xc(%eax),%eax
80101c2f:	83 e0 02             	and    $0x2,%eax
80101c32:	85 c0                	test   %eax,%eax
80101c34:	0f 85 ce 00 00 00    	jne    80101d08 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101c3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3d:	8b 40 04             	mov    0x4(%eax),%eax
80101c40:	c1 e8 03             	shr    $0x3,%eax
80101c43:	8d 50 02             	lea    0x2(%eax),%edx
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 00                	mov    (%eax),%eax
80101c4b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c4f:	89 04 24             	mov    %eax,(%esp)
80101c52:	e8 4f e5 ff ff       	call   801001a6 <bread>
80101c57:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c5d:	8d 50 18             	lea    0x18(%eax),%edx
80101c60:	8b 45 08             	mov    0x8(%ebp),%eax
80101c63:	8b 40 04             	mov    0x4(%eax),%eax
80101c66:	83 e0 07             	and    $0x7,%eax
80101c69:	c1 e0 06             	shl    $0x6,%eax
80101c6c:	01 d0                	add    %edx,%eax
80101c6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c74:	0f b7 10             	movzwl (%eax),%edx
80101c77:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7a:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c81:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101c85:	8b 45 08             	mov    0x8(%ebp),%eax
80101c88:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101c8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c8f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101c93:	8b 45 08             	mov    0x8(%ebp),%eax
80101c96:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c9d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca4:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101ca8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cab:	8b 50 08             	mov    0x8(%eax),%edx
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb7:	8d 50 0c             	lea    0xc(%eax),%edx
80101cba:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbd:	83 c0 1c             	add    $0x1c,%eax
80101cc0:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101cc7:	00 
80101cc8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ccc:	89 04 24             	mov    %eax,(%esp)
80101ccf:	e8 69 37 00 00       	call   8010543d <memmove>
    brelse(bp);
80101cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cd7:	89 04 24             	mov    %eax,(%esp)
80101cda:	e8 38 e5 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce2:	8b 40 0c             	mov    0xc(%eax),%eax
80101ce5:	89 c2                	mov    %eax,%edx
80101ce7:	83 ca 02             	or     $0x2,%edx
80101cea:	8b 45 08             	mov    0x8(%ebp),%eax
80101ced:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101cf7:	66 85 c0             	test   %ax,%ax
80101cfa:	75 0c                	jne    80101d08 <ilock+0x14c>
      panic("ilock: no type");
80101cfc:	c7 04 24 61 88 10 80 	movl   $0x80108861,(%esp)
80101d03:	e8 35 e8 ff ff       	call   8010053d <panic>
  }
}
80101d08:	c9                   	leave  
80101d09:	c3                   	ret    

80101d0a <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101d0a:	55                   	push   %ebp
80101d0b:	89 e5                	mov    %esp,%ebp
80101d0d:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101d10:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101d14:	74 17                	je     80101d2d <iunlock+0x23>
80101d16:	8b 45 08             	mov    0x8(%ebp),%eax
80101d19:	8b 40 0c             	mov    0xc(%eax),%eax
80101d1c:	83 e0 01             	and    $0x1,%eax
80101d1f:	85 c0                	test   %eax,%eax
80101d21:	74 0a                	je     80101d2d <iunlock+0x23>
80101d23:	8b 45 08             	mov    0x8(%ebp),%eax
80101d26:	8b 40 08             	mov    0x8(%eax),%eax
80101d29:	85 c0                	test   %eax,%eax
80101d2b:	7f 0c                	jg     80101d39 <iunlock+0x2f>
    panic("iunlock");
80101d2d:	c7 04 24 70 88 10 80 	movl   $0x80108870,(%esp)
80101d34:	e8 04 e8 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101d39:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d40:	e8 d6 33 00 00       	call   8010511b <acquire>
  ip->flags &= ~I_BUSY;
80101d45:	8b 45 08             	mov    0x8(%ebp),%eax
80101d48:	8b 40 0c             	mov    0xc(%eax),%eax
80101d4b:	89 c2                	mov    %eax,%edx
80101d4d:	83 e2 fe             	and    $0xfffffffe,%edx
80101d50:	8b 45 08             	mov    0x8(%ebp),%eax
80101d53:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101d56:	8b 45 08             	mov    0x8(%ebp),%eax
80101d59:	89 04 24             	mov    %eax,(%esp)
80101d5c:	e8 b0 31 00 00       	call   80104f11 <wakeup>
  release(&icache.lock);
80101d61:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d68:	e8 10 34 00 00       	call   8010517d <release>
}
80101d6d:	c9                   	leave  
80101d6e:	c3                   	ret    

80101d6f <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101d6f:	55                   	push   %ebp
80101d70:	89 e5                	mov    %esp,%ebp
80101d72:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101d75:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d7c:	e8 9a 33 00 00       	call   8010511b <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101d81:	8b 45 08             	mov    0x8(%ebp),%eax
80101d84:	8b 40 08             	mov    0x8(%eax),%eax
80101d87:	83 f8 01             	cmp    $0x1,%eax
80101d8a:	0f 85 93 00 00 00    	jne    80101e23 <iput+0xb4>
80101d90:	8b 45 08             	mov    0x8(%ebp),%eax
80101d93:	8b 40 0c             	mov    0xc(%eax),%eax
80101d96:	83 e0 02             	and    $0x2,%eax
80101d99:	85 c0                	test   %eax,%eax
80101d9b:	0f 84 82 00 00 00    	je     80101e23 <iput+0xb4>
80101da1:	8b 45 08             	mov    0x8(%ebp),%eax
80101da4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101da8:	66 85 c0             	test   %ax,%ax
80101dab:	75 76                	jne    80101e23 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101dad:	8b 45 08             	mov    0x8(%ebp),%eax
80101db0:	8b 40 0c             	mov    0xc(%eax),%eax
80101db3:	83 e0 01             	and    $0x1,%eax
80101db6:	84 c0                	test   %al,%al
80101db8:	74 0c                	je     80101dc6 <iput+0x57>
      panic("iput busy");
80101dba:	c7 04 24 78 88 10 80 	movl   $0x80108878,(%esp)
80101dc1:	e8 77 e7 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101dc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc9:	8b 40 0c             	mov    0xc(%eax),%eax
80101dcc:	89 c2                	mov    %eax,%edx
80101dce:	83 ca 01             	or     $0x1,%edx
80101dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd4:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101dd7:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101dde:	e8 9a 33 00 00       	call   8010517d <release>
    itrunc(ip);
80101de3:	8b 45 08             	mov    0x8(%ebp),%eax
80101de6:	89 04 24             	mov    %eax,(%esp)
80101de9:	e8 72 01 00 00       	call   80101f60 <itrunc>
    ip->type = 0;
80101dee:	8b 45 08             	mov    0x8(%ebp),%eax
80101df1:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101df7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfa:	89 04 24             	mov    %eax,(%esp)
80101dfd:	e8 fe fb ff ff       	call   80101a00 <iupdate>
    acquire(&icache.lock);
80101e02:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101e09:	e8 0d 33 00 00       	call   8010511b <acquire>
    ip->flags = 0;
80101e0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e11:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101e18:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1b:	89 04 24             	mov    %eax,(%esp)
80101e1e:	e8 ee 30 00 00       	call   80104f11 <wakeup>
  }
  ip->ref--;
80101e23:	8b 45 08             	mov    0x8(%ebp),%eax
80101e26:	8b 40 08             	mov    0x8(%eax),%eax
80101e29:	8d 50 ff             	lea    -0x1(%eax),%edx
80101e2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2f:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101e32:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101e39:	e8 3f 33 00 00       	call   8010517d <release>
}
80101e3e:	c9                   	leave  
80101e3f:	c3                   	ret    

80101e40 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101e40:	55                   	push   %ebp
80101e41:	89 e5                	mov    %esp,%ebp
80101e43:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101e46:	8b 45 08             	mov    0x8(%ebp),%eax
80101e49:	89 04 24             	mov    %eax,(%esp)
80101e4c:	e8 b9 fe ff ff       	call   80101d0a <iunlock>
  iput(ip);
80101e51:	8b 45 08             	mov    0x8(%ebp),%eax
80101e54:	89 04 24             	mov    %eax,(%esp)
80101e57:	e8 13 ff ff ff       	call   80101d6f <iput>
}
80101e5c:	c9                   	leave  
80101e5d:	c3                   	ret    

80101e5e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101e5e:	55                   	push   %ebp
80101e5f:	89 e5                	mov    %esp,%ebp
80101e61:	53                   	push   %ebx
80101e62:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101e65:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101e69:	77 3e                	ja     80101ea9 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e71:	83 c2 04             	add    $0x4,%edx
80101e74:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e7f:	75 20                	jne    80101ea1 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e81:	8b 45 08             	mov    0x8(%ebp),%eax
80101e84:	8b 00                	mov    (%eax),%eax
80101e86:	89 04 24             	mov    %eax,(%esp)
80101e89:	e8 49 f8 ff ff       	call   801016d7 <balloc>
80101e8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e91:	8b 45 08             	mov    0x8(%ebp),%eax
80101e94:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e97:	8d 4a 04             	lea    0x4(%edx),%ecx
80101e9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e9d:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ea4:	e9 b1 00 00 00       	jmp    80101f5a <bmap+0xfc>
  }
  bn -= NDIRECT;
80101ea9:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ead:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101eb1:	0f 87 97 00 00 00    	ja     80101f4e <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101eb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eba:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ebd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ec0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ec4:	75 19                	jne    80101edf <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec9:	8b 00                	mov    (%eax),%eax
80101ecb:	89 04 24             	mov    %eax,(%esp)
80101ece:	e8 04 f8 ff ff       	call   801016d7 <balloc>
80101ed3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101edc:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101edf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee2:	8b 00                	mov    (%eax),%eax
80101ee4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ee7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eeb:	89 04 24             	mov    %eax,(%esp)
80101eee:	e8 b3 e2 ff ff       	call   801001a6 <bread>
80101ef3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ef9:	83 c0 18             	add    $0x18,%eax
80101efc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101eff:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f02:	c1 e0 02             	shl    $0x2,%eax
80101f05:	03 45 ec             	add    -0x14(%ebp),%eax
80101f08:	8b 00                	mov    (%eax),%eax
80101f0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101f11:	75 2b                	jne    80101f3e <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101f13:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f16:	c1 e0 02             	shl    $0x2,%eax
80101f19:	89 c3                	mov    %eax,%ebx
80101f1b:	03 5d ec             	add    -0x14(%ebp),%ebx
80101f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f21:	8b 00                	mov    (%eax),%eax
80101f23:	89 04 24             	mov    %eax,(%esp)
80101f26:	e8 ac f7 ff ff       	call   801016d7 <balloc>
80101f2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f31:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f36:	89 04 24             	mov    %eax,(%esp)
80101f39:	e8 d4 16 00 00       	call   80103612 <log_write>
    }
    brelse(bp);
80101f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f41:	89 04 24             	mov    %eax,(%esp)
80101f44:	e8 ce e2 ff ff       	call   80100217 <brelse>
    return addr;
80101f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f4c:	eb 0c                	jmp    80101f5a <bmap+0xfc>
  }

  panic("bmap: out of range");
80101f4e:	c7 04 24 82 88 10 80 	movl   $0x80108882,(%esp)
80101f55:	e8 e3 e5 ff ff       	call   8010053d <panic>
}
80101f5a:	83 c4 24             	add    $0x24,%esp
80101f5d:	5b                   	pop    %ebx
80101f5e:	5d                   	pop    %ebp
80101f5f:	c3                   	ret    

80101f60 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f60:	55                   	push   %ebp
80101f61:	89 e5                	mov    %esp,%ebp
80101f63:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f6d:	eb 44                	jmp    80101fb3 <itrunc+0x53>
    if(ip->addrs[i]){
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f75:	83 c2 04             	add    $0x4,%edx
80101f78:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f7c:	85 c0                	test   %eax,%eax
80101f7e:	74 2f                	je     80101faf <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101f80:	8b 45 08             	mov    0x8(%ebp),%eax
80101f83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f86:	83 c2 04             	add    $0x4,%edx
80101f89:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101f8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f90:	8b 00                	mov    (%eax),%eax
80101f92:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f96:	89 04 24             	mov    %eax,(%esp)
80101f99:	e8 90 f8 ff ff       	call   8010182e <bfree>
      ip->addrs[i] = 0;
80101f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101fa4:	83 c2 04             	add    $0x4,%edx
80101fa7:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101fae:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101faf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101fb3:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101fb7:	7e b6                	jle    80101f6f <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbc:	8b 40 4c             	mov    0x4c(%eax),%eax
80101fbf:	85 c0                	test   %eax,%eax
80101fc1:	0f 84 8f 00 00 00    	je     80102056 <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101fc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101fca:	8b 50 4c             	mov    0x4c(%eax),%edx
80101fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd0:	8b 00                	mov    (%eax),%eax
80101fd2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fd6:	89 04 24             	mov    %eax,(%esp)
80101fd9:	e8 c8 e1 ff ff       	call   801001a6 <bread>
80101fde:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101fe1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fe4:	83 c0 18             	add    $0x18,%eax
80101fe7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101fea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ff1:	eb 2f                	jmp    80102022 <itrunc+0xc2>
      if(a[j])
80101ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff6:	c1 e0 02             	shl    $0x2,%eax
80101ff9:	03 45 e8             	add    -0x18(%ebp),%eax
80101ffc:	8b 00                	mov    (%eax),%eax
80101ffe:	85 c0                	test   %eax,%eax
80102000:	74 1c                	je     8010201e <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80102002:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102005:	c1 e0 02             	shl    $0x2,%eax
80102008:	03 45 e8             	add    -0x18(%ebp),%eax
8010200b:	8b 10                	mov    (%eax),%edx
8010200d:	8b 45 08             	mov    0x8(%ebp),%eax
80102010:	8b 00                	mov    (%eax),%eax
80102012:	89 54 24 04          	mov    %edx,0x4(%esp)
80102016:	89 04 24             	mov    %eax,(%esp)
80102019:	e8 10 f8 ff ff       	call   8010182e <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
8010201e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80102022:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102025:	83 f8 7f             	cmp    $0x7f,%eax
80102028:	76 c9                	jbe    80101ff3 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
8010202a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202d:	89 04 24             	mov    %eax,(%esp)
80102030:	e8 e2 e1 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80102035:	8b 45 08             	mov    0x8(%ebp),%eax
80102038:	8b 50 4c             	mov    0x4c(%eax),%edx
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	8b 00                	mov    (%eax),%eax
80102040:	89 54 24 04          	mov    %edx,0x4(%esp)
80102044:	89 04 24             	mov    %eax,(%esp)
80102047:	e8 e2 f7 ff ff       	call   8010182e <bfree>
    ip->addrs[NDIRECT] = 0;
8010204c:	8b 45 08             	mov    0x8(%ebp),%eax
8010204f:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80102056:	8b 45 08             	mov    0x8(%ebp),%eax
80102059:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80102060:	8b 45 08             	mov    0x8(%ebp),%eax
80102063:	89 04 24             	mov    %eax,(%esp)
80102066:	e8 95 f9 ff ff       	call   80101a00 <iupdate>
}
8010206b:	c9                   	leave  
8010206c:	c3                   	ret    

8010206d <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
8010206d:	55                   	push   %ebp
8010206e:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102070:	8b 45 08             	mov    0x8(%ebp),%eax
80102073:	8b 00                	mov    (%eax),%eax
80102075:	89 c2                	mov    %eax,%edx
80102077:	8b 45 0c             	mov    0xc(%ebp),%eax
8010207a:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
8010207d:	8b 45 08             	mov    0x8(%ebp),%eax
80102080:	8b 50 04             	mov    0x4(%eax),%edx
80102083:	8b 45 0c             	mov    0xc(%ebp),%eax
80102086:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102089:	8b 45 08             	mov    0x8(%ebp),%eax
8010208c:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80102090:	8b 45 0c             	mov    0xc(%ebp),%eax
80102093:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102096:	8b 45 08             	mov    0x8(%ebp),%eax
80102099:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010209d:	8b 45 0c             	mov    0xc(%ebp),%eax
801020a0:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
801020a4:	8b 45 08             	mov    0x8(%ebp),%eax
801020a7:	8b 50 18             	mov    0x18(%eax),%edx
801020aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801020ad:	89 50 10             	mov    %edx,0x10(%eax)
}
801020b0:	5d                   	pop    %ebp
801020b1:	c3                   	ret    

801020b2 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
801020b2:	55                   	push   %ebp
801020b3:	89 e5                	mov    %esp,%ebp
801020b5:	53                   	push   %ebx
801020b6:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020b9:	8b 45 08             	mov    0x8(%ebp),%eax
801020bc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020c0:	66 83 f8 03          	cmp    $0x3,%ax
801020c4:	75 60                	jne    80102126 <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801020c6:	8b 45 08             	mov    0x8(%ebp),%eax
801020c9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020cd:	66 85 c0             	test   %ax,%ax
801020d0:	78 20                	js     801020f2 <readi+0x40>
801020d2:	8b 45 08             	mov    0x8(%ebp),%eax
801020d5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020d9:	66 83 f8 09          	cmp    $0x9,%ax
801020dd:	7f 13                	jg     801020f2 <readi+0x40>
801020df:	8b 45 08             	mov    0x8(%ebp),%eax
801020e2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020e6:	98                   	cwtl   
801020e7:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
801020ee:	85 c0                	test   %eax,%eax
801020f0:	75 0a                	jne    801020fc <readi+0x4a>
      return -1;
801020f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020f7:	e9 1b 01 00 00       	jmp    80102217 <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
801020fc:	8b 45 08             	mov    0x8(%ebp),%eax
801020ff:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102103:	98                   	cwtl   
80102104:	8b 14 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%edx
8010210b:	8b 45 14             	mov    0x14(%ebp),%eax
8010210e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102112:	8b 45 0c             	mov    0xc(%ebp),%eax
80102115:	89 44 24 04          	mov    %eax,0x4(%esp)
80102119:	8b 45 08             	mov    0x8(%ebp),%eax
8010211c:	89 04 24             	mov    %eax,(%esp)
8010211f:	ff d2                	call   *%edx
80102121:	e9 f1 00 00 00       	jmp    80102217 <readi+0x165>
  }

  if(off > ip->size || off + n < off)
80102126:	8b 45 08             	mov    0x8(%ebp),%eax
80102129:	8b 40 18             	mov    0x18(%eax),%eax
8010212c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010212f:	72 0d                	jb     8010213e <readi+0x8c>
80102131:	8b 45 14             	mov    0x14(%ebp),%eax
80102134:	8b 55 10             	mov    0x10(%ebp),%edx
80102137:	01 d0                	add    %edx,%eax
80102139:	3b 45 10             	cmp    0x10(%ebp),%eax
8010213c:	73 0a                	jae    80102148 <readi+0x96>
    return -1;
8010213e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102143:	e9 cf 00 00 00       	jmp    80102217 <readi+0x165>
  if(off + n > ip->size)
80102148:	8b 45 14             	mov    0x14(%ebp),%eax
8010214b:	8b 55 10             	mov    0x10(%ebp),%edx
8010214e:	01 c2                	add    %eax,%edx
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	8b 40 18             	mov    0x18(%eax),%eax
80102156:	39 c2                	cmp    %eax,%edx
80102158:	76 0c                	jbe    80102166 <readi+0xb4>
    n = ip->size - off;
8010215a:	8b 45 08             	mov    0x8(%ebp),%eax
8010215d:	8b 40 18             	mov    0x18(%eax),%eax
80102160:	2b 45 10             	sub    0x10(%ebp),%eax
80102163:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102166:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010216d:	e9 96 00 00 00       	jmp    80102208 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102172:	8b 45 10             	mov    0x10(%ebp),%eax
80102175:	c1 e8 09             	shr    $0x9,%eax
80102178:	89 44 24 04          	mov    %eax,0x4(%esp)
8010217c:	8b 45 08             	mov    0x8(%ebp),%eax
8010217f:	89 04 24             	mov    %eax,(%esp)
80102182:	e8 d7 fc ff ff       	call   80101e5e <bmap>
80102187:	8b 55 08             	mov    0x8(%ebp),%edx
8010218a:	8b 12                	mov    (%edx),%edx
8010218c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102190:	89 14 24             	mov    %edx,(%esp)
80102193:	e8 0e e0 ff ff       	call   801001a6 <bread>
80102198:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010219b:	8b 45 10             	mov    0x10(%ebp),%eax
8010219e:	89 c2                	mov    %eax,%edx
801021a0:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801021a6:	b8 00 02 00 00       	mov    $0x200,%eax
801021ab:	89 c1                	mov    %eax,%ecx
801021ad:	29 d1                	sub    %edx,%ecx
801021af:	89 ca                	mov    %ecx,%edx
801021b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021b4:	8b 4d 14             	mov    0x14(%ebp),%ecx
801021b7:	89 cb                	mov    %ecx,%ebx
801021b9:	29 c3                	sub    %eax,%ebx
801021bb:	89 d8                	mov    %ebx,%eax
801021bd:	39 c2                	cmp    %eax,%edx
801021bf:	0f 46 c2             	cmovbe %edx,%eax
801021c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801021c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021c8:	8d 50 18             	lea    0x18(%eax),%edx
801021cb:	8b 45 10             	mov    0x10(%ebp),%eax
801021ce:	25 ff 01 00 00       	and    $0x1ff,%eax
801021d3:	01 c2                	add    %eax,%edx
801021d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021d8:	89 44 24 08          	mov    %eax,0x8(%esp)
801021dc:	89 54 24 04          	mov    %edx,0x4(%esp)
801021e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801021e3:	89 04 24             	mov    %eax,(%esp)
801021e6:	e8 52 32 00 00       	call   8010543d <memmove>
    brelse(bp);
801021eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021ee:	89 04 24             	mov    %eax,(%esp)
801021f1:	e8 21 e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801021f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021f9:	01 45 f4             	add    %eax,-0xc(%ebp)
801021fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021ff:	01 45 10             	add    %eax,0x10(%ebp)
80102202:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102205:	01 45 0c             	add    %eax,0xc(%ebp)
80102208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010220b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010220e:	0f 82 5e ff ff ff    	jb     80102172 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102214:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102217:	83 c4 24             	add    $0x24,%esp
8010221a:	5b                   	pop    %ebx
8010221b:	5d                   	pop    %ebp
8010221c:	c3                   	ret    

8010221d <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010221d:	55                   	push   %ebp
8010221e:	89 e5                	mov    %esp,%ebp
80102220:	53                   	push   %ebx
80102221:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102224:	8b 45 08             	mov    0x8(%ebp),%eax
80102227:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010222b:	66 83 f8 03          	cmp    $0x3,%ax
8010222f:	75 60                	jne    80102291 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102231:	8b 45 08             	mov    0x8(%ebp),%eax
80102234:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102238:	66 85 c0             	test   %ax,%ax
8010223b:	78 20                	js     8010225d <writei+0x40>
8010223d:	8b 45 08             	mov    0x8(%ebp),%eax
80102240:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102244:	66 83 f8 09          	cmp    $0x9,%ax
80102248:	7f 13                	jg     8010225d <writei+0x40>
8010224a:	8b 45 08             	mov    0x8(%ebp),%eax
8010224d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102251:	98                   	cwtl   
80102252:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
80102259:	85 c0                	test   %eax,%eax
8010225b:	75 0a                	jne    80102267 <writei+0x4a>
      return -1;
8010225d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102262:	e9 46 01 00 00       	jmp    801023ad <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80102267:	8b 45 08             	mov    0x8(%ebp),%eax
8010226a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010226e:	98                   	cwtl   
8010226f:	8b 14 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%edx
80102276:	8b 45 14             	mov    0x14(%ebp),%eax
80102279:	89 44 24 08          	mov    %eax,0x8(%esp)
8010227d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102280:	89 44 24 04          	mov    %eax,0x4(%esp)
80102284:	8b 45 08             	mov    0x8(%ebp),%eax
80102287:	89 04 24             	mov    %eax,(%esp)
8010228a:	ff d2                	call   *%edx
8010228c:	e9 1c 01 00 00       	jmp    801023ad <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80102291:	8b 45 08             	mov    0x8(%ebp),%eax
80102294:	8b 40 18             	mov    0x18(%eax),%eax
80102297:	3b 45 10             	cmp    0x10(%ebp),%eax
8010229a:	72 0d                	jb     801022a9 <writei+0x8c>
8010229c:	8b 45 14             	mov    0x14(%ebp),%eax
8010229f:	8b 55 10             	mov    0x10(%ebp),%edx
801022a2:	01 d0                	add    %edx,%eax
801022a4:	3b 45 10             	cmp    0x10(%ebp),%eax
801022a7:	73 0a                	jae    801022b3 <writei+0x96>
    return -1;
801022a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022ae:	e9 fa 00 00 00       	jmp    801023ad <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
801022b3:	8b 45 14             	mov    0x14(%ebp),%eax
801022b6:	8b 55 10             	mov    0x10(%ebp),%edx
801022b9:	01 d0                	add    %edx,%eax
801022bb:	3d 00 18 01 00       	cmp    $0x11800,%eax
801022c0:	76 0a                	jbe    801022cc <writei+0xaf>
    return -1;
801022c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c7:	e9 e1 00 00 00       	jmp    801023ad <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022d3:	e9 a1 00 00 00       	jmp    80102379 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801022d8:	8b 45 10             	mov    0x10(%ebp),%eax
801022db:	c1 e8 09             	shr    $0x9,%eax
801022de:	89 44 24 04          	mov    %eax,0x4(%esp)
801022e2:	8b 45 08             	mov    0x8(%ebp),%eax
801022e5:	89 04 24             	mov    %eax,(%esp)
801022e8:	e8 71 fb ff ff       	call   80101e5e <bmap>
801022ed:	8b 55 08             	mov    0x8(%ebp),%edx
801022f0:	8b 12                	mov    (%edx),%edx
801022f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801022f6:	89 14 24             	mov    %edx,(%esp)
801022f9:	e8 a8 de ff ff       	call   801001a6 <bread>
801022fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102301:	8b 45 10             	mov    0x10(%ebp),%eax
80102304:	89 c2                	mov    %eax,%edx
80102306:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010230c:	b8 00 02 00 00       	mov    $0x200,%eax
80102311:	89 c1                	mov    %eax,%ecx
80102313:	29 d1                	sub    %edx,%ecx
80102315:	89 ca                	mov    %ecx,%edx
80102317:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231a:	8b 4d 14             	mov    0x14(%ebp),%ecx
8010231d:	89 cb                	mov    %ecx,%ebx
8010231f:	29 c3                	sub    %eax,%ebx
80102321:	89 d8                	mov    %ebx,%eax
80102323:	39 c2                	cmp    %eax,%edx
80102325:	0f 46 c2             	cmovbe %edx,%eax
80102328:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010232b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010232e:	8d 50 18             	lea    0x18(%eax),%edx
80102331:	8b 45 10             	mov    0x10(%ebp),%eax
80102334:	25 ff 01 00 00       	and    $0x1ff,%eax
80102339:	01 c2                	add    %eax,%edx
8010233b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010233e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102342:	8b 45 0c             	mov    0xc(%ebp),%eax
80102345:	89 44 24 04          	mov    %eax,0x4(%esp)
80102349:	89 14 24             	mov    %edx,(%esp)
8010234c:	e8 ec 30 00 00       	call   8010543d <memmove>
    log_write(bp);
80102351:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102354:	89 04 24             	mov    %eax,(%esp)
80102357:	e8 b6 12 00 00       	call   80103612 <log_write>
    brelse(bp);
8010235c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010235f:	89 04 24             	mov    %eax,(%esp)
80102362:	e8 b0 de ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102367:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010236a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010236d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102370:	01 45 10             	add    %eax,0x10(%ebp)
80102373:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102376:	01 45 0c             	add    %eax,0xc(%ebp)
80102379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010237f:	0f 82 53 ff ff ff    	jb     801022d8 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102385:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102389:	74 1f                	je     801023aa <writei+0x18d>
8010238b:	8b 45 08             	mov    0x8(%ebp),%eax
8010238e:	8b 40 18             	mov    0x18(%eax),%eax
80102391:	3b 45 10             	cmp    0x10(%ebp),%eax
80102394:	73 14                	jae    801023aa <writei+0x18d>
    ip->size = off;
80102396:	8b 45 08             	mov    0x8(%ebp),%eax
80102399:	8b 55 10             	mov    0x10(%ebp),%edx
8010239c:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010239f:	8b 45 08             	mov    0x8(%ebp),%eax
801023a2:	89 04 24             	mov    %eax,(%esp)
801023a5:	e8 56 f6 ff ff       	call   80101a00 <iupdate>
  }
  return n;
801023aa:	8b 45 14             	mov    0x14(%ebp),%eax
}
801023ad:	83 c4 24             	add    $0x24,%esp
801023b0:	5b                   	pop    %ebx
801023b1:	5d                   	pop    %ebp
801023b2:	c3                   	ret    

801023b3 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801023b3:	55                   	push   %ebp
801023b4:	89 e5                	mov    %esp,%ebp
801023b6:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801023b9:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801023c0:	00 
801023c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801023c8:	8b 45 08             	mov    0x8(%ebp),%eax
801023cb:	89 04 24             	mov    %eax,(%esp)
801023ce:	e8 0e 31 00 00       	call   801054e1 <strncmp>
}
801023d3:	c9                   	leave  
801023d4:	c3                   	ret    

801023d5 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801023d5:	55                   	push   %ebp
801023d6:	89 e5                	mov    %esp,%ebp
801023d8:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801023db:	8b 45 08             	mov    0x8(%ebp),%eax
801023de:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023e2:	66 83 f8 01          	cmp    $0x1,%ax
801023e6:	74 0c                	je     801023f4 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801023e8:	c7 04 24 95 88 10 80 	movl   $0x80108895,(%esp)
801023ef:	e8 49 e1 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801023f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023fb:	e9 87 00 00 00       	jmp    80102487 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102400:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102407:	00 
80102408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010240b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010240f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102412:	89 44 24 04          	mov    %eax,0x4(%esp)
80102416:	8b 45 08             	mov    0x8(%ebp),%eax
80102419:	89 04 24             	mov    %eax,(%esp)
8010241c:	e8 91 fc ff ff       	call   801020b2 <readi>
80102421:	83 f8 10             	cmp    $0x10,%eax
80102424:	74 0c                	je     80102432 <dirlookup+0x5d>
      panic("dirlink read");
80102426:	c7 04 24 a7 88 10 80 	movl   $0x801088a7,(%esp)
8010242d:	e8 0b e1 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102432:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102436:	66 85 c0             	test   %ax,%ax
80102439:	74 47                	je     80102482 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
8010243b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010243e:	83 c0 02             	add    $0x2,%eax
80102441:	89 44 24 04          	mov    %eax,0x4(%esp)
80102445:	8b 45 0c             	mov    0xc(%ebp),%eax
80102448:	89 04 24             	mov    %eax,(%esp)
8010244b:	e8 63 ff ff ff       	call   801023b3 <namecmp>
80102450:	85 c0                	test   %eax,%eax
80102452:	75 2f                	jne    80102483 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102454:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102458:	74 08                	je     80102462 <dirlookup+0x8d>
        *poff = off;
8010245a:	8b 45 10             	mov    0x10(%ebp),%eax
8010245d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102460:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102462:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102466:	0f b7 c0             	movzwl %ax,%eax
80102469:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010246c:	8b 45 08             	mov    0x8(%ebp),%eax
8010246f:	8b 00                	mov    (%eax),%eax
80102471:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102474:	89 54 24 04          	mov    %edx,0x4(%esp)
80102478:	89 04 24             	mov    %eax,(%esp)
8010247b:	e8 38 f6 ff ff       	call   80101ab8 <iget>
80102480:	eb 19                	jmp    8010249b <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102482:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102483:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102487:	8b 45 08             	mov    0x8(%ebp),%eax
8010248a:	8b 40 18             	mov    0x18(%eax),%eax
8010248d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102490:	0f 87 6a ff ff ff    	ja     80102400 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102496:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010249b:	c9                   	leave  
8010249c:	c3                   	ret    

8010249d <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010249d:	55                   	push   %ebp
8010249e:	89 e5                	mov    %esp,%ebp
801024a0:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801024a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801024aa:	00 
801024ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801024ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801024b2:	8b 45 08             	mov    0x8(%ebp),%eax
801024b5:	89 04 24             	mov    %eax,(%esp)
801024b8:	e8 18 ff ff ff       	call   801023d5 <dirlookup>
801024bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024c4:	74 15                	je     801024db <dirlink+0x3e>
    iput(ip);
801024c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024c9:	89 04 24             	mov    %eax,(%esp)
801024cc:	e8 9e f8 ff ff       	call   80101d6f <iput>
    return -1;
801024d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024d6:	e9 b8 00 00 00       	jmp    80102593 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801024e2:	eb 44                	jmp    80102528 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024e7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801024ee:	00 
801024ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801024f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801024fa:	8b 45 08             	mov    0x8(%ebp),%eax
801024fd:	89 04 24             	mov    %eax,(%esp)
80102500:	e8 ad fb ff ff       	call   801020b2 <readi>
80102505:	83 f8 10             	cmp    $0x10,%eax
80102508:	74 0c                	je     80102516 <dirlink+0x79>
      panic("dirlink read");
8010250a:	c7 04 24 a7 88 10 80 	movl   $0x801088a7,(%esp)
80102511:	e8 27 e0 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102516:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010251a:	66 85 c0             	test   %ax,%ax
8010251d:	74 18                	je     80102537 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010251f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102522:	83 c0 10             	add    $0x10,%eax
80102525:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102528:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010252b:	8b 45 08             	mov    0x8(%ebp),%eax
8010252e:	8b 40 18             	mov    0x18(%eax),%eax
80102531:	39 c2                	cmp    %eax,%edx
80102533:	72 af                	jb     801024e4 <dirlink+0x47>
80102535:	eb 01                	jmp    80102538 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102537:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102538:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010253f:	00 
80102540:	8b 45 0c             	mov    0xc(%ebp),%eax
80102543:	89 44 24 04          	mov    %eax,0x4(%esp)
80102547:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010254a:	83 c0 02             	add    $0x2,%eax
8010254d:	89 04 24             	mov    %eax,(%esp)
80102550:	e8 e4 2f 00 00       	call   80105539 <strncpy>
  de.inum = inum;
80102555:	8b 45 10             	mov    0x10(%ebp),%eax
80102558:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010255c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010255f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102566:	00 
80102567:	89 44 24 08          	mov    %eax,0x8(%esp)
8010256b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010256e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102572:	8b 45 08             	mov    0x8(%ebp),%eax
80102575:	89 04 24             	mov    %eax,(%esp)
80102578:	e8 a0 fc ff ff       	call   8010221d <writei>
8010257d:	83 f8 10             	cmp    $0x10,%eax
80102580:	74 0c                	je     8010258e <dirlink+0xf1>
    panic("dirlink");
80102582:	c7 04 24 b4 88 10 80 	movl   $0x801088b4,(%esp)
80102589:	e8 af df ff ff       	call   8010053d <panic>
  
  return 0;
8010258e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102593:	c9                   	leave  
80102594:	c3                   	ret    

80102595 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102595:	55                   	push   %ebp
80102596:	89 e5                	mov    %esp,%ebp
80102598:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010259b:	eb 04                	jmp    801025a1 <skipelem+0xc>
    path++;
8010259d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801025a1:	8b 45 08             	mov    0x8(%ebp),%eax
801025a4:	0f b6 00             	movzbl (%eax),%eax
801025a7:	3c 2f                	cmp    $0x2f,%al
801025a9:	74 f2                	je     8010259d <skipelem+0x8>
    path++;
  if(*path == 0)
801025ab:	8b 45 08             	mov    0x8(%ebp),%eax
801025ae:	0f b6 00             	movzbl (%eax),%eax
801025b1:	84 c0                	test   %al,%al
801025b3:	75 0a                	jne    801025bf <skipelem+0x2a>
    return 0;
801025b5:	b8 00 00 00 00       	mov    $0x0,%eax
801025ba:	e9 86 00 00 00       	jmp    80102645 <skipelem+0xb0>
  s = path;
801025bf:	8b 45 08             	mov    0x8(%ebp),%eax
801025c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801025c5:	eb 04                	jmp    801025cb <skipelem+0x36>
    path++;
801025c7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801025cb:	8b 45 08             	mov    0x8(%ebp),%eax
801025ce:	0f b6 00             	movzbl (%eax),%eax
801025d1:	3c 2f                	cmp    $0x2f,%al
801025d3:	74 0a                	je     801025df <skipelem+0x4a>
801025d5:	8b 45 08             	mov    0x8(%ebp),%eax
801025d8:	0f b6 00             	movzbl (%eax),%eax
801025db:	84 c0                	test   %al,%al
801025dd:	75 e8                	jne    801025c7 <skipelem+0x32>
    path++;
  len = path - s;
801025df:	8b 55 08             	mov    0x8(%ebp),%edx
801025e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e5:	89 d1                	mov    %edx,%ecx
801025e7:	29 c1                	sub    %eax,%ecx
801025e9:	89 c8                	mov    %ecx,%eax
801025eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801025ee:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801025f2:	7e 1c                	jle    80102610 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801025f4:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801025fb:	00 
801025fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80102603:	8b 45 0c             	mov    0xc(%ebp),%eax
80102606:	89 04 24             	mov    %eax,(%esp)
80102609:	e8 2f 2e 00 00       	call   8010543d <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010260e:	eb 28                	jmp    80102638 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102613:	89 44 24 08          	mov    %eax,0x8(%esp)
80102617:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010261a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010261e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102621:	89 04 24             	mov    %eax,(%esp)
80102624:	e8 14 2e 00 00       	call   8010543d <memmove>
    name[len] = 0;
80102629:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010262c:	03 45 0c             	add    0xc(%ebp),%eax
8010262f:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102632:	eb 04                	jmp    80102638 <skipelem+0xa3>
    path++;
80102634:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102638:	8b 45 08             	mov    0x8(%ebp),%eax
8010263b:	0f b6 00             	movzbl (%eax),%eax
8010263e:	3c 2f                	cmp    $0x2f,%al
80102640:	74 f2                	je     80102634 <skipelem+0x9f>
    path++;
  return path;
80102642:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102645:	c9                   	leave  
80102646:	c3                   	ret    

80102647 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102647:	55                   	push   %ebp
80102648:	89 e5                	mov    %esp,%ebp
8010264a:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010264d:	8b 45 08             	mov    0x8(%ebp),%eax
80102650:	0f b6 00             	movzbl (%eax),%eax
80102653:	3c 2f                	cmp    $0x2f,%al
80102655:	75 1c                	jne    80102673 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102657:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010265e:	00 
8010265f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102666:	e8 4d f4 ff ff       	call   80101ab8 <iget>
8010266b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010266e:	e9 af 00 00 00       	jmp    80102722 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102673:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102679:	8b 40 68             	mov    0x68(%eax),%eax
8010267c:	89 04 24             	mov    %eax,(%esp)
8010267f:	e8 06 f5 ff ff       	call   80101b8a <idup>
80102684:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102687:	e9 96 00 00 00       	jmp    80102722 <namex+0xdb>
    ilock(ip);
8010268c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010268f:	89 04 24             	mov    %eax,(%esp)
80102692:	e8 25 f5 ff ff       	call   80101bbc <ilock>
    if(ip->type != T_DIR){
80102697:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010269a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010269e:	66 83 f8 01          	cmp    $0x1,%ax
801026a2:	74 15                	je     801026b9 <namex+0x72>
      iunlockput(ip);
801026a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a7:	89 04 24             	mov    %eax,(%esp)
801026aa:	e8 91 f7 ff ff       	call   80101e40 <iunlockput>
      return 0;
801026af:	b8 00 00 00 00       	mov    $0x0,%eax
801026b4:	e9 a3 00 00 00       	jmp    8010275c <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801026b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026bd:	74 1d                	je     801026dc <namex+0x95>
801026bf:	8b 45 08             	mov    0x8(%ebp),%eax
801026c2:	0f b6 00             	movzbl (%eax),%eax
801026c5:	84 c0                	test   %al,%al
801026c7:	75 13                	jne    801026dc <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801026c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026cc:	89 04 24             	mov    %eax,(%esp)
801026cf:	e8 36 f6 ff ff       	call   80101d0a <iunlock>
      return ip;
801026d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d7:	e9 80 00 00 00       	jmp    8010275c <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801026dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801026e3:	00 
801026e4:	8b 45 10             	mov    0x10(%ebp),%eax
801026e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801026eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ee:	89 04 24             	mov    %eax,(%esp)
801026f1:	e8 df fc ff ff       	call   801023d5 <dirlookup>
801026f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801026f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801026fd:	75 12                	jne    80102711 <namex+0xca>
      iunlockput(ip);
801026ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102702:	89 04 24             	mov    %eax,(%esp)
80102705:	e8 36 f7 ff ff       	call   80101e40 <iunlockput>
      return 0;
8010270a:	b8 00 00 00 00       	mov    $0x0,%eax
8010270f:	eb 4b                	jmp    8010275c <namex+0x115>
    }
    iunlockput(ip);
80102711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102714:	89 04 24             	mov    %eax,(%esp)
80102717:	e8 24 f7 ff ff       	call   80101e40 <iunlockput>
    ip = next;
8010271c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010271f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102722:	8b 45 10             	mov    0x10(%ebp),%eax
80102725:	89 44 24 04          	mov    %eax,0x4(%esp)
80102729:	8b 45 08             	mov    0x8(%ebp),%eax
8010272c:	89 04 24             	mov    %eax,(%esp)
8010272f:	e8 61 fe ff ff       	call   80102595 <skipelem>
80102734:	89 45 08             	mov    %eax,0x8(%ebp)
80102737:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010273b:	0f 85 4b ff ff ff    	jne    8010268c <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102741:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102745:	74 12                	je     80102759 <namex+0x112>
    iput(ip);
80102747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010274a:	89 04 24             	mov    %eax,(%esp)
8010274d:	e8 1d f6 ff ff       	call   80101d6f <iput>
    return 0;
80102752:	b8 00 00 00 00       	mov    $0x0,%eax
80102757:	eb 03                	jmp    8010275c <namex+0x115>
  }
  return ip;
80102759:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010275c:	c9                   	leave  
8010275d:	c3                   	ret    

8010275e <namei>:

struct inode*
namei(char *path)
{
8010275e:	55                   	push   %ebp
8010275f:	89 e5                	mov    %esp,%ebp
80102761:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102764:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102767:	89 44 24 08          	mov    %eax,0x8(%esp)
8010276b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102772:	00 
80102773:	8b 45 08             	mov    0x8(%ebp),%eax
80102776:	89 04 24             	mov    %eax,(%esp)
80102779:	e8 c9 fe ff ff       	call   80102647 <namex>
}
8010277e:	c9                   	leave  
8010277f:	c3                   	ret    

80102780 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102780:	55                   	push   %ebp
80102781:	89 e5                	mov    %esp,%ebp
80102783:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102786:	8b 45 0c             	mov    0xc(%ebp),%eax
80102789:	89 44 24 08          	mov    %eax,0x8(%esp)
8010278d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102794:	00 
80102795:	8b 45 08             	mov    0x8(%ebp),%eax
80102798:	89 04 24             	mov    %eax,(%esp)
8010279b:	e8 a7 fe ff ff       	call   80102647 <namex>
}
801027a0:	c9                   	leave  
801027a1:	c3                   	ret    
	...

801027a4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801027a4:	55                   	push   %ebp
801027a5:	89 e5                	mov    %esp,%ebp
801027a7:	53                   	push   %ebx
801027a8:	83 ec 14             	sub    $0x14,%esp
801027ab:	8b 45 08             	mov    0x8(%ebp),%eax
801027ae:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801027b2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801027b6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801027ba:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801027be:	ec                   	in     (%dx),%al
801027bf:	89 c3                	mov    %eax,%ebx
801027c1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801027c4:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801027c8:	83 c4 14             	add    $0x14,%esp
801027cb:	5b                   	pop    %ebx
801027cc:	5d                   	pop    %ebp
801027cd:	c3                   	ret    

801027ce <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801027ce:	55                   	push   %ebp
801027cf:	89 e5                	mov    %esp,%ebp
801027d1:	57                   	push   %edi
801027d2:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801027d3:	8b 55 08             	mov    0x8(%ebp),%edx
801027d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027d9:	8b 45 10             	mov    0x10(%ebp),%eax
801027dc:	89 cb                	mov    %ecx,%ebx
801027de:	89 df                	mov    %ebx,%edi
801027e0:	89 c1                	mov    %eax,%ecx
801027e2:	fc                   	cld    
801027e3:	f3 6d                	rep insl (%dx),%es:(%edi)
801027e5:	89 c8                	mov    %ecx,%eax
801027e7:	89 fb                	mov    %edi,%ebx
801027e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027ec:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801027ef:	5b                   	pop    %ebx
801027f0:	5f                   	pop    %edi
801027f1:	5d                   	pop    %ebp
801027f2:	c3                   	ret    

801027f3 <outb>:

static inline void
outb(ushort port, uchar data)
{
801027f3:	55                   	push   %ebp
801027f4:	89 e5                	mov    %esp,%ebp
801027f6:	83 ec 08             	sub    $0x8,%esp
801027f9:	8b 55 08             	mov    0x8(%ebp),%edx
801027fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801027ff:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102803:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102806:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010280a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010280e:	ee                   	out    %al,(%dx)
}
8010280f:	c9                   	leave  
80102810:	c3                   	ret    

80102811 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102811:	55                   	push   %ebp
80102812:	89 e5                	mov    %esp,%ebp
80102814:	56                   	push   %esi
80102815:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102816:	8b 55 08             	mov    0x8(%ebp),%edx
80102819:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010281c:	8b 45 10             	mov    0x10(%ebp),%eax
8010281f:	89 cb                	mov    %ecx,%ebx
80102821:	89 de                	mov    %ebx,%esi
80102823:	89 c1                	mov    %eax,%ecx
80102825:	fc                   	cld    
80102826:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102828:	89 c8                	mov    %ecx,%eax
8010282a:	89 f3                	mov    %esi,%ebx
8010282c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010282f:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102832:	5b                   	pop    %ebx
80102833:	5e                   	pop    %esi
80102834:	5d                   	pop    %ebp
80102835:	c3                   	ret    

80102836 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102836:	55                   	push   %ebp
80102837:	89 e5                	mov    %esp,%ebp
80102839:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
8010283c:	90                   	nop
8010283d:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102844:	e8 5b ff ff ff       	call   801027a4 <inb>
80102849:	0f b6 c0             	movzbl %al,%eax
8010284c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010284f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102852:	25 c0 00 00 00       	and    $0xc0,%eax
80102857:	83 f8 40             	cmp    $0x40,%eax
8010285a:	75 e1                	jne    8010283d <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010285c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102860:	74 11                	je     80102873 <idewait+0x3d>
80102862:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102865:	83 e0 21             	and    $0x21,%eax
80102868:	85 c0                	test   %eax,%eax
8010286a:	74 07                	je     80102873 <idewait+0x3d>
    return -1;
8010286c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102871:	eb 05                	jmp    80102878 <idewait+0x42>
  return 0;
80102873:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102878:	c9                   	leave  
80102879:	c3                   	ret    

8010287a <ideinit>:

void
ideinit(void)
{
8010287a:	55                   	push   %ebp
8010287b:	89 e5                	mov    %esp,%ebp
8010287d:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102880:	c7 44 24 04 bc 88 10 	movl   $0x801088bc,0x4(%esp)
80102887:	80 
80102888:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010288f:	e8 66 28 00 00       	call   801050fa <initlock>
  picenable(IRQ_IDE);
80102894:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010289b:	e8 75 15 00 00       	call   80103e15 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
801028a0:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
801028a5:	83 e8 01             	sub    $0x1,%eax
801028a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801028ac:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801028b3:	e8 12 04 00 00       	call   80102cca <ioapicenable>
  idewait(0);
801028b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028bf:	e8 72 ff ff ff       	call   80102836 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801028c4:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801028cb:	00 
801028cc:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028d3:	e8 1b ff ff ff       	call   801027f3 <outb>
  for(i=0; i<1000; i++){
801028d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028df:	eb 20                	jmp    80102901 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801028e1:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028e8:	e8 b7 fe ff ff       	call   801027a4 <inb>
801028ed:	84 c0                	test   %al,%al
801028ef:	74 0c                	je     801028fd <ideinit+0x83>
      havedisk1 = 1;
801028f1:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801028f8:	00 00 00 
      break;
801028fb:	eb 0d                	jmp    8010290a <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801028fd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102901:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102908:	7e d7                	jle    801028e1 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010290a:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102911:	00 
80102912:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102919:	e8 d5 fe ff ff       	call   801027f3 <outb>
}
8010291e:	c9                   	leave  
8010291f:	c3                   	ret    

80102920 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102920:	55                   	push   %ebp
80102921:	89 e5                	mov    %esp,%ebp
80102923:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102926:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010292a:	75 0c                	jne    80102938 <idestart+0x18>
    panic("idestart");
8010292c:	c7 04 24 c0 88 10 80 	movl   $0x801088c0,(%esp)
80102933:	e8 05 dc ff ff       	call   8010053d <panic>

  idewait(0);
80102938:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010293f:	e8 f2 fe ff ff       	call   80102836 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102944:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010294b:	00 
8010294c:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102953:	e8 9b fe ff ff       	call   801027f3 <outb>
  outb(0x1f2, 1);  // number of sectors
80102958:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010295f:	00 
80102960:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102967:	e8 87 fe ff ff       	call   801027f3 <outb>
  outb(0x1f3, b->sector & 0xff);
8010296c:	8b 45 08             	mov    0x8(%ebp),%eax
8010296f:	8b 40 08             	mov    0x8(%eax),%eax
80102972:	0f b6 c0             	movzbl %al,%eax
80102975:	89 44 24 04          	mov    %eax,0x4(%esp)
80102979:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102980:	e8 6e fe ff ff       	call   801027f3 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102985:	8b 45 08             	mov    0x8(%ebp),%eax
80102988:	8b 40 08             	mov    0x8(%eax),%eax
8010298b:	c1 e8 08             	shr    $0x8,%eax
8010298e:	0f b6 c0             	movzbl %al,%eax
80102991:	89 44 24 04          	mov    %eax,0x4(%esp)
80102995:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
8010299c:	e8 52 fe ff ff       	call   801027f3 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
801029a1:	8b 45 08             	mov    0x8(%ebp),%eax
801029a4:	8b 40 08             	mov    0x8(%eax),%eax
801029a7:	c1 e8 10             	shr    $0x10,%eax
801029aa:	0f b6 c0             	movzbl %al,%eax
801029ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801029b1:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801029b8:	e8 36 fe ff ff       	call   801027f3 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801029bd:	8b 45 08             	mov    0x8(%ebp),%eax
801029c0:	8b 40 04             	mov    0x4(%eax),%eax
801029c3:	83 e0 01             	and    $0x1,%eax
801029c6:	89 c2                	mov    %eax,%edx
801029c8:	c1 e2 04             	shl    $0x4,%edx
801029cb:	8b 45 08             	mov    0x8(%ebp),%eax
801029ce:	8b 40 08             	mov    0x8(%eax),%eax
801029d1:	c1 e8 18             	shr    $0x18,%eax
801029d4:	83 e0 0f             	and    $0xf,%eax
801029d7:	09 d0                	or     %edx,%eax
801029d9:	83 c8 e0             	or     $0xffffffe0,%eax
801029dc:	0f b6 c0             	movzbl %al,%eax
801029df:	89 44 24 04          	mov    %eax,0x4(%esp)
801029e3:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801029ea:	e8 04 fe ff ff       	call   801027f3 <outb>
  if(b->flags & B_DIRTY){
801029ef:	8b 45 08             	mov    0x8(%ebp),%eax
801029f2:	8b 00                	mov    (%eax),%eax
801029f4:	83 e0 04             	and    $0x4,%eax
801029f7:	85 c0                	test   %eax,%eax
801029f9:	74 34                	je     80102a2f <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801029fb:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102a02:	00 
80102a03:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a0a:	e8 e4 fd ff ff       	call   801027f3 <outb>
    outsl(0x1f0, b->data, 512/4);
80102a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a12:	83 c0 18             	add    $0x18,%eax
80102a15:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a1c:	00 
80102a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a21:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a28:	e8 e4 fd ff ff       	call   80102811 <outsl>
80102a2d:	eb 14                	jmp    80102a43 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102a2f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102a36:	00 
80102a37:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a3e:	e8 b0 fd ff ff       	call   801027f3 <outb>
  }
}
80102a43:	c9                   	leave  
80102a44:	c3                   	ret    

80102a45 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a45:	55                   	push   %ebp
80102a46:	89 e5                	mov    %esp,%ebp
80102a48:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a4b:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a52:	e8 c4 26 00 00       	call   8010511b <acquire>
  if((b = idequeue) == 0){
80102a57:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a63:	75 11                	jne    80102a76 <ideintr+0x31>
    release(&idelock);
80102a65:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a6c:	e8 0c 27 00 00       	call   8010517d <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102a71:	e9 90 00 00 00       	jmp    80102b06 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a79:	8b 40 14             	mov    0x14(%eax),%eax
80102a7c:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a84:	8b 00                	mov    (%eax),%eax
80102a86:	83 e0 04             	and    $0x4,%eax
80102a89:	85 c0                	test   %eax,%eax
80102a8b:	75 2e                	jne    80102abb <ideintr+0x76>
80102a8d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a94:	e8 9d fd ff ff       	call   80102836 <idewait>
80102a99:	85 c0                	test   %eax,%eax
80102a9b:	78 1e                	js     80102abb <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa0:	83 c0 18             	add    $0x18,%eax
80102aa3:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102aaa:	00 
80102aab:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aaf:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102ab6:	e8 13 fd ff ff       	call   801027ce <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102abe:	8b 00                	mov    (%eax),%eax
80102ac0:	89 c2                	mov    %eax,%edx
80102ac2:	83 ca 02             	or     $0x2,%edx
80102ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac8:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102acd:	8b 00                	mov    (%eax),%eax
80102acf:	89 c2                	mov    %eax,%edx
80102ad1:	83 e2 fb             	and    $0xfffffffb,%edx
80102ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad7:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102adc:	89 04 24             	mov    %eax,(%esp)
80102adf:	e8 2d 24 00 00       	call   80104f11 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102ae4:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102ae9:	85 c0                	test   %eax,%eax
80102aeb:	74 0d                	je     80102afa <ideintr+0xb5>
    idestart(idequeue);
80102aed:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102af2:	89 04 24             	mov    %eax,(%esp)
80102af5:	e8 26 fe ff ff       	call   80102920 <idestart>

  release(&idelock);
80102afa:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b01:	e8 77 26 00 00       	call   8010517d <release>
}
80102b06:	c9                   	leave  
80102b07:	c3                   	ret    

80102b08 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b08:	55                   	push   %ebp
80102b09:	89 e5                	mov    %esp,%ebp
80102b0b:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102b0e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b11:	8b 00                	mov    (%eax),%eax
80102b13:	83 e0 01             	and    $0x1,%eax
80102b16:	85 c0                	test   %eax,%eax
80102b18:	75 0c                	jne    80102b26 <iderw+0x1e>
    panic("iderw: buf not busy");
80102b1a:	c7 04 24 c9 88 10 80 	movl   $0x801088c9,(%esp)
80102b21:	e8 17 da ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b26:	8b 45 08             	mov    0x8(%ebp),%eax
80102b29:	8b 00                	mov    (%eax),%eax
80102b2b:	83 e0 06             	and    $0x6,%eax
80102b2e:	83 f8 02             	cmp    $0x2,%eax
80102b31:	75 0c                	jne    80102b3f <iderw+0x37>
    panic("iderw: nothing to do");
80102b33:	c7 04 24 dd 88 10 80 	movl   $0x801088dd,(%esp)
80102b3a:	e8 fe d9 ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102b3f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b42:	8b 40 04             	mov    0x4(%eax),%eax
80102b45:	85 c0                	test   %eax,%eax
80102b47:	74 15                	je     80102b5e <iderw+0x56>
80102b49:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102b4e:	85 c0                	test   %eax,%eax
80102b50:	75 0c                	jne    80102b5e <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102b52:	c7 04 24 f2 88 10 80 	movl   $0x801088f2,(%esp)
80102b59:	e8 df d9 ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102b5e:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b65:	e8 b1 25 00 00       	call   8010511b <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b6d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102b74:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102b7b:	eb 0b                	jmp    80102b88 <iderw+0x80>
80102b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b80:	8b 00                	mov    (%eax),%eax
80102b82:	83 c0 14             	add    $0x14,%eax
80102b85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8b:	8b 00                	mov    (%eax),%eax
80102b8d:	85 c0                	test   %eax,%eax
80102b8f:	75 ec                	jne    80102b7d <iderw+0x75>
    ;
  *pp = b;
80102b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b94:	8b 55 08             	mov    0x8(%ebp),%edx
80102b97:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102b99:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102b9e:	3b 45 08             	cmp    0x8(%ebp),%eax
80102ba1:	75 22                	jne    80102bc5 <iderw+0xbd>
    idestart(b);
80102ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba6:	89 04 24             	mov    %eax,(%esp)
80102ba9:	e8 72 fd ff ff       	call   80102920 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bae:	eb 15                	jmp    80102bc5 <iderw+0xbd>
    sleep(b, &idelock);
80102bb0:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102bb7:	80 
80102bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbb:	89 04 24             	mov    %eax,(%esp)
80102bbe:	e8 72 22 00 00       	call   80104e35 <sleep>
80102bc3:	eb 01                	jmp    80102bc6 <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bc5:	90                   	nop
80102bc6:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc9:	8b 00                	mov    (%eax),%eax
80102bcb:	83 e0 06             	and    $0x6,%eax
80102bce:	83 f8 02             	cmp    $0x2,%eax
80102bd1:	75 dd                	jne    80102bb0 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102bd3:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102bda:	e8 9e 25 00 00       	call   8010517d <release>
}
80102bdf:	c9                   	leave  
80102be0:	c3                   	ret    
80102be1:	00 00                	add    %al,(%eax)
	...

80102be4 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102be4:	55                   	push   %ebp
80102be5:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102be7:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bec:	8b 55 08             	mov    0x8(%ebp),%edx
80102bef:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102bf1:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102bf6:	8b 40 10             	mov    0x10(%eax),%eax
}
80102bf9:	5d                   	pop    %ebp
80102bfa:	c3                   	ret    

80102bfb <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bfb:	55                   	push   %ebp
80102bfc:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bfe:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102c03:	8b 55 08             	mov    0x8(%ebp),%edx
80102c06:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c08:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102c0d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c10:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c13:	5d                   	pop    %ebp
80102c14:	c3                   	ret    

80102c15 <ioapicinit>:

void
ioapicinit(void)
{
80102c15:	55                   	push   %ebp
80102c16:	89 e5                	mov    %esp,%ebp
80102c18:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102c1b:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102c20:	85 c0                	test   %eax,%eax
80102c22:	0f 84 9f 00 00 00    	je     80102cc7 <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c28:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
80102c2f:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c32:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c39:	e8 a6 ff ff ff       	call   80102be4 <ioapicread>
80102c3e:	c1 e8 10             	shr    $0x10,%eax
80102c41:	25 ff 00 00 00       	and    $0xff,%eax
80102c46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c50:	e8 8f ff ff ff       	call   80102be4 <ioapicread>
80102c55:	c1 e8 18             	shr    $0x18,%eax
80102c58:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c5b:	0f b6 05 20 f9 10 80 	movzbl 0x8010f920,%eax
80102c62:	0f b6 c0             	movzbl %al,%eax
80102c65:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c68:	74 0c                	je     80102c76 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c6a:	c7 04 24 10 89 10 80 	movl   $0x80108910,(%esp)
80102c71:	e8 2b d7 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c7d:	eb 3e                	jmp    80102cbd <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c82:	83 c0 20             	add    $0x20,%eax
80102c85:	0d 00 00 01 00       	or     $0x10000,%eax
80102c8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102c8d:	83 c2 08             	add    $0x8,%edx
80102c90:	01 d2                	add    %edx,%edx
80102c92:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c96:	89 14 24             	mov    %edx,(%esp)
80102c99:	e8 5d ff ff ff       	call   80102bfb <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca1:	83 c0 08             	add    $0x8,%eax
80102ca4:	01 c0                	add    %eax,%eax
80102ca6:	83 c0 01             	add    $0x1,%eax
80102ca9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102cb0:	00 
80102cb1:	89 04 24             	mov    %eax,(%esp)
80102cb4:	e8 42 ff ff ff       	call   80102bfb <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102cb9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102cc3:	7e ba                	jle    80102c7f <ioapicinit+0x6a>
80102cc5:	eb 01                	jmp    80102cc8 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102cc7:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102cc8:	c9                   	leave  
80102cc9:	c3                   	ret    

80102cca <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102cca:	55                   	push   %ebp
80102ccb:	89 e5                	mov    %esp,%ebp
80102ccd:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102cd0:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102cd5:	85 c0                	test   %eax,%eax
80102cd7:	74 39                	je     80102d12 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cd9:	8b 45 08             	mov    0x8(%ebp),%eax
80102cdc:	83 c0 20             	add    $0x20,%eax
80102cdf:	8b 55 08             	mov    0x8(%ebp),%edx
80102ce2:	83 c2 08             	add    $0x8,%edx
80102ce5:	01 d2                	add    %edx,%edx
80102ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ceb:	89 14 24             	mov    %edx,(%esp)
80102cee:	e8 08 ff ff ff       	call   80102bfb <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cf6:	c1 e0 18             	shl    $0x18,%eax
80102cf9:	8b 55 08             	mov    0x8(%ebp),%edx
80102cfc:	83 c2 08             	add    $0x8,%edx
80102cff:	01 d2                	add    %edx,%edx
80102d01:	83 c2 01             	add    $0x1,%edx
80102d04:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d08:	89 14 24             	mov    %edx,(%esp)
80102d0b:	e8 eb fe ff ff       	call   80102bfb <ioapicwrite>
80102d10:	eb 01                	jmp    80102d13 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102d12:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102d13:	c9                   	leave  
80102d14:	c3                   	ret    
80102d15:	00 00                	add    %al,(%eax)
	...

80102d18 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102d18:	55                   	push   %ebp
80102d19:	89 e5                	mov    %esp,%ebp
80102d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d1e:	05 00 00 00 80       	add    $0x80000000,%eax
80102d23:	5d                   	pop    %ebp
80102d24:	c3                   	ret    

80102d25 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d25:	55                   	push   %ebp
80102d26:	89 e5                	mov    %esp,%ebp
80102d28:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102d2b:	c7 44 24 04 42 89 10 	movl   $0x80108942,0x4(%esp)
80102d32:	80 
80102d33:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102d3a:	e8 bb 23 00 00       	call   801050fa <initlock>
  kmem.use_lock = 0;
80102d3f:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
80102d46:	00 00 00 
  freerange(vstart, vend);
80102d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d50:	8b 45 08             	mov    0x8(%ebp),%eax
80102d53:	89 04 24             	mov    %eax,(%esp)
80102d56:	e8 26 00 00 00       	call   80102d81 <freerange>
}
80102d5b:	c9                   	leave  
80102d5c:	c3                   	ret    

80102d5d <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d5d:	55                   	push   %ebp
80102d5e:	89 e5                	mov    %esp,%ebp
80102d60:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d63:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d66:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80102d6d:	89 04 24             	mov    %eax,(%esp)
80102d70:	e8 0c 00 00 00       	call   80102d81 <freerange>
  kmem.use_lock = 1;
80102d75:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
80102d7c:	00 00 00 
}
80102d7f:	c9                   	leave  
80102d80:	c3                   	ret    

80102d81 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d81:	55                   	push   %ebp
80102d82:	89 e5                	mov    %esp,%ebp
80102d84:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d87:	8b 45 08             	mov    0x8(%ebp),%eax
80102d8a:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d97:	eb 12                	jmp    80102dab <freerange+0x2a>
    kfree(p);
80102d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d9c:	89 04 24             	mov    %eax,(%esp)
80102d9f:	e8 16 00 00 00       	call   80102dba <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102da4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dae:	05 00 10 00 00       	add    $0x1000,%eax
80102db3:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102db6:	76 e1                	jbe    80102d99 <freerange+0x18>
    kfree(p);
}
80102db8:	c9                   	leave  
80102db9:	c3                   	ret    

80102dba <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dba:	55                   	push   %ebp
80102dbb:	89 e5                	mov    %esp,%ebp
80102dbd:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80102dc3:	25 ff 0f 00 00       	and    $0xfff,%eax
80102dc8:	85 c0                	test   %eax,%eax
80102dca:	75 1b                	jne    80102de7 <kfree+0x2d>
80102dcc:	81 7d 08 1c 2a 11 80 	cmpl   $0x80112a1c,0x8(%ebp)
80102dd3:	72 12                	jb     80102de7 <kfree+0x2d>
80102dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd8:	89 04 24             	mov    %eax,(%esp)
80102ddb:	e8 38 ff ff ff       	call   80102d18 <v2p>
80102de0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102de5:	76 0c                	jbe    80102df3 <kfree+0x39>
    panic("kfree");
80102de7:	c7 04 24 47 89 10 80 	movl   $0x80108947,(%esp)
80102dee:	e8 4a d7 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102df3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102dfa:	00 
80102dfb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102e02:	00 
80102e03:	8b 45 08             	mov    0x8(%ebp),%eax
80102e06:	89 04 24             	mov    %eax,(%esp)
80102e09:	e8 5c 25 00 00       	call   8010536a <memset>

  if(kmem.use_lock)
80102e0e:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e13:	85 c0                	test   %eax,%eax
80102e15:	74 0c                	je     80102e23 <kfree+0x69>
    acquire(&kmem.lock);
80102e17:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e1e:	e8 f8 22 00 00       	call   8010511b <acquire>
  r = (struct run*)v;
80102e23:	8b 45 08             	mov    0x8(%ebp),%eax
80102e26:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e29:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e32:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e37:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e3c:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e41:	85 c0                	test   %eax,%eax
80102e43:	74 0c                	je     80102e51 <kfree+0x97>
    release(&kmem.lock);
80102e45:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e4c:	e8 2c 23 00 00       	call   8010517d <release>
}
80102e51:	c9                   	leave  
80102e52:	c3                   	ret    

80102e53 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e53:	55                   	push   %ebp
80102e54:	89 e5                	mov    %esp,%ebp
80102e56:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102e59:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e5e:	85 c0                	test   %eax,%eax
80102e60:	74 0c                	je     80102e6e <kalloc+0x1b>
    acquire(&kmem.lock);
80102e62:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e69:	e8 ad 22 00 00       	call   8010511b <acquire>
  r = kmem.freelist;
80102e6e:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102e73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e7a:	74 0a                	je     80102e86 <kalloc+0x33>
    kmem.freelist = r->next;
80102e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e7f:	8b 00                	mov    (%eax),%eax
80102e81:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e86:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e8b:	85 c0                	test   %eax,%eax
80102e8d:	74 0c                	je     80102e9b <kalloc+0x48>
    release(&kmem.lock);
80102e8f:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e96:	e8 e2 22 00 00       	call   8010517d <release>
  return (char*)r;
80102e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e9e:	c9                   	leave  
80102e9f:	c3                   	ret    

80102ea0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ea0:	55                   	push   %ebp
80102ea1:	89 e5                	mov    %esp,%ebp
80102ea3:	53                   	push   %ebx
80102ea4:	83 ec 14             	sub    $0x14,%esp
80102ea7:	8b 45 08             	mov    0x8(%ebp),%eax
80102eaa:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102eae:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102eb2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102eb6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102eba:	ec                   	in     (%dx),%al
80102ebb:	89 c3                	mov    %eax,%ebx
80102ebd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102ec0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102ec4:	83 c4 14             	add    $0x14,%esp
80102ec7:	5b                   	pop    %ebx
80102ec8:	5d                   	pop    %ebp
80102ec9:	c3                   	ret    

80102eca <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102eca:	55                   	push   %ebp
80102ecb:	89 e5                	mov    %esp,%ebp
80102ecd:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ed0:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102ed7:	e8 c4 ff ff ff       	call   80102ea0 <inb>
80102edc:	0f b6 c0             	movzbl %al,%eax
80102edf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ee5:	83 e0 01             	and    $0x1,%eax
80102ee8:	85 c0                	test   %eax,%eax
80102eea:	75 0a                	jne    80102ef6 <kbdgetc+0x2c>
    return -1;
80102eec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ef1:	e9 23 01 00 00       	jmp    80103019 <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102ef6:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102efd:	e8 9e ff ff ff       	call   80102ea0 <inb>
80102f02:	0f b6 c0             	movzbl %al,%eax
80102f05:	89 45 fc             	mov    %eax,-0x4(%ebp)
    
  if(data == 0xE0){
80102f08:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f0f:	75 17                	jne    80102f28 <kbdgetc+0x5e>
    shift |= E0ESC;
80102f11:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f16:	83 c8 40             	or     $0x40,%eax
80102f19:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102f1e:	b8 00 00 00 00       	mov    $0x0,%eax
80102f23:	e9 f1 00 00 00       	jmp    80103019 <kbdgetc+0x14f>
  } else if(data & 0x80){
80102f28:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f2b:	25 80 00 00 00       	and    $0x80,%eax
80102f30:	85 c0                	test   %eax,%eax
80102f32:	74 45                	je     80102f79 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f34:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f39:	83 e0 40             	and    $0x40,%eax
80102f3c:	85 c0                	test   %eax,%eax
80102f3e:	75 08                	jne    80102f48 <kbdgetc+0x7e>
80102f40:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f43:	83 e0 7f             	and    $0x7f,%eax
80102f46:	eb 03                	jmp    80102f4b <kbdgetc+0x81>
80102f48:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f4b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f51:	05 20 90 10 80       	add    $0x80109020,%eax
80102f56:	0f b6 00             	movzbl (%eax),%eax
80102f59:	83 c8 40             	or     $0x40,%eax
80102f5c:	0f b6 c0             	movzbl %al,%eax
80102f5f:	f7 d0                	not    %eax
80102f61:	89 c2                	mov    %eax,%edx
80102f63:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f68:	21 d0                	and    %edx,%eax
80102f6a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102f6f:	b8 00 00 00 00       	mov    $0x0,%eax
80102f74:	e9 a0 00 00 00       	jmp    80103019 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102f79:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f7e:	83 e0 40             	and    $0x40,%eax
80102f81:	85 c0                	test   %eax,%eax
80102f83:	74 14                	je     80102f99 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f85:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f8c:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f91:	83 e0 bf             	and    $0xffffffbf,%eax
80102f94:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102f99:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f9c:	05 20 90 10 80       	add    $0x80109020,%eax
80102fa1:	0f b6 00             	movzbl (%eax),%eax
80102fa4:	0f b6 d0             	movzbl %al,%edx
80102fa7:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fac:	09 d0                	or     %edx,%eax
80102fae:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102fb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fb6:	05 20 91 10 80       	add    $0x80109120,%eax
80102fbb:	0f b6 00             	movzbl (%eax),%eax
80102fbe:	0f b6 d0             	movzbl %al,%edx
80102fc1:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fc6:	31 d0                	xor    %edx,%eax
80102fc8:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fcd:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fd2:	83 e0 03             	and    $0x3,%eax
80102fd5:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
80102fdc:	03 45 fc             	add    -0x4(%ebp),%eax
80102fdf:	0f b6 00             	movzbl (%eax),%eax
80102fe2:	0f b6 c0             	movzbl %al,%eax
80102fe5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102fe8:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102fed:	83 e0 08             	and    $0x8,%eax
80102ff0:	85 c0                	test   %eax,%eax
80102ff2:	74 22                	je     80103016 <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102ff4:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102ff8:	76 0c                	jbe    80103006 <kbdgetc+0x13c>
80102ffa:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102ffe:	77 06                	ja     80103006 <kbdgetc+0x13c>
      c += 'A' - 'a';
80103000:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103004:	eb 10                	jmp    80103016 <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80103006:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010300a:	76 0a                	jbe    80103016 <kbdgetc+0x14c>
8010300c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103010:	77 04                	ja     80103016 <kbdgetc+0x14c>
      c += 'a' - 'A';
80103012:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103016:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103019:	c9                   	leave  
8010301a:	c3                   	ret    

8010301b <kbdintr>:

void
kbdintr(void)
{
8010301b:	55                   	push   %ebp
8010301c:	89 e5                	mov    %esp,%ebp
8010301e:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80103021:	c7 04 24 ca 2e 10 80 	movl   $0x80102eca,(%esp)
80103028:	e8 a1 d8 ff ff       	call   801008ce <consoleintr>
}
8010302d:	c9                   	leave  
8010302e:	c3                   	ret    
	...

80103030 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103030:	55                   	push   %ebp
80103031:	89 e5                	mov    %esp,%ebp
80103033:	83 ec 08             	sub    $0x8,%esp
80103036:	8b 55 08             	mov    0x8(%ebp),%edx
80103039:	8b 45 0c             	mov    0xc(%ebp),%eax
8010303c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103040:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103043:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103047:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010304b:	ee                   	out    %al,(%dx)
}
8010304c:	c9                   	leave  
8010304d:	c3                   	ret    

8010304e <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010304e:	55                   	push   %ebp
8010304f:	89 e5                	mov    %esp,%ebp
80103051:	53                   	push   %ebx
80103052:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103055:	9c                   	pushf  
80103056:	5b                   	pop    %ebx
80103057:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010305a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010305d:	83 c4 10             	add    $0x10,%esp
80103060:	5b                   	pop    %ebx
80103061:	5d                   	pop    %ebp
80103062:	c3                   	ret    

80103063 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103063:	55                   	push   %ebp
80103064:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103066:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010306b:	8b 55 08             	mov    0x8(%ebp),%edx
8010306e:	c1 e2 02             	shl    $0x2,%edx
80103071:	01 c2                	add    %eax,%edx
80103073:	8b 45 0c             	mov    0xc(%ebp),%eax
80103076:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103078:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010307d:	83 c0 20             	add    $0x20,%eax
80103080:	8b 00                	mov    (%eax),%eax
}
80103082:	5d                   	pop    %ebp
80103083:	c3                   	ret    

80103084 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80103084:	55                   	push   %ebp
80103085:	89 e5                	mov    %esp,%ebp
80103087:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
8010308a:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010308f:	85 c0                	test   %eax,%eax
80103091:	0f 84 47 01 00 00    	je     801031de <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103097:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
8010309e:	00 
8010309f:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
801030a6:	e8 b8 ff ff ff       	call   80103063 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030ab:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
801030b2:	00 
801030b3:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
801030ba:	e8 a4 ff ff ff       	call   80103063 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801030bf:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
801030c6:	00 
801030c7:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030ce:	e8 90 ff ff ff       	call   80103063 <lapicw>
  lapicw(TICR, 10000000); 
801030d3:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801030da:	00 
801030db:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801030e2:	e8 7c ff ff ff       	call   80103063 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030e7:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030ee:	00 
801030ef:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801030f6:	e8 68 ff ff ff       	call   80103063 <lapicw>
  lapicw(LINT1, MASKED);
801030fb:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103102:	00 
80103103:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
8010310a:	e8 54 ff ff ff       	call   80103063 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010310f:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103114:	83 c0 30             	add    $0x30,%eax
80103117:	8b 00                	mov    (%eax),%eax
80103119:	c1 e8 10             	shr    $0x10,%eax
8010311c:	25 ff 00 00 00       	and    $0xff,%eax
80103121:	83 f8 03             	cmp    $0x3,%eax
80103124:	76 14                	jbe    8010313a <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
80103126:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010312d:	00 
8010312e:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103135:	e8 29 ff ff ff       	call   80103063 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010313a:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103141:	00 
80103142:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103149:	e8 15 ff ff ff       	call   80103063 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010314e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103155:	00 
80103156:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010315d:	e8 01 ff ff ff       	call   80103063 <lapicw>
  lapicw(ESR, 0);
80103162:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103169:	00 
8010316a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103171:	e8 ed fe ff ff       	call   80103063 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103176:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010317d:	00 
8010317e:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103185:	e8 d9 fe ff ff       	call   80103063 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010318a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103191:	00 
80103192:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103199:	e8 c5 fe ff ff       	call   80103063 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010319e:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
801031a5:	00 
801031a6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031ad:	e8 b1 fe ff ff       	call   80103063 <lapicw>
  while(lapic[ICRLO] & DELIVS)
801031b2:	90                   	nop
801031b3:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031b8:	05 00 03 00 00       	add    $0x300,%eax
801031bd:	8b 00                	mov    (%eax),%eax
801031bf:	25 00 10 00 00       	and    $0x1000,%eax
801031c4:	85 c0                	test   %eax,%eax
801031c6:	75 eb                	jne    801031b3 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031cf:	00 
801031d0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801031d7:	e8 87 fe ff ff       	call   80103063 <lapicw>
801031dc:	eb 01                	jmp    801031df <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
801031de:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801031df:	c9                   	leave  
801031e0:	c3                   	ret    

801031e1 <cpunum>:

int
cpunum(void)
{
801031e1:	55                   	push   %ebp
801031e2:	89 e5                	mov    %esp,%ebp
801031e4:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
801031e7:	e8 62 fe ff ff       	call   8010304e <readeflags>
801031ec:	25 00 02 00 00       	and    $0x200,%eax
801031f1:	85 c0                	test   %eax,%eax
801031f3:	74 29                	je     8010321e <cpunum+0x3d>
    static int n;
    if(n++ == 0)
801031f5:	a1 40 b6 10 80       	mov    0x8010b640,%eax
801031fa:	85 c0                	test   %eax,%eax
801031fc:	0f 94 c2             	sete   %dl
801031ff:	83 c0 01             	add    $0x1,%eax
80103202:	a3 40 b6 10 80       	mov    %eax,0x8010b640
80103207:	84 d2                	test   %dl,%dl
80103209:	74 13                	je     8010321e <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
8010320b:	8b 45 04             	mov    0x4(%ebp),%eax
8010320e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103212:	c7 04 24 50 89 10 80 	movl   $0x80108950,(%esp)
80103219:	e8 83 d1 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
8010321e:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103223:	85 c0                	test   %eax,%eax
80103225:	74 0f                	je     80103236 <cpunum+0x55>
    return lapic[ID]>>24;
80103227:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010322c:	83 c0 20             	add    $0x20,%eax
8010322f:	8b 00                	mov    (%eax),%eax
80103231:	c1 e8 18             	shr    $0x18,%eax
80103234:	eb 05                	jmp    8010323b <cpunum+0x5a>
  return 0;
80103236:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010323b:	c9                   	leave  
8010323c:	c3                   	ret    

8010323d <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010323d:	55                   	push   %ebp
8010323e:	89 e5                	mov    %esp,%ebp
80103240:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103243:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103248:	85 c0                	test   %eax,%eax
8010324a:	74 14                	je     80103260 <lapiceoi+0x23>
    lapicw(EOI, 0);
8010324c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103253:	00 
80103254:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010325b:	e8 03 fe ff ff       	call   80103063 <lapicw>
}
80103260:	c9                   	leave  
80103261:	c3                   	ret    

80103262 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103262:	55                   	push   %ebp
80103263:	89 e5                	mov    %esp,%ebp
}
80103265:	5d                   	pop    %ebp
80103266:	c3                   	ret    

80103267 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103267:	55                   	push   %ebp
80103268:	89 e5                	mov    %esp,%ebp
8010326a:	83 ec 1c             	sub    $0x1c,%esp
8010326d:	8b 45 08             	mov    0x8(%ebp),%eax
80103270:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80103273:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010327a:	00 
8010327b:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103282:	e8 a9 fd ff ff       	call   80103030 <outb>
  outb(IO_RTC+1, 0x0A);
80103287:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010328e:	00 
8010328f:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103296:	e8 95 fd ff ff       	call   80103030 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010329b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801032a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032a5:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801032aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801032ad:	8d 50 02             	lea    0x2(%eax),%edx
801032b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801032b3:	c1 e8 04             	shr    $0x4,%eax
801032b6:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801032b9:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032bd:	c1 e0 18             	shl    $0x18,%eax
801032c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801032c4:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032cb:	e8 93 fd ff ff       	call   80103063 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801032d0:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801032d7:	00 
801032d8:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032df:	e8 7f fd ff ff       	call   80103063 <lapicw>
  microdelay(200);
801032e4:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032eb:	e8 72 ff ff ff       	call   80103262 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801032f0:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801032f7:	00 
801032f8:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032ff:	e8 5f fd ff ff       	call   80103063 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103304:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
8010330b:	e8 52 ff ff ff       	call   80103262 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103310:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103317:	eb 40                	jmp    80103359 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80103319:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010331d:	c1 e0 18             	shl    $0x18,%eax
80103320:	89 44 24 04          	mov    %eax,0x4(%esp)
80103324:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010332b:	e8 33 fd ff ff       	call   80103063 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103330:	8b 45 0c             	mov    0xc(%ebp),%eax
80103333:	c1 e8 0c             	shr    $0xc,%eax
80103336:	80 cc 06             	or     $0x6,%ah
80103339:	89 44 24 04          	mov    %eax,0x4(%esp)
8010333d:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103344:	e8 1a fd ff ff       	call   80103063 <lapicw>
    microdelay(200);
80103349:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103350:	e8 0d ff ff ff       	call   80103262 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103355:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103359:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010335d:	7e ba                	jle    80103319 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010335f:	c9                   	leave  
80103360:	c3                   	ret    
80103361:	00 00                	add    %al,(%eax)
	...

80103364 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103364:	55                   	push   %ebp
80103365:	89 e5                	mov    %esp,%ebp
80103367:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010336a:	c7 44 24 04 7c 89 10 	movl   $0x8010897c,0x4(%esp)
80103371:	80 
80103372:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103379:	e8 7c 1d 00 00       	call   801050fa <initlock>
  readsb(ROOTDEV, &sb);
8010337e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103381:	89 44 24 04          	mov    %eax,0x4(%esp)
80103385:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010338c:	e8 af e2 ff ff       	call   80101640 <readsb>
  log.start = sb.size - sb.nlog;
80103391:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103397:	89 d1                	mov    %edx,%ecx
80103399:	29 c1                	sub    %eax,%ecx
8010339b:	89 c8                	mov    %ecx,%eax
8010339d:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
801033a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033a5:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
801033aa:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
801033b1:	00 00 00 
  recover_from_log();
801033b4:	e8 97 01 00 00       	call   80103550 <recover_from_log>
}
801033b9:	c9                   	leave  
801033ba:	c3                   	ret    

801033bb <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801033bb:	55                   	push   %ebp
801033bc:	89 e5                	mov    %esp,%ebp
801033be:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033c8:	e9 89 00 00 00       	jmp    80103456 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033cd:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801033d2:	03 45 f4             	add    -0xc(%ebp),%eax
801033d5:	83 c0 01             	add    $0x1,%eax
801033d8:	89 c2                	mov    %eax,%edx
801033da:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801033df:	89 54 24 04          	mov    %edx,0x4(%esp)
801033e3:	89 04 24             	mov    %eax,(%esp)
801033e6:	e8 bb cd ff ff       	call   801001a6 <bread>
801033eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801033ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033f1:	83 c0 10             	add    $0x10,%eax
801033f4:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
801033fb:	89 c2                	mov    %eax,%edx
801033fd:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103402:	89 54 24 04          	mov    %edx,0x4(%esp)
80103406:	89 04 24             	mov    %eax,(%esp)
80103409:	e8 98 cd ff ff       	call   801001a6 <bread>
8010340e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103411:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103414:	8d 50 18             	lea    0x18(%eax),%edx
80103417:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010341a:	83 c0 18             	add    $0x18,%eax
8010341d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103424:	00 
80103425:	89 54 24 04          	mov    %edx,0x4(%esp)
80103429:	89 04 24             	mov    %eax,(%esp)
8010342c:	e8 0c 20 00 00       	call   8010543d <memmove>
    bwrite(dbuf);  // write dst to disk
80103431:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103434:	89 04 24             	mov    %eax,(%esp)
80103437:	e8 a1 cd ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
8010343c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010343f:	89 04 24             	mov    %eax,(%esp)
80103442:	e8 d0 cd ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103447:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010344a:	89 04 24             	mov    %eax,(%esp)
8010344d:	e8 c5 cd ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103452:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103456:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010345b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010345e:	0f 8f 69 ff ff ff    	jg     801033cd <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103464:	c9                   	leave  
80103465:	c3                   	ret    

80103466 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103466:	55                   	push   %ebp
80103467:	89 e5                	mov    %esp,%ebp
80103469:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010346c:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103471:	89 c2                	mov    %eax,%edx
80103473:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103478:	89 54 24 04          	mov    %edx,0x4(%esp)
8010347c:	89 04 24             	mov    %eax,(%esp)
8010347f:	e8 22 cd ff ff       	call   801001a6 <bread>
80103484:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010348a:	83 c0 18             	add    $0x18,%eax
8010348d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103490:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103493:	8b 00                	mov    (%eax),%eax
80103495:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
8010349a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034a1:	eb 1b                	jmp    801034be <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
801034a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034a9:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034b0:	83 c2 10             	add    $0x10,%edx
801034b3:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034be:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801034c3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034c6:	7f db                	jg     801034a3 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801034c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cb:	89 04 24             	mov    %eax,(%esp)
801034ce:	e8 44 cd ff ff       	call   80100217 <brelse>
}
801034d3:	c9                   	leave  
801034d4:	c3                   	ret    

801034d5 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034d5:	55                   	push   %ebp
801034d6:	89 e5                	mov    %esp,%ebp
801034d8:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034db:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801034e0:	89 c2                	mov    %eax,%edx
801034e2:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801034e7:	89 54 24 04          	mov    %edx,0x4(%esp)
801034eb:	89 04 24             	mov    %eax,(%esp)
801034ee:	e8 b3 cc ff ff       	call   801001a6 <bread>
801034f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034f9:	83 c0 18             	add    $0x18,%eax
801034fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034ff:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
80103505:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103508:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010350a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103511:	eb 1b                	jmp    8010352e <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
80103513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103516:	83 c0 10             	add    $0x10,%eax
80103519:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
80103520:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103523:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103526:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010352a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010352e:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103533:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103536:	7f db                	jg     80103513 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010353b:	89 04 24             	mov    %eax,(%esp)
8010353e:	e8 9a cc ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103543:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103546:	89 04 24             	mov    %eax,(%esp)
80103549:	e8 c9 cc ff ff       	call   80100217 <brelse>
}
8010354e:	c9                   	leave  
8010354f:	c3                   	ret    

80103550 <recover_from_log>:

static void
recover_from_log(void)
{
80103550:	55                   	push   %ebp
80103551:	89 e5                	mov    %esp,%ebp
80103553:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103556:	e8 0b ff ff ff       	call   80103466 <read_head>
  install_trans(); // if committed, copy from log to disk
8010355b:	e8 5b fe ff ff       	call   801033bb <install_trans>
  log.lh.n = 0;
80103560:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
80103567:	00 00 00 
  write_head(); // clear the log
8010356a:	e8 66 ff ff ff       	call   801034d5 <write_head>
}
8010356f:	c9                   	leave  
80103570:	c3                   	ret    

80103571 <begin_trans>:

void
begin_trans(void)
{
80103571:	55                   	push   %ebp
80103572:	89 e5                	mov    %esp,%ebp
80103574:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103577:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010357e:	e8 98 1b 00 00       	call   8010511b <acquire>
  while (log.busy) {
80103583:	eb 14                	jmp    80103599 <begin_trans+0x28>
    sleep(&log, &log.lock);
80103585:	c7 44 24 04 a0 f8 10 	movl   $0x8010f8a0,0x4(%esp)
8010358c:	80 
8010358d:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103594:	e8 9c 18 00 00       	call   80104e35 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
80103599:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
8010359e:	85 c0                	test   %eax,%eax
801035a0:	75 e3                	jne    80103585 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
801035a2:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
801035a9:	00 00 00 
  release(&log.lock);
801035ac:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035b3:	e8 c5 1b 00 00       	call   8010517d <release>
}
801035b8:	c9                   	leave  
801035b9:	c3                   	ret    

801035ba <commit_trans>:

void
commit_trans(void)
{
801035ba:	55                   	push   %ebp
801035bb:	89 e5                	mov    %esp,%ebp
801035bd:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
801035c0:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035c5:	85 c0                	test   %eax,%eax
801035c7:	7e 19                	jle    801035e2 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
801035c9:	e8 07 ff ff ff       	call   801034d5 <write_head>
    install_trans(); // Now install writes to home locations
801035ce:	e8 e8 fd ff ff       	call   801033bb <install_trans>
    log.lh.n = 0; 
801035d3:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
801035da:	00 00 00 
    write_head();    // Erase the transaction from the log
801035dd:	e8 f3 fe ff ff       	call   801034d5 <write_head>
  }
  
  acquire(&log.lock);
801035e2:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035e9:	e8 2d 1b 00 00       	call   8010511b <acquire>
  log.busy = 0;
801035ee:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
801035f5:	00 00 00 
  wakeup(&log);
801035f8:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801035ff:	e8 0d 19 00 00       	call   80104f11 <wakeup>
  release(&log.lock);
80103604:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010360b:	e8 6d 1b 00 00       	call   8010517d <release>
}
80103610:	c9                   	leave  
80103611:	c3                   	ret    

80103612 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103612:	55                   	push   %ebp
80103613:	89 e5                	mov    %esp,%ebp
80103615:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103618:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010361d:	83 f8 09             	cmp    $0x9,%eax
80103620:	7f 12                	jg     80103634 <log_write+0x22>
80103622:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103627:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
8010362d:	83 ea 01             	sub    $0x1,%edx
80103630:	39 d0                	cmp    %edx,%eax
80103632:	7c 0c                	jl     80103640 <log_write+0x2e>
    panic("too big a transaction");
80103634:	c7 04 24 80 89 10 80 	movl   $0x80108980,(%esp)
8010363b:	e8 fd ce ff ff       	call   8010053d <panic>
  if (!log.busy)
80103640:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103645:	85 c0                	test   %eax,%eax
80103647:	75 0c                	jne    80103655 <log_write+0x43>
    panic("write outside of trans");
80103649:	c7 04 24 96 89 10 80 	movl   $0x80108996,(%esp)
80103650:	e8 e8 ce ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
80103655:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010365c:	eb 1d                	jmp    8010367b <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
8010365e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103661:	83 c0 10             	add    $0x10,%eax
80103664:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
8010366b:	89 c2                	mov    %eax,%edx
8010366d:	8b 45 08             	mov    0x8(%ebp),%eax
80103670:	8b 40 08             	mov    0x8(%eax),%eax
80103673:	39 c2                	cmp    %eax,%edx
80103675:	74 10                	je     80103687 <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
80103677:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010367b:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103680:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103683:	7f d9                	jg     8010365e <log_write+0x4c>
80103685:	eb 01                	jmp    80103688 <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
80103687:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103688:	8b 45 08             	mov    0x8(%ebp),%eax
8010368b:	8b 40 08             	mov    0x8(%eax),%eax
8010368e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103691:	83 c2 10             	add    $0x10,%edx
80103694:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
8010369b:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801036a0:	03 45 f4             	add    -0xc(%ebp),%eax
801036a3:	83 c0 01             	add    $0x1,%eax
801036a6:	89 c2                	mov    %eax,%edx
801036a8:	8b 45 08             	mov    0x8(%ebp),%eax
801036ab:	8b 40 04             	mov    0x4(%eax),%eax
801036ae:	89 54 24 04          	mov    %edx,0x4(%esp)
801036b2:	89 04 24             	mov    %eax,(%esp)
801036b5:	e8 ec ca ff ff       	call   801001a6 <bread>
801036ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
801036bd:	8b 45 08             	mov    0x8(%ebp),%eax
801036c0:	8d 50 18             	lea    0x18(%eax),%edx
801036c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036c6:	83 c0 18             	add    $0x18,%eax
801036c9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036d0:	00 
801036d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801036d5:	89 04 24             	mov    %eax,(%esp)
801036d8:	e8 60 1d 00 00       	call   8010543d <memmove>
  bwrite(lbuf);
801036dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036e0:	89 04 24             	mov    %eax,(%esp)
801036e3:	e8 f5 ca ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
801036e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036eb:	89 04 24             	mov    %eax,(%esp)
801036ee:	e8 24 cb ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
801036f3:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801036f8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036fb:	75 0d                	jne    8010370a <log_write+0xf8>
    log.lh.n++;
801036fd:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103702:	83 c0 01             	add    $0x1,%eax
80103705:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	8b 00                	mov    (%eax),%eax
8010370f:	89 c2                	mov    %eax,%edx
80103711:	83 ca 04             	or     $0x4,%edx
80103714:	8b 45 08             	mov    0x8(%ebp),%eax
80103717:	89 10                	mov    %edx,(%eax)
}
80103719:	c9                   	leave  
8010371a:	c3                   	ret    
	...

8010371c <v2p>:
8010371c:	55                   	push   %ebp
8010371d:	89 e5                	mov    %esp,%ebp
8010371f:	8b 45 08             	mov    0x8(%ebp),%eax
80103722:	05 00 00 00 80       	add    $0x80000000,%eax
80103727:	5d                   	pop    %ebp
80103728:	c3                   	ret    

80103729 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103729:	55                   	push   %ebp
8010372a:	89 e5                	mov    %esp,%ebp
8010372c:	8b 45 08             	mov    0x8(%ebp),%eax
8010372f:	05 00 00 00 80       	add    $0x80000000,%eax
80103734:	5d                   	pop    %ebp
80103735:	c3                   	ret    

80103736 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103736:	55                   	push   %ebp
80103737:	89 e5                	mov    %esp,%ebp
80103739:	53                   	push   %ebx
8010373a:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
8010373d:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103740:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80103743:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103746:	89 c3                	mov    %eax,%ebx
80103748:	89 d8                	mov    %ebx,%eax
8010374a:	f0 87 02             	lock xchg %eax,(%edx)
8010374d:	89 c3                	mov    %eax,%ebx
8010374f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103752:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103755:	83 c4 10             	add    $0x10,%esp
80103758:	5b                   	pop    %ebx
80103759:	5d                   	pop    %ebp
8010375a:	c3                   	ret    

8010375b <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010375b:	55                   	push   %ebp
8010375c:	89 e5                	mov    %esp,%ebp
8010375e:	83 e4 f0             	and    $0xfffffff0,%esp
80103761:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103764:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010376b:	80 
8010376c:	c7 04 24 1c 2a 11 80 	movl   $0x80112a1c,(%esp)
80103773:	e8 ad f5 ff ff       	call   80102d25 <kinit1>
  kvmalloc();      // kernel page table
80103778:	e8 5d 48 00 00       	call   80107fda <kvmalloc>
  mpinit();        // collect info about this machine
8010377d:	e8 63 04 00 00       	call   80103be5 <mpinit>
  lapicinit(mpbcpu());
80103782:	e8 2e 02 00 00       	call   801039b5 <mpbcpu>
80103787:	89 04 24             	mov    %eax,(%esp)
8010378a:	e8 f5 f8 ff ff       	call   80103084 <lapicinit>
  seginit();       // set up segments
8010378f:	e8 e9 41 00 00       	call   8010797d <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103794:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010379a:	0f b6 00             	movzbl (%eax),%eax
8010379d:	0f b6 c0             	movzbl %al,%eax
801037a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801037a4:	c7 04 24 ad 89 10 80 	movl   $0x801089ad,(%esp)
801037ab:	e8 f1 cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037b0:	e8 95 06 00 00       	call   80103e4a <picinit>
  ioapicinit();    // another interrupt controller
801037b5:	e8 5b f4 ff ff       	call   80102c15 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037ba:	e8 22 d6 ff ff       	call   80100de1 <consoleinit>
  uartinit();      // serial port
801037bf:	e8 04 35 00 00       	call   80106cc8 <uartinit>
  pinit();         // process table
801037c4:	e8 96 0b 00 00       	call   8010435f <pinit>
  tvinit();        // trap vectors
801037c9:	e8 9d 30 00 00       	call   8010686b <tvinit>
  binit();         // buffer cache
801037ce:	e8 61 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037d3:	e8 7c da ff ff       	call   80101254 <fileinit>
  iinit();         // inode cache
801037d8:	e8 2a e1 ff ff       	call   80101907 <iinit>
  ideinit();       // disk
801037dd:	e8 98 f0 ff ff       	call   8010287a <ideinit>
  if(!ismp)
801037e2:	a1 24 f9 10 80       	mov    0x8010f924,%eax
801037e7:	85 c0                	test   %eax,%eax
801037e9:	75 05                	jne    801037f0 <main+0x95>
    timerinit();   // uniprocessor timer
801037eb:	e8 be 2f 00 00       	call   801067ae <timerinit>
  startothers();   // start other processors
801037f0:	e8 87 00 00 00       	call   8010387c <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801037f5:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801037fc:	8e 
801037fd:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103804:	e8 54 f5 ff ff       	call   80102d5d <kinit2>
  userinit();      // first user process
80103809:	e8 6f 0c 00 00       	call   8010447d <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010380e:	e8 22 00 00 00       	call   80103835 <mpmain>

80103813 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103813:	55                   	push   %ebp
80103814:	89 e5                	mov    %esp,%ebp
80103816:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
80103819:	e8 d3 47 00 00       	call   80107ff1 <switchkvm>
  seginit();
8010381e:	e8 5a 41 00 00       	call   8010797d <seginit>
  lapicinit(cpunum());
80103823:	e8 b9 f9 ff ff       	call   801031e1 <cpunum>
80103828:	89 04 24             	mov    %eax,(%esp)
8010382b:	e8 54 f8 ff ff       	call   80103084 <lapicinit>
  mpmain();
80103830:	e8 00 00 00 00       	call   80103835 <mpmain>

80103835 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103835:	55                   	push   %ebp
80103836:	89 e5                	mov    %esp,%ebp
80103838:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010383b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103841:	0f b6 00             	movzbl (%eax),%eax
80103844:	0f b6 c0             	movzbl %al,%eax
80103847:	89 44 24 04          	mov    %eax,0x4(%esp)
8010384b:	c7 04 24 c4 89 10 80 	movl   $0x801089c4,(%esp)
80103852:	e8 4a cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80103857:	e8 83 31 00 00       	call   801069df <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010385c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103862:	05 a8 00 00 00       	add    $0xa8,%eax
80103867:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010386e:	00 
8010386f:	89 04 24             	mov    %eax,(%esp)
80103872:	e8 bf fe ff ff       	call   80103736 <xchg>
  scheduler();     // start running processes
80103877:	e8 a1 13 00 00       	call   80104c1d <scheduler>

8010387c <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010387c:	55                   	push   %ebp
8010387d:	89 e5                	mov    %esp,%ebp
8010387f:	53                   	push   %ebx
80103880:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103883:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
8010388a:	e8 9a fe ff ff       	call   80103729 <p2v>
8010388f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103892:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103897:	89 44 24 08          	mov    %eax,0x8(%esp)
8010389b:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
801038a2:	80 
801038a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a6:	89 04 24             	mov    %eax,(%esp)
801038a9:	e8 8f 1b 00 00       	call   8010543d <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801038ae:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
801038b5:	e9 86 00 00 00       	jmp    80103940 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
801038ba:	e8 22 f9 ff ff       	call   801031e1 <cpunum>
801038bf:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038c5:	05 40 f9 10 80       	add    $0x8010f940,%eax
801038ca:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038cd:	74 69                	je     80103938 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038cf:	e8 7f f5 ff ff       	call   80102e53 <kalloc>
801038d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038da:	83 e8 04             	sub    $0x4,%eax
801038dd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038e0:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038e6:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038eb:	83 e8 08             	sub    $0x8,%eax
801038ee:	c7 00 13 38 10 80    	movl   $0x80103813,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038f7:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038fa:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103901:	e8 16 fe ff ff       	call   8010371c <v2p>
80103906:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103908:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390b:	89 04 24             	mov    %eax,(%esp)
8010390e:	e8 09 fe ff ff       	call   8010371c <v2p>
80103913:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103916:	0f b6 12             	movzbl (%edx),%edx
80103919:	0f b6 d2             	movzbl %dl,%edx
8010391c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103920:	89 14 24             	mov    %edx,(%esp)
80103923:	e8 3f f9 ff ff       	call   80103267 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103928:	90                   	nop
80103929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010392c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103932:	85 c0                	test   %eax,%eax
80103934:	74 f3                	je     80103929 <startothers+0xad>
80103936:	eb 01                	jmp    80103939 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103938:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103939:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103940:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103945:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010394b:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103950:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103953:	0f 87 61 ff ff ff    	ja     801038ba <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103959:	83 c4 24             	add    $0x24,%esp
8010395c:	5b                   	pop    %ebx
8010395d:	5d                   	pop    %ebp
8010395e:	c3                   	ret    
	...

80103960 <p2v>:
80103960:	55                   	push   %ebp
80103961:	89 e5                	mov    %esp,%ebp
80103963:	8b 45 08             	mov    0x8(%ebp),%eax
80103966:	05 00 00 00 80       	add    $0x80000000,%eax
8010396b:	5d                   	pop    %ebp
8010396c:	c3                   	ret    

8010396d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010396d:	55                   	push   %ebp
8010396e:	89 e5                	mov    %esp,%ebp
80103970:	53                   	push   %ebx
80103971:	83 ec 14             	sub    $0x14,%esp
80103974:	8b 45 08             	mov    0x8(%ebp),%eax
80103977:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010397b:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010397f:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80103983:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80103987:	ec                   	in     (%dx),%al
80103988:	89 c3                	mov    %eax,%ebx
8010398a:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010398d:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103991:	83 c4 14             	add    $0x14,%esp
80103994:	5b                   	pop    %ebx
80103995:	5d                   	pop    %ebp
80103996:	c3                   	ret    

80103997 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103997:	55                   	push   %ebp
80103998:	89 e5                	mov    %esp,%ebp
8010399a:	83 ec 08             	sub    $0x8,%esp
8010399d:	8b 55 08             	mov    0x8(%ebp),%edx
801039a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801039a3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039a7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039aa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039ae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039b2:	ee                   	out    %al,(%dx)
}
801039b3:	c9                   	leave  
801039b4:	c3                   	ret    

801039b5 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039b5:	55                   	push   %ebp
801039b6:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039b8:	a1 44 b6 10 80       	mov    0x8010b644,%eax
801039bd:	89 c2                	mov    %eax,%edx
801039bf:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
801039c4:	89 d1                	mov    %edx,%ecx
801039c6:	29 c1                	sub    %eax,%ecx
801039c8:	89 c8                	mov    %ecx,%eax
801039ca:	c1 f8 02             	sar    $0x2,%eax
801039cd:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801039d3:	5d                   	pop    %ebp
801039d4:	c3                   	ret    

801039d5 <sum>:

static uchar
sum(uchar *addr, int len)
{
801039d5:	55                   	push   %ebp
801039d6:	89 e5                	mov    %esp,%ebp
801039d8:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039db:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039e9:	eb 13                	jmp    801039fe <sum+0x29>
    sum += addr[i];
801039eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039ee:	03 45 08             	add    0x8(%ebp),%eax
801039f1:	0f b6 00             	movzbl (%eax),%eax
801039f4:	0f b6 c0             	movzbl %al,%eax
801039f7:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801039fa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801039fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a01:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a04:	7c e5                	jl     801039eb <sum+0x16>
    sum += addr[i];
  return sum;
80103a06:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a09:	c9                   	leave  
80103a0a:	c3                   	ret    

80103a0b <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a0b:	55                   	push   %ebp
80103a0c:	89 e5                	mov    %esp,%ebp
80103a0e:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a11:	8b 45 08             	mov    0x8(%ebp),%eax
80103a14:	89 04 24             	mov    %eax,(%esp)
80103a17:	e8 44 ff ff ff       	call   80103960 <p2v>
80103a1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a22:	03 45 f0             	add    -0x10(%ebp),%eax
80103a25:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a2e:	eb 3f                	jmp    80103a6f <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a30:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a37:	00 
80103a38:	c7 44 24 04 d8 89 10 	movl   $0x801089d8,0x4(%esp)
80103a3f:	80 
80103a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a43:	89 04 24             	mov    %eax,(%esp)
80103a46:	e8 96 19 00 00       	call   801053e1 <memcmp>
80103a4b:	85 c0                	test   %eax,%eax
80103a4d:	75 1c                	jne    80103a6b <mpsearch1+0x60>
80103a4f:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a56:	00 
80103a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5a:	89 04 24             	mov    %eax,(%esp)
80103a5d:	e8 73 ff ff ff       	call   801039d5 <sum>
80103a62:	84 c0                	test   %al,%al
80103a64:	75 05                	jne    80103a6b <mpsearch1+0x60>
      return (struct mp*)p;
80103a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a69:	eb 11                	jmp    80103a7c <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a6b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a72:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a75:	72 b9                	jb     80103a30 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a77:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a7c:	c9                   	leave  
80103a7d:	c3                   	ret    

80103a7e <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a7e:	55                   	push   %ebp
80103a7f:	89 e5                	mov    %esp,%ebp
80103a81:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a84:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a8e:	83 c0 0f             	add    $0xf,%eax
80103a91:	0f b6 00             	movzbl (%eax),%eax
80103a94:	0f b6 c0             	movzbl %al,%eax
80103a97:	89 c2                	mov    %eax,%edx
80103a99:	c1 e2 08             	shl    $0x8,%edx
80103a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a9f:	83 c0 0e             	add    $0xe,%eax
80103aa2:	0f b6 00             	movzbl (%eax),%eax
80103aa5:	0f b6 c0             	movzbl %al,%eax
80103aa8:	09 d0                	or     %edx,%eax
80103aaa:	c1 e0 04             	shl    $0x4,%eax
80103aad:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ab0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ab4:	74 21                	je     80103ad7 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103ab6:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103abd:	00 
80103abe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac1:	89 04 24             	mov    %eax,(%esp)
80103ac4:	e8 42 ff ff ff       	call   80103a0b <mpsearch1>
80103ac9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103acc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ad0:	74 50                	je     80103b22 <mpsearch+0xa4>
      return mp;
80103ad2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ad5:	eb 5f                	jmp    80103b36 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ada:	83 c0 14             	add    $0x14,%eax
80103add:	0f b6 00             	movzbl (%eax),%eax
80103ae0:	0f b6 c0             	movzbl %al,%eax
80103ae3:	89 c2                	mov    %eax,%edx
80103ae5:	c1 e2 08             	shl    $0x8,%edx
80103ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aeb:	83 c0 13             	add    $0x13,%eax
80103aee:	0f b6 00             	movzbl (%eax),%eax
80103af1:	0f b6 c0             	movzbl %al,%eax
80103af4:	09 d0                	or     %edx,%eax
80103af6:	c1 e0 0a             	shl    $0xa,%eax
80103af9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103afc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aff:	2d 00 04 00 00       	sub    $0x400,%eax
80103b04:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b0b:	00 
80103b0c:	89 04 24             	mov    %eax,(%esp)
80103b0f:	e8 f7 fe ff ff       	call   80103a0b <mpsearch1>
80103b14:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b17:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b1b:	74 05                	je     80103b22 <mpsearch+0xa4>
      return mp;
80103b1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b20:	eb 14                	jmp    80103b36 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b22:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b29:	00 
80103b2a:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b31:	e8 d5 fe ff ff       	call   80103a0b <mpsearch1>
}
80103b36:	c9                   	leave  
80103b37:	c3                   	ret    

80103b38 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b38:	55                   	push   %ebp
80103b39:	89 e5                	mov    %esp,%ebp
80103b3b:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b3e:	e8 3b ff ff ff       	call   80103a7e <mpsearch>
80103b43:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b4a:	74 0a                	je     80103b56 <mpconfig+0x1e>
80103b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4f:	8b 40 04             	mov    0x4(%eax),%eax
80103b52:	85 c0                	test   %eax,%eax
80103b54:	75 0a                	jne    80103b60 <mpconfig+0x28>
    return 0;
80103b56:	b8 00 00 00 00       	mov    $0x0,%eax
80103b5b:	e9 83 00 00 00       	jmp    80103be3 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b63:	8b 40 04             	mov    0x4(%eax),%eax
80103b66:	89 04 24             	mov    %eax,(%esp)
80103b69:	e8 f2 fd ff ff       	call   80103960 <p2v>
80103b6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b71:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b78:	00 
80103b79:	c7 44 24 04 dd 89 10 	movl   $0x801089dd,0x4(%esp)
80103b80:	80 
80103b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b84:	89 04 24             	mov    %eax,(%esp)
80103b87:	e8 55 18 00 00       	call   801053e1 <memcmp>
80103b8c:	85 c0                	test   %eax,%eax
80103b8e:	74 07                	je     80103b97 <mpconfig+0x5f>
    return 0;
80103b90:	b8 00 00 00 00       	mov    $0x0,%eax
80103b95:	eb 4c                	jmp    80103be3 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b9a:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b9e:	3c 01                	cmp    $0x1,%al
80103ba0:	74 12                	je     80103bb4 <mpconfig+0x7c>
80103ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba5:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ba9:	3c 04                	cmp    $0x4,%al
80103bab:	74 07                	je     80103bb4 <mpconfig+0x7c>
    return 0;
80103bad:	b8 00 00 00 00       	mov    $0x0,%eax
80103bb2:	eb 2f                	jmp    80103be3 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb7:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bbb:	0f b7 c0             	movzwl %ax,%eax
80103bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc5:	89 04 24             	mov    %eax,(%esp)
80103bc8:	e8 08 fe ff ff       	call   801039d5 <sum>
80103bcd:	84 c0                	test   %al,%al
80103bcf:	74 07                	je     80103bd8 <mpconfig+0xa0>
    return 0;
80103bd1:	b8 00 00 00 00       	mov    $0x0,%eax
80103bd6:	eb 0b                	jmp    80103be3 <mpconfig+0xab>
  *pmp = mp;
80103bd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103bdb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bde:	89 10                	mov    %edx,(%eax)
  return conf;
80103be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103be3:	c9                   	leave  
80103be4:	c3                   	ret    

80103be5 <mpinit>:

void
mpinit(void)
{
80103be5:	55                   	push   %ebp
80103be6:	89 e5                	mov    %esp,%ebp
80103be8:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103beb:	c7 05 44 b6 10 80 40 	movl   $0x8010f940,0x8010b644
80103bf2:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103bf5:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103bf8:	89 04 24             	mov    %eax,(%esp)
80103bfb:	e8 38 ff ff ff       	call   80103b38 <mpconfig>
80103c00:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c03:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c07:	0f 84 9c 01 00 00    	je     80103da9 <mpinit+0x1c4>
    return;
  ismp = 1;
80103c0d:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
80103c14:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1a:	8b 40 24             	mov    0x24(%eax),%eax
80103c1d:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c25:	83 c0 2c             	add    $0x2c,%eax
80103c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c2e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c32:	0f b7 c0             	movzwl %ax,%eax
80103c35:	03 45 f0             	add    -0x10(%ebp),%eax
80103c38:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c3b:	e9 f4 00 00 00       	jmp    80103d34 <mpinit+0x14f>
    switch(*p){
80103c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c43:	0f b6 00             	movzbl (%eax),%eax
80103c46:	0f b6 c0             	movzbl %al,%eax
80103c49:	83 f8 04             	cmp    $0x4,%eax
80103c4c:	0f 87 bf 00 00 00    	ja     80103d11 <mpinit+0x12c>
80103c52:	8b 04 85 20 8a 10 80 	mov    -0x7fef75e0(,%eax,4),%eax
80103c59:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c61:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c64:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c68:	0f b6 d0             	movzbl %al,%edx
80103c6b:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c70:	39 c2                	cmp    %eax,%edx
80103c72:	74 2d                	je     80103ca1 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c74:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c77:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c7b:	0f b6 d0             	movzbl %al,%edx
80103c7e:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c83:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c87:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c8b:	c7 04 24 e2 89 10 80 	movl   $0x801089e2,(%esp)
80103c92:	e8 0a c7 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103c97:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103c9e:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103ca1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ca4:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103ca8:	0f b6 c0             	movzbl %al,%eax
80103cab:	83 e0 02             	and    $0x2,%eax
80103cae:	85 c0                	test   %eax,%eax
80103cb0:	74 15                	je     80103cc7 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103cb2:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103cb7:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103cbd:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103cc2:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103cc7:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
80103ccd:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103cd2:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103cd8:	81 c2 40 f9 10 80    	add    $0x8010f940,%edx
80103cde:	88 02                	mov    %al,(%edx)
      ncpu++;
80103ce0:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103ce5:	83 c0 01             	add    $0x1,%eax
80103ce8:	a3 20 ff 10 80       	mov    %eax,0x8010ff20
      p += sizeof(struct mpproc);
80103ced:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103cf1:	eb 41                	jmp    80103d34 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103cf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cfc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d00:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
80103d05:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d09:	eb 29                	jmp    80103d34 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d0b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d0f:	eb 23                	jmp    80103d34 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d14:	0f b6 00             	movzbl (%eax),%eax
80103d17:	0f b6 c0             	movzbl %al,%eax
80103d1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d1e:	c7 04 24 00 8a 10 80 	movl   $0x80108a00,(%esp)
80103d25:	e8 77 c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103d2a:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103d31:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d37:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d3a:	0f 82 00 ff ff ff    	jb     80103c40 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d40:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80103d45:	85 c0                	test   %eax,%eax
80103d47:	75 1d                	jne    80103d66 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d49:	c7 05 20 ff 10 80 01 	movl   $0x1,0x8010ff20
80103d50:	00 00 00 
    lapic = 0;
80103d53:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
80103d5a:	00 00 00 
    ioapicid = 0;
80103d5d:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
    return;
80103d64:	eb 44                	jmp    80103daa <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d66:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d69:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d6d:	84 c0                	test   %al,%al
80103d6f:	74 39                	je     80103daa <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d71:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d78:	00 
80103d79:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d80:	e8 12 fc ff ff       	call   80103997 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d85:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d8c:	e8 dc fb ff ff       	call   8010396d <inb>
80103d91:	83 c8 01             	or     $0x1,%eax
80103d94:	0f b6 c0             	movzbl %al,%eax
80103d97:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d9b:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103da2:	e8 f0 fb ff ff       	call   80103997 <outb>
80103da7:	eb 01                	jmp    80103daa <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103da9:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103daa:	c9                   	leave  
80103dab:	c3                   	ret    

80103dac <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103dac:	55                   	push   %ebp
80103dad:	89 e5                	mov    %esp,%ebp
80103daf:	83 ec 08             	sub    $0x8,%esp
80103db2:	8b 55 08             	mov    0x8(%ebp),%edx
80103db5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103db8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103dbc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103dbf:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103dc3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103dc7:	ee                   	out    %al,(%dx)
}
80103dc8:	c9                   	leave  
80103dc9:	c3                   	ret    

80103dca <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103dca:	55                   	push   %ebp
80103dcb:	89 e5                	mov    %esp,%ebp
80103dcd:	83 ec 0c             	sub    $0xc,%esp
80103dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103dd7:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ddb:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103de1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103de5:	0f b6 c0             	movzbl %al,%eax
80103de8:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dec:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103df3:	e8 b4 ff ff ff       	call   80103dac <outb>
  outb(IO_PIC2+1, mask >> 8);
80103df8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103dfc:	66 c1 e8 08          	shr    $0x8,%ax
80103e00:	0f b6 c0             	movzbl %al,%eax
80103e03:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e07:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e0e:	e8 99 ff ff ff       	call   80103dac <outb>
}
80103e13:	c9                   	leave  
80103e14:	c3                   	ret    

80103e15 <picenable>:

void
picenable(int irq)
{
80103e15:	55                   	push   %ebp
80103e16:	89 e5                	mov    %esp,%ebp
80103e18:	53                   	push   %ebx
80103e19:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e1f:	ba 01 00 00 00       	mov    $0x1,%edx
80103e24:	89 d3                	mov    %edx,%ebx
80103e26:	89 c1                	mov    %eax,%ecx
80103e28:	d3 e3                	shl    %cl,%ebx
80103e2a:	89 d8                	mov    %ebx,%eax
80103e2c:	89 c2                	mov    %eax,%edx
80103e2e:	f7 d2                	not    %edx
80103e30:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e37:	21 d0                	and    %edx,%eax
80103e39:	0f b7 c0             	movzwl %ax,%eax
80103e3c:	89 04 24             	mov    %eax,(%esp)
80103e3f:	e8 86 ff ff ff       	call   80103dca <picsetmask>
}
80103e44:	83 c4 04             	add    $0x4,%esp
80103e47:	5b                   	pop    %ebx
80103e48:	5d                   	pop    %ebp
80103e49:	c3                   	ret    

80103e4a <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e4a:	55                   	push   %ebp
80103e4b:	89 e5                	mov    %esp,%ebp
80103e4d:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e50:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e57:	00 
80103e58:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e5f:	e8 48 ff ff ff       	call   80103dac <outb>
  outb(IO_PIC2+1, 0xFF);
80103e64:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e6b:	00 
80103e6c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e73:	e8 34 ff ff ff       	call   80103dac <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e78:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e7f:	00 
80103e80:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e87:	e8 20 ff ff ff       	call   80103dac <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e8c:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e93:	00 
80103e94:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e9b:	e8 0c ff ff ff       	call   80103dac <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103ea0:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103ea7:	00 
80103ea8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eaf:	e8 f8 fe ff ff       	call   80103dac <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103eb4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ebb:	00 
80103ebc:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ec3:	e8 e4 fe ff ff       	call   80103dac <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103ec8:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ecf:	00 
80103ed0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103ed7:	e8 d0 fe ff ff       	call   80103dac <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103edc:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103ee3:	00 
80103ee4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eeb:	e8 bc fe ff ff       	call   80103dac <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103ef0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103ef7:	00 
80103ef8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eff:	e8 a8 fe ff ff       	call   80103dac <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f04:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f0b:	00 
80103f0c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f13:	e8 94 fe ff ff       	call   80103dac <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f18:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f1f:	00 
80103f20:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f27:	e8 80 fe ff ff       	call   80103dac <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f2c:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f33:	00 
80103f34:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f3b:	e8 6c fe ff ff       	call   80103dac <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f40:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f47:	00 
80103f48:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f4f:	e8 58 fe ff ff       	call   80103dac <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f54:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f5b:	00 
80103f5c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f63:	e8 44 fe ff ff       	call   80103dac <outb>

  if(irqmask != 0xFFFF)
80103f68:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f6f:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f73:	74 12                	je     80103f87 <picinit+0x13d>
    picsetmask(irqmask);
80103f75:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f7c:	0f b7 c0             	movzwl %ax,%eax
80103f7f:	89 04 24             	mov    %eax,(%esp)
80103f82:	e8 43 fe ff ff       	call   80103dca <picsetmask>
}
80103f87:	c9                   	leave  
80103f88:	c3                   	ret    
80103f89:	00 00                	add    %al,(%eax)
	...

80103f8c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f8c:	55                   	push   %ebp
80103f8d:	89 e5                	mov    %esp,%ebp
80103f8f:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f99:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f9c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fa2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fa5:	8b 10                	mov    (%eax),%edx
80103fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80103faa:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fac:	e8 bf d2 ff ff       	call   80101270 <filealloc>
80103fb1:	8b 55 08             	mov    0x8(%ebp),%edx
80103fb4:	89 02                	mov    %eax,(%edx)
80103fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb9:	8b 00                	mov    (%eax),%eax
80103fbb:	85 c0                	test   %eax,%eax
80103fbd:	0f 84 c8 00 00 00    	je     8010408b <pipealloc+0xff>
80103fc3:	e8 a8 d2 ff ff       	call   80101270 <filealloc>
80103fc8:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fcb:	89 02                	mov    %eax,(%edx)
80103fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd0:	8b 00                	mov    (%eax),%eax
80103fd2:	85 c0                	test   %eax,%eax
80103fd4:	0f 84 b1 00 00 00    	je     8010408b <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103fda:	e8 74 ee ff ff       	call   80102e53 <kalloc>
80103fdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fe2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fe6:	0f 84 9e 00 00 00    	je     8010408a <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fef:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ff6:	00 00 00 
  p->writeopen = 1;
80103ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ffc:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104003:	00 00 00 
  p->nwrite = 0;
80104006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104009:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104010:	00 00 00 
  p->nread = 0;
80104013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104016:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010401d:	00 00 00 
  initlock(&p->lock, "pipe");
80104020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104023:	c7 44 24 04 34 8a 10 	movl   $0x80108a34,0x4(%esp)
8010402a:	80 
8010402b:	89 04 24             	mov    %eax,(%esp)
8010402e:	e8 c7 10 00 00       	call   801050fa <initlock>
  (*f0)->type = FD_PIPE;
80104033:	8b 45 08             	mov    0x8(%ebp),%eax
80104036:	8b 00                	mov    (%eax),%eax
80104038:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010403e:	8b 45 08             	mov    0x8(%ebp),%eax
80104041:	8b 00                	mov    (%eax),%eax
80104043:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104047:	8b 45 08             	mov    0x8(%ebp),%eax
8010404a:	8b 00                	mov    (%eax),%eax
8010404c:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104050:	8b 45 08             	mov    0x8(%ebp),%eax
80104053:	8b 00                	mov    (%eax),%eax
80104055:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104058:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010405b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010405e:	8b 00                	mov    (%eax),%eax
80104060:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104066:	8b 45 0c             	mov    0xc(%ebp),%eax
80104069:	8b 00                	mov    (%eax),%eax
8010406b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010406f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104072:	8b 00                	mov    (%eax),%eax
80104074:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104078:	8b 45 0c             	mov    0xc(%ebp),%eax
8010407b:	8b 00                	mov    (%eax),%eax
8010407d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104080:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104083:	b8 00 00 00 00       	mov    $0x0,%eax
80104088:	eb 43                	jmp    801040cd <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010408a:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010408b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010408f:	74 0b                	je     8010409c <pipealloc+0x110>
    kfree((char*)p);
80104091:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104094:	89 04 24             	mov    %eax,(%esp)
80104097:	e8 1e ed ff ff       	call   80102dba <kfree>
  if(*f0)
8010409c:	8b 45 08             	mov    0x8(%ebp),%eax
8010409f:	8b 00                	mov    (%eax),%eax
801040a1:	85 c0                	test   %eax,%eax
801040a3:	74 0d                	je     801040b2 <pipealloc+0x126>
    fileclose(*f0);
801040a5:	8b 45 08             	mov    0x8(%ebp),%eax
801040a8:	8b 00                	mov    (%eax),%eax
801040aa:	89 04 24             	mov    %eax,(%esp)
801040ad:	e8 66 d2 ff ff       	call   80101318 <fileclose>
  if(*f1)
801040b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b5:	8b 00                	mov    (%eax),%eax
801040b7:	85 c0                	test   %eax,%eax
801040b9:	74 0d                	je     801040c8 <pipealloc+0x13c>
    fileclose(*f1);
801040bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801040be:	8b 00                	mov    (%eax),%eax
801040c0:	89 04 24             	mov    %eax,(%esp)
801040c3:	e8 50 d2 ff ff       	call   80101318 <fileclose>
  return -1;
801040c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040cd:	c9                   	leave  
801040ce:	c3                   	ret    

801040cf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040cf:	55                   	push   %ebp
801040d0:	89 e5                	mov    %esp,%ebp
801040d2:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801040d5:	8b 45 08             	mov    0x8(%ebp),%eax
801040d8:	89 04 24             	mov    %eax,(%esp)
801040db:	e8 3b 10 00 00       	call   8010511b <acquire>
  if(writable){
801040e0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801040e4:	74 1f                	je     80104105 <pipeclose+0x36>
    p->writeopen = 0;
801040e6:	8b 45 08             	mov    0x8(%ebp),%eax
801040e9:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801040f0:	00 00 00 
    wakeup(&p->nread);
801040f3:	8b 45 08             	mov    0x8(%ebp),%eax
801040f6:	05 34 02 00 00       	add    $0x234,%eax
801040fb:	89 04 24             	mov    %eax,(%esp)
801040fe:	e8 0e 0e 00 00       	call   80104f11 <wakeup>
80104103:	eb 1d                	jmp    80104122 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104105:	8b 45 08             	mov    0x8(%ebp),%eax
80104108:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010410f:	00 00 00 
    wakeup(&p->nwrite);
80104112:	8b 45 08             	mov    0x8(%ebp),%eax
80104115:	05 38 02 00 00       	add    $0x238,%eax
8010411a:	89 04 24             	mov    %eax,(%esp)
8010411d:	e8 ef 0d 00 00       	call   80104f11 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104122:	8b 45 08             	mov    0x8(%ebp),%eax
80104125:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010412b:	85 c0                	test   %eax,%eax
8010412d:	75 25                	jne    80104154 <pipeclose+0x85>
8010412f:	8b 45 08             	mov    0x8(%ebp),%eax
80104132:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104138:	85 c0                	test   %eax,%eax
8010413a:	75 18                	jne    80104154 <pipeclose+0x85>
    release(&p->lock);
8010413c:	8b 45 08             	mov    0x8(%ebp),%eax
8010413f:	89 04 24             	mov    %eax,(%esp)
80104142:	e8 36 10 00 00       	call   8010517d <release>
    kfree((char*)p);
80104147:	8b 45 08             	mov    0x8(%ebp),%eax
8010414a:	89 04 24             	mov    %eax,(%esp)
8010414d:	e8 68 ec ff ff       	call   80102dba <kfree>
80104152:	eb 0b                	jmp    8010415f <pipeclose+0x90>
  } else
    release(&p->lock);
80104154:	8b 45 08             	mov    0x8(%ebp),%eax
80104157:	89 04 24             	mov    %eax,(%esp)
8010415a:	e8 1e 10 00 00       	call   8010517d <release>
}
8010415f:	c9                   	leave  
80104160:	c3                   	ret    

80104161 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104161:	55                   	push   %ebp
80104162:	89 e5                	mov    %esp,%ebp
80104164:	53                   	push   %ebx
80104165:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104168:	8b 45 08             	mov    0x8(%ebp),%eax
8010416b:	89 04 24             	mov    %eax,(%esp)
8010416e:	e8 a8 0f 00 00       	call   8010511b <acquire>
  for(i = 0; i < n; i++){
80104173:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010417a:	e9 a6 00 00 00       	jmp    80104225 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010417f:	8b 45 08             	mov    0x8(%ebp),%eax
80104182:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104188:	85 c0                	test   %eax,%eax
8010418a:	74 0d                	je     80104199 <pipewrite+0x38>
8010418c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104192:	8b 40 24             	mov    0x24(%eax),%eax
80104195:	85 c0                	test   %eax,%eax
80104197:	74 15                	je     801041ae <pipewrite+0x4d>
        release(&p->lock);
80104199:	8b 45 08             	mov    0x8(%ebp),%eax
8010419c:	89 04 24             	mov    %eax,(%esp)
8010419f:	e8 d9 0f 00 00       	call   8010517d <release>
        return -1;
801041a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041a9:	e9 9d 00 00 00       	jmp    8010424b <pipewrite+0xea>
      }
      wakeup(&p->nread);
801041ae:	8b 45 08             	mov    0x8(%ebp),%eax
801041b1:	05 34 02 00 00       	add    $0x234,%eax
801041b6:	89 04 24             	mov    %eax,(%esp)
801041b9:	e8 53 0d 00 00       	call   80104f11 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041be:	8b 45 08             	mov    0x8(%ebp),%eax
801041c1:	8b 55 08             	mov    0x8(%ebp),%edx
801041c4:	81 c2 38 02 00 00    	add    $0x238,%edx
801041ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801041ce:	89 14 24             	mov    %edx,(%esp)
801041d1:	e8 5f 0c 00 00       	call   80104e35 <sleep>
801041d6:	eb 01                	jmp    801041d9 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041d8:	90                   	nop
801041d9:	8b 45 08             	mov    0x8(%ebp),%eax
801041dc:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041e2:	8b 45 08             	mov    0x8(%ebp),%eax
801041e5:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041eb:	05 00 02 00 00       	add    $0x200,%eax
801041f0:	39 c2                	cmp    %eax,%edx
801041f2:	74 8b                	je     8010417f <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801041f4:	8b 45 08             	mov    0x8(%ebp),%eax
801041f7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041fd:	89 c3                	mov    %eax,%ebx
801041ff:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104205:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104208:	03 55 0c             	add    0xc(%ebp),%edx
8010420b:	0f b6 0a             	movzbl (%edx),%ecx
8010420e:	8b 55 08             	mov    0x8(%ebp),%edx
80104211:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104215:	8d 50 01             	lea    0x1(%eax),%edx
80104218:	8b 45 08             	mov    0x8(%ebp),%eax
8010421b:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104221:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104228:	3b 45 10             	cmp    0x10(%ebp),%eax
8010422b:	7c ab                	jl     801041d8 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010422d:	8b 45 08             	mov    0x8(%ebp),%eax
80104230:	05 34 02 00 00       	add    $0x234,%eax
80104235:	89 04 24             	mov    %eax,(%esp)
80104238:	e8 d4 0c 00 00       	call   80104f11 <wakeup>
  release(&p->lock);
8010423d:	8b 45 08             	mov    0x8(%ebp),%eax
80104240:	89 04 24             	mov    %eax,(%esp)
80104243:	e8 35 0f 00 00       	call   8010517d <release>
  return n;
80104248:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010424b:	83 c4 24             	add    $0x24,%esp
8010424e:	5b                   	pop    %ebx
8010424f:	5d                   	pop    %ebp
80104250:	c3                   	ret    

80104251 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104251:	55                   	push   %ebp
80104252:	89 e5                	mov    %esp,%ebp
80104254:	53                   	push   %ebx
80104255:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104258:	8b 45 08             	mov    0x8(%ebp),%eax
8010425b:	89 04 24             	mov    %eax,(%esp)
8010425e:	e8 b8 0e 00 00       	call   8010511b <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104263:	eb 3a                	jmp    8010429f <piperead+0x4e>
    if(proc->killed){
80104265:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010426b:	8b 40 24             	mov    0x24(%eax),%eax
8010426e:	85 c0                	test   %eax,%eax
80104270:	74 15                	je     80104287 <piperead+0x36>
      release(&p->lock);
80104272:	8b 45 08             	mov    0x8(%ebp),%eax
80104275:	89 04 24             	mov    %eax,(%esp)
80104278:	e8 00 0f 00 00       	call   8010517d <release>
      return -1;
8010427d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104282:	e9 b6 00 00 00       	jmp    8010433d <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104287:	8b 45 08             	mov    0x8(%ebp),%eax
8010428a:	8b 55 08             	mov    0x8(%ebp),%edx
8010428d:	81 c2 34 02 00 00    	add    $0x234,%edx
80104293:	89 44 24 04          	mov    %eax,0x4(%esp)
80104297:	89 14 24             	mov    %edx,(%esp)
8010429a:	e8 96 0b 00 00       	call   80104e35 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010429f:	8b 45 08             	mov    0x8(%ebp),%eax
801042a2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042a8:	8b 45 08             	mov    0x8(%ebp),%eax
801042ab:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042b1:	39 c2                	cmp    %eax,%edx
801042b3:	75 0d                	jne    801042c2 <piperead+0x71>
801042b5:	8b 45 08             	mov    0x8(%ebp),%eax
801042b8:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042be:	85 c0                	test   %eax,%eax
801042c0:	75 a3                	jne    80104265 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042c9:	eb 49                	jmp    80104314 <piperead+0xc3>
    if(p->nread == p->nwrite)
801042cb:	8b 45 08             	mov    0x8(%ebp),%eax
801042ce:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042d4:	8b 45 08             	mov    0x8(%ebp),%eax
801042d7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042dd:	39 c2                	cmp    %eax,%edx
801042df:	74 3d                	je     8010431e <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e4:	89 c2                	mov    %eax,%edx
801042e6:	03 55 0c             	add    0xc(%ebp),%edx
801042e9:	8b 45 08             	mov    0x8(%ebp),%eax
801042ec:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042f2:	89 c3                	mov    %eax,%ebx
801042f4:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801042fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
801042fd:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80104302:	88 0a                	mov    %cl,(%edx)
80104304:	8d 50 01             	lea    0x1(%eax),%edx
80104307:	8b 45 08             	mov    0x8(%ebp),%eax
8010430a:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104310:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104317:	3b 45 10             	cmp    0x10(%ebp),%eax
8010431a:	7c af                	jl     801042cb <piperead+0x7a>
8010431c:	eb 01                	jmp    8010431f <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
8010431e:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010431f:	8b 45 08             	mov    0x8(%ebp),%eax
80104322:	05 38 02 00 00       	add    $0x238,%eax
80104327:	89 04 24             	mov    %eax,(%esp)
8010432a:	e8 e2 0b 00 00       	call   80104f11 <wakeup>
  release(&p->lock);
8010432f:	8b 45 08             	mov    0x8(%ebp),%eax
80104332:	89 04 24             	mov    %eax,(%esp)
80104335:	e8 43 0e 00 00       	call   8010517d <release>
  return i;
8010433a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010433d:	83 c4 24             	add    $0x24,%esp
80104340:	5b                   	pop    %ebx
80104341:	5d                   	pop    %ebp
80104342:	c3                   	ret    
	...

80104344 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104344:	55                   	push   %ebp
80104345:	89 e5                	mov    %esp,%ebp
80104347:	53                   	push   %ebx
80104348:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010434b:	9c                   	pushf  
8010434c:	5b                   	pop    %ebx
8010434d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104350:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104353:	83 c4 10             	add    $0x10,%esp
80104356:	5b                   	pop    %ebx
80104357:	5d                   	pop    %ebp
80104358:	c3                   	ret    

80104359 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104359:	55                   	push   %ebp
8010435a:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010435c:	fb                   	sti    
}
8010435d:	5d                   	pop    %ebp
8010435e:	c3                   	ret    

8010435f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010435f:	55                   	push   %ebp
80104360:	89 e5                	mov    %esp,%ebp
80104362:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104365:	c7 44 24 04 39 8a 10 	movl   $0x80108a39,0x4(%esp)
8010436c:	80 
8010436d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104374:	e8 81 0d 00 00       	call   801050fa <initlock>
}
80104379:	c9                   	leave  
8010437a:	c3                   	ret    

8010437b <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010437b:	55                   	push   %ebp
8010437c:	89 e5                	mov    %esp,%ebp
8010437e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104381:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104388:	e8 8e 0d 00 00       	call   8010511b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010438d:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104394:	eb 11                	jmp    801043a7 <allocproc+0x2c>
    if(p->state == UNUSED)
80104396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104399:	8b 40 0c             	mov    0xc(%eax),%eax
8010439c:	85 c0                	test   %eax,%eax
8010439e:	74 26                	je     801043c6 <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a0:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801043a7:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
801043ae:	72 e6                	jb     80104396 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801043b0:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801043b7:	e8 c1 0d 00 00       	call   8010517d <release>
  return 0;
801043bc:	b8 00 00 00 00       	mov    $0x0,%eax
801043c1:	e9 b5 00 00 00       	jmp    8010447b <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801043c6:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ca:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043d1:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801043d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043d9:	89 42 10             	mov    %eax,0x10(%edx)
801043dc:	83 c0 01             	add    $0x1,%eax
801043df:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
801043e4:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801043eb:	e8 8d 0d 00 00       	call   8010517d <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043f0:	e8 5e ea ff ff       	call   80102e53 <kalloc>
801043f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043f8:	89 42 08             	mov    %eax,0x8(%edx)
801043fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043fe:	8b 40 08             	mov    0x8(%eax),%eax
80104401:	85 c0                	test   %eax,%eax
80104403:	75 11                	jne    80104416 <allocproc+0x9b>
    p->state = UNUSED;
80104405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104408:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010440f:	b8 00 00 00 00       	mov    $0x0,%eax
80104414:	eb 65                	jmp    8010447b <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
80104416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104419:	8b 40 08             	mov    0x8(%eax),%eax
8010441c:	05 00 10 00 00       	add    $0x1000,%eax
80104421:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104424:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010442e:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104431:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104435:	ba 20 68 10 80       	mov    $0x80106820,%edx
8010443a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010443d:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010443f:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104446:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104449:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010444c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104452:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104459:	00 
8010445a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104461:	00 
80104462:	89 04 24             	mov    %eax,(%esp)
80104465:	e8 00 0f 00 00       	call   8010536a <memset>
  p->context->eip = (uint)forkret;
8010446a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104470:	ba 09 4e 10 80       	mov    $0x80104e09,%edx
80104475:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104478:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010447b:	c9                   	leave  
8010447c:	c3                   	ret    

8010447d <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010447d:	55                   	push   %ebp
8010447e:	89 e5                	mov    %esp,%ebp
80104480:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104483:	e8 f3 fe ff ff       	call   8010437b <allocproc>
80104488:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010448b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448e:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm(kalloc)) == 0)
80104493:	c7 04 24 53 2e 10 80 	movl   $0x80102e53,(%esp)
8010449a:	e8 7e 3a 00 00       	call   80107f1d <setupkvm>
8010449f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044a2:	89 42 04             	mov    %eax,0x4(%edx)
801044a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a8:	8b 40 04             	mov    0x4(%eax),%eax
801044ab:	85 c0                	test   %eax,%eax
801044ad:	75 0c                	jne    801044bb <userinit+0x3e>
    panic("userinit: out of memory?");
801044af:	c7 04 24 40 8a 10 80 	movl   $0x80108a40,(%esp)
801044b6:	e8 82 c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044bb:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c3:	8b 40 04             	mov    0x4(%eax),%eax
801044c6:	89 54 24 08          	mov    %edx,0x8(%esp)
801044ca:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801044d1:	80 
801044d2:	89 04 24             	mov    %eax,(%esp)
801044d5:	e8 9b 3c 00 00       	call   80108175 <inituvm>
  p->sz = PGSIZE;
801044da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044dd:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e6:	8b 40 18             	mov    0x18(%eax),%eax
801044e9:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044f0:	00 
801044f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044f8:	00 
801044f9:	89 04 24             	mov    %eax,(%esp)
801044fc:	e8 69 0e 00 00       	call   8010536a <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104504:	8b 40 18             	mov    0x18(%eax),%eax
80104507:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010450d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104510:	8b 40 18             	mov    0x18(%eax),%eax
80104513:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451c:	8b 40 18             	mov    0x18(%eax),%eax
8010451f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104522:	8b 52 18             	mov    0x18(%edx),%edx
80104525:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104529:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010452d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104530:	8b 40 18             	mov    0x18(%eax),%eax
80104533:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104536:	8b 52 18             	mov    0x18(%edx),%edx
80104539:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010453d:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104544:	8b 40 18             	mov    0x18(%eax),%eax
80104547:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010454e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104551:	8b 40 18             	mov    0x18(%eax),%eax
80104554:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010455b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455e:	8b 40 18             	mov    0x18(%eax),%eax
80104561:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456b:	83 c0 6c             	add    $0x6c,%eax
8010456e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104575:	00 
80104576:	c7 44 24 04 59 8a 10 	movl   $0x80108a59,0x4(%esp)
8010457d:	80 
8010457e:	89 04 24             	mov    %eax,(%esp)
80104581:	e8 14 10 00 00       	call   8010559a <safestrcpy>
  p->cwd = namei("/");
80104586:	c7 04 24 62 8a 10 80 	movl   $0x80108a62,(%esp)
8010458d:	e8 cc e1 ff ff       	call   8010275e <namei>
80104592:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104595:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045a2:	c9                   	leave  
801045a3:	c3                   	ret    

801045a4 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045a4:	55                   	push   %ebp
801045a5:	89 e5                	mov    %esp,%ebp
801045a7:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045b0:	8b 00                	mov    (%eax),%eax
801045b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045b5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045b9:	7e 34                	jle    801045ef <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045bb:	8b 45 08             	mov    0x8(%ebp),%eax
801045be:	89 c2                	mov    %eax,%edx
801045c0:	03 55 f4             	add    -0xc(%ebp),%edx
801045c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045c9:	8b 40 04             	mov    0x4(%eax),%eax
801045cc:	89 54 24 08          	mov    %edx,0x8(%esp)
801045d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801045d7:	89 04 24             	mov    %eax,(%esp)
801045da:	e8 10 3d 00 00       	call   801082ef <allocuvm>
801045df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045e6:	75 41                	jne    80104629 <growproc+0x85>
      return -1;
801045e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ed:	eb 58                	jmp    80104647 <growproc+0xa3>
  } else if(n < 0){
801045ef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045f3:	79 34                	jns    80104629 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801045f5:	8b 45 08             	mov    0x8(%ebp),%eax
801045f8:	89 c2                	mov    %eax,%edx
801045fa:	03 55 f4             	add    -0xc(%ebp),%edx
801045fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104603:	8b 40 04             	mov    0x4(%eax),%eax
80104606:	89 54 24 08          	mov    %edx,0x8(%esp)
8010460a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010460d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104611:	89 04 24             	mov    %eax,(%esp)
80104614:	e8 b0 3d 00 00       	call   801083c9 <deallocuvm>
80104619:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010461c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104620:	75 07                	jne    80104629 <growproc+0x85>
      return -1;
80104622:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104627:	eb 1e                	jmp    80104647 <growproc+0xa3>
  }
  proc->sz = sz;
80104629:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010462f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104632:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104634:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010463a:	89 04 24             	mov    %eax,(%esp)
8010463d:	e8 cc 39 00 00       	call   8010800e <switchuvm>
  return 0;
80104642:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104647:	c9                   	leave  
80104648:	c3                   	ret    

80104649 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104649:	55                   	push   %ebp
8010464a:	89 e5                	mov    %esp,%ebp
8010464c:	57                   	push   %edi
8010464d:	56                   	push   %esi
8010464e:	53                   	push   %ebx
8010464f:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104652:	e8 24 fd ff ff       	call   8010437b <allocproc>
80104657:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010465a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010465e:	75 0a                	jne    8010466a <fork+0x21>
    return -1;
80104660:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104665:	e9 6c 01 00 00       	jmp    801047d6 <fork+0x18d>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010466a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104670:	8b 10                	mov    (%eax),%edx
80104672:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104678:	8b 40 04             	mov    0x4(%eax),%eax
8010467b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010467f:	89 04 24             	mov    %eax,(%esp)
80104682:	e8 d2 3e 00 00       	call   80108559 <copyuvm>
80104687:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010468a:	89 42 04             	mov    %eax,0x4(%edx)
8010468d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104690:	8b 40 04             	mov    0x4(%eax),%eax
80104693:	85 c0                	test   %eax,%eax
80104695:	75 2c                	jne    801046c3 <fork+0x7a>
    kfree(np->kstack);
80104697:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010469a:	8b 40 08             	mov    0x8(%eax),%eax
8010469d:	89 04 24             	mov    %eax,(%esp)
801046a0:	e8 15 e7 ff ff       	call   80102dba <kfree>
    np->kstack = 0;
801046a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046be:	e9 13 01 00 00       	jmp    801047d6 <fork+0x18d>
  }
  np->sz = proc->sz;
801046c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046c9:	8b 10                	mov    (%eax),%edx
801046cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ce:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046d0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046da:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e0:	8b 50 18             	mov    0x18(%eax),%edx
801046e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e9:	8b 40 18             	mov    0x18(%eax),%eax
801046ec:	89 c3                	mov    %eax,%ebx
801046ee:	b8 13 00 00 00       	mov    $0x13,%eax
801046f3:	89 d7                	mov    %edx,%edi
801046f5:	89 de                	mov    %ebx,%esi
801046f7:	89 c1                	mov    %eax,%ecx
801046f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046fe:	8b 40 18             	mov    0x18(%eax),%eax
80104701:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104708:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010470f:	eb 3d                	jmp    8010474e <fork+0x105>
    if(proc->ofile[i])
80104711:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104717:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010471a:	83 c2 08             	add    $0x8,%edx
8010471d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104721:	85 c0                	test   %eax,%eax
80104723:	74 25                	je     8010474a <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104725:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010472b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010472e:	83 c2 08             	add    $0x8,%edx
80104731:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104735:	89 04 24             	mov    %eax,(%esp)
80104738:	e8 93 cb ff ff       	call   801012d0 <filedup>
8010473d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104740:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104743:	83 c1 08             	add    $0x8,%ecx
80104746:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010474a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010474e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104752:	7e bd                	jle    80104711 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104754:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010475a:	8b 40 68             	mov    0x68(%eax),%eax
8010475d:	89 04 24             	mov    %eax,(%esp)
80104760:	e8 25 d4 ff ff       	call   80101b8a <idup>
80104765:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104768:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
8010476b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010476e:	8b 40 10             	mov    0x10(%eax),%eax
80104771:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
80104774:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104777:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010477e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104784:	8d 50 6c             	lea    0x6c(%eax),%edx
80104787:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478a:	83 c0 6c             	add    $0x6c,%eax
8010478d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104794:	00 
80104795:	89 54 24 04          	mov    %edx,0x4(%esp)
80104799:	89 04 24             	mov    %eax,(%esp)
8010479c:	e8 f9 0d 00 00       	call   8010559a <safestrcpy>
  acquire(&tickslock);
801047a1:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801047a8:	e8 6e 09 00 00       	call   8010511b <acquire>
  np->ctime = ticks;
801047ad:	a1 c0 29 11 80       	mov    0x801129c0,%eax
801047b2:	89 c2                	mov    %eax,%edx
801047b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b7:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&tickslock);
801047ba:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801047c1:	e8 b7 09 00 00       	call   8010517d <release>
  np->rtime = 0;
801047c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c9:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
801047d0:	00 00 00 
  return pid;
801047d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047d6:	83 c4 2c             	add    $0x2c,%esp
801047d9:	5b                   	pop    %ebx
801047da:	5e                   	pop    %esi
801047db:	5f                   	pop    %edi
801047dc:	5d                   	pop    %ebp
801047dd:	c3                   	ret    

801047de <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047de:	55                   	push   %ebp
801047df:	89 e5                	mov    %esp,%ebp
801047e1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801047e4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047eb:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801047f0:	39 c2                	cmp    %eax,%edx
801047f2:	75 0c                	jne    80104800 <exit+0x22>
    panic("init exiting");
801047f4:	c7 04 24 64 8a 10 80 	movl   $0x80108a64,(%esp)
801047fb:	e8 3d bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104800:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104807:	eb 44                	jmp    8010484d <exit+0x6f>
    if(proc->ofile[fd]){
80104809:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104812:	83 c2 08             	add    $0x8,%edx
80104815:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104819:	85 c0                	test   %eax,%eax
8010481b:	74 2c                	je     80104849 <exit+0x6b>
      fileclose(proc->ofile[fd]);
8010481d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104823:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104826:	83 c2 08             	add    $0x8,%edx
80104829:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010482d:	89 04 24             	mov    %eax,(%esp)
80104830:	e8 e3 ca ff ff       	call   80101318 <fileclose>
      proc->ofile[fd] = 0;
80104835:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010483e:	83 c2 08             	add    $0x8,%edx
80104841:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104848:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104849:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010484d:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104851:	7e b6                	jle    80104809 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
80104853:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104859:	8b 40 68             	mov    0x68(%eax),%eax
8010485c:	89 04 24             	mov    %eax,(%esp)
8010485f:	e8 0b d5 ff ff       	call   80101d6f <iput>
  proc->cwd = 0;
80104864:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104871:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104878:	e8 9e 08 00 00       	call   8010511b <acquire>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010487d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104883:	8b 40 14             	mov    0x14(%eax),%eax
80104886:	89 04 24             	mov    %eax,(%esp)
80104889:	e8 42 06 00 00       	call   80104ed0 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010488e:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104895:	eb 3b                	jmp    801048d2 <exit+0xf4>
    if(p->parent == proc){
80104897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489a:	8b 50 14             	mov    0x14(%eax),%edx
8010489d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a3:	39 c2                	cmp    %eax,%edx
801048a5:	75 24                	jne    801048cb <exit+0xed>
      p->parent = initproc;
801048a7:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801048ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b0:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b6:	8b 40 0c             	mov    0xc(%eax),%eax
801048b9:	83 f8 05             	cmp    $0x5,%eax
801048bc:	75 0d                	jne    801048cb <exit+0xed>
        wakeup1(initproc);
801048be:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048c3:	89 04 24             	mov    %eax,(%esp)
801048c6:	e8 05 06 00 00       	call   80104ed0 <wakeup1>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048cb:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801048d2:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
801048d9:	72 bc                	jb     80104897 <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  acquire(&tickslock);
801048db:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801048e2:	e8 34 08 00 00       	call   8010511b <acquire>
  proc->etime = ticks;
801048e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ed:	8b 15 c0 29 11 80    	mov    0x801129c0,%edx
801048f3:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  release(&tickslock);
801048f9:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80104900:	e8 78 08 00 00       	call   8010517d <release>
  proc->state = ZOMBIE;
80104905:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010490b:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104912:	e8 0e 04 00 00       	call   80104d25 <sched>
  panic("zombie exit");
80104917:	c7 04 24 71 8a 10 80 	movl   $0x80108a71,(%esp)
8010491e:	e8 1a bc ff ff       	call   8010053d <panic>

80104923 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104923:	55                   	push   %ebp
80104924:	89 e5                	mov    %esp,%ebp
80104926:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104929:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104930:	e8 e6 07 00 00       	call   8010511b <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104935:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010493c:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104943:	e9 9d 00 00 00       	jmp    801049e5 <wait+0xc2>
      if(p->parent != proc)
80104948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494b:	8b 50 14             	mov    0x14(%eax),%edx
8010494e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104954:	39 c2                	cmp    %eax,%edx
80104956:	0f 85 81 00 00 00    	jne    801049dd <wait+0xba>
        continue;
      havekids = 1;
8010495c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104966:	8b 40 0c             	mov    0xc(%eax),%eax
80104969:	83 f8 05             	cmp    $0x5,%eax
8010496c:	75 70                	jne    801049de <wait+0xbb>
        // Found one.
        pid = p->pid;
8010496e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104971:	8b 40 10             	mov    0x10(%eax),%eax
80104974:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497a:	8b 40 08             	mov    0x8(%eax),%eax
8010497d:	89 04 24             	mov    %eax,(%esp)
80104980:	e8 35 e4 ff ff       	call   80102dba <kfree>
        p->kstack = 0;
80104985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104988:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010498f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104992:	8b 40 04             	mov    0x4(%eax),%eax
80104995:	89 04 24             	mov    %eax,(%esp)
80104998:	e8 e8 3a 00 00       	call   80108485 <freevm>
        p->state = UNUSED;
8010499d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801049a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049aa:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049be:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c5:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801049cc:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801049d3:	e8 a5 07 00 00       	call   8010517d <release>
        return pid;
801049d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049db:	eb 56                	jmp    80104a33 <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801049dd:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049de:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801049e5:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
801049ec:	0f 82 56 ff ff ff    	jb     80104948 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049f6:	74 0d                	je     80104a05 <wait+0xe2>
801049f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049fe:	8b 40 24             	mov    0x24(%eax),%eax
80104a01:	85 c0                	test   %eax,%eax
80104a03:	74 13                	je     80104a18 <wait+0xf5>
      release(&ptable.lock);
80104a05:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104a0c:	e8 6c 07 00 00       	call   8010517d <release>
      return -1;
80104a11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a16:	eb 1b                	jmp    80104a33 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104a18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a1e:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104a25:	80 
80104a26:	89 04 24             	mov    %eax,(%esp)
80104a29:	e8 07 04 00 00       	call   80104e35 <sleep>
  }
80104a2e:	e9 02 ff ff ff       	jmp    80104935 <wait+0x12>
}
80104a33:	c9                   	leave  
80104a34:	c3                   	ret    

80104a35 <wait2>:

int
wait2(int *wtime, int *rtime)
{
80104a35:	55                   	push   %ebp
80104a36:	89 e5                	mov    %esp,%ebp
80104a38:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a3b:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104a42:	e8 d4 06 00 00       	call   8010511b <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a47:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a4e:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104a55:	e9 d3 00 00 00       	jmp    80104b2d <wait2+0xf8>
      if(p->parent != proc)
80104a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5d:	8b 50 14             	mov    0x14(%eax),%edx
80104a60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a66:	39 c2                	cmp    %eax,%edx
80104a68:	0f 85 b7 00 00 00    	jne    80104b25 <wait2+0xf0>
        continue;
      havekids = 1;
80104a6e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a78:	8b 40 0c             	mov    0xc(%eax),%eax
80104a7b:	83 f8 05             	cmp    $0x5,%eax
80104a7e:	0f 85 a2 00 00 00    	jne    80104b26 <wait2+0xf1>
	*rtime = proc->rtime;
80104a84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a8a:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104a90:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a93:	89 10                	mov    %edx,(%eax)
	*wtime = p->etime - p->ctime - p->rtime;
80104a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a98:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa1:	8b 40 7c             	mov    0x7c(%eax),%eax
80104aa4:	29 c2                	sub    %eax,%edx
80104aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa9:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104aaf:	29 c2                	sub    %eax,%edx
80104ab1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab4:	89 10                	mov    %edx,(%eax)
	// Found one.
        pid = p->pid;
80104ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab9:	8b 40 10             	mov    0x10(%eax),%eax
80104abc:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac2:	8b 40 08             	mov    0x8(%eax),%eax
80104ac5:	89 04 24             	mov    %eax,(%esp)
80104ac8:	e8 ed e2 ff ff       	call   80102dba <kfree>
        p->kstack = 0;
80104acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ada:	8b 40 04             	mov    0x4(%eax),%eax
80104add:	89 04 24             	mov    %eax,(%esp)
80104ae0:	e8 a0 39 00 00       	call   80108485 <freevm>
        p->state = UNUSED;
80104ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b06:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104b14:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104b1b:	e8 5d 06 00 00       	call   8010517d <release>
        return pid;
80104b20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b23:	eb 56                	jmp    80104b7b <wait2+0x146>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104b25:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b26:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104b2d:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
80104b34:	0f 82 20 ff ff ff    	jb     80104a5a <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b3e:	74 0d                	je     80104b4d <wait2+0x118>
80104b40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b46:	8b 40 24             	mov    0x24(%eax),%eax
80104b49:	85 c0                	test   %eax,%eax
80104b4b:	74 13                	je     80104b60 <wait2+0x12b>
      release(&ptable.lock);
80104b4d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104b54:	e8 24 06 00 00       	call   8010517d <release>
      return -1;
80104b59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b5e:	eb 1b                	jmp    80104b7b <wait2+0x146>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b66:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104b6d:	80 
80104b6e:	89 04 24             	mov    %eax,(%esp)
80104b71:	e8 bf 02 00 00       	call   80104e35 <sleep>
  }
80104b76:	e9 cc fe ff ff       	jmp    80104a47 <wait2+0x12>
  
  
  return proc->pid;
}
80104b7b:	c9                   	leave  
80104b7c:	c3                   	ret    

80104b7d <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104b7d:	55                   	push   %ebp
80104b7e:	89 e5                	mov    %esp,%ebp
80104b80:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104b83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b89:	8b 40 18             	mov    0x18(%eax),%eax
80104b8c:	8b 40 44             	mov    0x44(%eax),%eax
80104b8f:	89 c2                	mov    %eax,%edx
80104b91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b97:	8b 40 04             	mov    0x4(%eax),%eax
80104b9a:	89 54 24 04          	mov    %edx,0x4(%esp)
80104b9e:	89 04 24             	mov    %eax,(%esp)
80104ba1:	e8 c4 3a 00 00       	call   8010866a <uva2ka>
80104ba6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104ba9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104baf:	8b 40 18             	mov    0x18(%eax),%eax
80104bb2:	8b 40 44             	mov    0x44(%eax),%eax
80104bb5:	25 ff 0f 00 00       	and    $0xfff,%eax
80104bba:	85 c0                	test   %eax,%eax
80104bbc:	75 0c                	jne    80104bca <register_handler+0x4d>
    panic("esp_offset == 0");
80104bbe:	c7 04 24 7d 8a 10 80 	movl   $0x80108a7d,(%esp)
80104bc5:	e8 73 b9 ff ff       	call   8010053d <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
80104bca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bd0:	8b 40 18             	mov    0x18(%eax),%eax
80104bd3:	8b 40 44             	mov    0x44(%eax),%eax
80104bd6:	83 e8 04             	sub    $0x4,%eax
80104bd9:	25 ff 0f 00 00       	and    $0xfff,%eax
80104bde:	03 45 f4             	add    -0xc(%ebp),%eax
          = proc->tf->eip;
80104be1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104be8:	8b 52 18             	mov    0x18(%edx),%edx
80104beb:	8b 52 38             	mov    0x38(%edx),%edx
80104bee:	89 10                	mov    %edx,(%eax)
  proc->tf->esp -= 4;
80104bf0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf6:	8b 40 18             	mov    0x18(%eax),%eax
80104bf9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104c00:	8b 52 18             	mov    0x18(%edx),%edx
80104c03:	8b 52 44             	mov    0x44(%edx),%edx
80104c06:	83 ea 04             	sub    $0x4,%edx
80104c09:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104c0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c12:	8b 40 18             	mov    0x18(%eax),%eax
80104c15:	8b 55 08             	mov    0x8(%ebp),%edx
80104c18:	89 50 38             	mov    %edx,0x38(%eax)
}
80104c1b:	c9                   	leave  
80104c1c:	c3                   	ret    

80104c1d <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c1d:	55                   	push   %ebp
80104c1e:	89 e5                	mov    %esp,%ebp
80104c20:	53                   	push   %ebx
80104c21:	83 ec 24             	sub    $0x24,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c24:	e8 30 f7 ff ff       	call   80104359 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c29:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104c30:	e8 e6 04 00 00       	call   8010511b <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c35:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104c3c:	e9 c6 00 00 00       	jmp    80104d07 <scheduler+0xea>
      if(p->state != RUNNABLE)
80104c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c44:	8b 40 0c             	mov    0xc(%eax),%eax
80104c47:	83 f8 03             	cmp    $0x3,%eax
80104c4a:	0f 85 af 00 00 00    	jne    80104cff <scheduler+0xe2>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c53:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      //int time = 0;
      acquire(&tickslock);
80104c59:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80104c60:	e8 b6 04 00 00       	call   8010511b <acquire>
      int startTime = ticks;
80104c65:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80104c6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      release(&tickslock);
80104c6d:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80104c74:	e8 04 05 00 00       	call   8010517d <release>
      
      switchuvm(p);
80104c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7c:	89 04 24             	mov    %eax,(%esp)
80104c7f:	e8 8a 33 00 00       	call   8010800e <switchuvm>
      p->state = RUNNING;
80104c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c87:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104c8e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c94:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c97:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c9e:	83 c2 04             	add    $0x4,%edx
80104ca1:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ca5:	89 14 24             	mov    %edx,(%esp)
80104ca8:	e8 63 09 00 00       	call   80105610 <swtch>
      switchkvm();
80104cad:	e8 3f 33 00 00       	call   80107ff1 <switchkvm>
      
      acquire(&tickslock);
80104cb2:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80104cb9:	e8 5d 04 00 00       	call   8010511b <acquire>
      int endTime = ticks;
80104cbe:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80104cc3:	89 45 ec             	mov    %eax,-0x14(%ebp)
      release(&tickslock);
80104cc6:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80104ccd:	e8 ab 04 00 00       	call   8010517d <release>
      p->rtime = p->rtime + (endTime-startTime);
80104cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd5:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104cdb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104cde:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80104ce1:	89 cb                	mov    %ecx,%ebx
80104ce3:	29 d3                	sub    %edx,%ebx
80104ce5:	89 da                	mov    %ebx,%edx
80104ce7:	01 c2                	add    %eax,%edx
80104ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cec:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104cf2:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104cf9:	00 00 00 00 
80104cfd:	eb 01                	jmp    80104d00 <scheduler+0xe3>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104cff:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d00:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104d07:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
80104d0e:	0f 82 2d ff ff ff    	jb     80104c41 <scheduler+0x24>
      p->rtime = p->rtime + (endTime-startTime);
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104d14:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d1b:	e8 5d 04 00 00       	call   8010517d <release>

  }
80104d20:	e9 ff fe ff ff       	jmp    80104c24 <scheduler+0x7>

80104d25 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104d25:	55                   	push   %ebp
80104d26:	89 e5                	mov    %esp,%ebp
80104d28:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104d2b:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d32:	e8 02 05 00 00       	call   80105239 <holding>
80104d37:	85 c0                	test   %eax,%eax
80104d39:	75 0c                	jne    80104d47 <sched+0x22>
    panic("sched ptable.lock");
80104d3b:	c7 04 24 8d 8a 10 80 	movl   $0x80108a8d,(%esp)
80104d42:	e8 f6 b7 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104d47:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d4d:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d53:	83 f8 01             	cmp    $0x1,%eax
80104d56:	74 0c                	je     80104d64 <sched+0x3f>
    panic("sched locks");
80104d58:	c7 04 24 9f 8a 10 80 	movl   $0x80108a9f,(%esp)
80104d5f:	e8 d9 b7 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104d64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d6a:	8b 40 0c             	mov    0xc(%eax),%eax
80104d6d:	83 f8 04             	cmp    $0x4,%eax
80104d70:	75 0c                	jne    80104d7e <sched+0x59>
    panic("sched running");
80104d72:	c7 04 24 ab 8a 10 80 	movl   $0x80108aab,(%esp)
80104d79:	e8 bf b7 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104d7e:	e8 c1 f5 ff ff       	call   80104344 <readeflags>
80104d83:	25 00 02 00 00       	and    $0x200,%eax
80104d88:	85 c0                	test   %eax,%eax
80104d8a:	74 0c                	je     80104d98 <sched+0x73>
    panic("sched interruptible");
80104d8c:	c7 04 24 b9 8a 10 80 	movl   $0x80108ab9,(%esp)
80104d93:	e8 a5 b7 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104d98:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d9e:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104da4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104da7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104dad:	8b 40 04             	mov    0x4(%eax),%eax
80104db0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104db7:	83 c2 1c             	add    $0x1c,%edx
80104dba:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dbe:	89 14 24             	mov    %edx,(%esp)
80104dc1:	e8 4a 08 00 00       	call   80105610 <swtch>
  cpu->intena = intena;
80104dc6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104dcc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dcf:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104dd5:	c9                   	leave  
80104dd6:	c3                   	ret    

80104dd7 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104dd7:	55                   	push   %ebp
80104dd8:	89 e5                	mov    %esp,%ebp
80104dda:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104ddd:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104de4:	e8 32 03 00 00       	call   8010511b <acquire>
  proc->state = RUNNABLE;
80104de9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104def:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104df6:	e8 2a ff ff ff       	call   80104d25 <sched>
  release(&ptable.lock);
80104dfb:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e02:	e8 76 03 00 00       	call   8010517d <release>
}
80104e07:	c9                   	leave  
80104e08:	c3                   	ret    

80104e09 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e09:	55                   	push   %ebp
80104e0a:	89 e5                	mov    %esp,%ebp
80104e0c:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e0f:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e16:	e8 62 03 00 00       	call   8010517d <release>

  if (first) {
80104e1b:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104e20:	85 c0                	test   %eax,%eax
80104e22:	74 0f                	je     80104e33 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104e24:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104e2b:	00 00 00 
    initlog();
80104e2e:	e8 31 e5 ff ff       	call   80103364 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104e33:	c9                   	leave  
80104e34:	c3                   	ret    

80104e35 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e35:	55                   	push   %ebp
80104e36:	89 e5                	mov    %esp,%ebp
80104e38:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104e3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e41:	85 c0                	test   %eax,%eax
80104e43:	75 0c                	jne    80104e51 <sleep+0x1c>
    panic("sleep");
80104e45:	c7 04 24 cd 8a 10 80 	movl   $0x80108acd,(%esp)
80104e4c:	e8 ec b6 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104e51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e55:	75 0c                	jne    80104e63 <sleep+0x2e>
    panic("sleep without lk");
80104e57:	c7 04 24 d3 8a 10 80 	movl   $0x80108ad3,(%esp)
80104e5e:	e8 da b6 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e63:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104e6a:	74 17                	je     80104e83 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e6c:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e73:	e8 a3 02 00 00       	call   8010511b <acquire>
    release(lk);
80104e78:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e7b:	89 04 24             	mov    %eax,(%esp)
80104e7e:	e8 fa 02 00 00       	call   8010517d <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104e83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e89:	8b 55 08             	mov    0x8(%ebp),%edx
80104e8c:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104e8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e95:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104e9c:	e8 84 fe ff ff       	call   80104d25 <sched>

  // Tidy up.
  proc->chan = 0;
80104ea1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ea7:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104eae:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104eb5:	74 17                	je     80104ece <sleep+0x99>
    release(&ptable.lock);
80104eb7:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ebe:	e8 ba 02 00 00       	call   8010517d <release>
    acquire(lk);
80104ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ec6:	89 04 24             	mov    %eax,(%esp)
80104ec9:	e8 4d 02 00 00       	call   8010511b <acquire>
  }
}
80104ece:	c9                   	leave  
80104ecf:	c3                   	ret    

80104ed0 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ed0:	55                   	push   %ebp
80104ed1:	89 e5                	mov    %esp,%ebp
80104ed3:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ed6:	c7 45 fc 74 ff 10 80 	movl   $0x8010ff74,-0x4(%ebp)
80104edd:	eb 27                	jmp    80104f06 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104edf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ee2:	8b 40 0c             	mov    0xc(%eax),%eax
80104ee5:	83 f8 02             	cmp    $0x2,%eax
80104ee8:	75 15                	jne    80104eff <wakeup1+0x2f>
80104eea:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eed:	8b 40 20             	mov    0x20(%eax),%eax
80104ef0:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ef3:	75 0a                	jne    80104eff <wakeup1+0x2f>
      p->state = RUNNABLE;
80104ef5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ef8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104eff:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80104f06:	81 7d fc 74 21 11 80 	cmpl   $0x80112174,-0x4(%ebp)
80104f0d:	72 d0                	jb     80104edf <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104f0f:	c9                   	leave  
80104f10:	c3                   	ret    

80104f11 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f11:	55                   	push   %ebp
80104f12:	89 e5                	mov    %esp,%ebp
80104f14:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104f17:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f1e:	e8 f8 01 00 00       	call   8010511b <acquire>
  wakeup1(chan);
80104f23:	8b 45 08             	mov    0x8(%ebp),%eax
80104f26:	89 04 24             	mov    %eax,(%esp)
80104f29:	e8 a2 ff ff ff       	call   80104ed0 <wakeup1>
  release(&ptable.lock);
80104f2e:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f35:	e8 43 02 00 00       	call   8010517d <release>
}
80104f3a:	c9                   	leave  
80104f3b:	c3                   	ret    

80104f3c <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f3c:	55                   	push   %ebp
80104f3d:	89 e5                	mov    %esp,%ebp
80104f3f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f42:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f49:	e8 cd 01 00 00       	call   8010511b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f4e:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104f55:	eb 44                	jmp    80104f9b <kill+0x5f>
    if(p->pid == pid){
80104f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f5a:	8b 40 10             	mov    0x10(%eax),%eax
80104f5d:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f60:	75 32                	jne    80104f94 <kill+0x58>
      p->killed = 1;
80104f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f65:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f6f:	8b 40 0c             	mov    0xc(%eax),%eax
80104f72:	83 f8 02             	cmp    $0x2,%eax
80104f75:	75 0a                	jne    80104f81 <kill+0x45>
        p->state = RUNNABLE;
80104f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f7a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f81:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f88:	e8 f0 01 00 00       	call   8010517d <release>
      return 0;
80104f8d:	b8 00 00 00 00       	mov    $0x0,%eax
80104f92:	eb 21                	jmp    80104fb5 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f94:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104f9b:	81 7d f4 74 21 11 80 	cmpl   $0x80112174,-0xc(%ebp)
80104fa2:	72 b3                	jb     80104f57 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104fa4:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104fab:	e8 cd 01 00 00       	call   8010517d <release>
  return -1;
80104fb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fb5:	c9                   	leave  
80104fb6:	c3                   	ret    

80104fb7 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104fb7:	55                   	push   %ebp
80104fb8:	89 e5                	mov    %esp,%ebp
80104fba:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fbd:	c7 45 f0 74 ff 10 80 	movl   $0x8010ff74,-0x10(%ebp)
80104fc4:	e9 db 00 00 00       	jmp    801050a4 <procdump+0xed>
    if(p->state == UNUSED)
80104fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fcc:	8b 40 0c             	mov    0xc(%eax),%eax
80104fcf:	85 c0                	test   %eax,%eax
80104fd1:	0f 84 c5 00 00 00    	je     8010509c <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fda:	8b 40 0c             	mov    0xc(%eax),%eax
80104fdd:	83 f8 05             	cmp    $0x5,%eax
80104fe0:	77 23                	ja     80105005 <procdump+0x4e>
80104fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe5:	8b 40 0c             	mov    0xc(%eax),%eax
80104fe8:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104fef:	85 c0                	test   %eax,%eax
80104ff1:	74 12                	je     80105005 <procdump+0x4e>
      state = states[p->state];
80104ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff6:	8b 40 0c             	mov    0xc(%eax),%eax
80104ff9:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80105000:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105003:	eb 07                	jmp    8010500c <procdump+0x55>
    else
      state = "???";
80105005:	c7 45 ec e4 8a 10 80 	movl   $0x80108ae4,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010500c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010500f:	8d 50 6c             	lea    0x6c(%eax),%edx
80105012:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105015:	8b 40 10             	mov    0x10(%eax),%eax
80105018:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010501c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010501f:	89 54 24 08          	mov    %edx,0x8(%esp)
80105023:	89 44 24 04          	mov    %eax,0x4(%esp)
80105027:	c7 04 24 e8 8a 10 80 	movl   $0x80108ae8,(%esp)
8010502e:	e8 6e b3 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80105033:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105036:	8b 40 0c             	mov    0xc(%eax),%eax
80105039:	83 f8 02             	cmp    $0x2,%eax
8010503c:	75 50                	jne    8010508e <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010503e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105041:	8b 40 1c             	mov    0x1c(%eax),%eax
80105044:	8b 40 0c             	mov    0xc(%eax),%eax
80105047:	83 c0 08             	add    $0x8,%eax
8010504a:	8d 55 c4             	lea    -0x3c(%ebp),%edx
8010504d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105051:	89 04 24             	mov    %eax,(%esp)
80105054:	e8 73 01 00 00       	call   801051cc <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80105059:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105060:	eb 1b                	jmp    8010507d <procdump+0xc6>
        cprintf(" %p", pc[i]);
80105062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105065:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105069:	89 44 24 04          	mov    %eax,0x4(%esp)
8010506d:	c7 04 24 f1 8a 10 80 	movl   $0x80108af1,(%esp)
80105074:	e8 28 b3 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105079:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010507d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105081:	7f 0b                	jg     8010508e <procdump+0xd7>
80105083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105086:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010508a:	85 c0                	test   %eax,%eax
8010508c:	75 d4                	jne    80105062 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010508e:	c7 04 24 f5 8a 10 80 	movl   $0x80108af5,(%esp)
80105095:	e8 07 b3 ff ff       	call   801003a1 <cprintf>
8010509a:	eb 01                	jmp    8010509d <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
8010509c:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010509d:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
801050a4:	81 7d f0 74 21 11 80 	cmpl   $0x80112174,-0x10(%ebp)
801050ab:	0f 82 18 ff ff ff    	jb     80104fc9 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801050b1:	c9                   	leave  
801050b2:	c3                   	ret    
	...

801050b4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801050b4:	55                   	push   %ebp
801050b5:	89 e5                	mov    %esp,%ebp
801050b7:	53                   	push   %ebx
801050b8:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801050bb:	9c                   	pushf  
801050bc:	5b                   	pop    %ebx
801050bd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
801050c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801050c3:	83 c4 10             	add    $0x10,%esp
801050c6:	5b                   	pop    %ebx
801050c7:	5d                   	pop    %ebp
801050c8:	c3                   	ret    

801050c9 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801050c9:	55                   	push   %ebp
801050ca:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801050cc:	fa                   	cli    
}
801050cd:	5d                   	pop    %ebp
801050ce:	c3                   	ret    

801050cf <sti>:

static inline void
sti(void)
{
801050cf:	55                   	push   %ebp
801050d0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801050d2:	fb                   	sti    
}
801050d3:	5d                   	pop    %ebp
801050d4:	c3                   	ret    

801050d5 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801050d5:	55                   	push   %ebp
801050d6:	89 e5                	mov    %esp,%ebp
801050d8:	53                   	push   %ebx
801050d9:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
801050dc:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801050df:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
801050e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801050e5:	89 c3                	mov    %eax,%ebx
801050e7:	89 d8                	mov    %ebx,%eax
801050e9:	f0 87 02             	lock xchg %eax,(%edx)
801050ec:	89 c3                	mov    %eax,%ebx
801050ee:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801050f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801050f4:	83 c4 10             	add    $0x10,%esp
801050f7:	5b                   	pop    %ebx
801050f8:	5d                   	pop    %ebp
801050f9:	c3                   	ret    

801050fa <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801050fa:	55                   	push   %ebp
801050fb:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801050fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105100:	8b 55 0c             	mov    0xc(%ebp),%edx
80105103:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105106:	8b 45 08             	mov    0x8(%ebp),%eax
80105109:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010510f:	8b 45 08             	mov    0x8(%ebp),%eax
80105112:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105119:	5d                   	pop    %ebp
8010511a:	c3                   	ret    

8010511b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010511b:	55                   	push   %ebp
8010511c:	89 e5                	mov    %esp,%ebp
8010511e:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105121:	e8 3d 01 00 00       	call   80105263 <pushcli>
  if(holding(lk))
80105126:	8b 45 08             	mov    0x8(%ebp),%eax
80105129:	89 04 24             	mov    %eax,(%esp)
8010512c:	e8 08 01 00 00       	call   80105239 <holding>
80105131:	85 c0                	test   %eax,%eax
80105133:	74 0c                	je     80105141 <acquire+0x26>
    panic("acquire");
80105135:	c7 04 24 21 8b 10 80 	movl   $0x80108b21,(%esp)
8010513c:	e8 fc b3 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105141:	90                   	nop
80105142:	8b 45 08             	mov    0x8(%ebp),%eax
80105145:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010514c:	00 
8010514d:	89 04 24             	mov    %eax,(%esp)
80105150:	e8 80 ff ff ff       	call   801050d5 <xchg>
80105155:	85 c0                	test   %eax,%eax
80105157:	75 e9                	jne    80105142 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105159:	8b 45 08             	mov    0x8(%ebp),%eax
8010515c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105163:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105166:	8b 45 08             	mov    0x8(%ebp),%eax
80105169:	83 c0 0c             	add    $0xc,%eax
8010516c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105170:	8d 45 08             	lea    0x8(%ebp),%eax
80105173:	89 04 24             	mov    %eax,(%esp)
80105176:	e8 51 00 00 00       	call   801051cc <getcallerpcs>
}
8010517b:	c9                   	leave  
8010517c:	c3                   	ret    

8010517d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010517d:	55                   	push   %ebp
8010517e:	89 e5                	mov    %esp,%ebp
80105180:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105183:	8b 45 08             	mov    0x8(%ebp),%eax
80105186:	89 04 24             	mov    %eax,(%esp)
80105189:	e8 ab 00 00 00       	call   80105239 <holding>
8010518e:	85 c0                	test   %eax,%eax
80105190:	75 0c                	jne    8010519e <release+0x21>
    panic("release");
80105192:	c7 04 24 29 8b 10 80 	movl   $0x80108b29,(%esp)
80105199:	e8 9f b3 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
8010519e:	8b 45 08             	mov    0x8(%ebp),%eax
801051a1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801051a8:	8b 45 08             	mov    0x8(%ebp),%eax
801051ab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801051b2:	8b 45 08             	mov    0x8(%ebp),%eax
801051b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801051bc:	00 
801051bd:	89 04 24             	mov    %eax,(%esp)
801051c0:	e8 10 ff ff ff       	call   801050d5 <xchg>

  popcli();
801051c5:	e8 e1 00 00 00       	call   801052ab <popcli>
}
801051ca:	c9                   	leave  
801051cb:	c3                   	ret    

801051cc <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801051cc:	55                   	push   %ebp
801051cd:	89 e5                	mov    %esp,%ebp
801051cf:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801051d2:	8b 45 08             	mov    0x8(%ebp),%eax
801051d5:	83 e8 08             	sub    $0x8,%eax
801051d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801051db:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801051e2:	eb 32                	jmp    80105216 <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801051e4:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801051e8:	74 47                	je     80105231 <getcallerpcs+0x65>
801051ea:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801051f1:	76 3e                	jbe    80105231 <getcallerpcs+0x65>
801051f3:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801051f7:	74 38                	je     80105231 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
801051f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051fc:	c1 e0 02             	shl    $0x2,%eax
801051ff:	03 45 0c             	add    0xc(%ebp),%eax
80105202:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105205:	8b 52 04             	mov    0x4(%edx),%edx
80105208:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
8010520a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010520d:	8b 00                	mov    (%eax),%eax
8010520f:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105212:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105216:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010521a:	7e c8                	jle    801051e4 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010521c:	eb 13                	jmp    80105231 <getcallerpcs+0x65>
    pcs[i] = 0;
8010521e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105221:	c1 e0 02             	shl    $0x2,%eax
80105224:	03 45 0c             	add    0xc(%ebp),%eax
80105227:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010522d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105231:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105235:	7e e7                	jle    8010521e <getcallerpcs+0x52>
    pcs[i] = 0;
}
80105237:	c9                   	leave  
80105238:	c3                   	ret    

80105239 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105239:	55                   	push   %ebp
8010523a:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010523c:	8b 45 08             	mov    0x8(%ebp),%eax
8010523f:	8b 00                	mov    (%eax),%eax
80105241:	85 c0                	test   %eax,%eax
80105243:	74 17                	je     8010525c <holding+0x23>
80105245:	8b 45 08             	mov    0x8(%ebp),%eax
80105248:	8b 50 08             	mov    0x8(%eax),%edx
8010524b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105251:	39 c2                	cmp    %eax,%edx
80105253:	75 07                	jne    8010525c <holding+0x23>
80105255:	b8 01 00 00 00       	mov    $0x1,%eax
8010525a:	eb 05                	jmp    80105261 <holding+0x28>
8010525c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105261:	5d                   	pop    %ebp
80105262:	c3                   	ret    

80105263 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105263:	55                   	push   %ebp
80105264:	89 e5                	mov    %esp,%ebp
80105266:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105269:	e8 46 fe ff ff       	call   801050b4 <readeflags>
8010526e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105271:	e8 53 fe ff ff       	call   801050c9 <cli>
  if(cpu->ncli++ == 0)
80105276:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010527c:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105282:	85 d2                	test   %edx,%edx
80105284:	0f 94 c1             	sete   %cl
80105287:	83 c2 01             	add    $0x1,%edx
8010528a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105290:	84 c9                	test   %cl,%cl
80105292:	74 15                	je     801052a9 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105294:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010529a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010529d:	81 e2 00 02 00 00    	and    $0x200,%edx
801052a3:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801052a9:	c9                   	leave  
801052aa:	c3                   	ret    

801052ab <popcli>:

void
popcli(void)
{
801052ab:	55                   	push   %ebp
801052ac:	89 e5                	mov    %esp,%ebp
801052ae:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801052b1:	e8 fe fd ff ff       	call   801050b4 <readeflags>
801052b6:	25 00 02 00 00       	and    $0x200,%eax
801052bb:	85 c0                	test   %eax,%eax
801052bd:	74 0c                	je     801052cb <popcli+0x20>
    panic("popcli - interruptible");
801052bf:	c7 04 24 31 8b 10 80 	movl   $0x80108b31,(%esp)
801052c6:	e8 72 b2 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
801052cb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052d1:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801052d7:	83 ea 01             	sub    $0x1,%edx
801052da:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801052e0:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801052e6:	85 c0                	test   %eax,%eax
801052e8:	79 0c                	jns    801052f6 <popcli+0x4b>
    panic("popcli");
801052ea:	c7 04 24 48 8b 10 80 	movl   $0x80108b48,(%esp)
801052f1:	e8 47 b2 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
801052f6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052fc:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105302:	85 c0                	test   %eax,%eax
80105304:	75 15                	jne    8010531b <popcli+0x70>
80105306:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010530c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105312:	85 c0                	test   %eax,%eax
80105314:	74 05                	je     8010531b <popcli+0x70>
    sti();
80105316:	e8 b4 fd ff ff       	call   801050cf <sti>
}
8010531b:	c9                   	leave  
8010531c:	c3                   	ret    
8010531d:	00 00                	add    %al,(%eax)
	...

80105320 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105320:	55                   	push   %ebp
80105321:	89 e5                	mov    %esp,%ebp
80105323:	57                   	push   %edi
80105324:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105325:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105328:	8b 55 10             	mov    0x10(%ebp),%edx
8010532b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010532e:	89 cb                	mov    %ecx,%ebx
80105330:	89 df                	mov    %ebx,%edi
80105332:	89 d1                	mov    %edx,%ecx
80105334:	fc                   	cld    
80105335:	f3 aa                	rep stos %al,%es:(%edi)
80105337:	89 ca                	mov    %ecx,%edx
80105339:	89 fb                	mov    %edi,%ebx
8010533b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010533e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105341:	5b                   	pop    %ebx
80105342:	5f                   	pop    %edi
80105343:	5d                   	pop    %ebp
80105344:	c3                   	ret    

80105345 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105345:	55                   	push   %ebp
80105346:	89 e5                	mov    %esp,%ebp
80105348:	57                   	push   %edi
80105349:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010534a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010534d:	8b 55 10             	mov    0x10(%ebp),%edx
80105350:	8b 45 0c             	mov    0xc(%ebp),%eax
80105353:	89 cb                	mov    %ecx,%ebx
80105355:	89 df                	mov    %ebx,%edi
80105357:	89 d1                	mov    %edx,%ecx
80105359:	fc                   	cld    
8010535a:	f3 ab                	rep stos %eax,%es:(%edi)
8010535c:	89 ca                	mov    %ecx,%edx
8010535e:	89 fb                	mov    %edi,%ebx
80105360:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105363:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105366:	5b                   	pop    %ebx
80105367:	5f                   	pop    %edi
80105368:	5d                   	pop    %ebp
80105369:	c3                   	ret    

8010536a <memset>:
#include "x86.h"
#include "string.h"

void*
memset(void *dst, int c, uint n)
{
8010536a:	55                   	push   %ebp
8010536b:	89 e5                	mov    %esp,%ebp
8010536d:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105370:	8b 45 08             	mov    0x8(%ebp),%eax
80105373:	83 e0 03             	and    $0x3,%eax
80105376:	85 c0                	test   %eax,%eax
80105378:	75 49                	jne    801053c3 <memset+0x59>
8010537a:	8b 45 10             	mov    0x10(%ebp),%eax
8010537d:	83 e0 03             	and    $0x3,%eax
80105380:	85 c0                	test   %eax,%eax
80105382:	75 3f                	jne    801053c3 <memset+0x59>
    c &= 0xFF;
80105384:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010538b:	8b 45 10             	mov    0x10(%ebp),%eax
8010538e:	c1 e8 02             	shr    $0x2,%eax
80105391:	89 c2                	mov    %eax,%edx
80105393:	8b 45 0c             	mov    0xc(%ebp),%eax
80105396:	89 c1                	mov    %eax,%ecx
80105398:	c1 e1 18             	shl    $0x18,%ecx
8010539b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010539e:	c1 e0 10             	shl    $0x10,%eax
801053a1:	09 c1                	or     %eax,%ecx
801053a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053a6:	c1 e0 08             	shl    $0x8,%eax
801053a9:	09 c8                	or     %ecx,%eax
801053ab:	0b 45 0c             	or     0xc(%ebp),%eax
801053ae:	89 54 24 08          	mov    %edx,0x8(%esp)
801053b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801053b6:	8b 45 08             	mov    0x8(%ebp),%eax
801053b9:	89 04 24             	mov    %eax,(%esp)
801053bc:	e8 84 ff ff ff       	call   80105345 <stosl>
801053c1:	eb 19                	jmp    801053dc <memset+0x72>
  } else
    stosb(dst, c, n);
801053c3:	8b 45 10             	mov    0x10(%ebp),%eax
801053c6:	89 44 24 08          	mov    %eax,0x8(%esp)
801053ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801053cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801053d1:	8b 45 08             	mov    0x8(%ebp),%eax
801053d4:	89 04 24             	mov    %eax,(%esp)
801053d7:	e8 44 ff ff ff       	call   80105320 <stosb>
  return dst;
801053dc:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053df:	c9                   	leave  
801053e0:	c3                   	ret    

801053e1 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801053e1:	55                   	push   %ebp
801053e2:	89 e5                	mov    %esp,%ebp
801053e4:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801053e7:	8b 45 08             	mov    0x8(%ebp),%eax
801053ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801053ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801053f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801053f3:	eb 32                	jmp    80105427 <memcmp+0x46>
    if(*s1 != *s2)
801053f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053f8:	0f b6 10             	movzbl (%eax),%edx
801053fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053fe:	0f b6 00             	movzbl (%eax),%eax
80105401:	38 c2                	cmp    %al,%dl
80105403:	74 1a                	je     8010541f <memcmp+0x3e>
      return *s1 - *s2;
80105405:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105408:	0f b6 00             	movzbl (%eax),%eax
8010540b:	0f b6 d0             	movzbl %al,%edx
8010540e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105411:	0f b6 00             	movzbl (%eax),%eax
80105414:	0f b6 c0             	movzbl %al,%eax
80105417:	89 d1                	mov    %edx,%ecx
80105419:	29 c1                	sub    %eax,%ecx
8010541b:	89 c8                	mov    %ecx,%eax
8010541d:	eb 1c                	jmp    8010543b <memcmp+0x5a>
    s1++, s2++;
8010541f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105423:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105427:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010542b:	0f 95 c0             	setne  %al
8010542e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105432:	84 c0                	test   %al,%al
80105434:	75 bf                	jne    801053f5 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105436:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010543b:	c9                   	leave  
8010543c:	c3                   	ret    

8010543d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010543d:	55                   	push   %ebp
8010543e:	89 e5                	mov    %esp,%ebp
80105440:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105443:	8b 45 0c             	mov    0xc(%ebp),%eax
80105446:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105449:	8b 45 08             	mov    0x8(%ebp),%eax
8010544c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010544f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105452:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105455:	73 54                	jae    801054ab <memmove+0x6e>
80105457:	8b 45 10             	mov    0x10(%ebp),%eax
8010545a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010545d:	01 d0                	add    %edx,%eax
8010545f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105462:	76 47                	jbe    801054ab <memmove+0x6e>
    s += n;
80105464:	8b 45 10             	mov    0x10(%ebp),%eax
80105467:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010546a:	8b 45 10             	mov    0x10(%ebp),%eax
8010546d:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105470:	eb 13                	jmp    80105485 <memmove+0x48>
      *--d = *--s;
80105472:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105476:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010547a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010547d:	0f b6 10             	movzbl (%eax),%edx
80105480:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105483:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105485:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105489:	0f 95 c0             	setne  %al
8010548c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105490:	84 c0                	test   %al,%al
80105492:	75 de                	jne    80105472 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105494:	eb 25                	jmp    801054bb <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105496:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105499:	0f b6 10             	movzbl (%eax),%edx
8010549c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010549f:	88 10                	mov    %dl,(%eax)
801054a1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801054a5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054a9:	eb 01                	jmp    801054ac <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801054ab:	90                   	nop
801054ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054b0:	0f 95 c0             	setne  %al
801054b3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054b7:	84 c0                	test   %al,%al
801054b9:	75 db                	jne    80105496 <memmove+0x59>
      *d++ = *s++;

  return dst;
801054bb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801054be:	c9                   	leave  
801054bf:	c3                   	ret    

801054c0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801054c0:	55                   	push   %ebp
801054c1:	89 e5                	mov    %esp,%ebp
801054c3:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801054c6:	8b 45 10             	mov    0x10(%ebp),%eax
801054c9:	89 44 24 08          	mov    %eax,0x8(%esp)
801054cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801054d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801054d4:	8b 45 08             	mov    0x8(%ebp),%eax
801054d7:	89 04 24             	mov    %eax,(%esp)
801054da:	e8 5e ff ff ff       	call   8010543d <memmove>
}
801054df:	c9                   	leave  
801054e0:	c3                   	ret    

801054e1 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801054e1:	55                   	push   %ebp
801054e2:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801054e4:	eb 0c                	jmp    801054f2 <strncmp+0x11>
    n--, p++, q++;
801054e6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054ea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801054ee:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801054f2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054f6:	74 1a                	je     80105512 <strncmp+0x31>
801054f8:	8b 45 08             	mov    0x8(%ebp),%eax
801054fb:	0f b6 00             	movzbl (%eax),%eax
801054fe:	84 c0                	test   %al,%al
80105500:	74 10                	je     80105512 <strncmp+0x31>
80105502:	8b 45 08             	mov    0x8(%ebp),%eax
80105505:	0f b6 10             	movzbl (%eax),%edx
80105508:	8b 45 0c             	mov    0xc(%ebp),%eax
8010550b:	0f b6 00             	movzbl (%eax),%eax
8010550e:	38 c2                	cmp    %al,%dl
80105510:	74 d4                	je     801054e6 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105512:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105516:	75 07                	jne    8010551f <strncmp+0x3e>
    return 0;
80105518:	b8 00 00 00 00       	mov    $0x0,%eax
8010551d:	eb 18                	jmp    80105537 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
8010551f:	8b 45 08             	mov    0x8(%ebp),%eax
80105522:	0f b6 00             	movzbl (%eax),%eax
80105525:	0f b6 d0             	movzbl %al,%edx
80105528:	8b 45 0c             	mov    0xc(%ebp),%eax
8010552b:	0f b6 00             	movzbl (%eax),%eax
8010552e:	0f b6 c0             	movzbl %al,%eax
80105531:	89 d1                	mov    %edx,%ecx
80105533:	29 c1                	sub    %eax,%ecx
80105535:	89 c8                	mov    %ecx,%eax
}
80105537:	5d                   	pop    %ebp
80105538:	c3                   	ret    

80105539 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105539:	55                   	push   %ebp
8010553a:	89 e5                	mov    %esp,%ebp
8010553c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010553f:	8b 45 08             	mov    0x8(%ebp),%eax
80105542:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105545:	90                   	nop
80105546:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010554a:	0f 9f c0             	setg   %al
8010554d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105551:	84 c0                	test   %al,%al
80105553:	74 30                	je     80105585 <strncpy+0x4c>
80105555:	8b 45 0c             	mov    0xc(%ebp),%eax
80105558:	0f b6 10             	movzbl (%eax),%edx
8010555b:	8b 45 08             	mov    0x8(%ebp),%eax
8010555e:	88 10                	mov    %dl,(%eax)
80105560:	8b 45 08             	mov    0x8(%ebp),%eax
80105563:	0f b6 00             	movzbl (%eax),%eax
80105566:	84 c0                	test   %al,%al
80105568:	0f 95 c0             	setne  %al
8010556b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010556f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105573:	84 c0                	test   %al,%al
80105575:	75 cf                	jne    80105546 <strncpy+0xd>
    ;
  while(n-- > 0)
80105577:	eb 0c                	jmp    80105585 <strncpy+0x4c>
    *s++ = 0;
80105579:	8b 45 08             	mov    0x8(%ebp),%eax
8010557c:	c6 00 00             	movb   $0x0,(%eax)
8010557f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105583:	eb 01                	jmp    80105586 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105585:	90                   	nop
80105586:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010558a:	0f 9f c0             	setg   %al
8010558d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105591:	84 c0                	test   %al,%al
80105593:	75 e4                	jne    80105579 <strncpy+0x40>
    *s++ = 0;
  return os;
80105595:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105598:	c9                   	leave  
80105599:	c3                   	ret    

8010559a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010559a:	55                   	push   %ebp
8010559b:	89 e5                	mov    %esp,%ebp
8010559d:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801055a0:	8b 45 08             	mov    0x8(%ebp),%eax
801055a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801055a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055aa:	7f 05                	jg     801055b1 <safestrcpy+0x17>
    return os;
801055ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055af:	eb 35                	jmp    801055e6 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801055b1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055b9:	7e 22                	jle    801055dd <safestrcpy+0x43>
801055bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801055be:	0f b6 10             	movzbl (%eax),%edx
801055c1:	8b 45 08             	mov    0x8(%ebp),%eax
801055c4:	88 10                	mov    %dl,(%eax)
801055c6:	8b 45 08             	mov    0x8(%ebp),%eax
801055c9:	0f b6 00             	movzbl (%eax),%eax
801055cc:	84 c0                	test   %al,%al
801055ce:	0f 95 c0             	setne  %al
801055d1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801055d5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801055d9:	84 c0                	test   %al,%al
801055db:	75 d4                	jne    801055b1 <safestrcpy+0x17>
    ;
  *s = 0;
801055dd:	8b 45 08             	mov    0x8(%ebp),%eax
801055e0:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801055e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055e6:	c9                   	leave  
801055e7:	c3                   	ret    

801055e8 <strlen>:

int
strlen(const char *s)
{
801055e8:	55                   	push   %ebp
801055e9:	89 e5                	mov    %esp,%ebp
801055eb:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801055ee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801055f5:	eb 04                	jmp    801055fb <strlen+0x13>
801055f7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055fe:	03 45 08             	add    0x8(%ebp),%eax
80105601:	0f b6 00             	movzbl (%eax),%eax
80105604:	84 c0                	test   %al,%al
80105606:	75 ef                	jne    801055f7 <strlen+0xf>
    ;
  return n;
80105608:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010560b:	c9                   	leave  
8010560c:	c3                   	ret    
8010560d:	00 00                	add    %al,(%eax)
	...

80105610 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105610:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105614:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105618:	55                   	push   %ebp
  pushl %ebx
80105619:	53                   	push   %ebx
  pushl %esi
8010561a:	56                   	push   %esi
  pushl %edi
8010561b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010561c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010561e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105620:	5f                   	pop    %edi
  popl %esi
80105621:	5e                   	pop    %esi
  popl %ebx
80105622:	5b                   	pop    %ebx
  popl %ebp
80105623:	5d                   	pop    %ebp
  ret
80105624:	c3                   	ret    
80105625:	00 00                	add    %al,(%eax)
	...

80105628 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
80105628:	55                   	push   %ebp
80105629:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
8010562b:	8b 45 08             	mov    0x8(%ebp),%eax
8010562e:	8b 00                	mov    (%eax),%eax
80105630:	3b 45 0c             	cmp    0xc(%ebp),%eax
80105633:	76 0f                	jbe    80105644 <fetchint+0x1c>
80105635:	8b 45 0c             	mov    0xc(%ebp),%eax
80105638:	8d 50 04             	lea    0x4(%eax),%edx
8010563b:	8b 45 08             	mov    0x8(%ebp),%eax
8010563e:	8b 00                	mov    (%eax),%eax
80105640:	39 c2                	cmp    %eax,%edx
80105642:	76 07                	jbe    8010564b <fetchint+0x23>
    return -1;
80105644:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105649:	eb 0f                	jmp    8010565a <fetchint+0x32>
  *ip = *(int*)(addr);
8010564b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010564e:	8b 10                	mov    (%eax),%edx
80105650:	8b 45 10             	mov    0x10(%ebp),%eax
80105653:	89 10                	mov    %edx,(%eax)
  return 0;
80105655:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010565a:	5d                   	pop    %ebp
8010565b:	c3                   	ret    

8010565c <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
8010565c:	55                   	push   %ebp
8010565d:	89 e5                	mov    %esp,%ebp
8010565f:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
80105662:	8b 45 08             	mov    0x8(%ebp),%eax
80105665:	8b 00                	mov    (%eax),%eax
80105667:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010566a:	77 07                	ja     80105673 <fetchstr+0x17>
    return -1;
8010566c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105671:	eb 45                	jmp    801056b8 <fetchstr+0x5c>
  *pp = (char*)addr;
80105673:	8b 55 0c             	mov    0xc(%ebp),%edx
80105676:	8b 45 10             	mov    0x10(%ebp),%eax
80105679:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
8010567b:	8b 45 08             	mov    0x8(%ebp),%eax
8010567e:	8b 00                	mov    (%eax),%eax
80105680:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105683:	8b 45 10             	mov    0x10(%ebp),%eax
80105686:	8b 00                	mov    (%eax),%eax
80105688:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010568b:	eb 1e                	jmp    801056ab <fetchstr+0x4f>
    if(*s == 0)
8010568d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105690:	0f b6 00             	movzbl (%eax),%eax
80105693:	84 c0                	test   %al,%al
80105695:	75 10                	jne    801056a7 <fetchstr+0x4b>
      return s - *pp;
80105697:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010569a:	8b 45 10             	mov    0x10(%ebp),%eax
8010569d:	8b 00                	mov    (%eax),%eax
8010569f:	89 d1                	mov    %edx,%ecx
801056a1:	29 c1                	sub    %eax,%ecx
801056a3:	89 c8                	mov    %ecx,%eax
801056a5:	eb 11                	jmp    801056b8 <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
801056a7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056ae:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056b1:	72 da                	jb     8010568d <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
801056b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056b8:	c9                   	leave  
801056b9:	c3                   	ret    

801056ba <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801056ba:	55                   	push   %ebp
801056bb:	89 e5                	mov    %esp,%ebp
801056bd:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
801056c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c6:	8b 40 18             	mov    0x18(%eax),%eax
801056c9:	8b 50 44             	mov    0x44(%eax),%edx
801056cc:	8b 45 08             	mov    0x8(%ebp),%eax
801056cf:	c1 e0 02             	shl    $0x2,%eax
801056d2:	01 d0                	add    %edx,%eax
801056d4:	8d 48 04             	lea    0x4(%eax),%ecx
801056d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801056e0:	89 54 24 08          	mov    %edx,0x8(%esp)
801056e4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801056e8:	89 04 24             	mov    %eax,(%esp)
801056eb:	e8 38 ff ff ff       	call   80105628 <fetchint>
}
801056f0:	c9                   	leave  
801056f1:	c3                   	ret    

801056f2 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801056f2:	55                   	push   %ebp
801056f3:	89 e5                	mov    %esp,%ebp
801056f5:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801056f8:	8d 45 fc             	lea    -0x4(%ebp),%eax
801056fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801056ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105702:	89 04 24             	mov    %eax,(%esp)
80105705:	e8 b0 ff ff ff       	call   801056ba <argint>
8010570a:	85 c0                	test   %eax,%eax
8010570c:	79 07                	jns    80105715 <argptr+0x23>
    return -1;
8010570e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105713:	eb 3d                	jmp    80105752 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105715:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105718:	89 c2                	mov    %eax,%edx
8010571a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105720:	8b 00                	mov    (%eax),%eax
80105722:	39 c2                	cmp    %eax,%edx
80105724:	73 16                	jae    8010573c <argptr+0x4a>
80105726:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105729:	89 c2                	mov    %eax,%edx
8010572b:	8b 45 10             	mov    0x10(%ebp),%eax
8010572e:	01 c2                	add    %eax,%edx
80105730:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105736:	8b 00                	mov    (%eax),%eax
80105738:	39 c2                	cmp    %eax,%edx
8010573a:	76 07                	jbe    80105743 <argptr+0x51>
    return -1;
8010573c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105741:	eb 0f                	jmp    80105752 <argptr+0x60>
  *pp = (char*)i;
80105743:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105746:	89 c2                	mov    %eax,%edx
80105748:	8b 45 0c             	mov    0xc(%ebp),%eax
8010574b:	89 10                	mov    %edx,(%eax)
  return 0;
8010574d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105752:	c9                   	leave  
80105753:	c3                   	ret    

80105754 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105754:	55                   	push   %ebp
80105755:	89 e5                	mov    %esp,%ebp
80105757:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010575a:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010575d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105761:	8b 45 08             	mov    0x8(%ebp),%eax
80105764:	89 04 24             	mov    %eax,(%esp)
80105767:	e8 4e ff ff ff       	call   801056ba <argint>
8010576c:	85 c0                	test   %eax,%eax
8010576e:	79 07                	jns    80105777 <argstr+0x23>
    return -1;
80105770:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105775:	eb 1e                	jmp    80105795 <argstr+0x41>
  return fetchstr(proc, addr, pp);
80105777:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010577a:	89 c2                	mov    %eax,%edx
8010577c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105782:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105785:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105789:	89 54 24 04          	mov    %edx,0x4(%esp)
8010578d:	89 04 24             	mov    %eax,(%esp)
80105790:	e8 c7 fe ff ff       	call   8010565c <fetchstr>
}
80105795:	c9                   	leave  
80105796:	c3                   	ret    

80105797 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105797:	55                   	push   %ebp
80105798:	89 e5                	mov    %esp,%ebp
8010579a:	53                   	push   %ebx
8010579b:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
8010579e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057a4:	8b 40 18             	mov    0x18(%eax),%eax
801057a7:	8b 40 1c             	mov    0x1c(%eax),%eax
801057aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
801057ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057b1:	78 2e                	js     801057e1 <syscall+0x4a>
801057b3:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801057b7:	7f 28                	jg     801057e1 <syscall+0x4a>
801057b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057bc:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801057c3:	85 c0                	test   %eax,%eax
801057c5:	74 1a                	je     801057e1 <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
801057c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057cd:	8b 58 18             	mov    0x18(%eax),%ebx
801057d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d3:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801057da:	ff d0                	call   *%eax
801057dc:	89 43 1c             	mov    %eax,0x1c(%ebx)
801057df:	eb 73                	jmp    80105854 <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
801057e1:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801057e5:	7e 30                	jle    80105817 <syscall+0x80>
801057e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ea:	83 f8 16             	cmp    $0x16,%eax
801057ed:	77 28                	ja     80105817 <syscall+0x80>
801057ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f2:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801057f9:	85 c0                	test   %eax,%eax
801057fb:	74 1a                	je     80105817 <syscall+0x80>
    proc->tf->eax = syscalls[num]();
801057fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105803:	8b 58 18             	mov    0x18(%eax),%ebx
80105806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105809:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105810:	ff d0                	call   *%eax
80105812:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105815:	eb 3d                	jmp    80105854 <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105817:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010581d:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105820:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105826:	8b 40 10             	mov    0x10(%eax),%eax
80105829:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010582c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105830:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105834:	89 44 24 04          	mov    %eax,0x4(%esp)
80105838:	c7 04 24 4f 8b 10 80 	movl   $0x80108b4f,(%esp)
8010583f:	e8 5d ab ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105844:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010584a:	8b 40 18             	mov    0x18(%eax),%eax
8010584d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105854:	83 c4 24             	add    $0x24,%esp
80105857:	5b                   	pop    %ebx
80105858:	5d                   	pop    %ebp
80105859:	c3                   	ret    
	...

8010585c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010585c:	55                   	push   %ebp
8010585d:	89 e5                	mov    %esp,%ebp
8010585f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105862:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105865:	89 44 24 04          	mov    %eax,0x4(%esp)
80105869:	8b 45 08             	mov    0x8(%ebp),%eax
8010586c:	89 04 24             	mov    %eax,(%esp)
8010586f:	e8 46 fe ff ff       	call   801056ba <argint>
80105874:	85 c0                	test   %eax,%eax
80105876:	79 07                	jns    8010587f <argfd+0x23>
    return -1;
80105878:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010587d:	eb 50                	jmp    801058cf <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010587f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105882:	85 c0                	test   %eax,%eax
80105884:	78 21                	js     801058a7 <argfd+0x4b>
80105886:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105889:	83 f8 0f             	cmp    $0xf,%eax
8010588c:	7f 19                	jg     801058a7 <argfd+0x4b>
8010588e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105894:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105897:	83 c2 08             	add    $0x8,%edx
8010589a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010589e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058a5:	75 07                	jne    801058ae <argfd+0x52>
    return -1;
801058a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058ac:	eb 21                	jmp    801058cf <argfd+0x73>
  if(pfd)
801058ae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058b2:	74 08                	je     801058bc <argfd+0x60>
    *pfd = fd;
801058b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801058ba:	89 10                	mov    %edx,(%eax)
  if(pf)
801058bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058c0:	74 08                	je     801058ca <argfd+0x6e>
    *pf = f;
801058c2:	8b 45 10             	mov    0x10(%ebp),%eax
801058c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058c8:	89 10                	mov    %edx,(%eax)
  return 0;
801058ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058cf:	c9                   	leave  
801058d0:	c3                   	ret    

801058d1 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801058d1:	55                   	push   %ebp
801058d2:	89 e5                	mov    %esp,%ebp
801058d4:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801058d7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801058de:	eb 30                	jmp    80105910 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801058e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058e9:	83 c2 08             	add    $0x8,%edx
801058ec:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801058f0:	85 c0                	test   %eax,%eax
801058f2:	75 18                	jne    8010590c <fdalloc+0x3b>
      proc->ofile[fd] = f;
801058f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058fd:	8d 4a 08             	lea    0x8(%edx),%ecx
80105900:	8b 55 08             	mov    0x8(%ebp),%edx
80105903:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105907:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010590a:	eb 0f                	jmp    8010591b <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010590c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105910:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105914:	7e ca                	jle    801058e0 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105916:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010591b:	c9                   	leave  
8010591c:	c3                   	ret    

8010591d <sys_dup>:

int
sys_dup(void)
{
8010591d:	55                   	push   %ebp
8010591e:	89 e5                	mov    %esp,%ebp
80105920:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105923:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105926:	89 44 24 08          	mov    %eax,0x8(%esp)
8010592a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105931:	00 
80105932:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105939:	e8 1e ff ff ff       	call   8010585c <argfd>
8010593e:	85 c0                	test   %eax,%eax
80105940:	79 07                	jns    80105949 <sys_dup+0x2c>
    return -1;
80105942:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105947:	eb 29                	jmp    80105972 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105949:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594c:	89 04 24             	mov    %eax,(%esp)
8010594f:	e8 7d ff ff ff       	call   801058d1 <fdalloc>
80105954:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105957:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010595b:	79 07                	jns    80105964 <sys_dup+0x47>
    return -1;
8010595d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105962:	eb 0e                	jmp    80105972 <sys_dup+0x55>
  filedup(f);
80105964:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105967:	89 04 24             	mov    %eax,(%esp)
8010596a:	e8 61 b9 ff ff       	call   801012d0 <filedup>
  return fd;
8010596f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105972:	c9                   	leave  
80105973:	c3                   	ret    

80105974 <sys_read>:

int
sys_read(void)
{
80105974:	55                   	push   %ebp
80105975:	89 e5                	mov    %esp,%ebp
80105977:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010597a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010597d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105981:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105988:	00 
80105989:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105990:	e8 c7 fe ff ff       	call   8010585c <argfd>
80105995:	85 c0                	test   %eax,%eax
80105997:	78 35                	js     801059ce <sys_read+0x5a>
80105999:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010599c:	89 44 24 04          	mov    %eax,0x4(%esp)
801059a0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801059a7:	e8 0e fd ff ff       	call   801056ba <argint>
801059ac:	85 c0                	test   %eax,%eax
801059ae:	78 1e                	js     801059ce <sys_read+0x5a>
801059b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801059b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801059be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059c5:	e8 28 fd ff ff       	call   801056f2 <argptr>
801059ca:	85 c0                	test   %eax,%eax
801059cc:	79 07                	jns    801059d5 <sys_read+0x61>
    return -1;
801059ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d3:	eb 19                	jmp    801059ee <sys_read+0x7a>
  return fileread(f, p, n);
801059d5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059d8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059de:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059e2:	89 54 24 04          	mov    %edx,0x4(%esp)
801059e6:	89 04 24             	mov    %eax,(%esp)
801059e9:	e8 4f ba ff ff       	call   8010143d <fileread>
}
801059ee:	c9                   	leave  
801059ef:	c3                   	ret    

801059f0 <sys_write>:

int
sys_write(void)
{
801059f0:	55                   	push   %ebp
801059f1:	89 e5                	mov    %esp,%ebp
801059f3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801059f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059f9:	89 44 24 08          	mov    %eax,0x8(%esp)
801059fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a04:	00 
80105a05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a0c:	e8 4b fe ff ff       	call   8010585c <argfd>
80105a11:	85 c0                	test   %eax,%eax
80105a13:	78 35                	js     80105a4a <sys_write+0x5a>
80105a15:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a18:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a1c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105a23:	e8 92 fc ff ff       	call   801056ba <argint>
80105a28:	85 c0                	test   %eax,%eax
80105a2a:	78 1e                	js     80105a4a <sys_write+0x5a>
80105a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a33:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a36:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a41:	e8 ac fc ff ff       	call   801056f2 <argptr>
80105a46:	85 c0                	test   %eax,%eax
80105a48:	79 07                	jns    80105a51 <sys_write+0x61>
    return -1;
80105a4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4f:	eb 19                	jmp    80105a6a <sys_write+0x7a>
  return filewrite(f, p, n);
80105a51:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a54:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a5e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a62:	89 04 24             	mov    %eax,(%esp)
80105a65:	e8 8f ba ff ff       	call   801014f9 <filewrite>
}
80105a6a:	c9                   	leave  
80105a6b:	c3                   	ret    

80105a6c <sys_close>:

int
sys_close(void)
{
80105a6c:	55                   	push   %ebp
80105a6d:	89 e5                	mov    %esp,%ebp
80105a6f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105a72:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a75:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a79:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a87:	e8 d0 fd ff ff       	call   8010585c <argfd>
80105a8c:	85 c0                	test   %eax,%eax
80105a8e:	79 07                	jns    80105a97 <sys_close+0x2b>
    return -1;
80105a90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a95:	eb 24                	jmp    80105abb <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105a97:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105aa0:	83 c2 08             	add    $0x8,%edx
80105aa3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105aaa:	00 
  fileclose(f);
80105aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aae:	89 04 24             	mov    %eax,(%esp)
80105ab1:	e8 62 b8 ff ff       	call   80101318 <fileclose>
  return 0;
80105ab6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105abb:	c9                   	leave  
80105abc:	c3                   	ret    

80105abd <sys_fstat>:

int
sys_fstat(void)
{
80105abd:	55                   	push   %ebp
80105abe:	89 e5                	mov    %esp,%ebp
80105ac0:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105ac3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ac6:	89 44 24 08          	mov    %eax,0x8(%esp)
80105aca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ad1:	00 
80105ad2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ad9:	e8 7e fd ff ff       	call   8010585c <argfd>
80105ade:	85 c0                	test   %eax,%eax
80105ae0:	78 1f                	js     80105b01 <sys_fstat+0x44>
80105ae2:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105ae9:	00 
80105aea:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105aed:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105af8:	e8 f5 fb ff ff       	call   801056f2 <argptr>
80105afd:	85 c0                	test   %eax,%eax
80105aff:	79 07                	jns    80105b08 <sys_fstat+0x4b>
    return -1;
80105b01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b06:	eb 12                	jmp    80105b1a <sys_fstat+0x5d>
  return filestat(f, st);
80105b08:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b12:	89 04 24             	mov    %eax,(%esp)
80105b15:	e8 d4 b8 ff ff       	call   801013ee <filestat>
}
80105b1a:	c9                   	leave  
80105b1b:	c3                   	ret    

80105b1c <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105b1c:	55                   	push   %ebp
80105b1d:	89 e5                	mov    %esp,%ebp
80105b1f:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105b22:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105b25:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b30:	e8 1f fc ff ff       	call   80105754 <argstr>
80105b35:	85 c0                	test   %eax,%eax
80105b37:	78 17                	js     80105b50 <sys_link+0x34>
80105b39:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b47:	e8 08 fc ff ff       	call   80105754 <argstr>
80105b4c:	85 c0                	test   %eax,%eax
80105b4e:	79 0a                	jns    80105b5a <sys_link+0x3e>
    return -1;
80105b50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b55:	e9 3c 01 00 00       	jmp    80105c96 <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80105b5a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105b5d:	89 04 24             	mov    %eax,(%esp)
80105b60:	e8 f9 cb ff ff       	call   8010275e <namei>
80105b65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b6c:	75 0a                	jne    80105b78 <sys_link+0x5c>
    return -1;
80105b6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b73:	e9 1e 01 00 00       	jmp    80105c96 <sys_link+0x17a>

  begin_trans();
80105b78:	e8 f4 d9 ff ff       	call   80103571 <begin_trans>

  ilock(ip);
80105b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b80:	89 04 24             	mov    %eax,(%esp)
80105b83:	e8 34 c0 ff ff       	call   80101bbc <ilock>
  if(ip->type == T_DIR){
80105b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b8f:	66 83 f8 01          	cmp    $0x1,%ax
80105b93:	75 1a                	jne    80105baf <sys_link+0x93>
    iunlockput(ip);
80105b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b98:	89 04 24             	mov    %eax,(%esp)
80105b9b:	e8 a0 c2 ff ff       	call   80101e40 <iunlockput>
    commit_trans();
80105ba0:	e8 15 da ff ff       	call   801035ba <commit_trans>
    return -1;
80105ba5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105baa:	e9 e7 00 00 00       	jmp    80105c96 <sys_link+0x17a>
  }

  ip->nlink++;
80105baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105bb6:	8d 50 01             	lea    0x1(%eax),%edx
80105bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbc:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc3:	89 04 24             	mov    %eax,(%esp)
80105bc6:	e8 35 be ff ff       	call   80101a00 <iupdate>
  iunlock(ip);
80105bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bce:	89 04 24             	mov    %eax,(%esp)
80105bd1:	e8 34 c1 ff ff       	call   80101d0a <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105bd6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105bd9:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105bdc:	89 54 24 04          	mov    %edx,0x4(%esp)
80105be0:	89 04 24             	mov    %eax,(%esp)
80105be3:	e8 98 cb ff ff       	call   80102780 <nameiparent>
80105be8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105beb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bef:	74 68                	je     80105c59 <sys_link+0x13d>
    goto bad;
  ilock(dp);
80105bf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf4:	89 04 24             	mov    %eax,(%esp)
80105bf7:	e8 c0 bf ff ff       	call   80101bbc <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bff:	8b 10                	mov    (%eax),%edx
80105c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c04:	8b 00                	mov    (%eax),%eax
80105c06:	39 c2                	cmp    %eax,%edx
80105c08:	75 20                	jne    80105c2a <sys_link+0x10e>
80105c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0d:	8b 40 04             	mov    0x4(%eax),%eax
80105c10:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c14:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105c17:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1e:	89 04 24             	mov    %eax,(%esp)
80105c21:	e8 77 c8 ff ff       	call   8010249d <dirlink>
80105c26:	85 c0                	test   %eax,%eax
80105c28:	79 0d                	jns    80105c37 <sys_link+0x11b>
    iunlockput(dp);
80105c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2d:	89 04 24             	mov    %eax,(%esp)
80105c30:	e8 0b c2 ff ff       	call   80101e40 <iunlockput>
    goto bad;
80105c35:	eb 23                	jmp    80105c5a <sys_link+0x13e>
  }
  iunlockput(dp);
80105c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3a:	89 04 24             	mov    %eax,(%esp)
80105c3d:	e8 fe c1 ff ff       	call   80101e40 <iunlockput>
  iput(ip);
80105c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c45:	89 04 24             	mov    %eax,(%esp)
80105c48:	e8 22 c1 ff ff       	call   80101d6f <iput>

  commit_trans();
80105c4d:	e8 68 d9 ff ff       	call   801035ba <commit_trans>

  return 0;
80105c52:	b8 00 00 00 00       	mov    $0x0,%eax
80105c57:	eb 3d                	jmp    80105c96 <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105c59:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80105c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5d:	89 04 24             	mov    %eax,(%esp)
80105c60:	e8 57 bf ff ff       	call   80101bbc <ilock>
  ip->nlink--;
80105c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c68:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c6c:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c72:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c79:	89 04 24             	mov    %eax,(%esp)
80105c7c:	e8 7f bd ff ff       	call   80101a00 <iupdate>
  iunlockput(ip);
80105c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c84:	89 04 24             	mov    %eax,(%esp)
80105c87:	e8 b4 c1 ff ff       	call   80101e40 <iunlockput>
  commit_trans();
80105c8c:	e8 29 d9 ff ff       	call   801035ba <commit_trans>
  return -1;
80105c91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c96:	c9                   	leave  
80105c97:	c3                   	ret    

80105c98 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105c98:	55                   	push   %ebp
80105c99:	89 e5                	mov    %esp,%ebp
80105c9b:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c9e:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ca5:	eb 4b                	jmp    80105cf2 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105caa:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105cb1:	00 
80105cb2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc0:	89 04 24             	mov    %eax,(%esp)
80105cc3:	e8 ea c3 ff ff       	call   801020b2 <readi>
80105cc8:	83 f8 10             	cmp    $0x10,%eax
80105ccb:	74 0c                	je     80105cd9 <isdirempty+0x41>
      panic("isdirempty: readi");
80105ccd:	c7 04 24 6b 8b 10 80 	movl   $0x80108b6b,(%esp)
80105cd4:	e8 64 a8 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105cd9:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105cdd:	66 85 c0             	test   %ax,%ax
80105ce0:	74 07                	je     80105ce9 <isdirempty+0x51>
      return 0;
80105ce2:	b8 00 00 00 00       	mov    $0x0,%eax
80105ce7:	eb 1b                	jmp    80105d04 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cec:	83 c0 10             	add    $0x10,%eax
80105cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80105cf8:	8b 40 18             	mov    0x18(%eax),%eax
80105cfb:	39 c2                	cmp    %eax,%edx
80105cfd:	72 a8                	jb     80105ca7 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105cff:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105d04:	c9                   	leave  
80105d05:	c3                   	ret    

80105d06 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105d06:	55                   	push   %ebp
80105d07:	89 e5                	mov    %esp,%ebp
80105d09:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105d0c:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d1a:	e8 35 fa ff ff       	call   80105754 <argstr>
80105d1f:	85 c0                	test   %eax,%eax
80105d21:	79 0a                	jns    80105d2d <sys_unlink+0x27>
    return -1;
80105d23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d28:	e9 aa 01 00 00       	jmp    80105ed7 <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105d2d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d30:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105d33:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d37:	89 04 24             	mov    %eax,(%esp)
80105d3a:	e8 41 ca ff ff       	call   80102780 <nameiparent>
80105d3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d46:	75 0a                	jne    80105d52 <sys_unlink+0x4c>
    return -1;
80105d48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d4d:	e9 85 01 00 00       	jmp    80105ed7 <sys_unlink+0x1d1>

  begin_trans();
80105d52:	e8 1a d8 ff ff       	call   80103571 <begin_trans>

  ilock(dp);
80105d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d5a:	89 04 24             	mov    %eax,(%esp)
80105d5d:	e8 5a be ff ff       	call   80101bbc <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105d62:	c7 44 24 04 7d 8b 10 	movl   $0x80108b7d,0x4(%esp)
80105d69:	80 
80105d6a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d6d:	89 04 24             	mov    %eax,(%esp)
80105d70:	e8 3e c6 ff ff       	call   801023b3 <namecmp>
80105d75:	85 c0                	test   %eax,%eax
80105d77:	0f 84 45 01 00 00    	je     80105ec2 <sys_unlink+0x1bc>
80105d7d:	c7 44 24 04 7f 8b 10 	movl   $0x80108b7f,0x4(%esp)
80105d84:	80 
80105d85:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d88:	89 04 24             	mov    %eax,(%esp)
80105d8b:	e8 23 c6 ff ff       	call   801023b3 <namecmp>
80105d90:	85 c0                	test   %eax,%eax
80105d92:	0f 84 2a 01 00 00    	je     80105ec2 <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105d98:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105d9b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d9f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105da2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da9:	89 04 24             	mov    %eax,(%esp)
80105dac:	e8 24 c6 ff ff       	call   801023d5 <dirlookup>
80105db1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105db4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105db8:	0f 84 03 01 00 00    	je     80105ec1 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80105dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc1:	89 04 24             	mov    %eax,(%esp)
80105dc4:	e8 f3 bd ff ff       	call   80101bbc <ilock>

  if(ip->nlink < 1)
80105dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dcc:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105dd0:	66 85 c0             	test   %ax,%ax
80105dd3:	7f 0c                	jg     80105de1 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80105dd5:	c7 04 24 82 8b 10 80 	movl   $0x80108b82,(%esp)
80105ddc:	e8 5c a7 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105de8:	66 83 f8 01          	cmp    $0x1,%ax
80105dec:	75 1f                	jne    80105e0d <sys_unlink+0x107>
80105dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df1:	89 04 24             	mov    %eax,(%esp)
80105df4:	e8 9f fe ff ff       	call   80105c98 <isdirempty>
80105df9:	85 c0                	test   %eax,%eax
80105dfb:	75 10                	jne    80105e0d <sys_unlink+0x107>
    iunlockput(ip);
80105dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e00:	89 04 24             	mov    %eax,(%esp)
80105e03:	e8 38 c0 ff ff       	call   80101e40 <iunlockput>
    goto bad;
80105e08:	e9 b5 00 00 00       	jmp    80105ec2 <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105e0d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105e14:	00 
80105e15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e1c:	00 
80105e1d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e20:	89 04 24             	mov    %eax,(%esp)
80105e23:	e8 42 f5 ff ff       	call   8010536a <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e28:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105e2b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105e32:	00 
80105e33:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e37:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e41:	89 04 24             	mov    %eax,(%esp)
80105e44:	e8 d4 c3 ff ff       	call   8010221d <writei>
80105e49:	83 f8 10             	cmp    $0x10,%eax
80105e4c:	74 0c                	je     80105e5a <sys_unlink+0x154>
    panic("unlink: writei");
80105e4e:	c7 04 24 94 8b 10 80 	movl   $0x80108b94,(%esp)
80105e55:	e8 e3 a6 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e5d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e61:	66 83 f8 01          	cmp    $0x1,%ax
80105e65:	75 1c                	jne    80105e83 <sys_unlink+0x17d>
    dp->nlink--;
80105e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e6a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e6e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e74:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7b:	89 04 24             	mov    %eax,(%esp)
80105e7e:	e8 7d bb ff ff       	call   80101a00 <iupdate>
  }
  iunlockput(dp);
80105e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e86:	89 04 24             	mov    %eax,(%esp)
80105e89:	e8 b2 bf ff ff       	call   80101e40 <iunlockput>

  ip->nlink--;
80105e8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e91:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e95:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9b:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea2:	89 04 24             	mov    %eax,(%esp)
80105ea5:	e8 56 bb ff ff       	call   80101a00 <iupdate>
  iunlockput(ip);
80105eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ead:	89 04 24             	mov    %eax,(%esp)
80105eb0:	e8 8b bf ff ff       	call   80101e40 <iunlockput>

  commit_trans();
80105eb5:	e8 00 d7 ff ff       	call   801035ba <commit_trans>

  return 0;
80105eba:	b8 00 00 00 00       	mov    $0x0,%eax
80105ebf:	eb 16                	jmp    80105ed7 <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105ec1:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80105ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec5:	89 04 24             	mov    %eax,(%esp)
80105ec8:	e8 73 bf ff ff       	call   80101e40 <iunlockput>
  commit_trans();
80105ecd:	e8 e8 d6 ff ff       	call   801035ba <commit_trans>
  return -1;
80105ed2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ed7:	c9                   	leave  
80105ed8:	c3                   	ret    

80105ed9 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105ed9:	55                   	push   %ebp
80105eda:	89 e5                	mov    %esp,%ebp
80105edc:	83 ec 48             	sub    $0x48,%esp
80105edf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105ee2:	8b 55 10             	mov    0x10(%ebp),%edx
80105ee5:	8b 45 14             	mov    0x14(%ebp),%eax
80105ee8:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105eec:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105ef0:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105ef4:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ef7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105efb:	8b 45 08             	mov    0x8(%ebp),%eax
80105efe:	89 04 24             	mov    %eax,(%esp)
80105f01:	e8 7a c8 ff ff       	call   80102780 <nameiparent>
80105f06:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f09:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f0d:	75 0a                	jne    80105f19 <create+0x40>
    return 0;
80105f0f:	b8 00 00 00 00       	mov    $0x0,%eax
80105f14:	e9 7e 01 00 00       	jmp    80106097 <create+0x1be>
  ilock(dp);
80105f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1c:	89 04 24             	mov    %eax,(%esp)
80105f1f:	e8 98 bc ff ff       	call   80101bbc <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105f24:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f27:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f2b:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f35:	89 04 24             	mov    %eax,(%esp)
80105f38:	e8 98 c4 ff ff       	call   801023d5 <dirlookup>
80105f3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f44:	74 47                	je     80105f8d <create+0xb4>
    iunlockput(dp);
80105f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f49:	89 04 24             	mov    %eax,(%esp)
80105f4c:	e8 ef be ff ff       	call   80101e40 <iunlockput>
    ilock(ip);
80105f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f54:	89 04 24             	mov    %eax,(%esp)
80105f57:	e8 60 bc ff ff       	call   80101bbc <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105f5c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105f61:	75 15                	jne    80105f78 <create+0x9f>
80105f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f66:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f6a:	66 83 f8 02          	cmp    $0x2,%ax
80105f6e:	75 08                	jne    80105f78 <create+0x9f>
      return ip;
80105f70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f73:	e9 1f 01 00 00       	jmp    80106097 <create+0x1be>
    iunlockput(ip);
80105f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f7b:	89 04 24             	mov    %eax,(%esp)
80105f7e:	e8 bd be ff ff       	call   80101e40 <iunlockput>
    return 0;
80105f83:	b8 00 00 00 00       	mov    $0x0,%eax
80105f88:	e9 0a 01 00 00       	jmp    80106097 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105f8d:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f94:	8b 00                	mov    (%eax),%eax
80105f96:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f9a:	89 04 24             	mov    %eax,(%esp)
80105f9d:	e8 81 b9 ff ff       	call   80101923 <ialloc>
80105fa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fa5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fa9:	75 0c                	jne    80105fb7 <create+0xde>
    panic("create: ialloc");
80105fab:	c7 04 24 a3 8b 10 80 	movl   $0x80108ba3,(%esp)
80105fb2:	e8 86 a5 ff ff       	call   8010053d <panic>

  ilock(ip);
80105fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fba:	89 04 24             	mov    %eax,(%esp)
80105fbd:	e8 fa bb ff ff       	call   80101bbc <ilock>
  ip->major = major;
80105fc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc5:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105fc9:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105fcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd0:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105fd4:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fdb:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe4:	89 04 24             	mov    %eax,(%esp)
80105fe7:	e8 14 ba ff ff       	call   80101a00 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105fec:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ff1:	75 6a                	jne    8010605d <create+0x184>
    dp->nlink++;  // for ".."
80105ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ffa:	8d 50 01             	lea    0x1(%eax),%edx
80105ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106000:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106004:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106007:	89 04 24             	mov    %eax,(%esp)
8010600a:	e8 f1 b9 ff ff       	call   80101a00 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010600f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106012:	8b 40 04             	mov    0x4(%eax),%eax
80106015:	89 44 24 08          	mov    %eax,0x8(%esp)
80106019:	c7 44 24 04 7d 8b 10 	movl   $0x80108b7d,0x4(%esp)
80106020:	80 
80106021:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106024:	89 04 24             	mov    %eax,(%esp)
80106027:	e8 71 c4 ff ff       	call   8010249d <dirlink>
8010602c:	85 c0                	test   %eax,%eax
8010602e:	78 21                	js     80106051 <create+0x178>
80106030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106033:	8b 40 04             	mov    0x4(%eax),%eax
80106036:	89 44 24 08          	mov    %eax,0x8(%esp)
8010603a:	c7 44 24 04 7f 8b 10 	movl   $0x80108b7f,0x4(%esp)
80106041:	80 
80106042:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106045:	89 04 24             	mov    %eax,(%esp)
80106048:	e8 50 c4 ff ff       	call   8010249d <dirlink>
8010604d:	85 c0                	test   %eax,%eax
8010604f:	79 0c                	jns    8010605d <create+0x184>
      panic("create dots");
80106051:	c7 04 24 b2 8b 10 80 	movl   $0x80108bb2,(%esp)
80106058:	e8 e0 a4 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010605d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106060:	8b 40 04             	mov    0x4(%eax),%eax
80106063:	89 44 24 08          	mov    %eax,0x8(%esp)
80106067:	8d 45 de             	lea    -0x22(%ebp),%eax
8010606a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010606e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106071:	89 04 24             	mov    %eax,(%esp)
80106074:	e8 24 c4 ff ff       	call   8010249d <dirlink>
80106079:	85 c0                	test   %eax,%eax
8010607b:	79 0c                	jns    80106089 <create+0x1b0>
    panic("create: dirlink");
8010607d:	c7 04 24 be 8b 10 80 	movl   $0x80108bbe,(%esp)
80106084:	e8 b4 a4 ff ff       	call   8010053d <panic>

  iunlockput(dp);
80106089:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608c:	89 04 24             	mov    %eax,(%esp)
8010608f:	e8 ac bd ff ff       	call   80101e40 <iunlockput>

  return ip;
80106094:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106097:	c9                   	leave  
80106098:	c3                   	ret    

80106099 <sys_open>:

int
sys_open(void)
{
80106099:	55                   	push   %ebp
8010609a:	89 e5                	mov    %esp,%ebp
8010609c:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010609f:	8d 45 e8             	lea    -0x18(%ebp),%eax
801060a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801060a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060ad:	e8 a2 f6 ff ff       	call   80105754 <argstr>
801060b2:	85 c0                	test   %eax,%eax
801060b4:	78 17                	js     801060cd <sys_open+0x34>
801060b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801060b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801060bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801060c4:	e8 f1 f5 ff ff       	call   801056ba <argint>
801060c9:	85 c0                	test   %eax,%eax
801060cb:	79 0a                	jns    801060d7 <sys_open+0x3e>
    return -1;
801060cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d2:	e9 46 01 00 00       	jmp    8010621d <sys_open+0x184>
  if(omode & O_CREATE){
801060d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060da:	25 00 02 00 00       	and    $0x200,%eax
801060df:	85 c0                	test   %eax,%eax
801060e1:	74 40                	je     80106123 <sys_open+0x8a>
    begin_trans();
801060e3:	e8 89 d4 ff ff       	call   80103571 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
801060e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801060f2:	00 
801060f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801060fa:	00 
801060fb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106102:	00 
80106103:	89 04 24             	mov    %eax,(%esp)
80106106:	e8 ce fd ff ff       	call   80105ed9 <create>
8010610b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
8010610e:	e8 a7 d4 ff ff       	call   801035ba <commit_trans>
    if(ip == 0)
80106113:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106117:	75 5c                	jne    80106175 <sys_open+0xdc>
      return -1;
80106119:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010611e:	e9 fa 00 00 00       	jmp    8010621d <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
80106123:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106126:	89 04 24             	mov    %eax,(%esp)
80106129:	e8 30 c6 ff ff       	call   8010275e <namei>
8010612e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106131:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106135:	75 0a                	jne    80106141 <sys_open+0xa8>
      return -1;
80106137:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010613c:	e9 dc 00 00 00       	jmp    8010621d <sys_open+0x184>
    ilock(ip);
80106141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106144:	89 04 24             	mov    %eax,(%esp)
80106147:	e8 70 ba ff ff       	call   80101bbc <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010614c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010614f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106153:	66 83 f8 01          	cmp    $0x1,%ax
80106157:	75 1c                	jne    80106175 <sys_open+0xdc>
80106159:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010615c:	85 c0                	test   %eax,%eax
8010615e:	74 15                	je     80106175 <sys_open+0xdc>
      iunlockput(ip);
80106160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106163:	89 04 24             	mov    %eax,(%esp)
80106166:	e8 d5 bc ff ff       	call   80101e40 <iunlockput>
      return -1;
8010616b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106170:	e9 a8 00 00 00       	jmp    8010621d <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106175:	e8 f6 b0 ff ff       	call   80101270 <filealloc>
8010617a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010617d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106181:	74 14                	je     80106197 <sys_open+0xfe>
80106183:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106186:	89 04 24             	mov    %eax,(%esp)
80106189:	e8 43 f7 ff ff       	call   801058d1 <fdalloc>
8010618e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106191:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106195:	79 23                	jns    801061ba <sys_open+0x121>
    if(f)
80106197:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010619b:	74 0b                	je     801061a8 <sys_open+0x10f>
      fileclose(f);
8010619d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a0:	89 04 24             	mov    %eax,(%esp)
801061a3:	e8 70 b1 ff ff       	call   80101318 <fileclose>
    iunlockput(ip);
801061a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ab:	89 04 24             	mov    %eax,(%esp)
801061ae:	e8 8d bc ff ff       	call   80101e40 <iunlockput>
    return -1;
801061b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b8:	eb 63                	jmp    8010621d <sys_open+0x184>
  }
  iunlock(ip);
801061ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061bd:	89 04 24             	mov    %eax,(%esp)
801061c0:	e8 45 bb ff ff       	call   80101d0a <iunlock>

  f->type = FD_INODE;
801061c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c8:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801061ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061d4:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801061d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061da:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801061e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061e4:	83 e0 01             	and    $0x1,%eax
801061e7:	85 c0                	test   %eax,%eax
801061e9:	0f 94 c2             	sete   %dl
801061ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ef:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801061f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061f5:	83 e0 01             	and    $0x1,%eax
801061f8:	84 c0                	test   %al,%al
801061fa:	75 0a                	jne    80106206 <sys_open+0x16d>
801061fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061ff:	83 e0 02             	and    $0x2,%eax
80106202:	85 c0                	test   %eax,%eax
80106204:	74 07                	je     8010620d <sys_open+0x174>
80106206:	b8 01 00 00 00       	mov    $0x1,%eax
8010620b:	eb 05                	jmp    80106212 <sys_open+0x179>
8010620d:	b8 00 00 00 00       	mov    $0x0,%eax
80106212:	89 c2                	mov    %eax,%edx
80106214:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106217:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010621a:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010621d:	c9                   	leave  
8010621e:	c3                   	ret    

8010621f <sys_mkdir>:

int
sys_mkdir(void)
{
8010621f:	55                   	push   %ebp
80106220:	89 e5                	mov    %esp,%ebp
80106222:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80106225:	e8 47 d3 ff ff       	call   80103571 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010622a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010622d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106231:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106238:	e8 17 f5 ff ff       	call   80105754 <argstr>
8010623d:	85 c0                	test   %eax,%eax
8010623f:	78 2c                	js     8010626d <sys_mkdir+0x4e>
80106241:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106244:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010624b:	00 
8010624c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106253:	00 
80106254:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010625b:	00 
8010625c:	89 04 24             	mov    %eax,(%esp)
8010625f:	e8 75 fc ff ff       	call   80105ed9 <create>
80106264:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106267:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010626b:	75 0c                	jne    80106279 <sys_mkdir+0x5a>
    commit_trans();
8010626d:	e8 48 d3 ff ff       	call   801035ba <commit_trans>
    return -1;
80106272:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106277:	eb 15                	jmp    8010628e <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106279:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627c:	89 04 24             	mov    %eax,(%esp)
8010627f:	e8 bc bb ff ff       	call   80101e40 <iunlockput>
  commit_trans();
80106284:	e8 31 d3 ff ff       	call   801035ba <commit_trans>
  return 0;
80106289:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010628e:	c9                   	leave  
8010628f:	c3                   	ret    

80106290 <sys_mknod>:

int
sys_mknod(void)
{
80106290:	55                   	push   %ebp
80106291:	89 e5                	mov    %esp,%ebp
80106293:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80106296:	e8 d6 d2 ff ff       	call   80103571 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
8010629b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010629e:	89 44 24 04          	mov    %eax,0x4(%esp)
801062a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062a9:	e8 a6 f4 ff ff       	call   80105754 <argstr>
801062ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062b5:	78 5e                	js     80106315 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
801062b7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801062be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062c5:	e8 f0 f3 ff ff       	call   801056ba <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
801062ca:	85 c0                	test   %eax,%eax
801062cc:	78 47                	js     80106315 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801062ce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801062d5:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801062dc:	e8 d9 f3 ff ff       	call   801056ba <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801062e1:	85 c0                	test   %eax,%eax
801062e3:	78 30                	js     80106315 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801062e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062e8:	0f bf c8             	movswl %ax,%ecx
801062eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062ee:	0f bf d0             	movswl %ax,%edx
801062f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801062f4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801062f8:	89 54 24 08          	mov    %edx,0x8(%esp)
801062fc:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106303:	00 
80106304:	89 04 24             	mov    %eax,(%esp)
80106307:	e8 cd fb ff ff       	call   80105ed9 <create>
8010630c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010630f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106313:	75 0c                	jne    80106321 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80106315:	e8 a0 d2 ff ff       	call   801035ba <commit_trans>
    return -1;
8010631a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631f:	eb 15                	jmp    80106336 <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106321:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106324:	89 04 24             	mov    %eax,(%esp)
80106327:	e8 14 bb ff ff       	call   80101e40 <iunlockput>
  commit_trans();
8010632c:	e8 89 d2 ff ff       	call   801035ba <commit_trans>
  return 0;
80106331:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106336:	c9                   	leave  
80106337:	c3                   	ret    

80106338 <sys_chdir>:

int
sys_chdir(void)
{
80106338:	55                   	push   %ebp
80106339:	89 e5                	mov    %esp,%ebp
8010633b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
8010633e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106341:	89 44 24 04          	mov    %eax,0x4(%esp)
80106345:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010634c:	e8 03 f4 ff ff       	call   80105754 <argstr>
80106351:	85 c0                	test   %eax,%eax
80106353:	78 14                	js     80106369 <sys_chdir+0x31>
80106355:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106358:	89 04 24             	mov    %eax,(%esp)
8010635b:	e8 fe c3 ff ff       	call   8010275e <namei>
80106360:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106363:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106367:	75 07                	jne    80106370 <sys_chdir+0x38>
    return -1;
80106369:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010636e:	eb 57                	jmp    801063c7 <sys_chdir+0x8f>
  ilock(ip);
80106370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106373:	89 04 24             	mov    %eax,(%esp)
80106376:	e8 41 b8 ff ff       	call   80101bbc <ilock>
  if(ip->type != T_DIR){
8010637b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106382:	66 83 f8 01          	cmp    $0x1,%ax
80106386:	74 12                	je     8010639a <sys_chdir+0x62>
    iunlockput(ip);
80106388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010638b:	89 04 24             	mov    %eax,(%esp)
8010638e:	e8 ad ba ff ff       	call   80101e40 <iunlockput>
    return -1;
80106393:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106398:	eb 2d                	jmp    801063c7 <sys_chdir+0x8f>
  }
  iunlock(ip);
8010639a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639d:	89 04 24             	mov    %eax,(%esp)
801063a0:	e8 65 b9 ff ff       	call   80101d0a <iunlock>
  iput(proc->cwd);
801063a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063ab:	8b 40 68             	mov    0x68(%eax),%eax
801063ae:	89 04 24             	mov    %eax,(%esp)
801063b1:	e8 b9 b9 ff ff       	call   80101d6f <iput>
  proc->cwd = ip;
801063b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063bf:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801063c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063c7:	c9                   	leave  
801063c8:	c3                   	ret    

801063c9 <sys_exec>:

int
sys_exec(void)
{
801063c9:	55                   	push   %ebp
801063ca:	89 e5                	mov    %esp,%ebp
801063cc:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801063d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801063d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063e0:	e8 6f f3 ff ff       	call   80105754 <argstr>
801063e5:	85 c0                	test   %eax,%eax
801063e7:	78 1a                	js     80106403 <sys_exec+0x3a>
801063e9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801063ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801063f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801063fa:	e8 bb f2 ff ff       	call   801056ba <argint>
801063ff:	85 c0                	test   %eax,%eax
80106401:	79 0a                	jns    8010640d <sys_exec+0x44>
    return -1;
80106403:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106408:	e9 e2 00 00 00       	jmp    801064ef <sys_exec+0x126>
  }
  memset(argv, 0, sizeof(argv));
8010640d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106414:	00 
80106415:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010641c:	00 
8010641d:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106423:	89 04 24             	mov    %eax,(%esp)
80106426:	e8 3f ef ff ff       	call   8010536a <memset>
  for(i=0;; i++){
8010642b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106435:	83 f8 1f             	cmp    $0x1f,%eax
80106438:	76 0a                	jbe    80106444 <sys_exec+0x7b>
      return -1;
8010643a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643f:	e9 ab 00 00 00       	jmp    801064ef <sys_exec+0x126>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
80106444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106447:	c1 e0 02             	shl    $0x2,%eax
8010644a:	89 c2                	mov    %eax,%edx
8010644c:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106452:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80106455:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010645b:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
80106461:	89 54 24 08          	mov    %edx,0x8(%esp)
80106465:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80106469:	89 04 24             	mov    %eax,(%esp)
8010646c:	e8 b7 f1 ff ff       	call   80105628 <fetchint>
80106471:	85 c0                	test   %eax,%eax
80106473:	79 07                	jns    8010647c <sys_exec+0xb3>
      return -1;
80106475:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010647a:	eb 73                	jmp    801064ef <sys_exec+0x126>
    if(uarg == 0){
8010647c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106482:	85 c0                	test   %eax,%eax
80106484:	75 26                	jne    801064ac <sys_exec+0xe3>
      argv[i] = 0;
80106486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106489:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106490:	00 00 00 00 
      break;
80106494:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106495:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106498:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010649e:	89 54 24 04          	mov    %edx,0x4(%esp)
801064a2:	89 04 24             	mov    %eax,(%esp)
801064a5:	e8 a6 a9 ff ff       	call   80100e50 <exec>
801064aa:	eb 43                	jmp    801064ef <sys_exec+0x126>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
801064ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801064b6:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064bc:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
801064bf:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
801064c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801064cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801064d3:	89 04 24             	mov    %eax,(%esp)
801064d6:	e8 81 f1 ff ff       	call   8010565c <fetchstr>
801064db:	85 c0                	test   %eax,%eax
801064dd:	79 07                	jns    801064e6 <sys_exec+0x11d>
      return -1;
801064df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e4:	eb 09                	jmp    801064ef <sys_exec+0x126>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801064e6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
801064ea:	e9 43 ff ff ff       	jmp    80106432 <sys_exec+0x69>
  return exec(path, argv);
}
801064ef:	c9                   	leave  
801064f0:	c3                   	ret    

801064f1 <sys_pipe>:

int
sys_pipe(void)
{
801064f1:	55                   	push   %ebp
801064f2:	89 e5                	mov    %esp,%ebp
801064f4:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801064f7:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801064fe:	00 
801064ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106502:	89 44 24 04          	mov    %eax,0x4(%esp)
80106506:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010650d:	e8 e0 f1 ff ff       	call   801056f2 <argptr>
80106512:	85 c0                	test   %eax,%eax
80106514:	79 0a                	jns    80106520 <sys_pipe+0x2f>
    return -1;
80106516:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651b:	e9 9b 00 00 00       	jmp    801065bb <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106520:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106523:	89 44 24 04          	mov    %eax,0x4(%esp)
80106527:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010652a:	89 04 24             	mov    %eax,(%esp)
8010652d:	e8 5a da ff ff       	call   80103f8c <pipealloc>
80106532:	85 c0                	test   %eax,%eax
80106534:	79 07                	jns    8010653d <sys_pipe+0x4c>
    return -1;
80106536:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010653b:	eb 7e                	jmp    801065bb <sys_pipe+0xca>
  fd0 = -1;
8010653d:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106544:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106547:	89 04 24             	mov    %eax,(%esp)
8010654a:	e8 82 f3 ff ff       	call   801058d1 <fdalloc>
8010654f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106552:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106556:	78 14                	js     8010656c <sys_pipe+0x7b>
80106558:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010655b:	89 04 24             	mov    %eax,(%esp)
8010655e:	e8 6e f3 ff ff       	call   801058d1 <fdalloc>
80106563:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106566:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010656a:	79 37                	jns    801065a3 <sys_pipe+0xb2>
    if(fd0 >= 0)
8010656c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106570:	78 14                	js     80106586 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106572:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106578:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010657b:	83 c2 08             	add    $0x8,%edx
8010657e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106585:	00 
    fileclose(rf);
80106586:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106589:	89 04 24             	mov    %eax,(%esp)
8010658c:	e8 87 ad ff ff       	call   80101318 <fileclose>
    fileclose(wf);
80106591:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106594:	89 04 24             	mov    %eax,(%esp)
80106597:	e8 7c ad ff ff       	call   80101318 <fileclose>
    return -1;
8010659c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a1:	eb 18                	jmp    801065bb <sys_pipe+0xca>
  }
  fd[0] = fd0;
801065a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065a9:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801065ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065ae:	8d 50 04             	lea    0x4(%eax),%edx
801065b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065b4:	89 02                	mov    %eax,(%edx)
  return 0;
801065b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065bb:	c9                   	leave  
801065bc:	c3                   	ret    
801065bd:	00 00                	add    %al,(%eax)
	...

801065c0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801065c0:	55                   	push   %ebp
801065c1:	89 e5                	mov    %esp,%ebp
801065c3:	83 ec 08             	sub    $0x8,%esp
  return fork();
801065c6:	e8 7e e0 ff ff       	call   80104649 <fork>
}
801065cb:	c9                   	leave  
801065cc:	c3                   	ret    

801065cd <sys_exit>:

int
sys_exit(void)
{
801065cd:	55                   	push   %ebp
801065ce:	89 e5                	mov    %esp,%ebp
801065d0:	83 ec 08             	sub    $0x8,%esp
  exit();
801065d3:	e8 06 e2 ff ff       	call   801047de <exit>
  return 0;  // not reached
801065d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065dd:	c9                   	leave  
801065de:	c3                   	ret    

801065df <sys_wait>:

int
sys_wait(void)
{
801065df:	55                   	push   %ebp
801065e0:	89 e5                	mov    %esp,%ebp
801065e2:	83 ec 08             	sub    $0x8,%esp
  return wait();
801065e5:	e8 39 e3 ff ff       	call   80104923 <wait>
}
801065ea:	c9                   	leave  
801065eb:	c3                   	ret    

801065ec <sys_wait2>:

int
sys_wait2(void)
{
801065ec:	55                   	push   %ebp
801065ed:	89 e5                	mov    %esp,%ebp
801065ef:	83 ec 28             	sub    $0x28,%esp
  char *rtime=0;
801065f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  char *wtime=0;
801065f9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  argptr(1,&rtime,sizeof(rtime));
80106600:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106607:	00 
80106608:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010660b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010660f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106616:	e8 d7 f0 ff ff       	call   801056f2 <argptr>
  argptr(0,&wtime,sizeof(wtime));
8010661b:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106622:	00 
80106623:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106626:	89 44 24 04          	mov    %eax,0x4(%esp)
8010662a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106631:	e8 bc f0 ff ff       	call   801056f2 <argptr>
  return wait2((int*)wtime, (int*)rtime);
80106636:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106639:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010663c:	89 54 24 04          	mov    %edx,0x4(%esp)
80106640:	89 04 24             	mov    %eax,(%esp)
80106643:	e8 ed e3 ff ff       	call   80104a35 <wait2>
}
80106648:	c9                   	leave  
80106649:	c3                   	ret    

8010664a <sys_kill>:

int
sys_kill(void)
{
8010664a:	55                   	push   %ebp
8010664b:	89 e5                	mov    %esp,%ebp
8010664d:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106650:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106653:	89 44 24 04          	mov    %eax,0x4(%esp)
80106657:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010665e:	e8 57 f0 ff ff       	call   801056ba <argint>
80106663:	85 c0                	test   %eax,%eax
80106665:	79 07                	jns    8010666e <sys_kill+0x24>
    return -1;
80106667:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010666c:	eb 0b                	jmp    80106679 <sys_kill+0x2f>
  return kill(pid);
8010666e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106671:	89 04 24             	mov    %eax,(%esp)
80106674:	e8 c3 e8 ff ff       	call   80104f3c <kill>
}
80106679:	c9                   	leave  
8010667a:	c3                   	ret    

8010667b <sys_getpid>:

int
sys_getpid(void)
{
8010667b:	55                   	push   %ebp
8010667c:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010667e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106684:	8b 40 10             	mov    0x10(%eax),%eax
}
80106687:	5d                   	pop    %ebp
80106688:	c3                   	ret    

80106689 <sys_sbrk>:

int
sys_sbrk(void)
{
80106689:	55                   	push   %ebp
8010668a:	89 e5                	mov    %esp,%ebp
8010668c:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010668f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106692:	89 44 24 04          	mov    %eax,0x4(%esp)
80106696:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010669d:	e8 18 f0 ff ff       	call   801056ba <argint>
801066a2:	85 c0                	test   %eax,%eax
801066a4:	79 07                	jns    801066ad <sys_sbrk+0x24>
    return -1;
801066a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ab:	eb 24                	jmp    801066d1 <sys_sbrk+0x48>
  addr = proc->sz;
801066ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066b3:	8b 00                	mov    (%eax),%eax
801066b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801066b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066bb:	89 04 24             	mov    %eax,(%esp)
801066be:	e8 e1 de ff ff       	call   801045a4 <growproc>
801066c3:	85 c0                	test   %eax,%eax
801066c5:	79 07                	jns    801066ce <sys_sbrk+0x45>
    return -1;
801066c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066cc:	eb 03                	jmp    801066d1 <sys_sbrk+0x48>
  return addr;
801066ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066d1:	c9                   	leave  
801066d2:	c3                   	ret    

801066d3 <sys_sleep>:

int
sys_sleep(void)
{
801066d3:	55                   	push   %ebp
801066d4:	89 e5                	mov    %esp,%ebp
801066d6:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801066d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801066e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066e7:	e8 ce ef ff ff       	call   801056ba <argint>
801066ec:	85 c0                	test   %eax,%eax
801066ee:	79 07                	jns    801066f7 <sys_sleep+0x24>
    return -1;
801066f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f5:	eb 6c                	jmp    80106763 <sys_sleep+0x90>
  acquire(&tickslock);
801066f7:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801066fe:	e8 18 ea ff ff       	call   8010511b <acquire>
  ticks0 = ticks;
80106703:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80106708:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010670b:	eb 34                	jmp    80106741 <sys_sleep+0x6e>
    if(proc->killed){
8010670d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106713:	8b 40 24             	mov    0x24(%eax),%eax
80106716:	85 c0                	test   %eax,%eax
80106718:	74 13                	je     8010672d <sys_sleep+0x5a>
      release(&tickslock);
8010671a:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106721:	e8 57 ea ff ff       	call   8010517d <release>
      return -1;
80106726:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010672b:	eb 36                	jmp    80106763 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010672d:	c7 44 24 04 80 21 11 	movl   $0x80112180,0x4(%esp)
80106734:	80 
80106735:	c7 04 24 c0 29 11 80 	movl   $0x801129c0,(%esp)
8010673c:	e8 f4 e6 ff ff       	call   80104e35 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106741:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80106746:	89 c2                	mov    %eax,%edx
80106748:	2b 55 f4             	sub    -0xc(%ebp),%edx
8010674b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010674e:	39 c2                	cmp    %eax,%edx
80106750:	72 bb                	jb     8010670d <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106752:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106759:	e8 1f ea ff ff       	call   8010517d <release>
  return 0;
8010675e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106763:	c9                   	leave  
80106764:	c3                   	ret    

80106765 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106765:	55                   	push   %ebp
80106766:	89 e5                	mov    %esp,%ebp
80106768:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
8010676b:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106772:	e8 a4 e9 ff ff       	call   8010511b <acquire>
  xticks = ticks;
80106777:	a1 c0 29 11 80       	mov    0x801129c0,%eax
8010677c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010677f:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106786:	e8 f2 e9 ff ff       	call   8010517d <release>
  return xticks;
8010678b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010678e:	c9                   	leave  
8010678f:	c3                   	ret    

80106790 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106790:	55                   	push   %ebp
80106791:	89 e5                	mov    %esp,%ebp
80106793:	83 ec 08             	sub    $0x8,%esp
80106796:	8b 55 08             	mov    0x8(%ebp),%edx
80106799:	8b 45 0c             	mov    0xc(%ebp),%eax
8010679c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801067a0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801067a3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801067a7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801067ab:	ee                   	out    %al,(%dx)
}
801067ac:	c9                   	leave  
801067ad:	c3                   	ret    

801067ae <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801067ae:	55                   	push   %ebp
801067af:	89 e5                	mov    %esp,%ebp
801067b1:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801067b4:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801067bb:	00 
801067bc:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801067c3:	e8 c8 ff ff ff       	call   80106790 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801067c8:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801067cf:	00 
801067d0:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801067d7:	e8 b4 ff ff ff       	call   80106790 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801067dc:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801067e3:	00 
801067e4:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801067eb:	e8 a0 ff ff ff       	call   80106790 <outb>
  picenable(IRQ_TIMER);
801067f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067f7:	e8 19 d6 ff ff       	call   80103e15 <picenable>
}
801067fc:	c9                   	leave  
801067fd:	c3                   	ret    
	...

80106800 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106800:	1e                   	push   %ds
  pushl %es
80106801:	06                   	push   %es
  pushl %fs
80106802:	0f a0                	push   %fs
  pushl %gs
80106804:	0f a8                	push   %gs
  pushal
80106806:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106807:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010680b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010680d:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010680f:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106813:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106815:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106817:	54                   	push   %esp
  call trap
80106818:	e8 de 01 00 00       	call   801069fb <trap>
  addl $4, %esp
8010681d:	83 c4 04             	add    $0x4,%esp

80106820 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106820:	61                   	popa   
  popl %gs
80106821:	0f a9                	pop    %gs
  popl %fs
80106823:	0f a1                	pop    %fs
  popl %es
80106825:	07                   	pop    %es
  popl %ds
80106826:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106827:	83 c4 08             	add    $0x8,%esp
  iret
8010682a:	cf                   	iret   
	...

8010682c <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010682c:	55                   	push   %ebp
8010682d:	89 e5                	mov    %esp,%ebp
8010682f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106832:	8b 45 0c             	mov    0xc(%ebp),%eax
80106835:	83 e8 01             	sub    $0x1,%eax
80106838:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010683c:	8b 45 08             	mov    0x8(%ebp),%eax
8010683f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106843:	8b 45 08             	mov    0x8(%ebp),%eax
80106846:	c1 e8 10             	shr    $0x10,%eax
80106849:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010684d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106850:	0f 01 18             	lidtl  (%eax)
}
80106853:	c9                   	leave  
80106854:	c3                   	ret    

80106855 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106855:	55                   	push   %ebp
80106856:	89 e5                	mov    %esp,%ebp
80106858:	53                   	push   %ebx
80106859:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010685c:	0f 20 d3             	mov    %cr2,%ebx
8010685f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106862:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106865:	83 c4 10             	add    $0x10,%esp
80106868:	5b                   	pop    %ebx
80106869:	5d                   	pop    %ebp
8010686a:	c3                   	ret    

8010686b <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010686b:	55                   	push   %ebp
8010686c:	89 e5                	mov    %esp,%ebp
8010686e:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106871:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106878:	e9 c3 00 00 00       	jmp    80106940 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010687d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106880:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
80106887:	89 c2                	mov    %eax,%edx
80106889:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010688c:	66 89 14 c5 c0 21 11 	mov    %dx,-0x7feede40(,%eax,8)
80106893:	80 
80106894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106897:	66 c7 04 c5 c2 21 11 	movw   $0x8,-0x7feede3e(,%eax,8)
8010689e:	80 08 00 
801068a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a4:	0f b6 14 c5 c4 21 11 	movzbl -0x7feede3c(,%eax,8),%edx
801068ab:	80 
801068ac:	83 e2 e0             	and    $0xffffffe0,%edx
801068af:	88 14 c5 c4 21 11 80 	mov    %dl,-0x7feede3c(,%eax,8)
801068b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068b9:	0f b6 14 c5 c4 21 11 	movzbl -0x7feede3c(,%eax,8),%edx
801068c0:	80 
801068c1:	83 e2 1f             	and    $0x1f,%edx
801068c4:	88 14 c5 c4 21 11 80 	mov    %dl,-0x7feede3c(,%eax,8)
801068cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ce:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
801068d5:	80 
801068d6:	83 e2 f0             	and    $0xfffffff0,%edx
801068d9:	83 ca 0e             	or     $0xe,%edx
801068dc:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
801068e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e6:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
801068ed:	80 
801068ee:	83 e2 ef             	and    $0xffffffef,%edx
801068f1:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
801068f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068fb:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
80106902:	80 
80106903:	83 e2 9f             	and    $0xffffff9f,%edx
80106906:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
8010690d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106910:	0f b6 14 c5 c5 21 11 	movzbl -0x7feede3b(,%eax,8),%edx
80106917:	80 
80106918:	83 ca 80             	or     $0xffffff80,%edx
8010691b:	88 14 c5 c5 21 11 80 	mov    %dl,-0x7feede3b(,%eax,8)
80106922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106925:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
8010692c:	c1 e8 10             	shr    $0x10,%eax
8010692f:	89 c2                	mov    %eax,%edx
80106931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106934:	66 89 14 c5 c6 21 11 	mov    %dx,-0x7feede3a(,%eax,8)
8010693b:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010693c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106940:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106947:	0f 8e 30 ff ff ff    	jle    8010687d <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010694d:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
80106952:	66 a3 c0 23 11 80    	mov    %ax,0x801123c0
80106958:	66 c7 05 c2 23 11 80 	movw   $0x8,0x801123c2
8010695f:	08 00 
80106961:	0f b6 05 c4 23 11 80 	movzbl 0x801123c4,%eax
80106968:	83 e0 e0             	and    $0xffffffe0,%eax
8010696b:	a2 c4 23 11 80       	mov    %al,0x801123c4
80106970:	0f b6 05 c4 23 11 80 	movzbl 0x801123c4,%eax
80106977:	83 e0 1f             	and    $0x1f,%eax
8010697a:	a2 c4 23 11 80       	mov    %al,0x801123c4
8010697f:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
80106986:	83 c8 0f             	or     $0xf,%eax
80106989:	a2 c5 23 11 80       	mov    %al,0x801123c5
8010698e:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
80106995:	83 e0 ef             	and    $0xffffffef,%eax
80106998:	a2 c5 23 11 80       	mov    %al,0x801123c5
8010699d:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
801069a4:	83 c8 60             	or     $0x60,%eax
801069a7:	a2 c5 23 11 80       	mov    %al,0x801123c5
801069ac:	0f b6 05 c5 23 11 80 	movzbl 0x801123c5,%eax
801069b3:	83 c8 80             	or     $0xffffff80,%eax
801069b6:	a2 c5 23 11 80       	mov    %al,0x801123c5
801069bb:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
801069c0:	c1 e8 10             	shr    $0x10,%eax
801069c3:	66 a3 c6 23 11 80    	mov    %ax,0x801123c6
  
  initlock(&tickslock, "time");
801069c9:	c7 44 24 04 d0 8b 10 	movl   $0x80108bd0,0x4(%esp)
801069d0:	80 
801069d1:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801069d8:	e8 1d e7 ff ff       	call   801050fa <initlock>
}
801069dd:	c9                   	leave  
801069de:	c3                   	ret    

801069df <idtinit>:

void
idtinit(void)
{
801069df:	55                   	push   %ebp
801069e0:	89 e5                	mov    %esp,%ebp
801069e2:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801069e5:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801069ec:	00 
801069ed:	c7 04 24 c0 21 11 80 	movl   $0x801121c0,(%esp)
801069f4:	e8 33 fe ff ff       	call   8010682c <lidt>
}
801069f9:	c9                   	leave  
801069fa:	c3                   	ret    

801069fb <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801069fb:	55                   	push   %ebp
801069fc:	89 e5                	mov    %esp,%ebp
801069fe:	57                   	push   %edi
801069ff:	56                   	push   %esi
80106a00:	53                   	push   %ebx
80106a01:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106a04:	8b 45 08             	mov    0x8(%ebp),%eax
80106a07:	8b 40 30             	mov    0x30(%eax),%eax
80106a0a:	83 f8 40             	cmp    $0x40,%eax
80106a0d:	75 3e                	jne    80106a4d <trap+0x52>
    if(proc->killed)
80106a0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a15:	8b 40 24             	mov    0x24(%eax),%eax
80106a18:	85 c0                	test   %eax,%eax
80106a1a:	74 05                	je     80106a21 <trap+0x26>
      exit();
80106a1c:	e8 bd dd ff ff       	call   801047de <exit>
    proc->tf = tf;
80106a21:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a27:	8b 55 08             	mov    0x8(%ebp),%edx
80106a2a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106a2d:	e8 65 ed ff ff       	call   80105797 <syscall>
    if(proc->killed)
80106a32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a38:	8b 40 24             	mov    0x24(%eax),%eax
80106a3b:	85 c0                	test   %eax,%eax
80106a3d:	0f 84 34 02 00 00    	je     80106c77 <trap+0x27c>
      exit();
80106a43:	e8 96 dd ff ff       	call   801047de <exit>
    return;
80106a48:	e9 2a 02 00 00       	jmp    80106c77 <trap+0x27c>
  }

  switch(tf->trapno){
80106a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80106a50:	8b 40 30             	mov    0x30(%eax),%eax
80106a53:	83 e8 20             	sub    $0x20,%eax
80106a56:	83 f8 1f             	cmp    $0x1f,%eax
80106a59:	0f 87 bc 00 00 00    	ja     80106b1b <trap+0x120>
80106a5f:	8b 04 85 78 8c 10 80 	mov    -0x7fef7388(,%eax,4),%eax
80106a66:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106a68:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a6e:	0f b6 00             	movzbl (%eax),%eax
80106a71:	84 c0                	test   %al,%al
80106a73:	75 31                	jne    80106aa6 <trap+0xab>
      acquire(&tickslock);
80106a75:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106a7c:	e8 9a e6 ff ff       	call   8010511b <acquire>
      ticks++;
80106a81:	a1 c0 29 11 80       	mov    0x801129c0,%eax
80106a86:	83 c0 01             	add    $0x1,%eax
80106a89:	a3 c0 29 11 80       	mov    %eax,0x801129c0
      wakeup(&ticks);
80106a8e:	c7 04 24 c0 29 11 80 	movl   $0x801129c0,(%esp)
80106a95:	e8 77 e4 ff ff       	call   80104f11 <wakeup>
      release(&tickslock);
80106a9a:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80106aa1:	e8 d7 e6 ff ff       	call   8010517d <release>
    }
    lapiceoi();
80106aa6:	e8 92 c7 ff ff       	call   8010323d <lapiceoi>
    break;
80106aab:	e9 41 01 00 00       	jmp    80106bf1 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106ab0:	e8 90 bf ff ff       	call   80102a45 <ideintr>
    lapiceoi();
80106ab5:	e8 83 c7 ff ff       	call   8010323d <lapiceoi>
    break;
80106aba:	e9 32 01 00 00       	jmp    80106bf1 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106abf:	e8 57 c5 ff ff       	call   8010301b <kbdintr>
    lapiceoi();
80106ac4:	e8 74 c7 ff ff       	call   8010323d <lapiceoi>
    break;
80106ac9:	e9 23 01 00 00       	jmp    80106bf1 <trap+0x1f6>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106ace:	e8 a9 03 00 00       	call   80106e7c <uartintr>
    lapiceoi();
80106ad3:	e8 65 c7 ff ff       	call   8010323d <lapiceoi>
    break;
80106ad8:	e9 14 01 00 00       	jmp    80106bf1 <trap+0x1f6>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106add:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ae0:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106ae3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106aea:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106aed:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106af3:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106af6:	0f b6 c0             	movzbl %al,%eax
80106af9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106afd:	89 54 24 08          	mov    %edx,0x8(%esp)
80106b01:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b05:	c7 04 24 d8 8b 10 80 	movl   $0x80108bd8,(%esp)
80106b0c:	e8 90 98 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106b11:	e8 27 c7 ff ff       	call   8010323d <lapiceoi>
    break;
80106b16:	e9 d6 00 00 00       	jmp    80106bf1 <trap+0x1f6>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106b1b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b21:	85 c0                	test   %eax,%eax
80106b23:	74 11                	je     80106b36 <trap+0x13b>
80106b25:	8b 45 08             	mov    0x8(%ebp),%eax
80106b28:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b2c:	0f b7 c0             	movzwl %ax,%eax
80106b2f:	83 e0 03             	and    $0x3,%eax
80106b32:	85 c0                	test   %eax,%eax
80106b34:	75 46                	jne    80106b7c <trap+0x181>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b36:	e8 1a fd ff ff       	call   80106855 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106b3b:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b3e:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106b41:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106b48:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b4b:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106b4e:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b51:	8b 52 30             	mov    0x30(%edx),%edx
80106b54:	89 44 24 10          	mov    %eax,0x10(%esp)
80106b58:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106b5c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106b60:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b64:	c7 04 24 fc 8b 10 80 	movl   $0x80108bfc,(%esp)
80106b6b:	e8 31 98 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106b70:	c7 04 24 2e 8c 10 80 	movl   $0x80108c2e,(%esp)
80106b77:	e8 c1 99 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b7c:	e8 d4 fc ff ff       	call   80106855 <rcr2>
80106b81:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b83:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b86:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b89:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b8f:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b92:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b95:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b98:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b9b:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b9e:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106ba1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ba7:	83 c0 6c             	add    $0x6c,%eax
80106baa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106bad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106bb3:	8b 40 10             	mov    0x10(%eax),%eax
80106bb6:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106bba:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106bbe:	89 74 24 14          	mov    %esi,0x14(%esp)
80106bc2:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106bc6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106bca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106bcd:	89 54 24 08          	mov    %edx,0x8(%esp)
80106bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bd5:	c7 04 24 34 8c 10 80 	movl   $0x80108c34,(%esp)
80106bdc:	e8 c0 97 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106be1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106be7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106bee:	eb 01                	jmp    80106bf1 <trap+0x1f6>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106bf0:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106bf1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bf7:	85 c0                	test   %eax,%eax
80106bf9:	74 24                	je     80106c1f <trap+0x224>
80106bfb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c01:	8b 40 24             	mov    0x24(%eax),%eax
80106c04:	85 c0                	test   %eax,%eax
80106c06:	74 17                	je     80106c1f <trap+0x224>
80106c08:	8b 45 08             	mov    0x8(%ebp),%eax
80106c0b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c0f:	0f b7 c0             	movzwl %ax,%eax
80106c12:	83 e0 03             	and    $0x3,%eax
80106c15:	83 f8 03             	cmp    $0x3,%eax
80106c18:	75 05                	jne    80106c1f <trap+0x224>
    exit();
80106c1a:	e8 bf db ff ff       	call   801047de <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106c1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c25:	85 c0                	test   %eax,%eax
80106c27:	74 1e                	je     80106c47 <trap+0x24c>
80106c29:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c2f:	8b 40 0c             	mov    0xc(%eax),%eax
80106c32:	83 f8 04             	cmp    $0x4,%eax
80106c35:	75 10                	jne    80106c47 <trap+0x24c>
80106c37:	8b 45 08             	mov    0x8(%ebp),%eax
80106c3a:	8b 40 30             	mov    0x30(%eax),%eax
80106c3d:	83 f8 20             	cmp    $0x20,%eax
80106c40:	75 05                	jne    80106c47 <trap+0x24c>
    yield();
80106c42:	e8 90 e1 ff ff       	call   80104dd7 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106c47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c4d:	85 c0                	test   %eax,%eax
80106c4f:	74 27                	je     80106c78 <trap+0x27d>
80106c51:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c57:	8b 40 24             	mov    0x24(%eax),%eax
80106c5a:	85 c0                	test   %eax,%eax
80106c5c:	74 1a                	je     80106c78 <trap+0x27d>
80106c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80106c61:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c65:	0f b7 c0             	movzwl %ax,%eax
80106c68:	83 e0 03             	and    $0x3,%eax
80106c6b:	83 f8 03             	cmp    $0x3,%eax
80106c6e:	75 08                	jne    80106c78 <trap+0x27d>
    exit();
80106c70:	e8 69 db ff ff       	call   801047de <exit>
80106c75:	eb 01                	jmp    80106c78 <trap+0x27d>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106c77:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106c78:	83 c4 3c             	add    $0x3c,%esp
80106c7b:	5b                   	pop    %ebx
80106c7c:	5e                   	pop    %esi
80106c7d:	5f                   	pop    %edi
80106c7e:	5d                   	pop    %ebp
80106c7f:	c3                   	ret    

80106c80 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106c80:	55                   	push   %ebp
80106c81:	89 e5                	mov    %esp,%ebp
80106c83:	53                   	push   %ebx
80106c84:	83 ec 14             	sub    $0x14,%esp
80106c87:	8b 45 08             	mov    0x8(%ebp),%eax
80106c8a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106c8e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106c92:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106c96:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106c9a:	ec                   	in     (%dx),%al
80106c9b:	89 c3                	mov    %eax,%ebx
80106c9d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106ca0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106ca4:	83 c4 14             	add    $0x14,%esp
80106ca7:	5b                   	pop    %ebx
80106ca8:	5d                   	pop    %ebp
80106ca9:	c3                   	ret    

80106caa <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106caa:	55                   	push   %ebp
80106cab:	89 e5                	mov    %esp,%ebp
80106cad:	83 ec 08             	sub    $0x8,%esp
80106cb0:	8b 55 08             	mov    0x8(%ebp),%edx
80106cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80106cb6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106cba:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106cbd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106cc1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106cc5:	ee                   	out    %al,(%dx)
}
80106cc6:	c9                   	leave  
80106cc7:	c3                   	ret    

80106cc8 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106cc8:	55                   	push   %ebp
80106cc9:	89 e5                	mov    %esp,%ebp
80106ccb:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106cce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106cd5:	00 
80106cd6:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106cdd:	e8 c8 ff ff ff       	call   80106caa <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106ce2:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106ce9:	00 
80106cea:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106cf1:	e8 b4 ff ff ff       	call   80106caa <outb>
  outb(COM1+0, 115200/9600);
80106cf6:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106cfd:	00 
80106cfe:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d05:	e8 a0 ff ff ff       	call   80106caa <outb>
  outb(COM1+1, 0);
80106d0a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d11:	00 
80106d12:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106d19:	e8 8c ff ff ff       	call   80106caa <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106d1e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106d25:	00 
80106d26:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106d2d:	e8 78 ff ff ff       	call   80106caa <outb>
  outb(COM1+4, 0);
80106d32:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d39:	00 
80106d3a:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106d41:	e8 64 ff ff ff       	call   80106caa <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106d46:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106d4d:	00 
80106d4e:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106d55:	e8 50 ff ff ff       	call   80106caa <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106d5a:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d61:	e8 1a ff ff ff       	call   80106c80 <inb>
80106d66:	3c ff                	cmp    $0xff,%al
80106d68:	74 6c                	je     80106dd6 <uartinit+0x10e>
    return;
  uart = 1;
80106d6a:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106d71:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106d74:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106d7b:	e8 00 ff ff ff       	call   80106c80 <inb>
  inb(COM1+0);
80106d80:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d87:	e8 f4 fe ff ff       	call   80106c80 <inb>
  picenable(IRQ_COM1);
80106d8c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d93:	e8 7d d0 ff ff       	call   80103e15 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106d98:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d9f:	00 
80106da0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106da7:	e8 1e bf ff ff       	call   80102cca <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106dac:	c7 45 f4 f8 8c 10 80 	movl   $0x80108cf8,-0xc(%ebp)
80106db3:	eb 15                	jmp    80106dca <uartinit+0x102>
    uartputc(*p);
80106db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106db8:	0f b6 00             	movzbl (%eax),%eax
80106dbb:	0f be c0             	movsbl %al,%eax
80106dbe:	89 04 24             	mov    %eax,(%esp)
80106dc1:	e8 13 00 00 00       	call   80106dd9 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106dc6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dcd:	0f b6 00             	movzbl (%eax),%eax
80106dd0:	84 c0                	test   %al,%al
80106dd2:	75 e1                	jne    80106db5 <uartinit+0xed>
80106dd4:	eb 01                	jmp    80106dd7 <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106dd6:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106dd7:	c9                   	leave  
80106dd8:	c3                   	ret    

80106dd9 <uartputc>:

void
uartputc(int c)
{
80106dd9:	55                   	push   %ebp
80106dda:	89 e5                	mov    %esp,%ebp
80106ddc:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106ddf:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106de4:	85 c0                	test   %eax,%eax
80106de6:	74 4d                	je     80106e35 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106de8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106def:	eb 10                	jmp    80106e01 <uartputc+0x28>
    microdelay(10);
80106df1:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106df8:	e8 65 c4 ff ff       	call   80103262 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106dfd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e01:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106e05:	7f 16                	jg     80106e1d <uartputc+0x44>
80106e07:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e0e:	e8 6d fe ff ff       	call   80106c80 <inb>
80106e13:	0f b6 c0             	movzbl %al,%eax
80106e16:	83 e0 20             	and    $0x20,%eax
80106e19:	85 c0                	test   %eax,%eax
80106e1b:	74 d4                	je     80106df1 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106e1d:	8b 45 08             	mov    0x8(%ebp),%eax
80106e20:	0f b6 c0             	movzbl %al,%eax
80106e23:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e27:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e2e:	e8 77 fe ff ff       	call   80106caa <outb>
80106e33:	eb 01                	jmp    80106e36 <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106e35:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106e36:	c9                   	leave  
80106e37:	c3                   	ret    

80106e38 <uartgetc>:

static int
uartgetc(void)
{
80106e38:	55                   	push   %ebp
80106e39:	89 e5                	mov    %esp,%ebp
80106e3b:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106e3e:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106e43:	85 c0                	test   %eax,%eax
80106e45:	75 07                	jne    80106e4e <uartgetc+0x16>
    return -1;
80106e47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e4c:	eb 2c                	jmp    80106e7a <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106e4e:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e55:	e8 26 fe ff ff       	call   80106c80 <inb>
80106e5a:	0f b6 c0             	movzbl %al,%eax
80106e5d:	83 e0 01             	and    $0x1,%eax
80106e60:	85 c0                	test   %eax,%eax
80106e62:	75 07                	jne    80106e6b <uartgetc+0x33>
    return -1;
80106e64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e69:	eb 0f                	jmp    80106e7a <uartgetc+0x42>
  return inb(COM1+0);
80106e6b:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e72:	e8 09 fe ff ff       	call   80106c80 <inb>
80106e77:	0f b6 c0             	movzbl %al,%eax
}
80106e7a:	c9                   	leave  
80106e7b:	c3                   	ret    

80106e7c <uartintr>:

void
uartintr(void)
{
80106e7c:	55                   	push   %ebp
80106e7d:	89 e5                	mov    %esp,%ebp
80106e7f:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106e82:	c7 04 24 38 6e 10 80 	movl   $0x80106e38,(%esp)
80106e89:	e8 40 9a ff ff       	call   801008ce <consoleintr>
}
80106e8e:	c9                   	leave  
80106e8f:	c3                   	ret    

80106e90 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106e90:	6a 00                	push   $0x0
  pushl $0
80106e92:	6a 00                	push   $0x0
  jmp alltraps
80106e94:	e9 67 f9 ff ff       	jmp    80106800 <alltraps>

80106e99 <vector1>:
.globl vector1
vector1:
  pushl $0
80106e99:	6a 00                	push   $0x0
  pushl $1
80106e9b:	6a 01                	push   $0x1
  jmp alltraps
80106e9d:	e9 5e f9 ff ff       	jmp    80106800 <alltraps>

80106ea2 <vector2>:
.globl vector2
vector2:
  pushl $0
80106ea2:	6a 00                	push   $0x0
  pushl $2
80106ea4:	6a 02                	push   $0x2
  jmp alltraps
80106ea6:	e9 55 f9 ff ff       	jmp    80106800 <alltraps>

80106eab <vector3>:
.globl vector3
vector3:
  pushl $0
80106eab:	6a 00                	push   $0x0
  pushl $3
80106ead:	6a 03                	push   $0x3
  jmp alltraps
80106eaf:	e9 4c f9 ff ff       	jmp    80106800 <alltraps>

80106eb4 <vector4>:
.globl vector4
vector4:
  pushl $0
80106eb4:	6a 00                	push   $0x0
  pushl $4
80106eb6:	6a 04                	push   $0x4
  jmp alltraps
80106eb8:	e9 43 f9 ff ff       	jmp    80106800 <alltraps>

80106ebd <vector5>:
.globl vector5
vector5:
  pushl $0
80106ebd:	6a 00                	push   $0x0
  pushl $5
80106ebf:	6a 05                	push   $0x5
  jmp alltraps
80106ec1:	e9 3a f9 ff ff       	jmp    80106800 <alltraps>

80106ec6 <vector6>:
.globl vector6
vector6:
  pushl $0
80106ec6:	6a 00                	push   $0x0
  pushl $6
80106ec8:	6a 06                	push   $0x6
  jmp alltraps
80106eca:	e9 31 f9 ff ff       	jmp    80106800 <alltraps>

80106ecf <vector7>:
.globl vector7
vector7:
  pushl $0
80106ecf:	6a 00                	push   $0x0
  pushl $7
80106ed1:	6a 07                	push   $0x7
  jmp alltraps
80106ed3:	e9 28 f9 ff ff       	jmp    80106800 <alltraps>

80106ed8 <vector8>:
.globl vector8
vector8:
  pushl $8
80106ed8:	6a 08                	push   $0x8
  jmp alltraps
80106eda:	e9 21 f9 ff ff       	jmp    80106800 <alltraps>

80106edf <vector9>:
.globl vector9
vector9:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $9
80106ee1:	6a 09                	push   $0x9
  jmp alltraps
80106ee3:	e9 18 f9 ff ff       	jmp    80106800 <alltraps>

80106ee8 <vector10>:
.globl vector10
vector10:
  pushl $10
80106ee8:	6a 0a                	push   $0xa
  jmp alltraps
80106eea:	e9 11 f9 ff ff       	jmp    80106800 <alltraps>

80106eef <vector11>:
.globl vector11
vector11:
  pushl $11
80106eef:	6a 0b                	push   $0xb
  jmp alltraps
80106ef1:	e9 0a f9 ff ff       	jmp    80106800 <alltraps>

80106ef6 <vector12>:
.globl vector12
vector12:
  pushl $12
80106ef6:	6a 0c                	push   $0xc
  jmp alltraps
80106ef8:	e9 03 f9 ff ff       	jmp    80106800 <alltraps>

80106efd <vector13>:
.globl vector13
vector13:
  pushl $13
80106efd:	6a 0d                	push   $0xd
  jmp alltraps
80106eff:	e9 fc f8 ff ff       	jmp    80106800 <alltraps>

80106f04 <vector14>:
.globl vector14
vector14:
  pushl $14
80106f04:	6a 0e                	push   $0xe
  jmp alltraps
80106f06:	e9 f5 f8 ff ff       	jmp    80106800 <alltraps>

80106f0b <vector15>:
.globl vector15
vector15:
  pushl $0
80106f0b:	6a 00                	push   $0x0
  pushl $15
80106f0d:	6a 0f                	push   $0xf
  jmp alltraps
80106f0f:	e9 ec f8 ff ff       	jmp    80106800 <alltraps>

80106f14 <vector16>:
.globl vector16
vector16:
  pushl $0
80106f14:	6a 00                	push   $0x0
  pushl $16
80106f16:	6a 10                	push   $0x10
  jmp alltraps
80106f18:	e9 e3 f8 ff ff       	jmp    80106800 <alltraps>

80106f1d <vector17>:
.globl vector17
vector17:
  pushl $17
80106f1d:	6a 11                	push   $0x11
  jmp alltraps
80106f1f:	e9 dc f8 ff ff       	jmp    80106800 <alltraps>

80106f24 <vector18>:
.globl vector18
vector18:
  pushl $0
80106f24:	6a 00                	push   $0x0
  pushl $18
80106f26:	6a 12                	push   $0x12
  jmp alltraps
80106f28:	e9 d3 f8 ff ff       	jmp    80106800 <alltraps>

80106f2d <vector19>:
.globl vector19
vector19:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $19
80106f2f:	6a 13                	push   $0x13
  jmp alltraps
80106f31:	e9 ca f8 ff ff       	jmp    80106800 <alltraps>

80106f36 <vector20>:
.globl vector20
vector20:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $20
80106f38:	6a 14                	push   $0x14
  jmp alltraps
80106f3a:	e9 c1 f8 ff ff       	jmp    80106800 <alltraps>

80106f3f <vector21>:
.globl vector21
vector21:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $21
80106f41:	6a 15                	push   $0x15
  jmp alltraps
80106f43:	e9 b8 f8 ff ff       	jmp    80106800 <alltraps>

80106f48 <vector22>:
.globl vector22
vector22:
  pushl $0
80106f48:	6a 00                	push   $0x0
  pushl $22
80106f4a:	6a 16                	push   $0x16
  jmp alltraps
80106f4c:	e9 af f8 ff ff       	jmp    80106800 <alltraps>

80106f51 <vector23>:
.globl vector23
vector23:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $23
80106f53:	6a 17                	push   $0x17
  jmp alltraps
80106f55:	e9 a6 f8 ff ff       	jmp    80106800 <alltraps>

80106f5a <vector24>:
.globl vector24
vector24:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $24
80106f5c:	6a 18                	push   $0x18
  jmp alltraps
80106f5e:	e9 9d f8 ff ff       	jmp    80106800 <alltraps>

80106f63 <vector25>:
.globl vector25
vector25:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $25
80106f65:	6a 19                	push   $0x19
  jmp alltraps
80106f67:	e9 94 f8 ff ff       	jmp    80106800 <alltraps>

80106f6c <vector26>:
.globl vector26
vector26:
  pushl $0
80106f6c:	6a 00                	push   $0x0
  pushl $26
80106f6e:	6a 1a                	push   $0x1a
  jmp alltraps
80106f70:	e9 8b f8 ff ff       	jmp    80106800 <alltraps>

80106f75 <vector27>:
.globl vector27
vector27:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $27
80106f77:	6a 1b                	push   $0x1b
  jmp alltraps
80106f79:	e9 82 f8 ff ff       	jmp    80106800 <alltraps>

80106f7e <vector28>:
.globl vector28
vector28:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $28
80106f80:	6a 1c                	push   $0x1c
  jmp alltraps
80106f82:	e9 79 f8 ff ff       	jmp    80106800 <alltraps>

80106f87 <vector29>:
.globl vector29
vector29:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $29
80106f89:	6a 1d                	push   $0x1d
  jmp alltraps
80106f8b:	e9 70 f8 ff ff       	jmp    80106800 <alltraps>

80106f90 <vector30>:
.globl vector30
vector30:
  pushl $0
80106f90:	6a 00                	push   $0x0
  pushl $30
80106f92:	6a 1e                	push   $0x1e
  jmp alltraps
80106f94:	e9 67 f8 ff ff       	jmp    80106800 <alltraps>

80106f99 <vector31>:
.globl vector31
vector31:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $31
80106f9b:	6a 1f                	push   $0x1f
  jmp alltraps
80106f9d:	e9 5e f8 ff ff       	jmp    80106800 <alltraps>

80106fa2 <vector32>:
.globl vector32
vector32:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $32
80106fa4:	6a 20                	push   $0x20
  jmp alltraps
80106fa6:	e9 55 f8 ff ff       	jmp    80106800 <alltraps>

80106fab <vector33>:
.globl vector33
vector33:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $33
80106fad:	6a 21                	push   $0x21
  jmp alltraps
80106faf:	e9 4c f8 ff ff       	jmp    80106800 <alltraps>

80106fb4 <vector34>:
.globl vector34
vector34:
  pushl $0
80106fb4:	6a 00                	push   $0x0
  pushl $34
80106fb6:	6a 22                	push   $0x22
  jmp alltraps
80106fb8:	e9 43 f8 ff ff       	jmp    80106800 <alltraps>

80106fbd <vector35>:
.globl vector35
vector35:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $35
80106fbf:	6a 23                	push   $0x23
  jmp alltraps
80106fc1:	e9 3a f8 ff ff       	jmp    80106800 <alltraps>

80106fc6 <vector36>:
.globl vector36
vector36:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $36
80106fc8:	6a 24                	push   $0x24
  jmp alltraps
80106fca:	e9 31 f8 ff ff       	jmp    80106800 <alltraps>

80106fcf <vector37>:
.globl vector37
vector37:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $37
80106fd1:	6a 25                	push   $0x25
  jmp alltraps
80106fd3:	e9 28 f8 ff ff       	jmp    80106800 <alltraps>

80106fd8 <vector38>:
.globl vector38
vector38:
  pushl $0
80106fd8:	6a 00                	push   $0x0
  pushl $38
80106fda:	6a 26                	push   $0x26
  jmp alltraps
80106fdc:	e9 1f f8 ff ff       	jmp    80106800 <alltraps>

80106fe1 <vector39>:
.globl vector39
vector39:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $39
80106fe3:	6a 27                	push   $0x27
  jmp alltraps
80106fe5:	e9 16 f8 ff ff       	jmp    80106800 <alltraps>

80106fea <vector40>:
.globl vector40
vector40:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $40
80106fec:	6a 28                	push   $0x28
  jmp alltraps
80106fee:	e9 0d f8 ff ff       	jmp    80106800 <alltraps>

80106ff3 <vector41>:
.globl vector41
vector41:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $41
80106ff5:	6a 29                	push   $0x29
  jmp alltraps
80106ff7:	e9 04 f8 ff ff       	jmp    80106800 <alltraps>

80106ffc <vector42>:
.globl vector42
vector42:
  pushl $0
80106ffc:	6a 00                	push   $0x0
  pushl $42
80106ffe:	6a 2a                	push   $0x2a
  jmp alltraps
80107000:	e9 fb f7 ff ff       	jmp    80106800 <alltraps>

80107005 <vector43>:
.globl vector43
vector43:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $43
80107007:	6a 2b                	push   $0x2b
  jmp alltraps
80107009:	e9 f2 f7 ff ff       	jmp    80106800 <alltraps>

8010700e <vector44>:
.globl vector44
vector44:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $44
80107010:	6a 2c                	push   $0x2c
  jmp alltraps
80107012:	e9 e9 f7 ff ff       	jmp    80106800 <alltraps>

80107017 <vector45>:
.globl vector45
vector45:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $45
80107019:	6a 2d                	push   $0x2d
  jmp alltraps
8010701b:	e9 e0 f7 ff ff       	jmp    80106800 <alltraps>

80107020 <vector46>:
.globl vector46
vector46:
  pushl $0
80107020:	6a 00                	push   $0x0
  pushl $46
80107022:	6a 2e                	push   $0x2e
  jmp alltraps
80107024:	e9 d7 f7 ff ff       	jmp    80106800 <alltraps>

80107029 <vector47>:
.globl vector47
vector47:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $47
8010702b:	6a 2f                	push   $0x2f
  jmp alltraps
8010702d:	e9 ce f7 ff ff       	jmp    80106800 <alltraps>

80107032 <vector48>:
.globl vector48
vector48:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $48
80107034:	6a 30                	push   $0x30
  jmp alltraps
80107036:	e9 c5 f7 ff ff       	jmp    80106800 <alltraps>

8010703b <vector49>:
.globl vector49
vector49:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $49
8010703d:	6a 31                	push   $0x31
  jmp alltraps
8010703f:	e9 bc f7 ff ff       	jmp    80106800 <alltraps>

80107044 <vector50>:
.globl vector50
vector50:
  pushl $0
80107044:	6a 00                	push   $0x0
  pushl $50
80107046:	6a 32                	push   $0x32
  jmp alltraps
80107048:	e9 b3 f7 ff ff       	jmp    80106800 <alltraps>

8010704d <vector51>:
.globl vector51
vector51:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $51
8010704f:	6a 33                	push   $0x33
  jmp alltraps
80107051:	e9 aa f7 ff ff       	jmp    80106800 <alltraps>

80107056 <vector52>:
.globl vector52
vector52:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $52
80107058:	6a 34                	push   $0x34
  jmp alltraps
8010705a:	e9 a1 f7 ff ff       	jmp    80106800 <alltraps>

8010705f <vector53>:
.globl vector53
vector53:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $53
80107061:	6a 35                	push   $0x35
  jmp alltraps
80107063:	e9 98 f7 ff ff       	jmp    80106800 <alltraps>

80107068 <vector54>:
.globl vector54
vector54:
  pushl $0
80107068:	6a 00                	push   $0x0
  pushl $54
8010706a:	6a 36                	push   $0x36
  jmp alltraps
8010706c:	e9 8f f7 ff ff       	jmp    80106800 <alltraps>

80107071 <vector55>:
.globl vector55
vector55:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $55
80107073:	6a 37                	push   $0x37
  jmp alltraps
80107075:	e9 86 f7 ff ff       	jmp    80106800 <alltraps>

8010707a <vector56>:
.globl vector56
vector56:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $56
8010707c:	6a 38                	push   $0x38
  jmp alltraps
8010707e:	e9 7d f7 ff ff       	jmp    80106800 <alltraps>

80107083 <vector57>:
.globl vector57
vector57:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $57
80107085:	6a 39                	push   $0x39
  jmp alltraps
80107087:	e9 74 f7 ff ff       	jmp    80106800 <alltraps>

8010708c <vector58>:
.globl vector58
vector58:
  pushl $0
8010708c:	6a 00                	push   $0x0
  pushl $58
8010708e:	6a 3a                	push   $0x3a
  jmp alltraps
80107090:	e9 6b f7 ff ff       	jmp    80106800 <alltraps>

80107095 <vector59>:
.globl vector59
vector59:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $59
80107097:	6a 3b                	push   $0x3b
  jmp alltraps
80107099:	e9 62 f7 ff ff       	jmp    80106800 <alltraps>

8010709e <vector60>:
.globl vector60
vector60:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $60
801070a0:	6a 3c                	push   $0x3c
  jmp alltraps
801070a2:	e9 59 f7 ff ff       	jmp    80106800 <alltraps>

801070a7 <vector61>:
.globl vector61
vector61:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $61
801070a9:	6a 3d                	push   $0x3d
  jmp alltraps
801070ab:	e9 50 f7 ff ff       	jmp    80106800 <alltraps>

801070b0 <vector62>:
.globl vector62
vector62:
  pushl $0
801070b0:	6a 00                	push   $0x0
  pushl $62
801070b2:	6a 3e                	push   $0x3e
  jmp alltraps
801070b4:	e9 47 f7 ff ff       	jmp    80106800 <alltraps>

801070b9 <vector63>:
.globl vector63
vector63:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $63
801070bb:	6a 3f                	push   $0x3f
  jmp alltraps
801070bd:	e9 3e f7 ff ff       	jmp    80106800 <alltraps>

801070c2 <vector64>:
.globl vector64
vector64:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $64
801070c4:	6a 40                	push   $0x40
  jmp alltraps
801070c6:	e9 35 f7 ff ff       	jmp    80106800 <alltraps>

801070cb <vector65>:
.globl vector65
vector65:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $65
801070cd:	6a 41                	push   $0x41
  jmp alltraps
801070cf:	e9 2c f7 ff ff       	jmp    80106800 <alltraps>

801070d4 <vector66>:
.globl vector66
vector66:
  pushl $0
801070d4:	6a 00                	push   $0x0
  pushl $66
801070d6:	6a 42                	push   $0x42
  jmp alltraps
801070d8:	e9 23 f7 ff ff       	jmp    80106800 <alltraps>

801070dd <vector67>:
.globl vector67
vector67:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $67
801070df:	6a 43                	push   $0x43
  jmp alltraps
801070e1:	e9 1a f7 ff ff       	jmp    80106800 <alltraps>

801070e6 <vector68>:
.globl vector68
vector68:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $68
801070e8:	6a 44                	push   $0x44
  jmp alltraps
801070ea:	e9 11 f7 ff ff       	jmp    80106800 <alltraps>

801070ef <vector69>:
.globl vector69
vector69:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $69
801070f1:	6a 45                	push   $0x45
  jmp alltraps
801070f3:	e9 08 f7 ff ff       	jmp    80106800 <alltraps>

801070f8 <vector70>:
.globl vector70
vector70:
  pushl $0
801070f8:	6a 00                	push   $0x0
  pushl $70
801070fa:	6a 46                	push   $0x46
  jmp alltraps
801070fc:	e9 ff f6 ff ff       	jmp    80106800 <alltraps>

80107101 <vector71>:
.globl vector71
vector71:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $71
80107103:	6a 47                	push   $0x47
  jmp alltraps
80107105:	e9 f6 f6 ff ff       	jmp    80106800 <alltraps>

8010710a <vector72>:
.globl vector72
vector72:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $72
8010710c:	6a 48                	push   $0x48
  jmp alltraps
8010710e:	e9 ed f6 ff ff       	jmp    80106800 <alltraps>

80107113 <vector73>:
.globl vector73
vector73:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $73
80107115:	6a 49                	push   $0x49
  jmp alltraps
80107117:	e9 e4 f6 ff ff       	jmp    80106800 <alltraps>

8010711c <vector74>:
.globl vector74
vector74:
  pushl $0
8010711c:	6a 00                	push   $0x0
  pushl $74
8010711e:	6a 4a                	push   $0x4a
  jmp alltraps
80107120:	e9 db f6 ff ff       	jmp    80106800 <alltraps>

80107125 <vector75>:
.globl vector75
vector75:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $75
80107127:	6a 4b                	push   $0x4b
  jmp alltraps
80107129:	e9 d2 f6 ff ff       	jmp    80106800 <alltraps>

8010712e <vector76>:
.globl vector76
vector76:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $76
80107130:	6a 4c                	push   $0x4c
  jmp alltraps
80107132:	e9 c9 f6 ff ff       	jmp    80106800 <alltraps>

80107137 <vector77>:
.globl vector77
vector77:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $77
80107139:	6a 4d                	push   $0x4d
  jmp alltraps
8010713b:	e9 c0 f6 ff ff       	jmp    80106800 <alltraps>

80107140 <vector78>:
.globl vector78
vector78:
  pushl $0
80107140:	6a 00                	push   $0x0
  pushl $78
80107142:	6a 4e                	push   $0x4e
  jmp alltraps
80107144:	e9 b7 f6 ff ff       	jmp    80106800 <alltraps>

80107149 <vector79>:
.globl vector79
vector79:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $79
8010714b:	6a 4f                	push   $0x4f
  jmp alltraps
8010714d:	e9 ae f6 ff ff       	jmp    80106800 <alltraps>

80107152 <vector80>:
.globl vector80
vector80:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $80
80107154:	6a 50                	push   $0x50
  jmp alltraps
80107156:	e9 a5 f6 ff ff       	jmp    80106800 <alltraps>

8010715b <vector81>:
.globl vector81
vector81:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $81
8010715d:	6a 51                	push   $0x51
  jmp alltraps
8010715f:	e9 9c f6 ff ff       	jmp    80106800 <alltraps>

80107164 <vector82>:
.globl vector82
vector82:
  pushl $0
80107164:	6a 00                	push   $0x0
  pushl $82
80107166:	6a 52                	push   $0x52
  jmp alltraps
80107168:	e9 93 f6 ff ff       	jmp    80106800 <alltraps>

8010716d <vector83>:
.globl vector83
vector83:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $83
8010716f:	6a 53                	push   $0x53
  jmp alltraps
80107171:	e9 8a f6 ff ff       	jmp    80106800 <alltraps>

80107176 <vector84>:
.globl vector84
vector84:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $84
80107178:	6a 54                	push   $0x54
  jmp alltraps
8010717a:	e9 81 f6 ff ff       	jmp    80106800 <alltraps>

8010717f <vector85>:
.globl vector85
vector85:
  pushl $0
8010717f:	6a 00                	push   $0x0
  pushl $85
80107181:	6a 55                	push   $0x55
  jmp alltraps
80107183:	e9 78 f6 ff ff       	jmp    80106800 <alltraps>

80107188 <vector86>:
.globl vector86
vector86:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $86
8010718a:	6a 56                	push   $0x56
  jmp alltraps
8010718c:	e9 6f f6 ff ff       	jmp    80106800 <alltraps>

80107191 <vector87>:
.globl vector87
vector87:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $87
80107193:	6a 57                	push   $0x57
  jmp alltraps
80107195:	e9 66 f6 ff ff       	jmp    80106800 <alltraps>

8010719a <vector88>:
.globl vector88
vector88:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $88
8010719c:	6a 58                	push   $0x58
  jmp alltraps
8010719e:	e9 5d f6 ff ff       	jmp    80106800 <alltraps>

801071a3 <vector89>:
.globl vector89
vector89:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $89
801071a5:	6a 59                	push   $0x59
  jmp alltraps
801071a7:	e9 54 f6 ff ff       	jmp    80106800 <alltraps>

801071ac <vector90>:
.globl vector90
vector90:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $90
801071ae:	6a 5a                	push   $0x5a
  jmp alltraps
801071b0:	e9 4b f6 ff ff       	jmp    80106800 <alltraps>

801071b5 <vector91>:
.globl vector91
vector91:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $91
801071b7:	6a 5b                	push   $0x5b
  jmp alltraps
801071b9:	e9 42 f6 ff ff       	jmp    80106800 <alltraps>

801071be <vector92>:
.globl vector92
vector92:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $92
801071c0:	6a 5c                	push   $0x5c
  jmp alltraps
801071c2:	e9 39 f6 ff ff       	jmp    80106800 <alltraps>

801071c7 <vector93>:
.globl vector93
vector93:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $93
801071c9:	6a 5d                	push   $0x5d
  jmp alltraps
801071cb:	e9 30 f6 ff ff       	jmp    80106800 <alltraps>

801071d0 <vector94>:
.globl vector94
vector94:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $94
801071d2:	6a 5e                	push   $0x5e
  jmp alltraps
801071d4:	e9 27 f6 ff ff       	jmp    80106800 <alltraps>

801071d9 <vector95>:
.globl vector95
vector95:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $95
801071db:	6a 5f                	push   $0x5f
  jmp alltraps
801071dd:	e9 1e f6 ff ff       	jmp    80106800 <alltraps>

801071e2 <vector96>:
.globl vector96
vector96:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $96
801071e4:	6a 60                	push   $0x60
  jmp alltraps
801071e6:	e9 15 f6 ff ff       	jmp    80106800 <alltraps>

801071eb <vector97>:
.globl vector97
vector97:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $97
801071ed:	6a 61                	push   $0x61
  jmp alltraps
801071ef:	e9 0c f6 ff ff       	jmp    80106800 <alltraps>

801071f4 <vector98>:
.globl vector98
vector98:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $98
801071f6:	6a 62                	push   $0x62
  jmp alltraps
801071f8:	e9 03 f6 ff ff       	jmp    80106800 <alltraps>

801071fd <vector99>:
.globl vector99
vector99:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $99
801071ff:	6a 63                	push   $0x63
  jmp alltraps
80107201:	e9 fa f5 ff ff       	jmp    80106800 <alltraps>

80107206 <vector100>:
.globl vector100
vector100:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $100
80107208:	6a 64                	push   $0x64
  jmp alltraps
8010720a:	e9 f1 f5 ff ff       	jmp    80106800 <alltraps>

8010720f <vector101>:
.globl vector101
vector101:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $101
80107211:	6a 65                	push   $0x65
  jmp alltraps
80107213:	e9 e8 f5 ff ff       	jmp    80106800 <alltraps>

80107218 <vector102>:
.globl vector102
vector102:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $102
8010721a:	6a 66                	push   $0x66
  jmp alltraps
8010721c:	e9 df f5 ff ff       	jmp    80106800 <alltraps>

80107221 <vector103>:
.globl vector103
vector103:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $103
80107223:	6a 67                	push   $0x67
  jmp alltraps
80107225:	e9 d6 f5 ff ff       	jmp    80106800 <alltraps>

8010722a <vector104>:
.globl vector104
vector104:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $104
8010722c:	6a 68                	push   $0x68
  jmp alltraps
8010722e:	e9 cd f5 ff ff       	jmp    80106800 <alltraps>

80107233 <vector105>:
.globl vector105
vector105:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $105
80107235:	6a 69                	push   $0x69
  jmp alltraps
80107237:	e9 c4 f5 ff ff       	jmp    80106800 <alltraps>

8010723c <vector106>:
.globl vector106
vector106:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $106
8010723e:	6a 6a                	push   $0x6a
  jmp alltraps
80107240:	e9 bb f5 ff ff       	jmp    80106800 <alltraps>

80107245 <vector107>:
.globl vector107
vector107:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $107
80107247:	6a 6b                	push   $0x6b
  jmp alltraps
80107249:	e9 b2 f5 ff ff       	jmp    80106800 <alltraps>

8010724e <vector108>:
.globl vector108
vector108:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $108
80107250:	6a 6c                	push   $0x6c
  jmp alltraps
80107252:	e9 a9 f5 ff ff       	jmp    80106800 <alltraps>

80107257 <vector109>:
.globl vector109
vector109:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $109
80107259:	6a 6d                	push   $0x6d
  jmp alltraps
8010725b:	e9 a0 f5 ff ff       	jmp    80106800 <alltraps>

80107260 <vector110>:
.globl vector110
vector110:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $110
80107262:	6a 6e                	push   $0x6e
  jmp alltraps
80107264:	e9 97 f5 ff ff       	jmp    80106800 <alltraps>

80107269 <vector111>:
.globl vector111
vector111:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $111
8010726b:	6a 6f                	push   $0x6f
  jmp alltraps
8010726d:	e9 8e f5 ff ff       	jmp    80106800 <alltraps>

80107272 <vector112>:
.globl vector112
vector112:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $112
80107274:	6a 70                	push   $0x70
  jmp alltraps
80107276:	e9 85 f5 ff ff       	jmp    80106800 <alltraps>

8010727b <vector113>:
.globl vector113
vector113:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $113
8010727d:	6a 71                	push   $0x71
  jmp alltraps
8010727f:	e9 7c f5 ff ff       	jmp    80106800 <alltraps>

80107284 <vector114>:
.globl vector114
vector114:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $114
80107286:	6a 72                	push   $0x72
  jmp alltraps
80107288:	e9 73 f5 ff ff       	jmp    80106800 <alltraps>

8010728d <vector115>:
.globl vector115
vector115:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $115
8010728f:	6a 73                	push   $0x73
  jmp alltraps
80107291:	e9 6a f5 ff ff       	jmp    80106800 <alltraps>

80107296 <vector116>:
.globl vector116
vector116:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $116
80107298:	6a 74                	push   $0x74
  jmp alltraps
8010729a:	e9 61 f5 ff ff       	jmp    80106800 <alltraps>

8010729f <vector117>:
.globl vector117
vector117:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $117
801072a1:	6a 75                	push   $0x75
  jmp alltraps
801072a3:	e9 58 f5 ff ff       	jmp    80106800 <alltraps>

801072a8 <vector118>:
.globl vector118
vector118:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $118
801072aa:	6a 76                	push   $0x76
  jmp alltraps
801072ac:	e9 4f f5 ff ff       	jmp    80106800 <alltraps>

801072b1 <vector119>:
.globl vector119
vector119:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $119
801072b3:	6a 77                	push   $0x77
  jmp alltraps
801072b5:	e9 46 f5 ff ff       	jmp    80106800 <alltraps>

801072ba <vector120>:
.globl vector120
vector120:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $120
801072bc:	6a 78                	push   $0x78
  jmp alltraps
801072be:	e9 3d f5 ff ff       	jmp    80106800 <alltraps>

801072c3 <vector121>:
.globl vector121
vector121:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $121
801072c5:	6a 79                	push   $0x79
  jmp alltraps
801072c7:	e9 34 f5 ff ff       	jmp    80106800 <alltraps>

801072cc <vector122>:
.globl vector122
vector122:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $122
801072ce:	6a 7a                	push   $0x7a
  jmp alltraps
801072d0:	e9 2b f5 ff ff       	jmp    80106800 <alltraps>

801072d5 <vector123>:
.globl vector123
vector123:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $123
801072d7:	6a 7b                	push   $0x7b
  jmp alltraps
801072d9:	e9 22 f5 ff ff       	jmp    80106800 <alltraps>

801072de <vector124>:
.globl vector124
vector124:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $124
801072e0:	6a 7c                	push   $0x7c
  jmp alltraps
801072e2:	e9 19 f5 ff ff       	jmp    80106800 <alltraps>

801072e7 <vector125>:
.globl vector125
vector125:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $125
801072e9:	6a 7d                	push   $0x7d
  jmp alltraps
801072eb:	e9 10 f5 ff ff       	jmp    80106800 <alltraps>

801072f0 <vector126>:
.globl vector126
vector126:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $126
801072f2:	6a 7e                	push   $0x7e
  jmp alltraps
801072f4:	e9 07 f5 ff ff       	jmp    80106800 <alltraps>

801072f9 <vector127>:
.globl vector127
vector127:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $127
801072fb:	6a 7f                	push   $0x7f
  jmp alltraps
801072fd:	e9 fe f4 ff ff       	jmp    80106800 <alltraps>

80107302 <vector128>:
.globl vector128
vector128:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $128
80107304:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107309:	e9 f2 f4 ff ff       	jmp    80106800 <alltraps>

8010730e <vector129>:
.globl vector129
vector129:
  pushl $0
8010730e:	6a 00                	push   $0x0
  pushl $129
80107310:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107315:	e9 e6 f4 ff ff       	jmp    80106800 <alltraps>

8010731a <vector130>:
.globl vector130
vector130:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $130
8010731c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107321:	e9 da f4 ff ff       	jmp    80106800 <alltraps>

80107326 <vector131>:
.globl vector131
vector131:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $131
80107328:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010732d:	e9 ce f4 ff ff       	jmp    80106800 <alltraps>

80107332 <vector132>:
.globl vector132
vector132:
  pushl $0
80107332:	6a 00                	push   $0x0
  pushl $132
80107334:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107339:	e9 c2 f4 ff ff       	jmp    80106800 <alltraps>

8010733e <vector133>:
.globl vector133
vector133:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $133
80107340:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107345:	e9 b6 f4 ff ff       	jmp    80106800 <alltraps>

8010734a <vector134>:
.globl vector134
vector134:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $134
8010734c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107351:	e9 aa f4 ff ff       	jmp    80106800 <alltraps>

80107356 <vector135>:
.globl vector135
vector135:
  pushl $0
80107356:	6a 00                	push   $0x0
  pushl $135
80107358:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010735d:	e9 9e f4 ff ff       	jmp    80106800 <alltraps>

80107362 <vector136>:
.globl vector136
vector136:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $136
80107364:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107369:	e9 92 f4 ff ff       	jmp    80106800 <alltraps>

8010736e <vector137>:
.globl vector137
vector137:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $137
80107370:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107375:	e9 86 f4 ff ff       	jmp    80106800 <alltraps>

8010737a <vector138>:
.globl vector138
vector138:
  pushl $0
8010737a:	6a 00                	push   $0x0
  pushl $138
8010737c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107381:	e9 7a f4 ff ff       	jmp    80106800 <alltraps>

80107386 <vector139>:
.globl vector139
vector139:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $139
80107388:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010738d:	e9 6e f4 ff ff       	jmp    80106800 <alltraps>

80107392 <vector140>:
.globl vector140
vector140:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $140
80107394:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107399:	e9 62 f4 ff ff       	jmp    80106800 <alltraps>

8010739e <vector141>:
.globl vector141
vector141:
  pushl $0
8010739e:	6a 00                	push   $0x0
  pushl $141
801073a0:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801073a5:	e9 56 f4 ff ff       	jmp    80106800 <alltraps>

801073aa <vector142>:
.globl vector142
vector142:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $142
801073ac:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801073b1:	e9 4a f4 ff ff       	jmp    80106800 <alltraps>

801073b6 <vector143>:
.globl vector143
vector143:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $143
801073b8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801073bd:	e9 3e f4 ff ff       	jmp    80106800 <alltraps>

801073c2 <vector144>:
.globl vector144
vector144:
  pushl $0
801073c2:	6a 00                	push   $0x0
  pushl $144
801073c4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801073c9:	e9 32 f4 ff ff       	jmp    80106800 <alltraps>

801073ce <vector145>:
.globl vector145
vector145:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $145
801073d0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801073d5:	e9 26 f4 ff ff       	jmp    80106800 <alltraps>

801073da <vector146>:
.globl vector146
vector146:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $146
801073dc:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801073e1:	e9 1a f4 ff ff       	jmp    80106800 <alltraps>

801073e6 <vector147>:
.globl vector147
vector147:
  pushl $0
801073e6:	6a 00                	push   $0x0
  pushl $147
801073e8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801073ed:	e9 0e f4 ff ff       	jmp    80106800 <alltraps>

801073f2 <vector148>:
.globl vector148
vector148:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $148
801073f4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801073f9:	e9 02 f4 ff ff       	jmp    80106800 <alltraps>

801073fe <vector149>:
.globl vector149
vector149:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $149
80107400:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107405:	e9 f6 f3 ff ff       	jmp    80106800 <alltraps>

8010740a <vector150>:
.globl vector150
vector150:
  pushl $0
8010740a:	6a 00                	push   $0x0
  pushl $150
8010740c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107411:	e9 ea f3 ff ff       	jmp    80106800 <alltraps>

80107416 <vector151>:
.globl vector151
vector151:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $151
80107418:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010741d:	e9 de f3 ff ff       	jmp    80106800 <alltraps>

80107422 <vector152>:
.globl vector152
vector152:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $152
80107424:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107429:	e9 d2 f3 ff ff       	jmp    80106800 <alltraps>

8010742e <vector153>:
.globl vector153
vector153:
  pushl $0
8010742e:	6a 00                	push   $0x0
  pushl $153
80107430:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107435:	e9 c6 f3 ff ff       	jmp    80106800 <alltraps>

8010743a <vector154>:
.globl vector154
vector154:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $154
8010743c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107441:	e9 ba f3 ff ff       	jmp    80106800 <alltraps>

80107446 <vector155>:
.globl vector155
vector155:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $155
80107448:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010744d:	e9 ae f3 ff ff       	jmp    80106800 <alltraps>

80107452 <vector156>:
.globl vector156
vector156:
  pushl $0
80107452:	6a 00                	push   $0x0
  pushl $156
80107454:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107459:	e9 a2 f3 ff ff       	jmp    80106800 <alltraps>

8010745e <vector157>:
.globl vector157
vector157:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $157
80107460:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107465:	e9 96 f3 ff ff       	jmp    80106800 <alltraps>

8010746a <vector158>:
.globl vector158
vector158:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $158
8010746c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107471:	e9 8a f3 ff ff       	jmp    80106800 <alltraps>

80107476 <vector159>:
.globl vector159
vector159:
  pushl $0
80107476:	6a 00                	push   $0x0
  pushl $159
80107478:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010747d:	e9 7e f3 ff ff       	jmp    80106800 <alltraps>

80107482 <vector160>:
.globl vector160
vector160:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $160
80107484:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107489:	e9 72 f3 ff ff       	jmp    80106800 <alltraps>

8010748e <vector161>:
.globl vector161
vector161:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $161
80107490:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107495:	e9 66 f3 ff ff       	jmp    80106800 <alltraps>

8010749a <vector162>:
.globl vector162
vector162:
  pushl $0
8010749a:	6a 00                	push   $0x0
  pushl $162
8010749c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801074a1:	e9 5a f3 ff ff       	jmp    80106800 <alltraps>

801074a6 <vector163>:
.globl vector163
vector163:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $163
801074a8:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801074ad:	e9 4e f3 ff ff       	jmp    80106800 <alltraps>

801074b2 <vector164>:
.globl vector164
vector164:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $164
801074b4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801074b9:	e9 42 f3 ff ff       	jmp    80106800 <alltraps>

801074be <vector165>:
.globl vector165
vector165:
  pushl $0
801074be:	6a 00                	push   $0x0
  pushl $165
801074c0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801074c5:	e9 36 f3 ff ff       	jmp    80106800 <alltraps>

801074ca <vector166>:
.globl vector166
vector166:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $166
801074cc:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801074d1:	e9 2a f3 ff ff       	jmp    80106800 <alltraps>

801074d6 <vector167>:
.globl vector167
vector167:
  pushl $0
801074d6:	6a 00                	push   $0x0
  pushl $167
801074d8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801074dd:	e9 1e f3 ff ff       	jmp    80106800 <alltraps>

801074e2 <vector168>:
.globl vector168
vector168:
  pushl $0
801074e2:	6a 00                	push   $0x0
  pushl $168
801074e4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801074e9:	e9 12 f3 ff ff       	jmp    80106800 <alltraps>

801074ee <vector169>:
.globl vector169
vector169:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $169
801074f0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801074f5:	e9 06 f3 ff ff       	jmp    80106800 <alltraps>

801074fa <vector170>:
.globl vector170
vector170:
  pushl $0
801074fa:	6a 00                	push   $0x0
  pushl $170
801074fc:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107501:	e9 fa f2 ff ff       	jmp    80106800 <alltraps>

80107506 <vector171>:
.globl vector171
vector171:
  pushl $0
80107506:	6a 00                	push   $0x0
  pushl $171
80107508:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010750d:	e9 ee f2 ff ff       	jmp    80106800 <alltraps>

80107512 <vector172>:
.globl vector172
vector172:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $172
80107514:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107519:	e9 e2 f2 ff ff       	jmp    80106800 <alltraps>

8010751e <vector173>:
.globl vector173
vector173:
  pushl $0
8010751e:	6a 00                	push   $0x0
  pushl $173
80107520:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107525:	e9 d6 f2 ff ff       	jmp    80106800 <alltraps>

8010752a <vector174>:
.globl vector174
vector174:
  pushl $0
8010752a:	6a 00                	push   $0x0
  pushl $174
8010752c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107531:	e9 ca f2 ff ff       	jmp    80106800 <alltraps>

80107536 <vector175>:
.globl vector175
vector175:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $175
80107538:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010753d:	e9 be f2 ff ff       	jmp    80106800 <alltraps>

80107542 <vector176>:
.globl vector176
vector176:
  pushl $0
80107542:	6a 00                	push   $0x0
  pushl $176
80107544:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107549:	e9 b2 f2 ff ff       	jmp    80106800 <alltraps>

8010754e <vector177>:
.globl vector177
vector177:
  pushl $0
8010754e:	6a 00                	push   $0x0
  pushl $177
80107550:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107555:	e9 a6 f2 ff ff       	jmp    80106800 <alltraps>

8010755a <vector178>:
.globl vector178
vector178:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $178
8010755c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107561:	e9 9a f2 ff ff       	jmp    80106800 <alltraps>

80107566 <vector179>:
.globl vector179
vector179:
  pushl $0
80107566:	6a 00                	push   $0x0
  pushl $179
80107568:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010756d:	e9 8e f2 ff ff       	jmp    80106800 <alltraps>

80107572 <vector180>:
.globl vector180
vector180:
  pushl $0
80107572:	6a 00                	push   $0x0
  pushl $180
80107574:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107579:	e9 82 f2 ff ff       	jmp    80106800 <alltraps>

8010757e <vector181>:
.globl vector181
vector181:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $181
80107580:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107585:	e9 76 f2 ff ff       	jmp    80106800 <alltraps>

8010758a <vector182>:
.globl vector182
vector182:
  pushl $0
8010758a:	6a 00                	push   $0x0
  pushl $182
8010758c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107591:	e9 6a f2 ff ff       	jmp    80106800 <alltraps>

80107596 <vector183>:
.globl vector183
vector183:
  pushl $0
80107596:	6a 00                	push   $0x0
  pushl $183
80107598:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010759d:	e9 5e f2 ff ff       	jmp    80106800 <alltraps>

801075a2 <vector184>:
.globl vector184
vector184:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $184
801075a4:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801075a9:	e9 52 f2 ff ff       	jmp    80106800 <alltraps>

801075ae <vector185>:
.globl vector185
vector185:
  pushl $0
801075ae:	6a 00                	push   $0x0
  pushl $185
801075b0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801075b5:	e9 46 f2 ff ff       	jmp    80106800 <alltraps>

801075ba <vector186>:
.globl vector186
vector186:
  pushl $0
801075ba:	6a 00                	push   $0x0
  pushl $186
801075bc:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801075c1:	e9 3a f2 ff ff       	jmp    80106800 <alltraps>

801075c6 <vector187>:
.globl vector187
vector187:
  pushl $0
801075c6:	6a 00                	push   $0x0
  pushl $187
801075c8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801075cd:	e9 2e f2 ff ff       	jmp    80106800 <alltraps>

801075d2 <vector188>:
.globl vector188
vector188:
  pushl $0
801075d2:	6a 00                	push   $0x0
  pushl $188
801075d4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801075d9:	e9 22 f2 ff ff       	jmp    80106800 <alltraps>

801075de <vector189>:
.globl vector189
vector189:
  pushl $0
801075de:	6a 00                	push   $0x0
  pushl $189
801075e0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801075e5:	e9 16 f2 ff ff       	jmp    80106800 <alltraps>

801075ea <vector190>:
.globl vector190
vector190:
  pushl $0
801075ea:	6a 00                	push   $0x0
  pushl $190
801075ec:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801075f1:	e9 0a f2 ff ff       	jmp    80106800 <alltraps>

801075f6 <vector191>:
.globl vector191
vector191:
  pushl $0
801075f6:	6a 00                	push   $0x0
  pushl $191
801075f8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801075fd:	e9 fe f1 ff ff       	jmp    80106800 <alltraps>

80107602 <vector192>:
.globl vector192
vector192:
  pushl $0
80107602:	6a 00                	push   $0x0
  pushl $192
80107604:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107609:	e9 f2 f1 ff ff       	jmp    80106800 <alltraps>

8010760e <vector193>:
.globl vector193
vector193:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $193
80107610:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107615:	e9 e6 f1 ff ff       	jmp    80106800 <alltraps>

8010761a <vector194>:
.globl vector194
vector194:
  pushl $0
8010761a:	6a 00                	push   $0x0
  pushl $194
8010761c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107621:	e9 da f1 ff ff       	jmp    80106800 <alltraps>

80107626 <vector195>:
.globl vector195
vector195:
  pushl $0
80107626:	6a 00                	push   $0x0
  pushl $195
80107628:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010762d:	e9 ce f1 ff ff       	jmp    80106800 <alltraps>

80107632 <vector196>:
.globl vector196
vector196:
  pushl $0
80107632:	6a 00                	push   $0x0
  pushl $196
80107634:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107639:	e9 c2 f1 ff ff       	jmp    80106800 <alltraps>

8010763e <vector197>:
.globl vector197
vector197:
  pushl $0
8010763e:	6a 00                	push   $0x0
  pushl $197
80107640:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107645:	e9 b6 f1 ff ff       	jmp    80106800 <alltraps>

8010764a <vector198>:
.globl vector198
vector198:
  pushl $0
8010764a:	6a 00                	push   $0x0
  pushl $198
8010764c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107651:	e9 aa f1 ff ff       	jmp    80106800 <alltraps>

80107656 <vector199>:
.globl vector199
vector199:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $199
80107658:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010765d:	e9 9e f1 ff ff       	jmp    80106800 <alltraps>

80107662 <vector200>:
.globl vector200
vector200:
  pushl $0
80107662:	6a 00                	push   $0x0
  pushl $200
80107664:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107669:	e9 92 f1 ff ff       	jmp    80106800 <alltraps>

8010766e <vector201>:
.globl vector201
vector201:
  pushl $0
8010766e:	6a 00                	push   $0x0
  pushl $201
80107670:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107675:	e9 86 f1 ff ff       	jmp    80106800 <alltraps>

8010767a <vector202>:
.globl vector202
vector202:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $202
8010767c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107681:	e9 7a f1 ff ff       	jmp    80106800 <alltraps>

80107686 <vector203>:
.globl vector203
vector203:
  pushl $0
80107686:	6a 00                	push   $0x0
  pushl $203
80107688:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010768d:	e9 6e f1 ff ff       	jmp    80106800 <alltraps>

80107692 <vector204>:
.globl vector204
vector204:
  pushl $0
80107692:	6a 00                	push   $0x0
  pushl $204
80107694:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107699:	e9 62 f1 ff ff       	jmp    80106800 <alltraps>

8010769e <vector205>:
.globl vector205
vector205:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $205
801076a0:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801076a5:	e9 56 f1 ff ff       	jmp    80106800 <alltraps>

801076aa <vector206>:
.globl vector206
vector206:
  pushl $0
801076aa:	6a 00                	push   $0x0
  pushl $206
801076ac:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801076b1:	e9 4a f1 ff ff       	jmp    80106800 <alltraps>

801076b6 <vector207>:
.globl vector207
vector207:
  pushl $0
801076b6:	6a 00                	push   $0x0
  pushl $207
801076b8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801076bd:	e9 3e f1 ff ff       	jmp    80106800 <alltraps>

801076c2 <vector208>:
.globl vector208
vector208:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $208
801076c4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801076c9:	e9 32 f1 ff ff       	jmp    80106800 <alltraps>

801076ce <vector209>:
.globl vector209
vector209:
  pushl $0
801076ce:	6a 00                	push   $0x0
  pushl $209
801076d0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801076d5:	e9 26 f1 ff ff       	jmp    80106800 <alltraps>

801076da <vector210>:
.globl vector210
vector210:
  pushl $0
801076da:	6a 00                	push   $0x0
  pushl $210
801076dc:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801076e1:	e9 1a f1 ff ff       	jmp    80106800 <alltraps>

801076e6 <vector211>:
.globl vector211
vector211:
  pushl $0
801076e6:	6a 00                	push   $0x0
  pushl $211
801076e8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801076ed:	e9 0e f1 ff ff       	jmp    80106800 <alltraps>

801076f2 <vector212>:
.globl vector212
vector212:
  pushl $0
801076f2:	6a 00                	push   $0x0
  pushl $212
801076f4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801076f9:	e9 02 f1 ff ff       	jmp    80106800 <alltraps>

801076fe <vector213>:
.globl vector213
vector213:
  pushl $0
801076fe:	6a 00                	push   $0x0
  pushl $213
80107700:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107705:	e9 f6 f0 ff ff       	jmp    80106800 <alltraps>

8010770a <vector214>:
.globl vector214
vector214:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $214
8010770c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107711:	e9 ea f0 ff ff       	jmp    80106800 <alltraps>

80107716 <vector215>:
.globl vector215
vector215:
  pushl $0
80107716:	6a 00                	push   $0x0
  pushl $215
80107718:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010771d:	e9 de f0 ff ff       	jmp    80106800 <alltraps>

80107722 <vector216>:
.globl vector216
vector216:
  pushl $0
80107722:	6a 00                	push   $0x0
  pushl $216
80107724:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107729:	e9 d2 f0 ff ff       	jmp    80106800 <alltraps>

8010772e <vector217>:
.globl vector217
vector217:
  pushl $0
8010772e:	6a 00                	push   $0x0
  pushl $217
80107730:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107735:	e9 c6 f0 ff ff       	jmp    80106800 <alltraps>

8010773a <vector218>:
.globl vector218
vector218:
  pushl $0
8010773a:	6a 00                	push   $0x0
  pushl $218
8010773c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107741:	e9 ba f0 ff ff       	jmp    80106800 <alltraps>

80107746 <vector219>:
.globl vector219
vector219:
  pushl $0
80107746:	6a 00                	push   $0x0
  pushl $219
80107748:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010774d:	e9 ae f0 ff ff       	jmp    80106800 <alltraps>

80107752 <vector220>:
.globl vector220
vector220:
  pushl $0
80107752:	6a 00                	push   $0x0
  pushl $220
80107754:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107759:	e9 a2 f0 ff ff       	jmp    80106800 <alltraps>

8010775e <vector221>:
.globl vector221
vector221:
  pushl $0
8010775e:	6a 00                	push   $0x0
  pushl $221
80107760:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107765:	e9 96 f0 ff ff       	jmp    80106800 <alltraps>

8010776a <vector222>:
.globl vector222
vector222:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $222
8010776c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107771:	e9 8a f0 ff ff       	jmp    80106800 <alltraps>

80107776 <vector223>:
.globl vector223
vector223:
  pushl $0
80107776:	6a 00                	push   $0x0
  pushl $223
80107778:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010777d:	e9 7e f0 ff ff       	jmp    80106800 <alltraps>

80107782 <vector224>:
.globl vector224
vector224:
  pushl $0
80107782:	6a 00                	push   $0x0
  pushl $224
80107784:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107789:	e9 72 f0 ff ff       	jmp    80106800 <alltraps>

8010778e <vector225>:
.globl vector225
vector225:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $225
80107790:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107795:	e9 66 f0 ff ff       	jmp    80106800 <alltraps>

8010779a <vector226>:
.globl vector226
vector226:
  pushl $0
8010779a:	6a 00                	push   $0x0
  pushl $226
8010779c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801077a1:	e9 5a f0 ff ff       	jmp    80106800 <alltraps>

801077a6 <vector227>:
.globl vector227
vector227:
  pushl $0
801077a6:	6a 00                	push   $0x0
  pushl $227
801077a8:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801077ad:	e9 4e f0 ff ff       	jmp    80106800 <alltraps>

801077b2 <vector228>:
.globl vector228
vector228:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $228
801077b4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801077b9:	e9 42 f0 ff ff       	jmp    80106800 <alltraps>

801077be <vector229>:
.globl vector229
vector229:
  pushl $0
801077be:	6a 00                	push   $0x0
  pushl $229
801077c0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801077c5:	e9 36 f0 ff ff       	jmp    80106800 <alltraps>

801077ca <vector230>:
.globl vector230
vector230:
  pushl $0
801077ca:	6a 00                	push   $0x0
  pushl $230
801077cc:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801077d1:	e9 2a f0 ff ff       	jmp    80106800 <alltraps>

801077d6 <vector231>:
.globl vector231
vector231:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $231
801077d8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801077dd:	e9 1e f0 ff ff       	jmp    80106800 <alltraps>

801077e2 <vector232>:
.globl vector232
vector232:
  pushl $0
801077e2:	6a 00                	push   $0x0
  pushl $232
801077e4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801077e9:	e9 12 f0 ff ff       	jmp    80106800 <alltraps>

801077ee <vector233>:
.globl vector233
vector233:
  pushl $0
801077ee:	6a 00                	push   $0x0
  pushl $233
801077f0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801077f5:	e9 06 f0 ff ff       	jmp    80106800 <alltraps>

801077fa <vector234>:
.globl vector234
vector234:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $234
801077fc:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107801:	e9 fa ef ff ff       	jmp    80106800 <alltraps>

80107806 <vector235>:
.globl vector235
vector235:
  pushl $0
80107806:	6a 00                	push   $0x0
  pushl $235
80107808:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010780d:	e9 ee ef ff ff       	jmp    80106800 <alltraps>

80107812 <vector236>:
.globl vector236
vector236:
  pushl $0
80107812:	6a 00                	push   $0x0
  pushl $236
80107814:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107819:	e9 e2 ef ff ff       	jmp    80106800 <alltraps>

8010781e <vector237>:
.globl vector237
vector237:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $237
80107820:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107825:	e9 d6 ef ff ff       	jmp    80106800 <alltraps>

8010782a <vector238>:
.globl vector238
vector238:
  pushl $0
8010782a:	6a 00                	push   $0x0
  pushl $238
8010782c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107831:	e9 ca ef ff ff       	jmp    80106800 <alltraps>

80107836 <vector239>:
.globl vector239
vector239:
  pushl $0
80107836:	6a 00                	push   $0x0
  pushl $239
80107838:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010783d:	e9 be ef ff ff       	jmp    80106800 <alltraps>

80107842 <vector240>:
.globl vector240
vector240:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $240
80107844:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107849:	e9 b2 ef ff ff       	jmp    80106800 <alltraps>

8010784e <vector241>:
.globl vector241
vector241:
  pushl $0
8010784e:	6a 00                	push   $0x0
  pushl $241
80107850:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107855:	e9 a6 ef ff ff       	jmp    80106800 <alltraps>

8010785a <vector242>:
.globl vector242
vector242:
  pushl $0
8010785a:	6a 00                	push   $0x0
  pushl $242
8010785c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107861:	e9 9a ef ff ff       	jmp    80106800 <alltraps>

80107866 <vector243>:
.globl vector243
vector243:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $243
80107868:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010786d:	e9 8e ef ff ff       	jmp    80106800 <alltraps>

80107872 <vector244>:
.globl vector244
vector244:
  pushl $0
80107872:	6a 00                	push   $0x0
  pushl $244
80107874:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107879:	e9 82 ef ff ff       	jmp    80106800 <alltraps>

8010787e <vector245>:
.globl vector245
vector245:
  pushl $0
8010787e:	6a 00                	push   $0x0
  pushl $245
80107880:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107885:	e9 76 ef ff ff       	jmp    80106800 <alltraps>

8010788a <vector246>:
.globl vector246
vector246:
  pushl $0
8010788a:	6a 00                	push   $0x0
  pushl $246
8010788c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107891:	e9 6a ef ff ff       	jmp    80106800 <alltraps>

80107896 <vector247>:
.globl vector247
vector247:
  pushl $0
80107896:	6a 00                	push   $0x0
  pushl $247
80107898:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010789d:	e9 5e ef ff ff       	jmp    80106800 <alltraps>

801078a2 <vector248>:
.globl vector248
vector248:
  pushl $0
801078a2:	6a 00                	push   $0x0
  pushl $248
801078a4:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801078a9:	e9 52 ef ff ff       	jmp    80106800 <alltraps>

801078ae <vector249>:
.globl vector249
vector249:
  pushl $0
801078ae:	6a 00                	push   $0x0
  pushl $249
801078b0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801078b5:	e9 46 ef ff ff       	jmp    80106800 <alltraps>

801078ba <vector250>:
.globl vector250
vector250:
  pushl $0
801078ba:	6a 00                	push   $0x0
  pushl $250
801078bc:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801078c1:	e9 3a ef ff ff       	jmp    80106800 <alltraps>

801078c6 <vector251>:
.globl vector251
vector251:
  pushl $0
801078c6:	6a 00                	push   $0x0
  pushl $251
801078c8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801078cd:	e9 2e ef ff ff       	jmp    80106800 <alltraps>

801078d2 <vector252>:
.globl vector252
vector252:
  pushl $0
801078d2:	6a 00                	push   $0x0
  pushl $252
801078d4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801078d9:	e9 22 ef ff ff       	jmp    80106800 <alltraps>

801078de <vector253>:
.globl vector253
vector253:
  pushl $0
801078de:	6a 00                	push   $0x0
  pushl $253
801078e0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801078e5:	e9 16 ef ff ff       	jmp    80106800 <alltraps>

801078ea <vector254>:
.globl vector254
vector254:
  pushl $0
801078ea:	6a 00                	push   $0x0
  pushl $254
801078ec:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801078f1:	e9 0a ef ff ff       	jmp    80106800 <alltraps>

801078f6 <vector255>:
.globl vector255
vector255:
  pushl $0
801078f6:	6a 00                	push   $0x0
  pushl $255
801078f8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801078fd:	e9 fe ee ff ff       	jmp    80106800 <alltraps>
	...

80107904 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107904:	55                   	push   %ebp
80107905:	89 e5                	mov    %esp,%ebp
80107907:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010790a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010790d:	83 e8 01             	sub    $0x1,%eax
80107910:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107914:	8b 45 08             	mov    0x8(%ebp),%eax
80107917:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010791b:	8b 45 08             	mov    0x8(%ebp),%eax
8010791e:	c1 e8 10             	shr    $0x10,%eax
80107921:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107925:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107928:	0f 01 10             	lgdtl  (%eax)
}
8010792b:	c9                   	leave  
8010792c:	c3                   	ret    

8010792d <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010792d:	55                   	push   %ebp
8010792e:	89 e5                	mov    %esp,%ebp
80107930:	83 ec 04             	sub    $0x4,%esp
80107933:	8b 45 08             	mov    0x8(%ebp),%eax
80107936:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010793a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010793e:	0f 00 d8             	ltr    %ax
}
80107941:	c9                   	leave  
80107942:	c3                   	ret    

80107943 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107943:	55                   	push   %ebp
80107944:	89 e5                	mov    %esp,%ebp
80107946:	83 ec 04             	sub    $0x4,%esp
80107949:	8b 45 08             	mov    0x8(%ebp),%eax
8010794c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107950:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107954:	8e e8                	mov    %eax,%gs
}
80107956:	c9                   	leave  
80107957:	c3                   	ret    

80107958 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107958:	55                   	push   %ebp
80107959:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010795b:	8b 45 08             	mov    0x8(%ebp),%eax
8010795e:	0f 22 d8             	mov    %eax,%cr3
}
80107961:	5d                   	pop    %ebp
80107962:	c3                   	ret    

80107963 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107963:	55                   	push   %ebp
80107964:	89 e5                	mov    %esp,%ebp
80107966:	8b 45 08             	mov    0x8(%ebp),%eax
80107969:	05 00 00 00 80       	add    $0x80000000,%eax
8010796e:	5d                   	pop    %ebp
8010796f:	c3                   	ret    

80107970 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107970:	55                   	push   %ebp
80107971:	89 e5                	mov    %esp,%ebp
80107973:	8b 45 08             	mov    0x8(%ebp),%eax
80107976:	05 00 00 00 80       	add    $0x80000000,%eax
8010797b:	5d                   	pop    %ebp
8010797c:	c3                   	ret    

8010797d <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010797d:	55                   	push   %ebp
8010797e:	89 e5                	mov    %esp,%ebp
80107980:	53                   	push   %ebx
80107981:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107984:	e8 58 b8 ff ff       	call   801031e1 <cpunum>
80107989:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010798f:	05 40 f9 10 80       	add    $0x8010f940,%eax
80107994:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799a:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801079a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a3:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801079a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ac:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801079b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801079b7:	83 e2 f0             	and    $0xfffffff0,%edx
801079ba:	83 ca 0a             	or     $0xa,%edx
801079bd:	88 50 7d             	mov    %dl,0x7d(%eax)
801079c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801079c7:	83 ca 10             	or     $0x10,%edx
801079ca:	88 50 7d             	mov    %dl,0x7d(%eax)
801079cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801079d4:	83 e2 9f             	and    $0xffffff9f,%edx
801079d7:	88 50 7d             	mov    %dl,0x7d(%eax)
801079da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079dd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801079e1:	83 ca 80             	or     $0xffffff80,%edx
801079e4:	88 50 7d             	mov    %dl,0x7d(%eax)
801079e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ea:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079ee:	83 ca 0f             	or     $0xf,%edx
801079f1:	88 50 7e             	mov    %dl,0x7e(%eax)
801079f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801079fb:	83 e2 ef             	and    $0xffffffef,%edx
801079fe:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a04:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a08:	83 e2 df             	and    $0xffffffdf,%edx
80107a0b:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a11:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a15:	83 ca 40             	or     $0x40,%edx
80107a18:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a22:	83 ca 80             	or     $0xffffff80,%edx
80107a25:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2b:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a32:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107a39:	ff ff 
80107a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a3e:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107a45:	00 00 
80107a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4a:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a54:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a5b:	83 e2 f0             	and    $0xfffffff0,%edx
80107a5e:	83 ca 02             	or     $0x2,%edx
80107a61:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a71:	83 ca 10             	or     $0x10,%edx
80107a74:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a84:	83 e2 9f             	and    $0xffffff9f,%edx
80107a87:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a90:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a97:	83 ca 80             	or     $0xffffff80,%edx
80107a9a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107aaa:	83 ca 0f             	or     $0xf,%edx
80107aad:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107abd:	83 e2 ef             	and    $0xffffffef,%edx
80107ac0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ad0:	83 e2 df             	and    $0xffffffdf,%edx
80107ad3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ae3:	83 ca 40             	or     $0x40,%edx
80107ae6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aef:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107af6:	83 ca 80             	or     $0xffffff80,%edx
80107af9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b02:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107b13:	ff ff 
80107b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b18:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107b1f:	00 00 
80107b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b24:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b35:	83 e2 f0             	and    $0xfffffff0,%edx
80107b38:	83 ca 0a             	or     $0xa,%edx
80107b3b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b44:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b4b:	83 ca 10             	or     $0x10,%edx
80107b4e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b57:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b5e:	83 ca 60             	or     $0x60,%edx
80107b61:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b71:	83 ca 80             	or     $0xffffff80,%edx
80107b74:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b84:	83 ca 0f             	or     $0xf,%edx
80107b87:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b90:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b97:	83 e2 ef             	and    $0xffffffef,%edx
80107b9a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107baa:	83 e2 df             	and    $0xffffffdf,%edx
80107bad:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bbd:	83 ca 40             	or     $0x40,%edx
80107bc0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bd0:	83 ca 80             	or     $0xffffff80,%edx
80107bd3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdc:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be6:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107bed:	ff ff 
80107bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf2:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107bf9:	00 00 
80107bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfe:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c08:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c0f:	83 e2 f0             	and    $0xfffffff0,%edx
80107c12:	83 ca 02             	or     $0x2,%edx
80107c15:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c25:	83 ca 10             	or     $0x10,%edx
80107c28:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c31:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c38:	83 ca 60             	or     $0x60,%edx
80107c3b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c44:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c4b:	83 ca 80             	or     $0xffffff80,%edx
80107c4e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c57:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c5e:	83 ca 0f             	or     $0xf,%edx
80107c61:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c71:	83 e2 ef             	and    $0xffffffef,%edx
80107c74:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c84:	83 e2 df             	and    $0xffffffdf,%edx
80107c87:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c90:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c97:	83 ca 40             	or     $0x40,%edx
80107c9a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107caa:	83 ca 80             	or     $0xffffff80,%edx
80107cad:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb6:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc0:	05 b4 00 00 00       	add    $0xb4,%eax
80107cc5:	89 c3                	mov    %eax,%ebx
80107cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cca:	05 b4 00 00 00       	add    $0xb4,%eax
80107ccf:	c1 e8 10             	shr    $0x10,%eax
80107cd2:	89 c1                	mov    %eax,%ecx
80107cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd7:	05 b4 00 00 00       	add    $0xb4,%eax
80107cdc:	c1 e8 18             	shr    $0x18,%eax
80107cdf:	89 c2                	mov    %eax,%edx
80107ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce4:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107ceb:	00 00 
80107ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf0:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfa:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d03:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107d0a:	83 e1 f0             	and    $0xfffffff0,%ecx
80107d0d:	83 c9 02             	or     $0x2,%ecx
80107d10:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d19:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107d20:	83 c9 10             	or     $0x10,%ecx
80107d23:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2c:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107d33:	83 e1 9f             	and    $0xffffff9f,%ecx
80107d36:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3f:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107d46:	83 c9 80             	or     $0xffffff80,%ecx
80107d49:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d52:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d59:	83 e1 f0             	and    $0xfffffff0,%ecx
80107d5c:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d65:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d6c:	83 e1 ef             	and    $0xffffffef,%ecx
80107d6f:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d78:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d7f:	83 e1 df             	and    $0xffffffdf,%ecx
80107d82:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8b:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d92:	83 c9 40             	or     $0x40,%ecx
80107d95:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107da5:	83 c9 80             	or     $0xffffff80,%ecx
80107da8:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db1:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dba:	83 c0 70             	add    $0x70,%eax
80107dbd:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107dc4:	00 
80107dc5:	89 04 24             	mov    %eax,(%esp)
80107dc8:	e8 37 fb ff ff       	call   80107904 <lgdt>
  loadgs(SEG_KCPU << 3);
80107dcd:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107dd4:	e8 6a fb ff ff       	call   80107943 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddc:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107de2:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107de9:	00 00 00 00 
}
80107ded:	83 c4 24             	add    $0x24,%esp
80107df0:	5b                   	pop    %ebx
80107df1:	5d                   	pop    %ebp
80107df2:	c3                   	ret    

80107df3 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107df3:	55                   	push   %ebp
80107df4:	89 e5                	mov    %esp,%ebp
80107df6:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107df9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dfc:	c1 e8 16             	shr    $0x16,%eax
80107dff:	c1 e0 02             	shl    $0x2,%eax
80107e02:	03 45 08             	add    0x8(%ebp),%eax
80107e05:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e0b:	8b 00                	mov    (%eax),%eax
80107e0d:	83 e0 01             	and    $0x1,%eax
80107e10:	84 c0                	test   %al,%al
80107e12:	74 17                	je     80107e2b <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107e14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e17:	8b 00                	mov    (%eax),%eax
80107e19:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e1e:	89 04 24             	mov    %eax,(%esp)
80107e21:	e8 4a fb ff ff       	call   80107970 <p2v>
80107e26:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e29:	eb 4b                	jmp    80107e76 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107e2b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107e2f:	74 0e                	je     80107e3f <walkpgdir+0x4c>
80107e31:	e8 1d b0 ff ff       	call   80102e53 <kalloc>
80107e36:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e3d:	75 07                	jne    80107e46 <walkpgdir+0x53>
      return 0;
80107e3f:	b8 00 00 00 00       	mov    $0x0,%eax
80107e44:	eb 41                	jmp    80107e87 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107e46:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e4d:	00 
80107e4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e55:	00 
80107e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e59:	89 04 24             	mov    %eax,(%esp)
80107e5c:	e8 09 d5 ff ff       	call   8010536a <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e64:	89 04 24             	mov    %eax,(%esp)
80107e67:	e8 f7 fa ff ff       	call   80107963 <v2p>
80107e6c:	89 c2                	mov    %eax,%edx
80107e6e:	83 ca 07             	or     $0x7,%edx
80107e71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e74:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107e76:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e79:	c1 e8 0c             	shr    $0xc,%eax
80107e7c:	25 ff 03 00 00       	and    $0x3ff,%eax
80107e81:	c1 e0 02             	shl    $0x2,%eax
80107e84:	03 45 f4             	add    -0xc(%ebp),%eax
}
80107e87:	c9                   	leave  
80107e88:	c3                   	ret    

80107e89 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107e89:	55                   	push   %ebp
80107e8a:	89 e5                	mov    %esp,%ebp
80107e8c:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e97:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e9d:	03 45 10             	add    0x10(%ebp),%eax
80107ea0:	83 e8 01             	sub    $0x1,%eax
80107ea3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ea8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107eab:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107eb2:	00 
80107eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb6:	89 44 24 04          	mov    %eax,0x4(%esp)
80107eba:	8b 45 08             	mov    0x8(%ebp),%eax
80107ebd:	89 04 24             	mov    %eax,(%esp)
80107ec0:	e8 2e ff ff ff       	call   80107df3 <walkpgdir>
80107ec5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ec8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ecc:	75 07                	jne    80107ed5 <mappages+0x4c>
      return -1;
80107ece:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ed3:	eb 46                	jmp    80107f1b <mappages+0x92>
    if(*pte & PTE_P)
80107ed5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ed8:	8b 00                	mov    (%eax),%eax
80107eda:	83 e0 01             	and    $0x1,%eax
80107edd:	84 c0                	test   %al,%al
80107edf:	74 0c                	je     80107eed <mappages+0x64>
      panic("remap");
80107ee1:	c7 04 24 00 8d 10 80 	movl   $0x80108d00,(%esp)
80107ee8:	e8 50 86 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80107eed:	8b 45 18             	mov    0x18(%ebp),%eax
80107ef0:	0b 45 14             	or     0x14(%ebp),%eax
80107ef3:	89 c2                	mov    %eax,%edx
80107ef5:	83 ca 01             	or     $0x1,%edx
80107ef8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107efb:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f00:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107f03:	74 10                	je     80107f15 <mappages+0x8c>
      break;
    a += PGSIZE;
80107f05:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107f0c:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107f13:	eb 96                	jmp    80107eab <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107f15:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107f16:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f1b:	c9                   	leave  
80107f1c:	c3                   	ret    

80107f1d <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80107f1d:	55                   	push   %ebp
80107f1e:	89 e5                	mov    %esp,%ebp
80107f20:	53                   	push   %ebx
80107f21:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107f24:	e8 2a af ff ff       	call   80102e53 <kalloc>
80107f29:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f2c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f30:	75 0a                	jne    80107f3c <setupkvm+0x1f>
    return 0;
80107f32:	b8 00 00 00 00       	mov    $0x0,%eax
80107f37:	e9 98 00 00 00       	jmp    80107fd4 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107f3c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f43:	00 
80107f44:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f4b:	00 
80107f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f4f:	89 04 24             	mov    %eax,(%esp)
80107f52:	e8 13 d4 ff ff       	call   8010536a <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107f57:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107f5e:	e8 0d fa ff ff       	call   80107970 <p2v>
80107f63:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107f68:	76 0c                	jbe    80107f76 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107f6a:	c7 04 24 06 8d 10 80 	movl   $0x80108d06,(%esp)
80107f71:	e8 c7 85 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f76:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107f7d:	eb 49                	jmp    80107fc8 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80107f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107f82:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107f88:	8b 50 04             	mov    0x4(%eax),%edx
80107f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8e:	8b 58 08             	mov    0x8(%eax),%ebx
80107f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f94:	8b 40 04             	mov    0x4(%eax),%eax
80107f97:	29 c3                	sub    %eax,%ebx
80107f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9c:	8b 00                	mov    (%eax),%eax
80107f9e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107fa2:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107fa6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107faa:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fb1:	89 04 24             	mov    %eax,(%esp)
80107fb4:	e8 d0 fe ff ff       	call   80107e89 <mappages>
80107fb9:	85 c0                	test   %eax,%eax
80107fbb:	79 07                	jns    80107fc4 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107fbd:	b8 00 00 00 00       	mov    $0x0,%eax
80107fc2:	eb 10                	jmp    80107fd4 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107fc4:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107fc8:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107fcf:	72 ae                	jb     80107f7f <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107fd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107fd4:	83 c4 34             	add    $0x34,%esp
80107fd7:	5b                   	pop    %ebx
80107fd8:	5d                   	pop    %ebp
80107fd9:	c3                   	ret    

80107fda <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107fda:	55                   	push   %ebp
80107fdb:	89 e5                	mov    %esp,%ebp
80107fdd:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107fe0:	e8 38 ff ff ff       	call   80107f1d <setupkvm>
80107fe5:	a3 18 2a 11 80       	mov    %eax,0x80112a18
  switchkvm();
80107fea:	e8 02 00 00 00       	call   80107ff1 <switchkvm>
}
80107fef:	c9                   	leave  
80107ff0:	c3                   	ret    

80107ff1 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107ff1:	55                   	push   %ebp
80107ff2:	89 e5                	mov    %esp,%ebp
80107ff4:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107ff7:	a1 18 2a 11 80       	mov    0x80112a18,%eax
80107ffc:	89 04 24             	mov    %eax,(%esp)
80107fff:	e8 5f f9 ff ff       	call   80107963 <v2p>
80108004:	89 04 24             	mov    %eax,(%esp)
80108007:	e8 4c f9 ff ff       	call   80107958 <lcr3>
}
8010800c:	c9                   	leave  
8010800d:	c3                   	ret    

8010800e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010800e:	55                   	push   %ebp
8010800f:	89 e5                	mov    %esp,%ebp
80108011:	53                   	push   %ebx
80108012:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108015:	e8 49 d2 ff ff       	call   80105263 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
8010801a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108020:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108027:	83 c2 08             	add    $0x8,%edx
8010802a:	89 d3                	mov    %edx,%ebx
8010802c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108033:	83 c2 08             	add    $0x8,%edx
80108036:	c1 ea 10             	shr    $0x10,%edx
80108039:	89 d1                	mov    %edx,%ecx
8010803b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108042:	83 c2 08             	add    $0x8,%edx
80108045:	c1 ea 18             	shr    $0x18,%edx
80108048:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010804f:	67 00 
80108051:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108058:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
8010805e:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108065:	83 e1 f0             	and    $0xfffffff0,%ecx
80108068:	83 c9 09             	or     $0x9,%ecx
8010806b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108071:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108078:	83 c9 10             	or     $0x10,%ecx
8010807b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108081:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108088:	83 e1 9f             	and    $0xffffff9f,%ecx
8010808b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108091:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108098:	83 c9 80             	or     $0xffffff80,%ecx
8010809b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801080a1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801080a8:	83 e1 f0             	and    $0xfffffff0,%ecx
801080ab:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801080b1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801080b8:	83 e1 ef             	and    $0xffffffef,%ecx
801080bb:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801080c1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801080c8:	83 e1 df             	and    $0xffffffdf,%ecx
801080cb:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801080d1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801080d8:	83 c9 40             	or     $0x40,%ecx
801080db:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801080e1:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801080e8:	83 e1 7f             	and    $0x7f,%ecx
801080eb:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801080f1:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801080f7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080fd:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108104:	83 e2 ef             	and    $0xffffffef,%edx
80108107:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
8010810d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108113:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108119:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010811f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108126:	8b 52 08             	mov    0x8(%edx),%edx
80108129:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010812f:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108132:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108139:	e8 ef f7 ff ff       	call   8010792d <ltr>
  if(p->pgdir == 0)
8010813e:	8b 45 08             	mov    0x8(%ebp),%eax
80108141:	8b 40 04             	mov    0x4(%eax),%eax
80108144:	85 c0                	test   %eax,%eax
80108146:	75 0c                	jne    80108154 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108148:	c7 04 24 17 8d 10 80 	movl   $0x80108d17,(%esp)
8010814f:	e8 e9 83 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108154:	8b 45 08             	mov    0x8(%ebp),%eax
80108157:	8b 40 04             	mov    0x4(%eax),%eax
8010815a:	89 04 24             	mov    %eax,(%esp)
8010815d:	e8 01 f8 ff ff       	call   80107963 <v2p>
80108162:	89 04 24             	mov    %eax,(%esp)
80108165:	e8 ee f7 ff ff       	call   80107958 <lcr3>
  popcli();
8010816a:	e8 3c d1 ff ff       	call   801052ab <popcli>
}
8010816f:	83 c4 14             	add    $0x14,%esp
80108172:	5b                   	pop    %ebx
80108173:	5d                   	pop    %ebp
80108174:	c3                   	ret    

80108175 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108175:	55                   	push   %ebp
80108176:	89 e5                	mov    %esp,%ebp
80108178:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010817b:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108182:	76 0c                	jbe    80108190 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108184:	c7 04 24 2b 8d 10 80 	movl   $0x80108d2b,(%esp)
8010818b:	e8 ad 83 ff ff       	call   8010053d <panic>
  mem = kalloc();
80108190:	e8 be ac ff ff       	call   80102e53 <kalloc>
80108195:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108198:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010819f:	00 
801081a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801081a7:	00 
801081a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ab:	89 04 24             	mov    %eax,(%esp)
801081ae:	e8 b7 d1 ff ff       	call   8010536a <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801081b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b6:	89 04 24             	mov    %eax,(%esp)
801081b9:	e8 a5 f7 ff ff       	call   80107963 <v2p>
801081be:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801081c5:	00 
801081c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
801081ca:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801081d1:	00 
801081d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801081d9:	00 
801081da:	8b 45 08             	mov    0x8(%ebp),%eax
801081dd:	89 04 24             	mov    %eax,(%esp)
801081e0:	e8 a4 fc ff ff       	call   80107e89 <mappages>
  memmove(mem, init, sz);
801081e5:	8b 45 10             	mov    0x10(%ebp),%eax
801081e8:	89 44 24 08          	mov    %eax,0x8(%esp)
801081ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801081ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801081f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f6:	89 04 24             	mov    %eax,(%esp)
801081f9:	e8 3f d2 ff ff       	call   8010543d <memmove>
}
801081fe:	c9                   	leave  
801081ff:	c3                   	ret    

80108200 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108200:	55                   	push   %ebp
80108201:	89 e5                	mov    %esp,%ebp
80108203:	53                   	push   %ebx
80108204:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108207:	8b 45 0c             	mov    0xc(%ebp),%eax
8010820a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010820f:	85 c0                	test   %eax,%eax
80108211:	74 0c                	je     8010821f <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108213:	c7 04 24 48 8d 10 80 	movl   $0x80108d48,(%esp)
8010821a:	e8 1e 83 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010821f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108226:	e9 ad 00 00 00       	jmp    801082d8 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010822b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822e:	8b 55 0c             	mov    0xc(%ebp),%edx
80108231:	01 d0                	add    %edx,%eax
80108233:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010823a:	00 
8010823b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010823f:	8b 45 08             	mov    0x8(%ebp),%eax
80108242:	89 04 24             	mov    %eax,(%esp)
80108245:	e8 a9 fb ff ff       	call   80107df3 <walkpgdir>
8010824a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010824d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108251:	75 0c                	jne    8010825f <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108253:	c7 04 24 6b 8d 10 80 	movl   $0x80108d6b,(%esp)
8010825a:	e8 de 82 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
8010825f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108262:	8b 00                	mov    (%eax),%eax
80108264:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108269:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010826c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826f:	8b 55 18             	mov    0x18(%ebp),%edx
80108272:	89 d1                	mov    %edx,%ecx
80108274:	29 c1                	sub    %eax,%ecx
80108276:	89 c8                	mov    %ecx,%eax
80108278:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010827d:	77 11                	ja     80108290 <loaduvm+0x90>
      n = sz - i;
8010827f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108282:	8b 55 18             	mov    0x18(%ebp),%edx
80108285:	89 d1                	mov    %edx,%ecx
80108287:	29 c1                	sub    %eax,%ecx
80108289:	89 c8                	mov    %ecx,%eax
8010828b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010828e:	eb 07                	jmp    80108297 <loaduvm+0x97>
    else
      n = PGSIZE;
80108290:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010829a:	8b 55 14             	mov    0x14(%ebp),%edx
8010829d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801082a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801082a3:	89 04 24             	mov    %eax,(%esp)
801082a6:	e8 c5 f6 ff ff       	call   80107970 <p2v>
801082ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801082ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
801082b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801082b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801082ba:	8b 45 10             	mov    0x10(%ebp),%eax
801082bd:	89 04 24             	mov    %eax,(%esp)
801082c0:	e8 ed 9d ff ff       	call   801020b2 <readi>
801082c5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801082c8:	74 07                	je     801082d1 <loaduvm+0xd1>
      return -1;
801082ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082cf:	eb 18                	jmp    801082e9 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801082d1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082db:	3b 45 18             	cmp    0x18(%ebp),%eax
801082de:	0f 82 47 ff ff ff    	jb     8010822b <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801082e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082e9:	83 c4 24             	add    $0x24,%esp
801082ec:	5b                   	pop    %ebx
801082ed:	5d                   	pop    %ebp
801082ee:	c3                   	ret    

801082ef <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801082ef:	55                   	push   %ebp
801082f0:	89 e5                	mov    %esp,%ebp
801082f2:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801082f5:	8b 45 10             	mov    0x10(%ebp),%eax
801082f8:	85 c0                	test   %eax,%eax
801082fa:	79 0a                	jns    80108306 <allocuvm+0x17>
    return 0;
801082fc:	b8 00 00 00 00       	mov    $0x0,%eax
80108301:	e9 c1 00 00 00       	jmp    801083c7 <allocuvm+0xd8>
  if(newsz < oldsz)
80108306:	8b 45 10             	mov    0x10(%ebp),%eax
80108309:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010830c:	73 08                	jae    80108316 <allocuvm+0x27>
    return oldsz;
8010830e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108311:	e9 b1 00 00 00       	jmp    801083c7 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108316:	8b 45 0c             	mov    0xc(%ebp),%eax
80108319:	05 ff 0f 00 00       	add    $0xfff,%eax
8010831e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108323:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108326:	e9 8d 00 00 00       	jmp    801083b8 <allocuvm+0xc9>
    mem = kalloc();
8010832b:	e8 23 ab ff ff       	call   80102e53 <kalloc>
80108330:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108333:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108337:	75 2c                	jne    80108365 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108339:	c7 04 24 89 8d 10 80 	movl   $0x80108d89,(%esp)
80108340:	e8 5c 80 ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108345:	8b 45 0c             	mov    0xc(%ebp),%eax
80108348:	89 44 24 08          	mov    %eax,0x8(%esp)
8010834c:	8b 45 10             	mov    0x10(%ebp),%eax
8010834f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108353:	8b 45 08             	mov    0x8(%ebp),%eax
80108356:	89 04 24             	mov    %eax,(%esp)
80108359:	e8 6b 00 00 00       	call   801083c9 <deallocuvm>
      return 0;
8010835e:	b8 00 00 00 00       	mov    $0x0,%eax
80108363:	eb 62                	jmp    801083c7 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108365:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010836c:	00 
8010836d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108374:	00 
80108375:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108378:	89 04 24             	mov    %eax,(%esp)
8010837b:	e8 ea cf ff ff       	call   8010536a <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108383:	89 04 24             	mov    %eax,(%esp)
80108386:	e8 d8 f5 ff ff       	call   80107963 <v2p>
8010838b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010838e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108395:	00 
80108396:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010839a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083a1:	00 
801083a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801083a6:	8b 45 08             	mov    0x8(%ebp),%eax
801083a9:	89 04 24             	mov    %eax,(%esp)
801083ac:	e8 d8 fa ff ff       	call   80107e89 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801083b1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083bb:	3b 45 10             	cmp    0x10(%ebp),%eax
801083be:	0f 82 67 ff ff ff    	jb     8010832b <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801083c4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801083c7:	c9                   	leave  
801083c8:	c3                   	ret    

801083c9 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083c9:	55                   	push   %ebp
801083ca:	89 e5                	mov    %esp,%ebp
801083cc:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801083cf:	8b 45 10             	mov    0x10(%ebp),%eax
801083d2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083d5:	72 08                	jb     801083df <deallocuvm+0x16>
    return oldsz;
801083d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801083da:	e9 a4 00 00 00       	jmp    80108483 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801083df:	8b 45 10             	mov    0x10(%ebp),%eax
801083e2:	05 ff 0f 00 00       	add    $0xfff,%eax
801083e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801083ef:	e9 80 00 00 00       	jmp    80108474 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801083f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083fe:	00 
801083ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80108403:	8b 45 08             	mov    0x8(%ebp),%eax
80108406:	89 04 24             	mov    %eax,(%esp)
80108409:	e8 e5 f9 ff ff       	call   80107df3 <walkpgdir>
8010840e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108411:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108415:	75 09                	jne    80108420 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108417:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010841e:	eb 4d                	jmp    8010846d <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108420:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108423:	8b 00                	mov    (%eax),%eax
80108425:	83 e0 01             	and    $0x1,%eax
80108428:	84 c0                	test   %al,%al
8010842a:	74 41                	je     8010846d <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
8010842c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010842f:	8b 00                	mov    (%eax),%eax
80108431:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108436:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108439:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010843d:	75 0c                	jne    8010844b <deallocuvm+0x82>
        panic("kfree");
8010843f:	c7 04 24 a1 8d 10 80 	movl   $0x80108da1,(%esp)
80108446:	e8 f2 80 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
8010844b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010844e:	89 04 24             	mov    %eax,(%esp)
80108451:	e8 1a f5 ff ff       	call   80107970 <p2v>
80108456:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108459:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010845c:	89 04 24             	mov    %eax,(%esp)
8010845f:	e8 56 a9 ff ff       	call   80102dba <kfree>
      *pte = 0;
80108464:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108467:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010846d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108477:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010847a:	0f 82 74 ff ff ff    	jb     801083f4 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108480:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108483:	c9                   	leave  
80108484:	c3                   	ret    

80108485 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108485:	55                   	push   %ebp
80108486:	89 e5                	mov    %esp,%ebp
80108488:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010848b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010848f:	75 0c                	jne    8010849d <freevm+0x18>
    panic("freevm: no pgdir");
80108491:	c7 04 24 a7 8d 10 80 	movl   $0x80108da7,(%esp)
80108498:	e8 a0 80 ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010849d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084a4:	00 
801084a5:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801084ac:	80 
801084ad:	8b 45 08             	mov    0x8(%ebp),%eax
801084b0:	89 04 24             	mov    %eax,(%esp)
801084b3:	e8 11 ff ff ff       	call   801083c9 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801084b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084bf:	eb 3c                	jmp    801084fd <freevm+0x78>
    if(pgdir[i] & PTE_P){
801084c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c4:	c1 e0 02             	shl    $0x2,%eax
801084c7:	03 45 08             	add    0x8(%ebp),%eax
801084ca:	8b 00                	mov    (%eax),%eax
801084cc:	83 e0 01             	and    $0x1,%eax
801084cf:	84 c0                	test   %al,%al
801084d1:	74 26                	je     801084f9 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801084d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d6:	c1 e0 02             	shl    $0x2,%eax
801084d9:	03 45 08             	add    0x8(%ebp),%eax
801084dc:	8b 00                	mov    (%eax),%eax
801084de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084e3:	89 04 24             	mov    %eax,(%esp)
801084e6:	e8 85 f4 ff ff       	call   80107970 <p2v>
801084eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801084ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084f1:	89 04 24             	mov    %eax,(%esp)
801084f4:	e8 c1 a8 ff ff       	call   80102dba <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801084f9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801084fd:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108504:	76 bb                	jbe    801084c1 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108506:	8b 45 08             	mov    0x8(%ebp),%eax
80108509:	89 04 24             	mov    %eax,(%esp)
8010850c:	e8 a9 a8 ff ff       	call   80102dba <kfree>
}
80108511:	c9                   	leave  
80108512:	c3                   	ret    

80108513 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108513:	55                   	push   %ebp
80108514:	89 e5                	mov    %esp,%ebp
80108516:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108519:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108520:	00 
80108521:	8b 45 0c             	mov    0xc(%ebp),%eax
80108524:	89 44 24 04          	mov    %eax,0x4(%esp)
80108528:	8b 45 08             	mov    0x8(%ebp),%eax
8010852b:	89 04 24             	mov    %eax,(%esp)
8010852e:	e8 c0 f8 ff ff       	call   80107df3 <walkpgdir>
80108533:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108536:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010853a:	75 0c                	jne    80108548 <clearpteu+0x35>
    panic("clearpteu");
8010853c:	c7 04 24 b8 8d 10 80 	movl   $0x80108db8,(%esp)
80108543:	e8 f5 7f ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80108548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854b:	8b 00                	mov    (%eax),%eax
8010854d:	89 c2                	mov    %eax,%edx
8010854f:	83 e2 fb             	and    $0xfffffffb,%edx
80108552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108555:	89 10                	mov    %edx,(%eax)
}
80108557:	c9                   	leave  
80108558:	c3                   	ret    

80108559 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108559:	55                   	push   %ebp
8010855a:	89 e5                	mov    %esp,%ebp
8010855c:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
8010855f:	e8 b9 f9 ff ff       	call   80107f1d <setupkvm>
80108564:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108567:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010856b:	75 0a                	jne    80108577 <copyuvm+0x1e>
    return 0;
8010856d:	b8 00 00 00 00       	mov    $0x0,%eax
80108572:	e9 f1 00 00 00       	jmp    80108668 <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
80108577:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010857e:	e9 c0 00 00 00       	jmp    80108643 <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108586:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010858d:	00 
8010858e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108592:	8b 45 08             	mov    0x8(%ebp),%eax
80108595:	89 04 24             	mov    %eax,(%esp)
80108598:	e8 56 f8 ff ff       	call   80107df3 <walkpgdir>
8010859d:	89 45 ec             	mov    %eax,-0x14(%ebp)
801085a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085a4:	75 0c                	jne    801085b2 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
801085a6:	c7 04 24 c2 8d 10 80 	movl   $0x80108dc2,(%esp)
801085ad:	e8 8b 7f ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
801085b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085b5:	8b 00                	mov    (%eax),%eax
801085b7:	83 e0 01             	and    $0x1,%eax
801085ba:	85 c0                	test   %eax,%eax
801085bc:	75 0c                	jne    801085ca <copyuvm+0x71>
      panic("copyuvm: page not present");
801085be:	c7 04 24 dc 8d 10 80 	movl   $0x80108ddc,(%esp)
801085c5:	e8 73 7f ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801085ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085cd:	8b 00                	mov    (%eax),%eax
801085cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
801085d7:	e8 77 a8 ff ff       	call   80102e53 <kalloc>
801085dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801085df:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801085e3:	74 6f                	je     80108654 <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801085e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085e8:	89 04 24             	mov    %eax,(%esp)
801085eb:	e8 80 f3 ff ff       	call   80107970 <p2v>
801085f0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085f7:	00 
801085f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801085fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801085ff:	89 04 24             	mov    %eax,(%esp)
80108602:	e8 36 ce ff ff       	call   8010543d <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
80108607:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010860a:	89 04 24             	mov    %eax,(%esp)
8010860d:	e8 51 f3 ff ff       	call   80107963 <v2p>
80108612:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108615:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010861c:	00 
8010861d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108621:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108628:	00 
80108629:	89 54 24 04          	mov    %edx,0x4(%esp)
8010862d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108630:	89 04 24             	mov    %eax,(%esp)
80108633:	e8 51 f8 ff ff       	call   80107e89 <mappages>
80108638:	85 c0                	test   %eax,%eax
8010863a:	78 1b                	js     80108657 <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010863c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108646:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108649:	0f 82 34 ff ff ff    	jb     80108583 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
8010864f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108652:	eb 14                	jmp    80108668 <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108654:	90                   	nop
80108655:	eb 01                	jmp    80108658 <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
80108657:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108658:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010865b:	89 04 24             	mov    %eax,(%esp)
8010865e:	e8 22 fe ff ff       	call   80108485 <freevm>
  return 0;
80108663:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108668:	c9                   	leave  
80108669:	c3                   	ret    

8010866a <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010866a:	55                   	push   %ebp
8010866b:	89 e5                	mov    %esp,%ebp
8010866d:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108670:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108677:	00 
80108678:	8b 45 0c             	mov    0xc(%ebp),%eax
8010867b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010867f:	8b 45 08             	mov    0x8(%ebp),%eax
80108682:	89 04 24             	mov    %eax,(%esp)
80108685:	e8 69 f7 ff ff       	call   80107df3 <walkpgdir>
8010868a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010868d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108690:	8b 00                	mov    (%eax),%eax
80108692:	83 e0 01             	and    $0x1,%eax
80108695:	85 c0                	test   %eax,%eax
80108697:	75 07                	jne    801086a0 <uva2ka+0x36>
    return 0;
80108699:	b8 00 00 00 00       	mov    $0x0,%eax
8010869e:	eb 25                	jmp    801086c5 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801086a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a3:	8b 00                	mov    (%eax),%eax
801086a5:	83 e0 04             	and    $0x4,%eax
801086a8:	85 c0                	test   %eax,%eax
801086aa:	75 07                	jne    801086b3 <uva2ka+0x49>
    return 0;
801086ac:	b8 00 00 00 00       	mov    $0x0,%eax
801086b1:	eb 12                	jmp    801086c5 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801086b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b6:	8b 00                	mov    (%eax),%eax
801086b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086bd:	89 04 24             	mov    %eax,(%esp)
801086c0:	e8 ab f2 ff ff       	call   80107970 <p2v>
}
801086c5:	c9                   	leave  
801086c6:	c3                   	ret    

801086c7 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801086c7:	55                   	push   %ebp
801086c8:	89 e5                	mov    %esp,%ebp
801086ca:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801086cd:	8b 45 10             	mov    0x10(%ebp),%eax
801086d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801086d3:	e9 8b 00 00 00       	jmp    80108763 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
801086d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801086db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801086e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801086ea:	8b 45 08             	mov    0x8(%ebp),%eax
801086ed:	89 04 24             	mov    %eax,(%esp)
801086f0:	e8 75 ff ff ff       	call   8010866a <uva2ka>
801086f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801086f8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801086fc:	75 07                	jne    80108705 <copyout+0x3e>
      return -1;
801086fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108703:	eb 6d                	jmp    80108772 <copyout+0xab>
    n = PGSIZE - (va - va0);
80108705:	8b 45 0c             	mov    0xc(%ebp),%eax
80108708:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010870b:	89 d1                	mov    %edx,%ecx
8010870d:	29 c1                	sub    %eax,%ecx
8010870f:	89 c8                	mov    %ecx,%eax
80108711:	05 00 10 00 00       	add    $0x1000,%eax
80108716:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108719:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010871c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010871f:	76 06                	jbe    80108727 <copyout+0x60>
      n = len;
80108721:	8b 45 14             	mov    0x14(%ebp),%eax
80108724:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108727:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010872a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010872d:	89 d1                	mov    %edx,%ecx
8010872f:	29 c1                	sub    %eax,%ecx
80108731:	89 c8                	mov    %ecx,%eax
80108733:	03 45 e8             	add    -0x18(%ebp),%eax
80108736:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108739:	89 54 24 08          	mov    %edx,0x8(%esp)
8010873d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108740:	89 54 24 04          	mov    %edx,0x4(%esp)
80108744:	89 04 24             	mov    %eax,(%esp)
80108747:	e8 f1 cc ff ff       	call   8010543d <memmove>
    len -= n;
8010874c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010874f:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108752:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108755:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108758:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010875b:	05 00 10 00 00       	add    $0x1000,%eax
80108760:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108763:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108767:	0f 85 6b ff ff ff    	jne    801086d8 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010876d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108772:	c9                   	leave  
80108773:	c3                   	ret    
