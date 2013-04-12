
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
8010002d:	b8 e3 36 10 80       	mov    $0x801036e3,%eax
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
8010003a:	c7 44 24 04 4c 88 10 	movl   $0x8010884c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 30 51 00 00       	call   8010517e <initlock>

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
801000bd:	e8 dd 50 00 00       	call   8010519f <acquire>

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
80100104:	e8 f8 50 00 00       	call   80105201 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 e6 4c 00 00       	call   80104e0a <sleep>
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
8010017c:	e8 80 50 00 00       	call   80105201 <release>
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
80100198:	c7 04 24 53 88 10 80 	movl   $0x80108853,(%esp)
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
801001d3:	e8 b8 28 00 00       	call   80102a90 <iderw>
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
801001ef:	c7 04 24 64 88 10 80 	movl   $0x80108864,(%esp)
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
80100210:	e8 7b 28 00 00       	call   80102a90 <iderw>
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
80100229:	c7 04 24 6b 88 10 80 	movl   $0x8010886b,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 5e 4f 00 00       	call   8010519f <acquire>

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
8010029d:	e8 44 4c 00 00       	call   80104ee6 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 53 4f 00 00       	call   80105201 <release>
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
80100390:	e8 f1 03 00 00       	call   80100786 <consputc>
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
801003bc:	e8 de 4d 00 00       	call   8010519f <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 72 88 10 80 	movl   $0x80108872,(%esp)
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
801003f2:	e8 8f 03 00 00       	call   80100786 <consputc>
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
801004af:	c7 45 ec 7b 88 10 80 	movl   $0x8010887b,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 bd 02 00 00       	call   80100786 <consputc>
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
801004e3:	e8 9e 02 00 00       	call   80100786 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 90 02 00 00       	call   80100786 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 85 02 00 00       	call   80100786 <consputc>
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
80100536:	e8 c6 4c 00 00       	call   80105201 <release>
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
80100562:	c7 04 24 82 88 10 80 	movl   $0x80108882,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 91 88 10 80 	movl   $0x80108891,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 b9 4c 00 00       	call   80105250 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 93 88 10 80 	movl   $0x80108893,(%esp)
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
80100656:	eb 56                	jmp    801006ae <cgaputc+0xe1>
  else if(c == BACKSPACE){
80100658:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065f:	75 0c                	jne    8010066d <cgaputc+0xa0>
    if(pos > 0) --pos;
80100661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100665:	7e 47                	jle    801006ae <cgaputc+0xe1>
80100667:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010066b:	eb 41                	jmp    801006ae <cgaputc+0xe1>
  }
  else if(c == KEY_LF){		// decreasing pos in a left key is pressed
8010066d:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
80100674:	75 0c                	jne    80100682 <cgaputc+0xb5>
    if(pos > 0)
80100676:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010067a:	7e 32                	jle    801006ae <cgaputc+0xe1>
      --pos;
8010067c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100680:	eb 2c                	jmp    801006ae <cgaputc+0xe1>
  }
  else if(c == KEY_RT){		// decreasing pos in a right key is pressed
80100682:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
80100689:	75 06                	jne    80100691 <cgaputc+0xc4>
    ++pos;
8010068b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010068f:	eb 1d                	jmp    801006ae <cgaputc+0xe1>
  }
  else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100691:	a1 00 90 10 80       	mov    0x80109000,%eax
80100696:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100699:	01 d2                	add    %edx,%edx
8010069b:	01 c2                	add    %eax,%edx
8010069d:	8b 45 08             	mov    0x8(%ebp),%eax
801006a0:	66 25 ff 00          	and    $0xff,%ax
801006a4:	80 cc 07             	or     $0x7,%ah
801006a7:	66 89 02             	mov    %ax,(%edx)
801006aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
801006ae:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006b5:	7e 53                	jle    8010070a <cgaputc+0x13d>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006b7:	a1 00 90 10 80       	mov    0x80109000,%eax
801006bc:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006c2:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c7:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006ce:	00 
801006cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801006d3:	89 04 24             	mov    %eax,(%esp)
801006d6:	e8 e6 4d 00 00       	call   801054c1 <memmove>
    pos -= 80;
801006db:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006df:	b8 80 07 00 00       	mov    $0x780,%eax
801006e4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006e7:	01 c0                	add    %eax,%eax
801006e9:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801006ef:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006f2:	01 c9                	add    %ecx,%ecx
801006f4:	01 ca                	add    %ecx,%edx
801006f6:	89 44 24 08          	mov    %eax,0x8(%esp)
801006fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100701:	00 
80100702:	89 14 24             	mov    %edx,(%esp)
80100705:	e8 e4 4c 00 00       	call   801053ee <memset>
  }
  
  outb(CRTPORT, 14);
8010070a:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100711:	00 
80100712:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100719:	e8 bc fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
8010071e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100721:	c1 f8 08             	sar    $0x8,%eax
80100724:	0f b6 c0             	movzbl %al,%eax
80100727:	89 44 24 04          	mov    %eax,0x4(%esp)
8010072b:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100732:	e8 a3 fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
80100737:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010073e:	00 
8010073f:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100746:	e8 8f fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
8010074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010074e:	0f b6 c0             	movzbl %al,%eax
80100751:	89 44 24 04          	mov    %eax,0x4(%esp)
80100755:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010075c:	e8 79 fb ff ff       	call   801002da <outb>
  if(c != KEY_LF && c != KEY_RT)
80100761:	81 7d 08 e4 00 00 00 	cmpl   $0xe4,0x8(%ebp)
80100768:	74 1a                	je     80100784 <cgaputc+0x1b7>
8010076a:	81 7d 08 e5 00 00 00 	cmpl   $0xe5,0x8(%ebp)
80100771:	74 11                	je     80100784 <cgaputc+0x1b7>
    crt[pos] = ' ' | 0x0700;
80100773:	a1 00 90 10 80       	mov    0x80109000,%eax
80100778:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010077b:	01 d2                	add    %edx,%edx
8010077d:	01 d0                	add    %edx,%eax
8010077f:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100784:	c9                   	leave  
80100785:	c3                   	ret    

80100786 <consputc>:

void
consputc(int c)
{
80100786:	55                   	push   %ebp
80100787:	89 e5                	mov    %esp,%ebp
80100789:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
8010078c:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100791:	85 c0                	test   %eax,%eax
80100793:	74 07                	je     8010079c <consputc+0x16>
    cli();
80100795:	e8 5e fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
8010079a:	eb fe                	jmp    8010079a <consputc+0x14>
  }

  if(c == BACKSPACE){
8010079c:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007a3:	75 26                	jne    801007cb <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007a5:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007ac:	e8 00 67 00 00       	call   80106eb1 <uartputc>
801007b1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801007b8:	e8 f4 66 00 00       	call   80106eb1 <uartputc>
801007bd:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007c4:	e8 e8 66 00 00       	call   80106eb1 <uartputc>
801007c9:	eb 0b                	jmp    801007d6 <consputc+0x50>
  }
  else if (c == KEY_RT){
    uartputc(0x601);
  }*/
  else
    uartputc(c);
801007cb:	8b 45 08             	mov    0x8(%ebp),%eax
801007ce:	89 04 24             	mov    %eax,(%esp)
801007d1:	e8 db 66 00 00       	call   80106eb1 <uartputc>
  cgaputc(c);
801007d6:	8b 45 08             	mov    0x8(%ebp),%eax
801007d9:	89 04 24             	mov    %eax,(%esp)
801007dc:	e8 ec fd ff ff       	call   801005cd <cgaputc>
}
801007e1:	c9                   	leave  
801007e2:	c3                   	ret    

801007e3 <shiftRightBuf>:

#define C(x)  ((x)-'@')  // Control-x

void
shiftRightBuf(uint e, uint k)			// a function for shifting our buffer one step to the right from the place we're not inserting
{						// k is our left we are in our line and e hold the end of line
801007e3:	55                   	push   %ebp
801007e4:	89 e5                	mov    %esp,%ebp
801007e6:	83 ec 10             	sub    $0x10,%esp
  uint j=0;
801007e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(;j < k;e--,j++){
801007f0:	eb 21                	jmp    80100813 <shiftRightBuf+0x30>
    input.buf[e] = input.buf[e-1];
801007f2:	8b 45 08             	mov    0x8(%ebp),%eax
801007f5:	83 e8 01             	sub    $0x1,%eax
801007f8:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
801007ff:	8b 55 08             	mov    0x8(%ebp),%edx
80100802:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
80100808:	88 42 04             	mov    %al,0x4(%edx)

void
shiftRightBuf(uint e, uint k)			// a function for shifting our buffer one step to the right from the place we're not inserting
{						// k is our left we are in our line and e hold the end of line
  uint j=0;
  for(;j < k;e--,j++){
8010080b:	83 6d 08 01          	subl   $0x1,0x8(%ebp)
8010080f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80100813:	8b 45 fc             	mov    -0x4(%ebp),%eax
80100816:	3b 45 0c             	cmp    0xc(%ebp),%eax
80100819:	72 d7                	jb     801007f2 <shiftRightBuf+0xf>
    input.buf[e] = input.buf[e-1];
  }
}
8010081b:	c9                   	leave  
8010081c:	c3                   	ret    

8010081d <shiftLeftBuf>:

void
shiftLeftBuf(uint e, uint k)			// a function for shifting our buffer one step to the left from the place we're not backspacing
{						// k is our left we are in our line and e hold the end of line
8010081d:	55                   	push   %ebp
8010081e:	89 e5                	mov    %esp,%ebp
80100820:	83 ec 10             	sub    $0x10,%esp
  uint i = e-k;
80100823:	8b 45 0c             	mov    0xc(%ebp),%eax
80100826:	8b 55 08             	mov    0x8(%ebp),%edx
80100829:	89 d1                	mov    %edx,%ecx
8010082b:	29 c1                	sub    %eax,%ecx
8010082d:	89 c8                	mov    %ecx,%eax
8010082f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  uint j=0;
80100832:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(;j < k ;i++,j++){
80100839:	eb 21                	jmp    8010085c <shiftLeftBuf+0x3f>
    input.buf[i] = input.buf[i+1];
8010083b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010083e:	83 c0 01             	add    $0x1,%eax
80100841:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100848:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010084b:	81 c2 d0 dd 10 80    	add    $0x8010ddd0,%edx
80100851:	88 42 04             	mov    %al,0x4(%edx)
void
shiftLeftBuf(uint e, uint k)			// a function for shifting our buffer one step to the left from the place we're not backspacing
{						// k is our left we are in our line and e hold the end of line
  uint i = e-k;
  uint j=0;
  for(;j < k ;i++,j++){
80100854:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80100858:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010085c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010085f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80100862:	72 d7                	jb     8010083b <shiftLeftBuf+0x1e>
    input.buf[i] = input.buf[i+1];
  }
  input.buf[e] = ' ';
80100864:	8b 45 08             	mov    0x8(%ebp),%eax
80100867:	05 d0 dd 10 80       	add    $0x8010ddd0,%eax
8010086c:	c6 40 04 20          	movb   $0x20,0x4(%eax)
}
80100870:	c9                   	leave  
80100871:	c3                   	ret    

80100872 <consoleintr>:

void
consoleintr(int (*getc)(void))
{
80100872:	55                   	push   %ebp
80100873:	89 e5                	mov    %esp,%ebp
80100875:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
80100878:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
8010087f:	e8 1b 49 00 00       	call   8010519f <acquire>
  while((c = getc()) >= 0){
80100884:	e9 57 03 00 00       	jmp    80100be0 <consoleintr+0x36e>
    switch(c){
80100889:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010088c:	83 f8 15             	cmp    $0x15,%eax
8010088f:	74 59                	je     801008ea <consoleintr+0x78>
80100891:	83 f8 15             	cmp    $0x15,%eax
80100894:	7f 0f                	jg     801008a5 <consoleintr+0x33>
80100896:	83 f8 08             	cmp    $0x8,%eax
80100899:	74 7e                	je     80100919 <consoleintr+0xa7>
8010089b:	83 f8 10             	cmp    $0x10,%eax
8010089e:	74 25                	je     801008c5 <consoleintr+0x53>
801008a0:	e9 d7 01 00 00       	jmp    80100a7c <consoleintr+0x20a>
801008a5:	3d e4 00 00 00       	cmp    $0xe4,%eax
801008aa:	0f 84 44 01 00 00    	je     801009f4 <consoleintr+0x182>
801008b0:	3d e5 00 00 00       	cmp    $0xe5,%eax
801008b5:	0f 84 7b 01 00 00    	je     80100a36 <consoleintr+0x1c4>
801008bb:	83 f8 7f             	cmp    $0x7f,%eax
801008be:	74 59                	je     80100919 <consoleintr+0xa7>
801008c0:	e9 b7 01 00 00       	jmp    80100a7c <consoleintr+0x20a>
    case C('P'):  // Process listing.
      procdump();
801008c5:	e8 c2 46 00 00       	call   80104f8c <procdump>
      break;
801008ca:	e9 11 03 00 00       	jmp    80100be0 <consoleintr+0x36e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008cf:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801008d4:	83 e8 01             	sub    $0x1,%eax
801008d7:	a3 5c de 10 80       	mov    %eax,0x8010de5c
        consputc(BACKSPACE);
801008dc:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801008e3:	e8 9e fe ff ff       	call   80100786 <consputc>
801008e8:	eb 01                	jmp    801008eb <consoleintr+0x79>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008ea:	90                   	nop
801008eb:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801008f1:	a1 58 de 10 80       	mov    0x8010de58,%eax
801008f6:	39 c2                	cmp    %eax,%edx
801008f8:	0f 84 d5 02 00 00    	je     80100bd3 <consoleintr+0x361>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008fe:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100903:	83 e8 01             	sub    $0x1,%eax
80100906:	83 e0 7f             	and    $0x7f,%eax
80100909:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100910:	3c 0a                	cmp    $0xa,%al
80100912:	75 bb                	jne    801008cf <consoleintr+0x5d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100914:	e9 ba 02 00 00       	jmp    80100bd3 <consoleintr+0x361>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100919:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010091f:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100924:	39 c2                	cmp    %eax,%edx
80100926:	0f 84 aa 02 00 00    	je     80100bd6 <consoleintr+0x364>
	if(input.a > 0)			// Checking if backspace was pressed not at the end marker
8010092c:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100931:	85 c0                	test   %eax,%eax
80100933:	0f 84 9d 00 00 00    	je     801009d6 <consoleintr+0x164>
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);	// shift our buffer one step to the left and print backspace
80100939:	a1 60 de 10 80       	mov    0x8010de60,%eax
8010093e:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100944:	83 ea 01             	sub    $0x1,%edx
80100947:	83 e2 7f             	and    $0x7f,%edx
8010094a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010094e:	89 14 24             	mov    %edx,(%esp)
80100951:	e8 c7 fe ff ff       	call   8010081d <shiftLeftBuf>
	    uint i = input.e-input.a-1;
80100956:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
8010095c:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100961:	89 d1                	mov    %edx,%ecx
80100963:	29 c1                	sub    %eax,%ecx
80100965:	89 c8                	mov    %ecx,%eax
80100967:	83 e8 01             	sub    $0x1,%eax
8010096a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    consputc(KEY_LF);					// move the screen marker one step to the left
8010096d:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100974:	e8 0d fe ff ff       	call   80100786 <consputc>
	    for(;i<input.e;i++){ 
80100979:	eb 1c                	jmp    80100997 <consoleintr+0x125>
	      consputc(input.buf[i%INPUT_BUF]);		// print to the screen all the characters that were on the right hand side of where we
8010097b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010097e:	83 e0 7f             	and    $0x7f,%eax
80100981:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100988:	0f be c0             	movsbl %al,%eax
8010098b:	89 04 24             	mov    %eax,(%esp)
8010098e:	e8 f3 fd ff ff       	call   80100786 <consputc>
	if(input.a > 0)			// Checking if backspace was pressed not at the end marker
	{
	    shiftLeftBuf((input.e-1) % INPUT_BUF,input.a);	// shift our buffer one step to the left and print backspace
	    uint i = input.e-input.a-1;
	    consputc(KEY_LF);					// move the screen marker one step to the left
	    for(;i<input.e;i++){ 
80100993:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100997:	a1 5c de 10 80       	mov    0x8010de5c,%eax
8010099c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010099f:	77 da                	ja     8010097b <consoleintr+0x109>
	      consputc(input.buf[i%INPUT_BUF]);		// print to the screen all the characters that were on the right hand side of where we
	    }							// we entred backspace
	    i = input.e-input.a;
801009a1:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
801009a7:	a1 60 de 10 80       	mov    0x8010de60,%eax
801009ac:	89 d1                	mov    %edx,%ecx
801009ae:	29 c1                	sub    %eax,%ecx
801009b0:	89 c8                	mov    %ecx,%eax
801009b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	    for(;i<input.e+1;i++){				// move the line marker back to were it was before pressing backspace
801009b5:	eb 10                	jmp    801009c7 <consoleintr+0x155>
	      consputc(KEY_LF);
801009b7:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
801009be:	e8 c3 fd ff ff       	call   80100786 <consputc>
	    consputc(KEY_LF);					// move the screen marker one step to the left
	    for(;i<input.e;i++){ 
	      consputc(input.buf[i%INPUT_BUF]);		// print to the screen all the characters that were on the right hand side of where we
	    }							// we entred backspace
	    i = input.e-input.a;
	    for(;i<input.e+1;i++){				// move the line marker back to were it was before pressing backspace
801009c3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801009c7:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801009cc:	83 c0 01             	add    $0x1,%eax
801009cf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009d2:	77 e3                	ja     801009b7 <consoleintr+0x145>
801009d4:	eb 0c                	jmp    801009e2 <consoleintr+0x170>
	      consputc(KEY_LF);
	    }
	}
	else
	{
	  consputc(BACKSPACE);		// if not, we'll pring backspace to the screen
801009d6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801009dd:	e8 a4 fd ff ff       	call   80100786 <consputc>
	}
	input.e--;
801009e2:	a1 5c de 10 80       	mov    0x8010de5c,%eax
801009e7:	83 e8 01             	sub    $0x1,%eax
801009ea:	a3 5c de 10 80       	mov    %eax,0x8010de5c
      }
      break;
801009ef:	e9 e2 01 00 00       	jmp    80100bd6 <consoleintr+0x364>
    case KEY_LF: //LEFT KEY
     if(c != 0 && input.e - input.a > input.w)		// if there is still room to move left
801009f4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801009f8:	0f 84 db 01 00 00    	je     80100bd9 <consoleintr+0x367>
801009fe:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a04:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a09:	29 c2                	sub    %eax,%edx
80100a0b:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100a10:	39 c2                	cmp    %eax,%edx
80100a12:	0f 86 c1 01 00 00    	jbe    80100bd9 <consoleintr+0x367>
      {
        consputc(KEY_LF);				// move our marker one step to the left
80100a18:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100a1f:	e8 62 fd ff ff       	call   80100786 <consputc>
	input.a++;					// increament our left steps counter
80100a24:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a29:	83 c0 01             	add    $0x1,%eax
80100a2c:	a3 60 de 10 80       	mov    %eax,0x8010de60
      }
      break;
80100a31:	e9 a3 01 00 00       	jmp    80100bd9 <consoleintr+0x367>
    case KEY_RT: //RIGHT KEY
      if(c != 0 && input.a > 0 && input.e % INPUT_BUF < INPUT_BUF-1) // if we're not at the end of the line and we've moved to the left before
80100a36:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a3a:	0f 84 9c 01 00 00    	je     80100bdc <consoleintr+0x36a>
80100a40:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a45:	85 c0                	test   %eax,%eax
80100a47:	0f 84 8f 01 00 00    	je     80100bdc <consoleintr+0x36a>
80100a4d:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100a52:	83 e0 7f             	and    $0x7f,%eax
80100a55:	83 f8 7e             	cmp    $0x7e,%eax
80100a58:	0f 87 7e 01 00 00    	ja     80100bdc <consoleintr+0x36a>
      {	
        consputc(KEY_RT);				// move our marker one step to the right
80100a5e:	c7 04 24 e5 00 00 00 	movl   $0xe5,(%esp)
80100a65:	e8 1c fd ff ff       	call   80100786 <consputc>
	input.a--;					// decreament our left steps counter				
80100a6a:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100a6f:	83 e8 01             	sub    $0x1,%eax
80100a72:	a3 60 de 10 80       	mov    %eax,0x8010de60
      }
      break;
80100a77:	e9 60 01 00 00       	jmp    80100bdc <consoleintr+0x36a>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
80100a7c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a80:	0f 84 59 01 00 00    	je     80100bdf <consoleintr+0x36d>
80100a86:	8b 15 5c de 10 80    	mov    0x8010de5c,%edx
80100a8c:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100a91:	89 d1                	mov    %edx,%ecx
80100a93:	29 c1                	sub    %eax,%ecx
80100a95:	89 c8                	mov    %ecx,%eax
80100a97:	83 f8 7f             	cmp    $0x7f,%eax
80100a9a:	0f 87 3f 01 00 00    	ja     80100bdf <consoleintr+0x36d>
      {
	c = (c == '\r') ? '\n' : c;
80100aa0:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
80100aa4:	74 05                	je     80100aab <consoleintr+0x239>
80100aa6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100aa9:	eb 05                	jmp    80100ab0 <consoleintr+0x23e>
80100aab:	b8 0a 00 00 00       	mov    $0xa,%eax
80100ab0:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(c != '\n' && input.a > 0)			// checking if we have moved left from the end of the line
80100ab3:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100ab7:	0f 84 b0 00 00 00    	je     80100b6d <consoleintr+0x2fb>
80100abd:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100ac2:	85 c0                	test   %eax,%eax
80100ac4:	0f 84 a3 00 00 00    	je     80100b6d <consoleintr+0x2fb>
	{
	    uint k = input.a;
80100aca:	a1 60 de 10 80       	mov    0x8010de60,%eax
80100acf:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    shiftRightBuf((input.e) % INPUT_BUF,k);	// shift our buffer one step to the write
80100ad2:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100ad7:	89 c2                	mov    %eax,%edx
80100ad9:	83 e2 7f             	and    $0x7f,%edx
80100adc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100adf:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ae3:	89 14 24             	mov    %edx,(%esp)
80100ae6:	e8 f8 fc ff ff       	call   801007e3 <shiftRightBuf>
	    input.buf[(input.e-k) % INPUT_BUF] = c;	// write to the buffer the inserted letter
80100aeb:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100af0:	2b 45 e8             	sub    -0x18(%ebp),%eax
80100af3:	89 c2                	mov    %eax,%edx
80100af5:	83 e2 7f             	and    $0x7f,%edx
80100af8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100afb:	88 82 d4 dd 10 80    	mov    %al,-0x7fef222c(%edx)
	    
	    uint i = input.e-k;
80100b01:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b06:	2b 45 e8             	sub    -0x18(%ebp),%eax
80100b09:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e+1;i++)			// print to the screen all the characters on the right hand side of the inserted character
80100b0c:	eb 1c                	jmp    80100b2a <consoleintr+0x2b8>
	      consputc(input.buf[i%INPUT_BUF]);
80100b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100b11:	83 e0 7f             	and    $0x7f,%eax
80100b14:	0f b6 80 d4 dd 10 80 	movzbl -0x7fef222c(%eax),%eax
80100b1b:	0f be c0             	movsbl %al,%eax
80100b1e:	89 04 24             	mov    %eax,(%esp)
80100b21:	e8 60 fc ff ff       	call   80100786 <consputc>
	    uint k = input.a;
	    shiftRightBuf((input.e) % INPUT_BUF,k);	// shift our buffer one step to the write
	    input.buf[(input.e-k) % INPUT_BUF] = c;	// write to the buffer the inserted letter
	    
	    uint i = input.e-k;
	    for(;i<input.e+1;i++)			// print to the screen all the characters on the right hand side of the inserted character
80100b26:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100b2a:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b2f:	83 c0 01             	add    $0x1,%eax
80100b32:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80100b35:	77 d7                	ja     80100b0e <consoleintr+0x29c>
	      consputc(input.buf[i%INPUT_BUF]);
	    
	    i = input.e-k;				// move our line marker to where it was before inserting a character
80100b37:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b3c:	2b 45 e8             	sub    -0x18(%ebp),%eax
80100b3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	    for(;i<input.e;i++)
80100b42:	eb 10                	jmp    80100b54 <consoleintr+0x2e2>
	      consputc(KEY_LF);
80100b44:	c7 04 24 e4 00 00 00 	movl   $0xe4,(%esp)
80100b4b:	e8 36 fc ff ff       	call   80100786 <consputc>
	    uint i = input.e-k;
	    for(;i<input.e+1;i++)			// print to the screen all the characters on the right hand side of the inserted character
	      consputc(input.buf[i%INPUT_BUF]);
	    
	    i = input.e-k;				// move our line marker to where it was before inserting a character
	    for(;i<input.e;i++)
80100b50:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80100b54:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b59:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80100b5c:	77 e6                	ja     80100b44 <consoleintr+0x2d2>
	      consputc(KEY_LF);
	
	    input.e++;
80100b5e:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b63:	83 c0 01             	add    $0x1,%eax
80100b66:	a3 5c de 10 80       	mov    %eax,0x8010de5c
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF)
      {
	c = (c == '\r') ? '\n' : c;
	if(c != '\n' && input.a > 0)			// checking if we have moved left from the end of the line
	{
80100b6b:	eb 26                	jmp    80100b93 <consoleintr+0x321>
	      consputc(KEY_LF);
	
	    input.e++;
	}
	else {
	  input.buf[input.e++ % INPUT_BUF] = c;
80100b6d:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100b72:	89 c1                	mov    %eax,%ecx
80100b74:	83 e1 7f             	and    $0x7f,%ecx
80100b77:	8b 55 ec             	mov    -0x14(%ebp),%edx
80100b7a:	88 91 d4 dd 10 80    	mov    %dl,-0x7fef222c(%ecx)
80100b80:	83 c0 01             	add    $0x1,%eax
80100b83:	a3 5c de 10 80       	mov    %eax,0x8010de5c
          consputc(c);
80100b88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100b8b:	89 04 24             	mov    %eax,(%esp)
80100b8e:	e8 f3 fb ff ff       	call   80100786 <consputc>
	}
	
	if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF)
80100b93:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
80100b97:	74 18                	je     80100bb1 <consoleintr+0x33f>
80100b99:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
80100b9d:	74 12                	je     80100bb1 <consoleintr+0x33f>
80100b9f:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100ba4:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100baa:	83 ea 80             	sub    $0xffffff80,%edx
80100bad:	39 d0                	cmp    %edx,%eax
80100baf:	75 2e                	jne    80100bdf <consoleintr+0x36d>
	{
	  input.w = input.e;
80100bb1:	a1 5c de 10 80       	mov    0x8010de5c,%eax
80100bb6:	a3 58 de 10 80       	mov    %eax,0x8010de58
          wakeup(&input.r);
80100bbb:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100bc2:	e8 1f 43 00 00       	call   80104ee6 <wakeup>
	  input.a = 0;					// after exec we'll init our left steps counter
80100bc7:	c7 05 60 de 10 80 00 	movl   $0x0,0x8010de60
80100bce:	00 00 00 
        }
      }
      break;
80100bd1:	eb 0c                	jmp    80100bdf <consoleintr+0x36d>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100bd3:	90                   	nop
80100bd4:	eb 0a                	jmp    80100be0 <consoleintr+0x36e>
	{
	  consputc(BACKSPACE);		// if not, we'll pring backspace to the screen
	}
	input.e--;
      }
      break;
80100bd6:	90                   	nop
80100bd7:	eb 07                	jmp    80100be0 <consoleintr+0x36e>
     if(c != 0 && input.e - input.a > input.w)		// if there is still room to move left
      {
        consputc(KEY_LF);				// move our marker one step to the left
	input.a++;					// increament our left steps counter
      }
      break;
80100bd9:	90                   	nop
80100bda:	eb 04                	jmp    80100be0 <consoleintr+0x36e>
      if(c != 0 && input.a > 0 && input.e % INPUT_BUF < INPUT_BUF-1) // if we're not at the end of the line and we've moved to the left before
      {	
        consputc(KEY_RT);				// move our marker one step to the right
	input.a--;					// decreament our left steps counter				
      }
      break;
80100bdc:	90                   	nop
80100bdd:	eb 01                	jmp    80100be0 <consoleintr+0x36e>
	  input.w = input.e;
          wakeup(&input.r);
	  input.a = 0;					// after exec we'll init our left steps counter
        }
      }
      break;
80100bdf:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100be0:	8b 45 08             	mov    0x8(%ebp),%eax
80100be3:	ff d0                	call   *%eax
80100be5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100be8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100bec:	0f 89 97 fc ff ff    	jns    80100889 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100bf2:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100bf9:	e8 03 46 00 00       	call   80105201 <release>
}
80100bfe:	c9                   	leave  
80100bff:	c3                   	ret    

80100c00 <consoleread>:


int
consoleread(struct inode *ip, char *dst, int n)
{
80100c00:	55                   	push   %ebp
80100c01:	89 e5                	mov    %esp,%ebp
80100c03:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100c06:	8b 45 08             	mov    0x8(%ebp),%eax
80100c09:	89 04 24             	mov    %eax,(%esp)
80100c0c:	e8 81 10 00 00       	call   80101c92 <iunlock>
  target = n;
80100c11:	8b 45 10             	mov    0x10(%ebp),%eax
80100c14:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100c17:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c1e:	e8 7c 45 00 00       	call   8010519f <acquire>
  while(n > 0){
80100c23:	e9 a8 00 00 00       	jmp    80100cd0 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
80100c28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100c2e:	8b 40 24             	mov    0x24(%eax),%eax
80100c31:	85 c0                	test   %eax,%eax
80100c33:	74 21                	je     80100c56 <consoleread+0x56>
        release(&input.lock);
80100c35:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100c3c:	e8 c0 45 00 00       	call   80105201 <release>
        ilock(ip);
80100c41:	8b 45 08             	mov    0x8(%ebp),%eax
80100c44:	89 04 24             	mov    %eax,(%esp)
80100c47:	e8 f8 0e 00 00       	call   80101b44 <ilock>
        return -1;
80100c4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c51:	e9 a9 00 00 00       	jmp    80100cff <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
80100c56:	c7 44 24 04 a0 dd 10 	movl   $0x8010dda0,0x4(%esp)
80100c5d:	80 
80100c5e:	c7 04 24 54 de 10 80 	movl   $0x8010de54,(%esp)
80100c65:	e8 a0 41 00 00       	call   80104e0a <sleep>
80100c6a:	eb 01                	jmp    80100c6d <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100c6c:	90                   	nop
80100c6d:	8b 15 54 de 10 80    	mov    0x8010de54,%edx
80100c73:	a1 58 de 10 80       	mov    0x8010de58,%eax
80100c78:	39 c2                	cmp    %eax,%edx
80100c7a:	74 ac                	je     80100c28 <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100c7c:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100c81:	89 c2                	mov    %eax,%edx
80100c83:	83 e2 7f             	and    $0x7f,%edx
80100c86:	0f b6 92 d4 dd 10 80 	movzbl -0x7fef222c(%edx),%edx
80100c8d:	0f be d2             	movsbl %dl,%edx
80100c90:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100c93:	83 c0 01             	add    $0x1,%eax
80100c96:	a3 54 de 10 80       	mov    %eax,0x8010de54
    if(c == C('D')){  // EOF
80100c9b:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100c9f:	75 17                	jne    80100cb8 <consoleread+0xb8>
      if(n < target){
80100ca1:	8b 45 10             	mov    0x10(%ebp),%eax
80100ca4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100ca7:	73 2f                	jae    80100cd8 <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100ca9:	a1 54 de 10 80       	mov    0x8010de54,%eax
80100cae:	83 e8 01             	sub    $0x1,%eax
80100cb1:	a3 54 de 10 80       	mov    %eax,0x8010de54
      }
      break;
80100cb6:	eb 20                	jmp    80100cd8 <consoleread+0xd8>
    }
    *dst++ = c;
80100cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100cbb:	89 c2                	mov    %eax,%edx
80100cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80100cc0:	88 10                	mov    %dl,(%eax)
80100cc2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
80100cc6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100cca:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100cce:	74 0b                	je     80100cdb <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100cd0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100cd4:	7f 96                	jg     80100c6c <consoleread+0x6c>
80100cd6:	eb 04                	jmp    80100cdc <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100cd8:	90                   	nop
80100cd9:	eb 01                	jmp    80100cdc <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100cdb:	90                   	nop
  }
  release(&input.lock);
80100cdc:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100ce3:	e8 19 45 00 00       	call   80105201 <release>
  ilock(ip);
80100ce8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ceb:	89 04 24             	mov    %eax,(%esp)
80100cee:	e8 51 0e 00 00       	call   80101b44 <ilock>

  return target - n;
80100cf3:	8b 45 10             	mov    0x10(%ebp),%eax
80100cf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100cf9:	89 d1                	mov    %edx,%ecx
80100cfb:	29 c1                	sub    %eax,%ecx
80100cfd:	89 c8                	mov    %ecx,%eax
}
80100cff:	c9                   	leave  
80100d00:	c3                   	ret    

80100d01 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100d01:	55                   	push   %ebp
80100d02:	89 e5                	mov    %esp,%ebp
80100d04:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100d07:	8b 45 08             	mov    0x8(%ebp),%eax
80100d0a:	89 04 24             	mov    %eax,(%esp)
80100d0d:	e8 80 0f 00 00       	call   80101c92 <iunlock>
  acquire(&cons.lock);
80100d12:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d19:	e8 81 44 00 00       	call   8010519f <acquire>
  for(i = 0; i < n; i++)
80100d1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100d25:	eb 1d                	jmp    80100d44 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d2a:	03 45 0c             	add    0xc(%ebp),%eax
80100d2d:	0f b6 00             	movzbl (%eax),%eax
80100d30:	0f be c0             	movsbl %al,%eax
80100d33:	25 ff 00 00 00       	and    $0xff,%eax
80100d38:	89 04 24             	mov    %eax,(%esp)
80100d3b:	e8 46 fa ff ff       	call   80100786 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100d40:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100d47:	3b 45 10             	cmp    0x10(%ebp),%eax
80100d4a:	7c db                	jl     80100d27 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100d4c:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d53:	e8 a9 44 00 00       	call   80105201 <release>
  ilock(ip);
80100d58:	8b 45 08             	mov    0x8(%ebp),%eax
80100d5b:	89 04 24             	mov    %eax,(%esp)
80100d5e:	e8 e1 0d 00 00       	call   80101b44 <ilock>

  return n;
80100d63:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100d66:	c9                   	leave  
80100d67:	c3                   	ret    

80100d68 <consoleinit>:

void
consoleinit(void)
{
80100d68:	55                   	push   %ebp
80100d69:	89 e5                	mov    %esp,%ebp
80100d6b:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100d6e:	c7 44 24 04 97 88 10 	movl   $0x80108897,0x4(%esp)
80100d75:	80 
80100d76:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100d7d:	e8 fc 43 00 00       	call   8010517e <initlock>
  initlock(&input.lock, "input");
80100d82:	c7 44 24 04 9f 88 10 	movl   $0x8010889f,0x4(%esp)
80100d89:	80 
80100d8a:	c7 04 24 a0 dd 10 80 	movl   $0x8010dda0,(%esp)
80100d91:	e8 e8 43 00 00       	call   8010517e <initlock>

  devsw[CONSOLE].write = consolewrite;
80100d96:	c7 05 2c e8 10 80 01 	movl   $0x80100d01,0x8010e82c
80100d9d:	0d 10 80 
  devsw[CONSOLE].read = consoleread;
80100da0:	c7 05 28 e8 10 80 00 	movl   $0x80100c00,0x8010e828
80100da7:	0c 10 80 
  cons.locking = 1;
80100daa:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100db1:	00 00 00 

  picenable(IRQ_KBD);
80100db4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100dbb:	e8 dd 2f 00 00       	call   80103d9d <picenable>
  ioapicenable(IRQ_KBD, 0);
80100dc0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100dc7:	00 
80100dc8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100dcf:	e8 7e 1e 00 00       	call   80102c52 <ioapicenable>
}
80100dd4:	c9                   	leave  
80100dd5:	c3                   	ret    
	...

80100dd8 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100dd8:	55                   	push   %ebp
80100dd9:	89 e5                	mov    %esp,%ebp
80100ddb:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100de1:	8b 45 08             	mov    0x8(%ebp),%eax
80100de4:	89 04 24             	mov    %eax,(%esp)
80100de7:	e8 fa 18 00 00       	call   801026e6 <namei>
80100dec:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100def:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100df3:	75 0a                	jne    80100dff <exec+0x27>
    return -1;
80100df5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100dfa:	e9 da 03 00 00       	jmp    801011d9 <exec+0x401>
  ilock(ip);
80100dff:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e02:	89 04 24             	mov    %eax,(%esp)
80100e05:	e8 3a 0d 00 00       	call   80101b44 <ilock>
  pgdir = 0;
80100e0a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100e11:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100e18:	00 
80100e19:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100e20:	00 
80100e21:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100e27:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e2b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e2e:	89 04 24             	mov    %eax,(%esp)
80100e31:	e8 04 12 00 00       	call   8010203a <readi>
80100e36:	83 f8 33             	cmp    $0x33,%eax
80100e39:	0f 86 54 03 00 00    	jbe    80101193 <exec+0x3bb>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100e3f:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100e45:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100e4a:	0f 85 46 03 00 00    	jne    80101196 <exec+0x3be>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100e50:	c7 04 24 db 2d 10 80 	movl   $0x80102ddb,(%esp)
80100e57:	e8 99 71 00 00       	call   80107ff5 <setupkvm>
80100e5c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100e5f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100e63:	0f 84 30 03 00 00    	je     80101199 <exec+0x3c1>
    goto bad;

  // Load program into memory.
  sz = 0;
80100e69:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e70:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100e77:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100e7d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e80:	e9 c5 00 00 00       	jmp    80100f4a <exec+0x172>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100e85:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100e88:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100e8f:	00 
80100e90:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e94:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100e9a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e9e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ea1:	89 04 24             	mov    %eax,(%esp)
80100ea4:	e8 91 11 00 00       	call   8010203a <readi>
80100ea9:	83 f8 20             	cmp    $0x20,%eax
80100eac:	0f 85 ea 02 00 00    	jne    8010119c <exec+0x3c4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100eb2:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100eb8:	83 f8 01             	cmp    $0x1,%eax
80100ebb:	75 7f                	jne    80100f3c <exec+0x164>
      continue;
    if(ph.memsz < ph.filesz)
80100ebd:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100ec3:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ec9:	39 c2                	cmp    %eax,%edx
80100ecb:	0f 82 ce 02 00 00    	jb     8010119f <exec+0x3c7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ed1:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100ed7:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100edd:	01 d0                	add    %edx,%eax
80100edf:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ee3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ee6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100eea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100eed:	89 04 24             	mov    %eax,(%esp)
80100ef0:	e8 d2 74 00 00       	call   801083c7 <allocuvm>
80100ef5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ef8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100efc:	0f 84 a0 02 00 00    	je     801011a2 <exec+0x3ca>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100f02:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100f08:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100f0e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100f14:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100f18:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100f1c:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100f1f:	89 54 24 08          	mov    %edx,0x8(%esp)
80100f23:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f27:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f2a:	89 04 24             	mov    %eax,(%esp)
80100f2d:	e8 a6 73 00 00       	call   801082d8 <loaduvm>
80100f32:	85 c0                	test   %eax,%eax
80100f34:	0f 88 6b 02 00 00    	js     801011a5 <exec+0x3cd>
80100f3a:	eb 01                	jmp    80100f3d <exec+0x165>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100f3c:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100f3d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100f41:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100f44:	83 c0 20             	add    $0x20,%eax
80100f47:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100f4a:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100f51:	0f b7 c0             	movzwl %ax,%eax
80100f54:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100f57:	0f 8f 28 ff ff ff    	jg     80100e85 <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100f5d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f60:	89 04 24             	mov    %eax,(%esp)
80100f63:	e8 60 0e 00 00       	call   80101dc8 <iunlockput>
  ip = 0;
80100f68:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100f6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f72:	05 ff 0f 00 00       	add    $0xfff,%eax
80100f77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100f7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100f7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f82:	05 00 20 00 00       	add    $0x2000,%eax
80100f87:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f95:	89 04 24             	mov    %eax,(%esp)
80100f98:	e8 2a 74 00 00       	call   801083c7 <allocuvm>
80100f9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100fa0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100fa4:	0f 84 fe 01 00 00    	je     801011a8 <exec+0x3d0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100faa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fad:	2d 00 20 00 00       	sub    $0x2000,%eax
80100fb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fb6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fb9:	89 04 24             	mov    %eax,(%esp)
80100fbc:	e8 2a 76 00 00       	call   801085eb <clearpteu>
  sp = sz;
80100fc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100fc4:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100fc7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100fce:	e9 81 00 00 00       	jmp    80101054 <exec+0x27c>
    if(argc >= MAXARG)
80100fd3:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100fd7:	0f 87 ce 01 00 00    	ja     801011ab <exec+0x3d3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100fdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fe0:	c1 e0 02             	shl    $0x2,%eax
80100fe3:	03 45 0c             	add    0xc(%ebp),%eax
80100fe6:	8b 00                	mov    (%eax),%eax
80100fe8:	89 04 24             	mov    %eax,(%esp)
80100feb:	e8 7c 46 00 00       	call   8010566c <strlen>
80100ff0:	f7 d0                	not    %eax
80100ff2:	03 45 dc             	add    -0x24(%ebp),%eax
80100ff5:	83 e0 fc             	and    $0xfffffffc,%eax
80100ff8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ffb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ffe:	c1 e0 02             	shl    $0x2,%eax
80101001:	03 45 0c             	add    0xc(%ebp),%eax
80101004:	8b 00                	mov    (%eax),%eax
80101006:	89 04 24             	mov    %eax,(%esp)
80101009:	e8 5e 46 00 00       	call   8010566c <strlen>
8010100e:	83 c0 01             	add    $0x1,%eax
80101011:	89 c2                	mov    %eax,%edx
80101013:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101016:	c1 e0 02             	shl    $0x2,%eax
80101019:	03 45 0c             	add    0xc(%ebp),%eax
8010101c:	8b 00                	mov    (%eax),%eax
8010101e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80101022:	89 44 24 08          	mov    %eax,0x8(%esp)
80101026:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101029:	89 44 24 04          	mov    %eax,0x4(%esp)
8010102d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101030:	89 04 24             	mov    %eax,(%esp)
80101033:	e8 67 77 00 00       	call   8010879f <copyout>
80101038:	85 c0                	test   %eax,%eax
8010103a:	0f 88 6e 01 00 00    	js     801011ae <exec+0x3d6>
      goto bad;
    ustack[3+argc] = sp;
80101040:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101043:	8d 50 03             	lea    0x3(%eax),%edx
80101046:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101049:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80101050:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101057:	c1 e0 02             	shl    $0x2,%eax
8010105a:	03 45 0c             	add    0xc(%ebp),%eax
8010105d:	8b 00                	mov    (%eax),%eax
8010105f:	85 c0                	test   %eax,%eax
80101061:	0f 85 6c ff ff ff    	jne    80100fd3 <exec+0x1fb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80101067:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010106a:	83 c0 03             	add    $0x3,%eax
8010106d:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80101074:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80101078:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
8010107f:	ff ff ff 
  ustack[1] = argc;
80101082:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101085:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
8010108b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010108e:	83 c0 01             	add    $0x1,%eax
80101091:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101098:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010109b:	29 d0                	sub    %edx,%eax
8010109d:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
801010a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010a6:	83 c0 04             	add    $0x4,%eax
801010a9:	c1 e0 02             	shl    $0x2,%eax
801010ac:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
801010af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010b2:	83 c0 04             	add    $0x4,%eax
801010b5:	c1 e0 02             	shl    $0x2,%eax
801010b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
801010bc:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
801010c2:	89 44 24 08          	mov    %eax,0x8(%esp)
801010c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801010c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801010cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801010d0:	89 04 24             	mov    %eax,(%esp)
801010d3:	e8 c7 76 00 00       	call   8010879f <copyout>
801010d8:	85 c0                	test   %eax,%eax
801010da:	0f 88 d1 00 00 00    	js     801011b1 <exec+0x3d9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
801010e0:	8b 45 08             	mov    0x8(%ebp),%eax
801010e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801010e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801010ec:	eb 17                	jmp    80101105 <exec+0x32d>
    if(*s == '/')
801010ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010f1:	0f b6 00             	movzbl (%eax),%eax
801010f4:	3c 2f                	cmp    $0x2f,%al
801010f6:	75 09                	jne    80101101 <exec+0x329>
      last = s+1;
801010f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010fb:	83 c0 01             	add    $0x1,%eax
801010fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80101101:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101108:	0f b6 00             	movzbl (%eax),%eax
8010110b:	84 c0                	test   %al,%al
8010110d:	75 df                	jne    801010ee <exec+0x316>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
8010110f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101115:	8d 50 6c             	lea    0x6c(%eax),%edx
80101118:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010111f:	00 
80101120:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101123:	89 44 24 04          	mov    %eax,0x4(%esp)
80101127:	89 14 24             	mov    %edx,(%esp)
8010112a:	e8 ef 44 00 00       	call   8010561e <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
8010112f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101135:	8b 40 04             	mov    0x4(%eax),%eax
80101138:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
8010113b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101141:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101144:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80101147:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010114d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101150:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80101152:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101158:	8b 40 18             	mov    0x18(%eax),%eax
8010115b:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80101161:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80101164:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010116a:	8b 40 18             	mov    0x18(%eax),%eax
8010116d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101170:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80101173:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80101179:	89 04 24             	mov    %eax,(%esp)
8010117c:	e8 65 6f 00 00       	call   801080e6 <switchuvm>
  freevm(oldpgdir);
80101181:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101184:	89 04 24             	mov    %eax,(%esp)
80101187:	e8 d1 73 00 00       	call   8010855d <freevm>
  return 0;
8010118c:	b8 00 00 00 00       	mov    $0x0,%eax
80101191:	eb 46                	jmp    801011d9 <exec+0x401>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80101193:	90                   	nop
80101194:	eb 1c                	jmp    801011b2 <exec+0x3da>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80101196:	90                   	nop
80101197:	eb 19                	jmp    801011b2 <exec+0x3da>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
80101199:	90                   	nop
8010119a:	eb 16                	jmp    801011b2 <exec+0x3da>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
8010119c:	90                   	nop
8010119d:	eb 13                	jmp    801011b2 <exec+0x3da>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
8010119f:	90                   	nop
801011a0:	eb 10                	jmp    801011b2 <exec+0x3da>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
801011a2:	90                   	nop
801011a3:	eb 0d                	jmp    801011b2 <exec+0x3da>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
801011a5:	90                   	nop
801011a6:	eb 0a                	jmp    801011b2 <exec+0x3da>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
801011a8:	90                   	nop
801011a9:	eb 07                	jmp    801011b2 <exec+0x3da>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
801011ab:	90                   	nop
801011ac:	eb 04                	jmp    801011b2 <exec+0x3da>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
801011ae:	90                   	nop
801011af:	eb 01                	jmp    801011b2 <exec+0x3da>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
801011b1:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
801011b2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801011b6:	74 0b                	je     801011c3 <exec+0x3eb>
    freevm(pgdir);
801011b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801011bb:	89 04 24             	mov    %eax,(%esp)
801011be:	e8 9a 73 00 00       	call   8010855d <freevm>
  if(ip)
801011c3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801011c7:	74 0b                	je     801011d4 <exec+0x3fc>
    iunlockput(ip);
801011c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801011cc:	89 04 24             	mov    %eax,(%esp)
801011cf:	e8 f4 0b 00 00       	call   80101dc8 <iunlockput>
  return -1;
801011d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011d9:	c9                   	leave  
801011da:	c3                   	ret    
	...

801011dc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801011dc:	55                   	push   %ebp
801011dd:	89 e5                	mov    %esp,%ebp
801011df:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
801011e2:	c7 44 24 04 a5 88 10 	movl   $0x801088a5,0x4(%esp)
801011e9:	80 
801011ea:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801011f1:	e8 88 3f 00 00       	call   8010517e <initlock>
}
801011f6:	c9                   	leave  
801011f7:	c3                   	ret    

801011f8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801011f8:	55                   	push   %ebp
801011f9:	89 e5                	mov    %esp,%ebp
801011fb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
801011fe:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101205:	e8 95 3f 00 00       	call   8010519f <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010120a:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
80101211:	eb 29                	jmp    8010123c <filealloc+0x44>
    if(f->ref == 0){
80101213:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101216:	8b 40 04             	mov    0x4(%eax),%eax
80101219:	85 c0                	test   %eax,%eax
8010121b:	75 1b                	jne    80101238 <filealloc+0x40>
      f->ref = 1;
8010121d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101220:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101227:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010122e:	e8 ce 3f 00 00       	call   80105201 <release>
      return f;
80101233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101236:	eb 1e                	jmp    80101256 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101238:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010123c:	81 7d f4 14 e8 10 80 	cmpl   $0x8010e814,-0xc(%ebp)
80101243:	72 ce                	jb     80101213 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101245:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010124c:	e8 b0 3f 00 00       	call   80105201 <release>
  return 0;
80101251:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101256:	c9                   	leave  
80101257:	c3                   	ret    

80101258 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101258:	55                   	push   %ebp
80101259:	89 e5                	mov    %esp,%ebp
8010125b:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
8010125e:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101265:	e8 35 3f 00 00       	call   8010519f <acquire>
  if(f->ref < 1)
8010126a:	8b 45 08             	mov    0x8(%ebp),%eax
8010126d:	8b 40 04             	mov    0x4(%eax),%eax
80101270:	85 c0                	test   %eax,%eax
80101272:	7f 0c                	jg     80101280 <filedup+0x28>
    panic("filedup");
80101274:	c7 04 24 ac 88 10 80 	movl   $0x801088ac,(%esp)
8010127b:	e8 bd f2 ff ff       	call   8010053d <panic>
  f->ref++;
80101280:	8b 45 08             	mov    0x8(%ebp),%eax
80101283:	8b 40 04             	mov    0x4(%eax),%eax
80101286:	8d 50 01             	lea    0x1(%eax),%edx
80101289:	8b 45 08             	mov    0x8(%ebp),%eax
8010128c:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010128f:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101296:	e8 66 3f 00 00       	call   80105201 <release>
  return f;
8010129b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010129e:	c9                   	leave  
8010129f:	c3                   	ret    

801012a0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801012a0:	55                   	push   %ebp
801012a1:	89 e5                	mov    %esp,%ebp
801012a3:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
801012a6:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012ad:	e8 ed 3e 00 00       	call   8010519f <acquire>
  if(f->ref < 1)
801012b2:	8b 45 08             	mov    0x8(%ebp),%eax
801012b5:	8b 40 04             	mov    0x4(%eax),%eax
801012b8:	85 c0                	test   %eax,%eax
801012ba:	7f 0c                	jg     801012c8 <fileclose+0x28>
    panic("fileclose");
801012bc:	c7 04 24 b4 88 10 80 	movl   $0x801088b4,(%esp)
801012c3:	e8 75 f2 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
801012c8:	8b 45 08             	mov    0x8(%ebp),%eax
801012cb:	8b 40 04             	mov    0x4(%eax),%eax
801012ce:	8d 50 ff             	lea    -0x1(%eax),%edx
801012d1:	8b 45 08             	mov    0x8(%ebp),%eax
801012d4:	89 50 04             	mov    %edx,0x4(%eax)
801012d7:	8b 45 08             	mov    0x8(%ebp),%eax
801012da:	8b 40 04             	mov    0x4(%eax),%eax
801012dd:	85 c0                	test   %eax,%eax
801012df:	7e 11                	jle    801012f2 <fileclose+0x52>
    release(&ftable.lock);
801012e1:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
801012e8:	e8 14 3f 00 00       	call   80105201 <release>
    return;
801012ed:	e9 82 00 00 00       	jmp    80101374 <fileclose+0xd4>
  }
  ff = *f;
801012f2:	8b 45 08             	mov    0x8(%ebp),%eax
801012f5:	8b 10                	mov    (%eax),%edx
801012f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
801012fa:	8b 50 04             	mov    0x4(%eax),%edx
801012fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101300:	8b 50 08             	mov    0x8(%eax),%edx
80101303:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101306:	8b 50 0c             	mov    0xc(%eax),%edx
80101309:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010130c:	8b 50 10             	mov    0x10(%eax),%edx
8010130f:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101312:	8b 40 14             	mov    0x14(%eax),%eax
80101315:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101318:	8b 45 08             	mov    0x8(%ebp),%eax
8010131b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101322:	8b 45 08             	mov    0x8(%ebp),%eax
80101325:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010132b:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101332:	e8 ca 3e 00 00       	call   80105201 <release>
  
  if(ff.type == FD_PIPE)
80101337:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010133a:	83 f8 01             	cmp    $0x1,%eax
8010133d:	75 18                	jne    80101357 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010133f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101343:	0f be d0             	movsbl %al,%edx
80101346:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101349:	89 54 24 04          	mov    %edx,0x4(%esp)
8010134d:	89 04 24             	mov    %eax,(%esp)
80101350:	e8 02 2d 00 00       	call   80104057 <pipeclose>
80101355:	eb 1d                	jmp    80101374 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101357:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010135a:	83 f8 02             	cmp    $0x2,%eax
8010135d:	75 15                	jne    80101374 <fileclose+0xd4>
    begin_trans();
8010135f:	e8 95 21 00 00       	call   801034f9 <begin_trans>
    iput(ff.ip);
80101364:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101367:	89 04 24             	mov    %eax,(%esp)
8010136a:	e8 88 09 00 00       	call   80101cf7 <iput>
    commit_trans();
8010136f:	e8 ce 21 00 00       	call   80103542 <commit_trans>
  }
}
80101374:	c9                   	leave  
80101375:	c3                   	ret    

80101376 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101376:	55                   	push   %ebp
80101377:	89 e5                	mov    %esp,%ebp
80101379:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
8010137c:	8b 45 08             	mov    0x8(%ebp),%eax
8010137f:	8b 00                	mov    (%eax),%eax
80101381:	83 f8 02             	cmp    $0x2,%eax
80101384:	75 38                	jne    801013be <filestat+0x48>
    ilock(f->ip);
80101386:	8b 45 08             	mov    0x8(%ebp),%eax
80101389:	8b 40 10             	mov    0x10(%eax),%eax
8010138c:	89 04 24             	mov    %eax,(%esp)
8010138f:	e8 b0 07 00 00       	call   80101b44 <ilock>
    stati(f->ip, st);
80101394:	8b 45 08             	mov    0x8(%ebp),%eax
80101397:	8b 40 10             	mov    0x10(%eax),%eax
8010139a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010139d:	89 54 24 04          	mov    %edx,0x4(%esp)
801013a1:	89 04 24             	mov    %eax,(%esp)
801013a4:	e8 4c 0c 00 00       	call   80101ff5 <stati>
    iunlock(f->ip);
801013a9:	8b 45 08             	mov    0x8(%ebp),%eax
801013ac:	8b 40 10             	mov    0x10(%eax),%eax
801013af:	89 04 24             	mov    %eax,(%esp)
801013b2:	e8 db 08 00 00       	call   80101c92 <iunlock>
    return 0;
801013b7:	b8 00 00 00 00       	mov    $0x0,%eax
801013bc:	eb 05                	jmp    801013c3 <filestat+0x4d>
  }
  return -1;
801013be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801013c3:	c9                   	leave  
801013c4:	c3                   	ret    

801013c5 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801013c5:	55                   	push   %ebp
801013c6:	89 e5                	mov    %esp,%ebp
801013c8:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801013cb:	8b 45 08             	mov    0x8(%ebp),%eax
801013ce:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801013d2:	84 c0                	test   %al,%al
801013d4:	75 0a                	jne    801013e0 <fileread+0x1b>
    return -1;
801013d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013db:	e9 9f 00 00 00       	jmp    8010147f <fileread+0xba>
  if(f->type == FD_PIPE)
801013e0:	8b 45 08             	mov    0x8(%ebp),%eax
801013e3:	8b 00                	mov    (%eax),%eax
801013e5:	83 f8 01             	cmp    $0x1,%eax
801013e8:	75 1e                	jne    80101408 <fileread+0x43>
    return piperead(f->pipe, addr, n);
801013ea:	8b 45 08             	mov    0x8(%ebp),%eax
801013ed:	8b 40 0c             	mov    0xc(%eax),%eax
801013f0:	8b 55 10             	mov    0x10(%ebp),%edx
801013f3:	89 54 24 08          	mov    %edx,0x8(%esp)
801013f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801013fa:	89 54 24 04          	mov    %edx,0x4(%esp)
801013fe:	89 04 24             	mov    %eax,(%esp)
80101401:	e8 d3 2d 00 00       	call   801041d9 <piperead>
80101406:	eb 77                	jmp    8010147f <fileread+0xba>
  if(f->type == FD_INODE){
80101408:	8b 45 08             	mov    0x8(%ebp),%eax
8010140b:	8b 00                	mov    (%eax),%eax
8010140d:	83 f8 02             	cmp    $0x2,%eax
80101410:	75 61                	jne    80101473 <fileread+0xae>
    ilock(f->ip);
80101412:	8b 45 08             	mov    0x8(%ebp),%eax
80101415:	8b 40 10             	mov    0x10(%eax),%eax
80101418:	89 04 24             	mov    %eax,(%esp)
8010141b:	e8 24 07 00 00       	call   80101b44 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101420:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101423:	8b 45 08             	mov    0x8(%ebp),%eax
80101426:	8b 50 14             	mov    0x14(%eax),%edx
80101429:	8b 45 08             	mov    0x8(%ebp),%eax
8010142c:	8b 40 10             	mov    0x10(%eax),%eax
8010142f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101433:	89 54 24 08          	mov    %edx,0x8(%esp)
80101437:	8b 55 0c             	mov    0xc(%ebp),%edx
8010143a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010143e:	89 04 24             	mov    %eax,(%esp)
80101441:	e8 f4 0b 00 00       	call   8010203a <readi>
80101446:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101449:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010144d:	7e 11                	jle    80101460 <fileread+0x9b>
      f->off += r;
8010144f:	8b 45 08             	mov    0x8(%ebp),%eax
80101452:	8b 50 14             	mov    0x14(%eax),%edx
80101455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101458:	01 c2                	add    %eax,%edx
8010145a:	8b 45 08             	mov    0x8(%ebp),%eax
8010145d:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101460:	8b 45 08             	mov    0x8(%ebp),%eax
80101463:	8b 40 10             	mov    0x10(%eax),%eax
80101466:	89 04 24             	mov    %eax,(%esp)
80101469:	e8 24 08 00 00       	call   80101c92 <iunlock>
    return r;
8010146e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101471:	eb 0c                	jmp    8010147f <fileread+0xba>
  }
  panic("fileread");
80101473:	c7 04 24 be 88 10 80 	movl   $0x801088be,(%esp)
8010147a:	e8 be f0 ff ff       	call   8010053d <panic>
}
8010147f:	c9                   	leave  
80101480:	c3                   	ret    

80101481 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101481:	55                   	push   %ebp
80101482:	89 e5                	mov    %esp,%ebp
80101484:	53                   	push   %ebx
80101485:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101488:	8b 45 08             	mov    0x8(%ebp),%eax
8010148b:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010148f:	84 c0                	test   %al,%al
80101491:	75 0a                	jne    8010149d <filewrite+0x1c>
    return -1;
80101493:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101498:	e9 23 01 00 00       	jmp    801015c0 <filewrite+0x13f>
  if(f->type == FD_PIPE)
8010149d:	8b 45 08             	mov    0x8(%ebp),%eax
801014a0:	8b 00                	mov    (%eax),%eax
801014a2:	83 f8 01             	cmp    $0x1,%eax
801014a5:	75 21                	jne    801014c8 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801014a7:	8b 45 08             	mov    0x8(%ebp),%eax
801014aa:	8b 40 0c             	mov    0xc(%eax),%eax
801014ad:	8b 55 10             	mov    0x10(%ebp),%edx
801014b0:	89 54 24 08          	mov    %edx,0x8(%esp)
801014b4:	8b 55 0c             	mov    0xc(%ebp),%edx
801014b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801014bb:	89 04 24             	mov    %eax,(%esp)
801014be:	e8 26 2c 00 00       	call   801040e9 <pipewrite>
801014c3:	e9 f8 00 00 00       	jmp    801015c0 <filewrite+0x13f>
  if(f->type == FD_INODE){
801014c8:	8b 45 08             	mov    0x8(%ebp),%eax
801014cb:	8b 00                	mov    (%eax),%eax
801014cd:	83 f8 02             	cmp    $0x2,%eax
801014d0:	0f 85 de 00 00 00    	jne    801015b4 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801014d6:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801014dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801014e4:	e9 a8 00 00 00       	jmp    80101591 <filewrite+0x110>
      int n1 = n - i;
801014e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014ec:	8b 55 10             	mov    0x10(%ebp),%edx
801014ef:	89 d1                	mov    %edx,%ecx
801014f1:	29 c1                	sub    %eax,%ecx
801014f3:	89 c8                	mov    %ecx,%eax
801014f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801014f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014fb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801014fe:	7e 06                	jle    80101506 <filewrite+0x85>
        n1 = max;
80101500:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101503:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
80101506:	e8 ee 1f 00 00       	call   801034f9 <begin_trans>
      ilock(f->ip);
8010150b:	8b 45 08             	mov    0x8(%ebp),%eax
8010150e:	8b 40 10             	mov    0x10(%eax),%eax
80101511:	89 04 24             	mov    %eax,(%esp)
80101514:	e8 2b 06 00 00       	call   80101b44 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101519:	8b 5d f0             	mov    -0x10(%ebp),%ebx
8010151c:	8b 45 08             	mov    0x8(%ebp),%eax
8010151f:	8b 48 14             	mov    0x14(%eax),%ecx
80101522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101525:	89 c2                	mov    %eax,%edx
80101527:	03 55 0c             	add    0xc(%ebp),%edx
8010152a:	8b 45 08             	mov    0x8(%ebp),%eax
8010152d:	8b 40 10             	mov    0x10(%eax),%eax
80101530:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80101534:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80101538:	89 54 24 04          	mov    %edx,0x4(%esp)
8010153c:	89 04 24             	mov    %eax,(%esp)
8010153f:	e8 61 0c 00 00       	call   801021a5 <writei>
80101544:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101547:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010154b:	7e 11                	jle    8010155e <filewrite+0xdd>
        f->off += r;
8010154d:	8b 45 08             	mov    0x8(%ebp),%eax
80101550:	8b 50 14             	mov    0x14(%eax),%edx
80101553:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101556:	01 c2                	add    %eax,%edx
80101558:	8b 45 08             	mov    0x8(%ebp),%eax
8010155b:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010155e:	8b 45 08             	mov    0x8(%ebp),%eax
80101561:	8b 40 10             	mov    0x10(%eax),%eax
80101564:	89 04 24             	mov    %eax,(%esp)
80101567:	e8 26 07 00 00       	call   80101c92 <iunlock>
      commit_trans();
8010156c:	e8 d1 1f 00 00       	call   80103542 <commit_trans>

      if(r < 0)
80101571:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101575:	78 28                	js     8010159f <filewrite+0x11e>
        break;
      if(r != n1)
80101577:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010157a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010157d:	74 0c                	je     8010158b <filewrite+0x10a>
        panic("short filewrite");
8010157f:	c7 04 24 c7 88 10 80 	movl   $0x801088c7,(%esp)
80101586:	e8 b2 ef ff ff       	call   8010053d <panic>
      i += r;
8010158b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010158e:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101594:	3b 45 10             	cmp    0x10(%ebp),%eax
80101597:	0f 8c 4c ff ff ff    	jl     801014e9 <filewrite+0x68>
8010159d:	eb 01                	jmp    801015a0 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
8010159f:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801015a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a3:	3b 45 10             	cmp    0x10(%ebp),%eax
801015a6:	75 05                	jne    801015ad <filewrite+0x12c>
801015a8:	8b 45 10             	mov    0x10(%ebp),%eax
801015ab:	eb 05                	jmp    801015b2 <filewrite+0x131>
801015ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801015b2:	eb 0c                	jmp    801015c0 <filewrite+0x13f>
  }
  panic("filewrite");
801015b4:	c7 04 24 d7 88 10 80 	movl   $0x801088d7,(%esp)
801015bb:	e8 7d ef ff ff       	call   8010053d <panic>
}
801015c0:	83 c4 24             	add    $0x24,%esp
801015c3:	5b                   	pop    %ebx
801015c4:	5d                   	pop    %ebp
801015c5:	c3                   	ret    
	...

801015c8 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801015c8:	55                   	push   %ebp
801015c9:	89 e5                	mov    %esp,%ebp
801015cb:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801015ce:	8b 45 08             	mov    0x8(%ebp),%eax
801015d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801015d8:	00 
801015d9:	89 04 24             	mov    %eax,(%esp)
801015dc:	e8 c5 eb ff ff       	call   801001a6 <bread>
801015e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801015e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015e7:	83 c0 18             	add    $0x18,%eax
801015ea:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801015f1:	00 
801015f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801015f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801015f9:	89 04 24             	mov    %eax,(%esp)
801015fc:	e8 c0 3e 00 00       	call   801054c1 <memmove>
  brelse(bp);
80101601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101604:	89 04 24             	mov    %eax,(%esp)
80101607:	e8 0b ec ff ff       	call   80100217 <brelse>
}
8010160c:	c9                   	leave  
8010160d:	c3                   	ret    

8010160e <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010160e:	55                   	push   %ebp
8010160f:	89 e5                	mov    %esp,%ebp
80101611:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101614:	8b 55 0c             	mov    0xc(%ebp),%edx
80101617:	8b 45 08             	mov    0x8(%ebp),%eax
8010161a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010161e:	89 04 24             	mov    %eax,(%esp)
80101621:	e8 80 eb ff ff       	call   801001a6 <bread>
80101626:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101629:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010162c:	83 c0 18             	add    $0x18,%eax
8010162f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101636:	00 
80101637:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010163e:	00 
8010163f:	89 04 24             	mov    %eax,(%esp)
80101642:	e8 a7 3d 00 00       	call   801053ee <memset>
  log_write(bp);
80101647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010164a:	89 04 24             	mov    %eax,(%esp)
8010164d:	e8 48 1f 00 00       	call   8010359a <log_write>
  brelse(bp);
80101652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101655:	89 04 24             	mov    %eax,(%esp)
80101658:	e8 ba eb ff ff       	call   80100217 <brelse>
}
8010165d:	c9                   	leave  
8010165e:	c3                   	ret    

8010165f <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010165f:	55                   	push   %ebp
80101660:	89 e5                	mov    %esp,%ebp
80101662:	53                   	push   %ebx
80101663:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101666:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
8010166d:	8b 45 08             	mov    0x8(%ebp),%eax
80101670:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101673:	89 54 24 04          	mov    %edx,0x4(%esp)
80101677:	89 04 24             	mov    %eax,(%esp)
8010167a:	e8 49 ff ff ff       	call   801015c8 <readsb>
  for(b = 0; b < sb.size; b += BPB){
8010167f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101686:	e9 11 01 00 00       	jmp    8010179c <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
8010168b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010168e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101694:	85 c0                	test   %eax,%eax
80101696:	0f 48 c2             	cmovs  %edx,%eax
80101699:	c1 f8 0c             	sar    $0xc,%eax
8010169c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010169f:	c1 ea 03             	shr    $0x3,%edx
801016a2:	01 d0                	add    %edx,%eax
801016a4:	83 c0 03             	add    $0x3,%eax
801016a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801016ab:	8b 45 08             	mov    0x8(%ebp),%eax
801016ae:	89 04 24             	mov    %eax,(%esp)
801016b1:	e8 f0 ea ff ff       	call   801001a6 <bread>
801016b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801016b9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801016c0:	e9 a7 00 00 00       	jmp    8010176c <balloc+0x10d>
      m = 1 << (bi % 8);
801016c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c8:	89 c2                	mov    %eax,%edx
801016ca:	c1 fa 1f             	sar    $0x1f,%edx
801016cd:	c1 ea 1d             	shr    $0x1d,%edx
801016d0:	01 d0                	add    %edx,%eax
801016d2:	83 e0 07             	and    $0x7,%eax
801016d5:	29 d0                	sub    %edx,%eax
801016d7:	ba 01 00 00 00       	mov    $0x1,%edx
801016dc:	89 d3                	mov    %edx,%ebx
801016de:	89 c1                	mov    %eax,%ecx
801016e0:	d3 e3                	shl    %cl,%ebx
801016e2:	89 d8                	mov    %ebx,%eax
801016e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801016e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ea:	8d 50 07             	lea    0x7(%eax),%edx
801016ed:	85 c0                	test   %eax,%eax
801016ef:	0f 48 c2             	cmovs  %edx,%eax
801016f2:	c1 f8 03             	sar    $0x3,%eax
801016f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016f8:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801016fd:	0f b6 c0             	movzbl %al,%eax
80101700:	23 45 e8             	and    -0x18(%ebp),%eax
80101703:	85 c0                	test   %eax,%eax
80101705:	75 61                	jne    80101768 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
80101707:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170a:	8d 50 07             	lea    0x7(%eax),%edx
8010170d:	85 c0                	test   %eax,%eax
8010170f:	0f 48 c2             	cmovs  %edx,%eax
80101712:	c1 f8 03             	sar    $0x3,%eax
80101715:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101718:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010171d:	89 d1                	mov    %edx,%ecx
8010171f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101722:	09 ca                	or     %ecx,%edx
80101724:	89 d1                	mov    %edx,%ecx
80101726:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101729:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010172d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101730:	89 04 24             	mov    %eax,(%esp)
80101733:	e8 62 1e 00 00       	call   8010359a <log_write>
        brelse(bp);
80101738:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010173b:	89 04 24             	mov    %eax,(%esp)
8010173e:	e8 d4 ea ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101743:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101746:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101749:	01 c2                	add    %eax,%edx
8010174b:	8b 45 08             	mov    0x8(%ebp),%eax
8010174e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101752:	89 04 24             	mov    %eax,(%esp)
80101755:	e8 b4 fe ff ff       	call   8010160e <bzero>
        return b + bi;
8010175a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101760:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
80101762:	83 c4 34             	add    $0x34,%esp
80101765:	5b                   	pop    %ebx
80101766:	5d                   	pop    %ebp
80101767:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101768:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010176c:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101773:	7f 15                	jg     8010178a <balloc+0x12b>
80101775:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101778:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010177b:	01 d0                	add    %edx,%eax
8010177d:	89 c2                	mov    %eax,%edx
8010177f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101782:	39 c2                	cmp    %eax,%edx
80101784:	0f 82 3b ff ff ff    	jb     801016c5 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010178a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010178d:	89 04 24             	mov    %eax,(%esp)
80101790:	e8 82 ea ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101795:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010179c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010179f:	8b 45 d8             	mov    -0x28(%ebp),%eax
801017a2:	39 c2                	cmp    %eax,%edx
801017a4:	0f 82 e1 fe ff ff    	jb     8010168b <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801017aa:	c7 04 24 e1 88 10 80 	movl   $0x801088e1,(%esp)
801017b1:	e8 87 ed ff ff       	call   8010053d <panic>

801017b6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801017b6:	55                   	push   %ebp
801017b7:	89 e5                	mov    %esp,%ebp
801017b9:	53                   	push   %ebx
801017ba:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801017bd:	8d 45 dc             	lea    -0x24(%ebp),%eax
801017c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801017c4:	8b 45 08             	mov    0x8(%ebp),%eax
801017c7:	89 04 24             	mov    %eax,(%esp)
801017ca:	e8 f9 fd ff ff       	call   801015c8 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801017cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801017d2:	89 c2                	mov    %eax,%edx
801017d4:	c1 ea 0c             	shr    $0xc,%edx
801017d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801017da:	c1 e8 03             	shr    $0x3,%eax
801017dd:	01 d0                	add    %edx,%eax
801017df:	8d 50 03             	lea    0x3(%eax),%edx
801017e2:	8b 45 08             	mov    0x8(%ebp),%eax
801017e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801017e9:	89 04 24             	mov    %eax,(%esp)
801017ec:	e8 b5 e9 ff ff       	call   801001a6 <bread>
801017f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801017f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801017f7:	25 ff 0f 00 00       	and    $0xfff,%eax
801017fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801017ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101802:	89 c2                	mov    %eax,%edx
80101804:	c1 fa 1f             	sar    $0x1f,%edx
80101807:	c1 ea 1d             	shr    $0x1d,%edx
8010180a:	01 d0                	add    %edx,%eax
8010180c:	83 e0 07             	and    $0x7,%eax
8010180f:	29 d0                	sub    %edx,%eax
80101811:	ba 01 00 00 00       	mov    $0x1,%edx
80101816:	89 d3                	mov    %edx,%ebx
80101818:	89 c1                	mov    %eax,%ecx
8010181a:	d3 e3                	shl    %cl,%ebx
8010181c:	89 d8                	mov    %ebx,%eax
8010181e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101821:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101824:	8d 50 07             	lea    0x7(%eax),%edx
80101827:	85 c0                	test   %eax,%eax
80101829:	0f 48 c2             	cmovs  %edx,%eax
8010182c:	c1 f8 03             	sar    $0x3,%eax
8010182f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101832:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101837:	0f b6 c0             	movzbl %al,%eax
8010183a:	23 45 ec             	and    -0x14(%ebp),%eax
8010183d:	85 c0                	test   %eax,%eax
8010183f:	75 0c                	jne    8010184d <bfree+0x97>
    panic("freeing free block");
80101841:	c7 04 24 f7 88 10 80 	movl   $0x801088f7,(%esp)
80101848:	e8 f0 ec ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
8010184d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101850:	8d 50 07             	lea    0x7(%eax),%edx
80101853:	85 c0                	test   %eax,%eax
80101855:	0f 48 c2             	cmovs  %edx,%eax
80101858:	c1 f8 03             	sar    $0x3,%eax
8010185b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010185e:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101863:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101866:	f7 d1                	not    %ecx
80101868:	21 ca                	and    %ecx,%edx
8010186a:	89 d1                	mov    %edx,%ecx
8010186c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010186f:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101876:	89 04 24             	mov    %eax,(%esp)
80101879:	e8 1c 1d 00 00       	call   8010359a <log_write>
  brelse(bp);
8010187e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101881:	89 04 24             	mov    %eax,(%esp)
80101884:	e8 8e e9 ff ff       	call   80100217 <brelse>
}
80101889:	83 c4 34             	add    $0x34,%esp
8010188c:	5b                   	pop    %ebx
8010188d:	5d                   	pop    %ebp
8010188e:	c3                   	ret    

8010188f <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
8010188f:	55                   	push   %ebp
80101890:	89 e5                	mov    %esp,%ebp
80101892:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101895:	c7 44 24 04 0a 89 10 	movl   $0x8010890a,0x4(%esp)
8010189c:	80 
8010189d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801018a4:	e8 d5 38 00 00       	call   8010517e <initlock>
}
801018a9:	c9                   	leave  
801018aa:	c3                   	ret    

801018ab <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801018ab:	55                   	push   %ebp
801018ac:	89 e5                	mov    %esp,%ebp
801018ae:	83 ec 48             	sub    $0x48,%esp
801018b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801018b4:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801018b8:	8b 45 08             	mov    0x8(%ebp),%eax
801018bb:	8d 55 dc             	lea    -0x24(%ebp),%edx
801018be:	89 54 24 04          	mov    %edx,0x4(%esp)
801018c2:	89 04 24             	mov    %eax,(%esp)
801018c5:	e8 fe fc ff ff       	call   801015c8 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801018ca:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801018d1:	e9 98 00 00 00       	jmp    8010196e <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801018d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d9:	c1 e8 03             	shr    $0x3,%eax
801018dc:	83 c0 02             	add    $0x2,%eax
801018df:	89 44 24 04          	mov    %eax,0x4(%esp)
801018e3:	8b 45 08             	mov    0x8(%ebp),%eax
801018e6:	89 04 24             	mov    %eax,(%esp)
801018e9:	e8 b8 e8 ff ff       	call   801001a6 <bread>
801018ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f4:	8d 50 18             	lea    0x18(%eax),%edx
801018f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018fa:	83 e0 07             	and    $0x7,%eax
801018fd:	c1 e0 06             	shl    $0x6,%eax
80101900:	01 d0                	add    %edx,%eax
80101902:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101905:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101908:	0f b7 00             	movzwl (%eax),%eax
8010190b:	66 85 c0             	test   %ax,%ax
8010190e:	75 4f                	jne    8010195f <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101910:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101917:	00 
80101918:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010191f:	00 
80101920:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101923:	89 04 24             	mov    %eax,(%esp)
80101926:	e8 c3 3a 00 00       	call   801053ee <memset>
      dip->type = type;
8010192b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010192e:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101932:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101935:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101938:	89 04 24             	mov    %eax,(%esp)
8010193b:	e8 5a 1c 00 00       	call   8010359a <log_write>
      brelse(bp);
80101940:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101943:	89 04 24             	mov    %eax,(%esp)
80101946:	e8 cc e8 ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010194b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101952:	8b 45 08             	mov    0x8(%ebp),%eax
80101955:	89 04 24             	mov    %eax,(%esp)
80101958:	e8 e3 00 00 00       	call   80101a40 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
8010195d:	c9                   	leave  
8010195e:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
8010195f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101962:	89 04 24             	mov    %eax,(%esp)
80101965:	e8 ad e8 ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010196a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010196e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101971:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101974:	39 c2                	cmp    %eax,%edx
80101976:	0f 82 5a ff ff ff    	jb     801018d6 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010197c:	c7 04 24 11 89 10 80 	movl   $0x80108911,(%esp)
80101983:	e8 b5 eb ff ff       	call   8010053d <panic>

80101988 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101988:	55                   	push   %ebp
80101989:	89 e5                	mov    %esp,%ebp
8010198b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
8010198e:	8b 45 08             	mov    0x8(%ebp),%eax
80101991:	8b 40 04             	mov    0x4(%eax),%eax
80101994:	c1 e8 03             	shr    $0x3,%eax
80101997:	8d 50 02             	lea    0x2(%eax),%edx
8010199a:	8b 45 08             	mov    0x8(%ebp),%eax
8010199d:	8b 00                	mov    (%eax),%eax
8010199f:	89 54 24 04          	mov    %edx,0x4(%esp)
801019a3:	89 04 24             	mov    %eax,(%esp)
801019a6:	e8 fb e7 ff ff       	call   801001a6 <bread>
801019ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b1:	8d 50 18             	lea    0x18(%eax),%edx
801019b4:	8b 45 08             	mov    0x8(%ebp),%eax
801019b7:	8b 40 04             	mov    0x4(%eax),%eax
801019ba:	83 e0 07             	and    $0x7,%eax
801019bd:	c1 e0 06             	shl    $0x6,%eax
801019c0:	01 d0                	add    %edx,%eax
801019c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801019c5:	8b 45 08             	mov    0x8(%ebp),%eax
801019c8:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801019cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cf:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801019d2:	8b 45 08             	mov    0x8(%ebp),%eax
801019d5:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801019d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019dc:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801019e0:	8b 45 08             	mov    0x8(%ebp),%eax
801019e3:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801019e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019ea:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801019ee:	8b 45 08             	mov    0x8(%ebp),%eax
801019f1:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801019f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f8:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801019fc:	8b 45 08             	mov    0x8(%ebp),%eax
801019ff:	8b 50 18             	mov    0x18(%eax),%edx
80101a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a05:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a08:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0b:	8d 50 1c             	lea    0x1c(%eax),%edx
80101a0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a11:	83 c0 0c             	add    $0xc,%eax
80101a14:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101a1b:	00 
80101a1c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a20:	89 04 24             	mov    %eax,(%esp)
80101a23:	e8 99 3a 00 00       	call   801054c1 <memmove>
  log_write(bp);
80101a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2b:	89 04 24             	mov    %eax,(%esp)
80101a2e:	e8 67 1b 00 00       	call   8010359a <log_write>
  brelse(bp);
80101a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a36:	89 04 24             	mov    %eax,(%esp)
80101a39:	e8 d9 e7 ff ff       	call   80100217 <brelse>
}
80101a3e:	c9                   	leave  
80101a3f:	c3                   	ret    

80101a40 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a40:	55                   	push   %ebp
80101a41:	89 e5                	mov    %esp,%ebp
80101a43:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a46:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a4d:	e8 4d 37 00 00       	call   8010519f <acquire>

  // Is the inode already cached?
  empty = 0;
80101a52:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a59:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
80101a60:	eb 59                	jmp    80101abb <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a65:	8b 40 08             	mov    0x8(%eax),%eax
80101a68:	85 c0                	test   %eax,%eax
80101a6a:	7e 35                	jle    80101aa1 <iget+0x61>
80101a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6f:	8b 00                	mov    (%eax),%eax
80101a71:	3b 45 08             	cmp    0x8(%ebp),%eax
80101a74:	75 2b                	jne    80101aa1 <iget+0x61>
80101a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a79:	8b 40 04             	mov    0x4(%eax),%eax
80101a7c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101a7f:	75 20                	jne    80101aa1 <iget+0x61>
      ip->ref++;
80101a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a84:	8b 40 08             	mov    0x8(%eax),%eax
80101a87:	8d 50 01             	lea    0x1(%eax),%edx
80101a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8d:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a90:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a97:	e8 65 37 00 00       	call   80105201 <release>
      return ip;
80101a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a9f:	eb 6f                	jmp    80101b10 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101aa1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101aa5:	75 10                	jne    80101ab7 <iget+0x77>
80101aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aaa:	8b 40 08             	mov    0x8(%eax),%eax
80101aad:	85 c0                	test   %eax,%eax
80101aaf:	75 06                	jne    80101ab7 <iget+0x77>
      empty = ip;
80101ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ab4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101ab7:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101abb:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
80101ac2:	72 9e                	jb     80101a62 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101ac4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101ac8:	75 0c                	jne    80101ad6 <iget+0x96>
    panic("iget: no inodes");
80101aca:	c7 04 24 23 89 10 80 	movl   $0x80108923,(%esp)
80101ad1:	e8 67 ea ff ff       	call   8010053d <panic>

  ip = empty;
80101ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101adf:	8b 55 08             	mov    0x8(%ebp),%edx
80101ae2:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ae7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101aea:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101af0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101afa:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101b01:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b08:	e8 f4 36 00 00       	call   80105201 <release>

  return ip;
80101b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b10:	c9                   	leave  
80101b11:	c3                   	ret    

80101b12 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b12:	55                   	push   %ebp
80101b13:	89 e5                	mov    %esp,%ebp
80101b15:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101b18:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b1f:	e8 7b 36 00 00       	call   8010519f <acquire>
  ip->ref++;
80101b24:	8b 45 08             	mov    0x8(%ebp),%eax
80101b27:	8b 40 08             	mov    0x8(%eax),%eax
80101b2a:	8d 50 01             	lea    0x1(%eax),%edx
80101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b30:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b33:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b3a:	e8 c2 36 00 00       	call   80105201 <release>
  return ip;
80101b3f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b42:	c9                   	leave  
80101b43:	c3                   	ret    

80101b44 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b44:	55                   	push   %ebp
80101b45:	89 e5                	mov    %esp,%ebp
80101b47:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b4a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b4e:	74 0a                	je     80101b5a <ilock+0x16>
80101b50:	8b 45 08             	mov    0x8(%ebp),%eax
80101b53:	8b 40 08             	mov    0x8(%eax),%eax
80101b56:	85 c0                	test   %eax,%eax
80101b58:	7f 0c                	jg     80101b66 <ilock+0x22>
    panic("ilock");
80101b5a:	c7 04 24 33 89 10 80 	movl   $0x80108933,(%esp)
80101b61:	e8 d7 e9 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101b66:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101b6d:	e8 2d 36 00 00       	call   8010519f <acquire>
  while(ip->flags & I_BUSY)
80101b72:	eb 13                	jmp    80101b87 <ilock+0x43>
    sleep(ip, &icache.lock);
80101b74:	c7 44 24 04 80 e8 10 	movl   $0x8010e880,0x4(%esp)
80101b7b:	80 
80101b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7f:	89 04 24             	mov    %eax,(%esp)
80101b82:	e8 83 32 00 00       	call   80104e0a <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101b87:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8a:	8b 40 0c             	mov    0xc(%eax),%eax
80101b8d:	83 e0 01             	and    $0x1,%eax
80101b90:	84 c0                	test   %al,%al
80101b92:	75 e0                	jne    80101b74 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101b94:	8b 45 08             	mov    0x8(%ebp),%eax
80101b97:	8b 40 0c             	mov    0xc(%eax),%eax
80101b9a:	89 c2                	mov    %eax,%edx
80101b9c:	83 ca 01             	or     $0x1,%edx
80101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba2:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101ba5:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101bac:	e8 50 36 00 00       	call   80105201 <release>

  if(!(ip->flags & I_VALID)){
80101bb1:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb4:	8b 40 0c             	mov    0xc(%eax),%eax
80101bb7:	83 e0 02             	and    $0x2,%eax
80101bba:	85 c0                	test   %eax,%eax
80101bbc:	0f 85 ce 00 00 00    	jne    80101c90 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc5:	8b 40 04             	mov    0x4(%eax),%eax
80101bc8:	c1 e8 03             	shr    $0x3,%eax
80101bcb:	8d 50 02             	lea    0x2(%eax),%edx
80101bce:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd1:	8b 00                	mov    (%eax),%eax
80101bd3:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bd7:	89 04 24             	mov    %eax,(%esp)
80101bda:	e8 c7 e5 ff ff       	call   801001a6 <bread>
80101bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101be5:	8d 50 18             	lea    0x18(%eax),%edx
80101be8:	8b 45 08             	mov    0x8(%ebp),%eax
80101beb:	8b 40 04             	mov    0x4(%eax),%eax
80101bee:	83 e0 07             	and    $0x7,%eax
80101bf1:	c1 e0 06             	shl    $0x6,%eax
80101bf4:	01 d0                	add    %edx,%eax
80101bf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bfc:	0f b7 10             	movzwl (%eax),%edx
80101bff:	8b 45 08             	mov    0x8(%ebp),%eax
80101c02:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c09:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c10:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c17:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1e:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c25:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101c29:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2c:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c33:	8b 50 08             	mov    0x8(%eax),%edx
80101c36:	8b 45 08             	mov    0x8(%ebp),%eax
80101c39:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c3f:	8d 50 0c             	lea    0xc(%eax),%edx
80101c42:	8b 45 08             	mov    0x8(%ebp),%eax
80101c45:	83 c0 1c             	add    $0x1c,%eax
80101c48:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101c4f:	00 
80101c50:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c54:	89 04 24             	mov    %eax,(%esp)
80101c57:	e8 65 38 00 00       	call   801054c1 <memmove>
    brelse(bp);
80101c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c5f:	89 04 24             	mov    %eax,(%esp)
80101c62:	e8 b0 e5 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	8b 40 0c             	mov    0xc(%eax),%eax
80101c6d:	89 c2                	mov    %eax,%edx
80101c6f:	83 ca 02             	or     $0x2,%edx
80101c72:	8b 45 08             	mov    0x8(%ebp),%eax
80101c75:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101c78:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101c7f:	66 85 c0             	test   %ax,%ax
80101c82:	75 0c                	jne    80101c90 <ilock+0x14c>
      panic("ilock: no type");
80101c84:	c7 04 24 39 89 10 80 	movl   $0x80108939,(%esp)
80101c8b:	e8 ad e8 ff ff       	call   8010053d <panic>
  }
}
80101c90:	c9                   	leave  
80101c91:	c3                   	ret    

80101c92 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c92:	55                   	push   %ebp
80101c93:	89 e5                	mov    %esp,%ebp
80101c95:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101c98:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c9c:	74 17                	je     80101cb5 <iunlock+0x23>
80101c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca1:	8b 40 0c             	mov    0xc(%eax),%eax
80101ca4:	83 e0 01             	and    $0x1,%eax
80101ca7:	85 c0                	test   %eax,%eax
80101ca9:	74 0a                	je     80101cb5 <iunlock+0x23>
80101cab:	8b 45 08             	mov    0x8(%ebp),%eax
80101cae:	8b 40 08             	mov    0x8(%eax),%eax
80101cb1:	85 c0                	test   %eax,%eax
80101cb3:	7f 0c                	jg     80101cc1 <iunlock+0x2f>
    panic("iunlock");
80101cb5:	c7 04 24 48 89 10 80 	movl   $0x80108948,(%esp)
80101cbc:	e8 7c e8 ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101cc1:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101cc8:	e8 d2 34 00 00       	call   8010519f <acquire>
  ip->flags &= ~I_BUSY;
80101ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd0:	8b 40 0c             	mov    0xc(%eax),%eax
80101cd3:	89 c2                	mov    %eax,%edx
80101cd5:	83 e2 fe             	and    $0xfffffffe,%edx
80101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdb:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101cde:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce1:	89 04 24             	mov    %eax,(%esp)
80101ce4:	e8 fd 31 00 00       	call   80104ee6 <wakeup>
  release(&icache.lock);
80101ce9:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101cf0:	e8 0c 35 00 00       	call   80105201 <release>
}
80101cf5:	c9                   	leave  
80101cf6:	c3                   	ret    

80101cf7 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101cf7:	55                   	push   %ebp
80101cf8:	89 e5                	mov    %esp,%ebp
80101cfa:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101cfd:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d04:	e8 96 34 00 00       	call   8010519f <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101d09:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0c:	8b 40 08             	mov    0x8(%eax),%eax
80101d0f:	83 f8 01             	cmp    $0x1,%eax
80101d12:	0f 85 93 00 00 00    	jne    80101dab <iput+0xb4>
80101d18:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1b:	8b 40 0c             	mov    0xc(%eax),%eax
80101d1e:	83 e0 02             	and    $0x2,%eax
80101d21:	85 c0                	test   %eax,%eax
80101d23:	0f 84 82 00 00 00    	je     80101dab <iput+0xb4>
80101d29:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101d30:	66 85 c0             	test   %ax,%ax
80101d33:	75 76                	jne    80101dab <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101d35:	8b 45 08             	mov    0x8(%ebp),%eax
80101d38:	8b 40 0c             	mov    0xc(%eax),%eax
80101d3b:	83 e0 01             	and    $0x1,%eax
80101d3e:	84 c0                	test   %al,%al
80101d40:	74 0c                	je     80101d4e <iput+0x57>
      panic("iput busy");
80101d42:	c7 04 24 50 89 10 80 	movl   $0x80108950,(%esp)
80101d49:	e8 ef e7 ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d51:	8b 40 0c             	mov    0xc(%eax),%eax
80101d54:	89 c2                	mov    %eax,%edx
80101d56:	83 ca 01             	or     $0x1,%edx
80101d59:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5c:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101d5f:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d66:	e8 96 34 00 00       	call   80105201 <release>
    itrunc(ip);
80101d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6e:	89 04 24             	mov    %eax,(%esp)
80101d71:	e8 72 01 00 00       	call   80101ee8 <itrunc>
    ip->type = 0;
80101d76:	8b 45 08             	mov    0x8(%ebp),%eax
80101d79:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101d7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d82:	89 04 24             	mov    %eax,(%esp)
80101d85:	e8 fe fb ff ff       	call   80101988 <iupdate>
    acquire(&icache.lock);
80101d8a:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101d91:	e8 09 34 00 00       	call   8010519f <acquire>
    ip->flags = 0;
80101d96:	8b 45 08             	mov    0x8(%ebp),%eax
80101d99:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101da0:	8b 45 08             	mov    0x8(%ebp),%eax
80101da3:	89 04 24             	mov    %eax,(%esp)
80101da6:	e8 3b 31 00 00       	call   80104ee6 <wakeup>
  }
  ip->ref--;
80101dab:	8b 45 08             	mov    0x8(%ebp),%eax
80101dae:	8b 40 08             	mov    0x8(%eax),%eax
80101db1:	8d 50 ff             	lea    -0x1(%eax),%edx
80101db4:	8b 45 08             	mov    0x8(%ebp),%eax
80101db7:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101dba:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101dc1:	e8 3b 34 00 00       	call   80105201 <release>
}
80101dc6:	c9                   	leave  
80101dc7:	c3                   	ret    

80101dc8 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101dc8:	55                   	push   %ebp
80101dc9:	89 e5                	mov    %esp,%ebp
80101dcb:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101dce:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd1:	89 04 24             	mov    %eax,(%esp)
80101dd4:	e8 b9 fe ff ff       	call   80101c92 <iunlock>
  iput(ip);
80101dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddc:	89 04 24             	mov    %eax,(%esp)
80101ddf:	e8 13 ff ff ff       	call   80101cf7 <iput>
}
80101de4:	c9                   	leave  
80101de5:	c3                   	ret    

80101de6 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101de6:	55                   	push   %ebp
80101de7:	89 e5                	mov    %esp,%ebp
80101de9:	53                   	push   %ebx
80101dea:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101ded:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101df1:	77 3e                	ja     80101e31 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101df3:	8b 45 08             	mov    0x8(%ebp),%eax
80101df6:	8b 55 0c             	mov    0xc(%ebp),%edx
80101df9:	83 c2 04             	add    $0x4,%edx
80101dfc:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e07:	75 20                	jne    80101e29 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e09:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0c:	8b 00                	mov    (%eax),%eax
80101e0e:	89 04 24             	mov    %eax,(%esp)
80101e11:	e8 49 f8 ff ff       	call   8010165f <balloc>
80101e16:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e19:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e1f:	8d 4a 04             	lea    0x4(%edx),%ecx
80101e22:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e25:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e2c:	e9 b1 00 00 00       	jmp    80101ee2 <bmap+0xfc>
  }
  bn -= NDIRECT;
80101e31:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101e35:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e39:	0f 87 97 00 00 00    	ja     80101ed6 <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e42:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e45:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e4c:	75 19                	jne    80101e67 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e51:	8b 00                	mov    (%eax),%eax
80101e53:	89 04 24             	mov    %eax,(%esp)
80101e56:	e8 04 f8 ff ff       	call   8010165f <balloc>
80101e5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e64:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101e67:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6a:	8b 00                	mov    (%eax),%eax
80101e6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e6f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e73:	89 04 24             	mov    %eax,(%esp)
80101e76:	e8 2b e3 ff ff       	call   801001a6 <bread>
80101e7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e81:	83 c0 18             	add    $0x18,%eax
80101e84:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e87:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e8a:	c1 e0 02             	shl    $0x2,%eax
80101e8d:	03 45 ec             	add    -0x14(%ebp),%eax
80101e90:	8b 00                	mov    (%eax),%eax
80101e92:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e95:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e99:	75 2b                	jne    80101ec6 <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9e:	c1 e0 02             	shl    $0x2,%eax
80101ea1:	89 c3                	mov    %eax,%ebx
80101ea3:	03 5d ec             	add    -0x14(%ebp),%ebx
80101ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea9:	8b 00                	mov    (%eax),%eax
80101eab:	89 04 24             	mov    %eax,(%esp)
80101eae:	e8 ac f7 ff ff       	call   8010165f <balloc>
80101eb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eb9:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ebe:	89 04 24             	mov    %eax,(%esp)
80101ec1:	e8 d4 16 00 00       	call   8010359a <log_write>
    }
    brelse(bp);
80101ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ec9:	89 04 24             	mov    %eax,(%esp)
80101ecc:	e8 46 e3 ff ff       	call   80100217 <brelse>
    return addr;
80101ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ed4:	eb 0c                	jmp    80101ee2 <bmap+0xfc>
  }

  panic("bmap: out of range");
80101ed6:	c7 04 24 5a 89 10 80 	movl   $0x8010895a,(%esp)
80101edd:	e8 5b e6 ff ff       	call   8010053d <panic>
}
80101ee2:	83 c4 24             	add    $0x24,%esp
80101ee5:	5b                   	pop    %ebx
80101ee6:	5d                   	pop    %ebp
80101ee7:	c3                   	ret    

80101ee8 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101ee8:	55                   	push   %ebp
80101ee9:	89 e5                	mov    %esp,%ebp
80101eeb:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101eee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ef5:	eb 44                	jmp    80101f3b <itrunc+0x53>
    if(ip->addrs[i]){
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101efd:	83 c2 04             	add    $0x4,%edx
80101f00:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f04:	85 c0                	test   %eax,%eax
80101f06:	74 2f                	je     80101f37 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101f08:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f0e:	83 c2 04             	add    $0x4,%edx
80101f11:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	8b 00                	mov    (%eax),%eax
80101f1a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f1e:	89 04 24             	mov    %eax,(%esp)
80101f21:	e8 90 f8 ff ff       	call   801017b6 <bfree>
      ip->addrs[i] = 0;
80101f26:	8b 45 08             	mov    0x8(%ebp),%eax
80101f29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f2c:	83 c2 04             	add    $0x4,%edx
80101f2f:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101f36:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f37:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f3b:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f3f:	7e b6                	jle    80101ef7 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101f41:	8b 45 08             	mov    0x8(%ebp),%eax
80101f44:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f47:	85 c0                	test   %eax,%eax
80101f49:	0f 84 8f 00 00 00    	je     80101fde <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f52:	8b 50 4c             	mov    0x4c(%eax),%edx
80101f55:	8b 45 08             	mov    0x8(%ebp),%eax
80101f58:	8b 00                	mov    (%eax),%eax
80101f5a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f5e:	89 04 24             	mov    %eax,(%esp)
80101f61:	e8 40 e2 ff ff       	call   801001a6 <bread>
80101f66:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f6c:	83 c0 18             	add    $0x18,%eax
80101f6f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f72:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101f79:	eb 2f                	jmp    80101faa <itrunc+0xc2>
      if(a[j])
80101f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f7e:	c1 e0 02             	shl    $0x2,%eax
80101f81:	03 45 e8             	add    -0x18(%ebp),%eax
80101f84:	8b 00                	mov    (%eax),%eax
80101f86:	85 c0                	test   %eax,%eax
80101f88:	74 1c                	je     80101fa6 <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80101f8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f8d:	c1 e0 02             	shl    $0x2,%eax
80101f90:	03 45 e8             	add    -0x18(%ebp),%eax
80101f93:	8b 10                	mov    (%eax),%edx
80101f95:	8b 45 08             	mov    0x8(%ebp),%eax
80101f98:	8b 00                	mov    (%eax),%eax
80101f9a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f9e:	89 04 24             	mov    %eax,(%esp)
80101fa1:	e8 10 f8 ff ff       	call   801017b6 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101fa6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fad:	83 f8 7f             	cmp    $0x7f,%eax
80101fb0:	76 c9                	jbe    80101f7b <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101fb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fb5:	89 04 24             	mov    %eax,(%esp)
80101fb8:	e8 5a e2 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc0:	8b 50 4c             	mov    0x4c(%eax),%edx
80101fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc6:	8b 00                	mov    (%eax),%eax
80101fc8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fcc:	89 04 24             	mov    %eax,(%esp)
80101fcf:	e8 e2 f7 ff ff       	call   801017b6 <bfree>
    ip->addrs[NDIRECT] = 0;
80101fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd7:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101fde:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe1:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101fe8:	8b 45 08             	mov    0x8(%ebp),%eax
80101feb:	89 04 24             	mov    %eax,(%esp)
80101fee:	e8 95 f9 ff ff       	call   80101988 <iupdate>
}
80101ff3:	c9                   	leave  
80101ff4:	c3                   	ret    

80101ff5 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101ff5:	55                   	push   %ebp
80101ff6:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffb:	8b 00                	mov    (%eax),%eax
80101ffd:	89 c2                	mov    %eax,%edx
80101fff:	8b 45 0c             	mov    0xc(%ebp),%eax
80102002:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80102005:	8b 45 08             	mov    0x8(%ebp),%eax
80102008:	8b 50 04             	mov    0x4(%eax),%edx
8010200b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010200e:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80102011:	8b 45 08             	mov    0x8(%ebp),%eax
80102014:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80102018:	8b 45 0c             	mov    0xc(%ebp),%eax
8010201b:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
8010201e:	8b 45 08             	mov    0x8(%ebp),%eax
80102021:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80102025:	8b 45 0c             	mov    0xc(%ebp),%eax
80102028:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
8010202c:	8b 45 08             	mov    0x8(%ebp),%eax
8010202f:	8b 50 18             	mov    0x18(%eax),%edx
80102032:	8b 45 0c             	mov    0xc(%ebp),%eax
80102035:	89 50 10             	mov    %edx,0x10(%eax)
}
80102038:	5d                   	pop    %ebp
80102039:	c3                   	ret    

8010203a <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
8010203a:	55                   	push   %ebp
8010203b:	89 e5                	mov    %esp,%ebp
8010203d:	53                   	push   %ebx
8010203e:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102041:	8b 45 08             	mov    0x8(%ebp),%eax
80102044:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102048:	66 83 f8 03          	cmp    $0x3,%ax
8010204c:	75 60                	jne    801020ae <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
8010204e:	8b 45 08             	mov    0x8(%ebp),%eax
80102051:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102055:	66 85 c0             	test   %ax,%ax
80102058:	78 20                	js     8010207a <readi+0x40>
8010205a:	8b 45 08             	mov    0x8(%ebp),%eax
8010205d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102061:	66 83 f8 09          	cmp    $0x9,%ax
80102065:	7f 13                	jg     8010207a <readi+0x40>
80102067:	8b 45 08             	mov    0x8(%ebp),%eax
8010206a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010206e:	98                   	cwtl   
8010206f:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
80102076:	85 c0                	test   %eax,%eax
80102078:	75 0a                	jne    80102084 <readi+0x4a>
      return -1;
8010207a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010207f:	e9 1b 01 00 00       	jmp    8010219f <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80102084:	8b 45 08             	mov    0x8(%ebp),%eax
80102087:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010208b:	98                   	cwtl   
8010208c:	8b 14 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%edx
80102093:	8b 45 14             	mov    0x14(%ebp),%eax
80102096:	89 44 24 08          	mov    %eax,0x8(%esp)
8010209a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010209d:	89 44 24 04          	mov    %eax,0x4(%esp)
801020a1:	8b 45 08             	mov    0x8(%ebp),%eax
801020a4:	89 04 24             	mov    %eax,(%esp)
801020a7:	ff d2                	call   *%edx
801020a9:	e9 f1 00 00 00       	jmp    8010219f <readi+0x165>
  }

  if(off > ip->size || off + n < off)
801020ae:	8b 45 08             	mov    0x8(%ebp),%eax
801020b1:	8b 40 18             	mov    0x18(%eax),%eax
801020b4:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b7:	72 0d                	jb     801020c6 <readi+0x8c>
801020b9:	8b 45 14             	mov    0x14(%ebp),%eax
801020bc:	8b 55 10             	mov    0x10(%ebp),%edx
801020bf:	01 d0                	add    %edx,%eax
801020c1:	3b 45 10             	cmp    0x10(%ebp),%eax
801020c4:	73 0a                	jae    801020d0 <readi+0x96>
    return -1;
801020c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020cb:	e9 cf 00 00 00       	jmp    8010219f <readi+0x165>
  if(off + n > ip->size)
801020d0:	8b 45 14             	mov    0x14(%ebp),%eax
801020d3:	8b 55 10             	mov    0x10(%ebp),%edx
801020d6:	01 c2                	add    %eax,%edx
801020d8:	8b 45 08             	mov    0x8(%ebp),%eax
801020db:	8b 40 18             	mov    0x18(%eax),%eax
801020de:	39 c2                	cmp    %eax,%edx
801020e0:	76 0c                	jbe    801020ee <readi+0xb4>
    n = ip->size - off;
801020e2:	8b 45 08             	mov    0x8(%ebp),%eax
801020e5:	8b 40 18             	mov    0x18(%eax),%eax
801020e8:	2b 45 10             	sub    0x10(%ebp),%eax
801020eb:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020f5:	e9 96 00 00 00       	jmp    80102190 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020fa:	8b 45 10             	mov    0x10(%ebp),%eax
801020fd:	c1 e8 09             	shr    $0x9,%eax
80102100:	89 44 24 04          	mov    %eax,0x4(%esp)
80102104:	8b 45 08             	mov    0x8(%ebp),%eax
80102107:	89 04 24             	mov    %eax,(%esp)
8010210a:	e8 d7 fc ff ff       	call   80101de6 <bmap>
8010210f:	8b 55 08             	mov    0x8(%ebp),%edx
80102112:	8b 12                	mov    (%edx),%edx
80102114:	89 44 24 04          	mov    %eax,0x4(%esp)
80102118:	89 14 24             	mov    %edx,(%esp)
8010211b:	e8 86 e0 ff ff       	call   801001a6 <bread>
80102120:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102123:	8b 45 10             	mov    0x10(%ebp),%eax
80102126:	89 c2                	mov    %eax,%edx
80102128:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010212e:	b8 00 02 00 00       	mov    $0x200,%eax
80102133:	89 c1                	mov    %eax,%ecx
80102135:	29 d1                	sub    %edx,%ecx
80102137:	89 ca                	mov    %ecx,%edx
80102139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010213c:	8b 4d 14             	mov    0x14(%ebp),%ecx
8010213f:	89 cb                	mov    %ecx,%ebx
80102141:	29 c3                	sub    %eax,%ebx
80102143:	89 d8                	mov    %ebx,%eax
80102145:	39 c2                	cmp    %eax,%edx
80102147:	0f 46 c2             	cmovbe %edx,%eax
8010214a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010214d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102150:	8d 50 18             	lea    0x18(%eax),%edx
80102153:	8b 45 10             	mov    0x10(%ebp),%eax
80102156:	25 ff 01 00 00       	and    $0x1ff,%eax
8010215b:	01 c2                	add    %eax,%edx
8010215d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102160:	89 44 24 08          	mov    %eax,0x8(%esp)
80102164:	89 54 24 04          	mov    %edx,0x4(%esp)
80102168:	8b 45 0c             	mov    0xc(%ebp),%eax
8010216b:	89 04 24             	mov    %eax,(%esp)
8010216e:	e8 4e 33 00 00       	call   801054c1 <memmove>
    brelse(bp);
80102173:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102176:	89 04 24             	mov    %eax,(%esp)
80102179:	e8 99 e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010217e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102181:	01 45 f4             	add    %eax,-0xc(%ebp)
80102184:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102187:	01 45 10             	add    %eax,0x10(%ebp)
8010218a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010218d:	01 45 0c             	add    %eax,0xc(%ebp)
80102190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102193:	3b 45 14             	cmp    0x14(%ebp),%eax
80102196:	0f 82 5e ff ff ff    	jb     801020fa <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010219c:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010219f:	83 c4 24             	add    $0x24,%esp
801021a2:	5b                   	pop    %ebx
801021a3:	5d                   	pop    %ebp
801021a4:	c3                   	ret    

801021a5 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021a5:	55                   	push   %ebp
801021a6:	89 e5                	mov    %esp,%ebp
801021a8:	53                   	push   %ebx
801021a9:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021ac:	8b 45 08             	mov    0x8(%ebp),%eax
801021af:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021b3:	66 83 f8 03          	cmp    $0x3,%ax
801021b7:	75 60                	jne    80102219 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801021b9:	8b 45 08             	mov    0x8(%ebp),%eax
801021bc:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021c0:	66 85 c0             	test   %ax,%ax
801021c3:	78 20                	js     801021e5 <writei+0x40>
801021c5:	8b 45 08             	mov    0x8(%ebp),%eax
801021c8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021cc:	66 83 f8 09          	cmp    $0x9,%ax
801021d0:	7f 13                	jg     801021e5 <writei+0x40>
801021d2:	8b 45 08             	mov    0x8(%ebp),%eax
801021d5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021d9:	98                   	cwtl   
801021da:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
801021e1:	85 c0                	test   %eax,%eax
801021e3:	75 0a                	jne    801021ef <writei+0x4a>
      return -1;
801021e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021ea:	e9 46 01 00 00       	jmp    80102335 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
801021ef:	8b 45 08             	mov    0x8(%ebp),%eax
801021f2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801021f6:	98                   	cwtl   
801021f7:	8b 14 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%edx
801021fe:	8b 45 14             	mov    0x14(%ebp),%eax
80102201:	89 44 24 08          	mov    %eax,0x8(%esp)
80102205:	8b 45 0c             	mov    0xc(%ebp),%eax
80102208:	89 44 24 04          	mov    %eax,0x4(%esp)
8010220c:	8b 45 08             	mov    0x8(%ebp),%eax
8010220f:	89 04 24             	mov    %eax,(%esp)
80102212:	ff d2                	call   *%edx
80102214:	e9 1c 01 00 00       	jmp    80102335 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80102219:	8b 45 08             	mov    0x8(%ebp),%eax
8010221c:	8b 40 18             	mov    0x18(%eax),%eax
8010221f:	3b 45 10             	cmp    0x10(%ebp),%eax
80102222:	72 0d                	jb     80102231 <writei+0x8c>
80102224:	8b 45 14             	mov    0x14(%ebp),%eax
80102227:	8b 55 10             	mov    0x10(%ebp),%edx
8010222a:	01 d0                	add    %edx,%eax
8010222c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010222f:	73 0a                	jae    8010223b <writei+0x96>
    return -1;
80102231:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102236:	e9 fa 00 00 00       	jmp    80102335 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
8010223b:	8b 45 14             	mov    0x14(%ebp),%eax
8010223e:	8b 55 10             	mov    0x10(%ebp),%edx
80102241:	01 d0                	add    %edx,%eax
80102243:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102248:	76 0a                	jbe    80102254 <writei+0xaf>
    return -1;
8010224a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010224f:	e9 e1 00 00 00       	jmp    80102335 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102254:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010225b:	e9 a1 00 00 00       	jmp    80102301 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102260:	8b 45 10             	mov    0x10(%ebp),%eax
80102263:	c1 e8 09             	shr    $0x9,%eax
80102266:	89 44 24 04          	mov    %eax,0x4(%esp)
8010226a:	8b 45 08             	mov    0x8(%ebp),%eax
8010226d:	89 04 24             	mov    %eax,(%esp)
80102270:	e8 71 fb ff ff       	call   80101de6 <bmap>
80102275:	8b 55 08             	mov    0x8(%ebp),%edx
80102278:	8b 12                	mov    (%edx),%edx
8010227a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010227e:	89 14 24             	mov    %edx,(%esp)
80102281:	e8 20 df ff ff       	call   801001a6 <bread>
80102286:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102289:	8b 45 10             	mov    0x10(%ebp),%eax
8010228c:	89 c2                	mov    %eax,%edx
8010228e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102294:	b8 00 02 00 00       	mov    $0x200,%eax
80102299:	89 c1                	mov    %eax,%ecx
8010229b:	29 d1                	sub    %edx,%ecx
8010229d:	89 ca                	mov    %ecx,%edx
8010229f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022a2:	8b 4d 14             	mov    0x14(%ebp),%ecx
801022a5:	89 cb                	mov    %ecx,%ebx
801022a7:	29 c3                	sub    %eax,%ebx
801022a9:	89 d8                	mov    %ebx,%eax
801022ab:	39 c2                	cmp    %eax,%edx
801022ad:	0f 46 c2             	cmovbe %edx,%eax
801022b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022b6:	8d 50 18             	lea    0x18(%eax),%edx
801022b9:	8b 45 10             	mov    0x10(%ebp),%eax
801022bc:	25 ff 01 00 00       	and    $0x1ff,%eax
801022c1:	01 c2                	add    %eax,%edx
801022c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022c6:	89 44 24 08          	mov    %eax,0x8(%esp)
801022ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801022cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801022d1:	89 14 24             	mov    %edx,(%esp)
801022d4:	e8 e8 31 00 00       	call   801054c1 <memmove>
    log_write(bp);
801022d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022dc:	89 04 24             	mov    %eax,(%esp)
801022df:	e8 b6 12 00 00       	call   8010359a <log_write>
    brelse(bp);
801022e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022e7:	89 04 24             	mov    %eax,(%esp)
801022ea:	e8 28 df ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801022ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022f2:	01 45 f4             	add    %eax,-0xc(%ebp)
801022f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022f8:	01 45 10             	add    %eax,0x10(%ebp)
801022fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022fe:	01 45 0c             	add    %eax,0xc(%ebp)
80102301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102304:	3b 45 14             	cmp    0x14(%ebp),%eax
80102307:	0f 82 53 ff ff ff    	jb     80102260 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010230d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102311:	74 1f                	je     80102332 <writei+0x18d>
80102313:	8b 45 08             	mov    0x8(%ebp),%eax
80102316:	8b 40 18             	mov    0x18(%eax),%eax
80102319:	3b 45 10             	cmp    0x10(%ebp),%eax
8010231c:	73 14                	jae    80102332 <writei+0x18d>
    ip->size = off;
8010231e:	8b 45 08             	mov    0x8(%ebp),%eax
80102321:	8b 55 10             	mov    0x10(%ebp),%edx
80102324:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102327:	8b 45 08             	mov    0x8(%ebp),%eax
8010232a:	89 04 24             	mov    %eax,(%esp)
8010232d:	e8 56 f6 ff ff       	call   80101988 <iupdate>
  }
  return n;
80102332:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102335:	83 c4 24             	add    $0x24,%esp
80102338:	5b                   	pop    %ebx
80102339:	5d                   	pop    %ebp
8010233a:	c3                   	ret    

8010233b <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010233b:	55                   	push   %ebp
8010233c:	89 e5                	mov    %esp,%ebp
8010233e:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102341:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102348:	00 
80102349:	8b 45 0c             	mov    0xc(%ebp),%eax
8010234c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102350:	8b 45 08             	mov    0x8(%ebp),%eax
80102353:	89 04 24             	mov    %eax,(%esp)
80102356:	e8 0a 32 00 00       	call   80105565 <strncmp>
}
8010235b:	c9                   	leave  
8010235c:	c3                   	ret    

8010235d <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010235d:	55                   	push   %ebp
8010235e:	89 e5                	mov    %esp,%ebp
80102360:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102363:	8b 45 08             	mov    0x8(%ebp),%eax
80102366:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010236a:	66 83 f8 01          	cmp    $0x1,%ax
8010236e:	74 0c                	je     8010237c <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102370:	c7 04 24 6d 89 10 80 	movl   $0x8010896d,(%esp)
80102377:	e8 c1 e1 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010237c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102383:	e9 87 00 00 00       	jmp    8010240f <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102388:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010238f:	00 
80102390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102393:	89 44 24 08          	mov    %eax,0x8(%esp)
80102397:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010239a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010239e:	8b 45 08             	mov    0x8(%ebp),%eax
801023a1:	89 04 24             	mov    %eax,(%esp)
801023a4:	e8 91 fc ff ff       	call   8010203a <readi>
801023a9:	83 f8 10             	cmp    $0x10,%eax
801023ac:	74 0c                	je     801023ba <dirlookup+0x5d>
      panic("dirlink read");
801023ae:	c7 04 24 7f 89 10 80 	movl   $0x8010897f,(%esp)
801023b5:	e8 83 e1 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801023ba:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023be:	66 85 c0             	test   %ax,%ax
801023c1:	74 47                	je     8010240a <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
801023c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023c6:	83 c0 02             	add    $0x2,%eax
801023c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801023cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801023d0:	89 04 24             	mov    %eax,(%esp)
801023d3:	e8 63 ff ff ff       	call   8010233b <namecmp>
801023d8:	85 c0                	test   %eax,%eax
801023da:	75 2f                	jne    8010240b <dirlookup+0xae>
      // entry matches path element
      if(poff)
801023dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023e0:	74 08                	je     801023ea <dirlookup+0x8d>
        *poff = off;
801023e2:	8b 45 10             	mov    0x10(%ebp),%eax
801023e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023e8:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023ea:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023ee:	0f b7 c0             	movzwl %ax,%eax
801023f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023f4:	8b 45 08             	mov    0x8(%ebp),%eax
801023f7:	8b 00                	mov    (%eax),%eax
801023f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023fc:	89 54 24 04          	mov    %edx,0x4(%esp)
80102400:	89 04 24             	mov    %eax,(%esp)
80102403:	e8 38 f6 ff ff       	call   80101a40 <iget>
80102408:	eb 19                	jmp    80102423 <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010240a:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010240b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010240f:	8b 45 08             	mov    0x8(%ebp),%eax
80102412:	8b 40 18             	mov    0x18(%eax),%eax
80102415:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102418:	0f 87 6a ff ff ff    	ja     80102388 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010241e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102423:	c9                   	leave  
80102424:	c3                   	ret    

80102425 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102425:	55                   	push   %ebp
80102426:	89 e5                	mov    %esp,%ebp
80102428:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010242b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102432:	00 
80102433:	8b 45 0c             	mov    0xc(%ebp),%eax
80102436:	89 44 24 04          	mov    %eax,0x4(%esp)
8010243a:	8b 45 08             	mov    0x8(%ebp),%eax
8010243d:	89 04 24             	mov    %eax,(%esp)
80102440:	e8 18 ff ff ff       	call   8010235d <dirlookup>
80102445:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102448:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010244c:	74 15                	je     80102463 <dirlink+0x3e>
    iput(ip);
8010244e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102451:	89 04 24             	mov    %eax,(%esp)
80102454:	e8 9e f8 ff ff       	call   80101cf7 <iput>
    return -1;
80102459:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010245e:	e9 b8 00 00 00       	jmp    8010251b <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102463:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010246a:	eb 44                	jmp    801024b0 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010246c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010246f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102476:	00 
80102477:	89 44 24 08          	mov    %eax,0x8(%esp)
8010247b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010247e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102482:	8b 45 08             	mov    0x8(%ebp),%eax
80102485:	89 04 24             	mov    %eax,(%esp)
80102488:	e8 ad fb ff ff       	call   8010203a <readi>
8010248d:	83 f8 10             	cmp    $0x10,%eax
80102490:	74 0c                	je     8010249e <dirlink+0x79>
      panic("dirlink read");
80102492:	c7 04 24 7f 89 10 80 	movl   $0x8010897f,(%esp)
80102499:	e8 9f e0 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
8010249e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801024a2:	66 85 c0             	test   %ax,%ax
801024a5:	74 18                	je     801024bf <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801024a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024aa:	83 c0 10             	add    $0x10,%eax
801024ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801024b3:	8b 45 08             	mov    0x8(%ebp),%eax
801024b6:	8b 40 18             	mov    0x18(%eax),%eax
801024b9:	39 c2                	cmp    %eax,%edx
801024bb:	72 af                	jb     8010246c <dirlink+0x47>
801024bd:	eb 01                	jmp    801024c0 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801024bf:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801024c0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801024c7:	00 
801024c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801024cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801024cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024d2:	83 c0 02             	add    $0x2,%eax
801024d5:	89 04 24             	mov    %eax,(%esp)
801024d8:	e8 e0 30 00 00       	call   801055bd <strncpy>
  de.inum = inum;
801024dd:	8b 45 10             	mov    0x10(%ebp),%eax
801024e0:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024e7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801024ee:	00 
801024ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801024f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801024fa:	8b 45 08             	mov    0x8(%ebp),%eax
801024fd:	89 04 24             	mov    %eax,(%esp)
80102500:	e8 a0 fc ff ff       	call   801021a5 <writei>
80102505:	83 f8 10             	cmp    $0x10,%eax
80102508:	74 0c                	je     80102516 <dirlink+0xf1>
    panic("dirlink");
8010250a:	c7 04 24 8c 89 10 80 	movl   $0x8010898c,(%esp)
80102511:	e8 27 e0 ff ff       	call   8010053d <panic>
  
  return 0;
80102516:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010251b:	c9                   	leave  
8010251c:	c3                   	ret    

8010251d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010251d:	55                   	push   %ebp
8010251e:	89 e5                	mov    %esp,%ebp
80102520:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102523:	eb 04                	jmp    80102529 <skipelem+0xc>
    path++;
80102525:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102529:	8b 45 08             	mov    0x8(%ebp),%eax
8010252c:	0f b6 00             	movzbl (%eax),%eax
8010252f:	3c 2f                	cmp    $0x2f,%al
80102531:	74 f2                	je     80102525 <skipelem+0x8>
    path++;
  if(*path == 0)
80102533:	8b 45 08             	mov    0x8(%ebp),%eax
80102536:	0f b6 00             	movzbl (%eax),%eax
80102539:	84 c0                	test   %al,%al
8010253b:	75 0a                	jne    80102547 <skipelem+0x2a>
    return 0;
8010253d:	b8 00 00 00 00       	mov    $0x0,%eax
80102542:	e9 86 00 00 00       	jmp    801025cd <skipelem+0xb0>
  s = path;
80102547:	8b 45 08             	mov    0x8(%ebp),%eax
8010254a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010254d:	eb 04                	jmp    80102553 <skipelem+0x36>
    path++;
8010254f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102553:	8b 45 08             	mov    0x8(%ebp),%eax
80102556:	0f b6 00             	movzbl (%eax),%eax
80102559:	3c 2f                	cmp    $0x2f,%al
8010255b:	74 0a                	je     80102567 <skipelem+0x4a>
8010255d:	8b 45 08             	mov    0x8(%ebp),%eax
80102560:	0f b6 00             	movzbl (%eax),%eax
80102563:	84 c0                	test   %al,%al
80102565:	75 e8                	jne    8010254f <skipelem+0x32>
    path++;
  len = path - s;
80102567:	8b 55 08             	mov    0x8(%ebp),%edx
8010256a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010256d:	89 d1                	mov    %edx,%ecx
8010256f:	29 c1                	sub    %eax,%ecx
80102571:	89 c8                	mov    %ecx,%eax
80102573:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102576:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010257a:	7e 1c                	jle    80102598 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
8010257c:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102583:	00 
80102584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102587:	89 44 24 04          	mov    %eax,0x4(%esp)
8010258b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010258e:	89 04 24             	mov    %eax,(%esp)
80102591:	e8 2b 2f 00 00       	call   801054c1 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102596:	eb 28                	jmp    801025c0 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102598:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010259b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010259f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801025a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801025a9:	89 04 24             	mov    %eax,(%esp)
801025ac:	e8 10 2f 00 00       	call   801054c1 <memmove>
    name[len] = 0;
801025b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025b4:	03 45 0c             	add    0xc(%ebp),%eax
801025b7:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801025ba:	eb 04                	jmp    801025c0 <skipelem+0xa3>
    path++;
801025bc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801025c0:	8b 45 08             	mov    0x8(%ebp),%eax
801025c3:	0f b6 00             	movzbl (%eax),%eax
801025c6:	3c 2f                	cmp    $0x2f,%al
801025c8:	74 f2                	je     801025bc <skipelem+0x9f>
    path++;
  return path;
801025ca:	8b 45 08             	mov    0x8(%ebp),%eax
}
801025cd:	c9                   	leave  
801025ce:	c3                   	ret    

801025cf <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801025cf:	55                   	push   %ebp
801025d0:	89 e5                	mov    %esp,%ebp
801025d2:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801025d5:	8b 45 08             	mov    0x8(%ebp),%eax
801025d8:	0f b6 00             	movzbl (%eax),%eax
801025db:	3c 2f                	cmp    $0x2f,%al
801025dd:	75 1c                	jne    801025fb <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
801025df:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801025e6:	00 
801025e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801025ee:	e8 4d f4 ff ff       	call   80101a40 <iget>
801025f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801025f6:	e9 af 00 00 00       	jmp    801026aa <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
801025fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102601:	8b 40 68             	mov    0x68(%eax),%eax
80102604:	89 04 24             	mov    %eax,(%esp)
80102607:	e8 06 f5 ff ff       	call   80101b12 <idup>
8010260c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010260f:	e9 96 00 00 00       	jmp    801026aa <namex+0xdb>
    ilock(ip);
80102614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102617:	89 04 24             	mov    %eax,(%esp)
8010261a:	e8 25 f5 ff ff       	call   80101b44 <ilock>
    if(ip->type != T_DIR){
8010261f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102622:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102626:	66 83 f8 01          	cmp    $0x1,%ax
8010262a:	74 15                	je     80102641 <namex+0x72>
      iunlockput(ip);
8010262c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262f:	89 04 24             	mov    %eax,(%esp)
80102632:	e8 91 f7 ff ff       	call   80101dc8 <iunlockput>
      return 0;
80102637:	b8 00 00 00 00       	mov    $0x0,%eax
8010263c:	e9 a3 00 00 00       	jmp    801026e4 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102641:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102645:	74 1d                	je     80102664 <namex+0x95>
80102647:	8b 45 08             	mov    0x8(%ebp),%eax
8010264a:	0f b6 00             	movzbl (%eax),%eax
8010264d:	84 c0                	test   %al,%al
8010264f:	75 13                	jne    80102664 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102654:	89 04 24             	mov    %eax,(%esp)
80102657:	e8 36 f6 ff ff       	call   80101c92 <iunlock>
      return ip;
8010265c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010265f:	e9 80 00 00 00       	jmp    801026e4 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102664:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010266b:	00 
8010266c:	8b 45 10             	mov    0x10(%ebp),%eax
8010266f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102676:	89 04 24             	mov    %eax,(%esp)
80102679:	e8 df fc ff ff       	call   8010235d <dirlookup>
8010267e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102681:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102685:	75 12                	jne    80102699 <namex+0xca>
      iunlockput(ip);
80102687:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010268a:	89 04 24             	mov    %eax,(%esp)
8010268d:	e8 36 f7 ff ff       	call   80101dc8 <iunlockput>
      return 0;
80102692:	b8 00 00 00 00       	mov    $0x0,%eax
80102697:	eb 4b                	jmp    801026e4 <namex+0x115>
    }
    iunlockput(ip);
80102699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010269c:	89 04 24             	mov    %eax,(%esp)
8010269f:	e8 24 f7 ff ff       	call   80101dc8 <iunlockput>
    ip = next;
801026a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801026aa:	8b 45 10             	mov    0x10(%ebp),%eax
801026ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801026b1:	8b 45 08             	mov    0x8(%ebp),%eax
801026b4:	89 04 24             	mov    %eax,(%esp)
801026b7:	e8 61 fe ff ff       	call   8010251d <skipelem>
801026bc:	89 45 08             	mov    %eax,0x8(%ebp)
801026bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026c3:	0f 85 4b ff ff ff    	jne    80102614 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801026c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026cd:	74 12                	je     801026e1 <namex+0x112>
    iput(ip);
801026cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d2:	89 04 24             	mov    %eax,(%esp)
801026d5:	e8 1d f6 ff ff       	call   80101cf7 <iput>
    return 0;
801026da:	b8 00 00 00 00       	mov    $0x0,%eax
801026df:	eb 03                	jmp    801026e4 <namex+0x115>
  }
  return ip;
801026e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801026e4:	c9                   	leave  
801026e5:	c3                   	ret    

801026e6 <namei>:

struct inode*
namei(char *path)
{
801026e6:	55                   	push   %ebp
801026e7:	89 e5                	mov    %esp,%ebp
801026e9:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801026ec:	8d 45 ea             	lea    -0x16(%ebp),%eax
801026ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801026f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801026fa:	00 
801026fb:	8b 45 08             	mov    0x8(%ebp),%eax
801026fe:	89 04 24             	mov    %eax,(%esp)
80102701:	e8 c9 fe ff ff       	call   801025cf <namex>
}
80102706:	c9                   	leave  
80102707:	c3                   	ret    

80102708 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102708:	55                   	push   %ebp
80102709:	89 e5                	mov    %esp,%ebp
8010270b:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010270e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102711:	89 44 24 08          	mov    %eax,0x8(%esp)
80102715:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010271c:	00 
8010271d:	8b 45 08             	mov    0x8(%ebp),%eax
80102720:	89 04 24             	mov    %eax,(%esp)
80102723:	e8 a7 fe ff ff       	call   801025cf <namex>
}
80102728:	c9                   	leave  
80102729:	c3                   	ret    
	...

8010272c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010272c:	55                   	push   %ebp
8010272d:	89 e5                	mov    %esp,%ebp
8010272f:	53                   	push   %ebx
80102730:	83 ec 14             	sub    $0x14,%esp
80102733:	8b 45 08             	mov    0x8(%ebp),%eax
80102736:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010273a:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010273e:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102742:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102746:	ec                   	in     (%dx),%al
80102747:	89 c3                	mov    %eax,%ebx
80102749:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010274c:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102750:	83 c4 14             	add    $0x14,%esp
80102753:	5b                   	pop    %ebx
80102754:	5d                   	pop    %ebp
80102755:	c3                   	ret    

80102756 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102756:	55                   	push   %ebp
80102757:	89 e5                	mov    %esp,%ebp
80102759:	57                   	push   %edi
8010275a:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010275b:	8b 55 08             	mov    0x8(%ebp),%edx
8010275e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102761:	8b 45 10             	mov    0x10(%ebp),%eax
80102764:	89 cb                	mov    %ecx,%ebx
80102766:	89 df                	mov    %ebx,%edi
80102768:	89 c1                	mov    %eax,%ecx
8010276a:	fc                   	cld    
8010276b:	f3 6d                	rep insl (%dx),%es:(%edi)
8010276d:	89 c8                	mov    %ecx,%eax
8010276f:	89 fb                	mov    %edi,%ebx
80102771:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102774:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102777:	5b                   	pop    %ebx
80102778:	5f                   	pop    %edi
80102779:	5d                   	pop    %ebp
8010277a:	c3                   	ret    

8010277b <outb>:

static inline void
outb(ushort port, uchar data)
{
8010277b:	55                   	push   %ebp
8010277c:	89 e5                	mov    %esp,%ebp
8010277e:	83 ec 08             	sub    $0x8,%esp
80102781:	8b 55 08             	mov    0x8(%ebp),%edx
80102784:	8b 45 0c             	mov    0xc(%ebp),%eax
80102787:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010278b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010278e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102792:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102796:	ee                   	out    %al,(%dx)
}
80102797:	c9                   	leave  
80102798:	c3                   	ret    

80102799 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102799:	55                   	push   %ebp
8010279a:	89 e5                	mov    %esp,%ebp
8010279c:	56                   	push   %esi
8010279d:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010279e:	8b 55 08             	mov    0x8(%ebp),%edx
801027a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027a4:	8b 45 10             	mov    0x10(%ebp),%eax
801027a7:	89 cb                	mov    %ecx,%ebx
801027a9:	89 de                	mov    %ebx,%esi
801027ab:	89 c1                	mov    %eax,%ecx
801027ad:	fc                   	cld    
801027ae:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801027b0:	89 c8                	mov    %ecx,%eax
801027b2:	89 f3                	mov    %esi,%ebx
801027b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027b7:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801027ba:	5b                   	pop    %ebx
801027bb:	5e                   	pop    %esi
801027bc:	5d                   	pop    %ebp
801027bd:	c3                   	ret    

801027be <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801027be:	55                   	push   %ebp
801027bf:	89 e5                	mov    %esp,%ebp
801027c1:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801027c4:	90                   	nop
801027c5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801027cc:	e8 5b ff ff ff       	call   8010272c <inb>
801027d1:	0f b6 c0             	movzbl %al,%eax
801027d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
801027d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027da:	25 c0 00 00 00       	and    $0xc0,%eax
801027df:	83 f8 40             	cmp    $0x40,%eax
801027e2:	75 e1                	jne    801027c5 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801027e4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027e8:	74 11                	je     801027fb <idewait+0x3d>
801027ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027ed:	83 e0 21             	and    $0x21,%eax
801027f0:	85 c0                	test   %eax,%eax
801027f2:	74 07                	je     801027fb <idewait+0x3d>
    return -1;
801027f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027f9:	eb 05                	jmp    80102800 <idewait+0x42>
  return 0;
801027fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102800:	c9                   	leave  
80102801:	c3                   	ret    

80102802 <ideinit>:

void
ideinit(void)
{
80102802:	55                   	push   %ebp
80102803:	89 e5                	mov    %esp,%ebp
80102805:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102808:	c7 44 24 04 94 89 10 	movl   $0x80108994,0x4(%esp)
8010280f:	80 
80102810:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102817:	e8 62 29 00 00       	call   8010517e <initlock>
  picenable(IRQ_IDE);
8010281c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102823:	e8 75 15 00 00       	call   80103d9d <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102828:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
8010282d:	83 e8 01             	sub    $0x1,%eax
80102830:	89 44 24 04          	mov    %eax,0x4(%esp)
80102834:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010283b:	e8 12 04 00 00       	call   80102c52 <ioapicenable>
  idewait(0);
80102840:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102847:	e8 72 ff ff ff       	call   801027be <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010284c:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102853:	00 
80102854:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010285b:	e8 1b ff ff ff       	call   8010277b <outb>
  for(i=0; i<1000; i++){
80102860:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102867:	eb 20                	jmp    80102889 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102869:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102870:	e8 b7 fe ff ff       	call   8010272c <inb>
80102875:	84 c0                	test   %al,%al
80102877:	74 0c                	je     80102885 <ideinit+0x83>
      havedisk1 = 1;
80102879:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
80102880:	00 00 00 
      break;
80102883:	eb 0d                	jmp    80102892 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102885:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102889:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102890:	7e d7                	jle    80102869 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102892:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102899:	00 
8010289a:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028a1:	e8 d5 fe ff ff       	call   8010277b <outb>
}
801028a6:	c9                   	leave  
801028a7:	c3                   	ret    

801028a8 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801028a8:	55                   	push   %ebp
801028a9:	89 e5                	mov    %esp,%ebp
801028ab:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801028ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028b2:	75 0c                	jne    801028c0 <idestart+0x18>
    panic("idestart");
801028b4:	c7 04 24 98 89 10 80 	movl   $0x80108998,(%esp)
801028bb:	e8 7d dc ff ff       	call   8010053d <panic>

  idewait(0);
801028c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028c7:	e8 f2 fe ff ff       	call   801027be <idewait>
  outb(0x3f6, 0);  // generate interrupt
801028cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801028d3:	00 
801028d4:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801028db:	e8 9b fe ff ff       	call   8010277b <outb>
  outb(0x1f2, 1);  // number of sectors
801028e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801028e7:	00 
801028e8:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801028ef:	e8 87 fe ff ff       	call   8010277b <outb>
  outb(0x1f3, b->sector & 0xff);
801028f4:	8b 45 08             	mov    0x8(%ebp),%eax
801028f7:	8b 40 08             	mov    0x8(%eax),%eax
801028fa:	0f b6 c0             	movzbl %al,%eax
801028fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102901:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102908:	e8 6e fe ff ff       	call   8010277b <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010290d:	8b 45 08             	mov    0x8(%ebp),%eax
80102910:	8b 40 08             	mov    0x8(%eax),%eax
80102913:	c1 e8 08             	shr    $0x8,%eax
80102916:	0f b6 c0             	movzbl %al,%eax
80102919:	89 44 24 04          	mov    %eax,0x4(%esp)
8010291d:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102924:	e8 52 fe ff ff       	call   8010277b <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102929:	8b 45 08             	mov    0x8(%ebp),%eax
8010292c:	8b 40 08             	mov    0x8(%eax),%eax
8010292f:	c1 e8 10             	shr    $0x10,%eax
80102932:	0f b6 c0             	movzbl %al,%eax
80102935:	89 44 24 04          	mov    %eax,0x4(%esp)
80102939:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102940:	e8 36 fe ff ff       	call   8010277b <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102945:	8b 45 08             	mov    0x8(%ebp),%eax
80102948:	8b 40 04             	mov    0x4(%eax),%eax
8010294b:	83 e0 01             	and    $0x1,%eax
8010294e:	89 c2                	mov    %eax,%edx
80102950:	c1 e2 04             	shl    $0x4,%edx
80102953:	8b 45 08             	mov    0x8(%ebp),%eax
80102956:	8b 40 08             	mov    0x8(%eax),%eax
80102959:	c1 e8 18             	shr    $0x18,%eax
8010295c:	83 e0 0f             	and    $0xf,%eax
8010295f:	09 d0                	or     %edx,%eax
80102961:	83 c8 e0             	or     $0xffffffe0,%eax
80102964:	0f b6 c0             	movzbl %al,%eax
80102967:	89 44 24 04          	mov    %eax,0x4(%esp)
8010296b:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102972:	e8 04 fe ff ff       	call   8010277b <outb>
  if(b->flags & B_DIRTY){
80102977:	8b 45 08             	mov    0x8(%ebp),%eax
8010297a:	8b 00                	mov    (%eax),%eax
8010297c:	83 e0 04             	and    $0x4,%eax
8010297f:	85 c0                	test   %eax,%eax
80102981:	74 34                	je     801029b7 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102983:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
8010298a:	00 
8010298b:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102992:	e8 e4 fd ff ff       	call   8010277b <outb>
    outsl(0x1f0, b->data, 512/4);
80102997:	8b 45 08             	mov    0x8(%ebp),%eax
8010299a:	83 c0 18             	add    $0x18,%eax
8010299d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801029a4:	00 
801029a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801029a9:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801029b0:	e8 e4 fd ff ff       	call   80102799 <outsl>
801029b5:	eb 14                	jmp    801029cb <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801029b7:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801029be:	00 
801029bf:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801029c6:	e8 b0 fd ff ff       	call   8010277b <outb>
  }
}
801029cb:	c9                   	leave  
801029cc:	c3                   	ret    

801029cd <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801029cd:	55                   	push   %ebp
801029ce:	89 e5                	mov    %esp,%ebp
801029d0:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801029d3:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801029da:	e8 c0 27 00 00       	call   8010519f <acquire>
  if((b = idequeue) == 0){
801029df:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801029e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801029eb:	75 11                	jne    801029fe <ideintr+0x31>
    release(&idelock);
801029ed:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801029f4:	e8 08 28 00 00       	call   80105201 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
801029f9:	e9 90 00 00 00       	jmp    80102a8e <ideintr+0xc1>
  }
  idequeue = b->qnext;
801029fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a01:	8b 40 14             	mov    0x14(%eax),%eax
80102a04:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a0c:	8b 00                	mov    (%eax),%eax
80102a0e:	83 e0 04             	and    $0x4,%eax
80102a11:	85 c0                	test   %eax,%eax
80102a13:	75 2e                	jne    80102a43 <ideintr+0x76>
80102a15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a1c:	e8 9d fd ff ff       	call   801027be <idewait>
80102a21:	85 c0                	test   %eax,%eax
80102a23:	78 1e                	js     80102a43 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a28:	83 c0 18             	add    $0x18,%eax
80102a2b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a32:	00 
80102a33:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a37:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a3e:	e8 13 fd ff ff       	call   80102756 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a46:	8b 00                	mov    (%eax),%eax
80102a48:	89 c2                	mov    %eax,%edx
80102a4a:	83 ca 02             	or     $0x2,%edx
80102a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a50:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a55:	8b 00                	mov    (%eax),%eax
80102a57:	89 c2                	mov    %eax,%edx
80102a59:	83 e2 fb             	and    $0xfffffffb,%edx
80102a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a5f:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a64:	89 04 24             	mov    %eax,(%esp)
80102a67:	e8 7a 24 00 00       	call   80104ee6 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a6c:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a71:	85 c0                	test   %eax,%eax
80102a73:	74 0d                	je     80102a82 <ideintr+0xb5>
    idestart(idequeue);
80102a75:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102a7a:	89 04 24             	mov    %eax,(%esp)
80102a7d:	e8 26 fe ff ff       	call   801028a8 <idestart>

  release(&idelock);
80102a82:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102a89:	e8 73 27 00 00       	call   80105201 <release>
}
80102a8e:	c9                   	leave  
80102a8f:	c3                   	ret    

80102a90 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102a90:	55                   	push   %ebp
80102a91:	89 e5                	mov    %esp,%ebp
80102a93:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102a96:	8b 45 08             	mov    0x8(%ebp),%eax
80102a99:	8b 00                	mov    (%eax),%eax
80102a9b:	83 e0 01             	and    $0x1,%eax
80102a9e:	85 c0                	test   %eax,%eax
80102aa0:	75 0c                	jne    80102aae <iderw+0x1e>
    panic("iderw: buf not busy");
80102aa2:	c7 04 24 a1 89 10 80 	movl   $0x801089a1,(%esp)
80102aa9:	e8 8f da ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102aae:	8b 45 08             	mov    0x8(%ebp),%eax
80102ab1:	8b 00                	mov    (%eax),%eax
80102ab3:	83 e0 06             	and    $0x6,%eax
80102ab6:	83 f8 02             	cmp    $0x2,%eax
80102ab9:	75 0c                	jne    80102ac7 <iderw+0x37>
    panic("iderw: nothing to do");
80102abb:	c7 04 24 b5 89 10 80 	movl   $0x801089b5,(%esp)
80102ac2:	e8 76 da ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80102aca:	8b 40 04             	mov    0x4(%eax),%eax
80102acd:	85 c0                	test   %eax,%eax
80102acf:	74 15                	je     80102ae6 <iderw+0x56>
80102ad1:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102ad6:	85 c0                	test   %eax,%eax
80102ad8:	75 0c                	jne    80102ae6 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102ada:	c7 04 24 ca 89 10 80 	movl   $0x801089ca,(%esp)
80102ae1:	e8 57 da ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
80102ae6:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102aed:	e8 ad 26 00 00       	call   8010519f <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102af2:	8b 45 08             	mov    0x8(%ebp),%eax
80102af5:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102afc:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102b03:	eb 0b                	jmp    80102b10 <iderw+0x80>
80102b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b08:	8b 00                	mov    (%eax),%eax
80102b0a:	83 c0 14             	add    $0x14,%eax
80102b0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b13:	8b 00                	mov    (%eax),%eax
80102b15:	85 c0                	test   %eax,%eax
80102b17:	75 ec                	jne    80102b05 <iderw+0x75>
    ;
  *pp = b;
80102b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1c:	8b 55 08             	mov    0x8(%ebp),%edx
80102b1f:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102b21:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102b26:	3b 45 08             	cmp    0x8(%ebp),%eax
80102b29:	75 22                	jne    80102b4d <iderw+0xbd>
    idestart(b);
80102b2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2e:	89 04 24             	mov    %eax,(%esp)
80102b31:	e8 72 fd ff ff       	call   801028a8 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b36:	eb 15                	jmp    80102b4d <iderw+0xbd>
    sleep(b, &idelock);
80102b38:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102b3f:	80 
80102b40:	8b 45 08             	mov    0x8(%ebp),%eax
80102b43:	89 04 24             	mov    %eax,(%esp)
80102b46:	e8 bf 22 00 00       	call   80104e0a <sleep>
80102b4b:	eb 01                	jmp    80102b4e <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b4d:	90                   	nop
80102b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b51:	8b 00                	mov    (%eax),%eax
80102b53:	83 e0 06             	and    $0x6,%eax
80102b56:	83 f8 02             	cmp    $0x2,%eax
80102b59:	75 dd                	jne    80102b38 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102b5b:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102b62:	e8 9a 26 00 00       	call   80105201 <release>
}
80102b67:	c9                   	leave  
80102b68:	c3                   	ret    
80102b69:	00 00                	add    %al,(%eax)
	...

80102b6c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b6c:	55                   	push   %ebp
80102b6d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b6f:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102b74:	8b 55 08             	mov    0x8(%ebp),%edx
80102b77:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b79:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102b7e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102b81:	5d                   	pop    %ebp
80102b82:	c3                   	ret    

80102b83 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102b83:	55                   	push   %ebp
80102b84:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b86:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102b8b:	8b 55 08             	mov    0x8(%ebp),%edx
80102b8e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b90:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102b95:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b98:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b9b:	5d                   	pop    %ebp
80102b9c:	c3                   	ret    

80102b9d <ioapicinit>:

void
ioapicinit(void)
{
80102b9d:	55                   	push   %ebp
80102b9e:	89 e5                	mov    %esp,%ebp
80102ba0:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102ba3:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102ba8:	85 c0                	test   %eax,%eax
80102baa:	0f 84 9f 00 00 00    	je     80102c4f <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102bb0:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
80102bb7:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102bba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102bc1:	e8 a6 ff ff ff       	call   80102b6c <ioapicread>
80102bc6:	c1 e8 10             	shr    $0x10,%eax
80102bc9:	25 ff 00 00 00       	and    $0xff,%eax
80102bce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102bd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102bd8:	e8 8f ff ff ff       	call   80102b6c <ioapicread>
80102bdd:	c1 e8 18             	shr    $0x18,%eax
80102be0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102be3:	0f b6 05 20 f9 10 80 	movzbl 0x8010f920,%eax
80102bea:	0f b6 c0             	movzbl %al,%eax
80102bed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102bf0:	74 0c                	je     80102bfe <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102bf2:	c7 04 24 e8 89 10 80 	movl   $0x801089e8,(%esp)
80102bf9:	e8 a3 d7 ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102bfe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c05:	eb 3e                	jmp    80102c45 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c0a:	83 c0 20             	add    $0x20,%eax
80102c0d:	0d 00 00 01 00       	or     $0x10000,%eax
80102c12:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102c15:	83 c2 08             	add    $0x8,%edx
80102c18:	01 d2                	add    %edx,%edx
80102c1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c1e:	89 14 24             	mov    %edx,(%esp)
80102c21:	e8 5d ff ff ff       	call   80102b83 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c29:	83 c0 08             	add    $0x8,%eax
80102c2c:	01 c0                	add    %eax,%eax
80102c2e:	83 c0 01             	add    $0x1,%eax
80102c31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102c38:	00 
80102c39:	89 04 24             	mov    %eax,(%esp)
80102c3c:	e8 42 ff ff ff       	call   80102b83 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c41:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c48:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c4b:	7e ba                	jle    80102c07 <ioapicinit+0x6a>
80102c4d:	eb 01                	jmp    80102c50 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102c4f:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102c50:	c9                   	leave  
80102c51:	c3                   	ret    

80102c52 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c52:	55                   	push   %ebp
80102c53:	89 e5                	mov    %esp,%ebp
80102c55:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102c58:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102c5d:	85 c0                	test   %eax,%eax
80102c5f:	74 39                	je     80102c9a <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c61:	8b 45 08             	mov    0x8(%ebp),%eax
80102c64:	83 c0 20             	add    $0x20,%eax
80102c67:	8b 55 08             	mov    0x8(%ebp),%edx
80102c6a:	83 c2 08             	add    $0x8,%edx
80102c6d:	01 d2                	add    %edx,%edx
80102c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c73:	89 14 24             	mov    %edx,(%esp)
80102c76:	e8 08 ff ff ff       	call   80102b83 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c7e:	c1 e0 18             	shl    $0x18,%eax
80102c81:	8b 55 08             	mov    0x8(%ebp),%edx
80102c84:	83 c2 08             	add    $0x8,%edx
80102c87:	01 d2                	add    %edx,%edx
80102c89:	83 c2 01             	add    $0x1,%edx
80102c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c90:	89 14 24             	mov    %edx,(%esp)
80102c93:	e8 eb fe ff ff       	call   80102b83 <ioapicwrite>
80102c98:	eb 01                	jmp    80102c9b <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102c9a:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102c9b:	c9                   	leave  
80102c9c:	c3                   	ret    
80102c9d:	00 00                	add    %al,(%eax)
	...

80102ca0 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102ca0:	55                   	push   %ebp
80102ca1:	89 e5                	mov    %esp,%ebp
80102ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca6:	05 00 00 00 80       	add    $0x80000000,%eax
80102cab:	5d                   	pop    %ebp
80102cac:	c3                   	ret    

80102cad <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102cad:	55                   	push   %ebp
80102cae:	89 e5                	mov    %esp,%ebp
80102cb0:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102cb3:	c7 44 24 04 1a 8a 10 	movl   $0x80108a1a,0x4(%esp)
80102cba:	80 
80102cbb:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102cc2:	e8 b7 24 00 00       	call   8010517e <initlock>
  kmem.use_lock = 0;
80102cc7:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
80102cce:	00 00 00 
  freerange(vstart, vend);
80102cd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cd4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80102cdb:	89 04 24             	mov    %eax,(%esp)
80102cde:	e8 26 00 00 00       	call   80102d09 <freerange>
}
80102ce3:	c9                   	leave  
80102ce4:	c3                   	ret    

80102ce5 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102ce5:	55                   	push   %ebp
80102ce6:	89 e5                	mov    %esp,%ebp
80102ce8:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cee:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cf2:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf5:	89 04 24             	mov    %eax,(%esp)
80102cf8:	e8 0c 00 00 00       	call   80102d09 <freerange>
  kmem.use_lock = 1;
80102cfd:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
80102d04:	00 00 00 
}
80102d07:	c9                   	leave  
80102d08:	c3                   	ret    

80102d09 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d09:	55                   	push   %ebp
80102d0a:	89 e5                	mov    %esp,%ebp
80102d0c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d0f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d12:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d17:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d1f:	eb 12                	jmp    80102d33 <freerange+0x2a>
    kfree(p);
80102d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d24:	89 04 24             	mov    %eax,(%esp)
80102d27:	e8 16 00 00 00       	call   80102d42 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d2c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d36:	05 00 10 00 00       	add    $0x1000,%eax
80102d3b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102d3e:	76 e1                	jbe    80102d21 <freerange+0x18>
    kfree(p);
}
80102d40:	c9                   	leave  
80102d41:	c3                   	ret    

80102d42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d42:	55                   	push   %ebp
80102d43:	89 e5                	mov    %esp,%ebp
80102d45:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102d48:	8b 45 08             	mov    0x8(%ebp),%eax
80102d4b:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d50:	85 c0                	test   %eax,%eax
80102d52:	75 1b                	jne    80102d6f <kfree+0x2d>
80102d54:	81 7d 08 1c 2e 11 80 	cmpl   $0x80112e1c,0x8(%ebp)
80102d5b:	72 12                	jb     80102d6f <kfree+0x2d>
80102d5d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d60:	89 04 24             	mov    %eax,(%esp)
80102d63:	e8 38 ff ff ff       	call   80102ca0 <v2p>
80102d68:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102d6d:	76 0c                	jbe    80102d7b <kfree+0x39>
    panic("kfree");
80102d6f:	c7 04 24 1f 8a 10 80 	movl   $0x80108a1f,(%esp)
80102d76:	e8 c2 d7 ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d7b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102d82:	00 
80102d83:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102d8a:	00 
80102d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d8e:	89 04 24             	mov    %eax,(%esp)
80102d91:	e8 58 26 00 00       	call   801053ee <memset>

  if(kmem.use_lock)
80102d96:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102d9b:	85 c0                	test   %eax,%eax
80102d9d:	74 0c                	je     80102dab <kfree+0x69>
    acquire(&kmem.lock);
80102d9f:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102da6:	e8 f4 23 00 00       	call   8010519f <acquire>
  r = (struct run*)v;
80102dab:	8b 45 08             	mov    0x8(%ebp),%eax
80102dae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102db1:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dba:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dbf:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102dc4:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102dc9:	85 c0                	test   %eax,%eax
80102dcb:	74 0c                	je     80102dd9 <kfree+0x97>
    release(&kmem.lock);
80102dcd:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102dd4:	e8 28 24 00 00       	call   80105201 <release>
}
80102dd9:	c9                   	leave  
80102dda:	c3                   	ret    

80102ddb <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102ddb:	55                   	push   %ebp
80102ddc:	89 e5                	mov    %esp,%ebp
80102dde:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102de1:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102de6:	85 c0                	test   %eax,%eax
80102de8:	74 0c                	je     80102df6 <kalloc+0x1b>
    acquire(&kmem.lock);
80102dea:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102df1:	e8 a9 23 00 00       	call   8010519f <acquire>
  r = kmem.freelist;
80102df6:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102dfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102dfe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e02:	74 0a                	je     80102e0e <kalloc+0x33>
    kmem.freelist = r->next;
80102e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e07:	8b 00                	mov    (%eax),%eax
80102e09:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102e0e:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102e13:	85 c0                	test   %eax,%eax
80102e15:	74 0c                	je     80102e23 <kalloc+0x48>
    release(&kmem.lock);
80102e17:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102e1e:	e8 de 23 00 00       	call   80105201 <release>
  return (char*)r;
80102e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e26:	c9                   	leave  
80102e27:	c3                   	ret    

80102e28 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e28:	55                   	push   %ebp
80102e29:	89 e5                	mov    %esp,%ebp
80102e2b:	53                   	push   %ebx
80102e2c:	83 ec 14             	sub    $0x14,%esp
80102e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80102e32:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e36:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102e3a:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102e3e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102e42:	ec                   	in     (%dx),%al
80102e43:	89 c3                	mov    %eax,%ebx
80102e45:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102e48:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102e4c:	83 c4 14             	add    $0x14,%esp
80102e4f:	5b                   	pop    %ebx
80102e50:	5d                   	pop    %ebp
80102e51:	c3                   	ret    

80102e52 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e52:	55                   	push   %ebp
80102e53:	89 e5                	mov    %esp,%ebp
80102e55:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e58:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102e5f:	e8 c4 ff ff ff       	call   80102e28 <inb>
80102e64:	0f b6 c0             	movzbl %al,%eax
80102e67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e6d:	83 e0 01             	and    $0x1,%eax
80102e70:	85 c0                	test   %eax,%eax
80102e72:	75 0a                	jne    80102e7e <kbdgetc+0x2c>
    return -1;
80102e74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e79:	e9 23 01 00 00       	jmp    80102fa1 <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102e7e:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102e85:	e8 9e ff ff ff       	call   80102e28 <inb>
80102e8a:	0f b6 c0             	movzbl %al,%eax
80102e8d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    
  if(data == 0xE0){
80102e90:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e97:	75 17                	jne    80102eb0 <kbdgetc+0x5e>
    shift |= E0ESC;
80102e99:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102e9e:	83 c8 40             	or     $0x40,%eax
80102ea1:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102ea6:	b8 00 00 00 00       	mov    $0x0,%eax
80102eab:	e9 f1 00 00 00       	jmp    80102fa1 <kbdgetc+0x14f>
  } else if(data & 0x80){
80102eb0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eb3:	25 80 00 00 00       	and    $0x80,%eax
80102eb8:	85 c0                	test   %eax,%eax
80102eba:	74 45                	je     80102f01 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ebc:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ec1:	83 e0 40             	and    $0x40,%eax
80102ec4:	85 c0                	test   %eax,%eax
80102ec6:	75 08                	jne    80102ed0 <kbdgetc+0x7e>
80102ec8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ecb:	83 e0 7f             	and    $0x7f,%eax
80102ece:	eb 03                	jmp    80102ed3 <kbdgetc+0x81>
80102ed0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ed3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102ed6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ed9:	05 20 90 10 80       	add    $0x80109020,%eax
80102ede:	0f b6 00             	movzbl (%eax),%eax
80102ee1:	83 c8 40             	or     $0x40,%eax
80102ee4:	0f b6 c0             	movzbl %al,%eax
80102ee7:	f7 d0                	not    %eax
80102ee9:	89 c2                	mov    %eax,%edx
80102eeb:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ef0:	21 d0                	and    %edx,%eax
80102ef2:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102ef7:	b8 00 00 00 00       	mov    $0x0,%eax
80102efc:	e9 a0 00 00 00       	jmp    80102fa1 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102f01:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f06:	83 e0 40             	and    $0x40,%eax
80102f09:	85 c0                	test   %eax,%eax
80102f0b:	74 14                	je     80102f21 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f0d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f14:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f19:	83 e0 bf             	and    $0xffffffbf,%eax
80102f1c:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102f21:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f24:	05 20 90 10 80       	add    $0x80109020,%eax
80102f29:	0f b6 00             	movzbl (%eax),%eax
80102f2c:	0f b6 d0             	movzbl %al,%edx
80102f2f:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f34:	09 d0                	or     %edx,%eax
80102f36:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102f3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f3e:	05 20 91 10 80       	add    $0x80109120,%eax
80102f43:	0f b6 00             	movzbl (%eax),%eax
80102f46:	0f b6 d0             	movzbl %al,%edx
80102f49:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f4e:	31 d0                	xor    %edx,%eax
80102f50:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f55:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f5a:	83 e0 03             	and    $0x3,%eax
80102f5d:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
80102f64:	03 45 fc             	add    -0x4(%ebp),%eax
80102f67:	0f b6 00             	movzbl (%eax),%eax
80102f6a:	0f b6 c0             	movzbl %al,%eax
80102f6d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f70:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102f75:	83 e0 08             	and    $0x8,%eax
80102f78:	85 c0                	test   %eax,%eax
80102f7a:	74 22                	je     80102f9e <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102f7c:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f80:	76 0c                	jbe    80102f8e <kbdgetc+0x13c>
80102f82:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f86:	77 06                	ja     80102f8e <kbdgetc+0x13c>
      c += 'A' - 'a';
80102f88:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f8c:	eb 10                	jmp    80102f9e <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80102f8e:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f92:	76 0a                	jbe    80102f9e <kbdgetc+0x14c>
80102f94:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f98:	77 04                	ja     80102f9e <kbdgetc+0x14c>
      c += 'a' - 'A';
80102f9a:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102fa1:	c9                   	leave  
80102fa2:	c3                   	ret    

80102fa3 <kbdintr>:

void
kbdintr(void)
{
80102fa3:	55                   	push   %ebp
80102fa4:	89 e5                	mov    %esp,%ebp
80102fa6:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102fa9:	c7 04 24 52 2e 10 80 	movl   $0x80102e52,(%esp)
80102fb0:	e8 bd d8 ff ff       	call   80100872 <consoleintr>
}
80102fb5:	c9                   	leave  
80102fb6:	c3                   	ret    
	...

80102fb8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102fb8:	55                   	push   %ebp
80102fb9:	89 e5                	mov    %esp,%ebp
80102fbb:	83 ec 08             	sub    $0x8,%esp
80102fbe:	8b 55 08             	mov    0x8(%ebp),%edx
80102fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fc4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102fc8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102fcb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102fcf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102fd3:	ee                   	out    %al,(%dx)
}
80102fd4:	c9                   	leave  
80102fd5:	c3                   	ret    

80102fd6 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102fd6:	55                   	push   %ebp
80102fd7:	89 e5                	mov    %esp,%ebp
80102fd9:	53                   	push   %ebx
80102fda:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102fdd:	9c                   	pushf  
80102fde:	5b                   	pop    %ebx
80102fdf:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80102fe2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102fe5:	83 c4 10             	add    $0x10,%esp
80102fe8:	5b                   	pop    %ebx
80102fe9:	5d                   	pop    %ebp
80102fea:	c3                   	ret    

80102feb <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102feb:	55                   	push   %ebp
80102fec:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102fee:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102ff3:	8b 55 08             	mov    0x8(%ebp),%edx
80102ff6:	c1 e2 02             	shl    $0x2,%edx
80102ff9:	01 c2                	add    %eax,%edx
80102ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ffe:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103000:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103005:	83 c0 20             	add    $0x20,%eax
80103008:	8b 00                	mov    (%eax),%eax
}
8010300a:	5d                   	pop    %ebp
8010300b:	c3                   	ret    

8010300c <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
8010300c:	55                   	push   %ebp
8010300d:	89 e5                	mov    %esp,%ebp
8010300f:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80103012:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103017:	85 c0                	test   %eax,%eax
80103019:	0f 84 47 01 00 00    	je     80103166 <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010301f:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80103026:	00 
80103027:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
8010302e:	e8 b8 ff ff ff       	call   80102feb <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103033:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
8010303a:	00 
8010303b:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103042:	e8 a4 ff ff ff       	call   80102feb <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103047:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
8010304e:	00 
8010304f:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103056:	e8 90 ff ff ff       	call   80102feb <lapicw>
  lapicw(TICR, 10000000); 
8010305b:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80103062:	00 
80103063:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
8010306a:	e8 7c ff ff ff       	call   80102feb <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010306f:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103076:	00 
80103077:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
8010307e:	e8 68 ff ff ff       	call   80102feb <lapicw>
  lapicw(LINT1, MASKED);
80103083:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010308a:	00 
8010308b:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80103092:	e8 54 ff ff ff       	call   80102feb <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103097:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010309c:	83 c0 30             	add    $0x30,%eax
8010309f:	8b 00                	mov    (%eax),%eax
801030a1:	c1 e8 10             	shr    $0x10,%eax
801030a4:	25 ff 00 00 00       	and    $0xff,%eax
801030a9:	83 f8 03             	cmp    $0x3,%eax
801030ac:	76 14                	jbe    801030c2 <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
801030ae:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030b5:	00 
801030b6:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801030bd:	e8 29 ff ff ff       	call   80102feb <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801030c2:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
801030c9:	00 
801030ca:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
801030d1:	e8 15 ff ff ff       	call   80102feb <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801030d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030dd:	00 
801030de:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801030e5:	e8 01 ff ff ff       	call   80102feb <lapicw>
  lapicw(ESR, 0);
801030ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030f1:	00 
801030f2:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801030f9:	e8 ed fe ff ff       	call   80102feb <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801030fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103105:	00 
80103106:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
8010310d:	e8 d9 fe ff ff       	call   80102feb <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103112:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103119:	00 
8010311a:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103121:	e8 c5 fe ff ff       	call   80102feb <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103126:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
8010312d:	00 
8010312e:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103135:	e8 b1 fe ff ff       	call   80102feb <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010313a:	90                   	nop
8010313b:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103140:	05 00 03 00 00       	add    $0x300,%eax
80103145:	8b 00                	mov    (%eax),%eax
80103147:	25 00 10 00 00       	and    $0x1000,%eax
8010314c:	85 c0                	test   %eax,%eax
8010314e:	75 eb                	jne    8010313b <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103150:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103157:	00 
80103158:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010315f:	e8 87 fe ff ff       	call   80102feb <lapicw>
80103164:	eb 01                	jmp    80103167 <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
80103166:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80103167:	c9                   	leave  
80103168:	c3                   	ret    

80103169 <cpunum>:

int
cpunum(void)
{
80103169:	55                   	push   %ebp
8010316a:	89 e5                	mov    %esp,%ebp
8010316c:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
8010316f:	e8 62 fe ff ff       	call   80102fd6 <readeflags>
80103174:	25 00 02 00 00       	and    $0x200,%eax
80103179:	85 c0                	test   %eax,%eax
8010317b:	74 29                	je     801031a6 <cpunum+0x3d>
    static int n;
    if(n++ == 0)
8010317d:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80103182:	85 c0                	test   %eax,%eax
80103184:	0f 94 c2             	sete   %dl
80103187:	83 c0 01             	add    $0x1,%eax
8010318a:	a3 40 b6 10 80       	mov    %eax,0x8010b640
8010318f:	84 d2                	test   %dl,%dl
80103191:	74 13                	je     801031a6 <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
80103193:	8b 45 04             	mov    0x4(%ebp),%eax
80103196:	89 44 24 04          	mov    %eax,0x4(%esp)
8010319a:	c7 04 24 28 8a 10 80 	movl   $0x80108a28,(%esp)
801031a1:	e8 fb d1 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
801031a6:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031ab:	85 c0                	test   %eax,%eax
801031ad:	74 0f                	je     801031be <cpunum+0x55>
    return lapic[ID]>>24;
801031af:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031b4:	83 c0 20             	add    $0x20,%eax
801031b7:	8b 00                	mov    (%eax),%eax
801031b9:	c1 e8 18             	shr    $0x18,%eax
801031bc:	eb 05                	jmp    801031c3 <cpunum+0x5a>
  return 0;
801031be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801031c3:	c9                   	leave  
801031c4:	c3                   	ret    

801031c5 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801031c5:	55                   	push   %ebp
801031c6:	89 e5                	mov    %esp,%ebp
801031c8:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801031cb:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
801031d0:	85 c0                	test   %eax,%eax
801031d2:	74 14                	je     801031e8 <lapiceoi+0x23>
    lapicw(EOI, 0);
801031d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031db:	00 
801031dc:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801031e3:	e8 03 fe ff ff       	call   80102feb <lapicw>
}
801031e8:	c9                   	leave  
801031e9:	c3                   	ret    

801031ea <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801031ea:	55                   	push   %ebp
801031eb:	89 e5                	mov    %esp,%ebp
}
801031ed:	5d                   	pop    %ebp
801031ee:	c3                   	ret    

801031ef <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801031ef:	55                   	push   %ebp
801031f0:	89 e5                	mov    %esp,%ebp
801031f2:	83 ec 1c             	sub    $0x1c,%esp
801031f5:	8b 45 08             	mov    0x8(%ebp),%eax
801031f8:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
801031fb:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103202:	00 
80103203:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010320a:	e8 a9 fd ff ff       	call   80102fb8 <outb>
  outb(IO_RTC+1, 0x0A);
8010320f:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103216:	00 
80103217:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010321e:	e8 95 fd ff ff       	call   80102fb8 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103223:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010322a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010322d:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103232:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103235:	8d 50 02             	lea    0x2(%eax),%edx
80103238:	8b 45 0c             	mov    0xc(%ebp),%eax
8010323b:	c1 e8 04             	shr    $0x4,%eax
8010323e:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103241:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103245:	c1 e0 18             	shl    $0x18,%eax
80103248:	89 44 24 04          	mov    %eax,0x4(%esp)
8010324c:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103253:	e8 93 fd ff ff       	call   80102feb <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103258:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
8010325f:	00 
80103260:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103267:	e8 7f fd ff ff       	call   80102feb <lapicw>
  microdelay(200);
8010326c:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103273:	e8 72 ff ff ff       	call   801031ea <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103278:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
8010327f:	00 
80103280:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103287:	e8 5f fd ff ff       	call   80102feb <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010328c:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103293:	e8 52 ff ff ff       	call   801031ea <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103298:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010329f:	eb 40                	jmp    801032e1 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801032a1:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032a5:	c1 e0 18             	shl    $0x18,%eax
801032a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801032ac:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032b3:	e8 33 fd ff ff       	call   80102feb <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801032b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801032bb:	c1 e8 0c             	shr    $0xc,%eax
801032be:	80 cc 06             	or     $0x6,%ah
801032c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801032c5:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032cc:	e8 1a fd ff ff       	call   80102feb <lapicw>
    microdelay(200);
801032d1:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032d8:	e8 0d ff ff ff       	call   801031ea <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801032dd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801032e1:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801032e5:	7e ba                	jle    801032a1 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801032e7:	c9                   	leave  
801032e8:	c3                   	ret    
801032e9:	00 00                	add    %al,(%eax)
	...

801032ec <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
801032ec:	55                   	push   %ebp
801032ed:	89 e5                	mov    %esp,%ebp
801032ef:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032f2:	c7 44 24 04 54 8a 10 	movl   $0x80108a54,0x4(%esp)
801032f9:	80 
801032fa:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103301:	e8 78 1e 00 00       	call   8010517e <initlock>
  readsb(ROOTDEV, &sb);
80103306:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103309:	89 44 24 04          	mov    %eax,0x4(%esp)
8010330d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103314:	e8 af e2 ff ff       	call   801015c8 <readsb>
  log.start = sb.size - sb.nlog;
80103319:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010331c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010331f:	89 d1                	mov    %edx,%ecx
80103321:	29 c1                	sub    %eax,%ecx
80103323:	89 c8                	mov    %ecx,%eax
80103325:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
8010332a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010332d:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
80103332:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
80103339:	00 00 00 
  recover_from_log();
8010333c:	e8 97 01 00 00       	call   801034d8 <recover_from_log>
}
80103341:	c9                   	leave  
80103342:	c3                   	ret    

80103343 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103343:	55                   	push   %ebp
80103344:	89 e5                	mov    %esp,%ebp
80103346:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103349:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103350:	e9 89 00 00 00       	jmp    801033de <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103355:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
8010335a:	03 45 f4             	add    -0xc(%ebp),%eax
8010335d:	83 c0 01             	add    $0x1,%eax
80103360:	89 c2                	mov    %eax,%edx
80103362:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103367:	89 54 24 04          	mov    %edx,0x4(%esp)
8010336b:	89 04 24             	mov    %eax,(%esp)
8010336e:	e8 33 ce ff ff       	call   801001a6 <bread>
80103373:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
80103376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103379:	83 c0 10             	add    $0x10,%eax
8010337c:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
80103383:	89 c2                	mov    %eax,%edx
80103385:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
8010338a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010338e:	89 04 24             	mov    %eax,(%esp)
80103391:	e8 10 ce ff ff       	call   801001a6 <bread>
80103396:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103399:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010339c:	8d 50 18             	lea    0x18(%eax),%edx
8010339f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033a2:	83 c0 18             	add    $0x18,%eax
801033a5:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801033ac:	00 
801033ad:	89 54 24 04          	mov    %edx,0x4(%esp)
801033b1:	89 04 24             	mov    %eax,(%esp)
801033b4:	e8 08 21 00 00       	call   801054c1 <memmove>
    bwrite(dbuf);  // write dst to disk
801033b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033bc:	89 04 24             	mov    %eax,(%esp)
801033bf:	e8 19 ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801033c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033c7:	89 04 24             	mov    %eax,(%esp)
801033ca:	e8 48 ce ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801033cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033d2:	89 04 24             	mov    %eax,(%esp)
801033d5:	e8 3d ce ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033da:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033de:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801033e3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033e6:	0f 8f 69 ff ff ff    	jg     80103355 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801033ec:	c9                   	leave  
801033ed:	c3                   	ret    

801033ee <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033ee:	55                   	push   %ebp
801033ef:	89 e5                	mov    %esp,%ebp
801033f1:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033f4:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801033f9:	89 c2                	mov    %eax,%edx
801033fb:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103400:	89 54 24 04          	mov    %edx,0x4(%esp)
80103404:	89 04 24             	mov    %eax,(%esp)
80103407:	e8 9a cd ff ff       	call   801001a6 <bread>
8010340c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010340f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103412:	83 c0 18             	add    $0x18,%eax
80103415:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103418:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010341b:	8b 00                	mov    (%eax),%eax
8010341d:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
80103422:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103429:	eb 1b                	jmp    80103446 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
8010342b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010342e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103431:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103435:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103438:	83 c2 10             	add    $0x10,%edx
8010343b:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103442:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103446:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010344b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010344e:	7f db                	jg     8010342b <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103450:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103453:	89 04 24             	mov    %eax,(%esp)
80103456:	e8 bc cd ff ff       	call   80100217 <brelse>
}
8010345b:	c9                   	leave  
8010345c:	c3                   	ret    

8010345d <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010345d:	55                   	push   %ebp
8010345e:	89 e5                	mov    %esp,%ebp
80103460:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103463:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103468:	89 c2                	mov    %eax,%edx
8010346a:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
8010346f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103473:	89 04 24             	mov    %eax,(%esp)
80103476:	e8 2b cd ff ff       	call   801001a6 <bread>
8010347b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010347e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103481:	83 c0 18             	add    $0x18,%eax
80103484:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103487:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
8010348d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103490:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103492:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103499:	eb 1b                	jmp    801034b6 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
8010349b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010349e:	83 c0 10             	add    $0x10,%eax
801034a1:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
801034a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034ae:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034b6:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801034bb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034be:	7f db                	jg     8010349b <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801034c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034c3:	89 04 24             	mov    %eax,(%esp)
801034c6:	e8 12 cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
801034cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ce:	89 04 24             	mov    %eax,(%esp)
801034d1:	e8 41 cd ff ff       	call   80100217 <brelse>
}
801034d6:	c9                   	leave  
801034d7:	c3                   	ret    

801034d8 <recover_from_log>:

static void
recover_from_log(void)
{
801034d8:	55                   	push   %ebp
801034d9:	89 e5                	mov    %esp,%ebp
801034db:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801034de:	e8 0b ff ff ff       	call   801033ee <read_head>
  install_trans(); // if committed, copy from log to disk
801034e3:	e8 5b fe ff ff       	call   80103343 <install_trans>
  log.lh.n = 0;
801034e8:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
801034ef:	00 00 00 
  write_head(); // clear the log
801034f2:	e8 66 ff ff ff       	call   8010345d <write_head>
}
801034f7:	c9                   	leave  
801034f8:	c3                   	ret    

801034f9 <begin_trans>:

void
begin_trans(void)
{
801034f9:	55                   	push   %ebp
801034fa:	89 e5                	mov    %esp,%ebp
801034fc:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801034ff:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103506:	e8 94 1c 00 00       	call   8010519f <acquire>
  while (log.busy) {
8010350b:	eb 14                	jmp    80103521 <begin_trans+0x28>
    sleep(&log, &log.lock);
8010350d:	c7 44 24 04 a0 f8 10 	movl   $0x8010f8a0,0x4(%esp)
80103514:	80 
80103515:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010351c:	e8 e9 18 00 00       	call   80104e0a <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
80103521:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103526:	85 c0                	test   %eax,%eax
80103528:	75 e3                	jne    8010350d <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
8010352a:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
80103531:	00 00 00 
  release(&log.lock);
80103534:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010353b:	e8 c1 1c 00 00       	call   80105201 <release>
}
80103540:	c9                   	leave  
80103541:	c3                   	ret    

80103542 <commit_trans>:

void
commit_trans(void)
{
80103542:	55                   	push   %ebp
80103543:	89 e5                	mov    %esp,%ebp
80103545:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
80103548:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010354d:	85 c0                	test   %eax,%eax
8010354f:	7e 19                	jle    8010356a <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
80103551:	e8 07 ff ff ff       	call   8010345d <write_head>
    install_trans(); // Now install writes to home locations
80103556:	e8 e8 fd ff ff       	call   80103343 <install_trans>
    log.lh.n = 0; 
8010355b:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
80103562:	00 00 00 
    write_head();    // Erase the transaction from the log
80103565:	e8 f3 fe ff ff       	call   8010345d <write_head>
  }
  
  acquire(&log.lock);
8010356a:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103571:	e8 29 1c 00 00       	call   8010519f <acquire>
  log.busy = 0;
80103576:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
8010357d:	00 00 00 
  wakeup(&log);
80103580:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103587:	e8 5a 19 00 00       	call   80104ee6 <wakeup>
  release(&log.lock);
8010358c:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103593:	e8 69 1c 00 00       	call   80105201 <release>
}
80103598:	c9                   	leave  
80103599:	c3                   	ret    

8010359a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010359a:	55                   	push   %ebp
8010359b:	89 e5                	mov    %esp,%ebp
8010359d:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801035a0:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035a5:	83 f8 09             	cmp    $0x9,%eax
801035a8:	7f 12                	jg     801035bc <log_write+0x22>
801035aa:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801035af:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
801035b5:	83 ea 01             	sub    $0x1,%edx
801035b8:	39 d0                	cmp    %edx,%eax
801035ba:	7c 0c                	jl     801035c8 <log_write+0x2e>
    panic("too big a transaction");
801035bc:	c7 04 24 58 8a 10 80 	movl   $0x80108a58,(%esp)
801035c3:	e8 75 cf ff ff       	call   8010053d <panic>
  if (!log.busy)
801035c8:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
801035cd:	85 c0                	test   %eax,%eax
801035cf:	75 0c                	jne    801035dd <log_write+0x43>
    panic("write outside of trans");
801035d1:	c7 04 24 6e 8a 10 80 	movl   $0x80108a6e,(%esp)
801035d8:	e8 60 cf ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
801035dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035e4:	eb 1d                	jmp    80103603 <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
801035e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035e9:	83 c0 10             	add    $0x10,%eax
801035ec:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
801035f3:	89 c2                	mov    %eax,%edx
801035f5:	8b 45 08             	mov    0x8(%ebp),%eax
801035f8:	8b 40 08             	mov    0x8(%eax),%eax
801035fb:	39 c2                	cmp    %eax,%edx
801035fd:	74 10                	je     8010360f <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
801035ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103603:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103608:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010360b:	7f d9                	jg     801035e6 <log_write+0x4c>
8010360d:	eb 01                	jmp    80103610 <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
8010360f:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103610:	8b 45 08             	mov    0x8(%ebp),%eax
80103613:	8b 40 08             	mov    0x8(%eax),%eax
80103616:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103619:	83 c2 10             	add    $0x10,%edx
8010361c:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
80103623:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103628:	03 45 f4             	add    -0xc(%ebp),%eax
8010362b:	83 c0 01             	add    $0x1,%eax
8010362e:	89 c2                	mov    %eax,%edx
80103630:	8b 45 08             	mov    0x8(%ebp),%eax
80103633:	8b 40 04             	mov    0x4(%eax),%eax
80103636:	89 54 24 04          	mov    %edx,0x4(%esp)
8010363a:	89 04 24             	mov    %eax,(%esp)
8010363d:	e8 64 cb ff ff       	call   801001a6 <bread>
80103642:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
80103645:	8b 45 08             	mov    0x8(%ebp),%eax
80103648:	8d 50 18             	lea    0x18(%eax),%edx
8010364b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010364e:	83 c0 18             	add    $0x18,%eax
80103651:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103658:	00 
80103659:	89 54 24 04          	mov    %edx,0x4(%esp)
8010365d:	89 04 24             	mov    %eax,(%esp)
80103660:	e8 5c 1e 00 00       	call   801054c1 <memmove>
  bwrite(lbuf);
80103665:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103668:	89 04 24             	mov    %eax,(%esp)
8010366b:	e8 6d cb ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
80103670:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103673:	89 04 24             	mov    %eax,(%esp)
80103676:	e8 9c cb ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
8010367b:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103680:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103683:	75 0d                	jne    80103692 <log_write+0xf8>
    log.lh.n++;
80103685:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010368a:	83 c0 01             	add    $0x1,%eax
8010368d:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
80103692:	8b 45 08             	mov    0x8(%ebp),%eax
80103695:	8b 00                	mov    (%eax),%eax
80103697:	89 c2                	mov    %eax,%edx
80103699:	83 ca 04             	or     $0x4,%edx
8010369c:	8b 45 08             	mov    0x8(%ebp),%eax
8010369f:	89 10                	mov    %edx,(%eax)
}
801036a1:	c9                   	leave  
801036a2:	c3                   	ret    
	...

801036a4 <v2p>:
801036a4:	55                   	push   %ebp
801036a5:	89 e5                	mov    %esp,%ebp
801036a7:	8b 45 08             	mov    0x8(%ebp),%eax
801036aa:	05 00 00 00 80       	add    $0x80000000,%eax
801036af:	5d                   	pop    %ebp
801036b0:	c3                   	ret    

801036b1 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801036b1:	55                   	push   %ebp
801036b2:	89 e5                	mov    %esp,%ebp
801036b4:	8b 45 08             	mov    0x8(%ebp),%eax
801036b7:	05 00 00 00 80       	add    $0x80000000,%eax
801036bc:	5d                   	pop    %ebp
801036bd:	c3                   	ret    

801036be <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801036be:	55                   	push   %ebp
801036bf:	89 e5                	mov    %esp,%ebp
801036c1:	53                   	push   %ebx
801036c2:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
801036c5:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801036c8:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
801036cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801036ce:	89 c3                	mov    %eax,%ebx
801036d0:	89 d8                	mov    %ebx,%eax
801036d2:	f0 87 02             	lock xchg %eax,(%edx)
801036d5:	89 c3                	mov    %eax,%ebx
801036d7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801036da:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801036dd:	83 c4 10             	add    $0x10,%esp
801036e0:	5b                   	pop    %ebx
801036e1:	5d                   	pop    %ebp
801036e2:	c3                   	ret    

801036e3 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801036e3:	55                   	push   %ebp
801036e4:	89 e5                	mov    %esp,%ebp
801036e6:	83 e4 f0             	and    $0xfffffff0,%esp
801036e9:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801036ec:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801036f3:	80 
801036f4:	c7 04 24 1c 2e 11 80 	movl   $0x80112e1c,(%esp)
801036fb:	e8 ad f5 ff ff       	call   80102cad <kinit1>
  kvmalloc();      // kernel page table
80103700:	e8 ad 49 00 00       	call   801080b2 <kvmalloc>
  mpinit();        // collect info about this machine
80103705:	e8 63 04 00 00       	call   80103b6d <mpinit>
  lapicinit(mpbcpu());
8010370a:	e8 2e 02 00 00       	call   8010393d <mpbcpu>
8010370f:	89 04 24             	mov    %eax,(%esp)
80103712:	e8 f5 f8 ff ff       	call   8010300c <lapicinit>
  seginit();       // set up segments
80103717:	e8 39 43 00 00       	call   80107a55 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
8010371c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103722:	0f b6 00             	movzbl (%eax),%eax
80103725:	0f b6 c0             	movzbl %al,%eax
80103728:	89 44 24 04          	mov    %eax,0x4(%esp)
8010372c:	c7 04 24 85 8a 10 80 	movl   $0x80108a85,(%esp)
80103733:	e8 69 cc ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
80103738:	e8 95 06 00 00       	call   80103dd2 <picinit>
  ioapicinit();    // another interrupt controller
8010373d:	e8 5b f4 ff ff       	call   80102b9d <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103742:	e8 21 d6 ff ff       	call   80100d68 <consoleinit>
  uartinit();      // serial port
80103747:	e8 54 36 00 00       	call   80106da0 <uartinit>
  pinit();         // process table
8010374c:	e8 96 0b 00 00       	call   801042e7 <pinit>
  tvinit();        // trap vectors
80103751:	e8 a9 31 00 00       	call   801068ff <tvinit>
  binit();         // buffer cache
80103756:	e8 d9 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010375b:	e8 7c da ff ff       	call   801011dc <fileinit>
  iinit();         // inode cache
80103760:	e8 2a e1 ff ff       	call   8010188f <iinit>
  ideinit();       // disk
80103765:	e8 98 f0 ff ff       	call   80102802 <ideinit>
  if(!ismp)
8010376a:	a1 24 f9 10 80       	mov    0x8010f924,%eax
8010376f:	85 c0                	test   %eax,%eax
80103771:	75 05                	jne    80103778 <main+0x95>
    timerinit();   // uniprocessor timer
80103773:	e8 ca 30 00 00       	call   80106842 <timerinit>
  startothers();   // start other processors
80103778:	e8 87 00 00 00       	call   80103804 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010377d:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103784:	8e 
80103785:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
8010378c:	e8 54 f5 ff ff       	call   80102ce5 <kinit2>
  userinit();      // first user process
80103791:	e8 6f 0c 00 00       	call   80104405 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103796:	e8 22 00 00 00       	call   801037bd <mpmain>

8010379b <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010379b:	55                   	push   %ebp
8010379c:	89 e5                	mov    %esp,%ebp
8010379e:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
801037a1:	e8 23 49 00 00       	call   801080c9 <switchkvm>
  seginit();
801037a6:	e8 aa 42 00 00       	call   80107a55 <seginit>
  lapicinit(cpunum());
801037ab:	e8 b9 f9 ff ff       	call   80103169 <cpunum>
801037b0:	89 04 24             	mov    %eax,(%esp)
801037b3:	e8 54 f8 ff ff       	call   8010300c <lapicinit>
  mpmain();
801037b8:	e8 00 00 00 00       	call   801037bd <mpmain>

801037bd <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801037bd:	55                   	push   %ebp
801037be:	89 e5                	mov    %esp,%ebp
801037c0:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801037c3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037c9:	0f b6 00             	movzbl (%eax),%eax
801037cc:	0f b6 c0             	movzbl %al,%eax
801037cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801037d3:	c7 04 24 9c 8a 10 80 	movl   $0x80108a9c,(%esp)
801037da:	e8 c2 cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
801037df:	e8 8f 32 00 00       	call   80106a73 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801037e4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037ea:	05 a8 00 00 00       	add    $0xa8,%eax
801037ef:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801037f6:	00 
801037f7:	89 04 24             	mov    %eax,(%esp)
801037fa:	e8 bf fe ff ff       	call   801036be <xchg>
  scheduler();     // start running processes
801037ff:	e8 ae 13 00 00       	call   80104bb2 <scheduler>

80103804 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103804:	55                   	push   %ebp
80103805:	89 e5                	mov    %esp,%ebp
80103807:	53                   	push   %ebx
80103808:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010380b:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103812:	e8 9a fe ff ff       	call   801036b1 <p2v>
80103817:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010381a:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010381f:	89 44 24 08          	mov    %eax,0x8(%esp)
80103823:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
8010382a:	80 
8010382b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010382e:	89 04 24             	mov    %eax,(%esp)
80103831:	e8 8b 1c 00 00       	call   801054c1 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103836:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
8010383d:	e9 86 00 00 00       	jmp    801038c8 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
80103842:	e8 22 f9 ff ff       	call   80103169 <cpunum>
80103847:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010384d:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103852:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103855:	74 69                	je     801038c0 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103857:	e8 7f f5 ff ff       	call   80102ddb <kalloc>
8010385c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010385f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103862:	83 e8 04             	sub    $0x4,%eax
80103865:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103868:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010386e:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103870:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103873:	83 e8 08             	sub    $0x8,%eax
80103876:	c7 00 9b 37 10 80    	movl   $0x8010379b,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010387c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010387f:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103882:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103889:	e8 16 fe ff ff       	call   801036a4 <v2p>
8010388e:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103890:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103893:	89 04 24             	mov    %eax,(%esp)
80103896:	e8 09 fe ff ff       	call   801036a4 <v2p>
8010389b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010389e:	0f b6 12             	movzbl (%edx),%edx
801038a1:	0f b6 d2             	movzbl %dl,%edx
801038a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801038a8:	89 14 24             	mov    %edx,(%esp)
801038ab:	e8 3f f9 ff ff       	call   801031ef <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801038b0:	90                   	nop
801038b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038b4:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801038ba:	85 c0                	test   %eax,%eax
801038bc:	74 f3                	je     801038b1 <startothers+0xad>
801038be:	eb 01                	jmp    801038c1 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801038c0:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801038c1:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801038c8:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
801038cd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038d3:	05 40 f9 10 80       	add    $0x8010f940,%eax
801038d8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038db:	0f 87 61 ff ff ff    	ja     80103842 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801038e1:	83 c4 24             	add    $0x24,%esp
801038e4:	5b                   	pop    %ebx
801038e5:	5d                   	pop    %ebp
801038e6:	c3                   	ret    
	...

801038e8 <p2v>:
801038e8:	55                   	push   %ebp
801038e9:	89 e5                	mov    %esp,%ebp
801038eb:	8b 45 08             	mov    0x8(%ebp),%eax
801038ee:	05 00 00 00 80       	add    $0x80000000,%eax
801038f3:	5d                   	pop    %ebp
801038f4:	c3                   	ret    

801038f5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801038f5:	55                   	push   %ebp
801038f6:	89 e5                	mov    %esp,%ebp
801038f8:	53                   	push   %ebx
801038f9:	83 ec 14             	sub    $0x14,%esp
801038fc:	8b 45 08             	mov    0x8(%ebp),%eax
801038ff:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103903:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103907:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010390b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010390f:	ec                   	in     (%dx),%al
80103910:	89 c3                	mov    %eax,%ebx
80103912:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103915:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103919:	83 c4 14             	add    $0x14,%esp
8010391c:	5b                   	pop    %ebx
8010391d:	5d                   	pop    %ebp
8010391e:	c3                   	ret    

8010391f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010391f:	55                   	push   %ebp
80103920:	89 e5                	mov    %esp,%ebp
80103922:	83 ec 08             	sub    $0x8,%esp
80103925:	8b 55 08             	mov    0x8(%ebp),%edx
80103928:	8b 45 0c             	mov    0xc(%ebp),%eax
8010392b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010392f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103932:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103936:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010393a:	ee                   	out    %al,(%dx)
}
8010393b:	c9                   	leave  
8010393c:	c3                   	ret    

8010393d <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
8010393d:	55                   	push   %ebp
8010393e:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103940:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103945:	89 c2                	mov    %eax,%edx
80103947:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
8010394c:	89 d1                	mov    %edx,%ecx
8010394e:	29 c1                	sub    %eax,%ecx
80103950:	89 c8                	mov    %ecx,%eax
80103952:	c1 f8 02             	sar    $0x2,%eax
80103955:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010395b:	5d                   	pop    %ebp
8010395c:	c3                   	ret    

8010395d <sum>:

static uchar
sum(uchar *addr, int len)
{
8010395d:	55                   	push   %ebp
8010395e:	89 e5                	mov    %esp,%ebp
80103960:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103963:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010396a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103971:	eb 13                	jmp    80103986 <sum+0x29>
    sum += addr[i];
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103976:	03 45 08             	add    0x8(%ebp),%eax
80103979:	0f b6 00             	movzbl (%eax),%eax
8010397c:	0f b6 c0             	movzbl %al,%eax
8010397f:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103982:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103986:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103989:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010398c:	7c e5                	jl     80103973 <sum+0x16>
    sum += addr[i];
  return sum;
8010398e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103991:	c9                   	leave  
80103992:	c3                   	ret    

80103993 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103993:	55                   	push   %ebp
80103994:	89 e5                	mov    %esp,%ebp
80103996:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103999:	8b 45 08             	mov    0x8(%ebp),%eax
8010399c:	89 04 24             	mov    %eax,(%esp)
8010399f:	e8 44 ff ff ff       	call   801038e8 <p2v>
801039a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801039a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801039aa:	03 45 f0             	add    -0x10(%ebp),%eax
801039ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801039b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039b6:	eb 3f                	jmp    801039f7 <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801039b8:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801039bf:	00 
801039c0:	c7 44 24 04 b0 8a 10 	movl   $0x80108ab0,0x4(%esp)
801039c7:	80 
801039c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039cb:	89 04 24             	mov    %eax,(%esp)
801039ce:	e8 92 1a 00 00       	call   80105465 <memcmp>
801039d3:	85 c0                	test   %eax,%eax
801039d5:	75 1c                	jne    801039f3 <mpsearch1+0x60>
801039d7:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801039de:	00 
801039df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039e2:	89 04 24             	mov    %eax,(%esp)
801039e5:	e8 73 ff ff ff       	call   8010395d <sum>
801039ea:	84 c0                	test   %al,%al
801039ec:	75 05                	jne    801039f3 <mpsearch1+0x60>
      return (struct mp*)p;
801039ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f1:	eb 11                	jmp    80103a04 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801039f3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801039f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039fa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801039fd:	72 b9                	jb     801039b8 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801039ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a04:	c9                   	leave  
80103a05:	c3                   	ret    

80103a06 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a06:	55                   	push   %ebp
80103a07:	89 e5                	mov    %esp,%ebp
80103a09:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a0c:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a16:	83 c0 0f             	add    $0xf,%eax
80103a19:	0f b6 00             	movzbl (%eax),%eax
80103a1c:	0f b6 c0             	movzbl %al,%eax
80103a1f:	89 c2                	mov    %eax,%edx
80103a21:	c1 e2 08             	shl    $0x8,%edx
80103a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a27:	83 c0 0e             	add    $0xe,%eax
80103a2a:	0f b6 00             	movzbl (%eax),%eax
80103a2d:	0f b6 c0             	movzbl %al,%eax
80103a30:	09 d0                	or     %edx,%eax
80103a32:	c1 e0 04             	shl    $0x4,%eax
80103a35:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103a38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103a3c:	74 21                	je     80103a5f <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103a3e:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a45:	00 
80103a46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a49:	89 04 24             	mov    %eax,(%esp)
80103a4c:	e8 42 ff ff ff       	call   80103993 <mpsearch1>
80103a51:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a54:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103a58:	74 50                	je     80103aaa <mpsearch+0xa4>
      return mp;
80103a5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a5d:	eb 5f                	jmp    80103abe <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a62:	83 c0 14             	add    $0x14,%eax
80103a65:	0f b6 00             	movzbl (%eax),%eax
80103a68:	0f b6 c0             	movzbl %al,%eax
80103a6b:	89 c2                	mov    %eax,%edx
80103a6d:	c1 e2 08             	shl    $0x8,%edx
80103a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a73:	83 c0 13             	add    $0x13,%eax
80103a76:	0f b6 00             	movzbl (%eax),%eax
80103a79:	0f b6 c0             	movzbl %al,%eax
80103a7c:	09 d0                	or     %edx,%eax
80103a7e:	c1 e0 0a             	shl    $0xa,%eax
80103a81:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a87:	2d 00 04 00 00       	sub    $0x400,%eax
80103a8c:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103a93:	00 
80103a94:	89 04 24             	mov    %eax,(%esp)
80103a97:	e8 f7 fe ff ff       	call   80103993 <mpsearch1>
80103a9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103a9f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103aa3:	74 05                	je     80103aaa <mpsearch+0xa4>
      return mp;
80103aa5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103aa8:	eb 14                	jmp    80103abe <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103aaa:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103ab1:	00 
80103ab2:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103ab9:	e8 d5 fe ff ff       	call   80103993 <mpsearch1>
}
80103abe:	c9                   	leave  
80103abf:	c3                   	ret    

80103ac0 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103ac0:	55                   	push   %ebp
80103ac1:	89 e5                	mov    %esp,%ebp
80103ac3:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103ac6:	e8 3b ff ff ff       	call   80103a06 <mpsearch>
80103acb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ace:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ad2:	74 0a                	je     80103ade <mpconfig+0x1e>
80103ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad7:	8b 40 04             	mov    0x4(%eax),%eax
80103ada:	85 c0                	test   %eax,%eax
80103adc:	75 0a                	jne    80103ae8 <mpconfig+0x28>
    return 0;
80103ade:	b8 00 00 00 00       	mov    $0x0,%eax
80103ae3:	e9 83 00 00 00       	jmp    80103b6b <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aeb:	8b 40 04             	mov    0x4(%eax),%eax
80103aee:	89 04 24             	mov    %eax,(%esp)
80103af1:	e8 f2 fd ff ff       	call   801038e8 <p2v>
80103af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103af9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b00:	00 
80103b01:	c7 44 24 04 b5 8a 10 	movl   $0x80108ab5,0x4(%esp)
80103b08:	80 
80103b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b0c:	89 04 24             	mov    %eax,(%esp)
80103b0f:	e8 51 19 00 00       	call   80105465 <memcmp>
80103b14:	85 c0                	test   %eax,%eax
80103b16:	74 07                	je     80103b1f <mpconfig+0x5f>
    return 0;
80103b18:	b8 00 00 00 00       	mov    $0x0,%eax
80103b1d:	eb 4c                	jmp    80103b6b <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b22:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b26:	3c 01                	cmp    $0x1,%al
80103b28:	74 12                	je     80103b3c <mpconfig+0x7c>
80103b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b2d:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103b31:	3c 04                	cmp    $0x4,%al
80103b33:	74 07                	je     80103b3c <mpconfig+0x7c>
    return 0;
80103b35:	b8 00 00 00 00       	mov    $0x0,%eax
80103b3a:	eb 2f                	jmp    80103b6b <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b3f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103b43:	0f b7 c0             	movzwl %ax,%eax
80103b46:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b4d:	89 04 24             	mov    %eax,(%esp)
80103b50:	e8 08 fe ff ff       	call   8010395d <sum>
80103b55:	84 c0                	test   %al,%al
80103b57:	74 07                	je     80103b60 <mpconfig+0xa0>
    return 0;
80103b59:	b8 00 00 00 00       	mov    $0x0,%eax
80103b5e:	eb 0b                	jmp    80103b6b <mpconfig+0xab>
  *pmp = mp;
80103b60:	8b 45 08             	mov    0x8(%ebp),%eax
80103b63:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b66:	89 10                	mov    %edx,(%eax)
  return conf;
80103b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103b6b:	c9                   	leave  
80103b6c:	c3                   	ret    

80103b6d <mpinit>:

void
mpinit(void)
{
80103b6d:	55                   	push   %ebp
80103b6e:	89 e5                	mov    %esp,%ebp
80103b70:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103b73:	c7 05 44 b6 10 80 40 	movl   $0x8010f940,0x8010b644
80103b7a:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103b7d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103b80:	89 04 24             	mov    %eax,(%esp)
80103b83:	e8 38 ff ff ff       	call   80103ac0 <mpconfig>
80103b88:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b8f:	0f 84 9c 01 00 00    	je     80103d31 <mpinit+0x1c4>
    return;
  ismp = 1;
80103b95:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
80103b9c:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba2:	8b 40 24             	mov    0x24(%eax),%eax
80103ba5:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bad:	83 c0 2c             	add    $0x2c,%eax
80103bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bba:	0f b7 c0             	movzwl %ax,%eax
80103bbd:	03 45 f0             	add    -0x10(%ebp),%eax
80103bc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bc3:	e9 f4 00 00 00       	jmp    80103cbc <mpinit+0x14f>
    switch(*p){
80103bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcb:	0f b6 00             	movzbl (%eax),%eax
80103bce:	0f b6 c0             	movzbl %al,%eax
80103bd1:	83 f8 04             	cmp    $0x4,%eax
80103bd4:	0f 87 bf 00 00 00    	ja     80103c99 <mpinit+0x12c>
80103bda:	8b 04 85 f8 8a 10 80 	mov    -0x7fef7508(,%eax,4),%eax
80103be1:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103be9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103bec:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103bf0:	0f b6 d0             	movzbl %al,%edx
80103bf3:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103bf8:	39 c2                	cmp    %eax,%edx
80103bfa:	74 2d                	je     80103c29 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103bfc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103bff:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c03:	0f b6 d0             	movzbl %al,%edx
80103c06:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c0b:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c13:	c7 04 24 ba 8a 10 80 	movl   $0x80108aba,(%esp)
80103c1a:	e8 82 c7 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103c1f:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103c26:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103c29:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c2c:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103c30:	0f b6 c0             	movzbl %al,%eax
80103c33:	83 e0 02             	and    $0x2,%eax
80103c36:	85 c0                	test   %eax,%eax
80103c38:	74 15                	je     80103c4f <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103c3a:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c3f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103c45:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103c4a:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103c4f:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
80103c55:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c5a:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103c60:	81 c2 40 f9 10 80    	add    $0x8010f940,%edx
80103c66:	88 02                	mov    %al,(%edx)
      ncpu++;
80103c68:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103c6d:	83 c0 01             	add    $0x1,%eax
80103c70:	a3 20 ff 10 80       	mov    %eax,0x8010ff20
      p += sizeof(struct mpproc);
80103c75:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103c79:	eb 41                	jmp    80103cbc <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103c81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c84:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c88:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
80103c8d:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c91:	eb 29                	jmp    80103cbc <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103c93:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103c97:	eb 23                	jmp    80103cbc <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9c:	0f b6 00             	movzbl (%eax),%eax
80103c9f:	0f b6 c0             	movzbl %al,%eax
80103ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ca6:	c7 04 24 d8 8a 10 80 	movl   $0x80108ad8,(%esp)
80103cad:	e8 ef c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103cb2:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103cb9:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103cc2:	0f 82 00 ff ff ff    	jb     80103bc8 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103cc8:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80103ccd:	85 c0                	test   %eax,%eax
80103ccf:	75 1d                	jne    80103cee <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103cd1:	c7 05 20 ff 10 80 01 	movl   $0x1,0x8010ff20
80103cd8:	00 00 00 
    lapic = 0;
80103cdb:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
80103ce2:	00 00 00 
    ioapicid = 0;
80103ce5:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
    return;
80103cec:	eb 44                	jmp    80103d32 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103cee:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103cf1:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103cf5:	84 c0                	test   %al,%al
80103cf7:	74 39                	je     80103d32 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103cf9:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d00:	00 
80103d01:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d08:	e8 12 fc ff ff       	call   8010391f <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d0d:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d14:	e8 dc fb ff ff       	call   801038f5 <inb>
80103d19:	83 c8 01             	or     $0x1,%eax
80103d1c:	0f b6 c0             	movzbl %al,%eax
80103d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d23:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d2a:	e8 f0 fb ff ff       	call   8010391f <outb>
80103d2f:	eb 01                	jmp    80103d32 <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103d31:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103d32:	c9                   	leave  
80103d33:	c3                   	ret    

80103d34 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d34:	55                   	push   %ebp
80103d35:	89 e5                	mov    %esp,%ebp
80103d37:	83 ec 08             	sub    $0x8,%esp
80103d3a:	8b 55 08             	mov    0x8(%ebp),%edx
80103d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d40:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103d44:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d47:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103d4b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103d4f:	ee                   	out    %al,(%dx)
}
80103d50:	c9                   	leave  
80103d51:	c3                   	ret    

80103d52 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103d52:	55                   	push   %ebp
80103d53:	89 e5                	mov    %esp,%ebp
80103d55:	83 ec 0c             	sub    $0xc,%esp
80103d58:	8b 45 08             	mov    0x8(%ebp),%eax
80103d5b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103d5f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d63:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103d69:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d6d:	0f b6 c0             	movzbl %al,%eax
80103d70:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d74:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d7b:	e8 b4 ff ff ff       	call   80103d34 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103d80:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103d84:	66 c1 e8 08          	shr    $0x8,%ax
80103d88:	0f b6 c0             	movzbl %al,%eax
80103d8b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d8f:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103d96:	e8 99 ff ff ff       	call   80103d34 <outb>
}
80103d9b:	c9                   	leave  
80103d9c:	c3                   	ret    

80103d9d <picenable>:

void
picenable(int irq)
{
80103d9d:	55                   	push   %ebp
80103d9e:	89 e5                	mov    %esp,%ebp
80103da0:	53                   	push   %ebx
80103da1:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103da4:	8b 45 08             	mov    0x8(%ebp),%eax
80103da7:	ba 01 00 00 00       	mov    $0x1,%edx
80103dac:	89 d3                	mov    %edx,%ebx
80103dae:	89 c1                	mov    %eax,%ecx
80103db0:	d3 e3                	shl    %cl,%ebx
80103db2:	89 d8                	mov    %ebx,%eax
80103db4:	89 c2                	mov    %eax,%edx
80103db6:	f7 d2                	not    %edx
80103db8:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103dbf:	21 d0                	and    %edx,%eax
80103dc1:	0f b7 c0             	movzwl %ax,%eax
80103dc4:	89 04 24             	mov    %eax,(%esp)
80103dc7:	e8 86 ff ff ff       	call   80103d52 <picsetmask>
}
80103dcc:	83 c4 04             	add    $0x4,%esp
80103dcf:	5b                   	pop    %ebx
80103dd0:	5d                   	pop    %ebp
80103dd1:	c3                   	ret    

80103dd2 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103dd2:	55                   	push   %ebp
80103dd3:	89 e5                	mov    %esp,%ebp
80103dd5:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103dd8:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ddf:	00 
80103de0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103de7:	e8 48 ff ff ff       	call   80103d34 <outb>
  outb(IO_PIC2+1, 0xFF);
80103dec:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103df3:	00 
80103df4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103dfb:	e8 34 ff ff ff       	call   80103d34 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e00:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e07:	00 
80103e08:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e0f:	e8 20 ff ff ff       	call   80103d34 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e14:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e1b:	00 
80103e1c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e23:	e8 0c ff ff ff       	call   80103d34 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103e28:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103e2f:	00 
80103e30:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e37:	e8 f8 fe ff ff       	call   80103d34 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103e3c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e43:	00 
80103e44:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e4b:	e8 e4 fe ff ff       	call   80103d34 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103e50:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e57:	00 
80103e58:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103e5f:	e8 d0 fe ff ff       	call   80103d34 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103e64:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103e6b:	00 
80103e6c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e73:	e8 bc fe ff ff       	call   80103d34 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103e78:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103e7f:	00 
80103e80:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e87:	e8 a8 fe ff ff       	call   80103d34 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103e8c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103e93:	00 
80103e94:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e9b:	e8 94 fe ff ff       	call   80103d34 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103ea0:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103ea7:	00 
80103ea8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103eaf:	e8 80 fe ff ff       	call   80103d34 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103eb4:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ebb:	00 
80103ebc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ec3:	e8 6c fe ff ff       	call   80103d34 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103ec8:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103ecf:	00 
80103ed0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103ed7:	e8 58 fe ff ff       	call   80103d34 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103edc:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ee3:	00 
80103ee4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103eeb:	e8 44 fe ff ff       	call   80103d34 <outb>

  if(irqmask != 0xFFFF)
80103ef0:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103ef7:	66 83 f8 ff          	cmp    $0xffff,%ax
80103efb:	74 12                	je     80103f0f <picinit+0x13d>
    picsetmask(irqmask);
80103efd:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f04:	0f b7 c0             	movzwl %ax,%eax
80103f07:	89 04 24             	mov    %eax,(%esp)
80103f0a:	e8 43 fe ff ff       	call   80103d52 <picsetmask>
}
80103f0f:	c9                   	leave  
80103f10:	c3                   	ret    
80103f11:	00 00                	add    %al,(%eax)
	...

80103f14 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f14:	55                   	push   %ebp
80103f15:	89 e5                	mov    %esp,%ebp
80103f17:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f21:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f2d:	8b 10                	mov    (%eax),%edx
80103f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f32:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f34:	e8 bf d2 ff ff       	call   801011f8 <filealloc>
80103f39:	8b 55 08             	mov    0x8(%ebp),%edx
80103f3c:	89 02                	mov    %eax,(%edx)
80103f3e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f41:	8b 00                	mov    (%eax),%eax
80103f43:	85 c0                	test   %eax,%eax
80103f45:	0f 84 c8 00 00 00    	je     80104013 <pipealloc+0xff>
80103f4b:	e8 a8 d2 ff ff       	call   801011f8 <filealloc>
80103f50:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f53:	89 02                	mov    %eax,(%edx)
80103f55:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f58:	8b 00                	mov    (%eax),%eax
80103f5a:	85 c0                	test   %eax,%eax
80103f5c:	0f 84 b1 00 00 00    	je     80104013 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f62:	e8 74 ee ff ff       	call   80102ddb <kalloc>
80103f67:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f6a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f6e:	0f 84 9e 00 00 00    	je     80104012 <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f77:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103f7e:	00 00 00 
  p->writeopen = 1;
80103f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f84:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103f8b:	00 00 00 
  p->nwrite = 0;
80103f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f91:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103f98:	00 00 00 
  p->nread = 0;
80103f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f9e:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103fa5:	00 00 00 
  initlock(&p->lock, "pipe");
80103fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fab:	c7 44 24 04 0c 8b 10 	movl   $0x80108b0c,0x4(%esp)
80103fb2:	80 
80103fb3:	89 04 24             	mov    %eax,(%esp)
80103fb6:	e8 c3 11 00 00       	call   8010517e <initlock>
  (*f0)->type = FD_PIPE;
80103fbb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbe:	8b 00                	mov    (%eax),%eax
80103fc0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc9:	8b 00                	mov    (%eax),%eax
80103fcb:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd2:	8b 00                	mov    (%eax),%eax
80103fd4:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103fd8:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdb:	8b 00                	mov    (%eax),%eax
80103fdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fe0:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103fe3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fe6:	8b 00                	mov    (%eax),%eax
80103fe8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ff1:	8b 00                	mov    (%eax),%eax
80103ff3:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ffa:	8b 00                	mov    (%eax),%eax
80103ffc:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104000:	8b 45 0c             	mov    0xc(%ebp),%eax
80104003:	8b 00                	mov    (%eax),%eax
80104005:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104008:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010400b:	b8 00 00 00 00       	mov    $0x0,%eax
80104010:	eb 43                	jmp    80104055 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104012:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104013:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104017:	74 0b                	je     80104024 <pipealloc+0x110>
    kfree((char*)p);
80104019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401c:	89 04 24             	mov    %eax,(%esp)
8010401f:	e8 1e ed ff ff       	call   80102d42 <kfree>
  if(*f0)
80104024:	8b 45 08             	mov    0x8(%ebp),%eax
80104027:	8b 00                	mov    (%eax),%eax
80104029:	85 c0                	test   %eax,%eax
8010402b:	74 0d                	je     8010403a <pipealloc+0x126>
    fileclose(*f0);
8010402d:	8b 45 08             	mov    0x8(%ebp),%eax
80104030:	8b 00                	mov    (%eax),%eax
80104032:	89 04 24             	mov    %eax,(%esp)
80104035:	e8 66 d2 ff ff       	call   801012a0 <fileclose>
  if(*f1)
8010403a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010403d:	8b 00                	mov    (%eax),%eax
8010403f:	85 c0                	test   %eax,%eax
80104041:	74 0d                	je     80104050 <pipealloc+0x13c>
    fileclose(*f1);
80104043:	8b 45 0c             	mov    0xc(%ebp),%eax
80104046:	8b 00                	mov    (%eax),%eax
80104048:	89 04 24             	mov    %eax,(%esp)
8010404b:	e8 50 d2 ff ff       	call   801012a0 <fileclose>
  return -1;
80104050:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104055:	c9                   	leave  
80104056:	c3                   	ret    

80104057 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104057:	55                   	push   %ebp
80104058:	89 e5                	mov    %esp,%ebp
8010405a:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
8010405d:	8b 45 08             	mov    0x8(%ebp),%eax
80104060:	89 04 24             	mov    %eax,(%esp)
80104063:	e8 37 11 00 00       	call   8010519f <acquire>
  if(writable){
80104068:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010406c:	74 1f                	je     8010408d <pipeclose+0x36>
    p->writeopen = 0;
8010406e:	8b 45 08             	mov    0x8(%ebp),%eax
80104071:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104078:	00 00 00 
    wakeup(&p->nread);
8010407b:	8b 45 08             	mov    0x8(%ebp),%eax
8010407e:	05 34 02 00 00       	add    $0x234,%eax
80104083:	89 04 24             	mov    %eax,(%esp)
80104086:	e8 5b 0e 00 00       	call   80104ee6 <wakeup>
8010408b:	eb 1d                	jmp    801040aa <pipeclose+0x53>
  } else {
    p->readopen = 0;
8010408d:	8b 45 08             	mov    0x8(%ebp),%eax
80104090:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104097:	00 00 00 
    wakeup(&p->nwrite);
8010409a:	8b 45 08             	mov    0x8(%ebp),%eax
8010409d:	05 38 02 00 00       	add    $0x238,%eax
801040a2:	89 04 24             	mov    %eax,(%esp)
801040a5:	e8 3c 0e 00 00       	call   80104ee6 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801040aa:	8b 45 08             	mov    0x8(%ebp),%eax
801040ad:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040b3:	85 c0                	test   %eax,%eax
801040b5:	75 25                	jne    801040dc <pipeclose+0x85>
801040b7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ba:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040c0:	85 c0                	test   %eax,%eax
801040c2:	75 18                	jne    801040dc <pipeclose+0x85>
    release(&p->lock);
801040c4:	8b 45 08             	mov    0x8(%ebp),%eax
801040c7:	89 04 24             	mov    %eax,(%esp)
801040ca:	e8 32 11 00 00       	call   80105201 <release>
    kfree((char*)p);
801040cf:	8b 45 08             	mov    0x8(%ebp),%eax
801040d2:	89 04 24             	mov    %eax,(%esp)
801040d5:	e8 68 ec ff ff       	call   80102d42 <kfree>
801040da:	eb 0b                	jmp    801040e7 <pipeclose+0x90>
  } else
    release(&p->lock);
801040dc:	8b 45 08             	mov    0x8(%ebp),%eax
801040df:	89 04 24             	mov    %eax,(%esp)
801040e2:	e8 1a 11 00 00       	call   80105201 <release>
}
801040e7:	c9                   	leave  
801040e8:	c3                   	ret    

801040e9 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801040e9:	55                   	push   %ebp
801040ea:	89 e5                	mov    %esp,%ebp
801040ec:	53                   	push   %ebx
801040ed:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801040f0:	8b 45 08             	mov    0x8(%ebp),%eax
801040f3:	89 04 24             	mov    %eax,(%esp)
801040f6:	e8 a4 10 00 00       	call   8010519f <acquire>
  for(i = 0; i < n; i++){
801040fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104102:	e9 a6 00 00 00       	jmp    801041ad <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104107:	8b 45 08             	mov    0x8(%ebp),%eax
8010410a:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104110:	85 c0                	test   %eax,%eax
80104112:	74 0d                	je     80104121 <pipewrite+0x38>
80104114:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010411a:	8b 40 24             	mov    0x24(%eax),%eax
8010411d:	85 c0                	test   %eax,%eax
8010411f:	74 15                	je     80104136 <pipewrite+0x4d>
        release(&p->lock);
80104121:	8b 45 08             	mov    0x8(%ebp),%eax
80104124:	89 04 24             	mov    %eax,(%esp)
80104127:	e8 d5 10 00 00       	call   80105201 <release>
        return -1;
8010412c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104131:	e9 9d 00 00 00       	jmp    801041d3 <pipewrite+0xea>
      }
      wakeup(&p->nread);
80104136:	8b 45 08             	mov    0x8(%ebp),%eax
80104139:	05 34 02 00 00       	add    $0x234,%eax
8010413e:	89 04 24             	mov    %eax,(%esp)
80104141:	e8 a0 0d 00 00       	call   80104ee6 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104146:	8b 45 08             	mov    0x8(%ebp),%eax
80104149:	8b 55 08             	mov    0x8(%ebp),%edx
8010414c:	81 c2 38 02 00 00    	add    $0x238,%edx
80104152:	89 44 24 04          	mov    %eax,0x4(%esp)
80104156:	89 14 24             	mov    %edx,(%esp)
80104159:	e8 ac 0c 00 00       	call   80104e0a <sleep>
8010415e:	eb 01                	jmp    80104161 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104160:	90                   	nop
80104161:	8b 45 08             	mov    0x8(%ebp),%eax
80104164:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010416a:	8b 45 08             	mov    0x8(%ebp),%eax
8010416d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104173:	05 00 02 00 00       	add    $0x200,%eax
80104178:	39 c2                	cmp    %eax,%edx
8010417a:	74 8b                	je     80104107 <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010417c:	8b 45 08             	mov    0x8(%ebp),%eax
8010417f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104185:	89 c3                	mov    %eax,%ebx
80104187:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
8010418d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104190:	03 55 0c             	add    0xc(%ebp),%edx
80104193:	0f b6 0a             	movzbl (%edx),%ecx
80104196:	8b 55 08             	mov    0x8(%ebp),%edx
80104199:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
8010419d:	8d 50 01             	lea    0x1(%eax),%edx
801041a0:	8b 45 08             	mov    0x8(%ebp),%eax
801041a3:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801041a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801041ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b0:	3b 45 10             	cmp    0x10(%ebp),%eax
801041b3:	7c ab                	jl     80104160 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801041b5:	8b 45 08             	mov    0x8(%ebp),%eax
801041b8:	05 34 02 00 00       	add    $0x234,%eax
801041bd:	89 04 24             	mov    %eax,(%esp)
801041c0:	e8 21 0d 00 00       	call   80104ee6 <wakeup>
  release(&p->lock);
801041c5:	8b 45 08             	mov    0x8(%ebp),%eax
801041c8:	89 04 24             	mov    %eax,(%esp)
801041cb:	e8 31 10 00 00       	call   80105201 <release>
  return n;
801041d0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801041d3:	83 c4 24             	add    $0x24,%esp
801041d6:	5b                   	pop    %ebx
801041d7:	5d                   	pop    %ebp
801041d8:	c3                   	ret    

801041d9 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801041d9:	55                   	push   %ebp
801041da:	89 e5                	mov    %esp,%ebp
801041dc:	53                   	push   %ebx
801041dd:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801041e0:	8b 45 08             	mov    0x8(%ebp),%eax
801041e3:	89 04 24             	mov    %eax,(%esp)
801041e6:	e8 b4 0f 00 00       	call   8010519f <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041eb:	eb 3a                	jmp    80104227 <piperead+0x4e>
    if(proc->killed){
801041ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041f3:	8b 40 24             	mov    0x24(%eax),%eax
801041f6:	85 c0                	test   %eax,%eax
801041f8:	74 15                	je     8010420f <piperead+0x36>
      release(&p->lock);
801041fa:	8b 45 08             	mov    0x8(%ebp),%eax
801041fd:	89 04 24             	mov    %eax,(%esp)
80104200:	e8 fc 0f 00 00       	call   80105201 <release>
      return -1;
80104205:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010420a:	e9 b6 00 00 00       	jmp    801042c5 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010420f:	8b 45 08             	mov    0x8(%ebp),%eax
80104212:	8b 55 08             	mov    0x8(%ebp),%edx
80104215:	81 c2 34 02 00 00    	add    $0x234,%edx
8010421b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010421f:	89 14 24             	mov    %edx,(%esp)
80104222:	e8 e3 0b 00 00       	call   80104e0a <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104227:	8b 45 08             	mov    0x8(%ebp),%eax
8010422a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104230:	8b 45 08             	mov    0x8(%ebp),%eax
80104233:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104239:	39 c2                	cmp    %eax,%edx
8010423b:	75 0d                	jne    8010424a <piperead+0x71>
8010423d:	8b 45 08             	mov    0x8(%ebp),%eax
80104240:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104246:	85 c0                	test   %eax,%eax
80104248:	75 a3                	jne    801041ed <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010424a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104251:	eb 49                	jmp    8010429c <piperead+0xc3>
    if(p->nread == p->nwrite)
80104253:	8b 45 08             	mov    0x8(%ebp),%eax
80104256:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010425c:	8b 45 08             	mov    0x8(%ebp),%eax
8010425f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104265:	39 c2                	cmp    %eax,%edx
80104267:	74 3d                	je     801042a6 <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104269:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426c:	89 c2                	mov    %eax,%edx
8010426e:	03 55 0c             	add    0xc(%ebp),%edx
80104271:	8b 45 08             	mov    0x8(%ebp),%eax
80104274:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010427a:	89 c3                	mov    %eax,%ebx
8010427c:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104282:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104285:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
8010428a:	88 0a                	mov    %cl,(%edx)
8010428c:	8d 50 01             	lea    0x1(%eax),%edx
8010428f:	8b 45 08             	mov    0x8(%ebp),%eax
80104292:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104298:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010429c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429f:	3b 45 10             	cmp    0x10(%ebp),%eax
801042a2:	7c af                	jl     80104253 <piperead+0x7a>
801042a4:	eb 01                	jmp    801042a7 <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
801042a6:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801042a7:	8b 45 08             	mov    0x8(%ebp),%eax
801042aa:	05 38 02 00 00       	add    $0x238,%eax
801042af:	89 04 24             	mov    %eax,(%esp)
801042b2:	e8 2f 0c 00 00       	call   80104ee6 <wakeup>
  release(&p->lock);
801042b7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ba:	89 04 24             	mov    %eax,(%esp)
801042bd:	e8 3f 0f 00 00       	call   80105201 <release>
  return i;
801042c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042c5:	83 c4 24             	add    $0x24,%esp
801042c8:	5b                   	pop    %ebx
801042c9:	5d                   	pop    %ebp
801042ca:	c3                   	ret    
	...

801042cc <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801042cc:	55                   	push   %ebp
801042cd:	89 e5                	mov    %esp,%ebp
801042cf:	53                   	push   %ebx
801042d0:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042d3:	9c                   	pushf  
801042d4:	5b                   	pop    %ebx
801042d5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
801042d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801042db:	83 c4 10             	add    $0x10,%esp
801042de:	5b                   	pop    %ebx
801042df:	5d                   	pop    %ebp
801042e0:	c3                   	ret    

801042e1 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801042e1:	55                   	push   %ebp
801042e2:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801042e4:	fb                   	sti    
}
801042e5:	5d                   	pop    %ebp
801042e6:	c3                   	ret    

801042e7 <pinit>:
extern void trapret(void);

static void wakeup1(void *chan);
void
pinit(void)
{
801042e7:	55                   	push   %ebp
801042e8:	89 e5                	mov    %esp,%ebp
801042ea:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801042ed:	c7 44 24 04 11 8b 10 	movl   $0x80108b11,0x4(%esp)
801042f4:	80 
801042f5:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801042fc:	e8 7d 0e 00 00       	call   8010517e <initlock>
}
80104301:	c9                   	leave  
80104302:	c3                   	ret    

80104303 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104303:	55                   	push   %ebp
80104304:	89 e5                	mov    %esp,%ebp
80104306:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104309:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104310:	e8 8a 0e 00 00       	call   8010519f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104315:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
8010431c:	eb 11                	jmp    8010432f <allocproc+0x2c>
    if(p->state == UNUSED)
8010431e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104321:	8b 40 0c             	mov    0xc(%eax),%eax
80104324:	85 c0                	test   %eax,%eax
80104326:	74 26                	je     8010434e <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104328:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
8010432f:	81 7d f4 74 25 11 80 	cmpl   $0x80112574,-0xc(%ebp)
80104336:	72 e6                	jb     8010431e <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104338:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010433f:	e8 bd 0e 00 00       	call   80105201 <release>
  return 0;
80104344:	b8 00 00 00 00       	mov    $0x0,%eax
80104349:	e9 b5 00 00 00       	jmp    80104403 <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
8010434e:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010434f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104352:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104359:	a1 04 b0 10 80       	mov    0x8010b004,%eax
8010435e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104361:	89 42 10             	mov    %eax,0x10(%edx)
80104364:	83 c0 01             	add    $0x1,%eax
80104367:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
8010436c:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104373:	e8 89 0e 00 00       	call   80105201 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104378:	e8 5e ea ff ff       	call   80102ddb <kalloc>
8010437d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104380:	89 42 08             	mov    %eax,0x8(%edx)
80104383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104386:	8b 40 08             	mov    0x8(%eax),%eax
80104389:	85 c0                	test   %eax,%eax
8010438b:	75 11                	jne    8010439e <allocproc+0x9b>
    p->state = UNUSED;
8010438d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104390:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104397:	b8 00 00 00 00       	mov    $0x0,%eax
8010439c:	eb 65                	jmp    80104403 <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
8010439e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a1:	8b 40 08             	mov    0x8(%eax),%eax
801043a4:	05 00 10 00 00       	add    $0x1000,%eax
801043a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043ac:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801043b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043b6:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801043b9:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801043bd:	ba b4 68 10 80       	mov    $0x801068b4,%edx
801043c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043c5:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801043c7:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801043cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801043d1:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801043d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d7:	8b 40 1c             	mov    0x1c(%eax),%eax
801043da:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801043e1:	00 
801043e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801043e9:	00 
801043ea:	89 04 24             	mov    %eax,(%esp)
801043ed:	e8 fc 0f 00 00       	call   801053ee <memset>
  p->context->eip = (uint)forkret;
801043f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f5:	8b 40 1c             	mov    0x1c(%eax),%eax
801043f8:	ba de 4d 10 80       	mov    $0x80104dde,%edx
801043fd:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104400:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104403:	c9                   	leave  
80104404:	c3                   	ret    

80104405 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104405:	55                   	push   %ebp
80104406:	89 e5                	mov    %esp,%ebp
80104408:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010440b:	e8 f3 fe ff ff       	call   80104303 <allocproc>
80104410:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104416:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm(kalloc)) == 0)
8010441b:	c7 04 24 db 2d 10 80 	movl   $0x80102ddb,(%esp)
80104422:	e8 ce 3b 00 00       	call   80107ff5 <setupkvm>
80104427:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010442a:	89 42 04             	mov    %eax,0x4(%edx)
8010442d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104430:	8b 40 04             	mov    0x4(%eax),%eax
80104433:	85 c0                	test   %eax,%eax
80104435:	75 0c                	jne    80104443 <userinit+0x3e>
    panic("userinit: out of memory?");
80104437:	c7 04 24 18 8b 10 80 	movl   $0x80108b18,(%esp)
8010443e:	e8 fa c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104443:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444b:	8b 40 04             	mov    0x4(%eax),%eax
8010444e:	89 54 24 08          	mov    %edx,0x8(%esp)
80104452:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
80104459:	80 
8010445a:	89 04 24             	mov    %eax,(%esp)
8010445d:	e8 eb 3d 00 00       	call   8010824d <inituvm>
  p->sz = PGSIZE;
80104462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104465:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010446b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446e:	8b 40 18             	mov    0x18(%eax),%eax
80104471:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104478:	00 
80104479:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104480:	00 
80104481:	89 04 24             	mov    %eax,(%esp)
80104484:	e8 65 0f 00 00       	call   801053ee <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104489:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448c:	8b 40 18             	mov    0x18(%eax),%eax
8010448f:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104498:	8b 40 18             	mov    0x18(%eax),%eax
8010449b:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801044a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a4:	8b 40 18             	mov    0x18(%eax),%eax
801044a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044aa:	8b 52 18             	mov    0x18(%edx),%edx
801044ad:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044b1:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801044b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b8:	8b 40 18             	mov    0x18(%eax),%eax
801044bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044be:	8b 52 18             	mov    0x18(%edx),%edx
801044c1:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801044c5:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801044c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044cc:	8b 40 18             	mov    0x18(%eax),%eax
801044cf:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801044d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d9:	8b 40 18             	mov    0x18(%eax),%eax
801044dc:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801044e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e6:	8b 40 18             	mov    0x18(%eax),%eax
801044e9:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801044f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f3:	83 c0 6c             	add    $0x6c,%eax
801044f6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801044fd:	00 
801044fe:	c7 44 24 04 31 8b 10 	movl   $0x80108b31,0x4(%esp)
80104505:	80 
80104506:	89 04 24             	mov    %eax,(%esp)
80104509:	e8 10 11 00 00       	call   8010561e <safestrcpy>
  p->cwd = namei("/");
8010450e:	c7 04 24 3a 8b 10 80 	movl   $0x80108b3a,(%esp)
80104515:	e8 cc e1 ff ff       	call   801026e6 <namei>
8010451a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010451d:	89 42 68             	mov    %eax,0x68(%edx)
  p->state = RUNNABLE;
80104520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104523:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
8010452a:	c9                   	leave  
8010452b:	c3                   	ret    

8010452c <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010452c:	55                   	push   %ebp
8010452d:	89 e5                	mov    %esp,%ebp
8010452f:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104532:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104538:	8b 00                	mov    (%eax),%eax
8010453a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010453d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104541:	7e 34                	jle    80104577 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104543:	8b 45 08             	mov    0x8(%ebp),%eax
80104546:	89 c2                	mov    %eax,%edx
80104548:	03 55 f4             	add    -0xc(%ebp),%edx
8010454b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104551:	8b 40 04             	mov    0x4(%eax),%eax
80104554:	89 54 24 08          	mov    %edx,0x8(%esp)
80104558:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010455b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010455f:	89 04 24             	mov    %eax,(%esp)
80104562:	e8 60 3e 00 00       	call   801083c7 <allocuvm>
80104567:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010456a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010456e:	75 41                	jne    801045b1 <growproc+0x85>
      return -1;
80104570:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104575:	eb 58                	jmp    801045cf <growproc+0xa3>
  } else if(n < 0){
80104577:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010457b:	79 34                	jns    801045b1 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010457d:	8b 45 08             	mov    0x8(%ebp),%eax
80104580:	89 c2                	mov    %eax,%edx
80104582:	03 55 f4             	add    -0xc(%ebp),%edx
80104585:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010458b:	8b 40 04             	mov    0x4(%eax),%eax
8010458e:	89 54 24 08          	mov    %edx,0x8(%esp)
80104592:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104595:	89 54 24 04          	mov    %edx,0x4(%esp)
80104599:	89 04 24             	mov    %eax,(%esp)
8010459c:	e8 00 3f 00 00       	call   801084a1 <deallocuvm>
801045a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045a8:	75 07                	jne    801045b1 <growproc+0x85>
      return -1;
801045aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045af:	eb 1e                	jmp    801045cf <growproc+0xa3>
  }
  proc->sz = sz;
801045b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ba:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801045bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045c2:	89 04 24             	mov    %eax,(%esp)
801045c5:	e8 1c 3b 00 00       	call   801080e6 <switchuvm>
  return 0;
801045ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045cf:	c9                   	leave  
801045d0:	c3                   	ret    

801045d1 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801045d1:	55                   	push   %ebp
801045d2:	89 e5                	mov    %esp,%ebp
801045d4:	57                   	push   %edi
801045d5:	56                   	push   %esi
801045d6:	53                   	push   %ebx
801045d7:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801045da:	e8 24 fd ff ff       	call   80104303 <allocproc>
801045df:	89 45 e0             	mov    %eax,-0x20(%ebp)
801045e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801045e6:	75 0a                	jne    801045f2 <fork+0x21>
    return -1;
801045e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ed:	e9 6c 01 00 00       	jmp    8010475e <fork+0x18d>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801045f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045f8:	8b 10                	mov    (%eax),%edx
801045fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104600:	8b 40 04             	mov    0x4(%eax),%eax
80104603:	89 54 24 04          	mov    %edx,0x4(%esp)
80104607:	89 04 24             	mov    %eax,(%esp)
8010460a:	e8 22 40 00 00       	call   80108631 <copyuvm>
8010460f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104612:	89 42 04             	mov    %eax,0x4(%edx)
80104615:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104618:	8b 40 04             	mov    0x4(%eax),%eax
8010461b:	85 c0                	test   %eax,%eax
8010461d:	75 2c                	jne    8010464b <fork+0x7a>
    kfree(np->kstack);
8010461f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104622:	8b 40 08             	mov    0x8(%eax),%eax
80104625:	89 04 24             	mov    %eax,(%esp)
80104628:	e8 15 e7 ff ff       	call   80102d42 <kfree>
    np->kstack = 0;
8010462d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104630:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104637:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010463a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104641:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104646:	e9 13 01 00 00       	jmp    8010475e <fork+0x18d>
  }
  np->sz = proc->sz;
8010464b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104651:	8b 10                	mov    (%eax),%edx
80104653:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104656:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104658:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010465f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104662:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104665:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104668:	8b 50 18             	mov    0x18(%eax),%edx
8010466b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104671:	8b 40 18             	mov    0x18(%eax),%eax
80104674:	89 c3                	mov    %eax,%ebx
80104676:	b8 13 00 00 00       	mov    $0x13,%eax
8010467b:	89 d7                	mov    %edx,%edi
8010467d:	89 de                	mov    %ebx,%esi
8010467f:	89 c1                	mov    %eax,%ecx
80104681:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104683:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104686:	8b 40 18             	mov    0x18(%eax),%eax
80104689:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104690:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104697:	eb 3d                	jmp    801046d6 <fork+0x105>
    if(proc->ofile[i])
80104699:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010469f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046a2:	83 c2 08             	add    $0x8,%edx
801046a5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046a9:	85 c0                	test   %eax,%eax
801046ab:	74 25                	je     801046d2 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801046ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046b6:	83 c2 08             	add    $0x8,%edx
801046b9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046bd:	89 04 24             	mov    %eax,(%esp)
801046c0:	e8 93 cb ff ff       	call   80101258 <filedup>
801046c5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046c8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801046cb:	83 c1 08             	add    $0x8,%ecx
801046ce:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801046d2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801046d6:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801046da:	7e bd                	jle    80104699 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801046dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e2:	8b 40 68             	mov    0x68(%eax),%eax
801046e5:	89 04 24             	mov    %eax,(%esp)
801046e8:	e8 25 d4 ff ff       	call   80101b12 <idup>
801046ed:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046f0:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
801046f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f6:	8b 40 10             	mov    0x10(%eax),%eax
801046f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
801046fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ff:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104706:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010470c:	8d 50 6c             	lea    0x6c(%eax),%edx
8010470f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104712:	83 c0 6c             	add    $0x6c,%eax
80104715:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010471c:	00 
8010471d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104721:	89 04 24             	mov    %eax,(%esp)
80104724:	e8 f5 0e 00 00       	call   8010561e <safestrcpy>
  acquire(&tickslock);
80104729:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80104730:	e8 6a 0a 00 00       	call   8010519f <acquire>
  np->ctime = ticks;			// set creation time 
80104735:	a1 c0 2d 11 80       	mov    0x80112dc0,%eax
8010473a:	89 c2                	mov    %eax,%edx
8010473c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010473f:	89 50 7c             	mov    %edx,0x7c(%eax)
  release(&tickslock);
80104742:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80104749:	e8 b3 0a 00 00       	call   80105201 <release>
  np->rtime = 0;			// init running time
8010474e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104751:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104758:	00 00 00 
    case _3Q:
      np->priority = HIGH;		// upon creation, process's priority is HIGH
      np->qvalue = 0;
      break;
  }
  return pid;
8010475b:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010475e:	83 c4 2c             	add    $0x2c,%esp
80104761:	5b                   	pop    %ebx
80104762:	5e                   	pop    %esi
80104763:	5f                   	pop    %edi
80104764:	5d                   	pop    %ebp
80104765:	c3                   	ret    

80104766 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104766:	55                   	push   %ebp
80104767:	89 e5                	mov    %esp,%ebp
80104769:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;
  
  if(proc == initproc)
8010476c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104773:	a1 48 b6 10 80       	mov    0x8010b648,%eax
80104778:	39 c2                	cmp    %eax,%edx
8010477a:	75 0c                	jne    80104788 <exit+0x22>
    panic("init exiting");
8010477c:	c7 04 24 3c 8b 10 80 	movl   $0x80108b3c,(%esp)
80104783:	e8 b5 bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104788:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010478f:	eb 44                	jmp    801047d5 <exit+0x6f>
    if(proc->ofile[fd]){
80104791:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104797:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010479a:	83 c2 08             	add    $0x8,%edx
8010479d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047a1:	85 c0                	test   %eax,%eax
801047a3:	74 2c                	je     801047d1 <exit+0x6b>
      fileclose(proc->ofile[fd]);
801047a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047ae:	83 c2 08             	add    $0x8,%edx
801047b1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047b5:	89 04 24             	mov    %eax,(%esp)
801047b8:	e8 e3 ca ff ff       	call   801012a0 <fileclose>
      proc->ofile[fd] = 0;
801047bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047c6:	83 c2 08             	add    $0x8,%edx
801047c9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801047d0:	00 
  
  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047d1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801047d5:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801047d9:	7e b6                	jle    80104791 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
801047db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047e1:	8b 40 68             	mov    0x68(%eax),%eax
801047e4:	89 04 24             	mov    %eax,(%esp)
801047e7:	e8 0b d5 ff ff       	call   80101cf7 <iput>
  proc->cwd = 0;
801047ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f2:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801047f9:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104800:	e8 9a 09 00 00       	call   8010519f <acquire>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104805:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480b:	8b 40 14             	mov    0x14(%eax),%eax
8010480e:	89 04 24             	mov    %eax,(%esp)
80104811:	e8 8f 06 00 00       	call   80104ea5 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104816:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
8010481d:	eb 3b                	jmp    8010485a <exit+0xf4>
    if(p->parent == proc){
8010481f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104822:	8b 50 14             	mov    0x14(%eax),%edx
80104825:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010482b:	39 c2                	cmp    %eax,%edx
8010482d:	75 24                	jne    80104853 <exit+0xed>
      p->parent = initproc;
8010482f:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104838:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010483b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483e:	8b 40 0c             	mov    0xc(%eax),%eax
80104841:	83 f8 05             	cmp    $0x5,%eax
80104844:	75 0d                	jne    80104853 <exit+0xed>
        wakeup1(initproc);
80104846:	a1 48 b6 10 80       	mov    0x8010b648,%eax
8010484b:	89 04 24             	mov    %eax,(%esp)
8010484e:	e8 52 06 00 00       	call   80104ea5 <wakeup1>
  
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104853:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
8010485a:	81 7d f4 74 25 11 80 	cmpl   $0x80112574,-0xc(%ebp)
80104861:	72 bc                	jb     8010481f <exit+0xb9>
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }
  // Jump into the scheduler, never to return.
  proc->priority = -1;				// clean process priority
80104863:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104869:	c7 80 8c 00 00 00 ff 	movl   $0xffffffff,0x8c(%eax)
80104870:	ff ff ff 
  acquire(&tickslock);
80104873:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
8010487a:	e8 20 09 00 00       	call   8010519f <acquire>
  proc->etime = ticks;				// set the current ticks as the process end time
8010487f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104885:	8b 15 c0 2d 11 80    	mov    0x80112dc0,%edx
8010488b:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  release(&tickslock);
80104891:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80104898:	e8 64 09 00 00       	call   80105201 <release>
  proc->state = ZOMBIE;
8010489d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048a3:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048aa:	e8 4b 04 00 00       	call   80104cfa <sched>
  panic("zombie exit");
801048af:	c7 04 24 49 8b 10 80 	movl   $0x80108b49,(%esp)
801048b6:	e8 82 bc ff ff       	call   8010053d <panic>

801048bb <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801048bb:	55                   	push   %ebp
801048bc:	89 e5                	mov    %esp,%ebp
801048be:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801048c1:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801048c8:	e8 d2 08 00 00       	call   8010519f <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801048cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048d4:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
801048db:	e9 9d 00 00 00       	jmp    8010497d <wait+0xc2>
      if(p->parent != proc)
801048e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e3:	8b 50 14             	mov    0x14(%eax),%edx
801048e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ec:	39 c2                	cmp    %eax,%edx
801048ee:	0f 85 81 00 00 00    	jne    80104975 <wait+0xba>
        continue;
      havekids = 1;
801048f4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801048fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fe:	8b 40 0c             	mov    0xc(%eax),%eax
80104901:	83 f8 05             	cmp    $0x5,%eax
80104904:	75 70                	jne    80104976 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104909:	8b 40 10             	mov    0x10(%eax),%eax
8010490c:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010490f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104912:	8b 40 08             	mov    0x8(%eax),%eax
80104915:	89 04 24             	mov    %eax,(%esp)
80104918:	e8 25 e4 ff ff       	call   80102d42 <kfree>
        p->kstack = 0;
8010491d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104920:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492a:	8b 40 04             	mov    0x4(%eax),%eax
8010492d:	89 04 24             	mov    %eax,(%esp)
80104930:	e8 28 3c 00 00       	call   8010855d <freevm>
        p->state = UNUSED;
80104935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104938:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010493f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104942:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104956:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010495a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104964:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010496b:	e8 91 08 00 00       	call   80105201 <release>
        return pid;
80104970:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104973:	eb 56                	jmp    801049cb <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104975:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104976:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
8010497d:	81 7d f4 74 25 11 80 	cmpl   $0x80112574,-0xc(%ebp)
80104984:	0f 82 56 ff ff ff    	jb     801048e0 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
8010498a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010498e:	74 0d                	je     8010499d <wait+0xe2>
80104990:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104996:	8b 40 24             	mov    0x24(%eax),%eax
80104999:	85 c0                	test   %eax,%eax
8010499b:	74 13                	je     801049b0 <wait+0xf5>
      release(&ptable.lock);
8010499d:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801049a4:	e8 58 08 00 00       	call   80105201 <release>
      return -1;
801049a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049ae:	eb 1b                	jmp    801049cb <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801049b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b6:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
801049bd:	80 
801049be:	89 04 24             	mov    %eax,(%esp)
801049c1:	e8 44 04 00 00       	call   80104e0a <sleep>
  }
801049c6:	e9 02 ff ff ff       	jmp    801048cd <wait+0x12>
}
801049cb:	c9                   	leave  
801049cc:	c3                   	ret    

801049cd <wait2>:

int
wait2(int *wtime, int *rtime)
{
801049cd:	55                   	push   %ebp
801049ce:	89 e5                	mov    %esp,%ebp
801049d0:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801049d3:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801049da:	e8 c0 07 00 00       	call   8010519f <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801049df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049e6:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
801049ed:	e9 d0 00 00 00       	jmp    80104ac2 <wait2+0xf5>
      if(p->parent != proc)
801049f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f5:	8b 50 14             	mov    0x14(%eax),%edx
801049f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049fe:	39 c2                	cmp    %eax,%edx
80104a00:	0f 85 b4 00 00 00    	jne    80104aba <wait2+0xed>
        continue;
      havekids = 1;
80104a06:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a10:	8b 40 0c             	mov    0xc(%eax),%eax
80104a13:	83 f8 05             	cmp    $0x5,%eax
80104a16:	0f 85 9f 00 00 00    	jne    80104abb <wait2+0xee>
	*rtime = p->rtime;				// sets rtime & wtime, the running and waiting pointers
80104a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1f:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104a25:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a28:	89 10                	mov    %edx,(%eax)
	*wtime = p->etime - p->ctime - p->rtime;	// rtime is the current process runtime and etime is the time the process waited since his 								// creation
80104a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2d:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a36:	8b 40 7c             	mov    0x7c(%eax),%eax
80104a39:	29 c2                	sub    %eax,%edx
80104a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3e:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104a44:	29 c2                	sub    %eax,%edx
80104a46:	8b 45 08             	mov    0x8(%ebp),%eax
80104a49:	89 10                	mov    %edx,(%eax)
	// Found one.
        pid = p->pid;
80104a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4e:	8b 40 10             	mov    0x10(%eax),%eax
80104a51:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a57:	8b 40 08             	mov    0x8(%eax),%eax
80104a5a:	89 04 24             	mov    %eax,(%esp)
80104a5d:	e8 e0 e2 ff ff       	call   80102d42 <kfree>
        p->kstack = 0;
80104a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a65:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a6f:	8b 40 04             	mov    0x4(%eax),%eax
80104a72:	89 04 24             	mov    %eax,(%esp)
80104a75:	e8 e3 3a 00 00       	call   8010855d <freevm>
        p->state = UNUSED;
80104a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a87:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a91:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa2:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104aa9:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ab0:	e8 4c 07 00 00       	call   80105201 <release>
        return pid;
80104ab5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ab8:	eb 56                	jmp    80104b10 <wait2+0x143>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104aba:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104abb:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
80104ac2:	81 7d f4 74 25 11 80 	cmpl   $0x80112574,-0xc(%ebp)
80104ac9:	0f 82 23 ff ff ff    	jb     801049f2 <wait2+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104acf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ad3:	74 0d                	je     80104ae2 <wait2+0x115>
80104ad5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104adb:	8b 40 24             	mov    0x24(%eax),%eax
80104ade:	85 c0                	test   %eax,%eax
80104ae0:	74 13                	je     80104af5 <wait2+0x128>
      release(&ptable.lock);
80104ae2:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ae9:	e8 13 07 00 00       	call   80105201 <release>
      return -1;
80104aee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104af3:	eb 1b                	jmp    80104b10 <wait2+0x143>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104af5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104afb:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104b02:	80 
80104b03:	89 04 24             	mov    %eax,(%esp)
80104b06:	e8 ff 02 00 00       	call   80104e0a <sleep>
  }
80104b0b:	e9 cf fe ff ff       	jmp    801049df <wait2+0x12>
  
  
  return proc->pid;
}
80104b10:	c9                   	leave  
80104b11:	c3                   	ret    

80104b12 <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104b12:	55                   	push   %ebp
80104b13:	89 e5                	mov    %esp,%ebp
80104b15:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104b18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b1e:	8b 40 18             	mov    0x18(%eax),%eax
80104b21:	8b 40 44             	mov    0x44(%eax),%eax
80104b24:	89 c2                	mov    %eax,%edx
80104b26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b2c:	8b 40 04             	mov    0x4(%eax),%eax
80104b2f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104b33:	89 04 24             	mov    %eax,(%esp)
80104b36:	e8 07 3c 00 00       	call   80108742 <uva2ka>
80104b3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
80104b3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b44:	8b 40 18             	mov    0x18(%eax),%eax
80104b47:	8b 40 44             	mov    0x44(%eax),%eax
80104b4a:	25 ff 0f 00 00       	and    $0xfff,%eax
80104b4f:	85 c0                	test   %eax,%eax
80104b51:	75 0c                	jne    80104b5f <register_handler+0x4d>
    panic("esp_offset == 0");
80104b53:	c7 04 24 55 8b 10 80 	movl   $0x80108b55,(%esp)
80104b5a:	e8 de b9 ff ff       	call   8010053d <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
80104b5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b65:	8b 40 18             	mov    0x18(%eax),%eax
80104b68:	8b 40 44             	mov    0x44(%eax),%eax
80104b6b:	83 e8 04             	sub    $0x4,%eax
80104b6e:	25 ff 0f 00 00       	and    $0xfff,%eax
80104b73:	03 45 f4             	add    -0xc(%ebp),%eax
          = proc->tf->eip;
80104b76:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b7d:	8b 52 18             	mov    0x18(%edx),%edx
80104b80:	8b 52 38             	mov    0x38(%edx),%edx
80104b83:	89 10                	mov    %edx,(%eax)
  proc->tf->esp -= 4;
80104b85:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b8b:	8b 40 18             	mov    0x18(%eax),%eax
80104b8e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b95:	8b 52 18             	mov    0x18(%edx),%edx
80104b98:	8b 52 44             	mov    0x44(%edx),%edx
80104b9b:	83 ea 04             	sub    $0x4,%edx
80104b9e:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104ba1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba7:	8b 40 18             	mov    0x18(%eax),%eax
80104baa:	8b 55 08             	mov    0x8(%ebp),%edx
80104bad:	89 50 38             	mov    %edx,0x38(%eax)
}
80104bb0:	c9                   	leave  
80104bb1:	c3                   	ret    

80104bb2 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104bb2:	55                   	push   %ebp
80104bb3:	89 e5                	mov    %esp,%ebp
80104bb5:	83 ec 48             	sub    $0x48,%esp
  struct proc *p;
  struct proc *medium;
  struct proc *high;
  struct proc *head = 0;		// a pointer for the last low priority that was found.
80104bb8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  struct proc *t = ptable.proc;
80104bbf:	c7 45 ec 74 ff 10 80 	movl   $0x8010ff74,-0x14(%ebp)
  uint grt_min;
  
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104bc6:	e8 16 f7 ff ff       	call   801042e1 <sti>
    highflag = 0;			// Indicates wheater a high priority process was found
80104bcb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    mediumflag = 0;			// Indicates wheater a medium priority process was found
80104bd2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    lowflag = 0;			// Indicates wheater a low priority process was found
80104bd9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    frr_min = 0;			
80104be0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    grt_min = 0;
80104be7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
    
    if(head && p==head)			// if the process that was ran in the last iteration was a low priority process we're gonna 		
80104bee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104bf2:	74 17                	je     80104c0b <scheduler+0x59>
80104bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104bfa:	75 0f                	jne    80104c0b <scheduler+0x59>
      t = ++head;			// start our next iteration from the process after it the ptable
80104bfc:	81 45 f0 98 00 00 00 	addl   $0x98,-0x10(%ebp)
80104c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c06:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104c09:	eb 0c                	jmp    80104c17 <scheduler+0x65>
    else if(head)			// for the init case where head = null
80104c0b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c0f:	74 06                	je     80104c17 <scheduler+0x65>
      t = head;				// head will now point for the ptable first process
80104c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c14:	89 45 ec             	mov    %eax,-0x14(%ebp)
    
    acquire(&tickslock);
80104c17:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80104c1e:	e8 7c 05 00 00       	call   8010519f <acquire>
    currentime = ticks;			// get ticks before each iteration so that every process in the grt case we'll be calculated 
80104c23:	a1 c0 2d 11 80       	mov    0x80112dc0,%eax
80104c28:	89 45 d0             	mov    %eax,-0x30(%ebp)
    release(&tickslock);  		// according to the same tick count
80104c2b:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80104c32:	e8 ca 05 00 00       	call   80105201 <release>
    int i=0;
80104c37:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    acquire(&ptable.lock); 
80104c3e:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104c45:	e8 55 05 00 00       	call   8010519f <acquire>
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104c4a:	e9 90 00 00 00       	jmp    80104cdf <scheduler+0x12d>
    {
      if(t >= &ptable.proc[NPROC])	// if our t iteator pointer passed the last process address in the ptable we'll
80104c4f:	81 7d ec 74 25 11 80 	cmpl   $0x80112574,-0x14(%ebp)
80104c56:	72 07                	jb     80104c5f <scheduler+0xad>
	t = ptable.proc;		// reset t to point to the first process
80104c58:	c7 45 ec 74 ff 10 80 	movl   $0x8010ff74,-0x14(%ebp)
      if(t->state != RUNNABLE)
80104c5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c62:	8b 40 0c             	mov    0xc(%eax),%eax
80104c65:	83 f8 03             	cmp    $0x3,%eax
80104c68:	74 09                	je     80104c73 <scheduler+0xc1>
      {
	t++;
80104c6a:	81 45 ec 98 00 00 00 	addl   $0x98,-0x14(%ebp)
	continue;
80104c71:	eb 68                	jmp    80104cdb <scheduler+0x129>
      }
      switch(SCHEDFLAG)
      {
	default:			// the deafult RR case stayed as it was
	  p = t;
80104c73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c76:	89 45 f4             	mov    %eax,-0xc(%ebp)
	  proc = p;
80104c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7c:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
	  switchuvm(p);
80104c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c85:	89 04 24             	mov    %eax,(%esp)
80104c88:	e8 59 34 00 00       	call   801080e6 <switchuvm>
	  p->state = RUNNING;
80104c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c90:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
	  p->quanta = QUANTA;
80104c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c9a:	c7 80 88 00 00 00 05 	movl   $0x5,0x88(%eax)
80104ca1:	00 00 00 
	  swtch(&cpu->scheduler, proc->context);
80104ca4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104caa:	8b 40 1c             	mov    0x1c(%eax),%eax
80104cad:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104cb4:	83 c2 04             	add    $0x4,%edx
80104cb7:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cbb:	89 14 24             	mov    %edx,(%esp)
80104cbe:	e8 d1 09 00 00       	call   80105694 <swtch>
	  switchkvm();
80104cc3:	e8 01 34 00 00       	call   801080c9 <switchkvm>
	  // Process is done running for now.
	  // It should have changed its p->state before coming back.
	  proc = 0;
80104cc8:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104ccf:	00 00 00 00 
	  break;
80104cd3:	90                   	nop
	    lowflag = 1;
	    t->quanta = QUANTA;					// give the process quanta for his executing
	  }
	  break;
      }
      t++;
80104cd4:	81 45 ec 98 00 00 00 	addl   $0x98,-0x14(%ebp)
    acquire(&tickslock);
    currentime = ticks;			// get ticks before each iteration so that every process in the grt case we'll be calculated 
    release(&tickslock);  		// according to the same tick count
    int i=0;
    acquire(&ptable.lock); 
    for(; i<NPROC; i++)			// Loop over process table looking for process to run.
80104cdb:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80104cdf:	83 7d e8 3f          	cmpl   $0x3f,-0x18(%ebp)
80104ce3:	0f 8e 66 ff ff ff    	jle    80104c4f <scheduler+0x9d>
	// Process is done running for now.
	// It should have changed its p->state before coming back.
	proc = 0;
      }
    }
    release(&ptable.lock);
80104ce9:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104cf0:	e8 0c 05 00 00       	call   80105201 <release>
    }
80104cf5:	e9 cc fe ff ff       	jmp    80104bc6 <scheduler+0x14>

80104cfa <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104cfa:	55                   	push   %ebp
80104cfb:	89 e5                	mov    %esp,%ebp
80104cfd:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104d00:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104d07:	e8 b1 05 00 00       	call   801052bd <holding>
80104d0c:	85 c0                	test   %eax,%eax
80104d0e:	75 0c                	jne    80104d1c <sched+0x22>
    panic("sched ptable.lock");
80104d10:	c7 04 24 65 8b 10 80 	movl   $0x80108b65,(%esp)
80104d17:	e8 21 b8 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104d1c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d22:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d28:	83 f8 01             	cmp    $0x1,%eax
80104d2b:	74 0c                	je     80104d39 <sched+0x3f>
    panic("sched locks");
80104d2d:	c7 04 24 77 8b 10 80 	movl   $0x80108b77,(%esp)
80104d34:	e8 04 b8 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104d39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d3f:	8b 40 0c             	mov    0xc(%eax),%eax
80104d42:	83 f8 04             	cmp    $0x4,%eax
80104d45:	75 0c                	jne    80104d53 <sched+0x59>
    panic("sched running");
80104d47:	c7 04 24 83 8b 10 80 	movl   $0x80108b83,(%esp)
80104d4e:	e8 ea b7 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104d53:	e8 74 f5 ff ff       	call   801042cc <readeflags>
80104d58:	25 00 02 00 00       	and    $0x200,%eax
80104d5d:	85 c0                	test   %eax,%eax
80104d5f:	74 0c                	je     80104d6d <sched+0x73>
    panic("sched interruptible");
80104d61:	c7 04 24 91 8b 10 80 	movl   $0x80108b91,(%esp)
80104d68:	e8 d0 b7 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104d6d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d73:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104d79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104d7c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d82:	8b 40 04             	mov    0x4(%eax),%eax
80104d85:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d8c:	83 c2 1c             	add    $0x1c,%edx
80104d8f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d93:	89 14 24             	mov    %edx,(%esp)
80104d96:	e8 f9 08 00 00       	call   80105694 <swtch>
  cpu->intena = intena;
80104d9b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104da1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104da4:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104daa:	c9                   	leave  
80104dab:	c3                   	ret    

80104dac <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104dac:	55                   	push   %ebp
80104dad:	89 e5                	mov    %esp,%ebp
80104daf:	83 ec 18             	sub    $0x18,%esp
	proc->qvalue = ticks;
	release(&tickslock);
      }
      break;
  }
  acquire(&ptable.lock);  //DOC: yieldlock
80104db2:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104db9:	e8 e1 03 00 00       	call   8010519f <acquire>
  proc->state = RUNNABLE;
80104dbe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dc4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104dcb:	e8 2a ff ff ff       	call   80104cfa <sched>
  release(&ptable.lock);
80104dd0:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104dd7:	e8 25 04 00 00       	call   80105201 <release>
  
}
80104ddc:	c9                   	leave  
80104ddd:	c3                   	ret    

80104dde <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104dde:	55                   	push   %ebp
80104ddf:	89 e5                	mov    %esp,%ebp
80104de1:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104de4:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104deb:	e8 11 04 00 00       	call   80105201 <release>

  if (first) {
80104df0:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104df5:	85 c0                	test   %eax,%eax
80104df7:	74 0f                	je     80104e08 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104df9:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104e00:	00 00 00 
    initlog();
80104e03:	e8 e4 e4 ff ff       	call   801032ec <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104e08:	c9                   	leave  
80104e09:	c3                   	ret    

80104e0a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e0a:	55                   	push   %ebp
80104e0b:	89 e5                	mov    %esp,%ebp
80104e0d:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104e10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e16:	85 c0                	test   %eax,%eax
80104e18:	75 0c                	jne    80104e26 <sleep+0x1c>
    panic("sleep");
80104e1a:	c7 04 24 a5 8b 10 80 	movl   $0x80108ba5,(%esp)
80104e21:	e8 17 b7 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104e26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e2a:	75 0c                	jne    80104e38 <sleep+0x2e>
    panic("sleep without lk");
80104e2c:	c7 04 24 ab 8b 10 80 	movl   $0x80108bab,(%esp)
80104e33:	e8 05 b7 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e38:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104e3f:	74 17                	je     80104e58 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e41:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e48:	e8 52 03 00 00       	call   8010519f <acquire>
    release(lk);
80104e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e50:	89 04 24             	mov    %eax,(%esp)
80104e53:	e8 a9 03 00 00       	call   80105201 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104e58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e5e:	8b 55 08             	mov    0x8(%ebp),%edx
80104e61:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104e64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e6a:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104e71:	e8 84 fe ff ff       	call   80104cfa <sched>

  // Tidy up.
  proc->chan = 0;
80104e76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e7c:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e83:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104e8a:	74 17                	je     80104ea3 <sleep+0x99>
    release(&ptable.lock);
80104e8c:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104e93:	e8 69 03 00 00       	call   80105201 <release>
    acquire(lk);
80104e98:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e9b:	89 04 24             	mov    %eax,(%esp)
80104e9e:	e8 fc 02 00 00       	call   8010519f <acquire>
  }
}
80104ea3:	c9                   	leave  
80104ea4:	c3                   	ret    

80104ea5 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ea5:	55                   	push   %ebp
80104ea6:	89 e5                	mov    %esp,%ebp
80104ea8:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104eab:	c7 45 fc 74 ff 10 80 	movl   $0x8010ff74,-0x4(%ebp)
80104eb2:	eb 27                	jmp    80104edb <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104eb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eb7:	8b 40 0c             	mov    0xc(%eax),%eax
80104eba:	83 f8 02             	cmp    $0x2,%eax
80104ebd:	75 15                	jne    80104ed4 <wakeup1+0x2f>
80104ebf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ec2:	8b 40 20             	mov    0x20(%eax),%eax
80104ec5:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ec8:	75 0a                	jne    80104ed4 <wakeup1+0x2f>
    {
      p->state = RUNNABLE;
80104eca:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ecd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ed4:	81 45 fc 98 00 00 00 	addl   $0x98,-0x4(%ebp)
80104edb:	81 7d fc 74 25 11 80 	cmpl   $0x80112574,-0x4(%ebp)
80104ee2:	72 d0                	jb     80104eb4 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
    {
      p->state = RUNNABLE;
    }
}
80104ee4:	c9                   	leave  
80104ee5:	c3                   	ret    

80104ee6 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ee6:	55                   	push   %ebp
80104ee7:	89 e5                	mov    %esp,%ebp
80104ee9:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104eec:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104ef3:	e8 a7 02 00 00       	call   8010519f <acquire>
  wakeup1(chan);
80104ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80104efb:	89 04 24             	mov    %eax,(%esp)
80104efe:	e8 a2 ff ff ff       	call   80104ea5 <wakeup1>
  release(&ptable.lock);
80104f03:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f0a:	e8 f2 02 00 00       	call   80105201 <release>
}
80104f0f:	c9                   	leave  
80104f10:	c3                   	ret    

80104f11 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f11:	55                   	push   %ebp
80104f12:	89 e5                	mov    %esp,%ebp
80104f14:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f17:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f1e:	e8 7c 02 00 00       	call   8010519f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f23:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104f2a:	eb 44                	jmp    80104f70 <kill+0x5f>
    if(p->pid == pid){
80104f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f2f:	8b 40 10             	mov    0x10(%eax),%eax
80104f32:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f35:	75 32                	jne    80104f69 <kill+0x58>
      p->killed = 1;
80104f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f44:	8b 40 0c             	mov    0xc(%eax),%eax
80104f47:	83 f8 02             	cmp    $0x2,%eax
80104f4a:	75 0a                	jne    80104f56 <kill+0x45>
        p->state = RUNNABLE;
80104f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f4f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f56:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f5d:	e8 9f 02 00 00       	call   80105201 <release>
      return 0;
80104f62:	b8 00 00 00 00       	mov    $0x0,%eax
80104f67:	eb 21                	jmp    80104f8a <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f69:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
80104f70:	81 7d f4 74 25 11 80 	cmpl   $0x80112574,-0xc(%ebp)
80104f77:	72 b3                	jb     80104f2c <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104f79:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104f80:	e8 7c 02 00 00       	call   80105201 <release>
  return -1;
80104f85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f8a:	c9                   	leave  
80104f8b:	c3                   	ret    

80104f8c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f8c:	55                   	push   %ebp
80104f8d:	89 e5                	mov    %esp,%ebp
80104f8f:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f92:	c7 45 f0 74 ff 10 80 	movl   $0x8010ff74,-0x10(%ebp)
80104f99:	e9 db 00 00 00       	jmp    80105079 <procdump+0xed>
    if(p->state == UNUSED)
80104f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa1:	8b 40 0c             	mov    0xc(%eax),%eax
80104fa4:	85 c0                	test   %eax,%eax
80104fa6:	0f 84 c5 00 00 00    	je     80105071 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104faf:	8b 40 0c             	mov    0xc(%eax),%eax
80104fb2:	83 f8 05             	cmp    $0x5,%eax
80104fb5:	77 23                	ja     80104fda <procdump+0x4e>
80104fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fba:	8b 40 0c             	mov    0xc(%eax),%eax
80104fbd:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104fc4:	85 c0                	test   %eax,%eax
80104fc6:	74 12                	je     80104fda <procdump+0x4e>
      state = states[p->state];
80104fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fcb:	8b 40 0c             	mov    0xc(%eax),%eax
80104fce:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104fd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104fd8:	eb 07                	jmp    80104fe1 <procdump+0x55>
    else
      state = "???";
80104fda:	c7 45 ec bc 8b 10 80 	movl   $0x80108bbc,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe4:	8d 50 6c             	lea    0x6c(%eax),%edx
80104fe7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fea:	8b 40 10             	mov    0x10(%eax),%eax
80104fed:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104ff1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104ff4:	89 54 24 08          	mov    %edx,0x8(%esp)
80104ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ffc:	c7 04 24 c0 8b 10 80 	movl   $0x80108bc0,(%esp)
80105003:	e8 99 b3 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80105008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010500b:	8b 40 0c             	mov    0xc(%eax),%eax
8010500e:	83 f8 02             	cmp    $0x2,%eax
80105011:	75 50                	jne    80105063 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105013:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105016:	8b 40 1c             	mov    0x1c(%eax),%eax
80105019:	8b 40 0c             	mov    0xc(%eax),%eax
8010501c:	83 c0 08             	add    $0x8,%eax
8010501f:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80105022:	89 54 24 04          	mov    %edx,0x4(%esp)
80105026:	89 04 24             	mov    %eax,(%esp)
80105029:	e8 22 02 00 00       	call   80105250 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010502e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105035:	eb 1b                	jmp    80105052 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80105037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010503a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010503e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105042:	c7 04 24 c9 8b 10 80 	movl   $0x80108bc9,(%esp)
80105049:	e8 53 b3 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010504e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105052:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105056:	7f 0b                	jg     80105063 <procdump+0xd7>
80105058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010505b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010505f:	85 c0                	test   %eax,%eax
80105061:	75 d4                	jne    80105037 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105063:	c7 04 24 cd 8b 10 80 	movl   $0x80108bcd,(%esp)
8010506a:	e8 32 b3 ff ff       	call   801003a1 <cprintf>
8010506f:	eb 01                	jmp    80105072 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105071:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105072:	81 45 f0 98 00 00 00 	addl   $0x98,-0x10(%ebp)
80105079:	81 7d f0 74 25 11 80 	cmpl   $0x80112574,-0x10(%ebp)
80105080:	0f 82 18 ff ff ff    	jb     80104f9e <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105086:	c9                   	leave  
80105087:	c3                   	ret    

80105088 <nice>:

int
nice(void)
{
80105088:	55                   	push   %ebp
80105089:	89 e5                	mov    %esp,%ebp
8010508b:	83 ec 28             	sub    $0x28,%esp
  if(proc)
8010508e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105094:	85 c0                	test   %eax,%eax
80105096:	0f 84 92 00 00 00    	je     8010512e <nice+0xa6>
  {
    if(proc->priority == HIGH)		// if the process priority was HIGH we'll now set it to MEDIUM
8010509c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050a2:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801050a8:	83 f8 03             	cmp    $0x3,%eax
801050ab:	75 54                	jne    80105101 <nice+0x79>
    {
      proc->priority--;
801050ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050b3:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
801050b9:	83 ea 01             	sub    $0x1,%edx
801050bc:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      acquire(&tickslock);
801050c2:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
801050c9:	e8 d1 00 00 00       	call   8010519f <acquire>
      proc->qvalue = ticks;
801050ce:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801050d5:	a1 c0 2d 11 80       	mov    0x80112dc0,%eax
801050da:	ba 00 00 00 00       	mov    $0x0,%edx
801050df:	89 45 f0             	mov    %eax,-0x10(%ebp)
801050e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801050e5:	df 6d f0             	fildll -0x10(%ebp)
801050e8:	dd 99 90 00 00 00    	fstpl  0x90(%ecx)
      release(&tickslock);
801050ee:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
801050f5:	e8 07 01 00 00       	call   80105201 <release>
      return 0;
801050fa:	b8 00 00 00 00       	mov    $0x0,%eax
801050ff:	eb 32                	jmp    80105133 <nice+0xab>
    }
    else if(proc->priority == MEDIUM)	// if the process priority was MEDIUM we'll now set it to LOW
80105101:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105107:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
8010510d:	83 f8 02             	cmp    $0x2,%eax
80105110:	75 1c                	jne    8010512e <nice+0xa6>
    {
      proc->priority--;
80105112:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105118:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
8010511e:	83 ea 01             	sub    $0x1,%edx
80105121:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      return 0;
80105127:	b8 00 00 00 00       	mov    $0x0,%eax
8010512c:	eb 05                	jmp    80105133 <nice+0xab>
    }
    
  }
  return -1;
8010512e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105133:	c9                   	leave  
80105134:	c3                   	ret    
80105135:	00 00                	add    %al,(%eax)
	...

80105138 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105138:	55                   	push   %ebp
80105139:	89 e5                	mov    %esp,%ebp
8010513b:	53                   	push   %ebx
8010513c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010513f:	9c                   	pushf  
80105140:	5b                   	pop    %ebx
80105141:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105144:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105147:	83 c4 10             	add    $0x10,%esp
8010514a:	5b                   	pop    %ebx
8010514b:	5d                   	pop    %ebp
8010514c:	c3                   	ret    

8010514d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010514d:	55                   	push   %ebp
8010514e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105150:	fa                   	cli    
}
80105151:	5d                   	pop    %ebp
80105152:	c3                   	ret    

80105153 <sti>:

static inline void
sti(void)
{
80105153:	55                   	push   %ebp
80105154:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105156:	fb                   	sti    
}
80105157:	5d                   	pop    %ebp
80105158:	c3                   	ret    

80105159 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105159:	55                   	push   %ebp
8010515a:	89 e5                	mov    %esp,%ebp
8010515c:	53                   	push   %ebx
8010515d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105160:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105163:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80105166:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105169:	89 c3                	mov    %eax,%ebx
8010516b:	89 d8                	mov    %ebx,%eax
8010516d:	f0 87 02             	lock xchg %eax,(%edx)
80105170:	89 c3                	mov    %eax,%ebx
80105172:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105175:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105178:	83 c4 10             	add    $0x10,%esp
8010517b:	5b                   	pop    %ebx
8010517c:	5d                   	pop    %ebp
8010517d:	c3                   	ret    

8010517e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010517e:	55                   	push   %ebp
8010517f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105181:	8b 45 08             	mov    0x8(%ebp),%eax
80105184:	8b 55 0c             	mov    0xc(%ebp),%edx
80105187:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010518a:	8b 45 08             	mov    0x8(%ebp),%eax
8010518d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105193:	8b 45 08             	mov    0x8(%ebp),%eax
80105196:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010519d:	5d                   	pop    %ebp
8010519e:	c3                   	ret    

8010519f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010519f:	55                   	push   %ebp
801051a0:	89 e5                	mov    %esp,%ebp
801051a2:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801051a5:	e8 3d 01 00 00       	call   801052e7 <pushcli>
  if(holding(lk))
801051aa:	8b 45 08             	mov    0x8(%ebp),%eax
801051ad:	89 04 24             	mov    %eax,(%esp)
801051b0:	e8 08 01 00 00       	call   801052bd <holding>
801051b5:	85 c0                	test   %eax,%eax
801051b7:	74 0c                	je     801051c5 <acquire+0x26>
    panic("acquire");
801051b9:	c7 04 24 f9 8b 10 80 	movl   $0x80108bf9,(%esp)
801051c0:	e8 78 b3 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801051c5:	90                   	nop
801051c6:	8b 45 08             	mov    0x8(%ebp),%eax
801051c9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801051d0:	00 
801051d1:	89 04 24             	mov    %eax,(%esp)
801051d4:	e8 80 ff ff ff       	call   80105159 <xchg>
801051d9:	85 c0                	test   %eax,%eax
801051db:	75 e9                	jne    801051c6 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801051dd:	8b 45 08             	mov    0x8(%ebp),%eax
801051e0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801051e7:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801051ea:	8b 45 08             	mov    0x8(%ebp),%eax
801051ed:	83 c0 0c             	add    $0xc,%eax
801051f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801051f4:	8d 45 08             	lea    0x8(%ebp),%eax
801051f7:	89 04 24             	mov    %eax,(%esp)
801051fa:	e8 51 00 00 00       	call   80105250 <getcallerpcs>
}
801051ff:	c9                   	leave  
80105200:	c3                   	ret    

80105201 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105201:	55                   	push   %ebp
80105202:	89 e5                	mov    %esp,%ebp
80105204:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105207:	8b 45 08             	mov    0x8(%ebp),%eax
8010520a:	89 04 24             	mov    %eax,(%esp)
8010520d:	e8 ab 00 00 00       	call   801052bd <holding>
80105212:	85 c0                	test   %eax,%eax
80105214:	75 0c                	jne    80105222 <release+0x21>
    panic("release");
80105216:	c7 04 24 01 8c 10 80 	movl   $0x80108c01,(%esp)
8010521d:	e8 1b b3 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80105222:	8b 45 08             	mov    0x8(%ebp),%eax
80105225:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010522c:	8b 45 08             	mov    0x8(%ebp),%eax
8010522f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105236:	8b 45 08             	mov    0x8(%ebp),%eax
80105239:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105240:	00 
80105241:	89 04 24             	mov    %eax,(%esp)
80105244:	e8 10 ff ff ff       	call   80105159 <xchg>

  popcli();
80105249:	e8 e1 00 00 00       	call   8010532f <popcli>
}
8010524e:	c9                   	leave  
8010524f:	c3                   	ret    

80105250 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105250:	55                   	push   %ebp
80105251:	89 e5                	mov    %esp,%ebp
80105253:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105256:	8b 45 08             	mov    0x8(%ebp),%eax
80105259:	83 e8 08             	sub    $0x8,%eax
8010525c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010525f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105266:	eb 32                	jmp    8010529a <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105268:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010526c:	74 47                	je     801052b5 <getcallerpcs+0x65>
8010526e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105275:	76 3e                	jbe    801052b5 <getcallerpcs+0x65>
80105277:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010527b:	74 38                	je     801052b5 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010527d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105280:	c1 e0 02             	shl    $0x2,%eax
80105283:	03 45 0c             	add    0xc(%ebp),%eax
80105286:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105289:	8b 52 04             	mov    0x4(%edx),%edx
8010528c:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
8010528e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105291:	8b 00                	mov    (%eax),%eax
80105293:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105296:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010529a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010529e:	7e c8                	jle    80105268 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052a0:	eb 13                	jmp    801052b5 <getcallerpcs+0x65>
    pcs[i] = 0;
801052a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052a5:	c1 e0 02             	shl    $0x2,%eax
801052a8:	03 45 0c             	add    0xc(%ebp),%eax
801052ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052b1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052b5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052b9:	7e e7                	jle    801052a2 <getcallerpcs+0x52>
    pcs[i] = 0;
}
801052bb:	c9                   	leave  
801052bc:	c3                   	ret    

801052bd <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801052bd:	55                   	push   %ebp
801052be:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801052c0:	8b 45 08             	mov    0x8(%ebp),%eax
801052c3:	8b 00                	mov    (%eax),%eax
801052c5:	85 c0                	test   %eax,%eax
801052c7:	74 17                	je     801052e0 <holding+0x23>
801052c9:	8b 45 08             	mov    0x8(%ebp),%eax
801052cc:	8b 50 08             	mov    0x8(%eax),%edx
801052cf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052d5:	39 c2                	cmp    %eax,%edx
801052d7:	75 07                	jne    801052e0 <holding+0x23>
801052d9:	b8 01 00 00 00       	mov    $0x1,%eax
801052de:	eb 05                	jmp    801052e5 <holding+0x28>
801052e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052e5:	5d                   	pop    %ebp
801052e6:	c3                   	ret    

801052e7 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801052e7:	55                   	push   %ebp
801052e8:	89 e5                	mov    %esp,%ebp
801052ea:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801052ed:	e8 46 fe ff ff       	call   80105138 <readeflags>
801052f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801052f5:	e8 53 fe ff ff       	call   8010514d <cli>
  if(cpu->ncli++ == 0)
801052fa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105300:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105306:	85 d2                	test   %edx,%edx
80105308:	0f 94 c1             	sete   %cl
8010530b:	83 c2 01             	add    $0x1,%edx
8010530e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105314:	84 c9                	test   %cl,%cl
80105316:	74 15                	je     8010532d <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105318:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010531e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105321:	81 e2 00 02 00 00    	and    $0x200,%edx
80105327:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010532d:	c9                   	leave  
8010532e:	c3                   	ret    

8010532f <popcli>:

void
popcli(void)
{
8010532f:	55                   	push   %ebp
80105330:	89 e5                	mov    %esp,%ebp
80105332:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105335:	e8 fe fd ff ff       	call   80105138 <readeflags>
8010533a:	25 00 02 00 00       	and    $0x200,%eax
8010533f:	85 c0                	test   %eax,%eax
80105341:	74 0c                	je     8010534f <popcli+0x20>
    panic("popcli - interruptible");
80105343:	c7 04 24 09 8c 10 80 	movl   $0x80108c09,(%esp)
8010534a:	e8 ee b1 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
8010534f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105355:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010535b:	83 ea 01             	sub    $0x1,%edx
8010535e:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105364:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010536a:	85 c0                	test   %eax,%eax
8010536c:	79 0c                	jns    8010537a <popcli+0x4b>
    panic("popcli");
8010536e:	c7 04 24 20 8c 10 80 	movl   $0x80108c20,(%esp)
80105375:	e8 c3 b1 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010537a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105380:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105386:	85 c0                	test   %eax,%eax
80105388:	75 15                	jne    8010539f <popcli+0x70>
8010538a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105390:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105396:	85 c0                	test   %eax,%eax
80105398:	74 05                	je     8010539f <popcli+0x70>
    sti();
8010539a:	e8 b4 fd ff ff       	call   80105153 <sti>
}
8010539f:	c9                   	leave  
801053a0:	c3                   	ret    
801053a1:	00 00                	add    %al,(%eax)
	...

801053a4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801053a4:	55                   	push   %ebp
801053a5:	89 e5                	mov    %esp,%ebp
801053a7:	57                   	push   %edi
801053a8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801053a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053ac:	8b 55 10             	mov    0x10(%ebp),%edx
801053af:	8b 45 0c             	mov    0xc(%ebp),%eax
801053b2:	89 cb                	mov    %ecx,%ebx
801053b4:	89 df                	mov    %ebx,%edi
801053b6:	89 d1                	mov    %edx,%ecx
801053b8:	fc                   	cld    
801053b9:	f3 aa                	rep stos %al,%es:(%edi)
801053bb:	89 ca                	mov    %ecx,%edx
801053bd:	89 fb                	mov    %edi,%ebx
801053bf:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053c2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053c5:	5b                   	pop    %ebx
801053c6:	5f                   	pop    %edi
801053c7:	5d                   	pop    %ebp
801053c8:	c3                   	ret    

801053c9 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801053c9:	55                   	push   %ebp
801053ca:	89 e5                	mov    %esp,%ebp
801053cc:	57                   	push   %edi
801053cd:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801053ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053d1:	8b 55 10             	mov    0x10(%ebp),%edx
801053d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801053d7:	89 cb                	mov    %ecx,%ebx
801053d9:	89 df                	mov    %ebx,%edi
801053db:	89 d1                	mov    %edx,%ecx
801053dd:	fc                   	cld    
801053de:	f3 ab                	rep stos %eax,%es:(%edi)
801053e0:	89 ca                	mov    %ecx,%edx
801053e2:	89 fb                	mov    %edi,%ebx
801053e4:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053e7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053ea:	5b                   	pop    %ebx
801053eb:	5f                   	pop    %edi
801053ec:	5d                   	pop    %ebp
801053ed:	c3                   	ret    

801053ee <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801053ee:	55                   	push   %ebp
801053ef:	89 e5                	mov    %esp,%ebp
801053f1:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801053f4:	8b 45 08             	mov    0x8(%ebp),%eax
801053f7:	83 e0 03             	and    $0x3,%eax
801053fa:	85 c0                	test   %eax,%eax
801053fc:	75 49                	jne    80105447 <memset+0x59>
801053fe:	8b 45 10             	mov    0x10(%ebp),%eax
80105401:	83 e0 03             	and    $0x3,%eax
80105404:	85 c0                	test   %eax,%eax
80105406:	75 3f                	jne    80105447 <memset+0x59>
    c &= 0xFF;
80105408:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010540f:	8b 45 10             	mov    0x10(%ebp),%eax
80105412:	c1 e8 02             	shr    $0x2,%eax
80105415:	89 c2                	mov    %eax,%edx
80105417:	8b 45 0c             	mov    0xc(%ebp),%eax
8010541a:	89 c1                	mov    %eax,%ecx
8010541c:	c1 e1 18             	shl    $0x18,%ecx
8010541f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105422:	c1 e0 10             	shl    $0x10,%eax
80105425:	09 c1                	or     %eax,%ecx
80105427:	8b 45 0c             	mov    0xc(%ebp),%eax
8010542a:	c1 e0 08             	shl    $0x8,%eax
8010542d:	09 c8                	or     %ecx,%eax
8010542f:	0b 45 0c             	or     0xc(%ebp),%eax
80105432:	89 54 24 08          	mov    %edx,0x8(%esp)
80105436:	89 44 24 04          	mov    %eax,0x4(%esp)
8010543a:	8b 45 08             	mov    0x8(%ebp),%eax
8010543d:	89 04 24             	mov    %eax,(%esp)
80105440:	e8 84 ff ff ff       	call   801053c9 <stosl>
80105445:	eb 19                	jmp    80105460 <memset+0x72>
  } else
    stosb(dst, c, n);
80105447:	8b 45 10             	mov    0x10(%ebp),%eax
8010544a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010544e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105451:	89 44 24 04          	mov    %eax,0x4(%esp)
80105455:	8b 45 08             	mov    0x8(%ebp),%eax
80105458:	89 04 24             	mov    %eax,(%esp)
8010545b:	e8 44 ff ff ff       	call   801053a4 <stosb>
  return dst;
80105460:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105463:	c9                   	leave  
80105464:	c3                   	ret    

80105465 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105465:	55                   	push   %ebp
80105466:	89 e5                	mov    %esp,%ebp
80105468:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010546b:	8b 45 08             	mov    0x8(%ebp),%eax
8010546e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105471:	8b 45 0c             	mov    0xc(%ebp),%eax
80105474:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105477:	eb 32                	jmp    801054ab <memcmp+0x46>
    if(*s1 != *s2)
80105479:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010547c:	0f b6 10             	movzbl (%eax),%edx
8010547f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105482:	0f b6 00             	movzbl (%eax),%eax
80105485:	38 c2                	cmp    %al,%dl
80105487:	74 1a                	je     801054a3 <memcmp+0x3e>
      return *s1 - *s2;
80105489:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010548c:	0f b6 00             	movzbl (%eax),%eax
8010548f:	0f b6 d0             	movzbl %al,%edx
80105492:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105495:	0f b6 00             	movzbl (%eax),%eax
80105498:	0f b6 c0             	movzbl %al,%eax
8010549b:	89 d1                	mov    %edx,%ecx
8010549d:	29 c1                	sub    %eax,%ecx
8010549f:	89 c8                	mov    %ecx,%eax
801054a1:	eb 1c                	jmp    801054bf <memcmp+0x5a>
    s1++, s2++;
801054a3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054a7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801054ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054af:	0f 95 c0             	setne  %al
801054b2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054b6:	84 c0                	test   %al,%al
801054b8:	75 bf                	jne    80105479 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801054ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054bf:	c9                   	leave  
801054c0:	c3                   	ret    

801054c1 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801054c1:	55                   	push   %ebp
801054c2:	89 e5                	mov    %esp,%ebp
801054c4:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801054c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801054cd:	8b 45 08             	mov    0x8(%ebp),%eax
801054d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801054d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054d6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054d9:	73 54                	jae    8010552f <memmove+0x6e>
801054db:	8b 45 10             	mov    0x10(%ebp),%eax
801054de:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054e1:	01 d0                	add    %edx,%eax
801054e3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054e6:	76 47                	jbe    8010552f <memmove+0x6e>
    s += n;
801054e8:	8b 45 10             	mov    0x10(%ebp),%eax
801054eb:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801054ee:	8b 45 10             	mov    0x10(%ebp),%eax
801054f1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801054f4:	eb 13                	jmp    80105509 <memmove+0x48>
      *--d = *--s;
801054f6:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801054fa:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801054fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105501:	0f b6 10             	movzbl (%eax),%edx
80105504:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105507:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105509:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010550d:	0f 95 c0             	setne  %al
80105510:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105514:	84 c0                	test   %al,%al
80105516:	75 de                	jne    801054f6 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105518:	eb 25                	jmp    8010553f <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010551a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010551d:	0f b6 10             	movzbl (%eax),%edx
80105520:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105523:	88 10                	mov    %dl,(%eax)
80105525:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105529:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010552d:	eb 01                	jmp    80105530 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010552f:	90                   	nop
80105530:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105534:	0f 95 c0             	setne  %al
80105537:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010553b:	84 c0                	test   %al,%al
8010553d:	75 db                	jne    8010551a <memmove+0x59>
      *d++ = *s++;

  return dst;
8010553f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105542:	c9                   	leave  
80105543:	c3                   	ret    

80105544 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105544:	55                   	push   %ebp
80105545:	89 e5                	mov    %esp,%ebp
80105547:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010554a:	8b 45 10             	mov    0x10(%ebp),%eax
8010554d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105551:	8b 45 0c             	mov    0xc(%ebp),%eax
80105554:	89 44 24 04          	mov    %eax,0x4(%esp)
80105558:	8b 45 08             	mov    0x8(%ebp),%eax
8010555b:	89 04 24             	mov    %eax,(%esp)
8010555e:	e8 5e ff ff ff       	call   801054c1 <memmove>
}
80105563:	c9                   	leave  
80105564:	c3                   	ret    

80105565 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105565:	55                   	push   %ebp
80105566:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105568:	eb 0c                	jmp    80105576 <strncmp+0x11>
    n--, p++, q++;
8010556a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010556e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105572:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105576:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010557a:	74 1a                	je     80105596 <strncmp+0x31>
8010557c:	8b 45 08             	mov    0x8(%ebp),%eax
8010557f:	0f b6 00             	movzbl (%eax),%eax
80105582:	84 c0                	test   %al,%al
80105584:	74 10                	je     80105596 <strncmp+0x31>
80105586:	8b 45 08             	mov    0x8(%ebp),%eax
80105589:	0f b6 10             	movzbl (%eax),%edx
8010558c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010558f:	0f b6 00             	movzbl (%eax),%eax
80105592:	38 c2                	cmp    %al,%dl
80105594:	74 d4                	je     8010556a <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105596:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010559a:	75 07                	jne    801055a3 <strncmp+0x3e>
    return 0;
8010559c:	b8 00 00 00 00       	mov    $0x0,%eax
801055a1:	eb 18                	jmp    801055bb <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
801055a3:	8b 45 08             	mov    0x8(%ebp),%eax
801055a6:	0f b6 00             	movzbl (%eax),%eax
801055a9:	0f b6 d0             	movzbl %al,%edx
801055ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801055af:	0f b6 00             	movzbl (%eax),%eax
801055b2:	0f b6 c0             	movzbl %al,%eax
801055b5:	89 d1                	mov    %edx,%ecx
801055b7:	29 c1                	sub    %eax,%ecx
801055b9:	89 c8                	mov    %ecx,%eax
}
801055bb:	5d                   	pop    %ebp
801055bc:	c3                   	ret    

801055bd <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801055bd:	55                   	push   %ebp
801055be:	89 e5                	mov    %esp,%ebp
801055c0:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801055c3:	8b 45 08             	mov    0x8(%ebp),%eax
801055c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801055c9:	90                   	nop
801055ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ce:	0f 9f c0             	setg   %al
801055d1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801055d5:	84 c0                	test   %al,%al
801055d7:	74 30                	je     80105609 <strncpy+0x4c>
801055d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055dc:	0f b6 10             	movzbl (%eax),%edx
801055df:	8b 45 08             	mov    0x8(%ebp),%eax
801055e2:	88 10                	mov    %dl,(%eax)
801055e4:	8b 45 08             	mov    0x8(%ebp),%eax
801055e7:	0f b6 00             	movzbl (%eax),%eax
801055ea:	84 c0                	test   %al,%al
801055ec:	0f 95 c0             	setne  %al
801055ef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801055f3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801055f7:	84 c0                	test   %al,%al
801055f9:	75 cf                	jne    801055ca <strncpy+0xd>
    ;
  while(n-- > 0)
801055fb:	eb 0c                	jmp    80105609 <strncpy+0x4c>
    *s++ = 0;
801055fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105600:	c6 00 00             	movb   $0x0,(%eax)
80105603:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105607:	eb 01                	jmp    8010560a <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105609:	90                   	nop
8010560a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010560e:	0f 9f c0             	setg   %al
80105611:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105615:	84 c0                	test   %al,%al
80105617:	75 e4                	jne    801055fd <strncpy+0x40>
    *s++ = 0;
  return os;
80105619:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010561c:	c9                   	leave  
8010561d:	c3                   	ret    

8010561e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010561e:	55                   	push   %ebp
8010561f:	89 e5                	mov    %esp,%ebp
80105621:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105624:	8b 45 08             	mov    0x8(%ebp),%eax
80105627:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010562a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010562e:	7f 05                	jg     80105635 <safestrcpy+0x17>
    return os;
80105630:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105633:	eb 35                	jmp    8010566a <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105635:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105639:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010563d:	7e 22                	jle    80105661 <safestrcpy+0x43>
8010563f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105642:	0f b6 10             	movzbl (%eax),%edx
80105645:	8b 45 08             	mov    0x8(%ebp),%eax
80105648:	88 10                	mov    %dl,(%eax)
8010564a:	8b 45 08             	mov    0x8(%ebp),%eax
8010564d:	0f b6 00             	movzbl (%eax),%eax
80105650:	84 c0                	test   %al,%al
80105652:	0f 95 c0             	setne  %al
80105655:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105659:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010565d:	84 c0                	test   %al,%al
8010565f:	75 d4                	jne    80105635 <safestrcpy+0x17>
    ;
  *s = 0;
80105661:	8b 45 08             	mov    0x8(%ebp),%eax
80105664:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105667:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010566a:	c9                   	leave  
8010566b:	c3                   	ret    

8010566c <strlen>:

int
strlen(const char *s)
{
8010566c:	55                   	push   %ebp
8010566d:	89 e5                	mov    %esp,%ebp
8010566f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105672:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105679:	eb 04                	jmp    8010567f <strlen+0x13>
8010567b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010567f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105682:	03 45 08             	add    0x8(%ebp),%eax
80105685:	0f b6 00             	movzbl (%eax),%eax
80105688:	84 c0                	test   %al,%al
8010568a:	75 ef                	jne    8010567b <strlen+0xf>
    ;
  return n;
8010568c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010568f:	c9                   	leave  
80105690:	c3                   	ret    
80105691:	00 00                	add    %al,(%eax)
	...

80105694 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105694:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105698:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010569c:	55                   	push   %ebp
  pushl %ebx
8010569d:	53                   	push   %ebx
  pushl %esi
8010569e:	56                   	push   %esi
  pushl %edi
8010569f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801056a0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801056a2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801056a4:	5f                   	pop    %edi
  popl %esi
801056a5:	5e                   	pop    %esi
  popl %ebx
801056a6:	5b                   	pop    %ebx
  popl %ebp
801056a7:	5d                   	pop    %ebp
  ret
801056a8:	c3                   	ret    
801056a9:	00 00                	add    %al,(%eax)
	...

801056ac <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
801056ac:	55                   	push   %ebp
801056ad:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz)
801056af:	8b 45 08             	mov    0x8(%ebp),%eax
801056b2:	8b 00                	mov    (%eax),%eax
801056b4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801056b7:	76 0f                	jbe    801056c8 <fetchint+0x1c>
801056b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801056bc:	8d 50 04             	lea    0x4(%eax),%edx
801056bf:	8b 45 08             	mov    0x8(%ebp),%eax
801056c2:	8b 00                	mov    (%eax),%eax
801056c4:	39 c2                	cmp    %eax,%edx
801056c6:	76 07                	jbe    801056cf <fetchint+0x23>
    return -1;
801056c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056cd:	eb 0f                	jmp    801056de <fetchint+0x32>
  *ip = *(int*)(addr);
801056cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801056d2:	8b 10                	mov    (%eax),%edx
801056d4:	8b 45 10             	mov    0x10(%ebp),%eax
801056d7:	89 10                	mov    %edx,(%eax)
  return 0;
801056d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056de:	5d                   	pop    %ebp
801056df:	c3                   	ret    

801056e0 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
801056e0:	55                   	push   %ebp
801056e1:	89 e5                	mov    %esp,%ebp
801056e3:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
801056e6:	8b 45 08             	mov    0x8(%ebp),%eax
801056e9:	8b 00                	mov    (%eax),%eax
801056eb:	3b 45 0c             	cmp    0xc(%ebp),%eax
801056ee:	77 07                	ja     801056f7 <fetchstr+0x17>
    return -1;
801056f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056f5:	eb 45                	jmp    8010573c <fetchstr+0x5c>
  *pp = (char*)addr;
801056f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801056fa:	8b 45 10             	mov    0x10(%ebp),%eax
801056fd:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
801056ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105702:	8b 00                	mov    (%eax),%eax
80105704:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105707:	8b 45 10             	mov    0x10(%ebp),%eax
8010570a:	8b 00                	mov    (%eax),%eax
8010570c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010570f:	eb 1e                	jmp    8010572f <fetchstr+0x4f>
    if(*s == 0)
80105711:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105714:	0f b6 00             	movzbl (%eax),%eax
80105717:	84 c0                	test   %al,%al
80105719:	75 10                	jne    8010572b <fetchstr+0x4b>
      return s - *pp;
8010571b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010571e:	8b 45 10             	mov    0x10(%ebp),%eax
80105721:	8b 00                	mov    (%eax),%eax
80105723:	89 d1                	mov    %edx,%ecx
80105725:	29 c1                	sub    %eax,%ecx
80105727:	89 c8                	mov    %ecx,%eax
80105729:	eb 11                	jmp    8010573c <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
8010572b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010572f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105732:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105735:	72 da                	jb     80105711 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
80105737:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010573c:	c9                   	leave  
8010573d:	c3                   	ret    

8010573e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010573e:	55                   	push   %ebp
8010573f:	89 e5                	mov    %esp,%ebp
80105741:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
80105744:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010574a:	8b 40 18             	mov    0x18(%eax),%eax
8010574d:	8b 50 44             	mov    0x44(%eax),%edx
80105750:	8b 45 08             	mov    0x8(%ebp),%eax
80105753:	c1 e0 02             	shl    $0x2,%eax
80105756:	01 d0                	add    %edx,%eax
80105758:	8d 48 04             	lea    0x4(%eax),%ecx
8010575b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105761:	8b 55 0c             	mov    0xc(%ebp),%edx
80105764:	89 54 24 08          	mov    %edx,0x8(%esp)
80105768:	89 4c 24 04          	mov    %ecx,0x4(%esp)
8010576c:	89 04 24             	mov    %eax,(%esp)
8010576f:	e8 38 ff ff ff       	call   801056ac <fetchint>
}
80105774:	c9                   	leave  
80105775:	c3                   	ret    

80105776 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105776:	55                   	push   %ebp
80105777:	89 e5                	mov    %esp,%ebp
80105779:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010577c:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010577f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105783:	8b 45 08             	mov    0x8(%ebp),%eax
80105786:	89 04 24             	mov    %eax,(%esp)
80105789:	e8 b0 ff ff ff       	call   8010573e <argint>
8010578e:	85 c0                	test   %eax,%eax
80105790:	79 07                	jns    80105799 <argptr+0x23>
    return -1;
80105792:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105797:	eb 3d                	jmp    801057d6 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105799:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010579c:	89 c2                	mov    %eax,%edx
8010579e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057a4:	8b 00                	mov    (%eax),%eax
801057a6:	39 c2                	cmp    %eax,%edx
801057a8:	73 16                	jae    801057c0 <argptr+0x4a>
801057aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057ad:	89 c2                	mov    %eax,%edx
801057af:	8b 45 10             	mov    0x10(%ebp),%eax
801057b2:	01 c2                	add    %eax,%edx
801057b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057ba:	8b 00                	mov    (%eax),%eax
801057bc:	39 c2                	cmp    %eax,%edx
801057be:	76 07                	jbe    801057c7 <argptr+0x51>
    return -1;
801057c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057c5:	eb 0f                	jmp    801057d6 <argptr+0x60>
  *pp = (char*)i;
801057c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057ca:	89 c2                	mov    %eax,%edx
801057cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801057cf:	89 10                	mov    %edx,(%eax)
  return 0;
801057d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057d6:	c9                   	leave  
801057d7:	c3                   	ret    

801057d8 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801057d8:	55                   	push   %ebp
801057d9:	89 e5                	mov    %esp,%ebp
801057db:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
801057de:	8d 45 fc             	lea    -0x4(%ebp),%eax
801057e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801057e5:	8b 45 08             	mov    0x8(%ebp),%eax
801057e8:	89 04 24             	mov    %eax,(%esp)
801057eb:	e8 4e ff ff ff       	call   8010573e <argint>
801057f0:	85 c0                	test   %eax,%eax
801057f2:	79 07                	jns    801057fb <argstr+0x23>
    return -1;
801057f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057f9:	eb 1e                	jmp    80105819 <argstr+0x41>
  return fetchstr(proc, addr, pp);
801057fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057fe:	89 c2                	mov    %eax,%edx
80105800:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105806:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105809:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010580d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105811:	89 04 24             	mov    %eax,(%esp)
80105814:	e8 c7 fe ff ff       	call   801056e0 <fetchstr>
}
80105819:	c9                   	leave  
8010581a:	c3                   	ret    

8010581b <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
8010581b:	55                   	push   %ebp
8010581c:	89 e5                	mov    %esp,%ebp
8010581e:	53                   	push   %ebx
8010581f:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105822:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105828:	8b 40 18             	mov    0x18(%eax),%eax
8010582b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010582e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
80105831:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105835:	78 2e                	js     80105865 <syscall+0x4a>
80105837:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010583b:	7f 28                	jg     80105865 <syscall+0x4a>
8010583d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105840:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105847:	85 c0                	test   %eax,%eax
80105849:	74 1a                	je     80105865 <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
8010584b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105851:	8b 58 18             	mov    0x18(%eax),%ebx
80105854:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105857:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010585e:	ff d0                	call   *%eax
80105860:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105863:	eb 73                	jmp    801058d8 <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
80105865:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80105869:	7e 30                	jle    8010589b <syscall+0x80>
8010586b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010586e:	83 f8 17             	cmp    $0x17,%eax
80105871:	77 28                	ja     8010589b <syscall+0x80>
80105873:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105876:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010587d:	85 c0                	test   %eax,%eax
8010587f:	74 1a                	je     8010589b <syscall+0x80>
    proc->tf->eax = syscalls[num]();
80105881:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105887:	8b 58 18             	mov    0x18(%eax),%ebx
8010588a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588d:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105894:	ff d0                	call   *%eax
80105896:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105899:	eb 3d                	jmp    801058d8 <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010589b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058a1:	8d 48 6c             	lea    0x6c(%eax),%ecx
801058a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801058aa:	8b 40 10             	mov    0x10(%eax),%eax
801058ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
801058b4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801058b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801058bc:	c7 04 24 27 8c 10 80 	movl   $0x80108c27,(%esp)
801058c3:	e8 d9 aa ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801058c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058ce:	8b 40 18             	mov    0x18(%eax),%eax
801058d1:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
801058d8:	83 c4 24             	add    $0x24,%esp
801058db:	5b                   	pop    %ebx
801058dc:	5d                   	pop    %ebp
801058dd:	c3                   	ret    
	...

801058e0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801058e0:	55                   	push   %ebp
801058e1:	89 e5                	mov    %esp,%ebp
801058e3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801058e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801058ed:	8b 45 08             	mov    0x8(%ebp),%eax
801058f0:	89 04 24             	mov    %eax,(%esp)
801058f3:	e8 46 fe ff ff       	call   8010573e <argint>
801058f8:	85 c0                	test   %eax,%eax
801058fa:	79 07                	jns    80105903 <argfd+0x23>
    return -1;
801058fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105901:	eb 50                	jmp    80105953 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105903:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105906:	85 c0                	test   %eax,%eax
80105908:	78 21                	js     8010592b <argfd+0x4b>
8010590a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010590d:	83 f8 0f             	cmp    $0xf,%eax
80105910:	7f 19                	jg     8010592b <argfd+0x4b>
80105912:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105918:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010591b:	83 c2 08             	add    $0x8,%edx
8010591e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105922:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105925:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105929:	75 07                	jne    80105932 <argfd+0x52>
    return -1;
8010592b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105930:	eb 21                	jmp    80105953 <argfd+0x73>
  if(pfd)
80105932:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105936:	74 08                	je     80105940 <argfd+0x60>
    *pfd = fd;
80105938:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010593b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010593e:	89 10                	mov    %edx,(%eax)
  if(pf)
80105940:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105944:	74 08                	je     8010594e <argfd+0x6e>
    *pf = f;
80105946:	8b 45 10             	mov    0x10(%ebp),%eax
80105949:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010594c:	89 10                	mov    %edx,(%eax)
  return 0;
8010594e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105953:	c9                   	leave  
80105954:	c3                   	ret    

80105955 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105955:	55                   	push   %ebp
80105956:	89 e5                	mov    %esp,%ebp
80105958:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010595b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105962:	eb 30                	jmp    80105994 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105964:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010596a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010596d:	83 c2 08             	add    $0x8,%edx
80105970:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105974:	85 c0                	test   %eax,%eax
80105976:	75 18                	jne    80105990 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105978:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010597e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105981:	8d 4a 08             	lea    0x8(%edx),%ecx
80105984:	8b 55 08             	mov    0x8(%ebp),%edx
80105987:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010598b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010598e:	eb 0f                	jmp    8010599f <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105990:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105994:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105998:	7e ca                	jle    80105964 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010599a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010599f:	c9                   	leave  
801059a0:	c3                   	ret    

801059a1 <sys_dup>:

int
sys_dup(void)
{
801059a1:	55                   	push   %ebp
801059a2:	89 e5                	mov    %esp,%ebp
801059a4:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801059a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059aa:	89 44 24 08          	mov    %eax,0x8(%esp)
801059ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801059b5:	00 
801059b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059bd:	e8 1e ff ff ff       	call   801058e0 <argfd>
801059c2:	85 c0                	test   %eax,%eax
801059c4:	79 07                	jns    801059cd <sys_dup+0x2c>
    return -1;
801059c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cb:	eb 29                	jmp    801059f6 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801059cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059d0:	89 04 24             	mov    %eax,(%esp)
801059d3:	e8 7d ff ff ff       	call   80105955 <fdalloc>
801059d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059df:	79 07                	jns    801059e8 <sys_dup+0x47>
    return -1;
801059e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059e6:	eb 0e                	jmp    801059f6 <sys_dup+0x55>
  filedup(f);
801059e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059eb:	89 04 24             	mov    %eax,(%esp)
801059ee:	e8 65 b8 ff ff       	call   80101258 <filedup>
  return fd;
801059f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801059f6:	c9                   	leave  
801059f7:	c3                   	ret    

801059f8 <sys_read>:

int
sys_read(void)
{
801059f8:	55                   	push   %ebp
801059f9:	89 e5                	mov    %esp,%ebp
801059fb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801059fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a01:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a05:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a0c:	00 
80105a0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a14:	e8 c7 fe ff ff       	call   801058e0 <argfd>
80105a19:	85 c0                	test   %eax,%eax
80105a1b:	78 35                	js     80105a52 <sys_read+0x5a>
80105a1d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a20:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a24:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105a2b:	e8 0e fd ff ff       	call   8010573e <argint>
80105a30:	85 c0                	test   %eax,%eax
80105a32:	78 1e                	js     80105a52 <sys_read+0x5a>
80105a34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a37:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a3b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a49:	e8 28 fd ff ff       	call   80105776 <argptr>
80105a4e:	85 c0                	test   %eax,%eax
80105a50:	79 07                	jns    80105a59 <sys_read+0x61>
    return -1;
80105a52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a57:	eb 19                	jmp    80105a72 <sys_read+0x7a>
  return fileread(f, p, n);
80105a59:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a5c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a62:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a66:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a6a:	89 04 24             	mov    %eax,(%esp)
80105a6d:	e8 53 b9 ff ff       	call   801013c5 <fileread>
}
80105a72:	c9                   	leave  
80105a73:	c3                   	ret    

80105a74 <sys_write>:

int
sys_write(void)
{
80105a74:	55                   	push   %ebp
80105a75:	89 e5                	mov    %esp,%ebp
80105a77:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105a7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a7d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a81:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a88:	00 
80105a89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a90:	e8 4b fe ff ff       	call   801058e0 <argfd>
80105a95:	85 c0                	test   %eax,%eax
80105a97:	78 35                	js     80105ace <sys_write+0x5a>
80105a99:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105aa0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105aa7:	e8 92 fc ff ff       	call   8010573e <argint>
80105aac:	85 c0                	test   %eax,%eax
80105aae:	78 1e                	js     80105ace <sys_write+0x5a>
80105ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ab7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105aba:	89 44 24 04          	mov    %eax,0x4(%esp)
80105abe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ac5:	e8 ac fc ff ff       	call   80105776 <argptr>
80105aca:	85 c0                	test   %eax,%eax
80105acc:	79 07                	jns    80105ad5 <sys_write+0x61>
    return -1;
80105ace:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad3:	eb 19                	jmp    80105aee <sys_write+0x7a>
  return filewrite(f, p, n);
80105ad5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ad8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ade:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105ae2:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ae6:	89 04 24             	mov    %eax,(%esp)
80105ae9:	e8 93 b9 ff ff       	call   80101481 <filewrite>
}
80105aee:	c9                   	leave  
80105aef:	c3                   	ret    

80105af0 <sys_close>:

int
sys_close(void)
{
80105af0:	55                   	push   %ebp
80105af1:	89 e5                	mov    %esp,%ebp
80105af3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105af6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105af9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105afd:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b00:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b0b:	e8 d0 fd ff ff       	call   801058e0 <argfd>
80105b10:	85 c0                	test   %eax,%eax
80105b12:	79 07                	jns    80105b1b <sys_close+0x2b>
    return -1;
80105b14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b19:	eb 24                	jmp    80105b3f <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105b1b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b24:	83 c2 08             	add    $0x8,%edx
80105b27:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b2e:	00 
  fileclose(f);
80105b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b32:	89 04 24             	mov    %eax,(%esp)
80105b35:	e8 66 b7 ff ff       	call   801012a0 <fileclose>
  return 0;
80105b3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b3f:	c9                   	leave  
80105b40:	c3                   	ret    

80105b41 <sys_fstat>:

int
sys_fstat(void)
{
80105b41:	55                   	push   %ebp
80105b42:	89 e5                	mov    %esp,%ebp
80105b44:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105b47:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b4a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b55:	00 
80105b56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b5d:	e8 7e fd ff ff       	call   801058e0 <argfd>
80105b62:	85 c0                	test   %eax,%eax
80105b64:	78 1f                	js     80105b85 <sys_fstat+0x44>
80105b66:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105b6d:	00 
80105b6e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b71:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b75:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b7c:	e8 f5 fb ff ff       	call   80105776 <argptr>
80105b81:	85 c0                	test   %eax,%eax
80105b83:	79 07                	jns    80105b8c <sys_fstat+0x4b>
    return -1;
80105b85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b8a:	eb 12                	jmp    80105b9e <sys_fstat+0x5d>
  return filestat(f, st);
80105b8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b92:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b96:	89 04 24             	mov    %eax,(%esp)
80105b99:	e8 d8 b7 ff ff       	call   80101376 <filestat>
}
80105b9e:	c9                   	leave  
80105b9f:	c3                   	ret    

80105ba0 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ba0:	55                   	push   %ebp
80105ba1:	89 e5                	mov    %esp,%ebp
80105ba3:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105ba6:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105ba9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bb4:	e8 1f fc ff ff       	call   801057d8 <argstr>
80105bb9:	85 c0                	test   %eax,%eax
80105bbb:	78 17                	js     80105bd4 <sys_link+0x34>
80105bbd:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bc4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105bcb:	e8 08 fc ff ff       	call   801057d8 <argstr>
80105bd0:	85 c0                	test   %eax,%eax
80105bd2:	79 0a                	jns    80105bde <sys_link+0x3e>
    return -1;
80105bd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bd9:	e9 3c 01 00 00       	jmp    80105d1a <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80105bde:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105be1:	89 04 24             	mov    %eax,(%esp)
80105be4:	e8 fd ca ff ff       	call   801026e6 <namei>
80105be9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bf0:	75 0a                	jne    80105bfc <sys_link+0x5c>
    return -1;
80105bf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bf7:	e9 1e 01 00 00       	jmp    80105d1a <sys_link+0x17a>

  begin_trans();
80105bfc:	e8 f8 d8 ff ff       	call   801034f9 <begin_trans>

  ilock(ip);
80105c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c04:	89 04 24             	mov    %eax,(%esp)
80105c07:	e8 38 bf ff ff       	call   80101b44 <ilock>
  if(ip->type == T_DIR){
80105c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c13:	66 83 f8 01          	cmp    $0x1,%ax
80105c17:	75 1a                	jne    80105c33 <sys_link+0x93>
    iunlockput(ip);
80105c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c1c:	89 04 24             	mov    %eax,(%esp)
80105c1f:	e8 a4 c1 ff ff       	call   80101dc8 <iunlockput>
    commit_trans();
80105c24:	e8 19 d9 ff ff       	call   80103542 <commit_trans>
    return -1;
80105c29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c2e:	e9 e7 00 00 00       	jmp    80105d1a <sys_link+0x17a>
  }

  ip->nlink++;
80105c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c36:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c3a:	8d 50 01             	lea    0x1(%eax),%edx
80105c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c40:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c47:	89 04 24             	mov    %eax,(%esp)
80105c4a:	e8 39 bd ff ff       	call   80101988 <iupdate>
  iunlock(ip);
80105c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c52:	89 04 24             	mov    %eax,(%esp)
80105c55:	e8 38 c0 ff ff       	call   80101c92 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105c5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c5d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105c60:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c64:	89 04 24             	mov    %eax,(%esp)
80105c67:	e8 9c ca ff ff       	call   80102708 <nameiparent>
80105c6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c6f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c73:	74 68                	je     80105cdd <sys_link+0x13d>
    goto bad;
  ilock(dp);
80105c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c78:	89 04 24             	mov    %eax,(%esp)
80105c7b:	e8 c4 be ff ff       	call   80101b44 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105c80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c83:	8b 10                	mov    (%eax),%edx
80105c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c88:	8b 00                	mov    (%eax),%eax
80105c8a:	39 c2                	cmp    %eax,%edx
80105c8c:	75 20                	jne    80105cae <sys_link+0x10e>
80105c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c91:	8b 40 04             	mov    0x4(%eax),%eax
80105c94:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c98:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca2:	89 04 24             	mov    %eax,(%esp)
80105ca5:	e8 7b c7 ff ff       	call   80102425 <dirlink>
80105caa:	85 c0                	test   %eax,%eax
80105cac:	79 0d                	jns    80105cbb <sys_link+0x11b>
    iunlockput(dp);
80105cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb1:	89 04 24             	mov    %eax,(%esp)
80105cb4:	e8 0f c1 ff ff       	call   80101dc8 <iunlockput>
    goto bad;
80105cb9:	eb 23                	jmp    80105cde <sys_link+0x13e>
  }
  iunlockput(dp);
80105cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cbe:	89 04 24             	mov    %eax,(%esp)
80105cc1:	e8 02 c1 ff ff       	call   80101dc8 <iunlockput>
  iput(ip);
80105cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc9:	89 04 24             	mov    %eax,(%esp)
80105ccc:	e8 26 c0 ff ff       	call   80101cf7 <iput>

  commit_trans();
80105cd1:	e8 6c d8 ff ff       	call   80103542 <commit_trans>

  return 0;
80105cd6:	b8 00 00 00 00       	mov    $0x0,%eax
80105cdb:	eb 3d                	jmp    80105d1a <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105cdd:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80105cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce1:	89 04 24             	mov    %eax,(%esp)
80105ce4:	e8 5b be ff ff       	call   80101b44 <ilock>
  ip->nlink--;
80105ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cec:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105cf0:	8d 50 ff             	lea    -0x1(%eax),%edx
80105cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf6:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cfd:	89 04 24             	mov    %eax,(%esp)
80105d00:	e8 83 bc ff ff       	call   80101988 <iupdate>
  iunlockput(ip);
80105d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d08:	89 04 24             	mov    %eax,(%esp)
80105d0b:	e8 b8 c0 ff ff       	call   80101dc8 <iunlockput>
  commit_trans();
80105d10:	e8 2d d8 ff ff       	call   80103542 <commit_trans>
  return -1;
80105d15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d1a:	c9                   	leave  
80105d1b:	c3                   	ret    

80105d1c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105d1c:	55                   	push   %ebp
80105d1d:	89 e5                	mov    %esp,%ebp
80105d1f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d22:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105d29:	eb 4b                	jmp    80105d76 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d35:	00 
80105d36:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d3a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d41:	8b 45 08             	mov    0x8(%ebp),%eax
80105d44:	89 04 24             	mov    %eax,(%esp)
80105d47:	e8 ee c2 ff ff       	call   8010203a <readi>
80105d4c:	83 f8 10             	cmp    $0x10,%eax
80105d4f:	74 0c                	je     80105d5d <isdirempty+0x41>
      panic("isdirempty: readi");
80105d51:	c7 04 24 43 8c 10 80 	movl   $0x80108c43,(%esp)
80105d58:	e8 e0 a7 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105d5d:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105d61:	66 85 c0             	test   %ax,%ax
80105d64:	74 07                	je     80105d6d <isdirempty+0x51>
      return 0;
80105d66:	b8 00 00 00 00       	mov    $0x0,%eax
80105d6b:	eb 1b                	jmp    80105d88 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d70:	83 c0 10             	add    $0x10,%eax
80105d73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d76:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d79:	8b 45 08             	mov    0x8(%ebp),%eax
80105d7c:	8b 40 18             	mov    0x18(%eax),%eax
80105d7f:	39 c2                	cmp    %eax,%edx
80105d81:	72 a8                	jb     80105d2b <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105d83:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105d88:	c9                   	leave  
80105d89:	c3                   	ret    

80105d8a <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105d8a:	55                   	push   %ebp
80105d8b:	89 e5                	mov    %esp,%ebp
80105d8d:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105d90:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105d93:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d9e:	e8 35 fa ff ff       	call   801057d8 <argstr>
80105da3:	85 c0                	test   %eax,%eax
80105da5:	79 0a                	jns    80105db1 <sys_unlink+0x27>
    return -1;
80105da7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dac:	e9 aa 01 00 00       	jmp    80105f5b <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105db1:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105db4:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105db7:	89 54 24 04          	mov    %edx,0x4(%esp)
80105dbb:	89 04 24             	mov    %eax,(%esp)
80105dbe:	e8 45 c9 ff ff       	call   80102708 <nameiparent>
80105dc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dca:	75 0a                	jne    80105dd6 <sys_unlink+0x4c>
    return -1;
80105dcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dd1:	e9 85 01 00 00       	jmp    80105f5b <sys_unlink+0x1d1>

  begin_trans();
80105dd6:	e8 1e d7 ff ff       	call   801034f9 <begin_trans>

  ilock(dp);
80105ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dde:	89 04 24             	mov    %eax,(%esp)
80105de1:	e8 5e bd ff ff       	call   80101b44 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105de6:	c7 44 24 04 55 8c 10 	movl   $0x80108c55,0x4(%esp)
80105ded:	80 
80105dee:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105df1:	89 04 24             	mov    %eax,(%esp)
80105df4:	e8 42 c5 ff ff       	call   8010233b <namecmp>
80105df9:	85 c0                	test   %eax,%eax
80105dfb:	0f 84 45 01 00 00    	je     80105f46 <sys_unlink+0x1bc>
80105e01:	c7 44 24 04 57 8c 10 	movl   $0x80108c57,0x4(%esp)
80105e08:	80 
80105e09:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e0c:	89 04 24             	mov    %eax,(%esp)
80105e0f:	e8 27 c5 ff ff       	call   8010233b <namecmp>
80105e14:	85 c0                	test   %eax,%eax
80105e16:	0f 84 2a 01 00 00    	je     80105f46 <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105e1c:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105e1f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e23:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105e26:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e2d:	89 04 24             	mov    %eax,(%esp)
80105e30:	e8 28 c5 ff ff       	call   8010235d <dirlookup>
80105e35:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e3c:	0f 84 03 01 00 00    	je     80105f45 <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80105e42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e45:	89 04 24             	mov    %eax,(%esp)
80105e48:	e8 f7 bc ff ff       	call   80101b44 <ilock>

  if(ip->nlink < 1)
80105e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e50:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e54:	66 85 c0             	test   %ax,%ax
80105e57:	7f 0c                	jg     80105e65 <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80105e59:	c7 04 24 5a 8c 10 80 	movl   $0x80108c5a,(%esp)
80105e60:	e8 d8 a6 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e68:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e6c:	66 83 f8 01          	cmp    $0x1,%ax
80105e70:	75 1f                	jne    80105e91 <sys_unlink+0x107>
80105e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e75:	89 04 24             	mov    %eax,(%esp)
80105e78:	e8 9f fe ff ff       	call   80105d1c <isdirempty>
80105e7d:	85 c0                	test   %eax,%eax
80105e7f:	75 10                	jne    80105e91 <sys_unlink+0x107>
    iunlockput(ip);
80105e81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e84:	89 04 24             	mov    %eax,(%esp)
80105e87:	e8 3c bf ff ff       	call   80101dc8 <iunlockput>
    goto bad;
80105e8c:	e9 b5 00 00 00       	jmp    80105f46 <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105e91:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105e98:	00 
80105e99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ea0:	00 
80105ea1:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ea4:	89 04 24             	mov    %eax,(%esp)
80105ea7:	e8 42 f5 ff ff       	call   801053ee <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105eac:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105eaf:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105eb6:	00 
80105eb7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ebb:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ebe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec5:	89 04 24             	mov    %eax,(%esp)
80105ec8:	e8 d8 c2 ff ff       	call   801021a5 <writei>
80105ecd:	83 f8 10             	cmp    $0x10,%eax
80105ed0:	74 0c                	je     80105ede <sys_unlink+0x154>
    panic("unlink: writei");
80105ed2:	c7 04 24 6c 8c 10 80 	movl   $0x80108c6c,(%esp)
80105ed9:	e8 5f a6 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ee5:	66 83 f8 01          	cmp    $0x1,%ax
80105ee9:	75 1c                	jne    80105f07 <sys_unlink+0x17d>
    dp->nlink--;
80105eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eee:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ef2:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef8:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eff:	89 04 24             	mov    %eax,(%esp)
80105f02:	e8 81 ba ff ff       	call   80101988 <iupdate>
  }
  iunlockput(dp);
80105f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0a:	89 04 24             	mov    %eax,(%esp)
80105f0d:	e8 b6 be ff ff       	call   80101dc8 <iunlockput>

  ip->nlink--;
80105f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f15:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105f19:	8d 50 ff             	lea    -0x1(%eax),%edx
80105f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f26:	89 04 24             	mov    %eax,(%esp)
80105f29:	e8 5a ba ff ff       	call   80101988 <iupdate>
  iunlockput(ip);
80105f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f31:	89 04 24             	mov    %eax,(%esp)
80105f34:	e8 8f be ff ff       	call   80101dc8 <iunlockput>

  commit_trans();
80105f39:	e8 04 d6 ff ff       	call   80103542 <commit_trans>

  return 0;
80105f3e:	b8 00 00 00 00       	mov    $0x0,%eax
80105f43:	eb 16                	jmp    80105f5b <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105f45:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80105f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f49:	89 04 24             	mov    %eax,(%esp)
80105f4c:	e8 77 be ff ff       	call   80101dc8 <iunlockput>
  commit_trans();
80105f51:	e8 ec d5 ff ff       	call   80103542 <commit_trans>
  return -1;
80105f56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f5b:	c9                   	leave  
80105f5c:	c3                   	ret    

80105f5d <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105f5d:	55                   	push   %ebp
80105f5e:	89 e5                	mov    %esp,%ebp
80105f60:	83 ec 48             	sub    $0x48,%esp
80105f63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105f66:	8b 55 10             	mov    0x10(%ebp),%edx
80105f69:	8b 45 14             	mov    0x14(%ebp),%eax
80105f6c:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105f70:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105f74:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105f78:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f7f:	8b 45 08             	mov    0x8(%ebp),%eax
80105f82:	89 04 24             	mov    %eax,(%esp)
80105f85:	e8 7e c7 ff ff       	call   80102708 <nameiparent>
80105f8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f91:	75 0a                	jne    80105f9d <create+0x40>
    return 0;
80105f93:	b8 00 00 00 00       	mov    $0x0,%eax
80105f98:	e9 7e 01 00 00       	jmp    8010611b <create+0x1be>
  ilock(dp);
80105f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa0:	89 04 24             	mov    %eax,(%esp)
80105fa3:	e8 9c bb ff ff       	call   80101b44 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105fa8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fab:	89 44 24 08          	mov    %eax,0x8(%esp)
80105faf:	8d 45 de             	lea    -0x22(%ebp),%eax
80105fb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb9:	89 04 24             	mov    %eax,(%esp)
80105fbc:	e8 9c c3 ff ff       	call   8010235d <dirlookup>
80105fc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fc4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fc8:	74 47                	je     80106011 <create+0xb4>
    iunlockput(dp);
80105fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fcd:	89 04 24             	mov    %eax,(%esp)
80105fd0:	e8 f3 bd ff ff       	call   80101dc8 <iunlockput>
    ilock(ip);
80105fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd8:	89 04 24             	mov    %eax,(%esp)
80105fdb:	e8 64 bb ff ff       	call   80101b44 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105fe0:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105fe5:	75 15                	jne    80105ffc <create+0x9f>
80105fe7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fea:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fee:	66 83 f8 02          	cmp    $0x2,%ax
80105ff2:	75 08                	jne    80105ffc <create+0x9f>
      return ip;
80105ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff7:	e9 1f 01 00 00       	jmp    8010611b <create+0x1be>
    iunlockput(ip);
80105ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fff:	89 04 24             	mov    %eax,(%esp)
80106002:	e8 c1 bd ff ff       	call   80101dc8 <iunlockput>
    return 0;
80106007:	b8 00 00 00 00       	mov    $0x0,%eax
8010600c:	e9 0a 01 00 00       	jmp    8010611b <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106011:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106018:	8b 00                	mov    (%eax),%eax
8010601a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010601e:	89 04 24             	mov    %eax,(%esp)
80106021:	e8 85 b8 ff ff       	call   801018ab <ialloc>
80106026:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106029:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010602d:	75 0c                	jne    8010603b <create+0xde>
    panic("create: ialloc");
8010602f:	c7 04 24 7b 8c 10 80 	movl   $0x80108c7b,(%esp)
80106036:	e8 02 a5 ff ff       	call   8010053d <panic>

  ilock(ip);
8010603b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603e:	89 04 24             	mov    %eax,(%esp)
80106041:	e8 fe ba ff ff       	call   80101b44 <ilock>
  ip->major = major;
80106046:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106049:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010604d:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106051:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106054:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106058:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
8010605c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605f:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106065:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106068:	89 04 24             	mov    %eax,(%esp)
8010606b:	e8 18 b9 ff ff       	call   80101988 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106070:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106075:	75 6a                	jne    801060e1 <create+0x184>
    dp->nlink++;  // for ".."
80106077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010607a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010607e:	8d 50 01             	lea    0x1(%eax),%edx
80106081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106084:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608b:	89 04 24             	mov    %eax,(%esp)
8010608e:	e8 f5 b8 ff ff       	call   80101988 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106093:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106096:	8b 40 04             	mov    0x4(%eax),%eax
80106099:	89 44 24 08          	mov    %eax,0x8(%esp)
8010609d:	c7 44 24 04 55 8c 10 	movl   $0x80108c55,0x4(%esp)
801060a4:	80 
801060a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a8:	89 04 24             	mov    %eax,(%esp)
801060ab:	e8 75 c3 ff ff       	call   80102425 <dirlink>
801060b0:	85 c0                	test   %eax,%eax
801060b2:	78 21                	js     801060d5 <create+0x178>
801060b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b7:	8b 40 04             	mov    0x4(%eax),%eax
801060ba:	89 44 24 08          	mov    %eax,0x8(%esp)
801060be:	c7 44 24 04 57 8c 10 	movl   $0x80108c57,0x4(%esp)
801060c5:	80 
801060c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c9:	89 04 24             	mov    %eax,(%esp)
801060cc:	e8 54 c3 ff ff       	call   80102425 <dirlink>
801060d1:	85 c0                	test   %eax,%eax
801060d3:	79 0c                	jns    801060e1 <create+0x184>
      panic("create dots");
801060d5:	c7 04 24 8a 8c 10 80 	movl   $0x80108c8a,(%esp)
801060dc:	e8 5c a4 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801060e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e4:	8b 40 04             	mov    0x4(%eax),%eax
801060e7:	89 44 24 08          	mov    %eax,0x8(%esp)
801060eb:	8d 45 de             	lea    -0x22(%ebp),%eax
801060ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801060f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f5:	89 04 24             	mov    %eax,(%esp)
801060f8:	e8 28 c3 ff ff       	call   80102425 <dirlink>
801060fd:	85 c0                	test   %eax,%eax
801060ff:	79 0c                	jns    8010610d <create+0x1b0>
    panic("create: dirlink");
80106101:	c7 04 24 96 8c 10 80 	movl   $0x80108c96,(%esp)
80106108:	e8 30 a4 ff ff       	call   8010053d <panic>

  iunlockput(dp);
8010610d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106110:	89 04 24             	mov    %eax,(%esp)
80106113:	e8 b0 bc ff ff       	call   80101dc8 <iunlockput>

  return ip;
80106118:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010611b:	c9                   	leave  
8010611c:	c3                   	ret    

8010611d <sys_open>:

int
sys_open(void)
{
8010611d:	55                   	push   %ebp
8010611e:	89 e5                	mov    %esp,%ebp
80106120:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106123:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106126:	89 44 24 04          	mov    %eax,0x4(%esp)
8010612a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106131:	e8 a2 f6 ff ff       	call   801057d8 <argstr>
80106136:	85 c0                	test   %eax,%eax
80106138:	78 17                	js     80106151 <sys_open+0x34>
8010613a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010613d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106141:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106148:	e8 f1 f5 ff ff       	call   8010573e <argint>
8010614d:	85 c0                	test   %eax,%eax
8010614f:	79 0a                	jns    8010615b <sys_open+0x3e>
    return -1;
80106151:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106156:	e9 46 01 00 00       	jmp    801062a1 <sys_open+0x184>
  if(omode & O_CREATE){
8010615b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010615e:	25 00 02 00 00       	and    $0x200,%eax
80106163:	85 c0                	test   %eax,%eax
80106165:	74 40                	je     801061a7 <sys_open+0x8a>
    begin_trans();
80106167:	e8 8d d3 ff ff       	call   801034f9 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
8010616c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010616f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106176:	00 
80106177:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010617e:	00 
8010617f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106186:	00 
80106187:	89 04 24             	mov    %eax,(%esp)
8010618a:	e8 ce fd ff ff       	call   80105f5d <create>
8010618f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80106192:	e8 ab d3 ff ff       	call   80103542 <commit_trans>
    if(ip == 0)
80106197:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010619b:	75 5c                	jne    801061f9 <sys_open+0xdc>
      return -1;
8010619d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a2:	e9 fa 00 00 00       	jmp    801062a1 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
801061a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061aa:	89 04 24             	mov    %eax,(%esp)
801061ad:	e8 34 c5 ff ff       	call   801026e6 <namei>
801061b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061b9:	75 0a                	jne    801061c5 <sys_open+0xa8>
      return -1;
801061bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c0:	e9 dc 00 00 00       	jmp    801062a1 <sys_open+0x184>
    ilock(ip);
801061c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c8:	89 04 24             	mov    %eax,(%esp)
801061cb:	e8 74 b9 ff ff       	call   80101b44 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801061d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061d7:	66 83 f8 01          	cmp    $0x1,%ax
801061db:	75 1c                	jne    801061f9 <sys_open+0xdc>
801061dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061e0:	85 c0                	test   %eax,%eax
801061e2:	74 15                	je     801061f9 <sys_open+0xdc>
      iunlockput(ip);
801061e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e7:	89 04 24             	mov    %eax,(%esp)
801061ea:	e8 d9 bb ff ff       	call   80101dc8 <iunlockput>
      return -1;
801061ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f4:	e9 a8 00 00 00       	jmp    801062a1 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801061f9:	e8 fa af ff ff       	call   801011f8 <filealloc>
801061fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106201:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106205:	74 14                	je     8010621b <sys_open+0xfe>
80106207:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620a:	89 04 24             	mov    %eax,(%esp)
8010620d:	e8 43 f7 ff ff       	call   80105955 <fdalloc>
80106212:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106215:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106219:	79 23                	jns    8010623e <sys_open+0x121>
    if(f)
8010621b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010621f:	74 0b                	je     8010622c <sys_open+0x10f>
      fileclose(f);
80106221:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106224:	89 04 24             	mov    %eax,(%esp)
80106227:	e8 74 b0 ff ff       	call   801012a0 <fileclose>
    iunlockput(ip);
8010622c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622f:	89 04 24             	mov    %eax,(%esp)
80106232:	e8 91 bb ff ff       	call   80101dc8 <iunlockput>
    return -1;
80106237:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010623c:	eb 63                	jmp    801062a1 <sys_open+0x184>
  }
  iunlock(ip);
8010623e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106241:	89 04 24             	mov    %eax,(%esp)
80106244:	e8 49 ba ff ff       	call   80101c92 <iunlock>

  f->type = FD_INODE;
80106249:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106252:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106255:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106258:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010625b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010625e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106265:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106268:	83 e0 01             	and    $0x1,%eax
8010626b:	85 c0                	test   %eax,%eax
8010626d:	0f 94 c2             	sete   %dl
80106270:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106273:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106276:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106279:	83 e0 01             	and    $0x1,%eax
8010627c:	84 c0                	test   %al,%al
8010627e:	75 0a                	jne    8010628a <sys_open+0x16d>
80106280:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106283:	83 e0 02             	and    $0x2,%eax
80106286:	85 c0                	test   %eax,%eax
80106288:	74 07                	je     80106291 <sys_open+0x174>
8010628a:	b8 01 00 00 00       	mov    $0x1,%eax
8010628f:	eb 05                	jmp    80106296 <sys_open+0x179>
80106291:	b8 00 00 00 00       	mov    $0x0,%eax
80106296:	89 c2                	mov    %eax,%edx
80106298:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629b:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010629e:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801062a1:	c9                   	leave  
801062a2:	c3                   	ret    

801062a3 <sys_mkdir>:

int
sys_mkdir(void)
{
801062a3:	55                   	push   %ebp
801062a4:	89 e5                	mov    %esp,%ebp
801062a6:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
801062a9:	e8 4b d2 ff ff       	call   801034f9 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801062ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801062b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062bc:	e8 17 f5 ff ff       	call   801057d8 <argstr>
801062c1:	85 c0                	test   %eax,%eax
801062c3:	78 2c                	js     801062f1 <sys_mkdir+0x4e>
801062c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801062cf:	00 
801062d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801062d7:	00 
801062d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801062df:	00 
801062e0:	89 04 24             	mov    %eax,(%esp)
801062e3:	e8 75 fc ff ff       	call   80105f5d <create>
801062e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062ef:	75 0c                	jne    801062fd <sys_mkdir+0x5a>
    commit_trans();
801062f1:	e8 4c d2 ff ff       	call   80103542 <commit_trans>
    return -1;
801062f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062fb:	eb 15                	jmp    80106312 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801062fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106300:	89 04 24             	mov    %eax,(%esp)
80106303:	e8 c0 ba ff ff       	call   80101dc8 <iunlockput>
  commit_trans();
80106308:	e8 35 d2 ff ff       	call   80103542 <commit_trans>
  return 0;
8010630d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106312:	c9                   	leave  
80106313:	c3                   	ret    

80106314 <sys_mknod>:

int
sys_mknod(void)
{
80106314:	55                   	push   %ebp
80106315:	89 e5                	mov    %esp,%ebp
80106317:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
8010631a:	e8 da d1 ff ff       	call   801034f9 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
8010631f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106322:	89 44 24 04          	mov    %eax,0x4(%esp)
80106326:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010632d:	e8 a6 f4 ff ff       	call   801057d8 <argstr>
80106332:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106335:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106339:	78 5e                	js     80106399 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010633b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010633e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106342:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106349:	e8 f0 f3 ff ff       	call   8010573e <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
8010634e:	85 c0                	test   %eax,%eax
80106350:	78 47                	js     80106399 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106352:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106355:	89 44 24 04          	mov    %eax,0x4(%esp)
80106359:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106360:	e8 d9 f3 ff ff       	call   8010573e <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106365:	85 c0                	test   %eax,%eax
80106367:	78 30                	js     80106399 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106369:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010636c:	0f bf c8             	movswl %ax,%ecx
8010636f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106372:	0f bf d0             	movswl %ax,%edx
80106375:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106378:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010637c:	89 54 24 08          	mov    %edx,0x8(%esp)
80106380:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106387:	00 
80106388:	89 04 24             	mov    %eax,(%esp)
8010638b:	e8 cd fb ff ff       	call   80105f5d <create>
80106390:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106393:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106397:	75 0c                	jne    801063a5 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80106399:	e8 a4 d1 ff ff       	call   80103542 <commit_trans>
    return -1;
8010639e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063a3:	eb 15                	jmp    801063ba <sys_mknod+0xa6>
  }
  iunlockput(ip);
801063a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a8:	89 04 24             	mov    %eax,(%esp)
801063ab:	e8 18 ba ff ff       	call   80101dc8 <iunlockput>
  commit_trans();
801063b0:	e8 8d d1 ff ff       	call   80103542 <commit_trans>
  return 0;
801063b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063ba:	c9                   	leave  
801063bb:	c3                   	ret    

801063bc <sys_chdir>:

int
sys_chdir(void)
{
801063bc:	55                   	push   %ebp
801063bd:	89 e5                	mov    %esp,%ebp
801063bf:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
801063c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801063c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063d0:	e8 03 f4 ff ff       	call   801057d8 <argstr>
801063d5:	85 c0                	test   %eax,%eax
801063d7:	78 14                	js     801063ed <sys_chdir+0x31>
801063d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063dc:	89 04 24             	mov    %eax,(%esp)
801063df:	e8 02 c3 ff ff       	call   801026e6 <namei>
801063e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063eb:	75 07                	jne    801063f4 <sys_chdir+0x38>
    return -1;
801063ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f2:	eb 57                	jmp    8010644b <sys_chdir+0x8f>
  ilock(ip);
801063f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f7:	89 04 24             	mov    %eax,(%esp)
801063fa:	e8 45 b7 ff ff       	call   80101b44 <ilock>
  if(ip->type != T_DIR){
801063ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106402:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106406:	66 83 f8 01          	cmp    $0x1,%ax
8010640a:	74 12                	je     8010641e <sys_chdir+0x62>
    iunlockput(ip);
8010640c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640f:	89 04 24             	mov    %eax,(%esp)
80106412:	e8 b1 b9 ff ff       	call   80101dc8 <iunlockput>
    return -1;
80106417:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010641c:	eb 2d                	jmp    8010644b <sys_chdir+0x8f>
  }
  iunlock(ip);
8010641e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106421:	89 04 24             	mov    %eax,(%esp)
80106424:	e8 69 b8 ff ff       	call   80101c92 <iunlock>
  iput(proc->cwd);
80106429:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010642f:	8b 40 68             	mov    0x68(%eax),%eax
80106432:	89 04 24             	mov    %eax,(%esp)
80106435:	e8 bd b8 ff ff       	call   80101cf7 <iput>
  proc->cwd = ip;
8010643a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106440:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106443:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106446:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010644b:	c9                   	leave  
8010644c:	c3                   	ret    

8010644d <sys_exec>:

int
sys_exec(void)
{
8010644d:	55                   	push   %ebp
8010644e:	89 e5                	mov    %esp,%ebp
80106450:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106456:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106459:	89 44 24 04          	mov    %eax,0x4(%esp)
8010645d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106464:	e8 6f f3 ff ff       	call   801057d8 <argstr>
80106469:	85 c0                	test   %eax,%eax
8010646b:	78 1a                	js     80106487 <sys_exec+0x3a>
8010646d:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106473:	89 44 24 04          	mov    %eax,0x4(%esp)
80106477:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010647e:	e8 bb f2 ff ff       	call   8010573e <argint>
80106483:	85 c0                	test   %eax,%eax
80106485:	79 0a                	jns    80106491 <sys_exec+0x44>
    return -1;
80106487:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010648c:	e9 e2 00 00 00       	jmp    80106573 <sys_exec+0x126>
  }
  memset(argv, 0, sizeof(argv));
80106491:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106498:	00 
80106499:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801064a0:	00 
801064a1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064a7:	89 04 24             	mov    %eax,(%esp)
801064aa:	e8 3f ef ff ff       	call   801053ee <memset>
  for(i=0;; i++){
801064af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801064b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b9:	83 f8 1f             	cmp    $0x1f,%eax
801064bc:	76 0a                	jbe    801064c8 <sys_exec+0x7b>
      return -1;
801064be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c3:	e9 ab 00 00 00       	jmp    80106573 <sys_exec+0x126>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
801064c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064cb:	c1 e0 02             	shl    $0x2,%eax
801064ce:	89 c2                	mov    %eax,%edx
801064d0:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801064d6:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801064d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064df:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
801064e5:	89 54 24 08          	mov    %edx,0x8(%esp)
801064e9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801064ed:	89 04 24             	mov    %eax,(%esp)
801064f0:	e8 b7 f1 ff ff       	call   801056ac <fetchint>
801064f5:	85 c0                	test   %eax,%eax
801064f7:	79 07                	jns    80106500 <sys_exec+0xb3>
      return -1;
801064f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064fe:	eb 73                	jmp    80106573 <sys_exec+0x126>
    if(uarg == 0){
80106500:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106506:	85 c0                	test   %eax,%eax
80106508:	75 26                	jne    80106530 <sys_exec+0xe3>
      argv[i] = 0;
8010650a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010650d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106514:	00 00 00 00 
      break;
80106518:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106519:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010651c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106522:	89 54 24 04          	mov    %edx,0x4(%esp)
80106526:	89 04 24             	mov    %eax,(%esp)
80106529:	e8 aa a8 ff ff       	call   80100dd8 <exec>
8010652e:	eb 43                	jmp    80106573 <sys_exec+0x126>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
80106530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106533:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010653a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106540:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80106543:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106549:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010654f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106553:	89 54 24 04          	mov    %edx,0x4(%esp)
80106557:	89 04 24             	mov    %eax,(%esp)
8010655a:	e8 81 f1 ff ff       	call   801056e0 <fetchstr>
8010655f:	85 c0                	test   %eax,%eax
80106561:	79 07                	jns    8010656a <sys_exec+0x11d>
      return -1;
80106563:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106568:	eb 09                	jmp    80106573 <sys_exec+0x126>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010656a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
8010656e:	e9 43 ff ff ff       	jmp    801064b6 <sys_exec+0x69>
  return exec(path, argv);
}
80106573:	c9                   	leave  
80106574:	c3                   	ret    

80106575 <sys_pipe>:

int
sys_pipe(void)
{
80106575:	55                   	push   %ebp
80106576:	89 e5                	mov    %esp,%ebp
80106578:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010657b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106582:	00 
80106583:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106586:	89 44 24 04          	mov    %eax,0x4(%esp)
8010658a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106591:	e8 e0 f1 ff ff       	call   80105776 <argptr>
80106596:	85 c0                	test   %eax,%eax
80106598:	79 0a                	jns    801065a4 <sys_pipe+0x2f>
    return -1;
8010659a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010659f:	e9 9b 00 00 00       	jmp    8010663f <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801065a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801065ab:	8d 45 e8             	lea    -0x18(%ebp),%eax
801065ae:	89 04 24             	mov    %eax,(%esp)
801065b1:	e8 5e d9 ff ff       	call   80103f14 <pipealloc>
801065b6:	85 c0                	test   %eax,%eax
801065b8:	79 07                	jns    801065c1 <sys_pipe+0x4c>
    return -1;
801065ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065bf:	eb 7e                	jmp    8010663f <sys_pipe+0xca>
  fd0 = -1;
801065c1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801065c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065cb:	89 04 24             	mov    %eax,(%esp)
801065ce:	e8 82 f3 ff ff       	call   80105955 <fdalloc>
801065d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065da:	78 14                	js     801065f0 <sys_pipe+0x7b>
801065dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065df:	89 04 24             	mov    %eax,(%esp)
801065e2:	e8 6e f3 ff ff       	call   80105955 <fdalloc>
801065e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065ee:	79 37                	jns    80106627 <sys_pipe+0xb2>
    if(fd0 >= 0)
801065f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065f4:	78 14                	js     8010660a <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801065f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065ff:	83 c2 08             	add    $0x8,%edx
80106602:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106609:	00 
    fileclose(rf);
8010660a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010660d:	89 04 24             	mov    %eax,(%esp)
80106610:	e8 8b ac ff ff       	call   801012a0 <fileclose>
    fileclose(wf);
80106615:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106618:	89 04 24             	mov    %eax,(%esp)
8010661b:	e8 80 ac ff ff       	call   801012a0 <fileclose>
    return -1;
80106620:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106625:	eb 18                	jmp    8010663f <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106627:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010662a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010662d:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010662f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106632:	8d 50 04             	lea    0x4(%eax),%edx
80106635:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106638:	89 02                	mov    %eax,(%edx)
  return 0;
8010663a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010663f:	c9                   	leave  
80106640:	c3                   	ret    
80106641:	00 00                	add    %al,(%eax)
	...

80106644 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106644:	55                   	push   %ebp
80106645:	89 e5                	mov    %esp,%ebp
80106647:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010664a:	e8 82 df ff ff       	call   801045d1 <fork>
}
8010664f:	c9                   	leave  
80106650:	c3                   	ret    

80106651 <sys_exit>:

int
sys_exit(void)
{
80106651:	55                   	push   %ebp
80106652:	89 e5                	mov    %esp,%ebp
80106654:	83 ec 08             	sub    $0x8,%esp
  exit();
80106657:	e8 0a e1 ff ff       	call   80104766 <exit>
  return 0;  // not reached
8010665c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106661:	c9                   	leave  
80106662:	c3                   	ret    

80106663 <sys_wait>:

int
sys_wait(void)
{
80106663:	55                   	push   %ebp
80106664:	89 e5                	mov    %esp,%ebp
80106666:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106669:	e8 4d e2 ff ff       	call   801048bb <wait>
}
8010666e:	c9                   	leave  
8010666f:	c3                   	ret    

80106670 <sys_wait2>:

int
sys_wait2(void)
{
80106670:	55                   	push   %ebp
80106671:	89 e5                	mov    %esp,%ebp
80106673:	83 ec 28             	sub    $0x28,%esp
  char *rtime=0;
80106676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  char *wtime=0;
8010667d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  argptr(1,&rtime,sizeof(rtime));
80106684:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
8010668b:	00 
8010668c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010668f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106693:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010669a:	e8 d7 f0 ff ff       	call   80105776 <argptr>
  argptr(0,&wtime,sizeof(wtime));
8010669f:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801066a6:	00 
801066a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801066ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066b5:	e8 bc f0 ff ff       	call   80105776 <argptr>
  return wait2((int*)wtime, (int*)rtime);
801066ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066c0:	89 54 24 04          	mov    %edx,0x4(%esp)
801066c4:	89 04 24             	mov    %eax,(%esp)
801066c7:	e8 01 e3 ff ff       	call   801049cd <wait2>
}
801066cc:	c9                   	leave  
801066cd:	c3                   	ret    

801066ce <sys_nice>:

int
sys_nice(void)
{
801066ce:	55                   	push   %ebp
801066cf:	89 e5                	mov    %esp,%ebp
801066d1:	83 ec 08             	sub    $0x8,%esp
  return nice();
801066d4:	e8 af e9 ff ff       	call   80105088 <nice>
}
801066d9:	c9                   	leave  
801066da:	c3                   	ret    

801066db <sys_kill>:
int
sys_kill(void)
{
801066db:	55                   	push   %ebp
801066dc:	89 e5                	mov    %esp,%ebp
801066de:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801066e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801066e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066ef:	e8 4a f0 ff ff       	call   8010573e <argint>
801066f4:	85 c0                	test   %eax,%eax
801066f6:	79 07                	jns    801066ff <sys_kill+0x24>
    return -1;
801066f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066fd:	eb 0b                	jmp    8010670a <sys_kill+0x2f>
  return kill(pid);
801066ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106702:	89 04 24             	mov    %eax,(%esp)
80106705:	e8 07 e8 ff ff       	call   80104f11 <kill>
}
8010670a:	c9                   	leave  
8010670b:	c3                   	ret    

8010670c <sys_getpid>:

int
sys_getpid(void)
{
8010670c:	55                   	push   %ebp
8010670d:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010670f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106715:	8b 40 10             	mov    0x10(%eax),%eax
}
80106718:	5d                   	pop    %ebp
80106719:	c3                   	ret    

8010671a <sys_sbrk>:

int
sys_sbrk(void)
{
8010671a:	55                   	push   %ebp
8010671b:	89 e5                	mov    %esp,%ebp
8010671d:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106720:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106723:	89 44 24 04          	mov    %eax,0x4(%esp)
80106727:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010672e:	e8 0b f0 ff ff       	call   8010573e <argint>
80106733:	85 c0                	test   %eax,%eax
80106735:	79 07                	jns    8010673e <sys_sbrk+0x24>
    return -1;
80106737:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010673c:	eb 24                	jmp    80106762 <sys_sbrk+0x48>
  addr = proc->sz;
8010673e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106744:	8b 00                	mov    (%eax),%eax
80106746:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106749:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010674c:	89 04 24             	mov    %eax,(%esp)
8010674f:	e8 d8 dd ff ff       	call   8010452c <growproc>
80106754:	85 c0                	test   %eax,%eax
80106756:	79 07                	jns    8010675f <sys_sbrk+0x45>
    return -1;
80106758:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010675d:	eb 03                	jmp    80106762 <sys_sbrk+0x48>
  return addr;
8010675f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106762:	c9                   	leave  
80106763:	c3                   	ret    

80106764 <sys_sleep>:

int
sys_sleep(void)
{
80106764:	55                   	push   %ebp
80106765:	89 e5                	mov    %esp,%ebp
80106767:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010676a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010676d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106771:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106778:	e8 c1 ef ff ff       	call   8010573e <argint>
8010677d:	85 c0                	test   %eax,%eax
8010677f:	79 07                	jns    80106788 <sys_sleep+0x24>
    return -1;
80106781:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106786:	eb 6c                	jmp    801067f4 <sys_sleep+0x90>
  acquire(&tickslock);
80106788:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
8010678f:	e8 0b ea ff ff       	call   8010519f <acquire>
  ticks0 = ticks;
80106794:	a1 c0 2d 11 80       	mov    0x80112dc0,%eax
80106799:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010679c:	eb 34                	jmp    801067d2 <sys_sleep+0x6e>
    if(proc->killed){
8010679e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067a4:	8b 40 24             	mov    0x24(%eax),%eax
801067a7:	85 c0                	test   %eax,%eax
801067a9:	74 13                	je     801067be <sys_sleep+0x5a>
      release(&tickslock);
801067ab:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
801067b2:	e8 4a ea ff ff       	call   80105201 <release>
      return -1;
801067b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067bc:	eb 36                	jmp    801067f4 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801067be:	c7 44 24 04 80 25 11 	movl   $0x80112580,0x4(%esp)
801067c5:	80 
801067c6:	c7 04 24 c0 2d 11 80 	movl   $0x80112dc0,(%esp)
801067cd:	e8 38 e6 ff ff       	call   80104e0a <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801067d2:	a1 c0 2d 11 80       	mov    0x80112dc0,%eax
801067d7:	89 c2                	mov    %eax,%edx
801067d9:	2b 55 f4             	sub    -0xc(%ebp),%edx
801067dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067df:	39 c2                	cmp    %eax,%edx
801067e1:	72 bb                	jb     8010679e <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801067e3:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
801067ea:	e8 12 ea ff ff       	call   80105201 <release>
  return 0;
801067ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067f4:	c9                   	leave  
801067f5:	c3                   	ret    

801067f6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801067f6:	55                   	push   %ebp
801067f7:	89 e5                	mov    %esp,%ebp
801067f9:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801067fc:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80106803:	e8 97 e9 ff ff       	call   8010519f <acquire>
  xticks = ticks;
80106808:	a1 c0 2d 11 80       	mov    0x80112dc0,%eax
8010680d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106810:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80106817:	e8 e5 e9 ff ff       	call   80105201 <release>
  return xticks;
8010681c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010681f:	c9                   	leave  
80106820:	c3                   	ret    
80106821:	00 00                	add    %al,(%eax)
	...

80106824 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106824:	55                   	push   %ebp
80106825:	89 e5                	mov    %esp,%ebp
80106827:	83 ec 08             	sub    $0x8,%esp
8010682a:	8b 55 08             	mov    0x8(%ebp),%edx
8010682d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106830:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106834:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106837:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010683b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010683f:	ee                   	out    %al,(%dx)
}
80106840:	c9                   	leave  
80106841:	c3                   	ret    

80106842 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106842:	55                   	push   %ebp
80106843:	89 e5                	mov    %esp,%ebp
80106845:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106848:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010684f:	00 
80106850:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106857:	e8 c8 ff ff ff       	call   80106824 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010685c:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106863:	00 
80106864:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010686b:	e8 b4 ff ff ff       	call   80106824 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106870:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106877:	00 
80106878:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010687f:	e8 a0 ff ff ff       	call   80106824 <outb>
  picenable(IRQ_TIMER);
80106884:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010688b:	e8 0d d5 ff ff       	call   80103d9d <picenable>
}
80106890:	c9                   	leave  
80106891:	c3                   	ret    
	...

80106894 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106894:	1e                   	push   %ds
  pushl %es
80106895:	06                   	push   %es
  pushl %fs
80106896:	0f a0                	push   %fs
  pushl %gs
80106898:	0f a8                	push   %gs
  pushal
8010689a:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010689b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010689f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801068a1:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801068a3:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801068a7:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801068a9:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801068ab:	54                   	push   %esp
  call trap
801068ac:	e8 de 01 00 00       	call   80106a8f <trap>
  addl $4, %esp
801068b1:	83 c4 04             	add    $0x4,%esp

801068b4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801068b4:	61                   	popa   
  popl %gs
801068b5:	0f a9                	pop    %gs
  popl %fs
801068b7:	0f a1                	pop    %fs
  popl %es
801068b9:	07                   	pop    %es
  popl %ds
801068ba:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801068bb:	83 c4 08             	add    $0x8,%esp
  iret
801068be:	cf                   	iret   
	...

801068c0 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801068c0:	55                   	push   %ebp
801068c1:	89 e5                	mov    %esp,%ebp
801068c3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801068c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801068c9:	83 e8 01             	sub    $0x1,%eax
801068cc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801068d0:	8b 45 08             	mov    0x8(%ebp),%eax
801068d3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801068d7:	8b 45 08             	mov    0x8(%ebp),%eax
801068da:	c1 e8 10             	shr    $0x10,%eax
801068dd:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801068e1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801068e4:	0f 01 18             	lidtl  (%eax)
}
801068e7:	c9                   	leave  
801068e8:	c3                   	ret    

801068e9 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801068e9:	55                   	push   %ebp
801068ea:	89 e5                	mov    %esp,%ebp
801068ec:	53                   	push   %ebx
801068ed:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801068f0:	0f 20 d3             	mov    %cr2,%ebx
801068f3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
801068f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801068f9:	83 c4 10             	add    $0x10,%esp
801068fc:	5b                   	pop    %ebx
801068fd:	5d                   	pop    %ebp
801068fe:	c3                   	ret    

801068ff <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801068ff:	55                   	push   %ebp
80106900:	89 e5                	mov    %esp,%ebp
80106902:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106905:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010690c:	e9 c3 00 00 00       	jmp    801069d4 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106914:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
8010691b:	89 c2                	mov    %eax,%edx
8010691d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106920:	66 89 14 c5 c0 25 11 	mov    %dx,-0x7feeda40(,%eax,8)
80106927:	80 
80106928:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010692b:	66 c7 04 c5 c2 25 11 	movw   $0x8,-0x7feeda3e(,%eax,8)
80106932:	80 08 00 
80106935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106938:	0f b6 14 c5 c4 25 11 	movzbl -0x7feeda3c(,%eax,8),%edx
8010693f:	80 
80106940:	83 e2 e0             	and    $0xffffffe0,%edx
80106943:	88 14 c5 c4 25 11 80 	mov    %dl,-0x7feeda3c(,%eax,8)
8010694a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010694d:	0f b6 14 c5 c4 25 11 	movzbl -0x7feeda3c(,%eax,8),%edx
80106954:	80 
80106955:	83 e2 1f             	and    $0x1f,%edx
80106958:	88 14 c5 c4 25 11 80 	mov    %dl,-0x7feeda3c(,%eax,8)
8010695f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106962:	0f b6 14 c5 c5 25 11 	movzbl -0x7feeda3b(,%eax,8),%edx
80106969:	80 
8010696a:	83 e2 f0             	and    $0xfffffff0,%edx
8010696d:	83 ca 0e             	or     $0xe,%edx
80106970:	88 14 c5 c5 25 11 80 	mov    %dl,-0x7feeda3b(,%eax,8)
80106977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010697a:	0f b6 14 c5 c5 25 11 	movzbl -0x7feeda3b(,%eax,8),%edx
80106981:	80 
80106982:	83 e2 ef             	and    $0xffffffef,%edx
80106985:	88 14 c5 c5 25 11 80 	mov    %dl,-0x7feeda3b(,%eax,8)
8010698c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010698f:	0f b6 14 c5 c5 25 11 	movzbl -0x7feeda3b(,%eax,8),%edx
80106996:	80 
80106997:	83 e2 9f             	and    $0xffffff9f,%edx
8010699a:	88 14 c5 c5 25 11 80 	mov    %dl,-0x7feeda3b(,%eax,8)
801069a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069a4:	0f b6 14 c5 c5 25 11 	movzbl -0x7feeda3b(,%eax,8),%edx
801069ab:	80 
801069ac:	83 ca 80             	or     $0xffffff80,%edx
801069af:	88 14 c5 c5 25 11 80 	mov    %dl,-0x7feeda3b(,%eax,8)
801069b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069b9:	8b 04 85 a0 b0 10 80 	mov    -0x7fef4f60(,%eax,4),%eax
801069c0:	c1 e8 10             	shr    $0x10,%eax
801069c3:	89 c2                	mov    %eax,%edx
801069c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c8:	66 89 14 c5 c6 25 11 	mov    %dx,-0x7feeda3a(,%eax,8)
801069cf:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801069d0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069d4:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801069db:	0f 8e 30 ff ff ff    	jle    80106911 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801069e1:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
801069e6:	66 a3 c0 27 11 80    	mov    %ax,0x801127c0
801069ec:	66 c7 05 c2 27 11 80 	movw   $0x8,0x801127c2
801069f3:	08 00 
801069f5:	0f b6 05 c4 27 11 80 	movzbl 0x801127c4,%eax
801069fc:	83 e0 e0             	and    $0xffffffe0,%eax
801069ff:	a2 c4 27 11 80       	mov    %al,0x801127c4
80106a04:	0f b6 05 c4 27 11 80 	movzbl 0x801127c4,%eax
80106a0b:	83 e0 1f             	and    $0x1f,%eax
80106a0e:	a2 c4 27 11 80       	mov    %al,0x801127c4
80106a13:	0f b6 05 c5 27 11 80 	movzbl 0x801127c5,%eax
80106a1a:	83 c8 0f             	or     $0xf,%eax
80106a1d:	a2 c5 27 11 80       	mov    %al,0x801127c5
80106a22:	0f b6 05 c5 27 11 80 	movzbl 0x801127c5,%eax
80106a29:	83 e0 ef             	and    $0xffffffef,%eax
80106a2c:	a2 c5 27 11 80       	mov    %al,0x801127c5
80106a31:	0f b6 05 c5 27 11 80 	movzbl 0x801127c5,%eax
80106a38:	83 c8 60             	or     $0x60,%eax
80106a3b:	a2 c5 27 11 80       	mov    %al,0x801127c5
80106a40:	0f b6 05 c5 27 11 80 	movzbl 0x801127c5,%eax
80106a47:	83 c8 80             	or     $0xffffff80,%eax
80106a4a:	a2 c5 27 11 80       	mov    %al,0x801127c5
80106a4f:	a1 a0 b1 10 80       	mov    0x8010b1a0,%eax
80106a54:	c1 e8 10             	shr    $0x10,%eax
80106a57:	66 a3 c6 27 11 80    	mov    %ax,0x801127c6
  
  initlock(&tickslock, "time");
80106a5d:	c7 44 24 04 a8 8c 10 	movl   $0x80108ca8,0x4(%esp)
80106a64:	80 
80106a65:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80106a6c:	e8 0d e7 ff ff       	call   8010517e <initlock>
}
80106a71:	c9                   	leave  
80106a72:	c3                   	ret    

80106a73 <idtinit>:

void
idtinit(void)
{
80106a73:	55                   	push   %ebp
80106a74:	89 e5                	mov    %esp,%ebp
80106a76:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106a79:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106a80:	00 
80106a81:	c7 04 24 c0 25 11 80 	movl   $0x801125c0,(%esp)
80106a88:	e8 33 fe ff ff       	call   801068c0 <lidt>
}
80106a8d:	c9                   	leave  
80106a8e:	c3                   	ret    

80106a8f <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106a8f:	55                   	push   %ebp
80106a90:	89 e5                	mov    %esp,%ebp
80106a92:	57                   	push   %edi
80106a93:	56                   	push   %esi
80106a94:	53                   	push   %ebx
80106a95:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106a98:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9b:	8b 40 30             	mov    0x30(%eax),%eax
80106a9e:	83 f8 40             	cmp    $0x40,%eax
80106aa1:	75 3e                	jne    80106ae1 <trap+0x52>
    if(proc->killed)
80106aa3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aa9:	8b 40 24             	mov    0x24(%eax),%eax
80106aac:	85 c0                	test   %eax,%eax
80106aae:	74 05                	je     80106ab5 <trap+0x26>
      exit();
80106ab0:	e8 b1 dc ff ff       	call   80104766 <exit>
    proc->tf = tf;
80106ab5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106abb:	8b 55 08             	mov    0x8(%ebp),%edx
80106abe:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106ac1:	e8 55 ed ff ff       	call   8010581b <syscall>
    if(proc->killed)
80106ac6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106acc:	8b 40 24             	mov    0x24(%eax),%eax
80106acf:	85 c0                	test   %eax,%eax
80106ad1:	0f 84 78 02 00 00    	je     80106d4f <trap+0x2c0>
      exit();
80106ad7:	e8 8a dc ff ff       	call   80104766 <exit>
    return;
80106adc:	e9 6e 02 00 00       	jmp    80106d4f <trap+0x2c0>
  }

  switch(tf->trapno){
80106ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae4:	8b 40 30             	mov    0x30(%eax),%eax
80106ae7:	83 e8 20             	sub    $0x20,%eax
80106aea:	83 f8 1f             	cmp    $0x1f,%eax
80106aed:	0f 87 f0 00 00 00    	ja     80106be3 <trap+0x154>
80106af3:	8b 04 85 50 8d 10 80 	mov    -0x7fef72b0(,%eax,4),%eax
80106afa:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106afc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b02:	0f b6 00             	movzbl (%eax),%eax
80106b05:	84 c0                	test   %al,%al
80106b07:	75 65                	jne    80106b6e <trap+0xdf>
      acquire(&tickslock);
80106b09:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80106b10:	e8 8a e6 ff ff       	call   8010519f <acquire>
      ticks++;
80106b15:	a1 c0 2d 11 80       	mov    0x80112dc0,%eax
80106b1a:	83 c0 01             	add    $0x1,%eax
80106b1d:	a3 c0 2d 11 80       	mov    %eax,0x80112dc0
      if(proc)		//make sure proc is not null
80106b22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b28:	85 c0                	test   %eax,%eax
80106b2a:	74 2a                	je     80106b56 <trap+0xc7>
      {
	proc->rtime++;	//increment the running time of the current process
80106b2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b32:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80106b38:	83 c2 01             	add    $0x1,%edx
80106b3b:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
	proc->quanta--;	//decrement the quanta of the current process
80106b41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b47:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80106b4d:	83 ea 01             	sub    $0x1,%edx
80106b50:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
      }
      wakeup(&ticks);
80106b56:	c7 04 24 c0 2d 11 80 	movl   $0x80112dc0,(%esp)
80106b5d:	e8 84 e3 ff ff       	call   80104ee6 <wakeup>
      release(&tickslock);
80106b62:	c7 04 24 80 25 11 80 	movl   $0x80112580,(%esp)
80106b69:	e8 93 e6 ff ff       	call   80105201 <release>
    }
    lapiceoi();
80106b6e:	e8 52 c6 ff ff       	call   801031c5 <lapiceoi>
    break;
80106b73:	e9 41 01 00 00       	jmp    80106cb9 <trap+0x22a>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106b78:	e8 50 be ff ff       	call   801029cd <ideintr>
    lapiceoi();
80106b7d:	e8 43 c6 ff ff       	call   801031c5 <lapiceoi>
    break;
80106b82:	e9 32 01 00 00       	jmp    80106cb9 <trap+0x22a>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106b87:	e8 17 c4 ff ff       	call   80102fa3 <kbdintr>
    lapiceoi();
80106b8c:	e8 34 c6 ff ff       	call   801031c5 <lapiceoi>
    break;
80106b91:	e9 23 01 00 00       	jmp    80106cb9 <trap+0x22a>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106b96:	e8 b9 03 00 00       	call   80106f54 <uartintr>
    lapiceoi();
80106b9b:	e8 25 c6 ff ff       	call   801031c5 <lapiceoi>
    break;
80106ba0:	e9 14 01 00 00       	jmp    80106cb9 <trap+0x22a>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106ba5:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106ba8:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106bab:	8b 45 08             	mov    0x8(%ebp),%eax
80106bae:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bb2:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106bb5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106bbb:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bbe:	0f b6 c0             	movzbl %al,%eax
80106bc1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106bc5:	89 54 24 08          	mov    %edx,0x8(%esp)
80106bc9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bcd:	c7 04 24 b0 8c 10 80 	movl   $0x80108cb0,(%esp)
80106bd4:	e8 c8 97 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106bd9:	e8 e7 c5 ff ff       	call   801031c5 <lapiceoi>
    break;
80106bde:	e9 d6 00 00 00       	jmp    80106cb9 <trap+0x22a>
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106be3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106be9:	85 c0                	test   %eax,%eax
80106beb:	74 11                	je     80106bfe <trap+0x16f>
80106bed:	8b 45 08             	mov    0x8(%ebp),%eax
80106bf0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bf4:	0f b7 c0             	movzwl %ax,%eax
80106bf7:	83 e0 03             	and    $0x3,%eax
80106bfa:	85 c0                	test   %eax,%eax
80106bfc:	75 46                	jne    80106c44 <trap+0x1b5>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106bfe:	e8 e6 fc ff ff       	call   801068e9 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c03:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c06:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c09:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106c10:	0f b6 12             	movzbl (%edx),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c13:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c16:	8b 55 08             	mov    0x8(%ebp),%edx
      
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c19:	8b 52 30             	mov    0x30(%edx),%edx
80106c1c:	89 44 24 10          	mov    %eax,0x10(%esp)
80106c20:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106c24:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106c28:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c2c:	c7 04 24 d4 8c 10 80 	movl   $0x80108cd4,(%esp)
80106c33:	e8 69 97 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106c38:	c7 04 24 06 8d 10 80 	movl   $0x80108d06,(%esp)
80106c3f:	e8 f9 98 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c44:	e8 a0 fc ff ff       	call   801068e9 <rcr2>
80106c49:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c4b:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c4e:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c51:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c57:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c5a:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c5d:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c60:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c63:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c66:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c6f:	83 c0 6c             	add    $0x6c,%eax
80106c72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106c75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c7b:	8b 40 10             	mov    0x10(%eax),%eax
80106c7e:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106c82:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106c86:	89 74 24 14          	mov    %esi,0x14(%esp)
80106c8a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106c8e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c92:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106c95:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c99:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c9d:	c7 04 24 0c 8d 10 80 	movl   $0x80108d0c,(%esp)
80106ca4:	e8 f8 96 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106ca9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106caf:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106cb6:	eb 01                	jmp    80106cb9 <trap+0x22a>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106cb8:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106cb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cbf:	85 c0                	test   %eax,%eax
80106cc1:	74 24                	je     80106ce7 <trap+0x258>
80106cc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cc9:	8b 40 24             	mov    0x24(%eax),%eax
80106ccc:	85 c0                	test   %eax,%eax
80106cce:	74 17                	je     80106ce7 <trap+0x258>
80106cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cd7:	0f b7 c0             	movzwl %ax,%eax
80106cda:	83 e0 03             	and    $0x3,%eax
80106cdd:	83 f8 03             	cmp    $0x3,%eax
80106ce0:	75 05                	jne    80106ce7 <trap+0x258>
    exit();
80106ce2:	e8 7f da ff ff       	call   80104766 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER && proc->quanta <= 0) //added quanta check to yield only after quanta is spent
80106ce7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ced:	85 c0                	test   %eax,%eax
80106cef:	74 2e                	je     80106d1f <trap+0x290>
80106cf1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cf7:	8b 40 0c             	mov    0xc(%eax),%eax
80106cfa:	83 f8 04             	cmp    $0x4,%eax
80106cfd:	75 20                	jne    80106d1f <trap+0x290>
80106cff:	8b 45 08             	mov    0x8(%ebp),%eax
80106d02:	8b 40 30             	mov    0x30(%eax),%eax
80106d05:	83 f8 20             	cmp    $0x20,%eax
80106d08:	75 15                	jne    80106d1f <trap+0x290>
80106d0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d10:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80106d16:	85 c0                	test   %eax,%eax
80106d18:	7f 05                	jg     80106d1f <trap+0x290>
    yield();
80106d1a:	e8 8d e0 ff ff       	call   80104dac <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d1f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d25:	85 c0                	test   %eax,%eax
80106d27:	74 27                	je     80106d50 <trap+0x2c1>
80106d29:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d2f:	8b 40 24             	mov    0x24(%eax),%eax
80106d32:	85 c0                	test   %eax,%eax
80106d34:	74 1a                	je     80106d50 <trap+0x2c1>
80106d36:	8b 45 08             	mov    0x8(%ebp),%eax
80106d39:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d3d:	0f b7 c0             	movzwl %ax,%eax
80106d40:	83 e0 03             	and    $0x3,%eax
80106d43:	83 f8 03             	cmp    $0x3,%eax
80106d46:	75 08                	jne    80106d50 <trap+0x2c1>
    exit();
80106d48:	e8 19 da ff ff       	call   80104766 <exit>
80106d4d:	eb 01                	jmp    80106d50 <trap+0x2c1>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106d4f:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106d50:	83 c4 3c             	add    $0x3c,%esp
80106d53:	5b                   	pop    %ebx
80106d54:	5e                   	pop    %esi
80106d55:	5f                   	pop    %edi
80106d56:	5d                   	pop    %ebp
80106d57:	c3                   	ret    

80106d58 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106d58:	55                   	push   %ebp
80106d59:	89 e5                	mov    %esp,%ebp
80106d5b:	53                   	push   %ebx
80106d5c:	83 ec 14             	sub    $0x14,%esp
80106d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d62:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106d66:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106d6a:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106d6e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106d72:	ec                   	in     (%dx),%al
80106d73:	89 c3                	mov    %eax,%ebx
80106d75:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106d78:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106d7c:	83 c4 14             	add    $0x14,%esp
80106d7f:	5b                   	pop    %ebx
80106d80:	5d                   	pop    %ebp
80106d81:	c3                   	ret    

80106d82 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106d82:	55                   	push   %ebp
80106d83:	89 e5                	mov    %esp,%ebp
80106d85:	83 ec 08             	sub    $0x8,%esp
80106d88:	8b 55 08             	mov    0x8(%ebp),%edx
80106d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d8e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106d92:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106d95:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106d99:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106d9d:	ee                   	out    %al,(%dx)
}
80106d9e:	c9                   	leave  
80106d9f:	c3                   	ret    

80106da0 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106da0:	55                   	push   %ebp
80106da1:	89 e5                	mov    %esp,%ebp
80106da3:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106da6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106dad:	00 
80106dae:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106db5:	e8 c8 ff ff ff       	call   80106d82 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106dba:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106dc1:	00 
80106dc2:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106dc9:	e8 b4 ff ff ff       	call   80106d82 <outb>
  outb(COM1+0, 115200/9600);
80106dce:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106dd5:	00 
80106dd6:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106ddd:	e8 a0 ff ff ff       	call   80106d82 <outb>
  outb(COM1+1, 0);
80106de2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106de9:	00 
80106dea:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106df1:	e8 8c ff ff ff       	call   80106d82 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106df6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106dfd:	00 
80106dfe:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106e05:	e8 78 ff ff ff       	call   80106d82 <outb>
  outb(COM1+4, 0);
80106e0a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e11:	00 
80106e12:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106e19:	e8 64 ff ff ff       	call   80106d82 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106e1e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106e25:	00 
80106e26:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e2d:	e8 50 ff ff ff       	call   80106d82 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e32:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e39:	e8 1a ff ff ff       	call   80106d58 <inb>
80106e3e:	3c ff                	cmp    $0xff,%al
80106e40:	74 6c                	je     80106eae <uartinit+0x10e>
    return;
  uart = 1;
80106e42:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106e49:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e4c:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106e53:	e8 00 ff ff ff       	call   80106d58 <inb>
  inb(COM1+0);
80106e58:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e5f:	e8 f4 fe ff ff       	call   80106d58 <inb>
  picenable(IRQ_COM1);
80106e64:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e6b:	e8 2d cf ff ff       	call   80103d9d <picenable>
  ioapicenable(IRQ_COM1, 0);
80106e70:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e77:	00 
80106e78:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e7f:	e8 ce bd ff ff       	call   80102c52 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e84:	c7 45 f4 d0 8d 10 80 	movl   $0x80108dd0,-0xc(%ebp)
80106e8b:	eb 15                	jmp    80106ea2 <uartinit+0x102>
    uartputc(*p);
80106e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e90:	0f b6 00             	movzbl (%eax),%eax
80106e93:	0f be c0             	movsbl %al,%eax
80106e96:	89 04 24             	mov    %eax,(%esp)
80106e99:	e8 13 00 00 00       	call   80106eb1 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e9e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ea5:	0f b6 00             	movzbl (%eax),%eax
80106ea8:	84 c0                	test   %al,%al
80106eaa:	75 e1                	jne    80106e8d <uartinit+0xed>
80106eac:	eb 01                	jmp    80106eaf <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106eae:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106eaf:	c9                   	leave  
80106eb0:	c3                   	ret    

80106eb1 <uartputc>:

void
uartputc(int c)
{
80106eb1:	55                   	push   %ebp
80106eb2:	89 e5                	mov    %esp,%ebp
80106eb4:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106eb7:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106ebc:	85 c0                	test   %eax,%eax
80106ebe:	74 4d                	je     80106f0d <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ec0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ec7:	eb 10                	jmp    80106ed9 <uartputc+0x28>
    microdelay(10);
80106ec9:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106ed0:	e8 15 c3 ff ff       	call   801031ea <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106ed5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ed9:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106edd:	7f 16                	jg     80106ef5 <uartputc+0x44>
80106edf:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106ee6:	e8 6d fe ff ff       	call   80106d58 <inb>
80106eeb:	0f b6 c0             	movzbl %al,%eax
80106eee:	83 e0 20             	and    $0x20,%eax
80106ef1:	85 c0                	test   %eax,%eax
80106ef3:	74 d4                	je     80106ec9 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80106ef8:	0f b6 c0             	movzbl %al,%eax
80106efb:	89 44 24 04          	mov    %eax,0x4(%esp)
80106eff:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f06:	e8 77 fe ff ff       	call   80106d82 <outb>
80106f0b:	eb 01                	jmp    80106f0e <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106f0d:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106f0e:	c9                   	leave  
80106f0f:	c3                   	ret    

80106f10 <uartgetc>:

static int
uartgetc(void)
{
80106f10:	55                   	push   %ebp
80106f11:	89 e5                	mov    %esp,%ebp
80106f13:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106f16:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106f1b:	85 c0                	test   %eax,%eax
80106f1d:	75 07                	jne    80106f26 <uartgetc+0x16>
    return -1;
80106f1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f24:	eb 2c                	jmp    80106f52 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106f26:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f2d:	e8 26 fe ff ff       	call   80106d58 <inb>
80106f32:	0f b6 c0             	movzbl %al,%eax
80106f35:	83 e0 01             	and    $0x1,%eax
80106f38:	85 c0                	test   %eax,%eax
80106f3a:	75 07                	jne    80106f43 <uartgetc+0x33>
    return -1;
80106f3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f41:	eb 0f                	jmp    80106f52 <uartgetc+0x42>
  return inb(COM1+0);
80106f43:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f4a:	e8 09 fe ff ff       	call   80106d58 <inb>
80106f4f:	0f b6 c0             	movzbl %al,%eax
}
80106f52:	c9                   	leave  
80106f53:	c3                   	ret    

80106f54 <uartintr>:

void
uartintr(void)
{
80106f54:	55                   	push   %ebp
80106f55:	89 e5                	mov    %esp,%ebp
80106f57:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106f5a:	c7 04 24 10 6f 10 80 	movl   $0x80106f10,(%esp)
80106f61:	e8 0c 99 ff ff       	call   80100872 <consoleintr>
}
80106f66:	c9                   	leave  
80106f67:	c3                   	ret    

80106f68 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f68:	6a 00                	push   $0x0
  pushl $0
80106f6a:	6a 00                	push   $0x0
  jmp alltraps
80106f6c:	e9 23 f9 ff ff       	jmp    80106894 <alltraps>

80106f71 <vector1>:
.globl vector1
vector1:
  pushl $0
80106f71:	6a 00                	push   $0x0
  pushl $1
80106f73:	6a 01                	push   $0x1
  jmp alltraps
80106f75:	e9 1a f9 ff ff       	jmp    80106894 <alltraps>

80106f7a <vector2>:
.globl vector2
vector2:
  pushl $0
80106f7a:	6a 00                	push   $0x0
  pushl $2
80106f7c:	6a 02                	push   $0x2
  jmp alltraps
80106f7e:	e9 11 f9 ff ff       	jmp    80106894 <alltraps>

80106f83 <vector3>:
.globl vector3
vector3:
  pushl $0
80106f83:	6a 00                	push   $0x0
  pushl $3
80106f85:	6a 03                	push   $0x3
  jmp alltraps
80106f87:	e9 08 f9 ff ff       	jmp    80106894 <alltraps>

80106f8c <vector4>:
.globl vector4
vector4:
  pushl $0
80106f8c:	6a 00                	push   $0x0
  pushl $4
80106f8e:	6a 04                	push   $0x4
  jmp alltraps
80106f90:	e9 ff f8 ff ff       	jmp    80106894 <alltraps>

80106f95 <vector5>:
.globl vector5
vector5:
  pushl $0
80106f95:	6a 00                	push   $0x0
  pushl $5
80106f97:	6a 05                	push   $0x5
  jmp alltraps
80106f99:	e9 f6 f8 ff ff       	jmp    80106894 <alltraps>

80106f9e <vector6>:
.globl vector6
vector6:
  pushl $0
80106f9e:	6a 00                	push   $0x0
  pushl $6
80106fa0:	6a 06                	push   $0x6
  jmp alltraps
80106fa2:	e9 ed f8 ff ff       	jmp    80106894 <alltraps>

80106fa7 <vector7>:
.globl vector7
vector7:
  pushl $0
80106fa7:	6a 00                	push   $0x0
  pushl $7
80106fa9:	6a 07                	push   $0x7
  jmp alltraps
80106fab:	e9 e4 f8 ff ff       	jmp    80106894 <alltraps>

80106fb0 <vector8>:
.globl vector8
vector8:
  pushl $8
80106fb0:	6a 08                	push   $0x8
  jmp alltraps
80106fb2:	e9 dd f8 ff ff       	jmp    80106894 <alltraps>

80106fb7 <vector9>:
.globl vector9
vector9:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $9
80106fb9:	6a 09                	push   $0x9
  jmp alltraps
80106fbb:	e9 d4 f8 ff ff       	jmp    80106894 <alltraps>

80106fc0 <vector10>:
.globl vector10
vector10:
  pushl $10
80106fc0:	6a 0a                	push   $0xa
  jmp alltraps
80106fc2:	e9 cd f8 ff ff       	jmp    80106894 <alltraps>

80106fc7 <vector11>:
.globl vector11
vector11:
  pushl $11
80106fc7:	6a 0b                	push   $0xb
  jmp alltraps
80106fc9:	e9 c6 f8 ff ff       	jmp    80106894 <alltraps>

80106fce <vector12>:
.globl vector12
vector12:
  pushl $12
80106fce:	6a 0c                	push   $0xc
  jmp alltraps
80106fd0:	e9 bf f8 ff ff       	jmp    80106894 <alltraps>

80106fd5 <vector13>:
.globl vector13
vector13:
  pushl $13
80106fd5:	6a 0d                	push   $0xd
  jmp alltraps
80106fd7:	e9 b8 f8 ff ff       	jmp    80106894 <alltraps>

80106fdc <vector14>:
.globl vector14
vector14:
  pushl $14
80106fdc:	6a 0e                	push   $0xe
  jmp alltraps
80106fde:	e9 b1 f8 ff ff       	jmp    80106894 <alltraps>

80106fe3 <vector15>:
.globl vector15
vector15:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $15
80106fe5:	6a 0f                	push   $0xf
  jmp alltraps
80106fe7:	e9 a8 f8 ff ff       	jmp    80106894 <alltraps>

80106fec <vector16>:
.globl vector16
vector16:
  pushl $0
80106fec:	6a 00                	push   $0x0
  pushl $16
80106fee:	6a 10                	push   $0x10
  jmp alltraps
80106ff0:	e9 9f f8 ff ff       	jmp    80106894 <alltraps>

80106ff5 <vector17>:
.globl vector17
vector17:
  pushl $17
80106ff5:	6a 11                	push   $0x11
  jmp alltraps
80106ff7:	e9 98 f8 ff ff       	jmp    80106894 <alltraps>

80106ffc <vector18>:
.globl vector18
vector18:
  pushl $0
80106ffc:	6a 00                	push   $0x0
  pushl $18
80106ffe:	6a 12                	push   $0x12
  jmp alltraps
80107000:	e9 8f f8 ff ff       	jmp    80106894 <alltraps>

80107005 <vector19>:
.globl vector19
vector19:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $19
80107007:	6a 13                	push   $0x13
  jmp alltraps
80107009:	e9 86 f8 ff ff       	jmp    80106894 <alltraps>

8010700e <vector20>:
.globl vector20
vector20:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $20
80107010:	6a 14                	push   $0x14
  jmp alltraps
80107012:	e9 7d f8 ff ff       	jmp    80106894 <alltraps>

80107017 <vector21>:
.globl vector21
vector21:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $21
80107019:	6a 15                	push   $0x15
  jmp alltraps
8010701b:	e9 74 f8 ff ff       	jmp    80106894 <alltraps>

80107020 <vector22>:
.globl vector22
vector22:
  pushl $0
80107020:	6a 00                	push   $0x0
  pushl $22
80107022:	6a 16                	push   $0x16
  jmp alltraps
80107024:	e9 6b f8 ff ff       	jmp    80106894 <alltraps>

80107029 <vector23>:
.globl vector23
vector23:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $23
8010702b:	6a 17                	push   $0x17
  jmp alltraps
8010702d:	e9 62 f8 ff ff       	jmp    80106894 <alltraps>

80107032 <vector24>:
.globl vector24
vector24:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $24
80107034:	6a 18                	push   $0x18
  jmp alltraps
80107036:	e9 59 f8 ff ff       	jmp    80106894 <alltraps>

8010703b <vector25>:
.globl vector25
vector25:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $25
8010703d:	6a 19                	push   $0x19
  jmp alltraps
8010703f:	e9 50 f8 ff ff       	jmp    80106894 <alltraps>

80107044 <vector26>:
.globl vector26
vector26:
  pushl $0
80107044:	6a 00                	push   $0x0
  pushl $26
80107046:	6a 1a                	push   $0x1a
  jmp alltraps
80107048:	e9 47 f8 ff ff       	jmp    80106894 <alltraps>

8010704d <vector27>:
.globl vector27
vector27:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $27
8010704f:	6a 1b                	push   $0x1b
  jmp alltraps
80107051:	e9 3e f8 ff ff       	jmp    80106894 <alltraps>

80107056 <vector28>:
.globl vector28
vector28:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $28
80107058:	6a 1c                	push   $0x1c
  jmp alltraps
8010705a:	e9 35 f8 ff ff       	jmp    80106894 <alltraps>

8010705f <vector29>:
.globl vector29
vector29:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $29
80107061:	6a 1d                	push   $0x1d
  jmp alltraps
80107063:	e9 2c f8 ff ff       	jmp    80106894 <alltraps>

80107068 <vector30>:
.globl vector30
vector30:
  pushl $0
80107068:	6a 00                	push   $0x0
  pushl $30
8010706a:	6a 1e                	push   $0x1e
  jmp alltraps
8010706c:	e9 23 f8 ff ff       	jmp    80106894 <alltraps>

80107071 <vector31>:
.globl vector31
vector31:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $31
80107073:	6a 1f                	push   $0x1f
  jmp alltraps
80107075:	e9 1a f8 ff ff       	jmp    80106894 <alltraps>

8010707a <vector32>:
.globl vector32
vector32:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $32
8010707c:	6a 20                	push   $0x20
  jmp alltraps
8010707e:	e9 11 f8 ff ff       	jmp    80106894 <alltraps>

80107083 <vector33>:
.globl vector33
vector33:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $33
80107085:	6a 21                	push   $0x21
  jmp alltraps
80107087:	e9 08 f8 ff ff       	jmp    80106894 <alltraps>

8010708c <vector34>:
.globl vector34
vector34:
  pushl $0
8010708c:	6a 00                	push   $0x0
  pushl $34
8010708e:	6a 22                	push   $0x22
  jmp alltraps
80107090:	e9 ff f7 ff ff       	jmp    80106894 <alltraps>

80107095 <vector35>:
.globl vector35
vector35:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $35
80107097:	6a 23                	push   $0x23
  jmp alltraps
80107099:	e9 f6 f7 ff ff       	jmp    80106894 <alltraps>

8010709e <vector36>:
.globl vector36
vector36:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $36
801070a0:	6a 24                	push   $0x24
  jmp alltraps
801070a2:	e9 ed f7 ff ff       	jmp    80106894 <alltraps>

801070a7 <vector37>:
.globl vector37
vector37:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $37
801070a9:	6a 25                	push   $0x25
  jmp alltraps
801070ab:	e9 e4 f7 ff ff       	jmp    80106894 <alltraps>

801070b0 <vector38>:
.globl vector38
vector38:
  pushl $0
801070b0:	6a 00                	push   $0x0
  pushl $38
801070b2:	6a 26                	push   $0x26
  jmp alltraps
801070b4:	e9 db f7 ff ff       	jmp    80106894 <alltraps>

801070b9 <vector39>:
.globl vector39
vector39:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $39
801070bb:	6a 27                	push   $0x27
  jmp alltraps
801070bd:	e9 d2 f7 ff ff       	jmp    80106894 <alltraps>

801070c2 <vector40>:
.globl vector40
vector40:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $40
801070c4:	6a 28                	push   $0x28
  jmp alltraps
801070c6:	e9 c9 f7 ff ff       	jmp    80106894 <alltraps>

801070cb <vector41>:
.globl vector41
vector41:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $41
801070cd:	6a 29                	push   $0x29
  jmp alltraps
801070cf:	e9 c0 f7 ff ff       	jmp    80106894 <alltraps>

801070d4 <vector42>:
.globl vector42
vector42:
  pushl $0
801070d4:	6a 00                	push   $0x0
  pushl $42
801070d6:	6a 2a                	push   $0x2a
  jmp alltraps
801070d8:	e9 b7 f7 ff ff       	jmp    80106894 <alltraps>

801070dd <vector43>:
.globl vector43
vector43:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $43
801070df:	6a 2b                	push   $0x2b
  jmp alltraps
801070e1:	e9 ae f7 ff ff       	jmp    80106894 <alltraps>

801070e6 <vector44>:
.globl vector44
vector44:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $44
801070e8:	6a 2c                	push   $0x2c
  jmp alltraps
801070ea:	e9 a5 f7 ff ff       	jmp    80106894 <alltraps>

801070ef <vector45>:
.globl vector45
vector45:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $45
801070f1:	6a 2d                	push   $0x2d
  jmp alltraps
801070f3:	e9 9c f7 ff ff       	jmp    80106894 <alltraps>

801070f8 <vector46>:
.globl vector46
vector46:
  pushl $0
801070f8:	6a 00                	push   $0x0
  pushl $46
801070fa:	6a 2e                	push   $0x2e
  jmp alltraps
801070fc:	e9 93 f7 ff ff       	jmp    80106894 <alltraps>

80107101 <vector47>:
.globl vector47
vector47:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $47
80107103:	6a 2f                	push   $0x2f
  jmp alltraps
80107105:	e9 8a f7 ff ff       	jmp    80106894 <alltraps>

8010710a <vector48>:
.globl vector48
vector48:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $48
8010710c:	6a 30                	push   $0x30
  jmp alltraps
8010710e:	e9 81 f7 ff ff       	jmp    80106894 <alltraps>

80107113 <vector49>:
.globl vector49
vector49:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $49
80107115:	6a 31                	push   $0x31
  jmp alltraps
80107117:	e9 78 f7 ff ff       	jmp    80106894 <alltraps>

8010711c <vector50>:
.globl vector50
vector50:
  pushl $0
8010711c:	6a 00                	push   $0x0
  pushl $50
8010711e:	6a 32                	push   $0x32
  jmp alltraps
80107120:	e9 6f f7 ff ff       	jmp    80106894 <alltraps>

80107125 <vector51>:
.globl vector51
vector51:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $51
80107127:	6a 33                	push   $0x33
  jmp alltraps
80107129:	e9 66 f7 ff ff       	jmp    80106894 <alltraps>

8010712e <vector52>:
.globl vector52
vector52:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $52
80107130:	6a 34                	push   $0x34
  jmp alltraps
80107132:	e9 5d f7 ff ff       	jmp    80106894 <alltraps>

80107137 <vector53>:
.globl vector53
vector53:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $53
80107139:	6a 35                	push   $0x35
  jmp alltraps
8010713b:	e9 54 f7 ff ff       	jmp    80106894 <alltraps>

80107140 <vector54>:
.globl vector54
vector54:
  pushl $0
80107140:	6a 00                	push   $0x0
  pushl $54
80107142:	6a 36                	push   $0x36
  jmp alltraps
80107144:	e9 4b f7 ff ff       	jmp    80106894 <alltraps>

80107149 <vector55>:
.globl vector55
vector55:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $55
8010714b:	6a 37                	push   $0x37
  jmp alltraps
8010714d:	e9 42 f7 ff ff       	jmp    80106894 <alltraps>

80107152 <vector56>:
.globl vector56
vector56:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $56
80107154:	6a 38                	push   $0x38
  jmp alltraps
80107156:	e9 39 f7 ff ff       	jmp    80106894 <alltraps>

8010715b <vector57>:
.globl vector57
vector57:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $57
8010715d:	6a 39                	push   $0x39
  jmp alltraps
8010715f:	e9 30 f7 ff ff       	jmp    80106894 <alltraps>

80107164 <vector58>:
.globl vector58
vector58:
  pushl $0
80107164:	6a 00                	push   $0x0
  pushl $58
80107166:	6a 3a                	push   $0x3a
  jmp alltraps
80107168:	e9 27 f7 ff ff       	jmp    80106894 <alltraps>

8010716d <vector59>:
.globl vector59
vector59:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $59
8010716f:	6a 3b                	push   $0x3b
  jmp alltraps
80107171:	e9 1e f7 ff ff       	jmp    80106894 <alltraps>

80107176 <vector60>:
.globl vector60
vector60:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $60
80107178:	6a 3c                	push   $0x3c
  jmp alltraps
8010717a:	e9 15 f7 ff ff       	jmp    80106894 <alltraps>

8010717f <vector61>:
.globl vector61
vector61:
  pushl $0
8010717f:	6a 00                	push   $0x0
  pushl $61
80107181:	6a 3d                	push   $0x3d
  jmp alltraps
80107183:	e9 0c f7 ff ff       	jmp    80106894 <alltraps>

80107188 <vector62>:
.globl vector62
vector62:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $62
8010718a:	6a 3e                	push   $0x3e
  jmp alltraps
8010718c:	e9 03 f7 ff ff       	jmp    80106894 <alltraps>

80107191 <vector63>:
.globl vector63
vector63:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $63
80107193:	6a 3f                	push   $0x3f
  jmp alltraps
80107195:	e9 fa f6 ff ff       	jmp    80106894 <alltraps>

8010719a <vector64>:
.globl vector64
vector64:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $64
8010719c:	6a 40                	push   $0x40
  jmp alltraps
8010719e:	e9 f1 f6 ff ff       	jmp    80106894 <alltraps>

801071a3 <vector65>:
.globl vector65
vector65:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $65
801071a5:	6a 41                	push   $0x41
  jmp alltraps
801071a7:	e9 e8 f6 ff ff       	jmp    80106894 <alltraps>

801071ac <vector66>:
.globl vector66
vector66:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $66
801071ae:	6a 42                	push   $0x42
  jmp alltraps
801071b0:	e9 df f6 ff ff       	jmp    80106894 <alltraps>

801071b5 <vector67>:
.globl vector67
vector67:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $67
801071b7:	6a 43                	push   $0x43
  jmp alltraps
801071b9:	e9 d6 f6 ff ff       	jmp    80106894 <alltraps>

801071be <vector68>:
.globl vector68
vector68:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $68
801071c0:	6a 44                	push   $0x44
  jmp alltraps
801071c2:	e9 cd f6 ff ff       	jmp    80106894 <alltraps>

801071c7 <vector69>:
.globl vector69
vector69:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $69
801071c9:	6a 45                	push   $0x45
  jmp alltraps
801071cb:	e9 c4 f6 ff ff       	jmp    80106894 <alltraps>

801071d0 <vector70>:
.globl vector70
vector70:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $70
801071d2:	6a 46                	push   $0x46
  jmp alltraps
801071d4:	e9 bb f6 ff ff       	jmp    80106894 <alltraps>

801071d9 <vector71>:
.globl vector71
vector71:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $71
801071db:	6a 47                	push   $0x47
  jmp alltraps
801071dd:	e9 b2 f6 ff ff       	jmp    80106894 <alltraps>

801071e2 <vector72>:
.globl vector72
vector72:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $72
801071e4:	6a 48                	push   $0x48
  jmp alltraps
801071e6:	e9 a9 f6 ff ff       	jmp    80106894 <alltraps>

801071eb <vector73>:
.globl vector73
vector73:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $73
801071ed:	6a 49                	push   $0x49
  jmp alltraps
801071ef:	e9 a0 f6 ff ff       	jmp    80106894 <alltraps>

801071f4 <vector74>:
.globl vector74
vector74:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $74
801071f6:	6a 4a                	push   $0x4a
  jmp alltraps
801071f8:	e9 97 f6 ff ff       	jmp    80106894 <alltraps>

801071fd <vector75>:
.globl vector75
vector75:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $75
801071ff:	6a 4b                	push   $0x4b
  jmp alltraps
80107201:	e9 8e f6 ff ff       	jmp    80106894 <alltraps>

80107206 <vector76>:
.globl vector76
vector76:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $76
80107208:	6a 4c                	push   $0x4c
  jmp alltraps
8010720a:	e9 85 f6 ff ff       	jmp    80106894 <alltraps>

8010720f <vector77>:
.globl vector77
vector77:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $77
80107211:	6a 4d                	push   $0x4d
  jmp alltraps
80107213:	e9 7c f6 ff ff       	jmp    80106894 <alltraps>

80107218 <vector78>:
.globl vector78
vector78:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $78
8010721a:	6a 4e                	push   $0x4e
  jmp alltraps
8010721c:	e9 73 f6 ff ff       	jmp    80106894 <alltraps>

80107221 <vector79>:
.globl vector79
vector79:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $79
80107223:	6a 4f                	push   $0x4f
  jmp alltraps
80107225:	e9 6a f6 ff ff       	jmp    80106894 <alltraps>

8010722a <vector80>:
.globl vector80
vector80:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $80
8010722c:	6a 50                	push   $0x50
  jmp alltraps
8010722e:	e9 61 f6 ff ff       	jmp    80106894 <alltraps>

80107233 <vector81>:
.globl vector81
vector81:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $81
80107235:	6a 51                	push   $0x51
  jmp alltraps
80107237:	e9 58 f6 ff ff       	jmp    80106894 <alltraps>

8010723c <vector82>:
.globl vector82
vector82:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $82
8010723e:	6a 52                	push   $0x52
  jmp alltraps
80107240:	e9 4f f6 ff ff       	jmp    80106894 <alltraps>

80107245 <vector83>:
.globl vector83
vector83:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $83
80107247:	6a 53                	push   $0x53
  jmp alltraps
80107249:	e9 46 f6 ff ff       	jmp    80106894 <alltraps>

8010724e <vector84>:
.globl vector84
vector84:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $84
80107250:	6a 54                	push   $0x54
  jmp alltraps
80107252:	e9 3d f6 ff ff       	jmp    80106894 <alltraps>

80107257 <vector85>:
.globl vector85
vector85:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $85
80107259:	6a 55                	push   $0x55
  jmp alltraps
8010725b:	e9 34 f6 ff ff       	jmp    80106894 <alltraps>

80107260 <vector86>:
.globl vector86
vector86:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $86
80107262:	6a 56                	push   $0x56
  jmp alltraps
80107264:	e9 2b f6 ff ff       	jmp    80106894 <alltraps>

80107269 <vector87>:
.globl vector87
vector87:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $87
8010726b:	6a 57                	push   $0x57
  jmp alltraps
8010726d:	e9 22 f6 ff ff       	jmp    80106894 <alltraps>

80107272 <vector88>:
.globl vector88
vector88:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $88
80107274:	6a 58                	push   $0x58
  jmp alltraps
80107276:	e9 19 f6 ff ff       	jmp    80106894 <alltraps>

8010727b <vector89>:
.globl vector89
vector89:
  pushl $0
8010727b:	6a 00                	push   $0x0
  pushl $89
8010727d:	6a 59                	push   $0x59
  jmp alltraps
8010727f:	e9 10 f6 ff ff       	jmp    80106894 <alltraps>

80107284 <vector90>:
.globl vector90
vector90:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $90
80107286:	6a 5a                	push   $0x5a
  jmp alltraps
80107288:	e9 07 f6 ff ff       	jmp    80106894 <alltraps>

8010728d <vector91>:
.globl vector91
vector91:
  pushl $0
8010728d:	6a 00                	push   $0x0
  pushl $91
8010728f:	6a 5b                	push   $0x5b
  jmp alltraps
80107291:	e9 fe f5 ff ff       	jmp    80106894 <alltraps>

80107296 <vector92>:
.globl vector92
vector92:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $92
80107298:	6a 5c                	push   $0x5c
  jmp alltraps
8010729a:	e9 f5 f5 ff ff       	jmp    80106894 <alltraps>

8010729f <vector93>:
.globl vector93
vector93:
  pushl $0
8010729f:	6a 00                	push   $0x0
  pushl $93
801072a1:	6a 5d                	push   $0x5d
  jmp alltraps
801072a3:	e9 ec f5 ff ff       	jmp    80106894 <alltraps>

801072a8 <vector94>:
.globl vector94
vector94:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $94
801072aa:	6a 5e                	push   $0x5e
  jmp alltraps
801072ac:	e9 e3 f5 ff ff       	jmp    80106894 <alltraps>

801072b1 <vector95>:
.globl vector95
vector95:
  pushl $0
801072b1:	6a 00                	push   $0x0
  pushl $95
801072b3:	6a 5f                	push   $0x5f
  jmp alltraps
801072b5:	e9 da f5 ff ff       	jmp    80106894 <alltraps>

801072ba <vector96>:
.globl vector96
vector96:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $96
801072bc:	6a 60                	push   $0x60
  jmp alltraps
801072be:	e9 d1 f5 ff ff       	jmp    80106894 <alltraps>

801072c3 <vector97>:
.globl vector97
vector97:
  pushl $0
801072c3:	6a 00                	push   $0x0
  pushl $97
801072c5:	6a 61                	push   $0x61
  jmp alltraps
801072c7:	e9 c8 f5 ff ff       	jmp    80106894 <alltraps>

801072cc <vector98>:
.globl vector98
vector98:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $98
801072ce:	6a 62                	push   $0x62
  jmp alltraps
801072d0:	e9 bf f5 ff ff       	jmp    80106894 <alltraps>

801072d5 <vector99>:
.globl vector99
vector99:
  pushl $0
801072d5:	6a 00                	push   $0x0
  pushl $99
801072d7:	6a 63                	push   $0x63
  jmp alltraps
801072d9:	e9 b6 f5 ff ff       	jmp    80106894 <alltraps>

801072de <vector100>:
.globl vector100
vector100:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $100
801072e0:	6a 64                	push   $0x64
  jmp alltraps
801072e2:	e9 ad f5 ff ff       	jmp    80106894 <alltraps>

801072e7 <vector101>:
.globl vector101
vector101:
  pushl $0
801072e7:	6a 00                	push   $0x0
  pushl $101
801072e9:	6a 65                	push   $0x65
  jmp alltraps
801072eb:	e9 a4 f5 ff ff       	jmp    80106894 <alltraps>

801072f0 <vector102>:
.globl vector102
vector102:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $102
801072f2:	6a 66                	push   $0x66
  jmp alltraps
801072f4:	e9 9b f5 ff ff       	jmp    80106894 <alltraps>

801072f9 <vector103>:
.globl vector103
vector103:
  pushl $0
801072f9:	6a 00                	push   $0x0
  pushl $103
801072fb:	6a 67                	push   $0x67
  jmp alltraps
801072fd:	e9 92 f5 ff ff       	jmp    80106894 <alltraps>

80107302 <vector104>:
.globl vector104
vector104:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $104
80107304:	6a 68                	push   $0x68
  jmp alltraps
80107306:	e9 89 f5 ff ff       	jmp    80106894 <alltraps>

8010730b <vector105>:
.globl vector105
vector105:
  pushl $0
8010730b:	6a 00                	push   $0x0
  pushl $105
8010730d:	6a 69                	push   $0x69
  jmp alltraps
8010730f:	e9 80 f5 ff ff       	jmp    80106894 <alltraps>

80107314 <vector106>:
.globl vector106
vector106:
  pushl $0
80107314:	6a 00                	push   $0x0
  pushl $106
80107316:	6a 6a                	push   $0x6a
  jmp alltraps
80107318:	e9 77 f5 ff ff       	jmp    80106894 <alltraps>

8010731d <vector107>:
.globl vector107
vector107:
  pushl $0
8010731d:	6a 00                	push   $0x0
  pushl $107
8010731f:	6a 6b                	push   $0x6b
  jmp alltraps
80107321:	e9 6e f5 ff ff       	jmp    80106894 <alltraps>

80107326 <vector108>:
.globl vector108
vector108:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $108
80107328:	6a 6c                	push   $0x6c
  jmp alltraps
8010732a:	e9 65 f5 ff ff       	jmp    80106894 <alltraps>

8010732f <vector109>:
.globl vector109
vector109:
  pushl $0
8010732f:	6a 00                	push   $0x0
  pushl $109
80107331:	6a 6d                	push   $0x6d
  jmp alltraps
80107333:	e9 5c f5 ff ff       	jmp    80106894 <alltraps>

80107338 <vector110>:
.globl vector110
vector110:
  pushl $0
80107338:	6a 00                	push   $0x0
  pushl $110
8010733a:	6a 6e                	push   $0x6e
  jmp alltraps
8010733c:	e9 53 f5 ff ff       	jmp    80106894 <alltraps>

80107341 <vector111>:
.globl vector111
vector111:
  pushl $0
80107341:	6a 00                	push   $0x0
  pushl $111
80107343:	6a 6f                	push   $0x6f
  jmp alltraps
80107345:	e9 4a f5 ff ff       	jmp    80106894 <alltraps>

8010734a <vector112>:
.globl vector112
vector112:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $112
8010734c:	6a 70                	push   $0x70
  jmp alltraps
8010734e:	e9 41 f5 ff ff       	jmp    80106894 <alltraps>

80107353 <vector113>:
.globl vector113
vector113:
  pushl $0
80107353:	6a 00                	push   $0x0
  pushl $113
80107355:	6a 71                	push   $0x71
  jmp alltraps
80107357:	e9 38 f5 ff ff       	jmp    80106894 <alltraps>

8010735c <vector114>:
.globl vector114
vector114:
  pushl $0
8010735c:	6a 00                	push   $0x0
  pushl $114
8010735e:	6a 72                	push   $0x72
  jmp alltraps
80107360:	e9 2f f5 ff ff       	jmp    80106894 <alltraps>

80107365 <vector115>:
.globl vector115
vector115:
  pushl $0
80107365:	6a 00                	push   $0x0
  pushl $115
80107367:	6a 73                	push   $0x73
  jmp alltraps
80107369:	e9 26 f5 ff ff       	jmp    80106894 <alltraps>

8010736e <vector116>:
.globl vector116
vector116:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $116
80107370:	6a 74                	push   $0x74
  jmp alltraps
80107372:	e9 1d f5 ff ff       	jmp    80106894 <alltraps>

80107377 <vector117>:
.globl vector117
vector117:
  pushl $0
80107377:	6a 00                	push   $0x0
  pushl $117
80107379:	6a 75                	push   $0x75
  jmp alltraps
8010737b:	e9 14 f5 ff ff       	jmp    80106894 <alltraps>

80107380 <vector118>:
.globl vector118
vector118:
  pushl $0
80107380:	6a 00                	push   $0x0
  pushl $118
80107382:	6a 76                	push   $0x76
  jmp alltraps
80107384:	e9 0b f5 ff ff       	jmp    80106894 <alltraps>

80107389 <vector119>:
.globl vector119
vector119:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $119
8010738b:	6a 77                	push   $0x77
  jmp alltraps
8010738d:	e9 02 f5 ff ff       	jmp    80106894 <alltraps>

80107392 <vector120>:
.globl vector120
vector120:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $120
80107394:	6a 78                	push   $0x78
  jmp alltraps
80107396:	e9 f9 f4 ff ff       	jmp    80106894 <alltraps>

8010739b <vector121>:
.globl vector121
vector121:
  pushl $0
8010739b:	6a 00                	push   $0x0
  pushl $121
8010739d:	6a 79                	push   $0x79
  jmp alltraps
8010739f:	e9 f0 f4 ff ff       	jmp    80106894 <alltraps>

801073a4 <vector122>:
.globl vector122
vector122:
  pushl $0
801073a4:	6a 00                	push   $0x0
  pushl $122
801073a6:	6a 7a                	push   $0x7a
  jmp alltraps
801073a8:	e9 e7 f4 ff ff       	jmp    80106894 <alltraps>

801073ad <vector123>:
.globl vector123
vector123:
  pushl $0
801073ad:	6a 00                	push   $0x0
  pushl $123
801073af:	6a 7b                	push   $0x7b
  jmp alltraps
801073b1:	e9 de f4 ff ff       	jmp    80106894 <alltraps>

801073b6 <vector124>:
.globl vector124
vector124:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $124
801073b8:	6a 7c                	push   $0x7c
  jmp alltraps
801073ba:	e9 d5 f4 ff ff       	jmp    80106894 <alltraps>

801073bf <vector125>:
.globl vector125
vector125:
  pushl $0
801073bf:	6a 00                	push   $0x0
  pushl $125
801073c1:	6a 7d                	push   $0x7d
  jmp alltraps
801073c3:	e9 cc f4 ff ff       	jmp    80106894 <alltraps>

801073c8 <vector126>:
.globl vector126
vector126:
  pushl $0
801073c8:	6a 00                	push   $0x0
  pushl $126
801073ca:	6a 7e                	push   $0x7e
  jmp alltraps
801073cc:	e9 c3 f4 ff ff       	jmp    80106894 <alltraps>

801073d1 <vector127>:
.globl vector127
vector127:
  pushl $0
801073d1:	6a 00                	push   $0x0
  pushl $127
801073d3:	6a 7f                	push   $0x7f
  jmp alltraps
801073d5:	e9 ba f4 ff ff       	jmp    80106894 <alltraps>

801073da <vector128>:
.globl vector128
vector128:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $128
801073dc:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801073e1:	e9 ae f4 ff ff       	jmp    80106894 <alltraps>

801073e6 <vector129>:
.globl vector129
vector129:
  pushl $0
801073e6:	6a 00                	push   $0x0
  pushl $129
801073e8:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801073ed:	e9 a2 f4 ff ff       	jmp    80106894 <alltraps>

801073f2 <vector130>:
.globl vector130
vector130:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $130
801073f4:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801073f9:	e9 96 f4 ff ff       	jmp    80106894 <alltraps>

801073fe <vector131>:
.globl vector131
vector131:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $131
80107400:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107405:	e9 8a f4 ff ff       	jmp    80106894 <alltraps>

8010740a <vector132>:
.globl vector132
vector132:
  pushl $0
8010740a:	6a 00                	push   $0x0
  pushl $132
8010740c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107411:	e9 7e f4 ff ff       	jmp    80106894 <alltraps>

80107416 <vector133>:
.globl vector133
vector133:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $133
80107418:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010741d:	e9 72 f4 ff ff       	jmp    80106894 <alltraps>

80107422 <vector134>:
.globl vector134
vector134:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $134
80107424:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107429:	e9 66 f4 ff ff       	jmp    80106894 <alltraps>

8010742e <vector135>:
.globl vector135
vector135:
  pushl $0
8010742e:	6a 00                	push   $0x0
  pushl $135
80107430:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107435:	e9 5a f4 ff ff       	jmp    80106894 <alltraps>

8010743a <vector136>:
.globl vector136
vector136:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $136
8010743c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107441:	e9 4e f4 ff ff       	jmp    80106894 <alltraps>

80107446 <vector137>:
.globl vector137
vector137:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $137
80107448:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010744d:	e9 42 f4 ff ff       	jmp    80106894 <alltraps>

80107452 <vector138>:
.globl vector138
vector138:
  pushl $0
80107452:	6a 00                	push   $0x0
  pushl $138
80107454:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107459:	e9 36 f4 ff ff       	jmp    80106894 <alltraps>

8010745e <vector139>:
.globl vector139
vector139:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $139
80107460:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107465:	e9 2a f4 ff ff       	jmp    80106894 <alltraps>

8010746a <vector140>:
.globl vector140
vector140:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $140
8010746c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107471:	e9 1e f4 ff ff       	jmp    80106894 <alltraps>

80107476 <vector141>:
.globl vector141
vector141:
  pushl $0
80107476:	6a 00                	push   $0x0
  pushl $141
80107478:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010747d:	e9 12 f4 ff ff       	jmp    80106894 <alltraps>

80107482 <vector142>:
.globl vector142
vector142:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $142
80107484:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107489:	e9 06 f4 ff ff       	jmp    80106894 <alltraps>

8010748e <vector143>:
.globl vector143
vector143:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $143
80107490:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107495:	e9 fa f3 ff ff       	jmp    80106894 <alltraps>

8010749a <vector144>:
.globl vector144
vector144:
  pushl $0
8010749a:	6a 00                	push   $0x0
  pushl $144
8010749c:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801074a1:	e9 ee f3 ff ff       	jmp    80106894 <alltraps>

801074a6 <vector145>:
.globl vector145
vector145:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $145
801074a8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801074ad:	e9 e2 f3 ff ff       	jmp    80106894 <alltraps>

801074b2 <vector146>:
.globl vector146
vector146:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $146
801074b4:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801074b9:	e9 d6 f3 ff ff       	jmp    80106894 <alltraps>

801074be <vector147>:
.globl vector147
vector147:
  pushl $0
801074be:	6a 00                	push   $0x0
  pushl $147
801074c0:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801074c5:	e9 ca f3 ff ff       	jmp    80106894 <alltraps>

801074ca <vector148>:
.globl vector148
vector148:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $148
801074cc:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801074d1:	e9 be f3 ff ff       	jmp    80106894 <alltraps>

801074d6 <vector149>:
.globl vector149
vector149:
  pushl $0
801074d6:	6a 00                	push   $0x0
  pushl $149
801074d8:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801074dd:	e9 b2 f3 ff ff       	jmp    80106894 <alltraps>

801074e2 <vector150>:
.globl vector150
vector150:
  pushl $0
801074e2:	6a 00                	push   $0x0
  pushl $150
801074e4:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801074e9:	e9 a6 f3 ff ff       	jmp    80106894 <alltraps>

801074ee <vector151>:
.globl vector151
vector151:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $151
801074f0:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801074f5:	e9 9a f3 ff ff       	jmp    80106894 <alltraps>

801074fa <vector152>:
.globl vector152
vector152:
  pushl $0
801074fa:	6a 00                	push   $0x0
  pushl $152
801074fc:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107501:	e9 8e f3 ff ff       	jmp    80106894 <alltraps>

80107506 <vector153>:
.globl vector153
vector153:
  pushl $0
80107506:	6a 00                	push   $0x0
  pushl $153
80107508:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010750d:	e9 82 f3 ff ff       	jmp    80106894 <alltraps>

80107512 <vector154>:
.globl vector154
vector154:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $154
80107514:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107519:	e9 76 f3 ff ff       	jmp    80106894 <alltraps>

8010751e <vector155>:
.globl vector155
vector155:
  pushl $0
8010751e:	6a 00                	push   $0x0
  pushl $155
80107520:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107525:	e9 6a f3 ff ff       	jmp    80106894 <alltraps>

8010752a <vector156>:
.globl vector156
vector156:
  pushl $0
8010752a:	6a 00                	push   $0x0
  pushl $156
8010752c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107531:	e9 5e f3 ff ff       	jmp    80106894 <alltraps>

80107536 <vector157>:
.globl vector157
vector157:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $157
80107538:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010753d:	e9 52 f3 ff ff       	jmp    80106894 <alltraps>

80107542 <vector158>:
.globl vector158
vector158:
  pushl $0
80107542:	6a 00                	push   $0x0
  pushl $158
80107544:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107549:	e9 46 f3 ff ff       	jmp    80106894 <alltraps>

8010754e <vector159>:
.globl vector159
vector159:
  pushl $0
8010754e:	6a 00                	push   $0x0
  pushl $159
80107550:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107555:	e9 3a f3 ff ff       	jmp    80106894 <alltraps>

8010755a <vector160>:
.globl vector160
vector160:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $160
8010755c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107561:	e9 2e f3 ff ff       	jmp    80106894 <alltraps>

80107566 <vector161>:
.globl vector161
vector161:
  pushl $0
80107566:	6a 00                	push   $0x0
  pushl $161
80107568:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010756d:	e9 22 f3 ff ff       	jmp    80106894 <alltraps>

80107572 <vector162>:
.globl vector162
vector162:
  pushl $0
80107572:	6a 00                	push   $0x0
  pushl $162
80107574:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107579:	e9 16 f3 ff ff       	jmp    80106894 <alltraps>

8010757e <vector163>:
.globl vector163
vector163:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $163
80107580:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107585:	e9 0a f3 ff ff       	jmp    80106894 <alltraps>

8010758a <vector164>:
.globl vector164
vector164:
  pushl $0
8010758a:	6a 00                	push   $0x0
  pushl $164
8010758c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107591:	e9 fe f2 ff ff       	jmp    80106894 <alltraps>

80107596 <vector165>:
.globl vector165
vector165:
  pushl $0
80107596:	6a 00                	push   $0x0
  pushl $165
80107598:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010759d:	e9 f2 f2 ff ff       	jmp    80106894 <alltraps>

801075a2 <vector166>:
.globl vector166
vector166:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $166
801075a4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801075a9:	e9 e6 f2 ff ff       	jmp    80106894 <alltraps>

801075ae <vector167>:
.globl vector167
vector167:
  pushl $0
801075ae:	6a 00                	push   $0x0
  pushl $167
801075b0:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801075b5:	e9 da f2 ff ff       	jmp    80106894 <alltraps>

801075ba <vector168>:
.globl vector168
vector168:
  pushl $0
801075ba:	6a 00                	push   $0x0
  pushl $168
801075bc:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801075c1:	e9 ce f2 ff ff       	jmp    80106894 <alltraps>

801075c6 <vector169>:
.globl vector169
vector169:
  pushl $0
801075c6:	6a 00                	push   $0x0
  pushl $169
801075c8:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801075cd:	e9 c2 f2 ff ff       	jmp    80106894 <alltraps>

801075d2 <vector170>:
.globl vector170
vector170:
  pushl $0
801075d2:	6a 00                	push   $0x0
  pushl $170
801075d4:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801075d9:	e9 b6 f2 ff ff       	jmp    80106894 <alltraps>

801075de <vector171>:
.globl vector171
vector171:
  pushl $0
801075de:	6a 00                	push   $0x0
  pushl $171
801075e0:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801075e5:	e9 aa f2 ff ff       	jmp    80106894 <alltraps>

801075ea <vector172>:
.globl vector172
vector172:
  pushl $0
801075ea:	6a 00                	push   $0x0
  pushl $172
801075ec:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801075f1:	e9 9e f2 ff ff       	jmp    80106894 <alltraps>

801075f6 <vector173>:
.globl vector173
vector173:
  pushl $0
801075f6:	6a 00                	push   $0x0
  pushl $173
801075f8:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801075fd:	e9 92 f2 ff ff       	jmp    80106894 <alltraps>

80107602 <vector174>:
.globl vector174
vector174:
  pushl $0
80107602:	6a 00                	push   $0x0
  pushl $174
80107604:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107609:	e9 86 f2 ff ff       	jmp    80106894 <alltraps>

8010760e <vector175>:
.globl vector175
vector175:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $175
80107610:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107615:	e9 7a f2 ff ff       	jmp    80106894 <alltraps>

8010761a <vector176>:
.globl vector176
vector176:
  pushl $0
8010761a:	6a 00                	push   $0x0
  pushl $176
8010761c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107621:	e9 6e f2 ff ff       	jmp    80106894 <alltraps>

80107626 <vector177>:
.globl vector177
vector177:
  pushl $0
80107626:	6a 00                	push   $0x0
  pushl $177
80107628:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010762d:	e9 62 f2 ff ff       	jmp    80106894 <alltraps>

80107632 <vector178>:
.globl vector178
vector178:
  pushl $0
80107632:	6a 00                	push   $0x0
  pushl $178
80107634:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107639:	e9 56 f2 ff ff       	jmp    80106894 <alltraps>

8010763e <vector179>:
.globl vector179
vector179:
  pushl $0
8010763e:	6a 00                	push   $0x0
  pushl $179
80107640:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107645:	e9 4a f2 ff ff       	jmp    80106894 <alltraps>

8010764a <vector180>:
.globl vector180
vector180:
  pushl $0
8010764a:	6a 00                	push   $0x0
  pushl $180
8010764c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107651:	e9 3e f2 ff ff       	jmp    80106894 <alltraps>

80107656 <vector181>:
.globl vector181
vector181:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $181
80107658:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010765d:	e9 32 f2 ff ff       	jmp    80106894 <alltraps>

80107662 <vector182>:
.globl vector182
vector182:
  pushl $0
80107662:	6a 00                	push   $0x0
  pushl $182
80107664:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107669:	e9 26 f2 ff ff       	jmp    80106894 <alltraps>

8010766e <vector183>:
.globl vector183
vector183:
  pushl $0
8010766e:	6a 00                	push   $0x0
  pushl $183
80107670:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107675:	e9 1a f2 ff ff       	jmp    80106894 <alltraps>

8010767a <vector184>:
.globl vector184
vector184:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $184
8010767c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107681:	e9 0e f2 ff ff       	jmp    80106894 <alltraps>

80107686 <vector185>:
.globl vector185
vector185:
  pushl $0
80107686:	6a 00                	push   $0x0
  pushl $185
80107688:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010768d:	e9 02 f2 ff ff       	jmp    80106894 <alltraps>

80107692 <vector186>:
.globl vector186
vector186:
  pushl $0
80107692:	6a 00                	push   $0x0
  pushl $186
80107694:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107699:	e9 f6 f1 ff ff       	jmp    80106894 <alltraps>

8010769e <vector187>:
.globl vector187
vector187:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $187
801076a0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801076a5:	e9 ea f1 ff ff       	jmp    80106894 <alltraps>

801076aa <vector188>:
.globl vector188
vector188:
  pushl $0
801076aa:	6a 00                	push   $0x0
  pushl $188
801076ac:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801076b1:	e9 de f1 ff ff       	jmp    80106894 <alltraps>

801076b6 <vector189>:
.globl vector189
vector189:
  pushl $0
801076b6:	6a 00                	push   $0x0
  pushl $189
801076b8:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801076bd:	e9 d2 f1 ff ff       	jmp    80106894 <alltraps>

801076c2 <vector190>:
.globl vector190
vector190:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $190
801076c4:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801076c9:	e9 c6 f1 ff ff       	jmp    80106894 <alltraps>

801076ce <vector191>:
.globl vector191
vector191:
  pushl $0
801076ce:	6a 00                	push   $0x0
  pushl $191
801076d0:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801076d5:	e9 ba f1 ff ff       	jmp    80106894 <alltraps>

801076da <vector192>:
.globl vector192
vector192:
  pushl $0
801076da:	6a 00                	push   $0x0
  pushl $192
801076dc:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801076e1:	e9 ae f1 ff ff       	jmp    80106894 <alltraps>

801076e6 <vector193>:
.globl vector193
vector193:
  pushl $0
801076e6:	6a 00                	push   $0x0
  pushl $193
801076e8:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801076ed:	e9 a2 f1 ff ff       	jmp    80106894 <alltraps>

801076f2 <vector194>:
.globl vector194
vector194:
  pushl $0
801076f2:	6a 00                	push   $0x0
  pushl $194
801076f4:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801076f9:	e9 96 f1 ff ff       	jmp    80106894 <alltraps>

801076fe <vector195>:
.globl vector195
vector195:
  pushl $0
801076fe:	6a 00                	push   $0x0
  pushl $195
80107700:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107705:	e9 8a f1 ff ff       	jmp    80106894 <alltraps>

8010770a <vector196>:
.globl vector196
vector196:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $196
8010770c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107711:	e9 7e f1 ff ff       	jmp    80106894 <alltraps>

80107716 <vector197>:
.globl vector197
vector197:
  pushl $0
80107716:	6a 00                	push   $0x0
  pushl $197
80107718:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010771d:	e9 72 f1 ff ff       	jmp    80106894 <alltraps>

80107722 <vector198>:
.globl vector198
vector198:
  pushl $0
80107722:	6a 00                	push   $0x0
  pushl $198
80107724:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107729:	e9 66 f1 ff ff       	jmp    80106894 <alltraps>

8010772e <vector199>:
.globl vector199
vector199:
  pushl $0
8010772e:	6a 00                	push   $0x0
  pushl $199
80107730:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107735:	e9 5a f1 ff ff       	jmp    80106894 <alltraps>

8010773a <vector200>:
.globl vector200
vector200:
  pushl $0
8010773a:	6a 00                	push   $0x0
  pushl $200
8010773c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107741:	e9 4e f1 ff ff       	jmp    80106894 <alltraps>

80107746 <vector201>:
.globl vector201
vector201:
  pushl $0
80107746:	6a 00                	push   $0x0
  pushl $201
80107748:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010774d:	e9 42 f1 ff ff       	jmp    80106894 <alltraps>

80107752 <vector202>:
.globl vector202
vector202:
  pushl $0
80107752:	6a 00                	push   $0x0
  pushl $202
80107754:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107759:	e9 36 f1 ff ff       	jmp    80106894 <alltraps>

8010775e <vector203>:
.globl vector203
vector203:
  pushl $0
8010775e:	6a 00                	push   $0x0
  pushl $203
80107760:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107765:	e9 2a f1 ff ff       	jmp    80106894 <alltraps>

8010776a <vector204>:
.globl vector204
vector204:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $204
8010776c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107771:	e9 1e f1 ff ff       	jmp    80106894 <alltraps>

80107776 <vector205>:
.globl vector205
vector205:
  pushl $0
80107776:	6a 00                	push   $0x0
  pushl $205
80107778:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010777d:	e9 12 f1 ff ff       	jmp    80106894 <alltraps>

80107782 <vector206>:
.globl vector206
vector206:
  pushl $0
80107782:	6a 00                	push   $0x0
  pushl $206
80107784:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107789:	e9 06 f1 ff ff       	jmp    80106894 <alltraps>

8010778e <vector207>:
.globl vector207
vector207:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $207
80107790:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107795:	e9 fa f0 ff ff       	jmp    80106894 <alltraps>

8010779a <vector208>:
.globl vector208
vector208:
  pushl $0
8010779a:	6a 00                	push   $0x0
  pushl $208
8010779c:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801077a1:	e9 ee f0 ff ff       	jmp    80106894 <alltraps>

801077a6 <vector209>:
.globl vector209
vector209:
  pushl $0
801077a6:	6a 00                	push   $0x0
  pushl $209
801077a8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801077ad:	e9 e2 f0 ff ff       	jmp    80106894 <alltraps>

801077b2 <vector210>:
.globl vector210
vector210:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $210
801077b4:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801077b9:	e9 d6 f0 ff ff       	jmp    80106894 <alltraps>

801077be <vector211>:
.globl vector211
vector211:
  pushl $0
801077be:	6a 00                	push   $0x0
  pushl $211
801077c0:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801077c5:	e9 ca f0 ff ff       	jmp    80106894 <alltraps>

801077ca <vector212>:
.globl vector212
vector212:
  pushl $0
801077ca:	6a 00                	push   $0x0
  pushl $212
801077cc:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801077d1:	e9 be f0 ff ff       	jmp    80106894 <alltraps>

801077d6 <vector213>:
.globl vector213
vector213:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $213
801077d8:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801077dd:	e9 b2 f0 ff ff       	jmp    80106894 <alltraps>

801077e2 <vector214>:
.globl vector214
vector214:
  pushl $0
801077e2:	6a 00                	push   $0x0
  pushl $214
801077e4:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801077e9:	e9 a6 f0 ff ff       	jmp    80106894 <alltraps>

801077ee <vector215>:
.globl vector215
vector215:
  pushl $0
801077ee:	6a 00                	push   $0x0
  pushl $215
801077f0:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801077f5:	e9 9a f0 ff ff       	jmp    80106894 <alltraps>

801077fa <vector216>:
.globl vector216
vector216:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $216
801077fc:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107801:	e9 8e f0 ff ff       	jmp    80106894 <alltraps>

80107806 <vector217>:
.globl vector217
vector217:
  pushl $0
80107806:	6a 00                	push   $0x0
  pushl $217
80107808:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010780d:	e9 82 f0 ff ff       	jmp    80106894 <alltraps>

80107812 <vector218>:
.globl vector218
vector218:
  pushl $0
80107812:	6a 00                	push   $0x0
  pushl $218
80107814:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107819:	e9 76 f0 ff ff       	jmp    80106894 <alltraps>

8010781e <vector219>:
.globl vector219
vector219:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $219
80107820:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107825:	e9 6a f0 ff ff       	jmp    80106894 <alltraps>

8010782a <vector220>:
.globl vector220
vector220:
  pushl $0
8010782a:	6a 00                	push   $0x0
  pushl $220
8010782c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107831:	e9 5e f0 ff ff       	jmp    80106894 <alltraps>

80107836 <vector221>:
.globl vector221
vector221:
  pushl $0
80107836:	6a 00                	push   $0x0
  pushl $221
80107838:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010783d:	e9 52 f0 ff ff       	jmp    80106894 <alltraps>

80107842 <vector222>:
.globl vector222
vector222:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $222
80107844:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107849:	e9 46 f0 ff ff       	jmp    80106894 <alltraps>

8010784e <vector223>:
.globl vector223
vector223:
  pushl $0
8010784e:	6a 00                	push   $0x0
  pushl $223
80107850:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107855:	e9 3a f0 ff ff       	jmp    80106894 <alltraps>

8010785a <vector224>:
.globl vector224
vector224:
  pushl $0
8010785a:	6a 00                	push   $0x0
  pushl $224
8010785c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107861:	e9 2e f0 ff ff       	jmp    80106894 <alltraps>

80107866 <vector225>:
.globl vector225
vector225:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $225
80107868:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010786d:	e9 22 f0 ff ff       	jmp    80106894 <alltraps>

80107872 <vector226>:
.globl vector226
vector226:
  pushl $0
80107872:	6a 00                	push   $0x0
  pushl $226
80107874:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107879:	e9 16 f0 ff ff       	jmp    80106894 <alltraps>

8010787e <vector227>:
.globl vector227
vector227:
  pushl $0
8010787e:	6a 00                	push   $0x0
  pushl $227
80107880:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107885:	e9 0a f0 ff ff       	jmp    80106894 <alltraps>

8010788a <vector228>:
.globl vector228
vector228:
  pushl $0
8010788a:	6a 00                	push   $0x0
  pushl $228
8010788c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107891:	e9 fe ef ff ff       	jmp    80106894 <alltraps>

80107896 <vector229>:
.globl vector229
vector229:
  pushl $0
80107896:	6a 00                	push   $0x0
  pushl $229
80107898:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010789d:	e9 f2 ef ff ff       	jmp    80106894 <alltraps>

801078a2 <vector230>:
.globl vector230
vector230:
  pushl $0
801078a2:	6a 00                	push   $0x0
  pushl $230
801078a4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801078a9:	e9 e6 ef ff ff       	jmp    80106894 <alltraps>

801078ae <vector231>:
.globl vector231
vector231:
  pushl $0
801078ae:	6a 00                	push   $0x0
  pushl $231
801078b0:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801078b5:	e9 da ef ff ff       	jmp    80106894 <alltraps>

801078ba <vector232>:
.globl vector232
vector232:
  pushl $0
801078ba:	6a 00                	push   $0x0
  pushl $232
801078bc:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801078c1:	e9 ce ef ff ff       	jmp    80106894 <alltraps>

801078c6 <vector233>:
.globl vector233
vector233:
  pushl $0
801078c6:	6a 00                	push   $0x0
  pushl $233
801078c8:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801078cd:	e9 c2 ef ff ff       	jmp    80106894 <alltraps>

801078d2 <vector234>:
.globl vector234
vector234:
  pushl $0
801078d2:	6a 00                	push   $0x0
  pushl $234
801078d4:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801078d9:	e9 b6 ef ff ff       	jmp    80106894 <alltraps>

801078de <vector235>:
.globl vector235
vector235:
  pushl $0
801078de:	6a 00                	push   $0x0
  pushl $235
801078e0:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801078e5:	e9 aa ef ff ff       	jmp    80106894 <alltraps>

801078ea <vector236>:
.globl vector236
vector236:
  pushl $0
801078ea:	6a 00                	push   $0x0
  pushl $236
801078ec:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801078f1:	e9 9e ef ff ff       	jmp    80106894 <alltraps>

801078f6 <vector237>:
.globl vector237
vector237:
  pushl $0
801078f6:	6a 00                	push   $0x0
  pushl $237
801078f8:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801078fd:	e9 92 ef ff ff       	jmp    80106894 <alltraps>

80107902 <vector238>:
.globl vector238
vector238:
  pushl $0
80107902:	6a 00                	push   $0x0
  pushl $238
80107904:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107909:	e9 86 ef ff ff       	jmp    80106894 <alltraps>

8010790e <vector239>:
.globl vector239
vector239:
  pushl $0
8010790e:	6a 00                	push   $0x0
  pushl $239
80107910:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107915:	e9 7a ef ff ff       	jmp    80106894 <alltraps>

8010791a <vector240>:
.globl vector240
vector240:
  pushl $0
8010791a:	6a 00                	push   $0x0
  pushl $240
8010791c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107921:	e9 6e ef ff ff       	jmp    80106894 <alltraps>

80107926 <vector241>:
.globl vector241
vector241:
  pushl $0
80107926:	6a 00                	push   $0x0
  pushl $241
80107928:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010792d:	e9 62 ef ff ff       	jmp    80106894 <alltraps>

80107932 <vector242>:
.globl vector242
vector242:
  pushl $0
80107932:	6a 00                	push   $0x0
  pushl $242
80107934:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107939:	e9 56 ef ff ff       	jmp    80106894 <alltraps>

8010793e <vector243>:
.globl vector243
vector243:
  pushl $0
8010793e:	6a 00                	push   $0x0
  pushl $243
80107940:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107945:	e9 4a ef ff ff       	jmp    80106894 <alltraps>

8010794a <vector244>:
.globl vector244
vector244:
  pushl $0
8010794a:	6a 00                	push   $0x0
  pushl $244
8010794c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107951:	e9 3e ef ff ff       	jmp    80106894 <alltraps>

80107956 <vector245>:
.globl vector245
vector245:
  pushl $0
80107956:	6a 00                	push   $0x0
  pushl $245
80107958:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010795d:	e9 32 ef ff ff       	jmp    80106894 <alltraps>

80107962 <vector246>:
.globl vector246
vector246:
  pushl $0
80107962:	6a 00                	push   $0x0
  pushl $246
80107964:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107969:	e9 26 ef ff ff       	jmp    80106894 <alltraps>

8010796e <vector247>:
.globl vector247
vector247:
  pushl $0
8010796e:	6a 00                	push   $0x0
  pushl $247
80107970:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107975:	e9 1a ef ff ff       	jmp    80106894 <alltraps>

8010797a <vector248>:
.globl vector248
vector248:
  pushl $0
8010797a:	6a 00                	push   $0x0
  pushl $248
8010797c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107981:	e9 0e ef ff ff       	jmp    80106894 <alltraps>

80107986 <vector249>:
.globl vector249
vector249:
  pushl $0
80107986:	6a 00                	push   $0x0
  pushl $249
80107988:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010798d:	e9 02 ef ff ff       	jmp    80106894 <alltraps>

80107992 <vector250>:
.globl vector250
vector250:
  pushl $0
80107992:	6a 00                	push   $0x0
  pushl $250
80107994:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107999:	e9 f6 ee ff ff       	jmp    80106894 <alltraps>

8010799e <vector251>:
.globl vector251
vector251:
  pushl $0
8010799e:	6a 00                	push   $0x0
  pushl $251
801079a0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801079a5:	e9 ea ee ff ff       	jmp    80106894 <alltraps>

801079aa <vector252>:
.globl vector252
vector252:
  pushl $0
801079aa:	6a 00                	push   $0x0
  pushl $252
801079ac:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801079b1:	e9 de ee ff ff       	jmp    80106894 <alltraps>

801079b6 <vector253>:
.globl vector253
vector253:
  pushl $0
801079b6:	6a 00                	push   $0x0
  pushl $253
801079b8:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801079bd:	e9 d2 ee ff ff       	jmp    80106894 <alltraps>

801079c2 <vector254>:
.globl vector254
vector254:
  pushl $0
801079c2:	6a 00                	push   $0x0
  pushl $254
801079c4:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801079c9:	e9 c6 ee ff ff       	jmp    80106894 <alltraps>

801079ce <vector255>:
.globl vector255
vector255:
  pushl $0
801079ce:	6a 00                	push   $0x0
  pushl $255
801079d0:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801079d5:	e9 ba ee ff ff       	jmp    80106894 <alltraps>
	...

801079dc <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801079dc:	55                   	push   %ebp
801079dd:	89 e5                	mov    %esp,%ebp
801079df:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801079e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801079e5:	83 e8 01             	sub    $0x1,%eax
801079e8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801079ec:	8b 45 08             	mov    0x8(%ebp),%eax
801079ef:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801079f3:	8b 45 08             	mov    0x8(%ebp),%eax
801079f6:	c1 e8 10             	shr    $0x10,%eax
801079f9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801079fd:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107a00:	0f 01 10             	lgdtl  (%eax)
}
80107a03:	c9                   	leave  
80107a04:	c3                   	ret    

80107a05 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107a05:	55                   	push   %ebp
80107a06:	89 e5                	mov    %esp,%ebp
80107a08:	83 ec 04             	sub    $0x4,%esp
80107a0b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a0e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107a12:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a16:	0f 00 d8             	ltr    %ax
}
80107a19:	c9                   	leave  
80107a1a:	c3                   	ret    

80107a1b <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107a1b:	55                   	push   %ebp
80107a1c:	89 e5                	mov    %esp,%ebp
80107a1e:	83 ec 04             	sub    $0x4,%esp
80107a21:	8b 45 08             	mov    0x8(%ebp),%eax
80107a24:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107a28:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a2c:	8e e8                	mov    %eax,%gs
}
80107a2e:	c9                   	leave  
80107a2f:	c3                   	ret    

80107a30 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107a30:	55                   	push   %ebp
80107a31:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a33:	8b 45 08             	mov    0x8(%ebp),%eax
80107a36:	0f 22 d8             	mov    %eax,%cr3
}
80107a39:	5d                   	pop    %ebp
80107a3a:	c3                   	ret    

80107a3b <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107a3b:	55                   	push   %ebp
80107a3c:	89 e5                	mov    %esp,%ebp
80107a3e:	8b 45 08             	mov    0x8(%ebp),%eax
80107a41:	05 00 00 00 80       	add    $0x80000000,%eax
80107a46:	5d                   	pop    %ebp
80107a47:	c3                   	ret    

80107a48 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107a48:	55                   	push   %ebp
80107a49:	89 e5                	mov    %esp,%ebp
80107a4b:	8b 45 08             	mov    0x8(%ebp),%eax
80107a4e:	05 00 00 00 80       	add    $0x80000000,%eax
80107a53:	5d                   	pop    %ebp
80107a54:	c3                   	ret    

80107a55 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a55:	55                   	push   %ebp
80107a56:	89 e5                	mov    %esp,%ebp
80107a58:	53                   	push   %ebx
80107a59:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107a5c:	e8 08 b7 ff ff       	call   80103169 <cpunum>
80107a61:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107a67:	05 40 f9 10 80       	add    $0x8010f940,%eax
80107a6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a72:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7b:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a84:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a8f:	83 e2 f0             	and    $0xfffffff0,%edx
80107a92:	83 ca 0a             	or     $0xa,%edx
80107a95:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a9f:	83 ca 10             	or     $0x10,%edx
80107aa2:	88 50 7d             	mov    %dl,0x7d(%eax)
80107aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107aac:	83 e2 9f             	and    $0xffffff9f,%edx
80107aaf:	88 50 7d             	mov    %dl,0x7d(%eax)
80107ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ab9:	83 ca 80             	or     $0xffffff80,%edx
80107abc:	88 50 7d             	mov    %dl,0x7d(%eax)
80107abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac2:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ac6:	83 ca 0f             	or     $0xf,%edx
80107ac9:	88 50 7e             	mov    %dl,0x7e(%eax)
80107acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acf:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ad3:	83 e2 ef             	and    $0xffffffef,%edx
80107ad6:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ae0:	83 e2 df             	and    $0xffffffdf,%edx
80107ae3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae9:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107aed:	83 ca 40             	or     $0x40,%edx
80107af0:	88 50 7e             	mov    %dl,0x7e(%eax)
80107af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af6:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107afa:	83 ca 80             	or     $0xffffff80,%edx
80107afd:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b03:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b11:	ff ff 
80107b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b16:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b1d:	00 00 
80107b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b22:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b33:	83 e2 f0             	and    $0xfffffff0,%edx
80107b36:	83 ca 02             	or     $0x2,%edx
80107b39:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b42:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b49:	83 ca 10             	or     $0x10,%edx
80107b4c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b55:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b5c:	83 e2 9f             	and    $0xffffff9f,%edx
80107b5f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b68:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b6f:	83 ca 80             	or     $0xffffff80,%edx
80107b72:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b82:	83 ca 0f             	or     $0xf,%edx
80107b85:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b95:	83 e2 ef             	and    $0xffffffef,%edx
80107b98:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ba8:	83 e2 df             	and    $0xffffffdf,%edx
80107bab:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bbb:	83 ca 40             	or     $0x40,%edx
80107bbe:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107bce:	83 ca 80             	or     $0xffffff80,%edx
80107bd1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bda:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be4:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107beb:	ff ff 
80107bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf0:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107bf7:	00 00 
80107bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfc:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c06:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c0d:	83 e2 f0             	and    $0xfffffff0,%edx
80107c10:	83 ca 0a             	or     $0xa,%edx
80107c13:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c23:	83 ca 10             	or     $0x10,%edx
80107c26:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c36:	83 ca 60             	or     $0x60,%edx
80107c39:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c42:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c49:	83 ca 80             	or     $0xffffff80,%edx
80107c4c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c55:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c5c:	83 ca 0f             	or     $0xf,%edx
80107c5f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c68:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c6f:	83 e2 ef             	and    $0xffffffef,%edx
80107c72:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c7b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c82:	83 e2 df             	and    $0xffffffdf,%edx
80107c85:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c95:	83 ca 40             	or     $0x40,%edx
80107c98:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ca8:	83 ca 80             	or     $0xffffff80,%edx
80107cab:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb4:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbe:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107cc5:	ff ff 
80107cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cca:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107cd1:	00 00 
80107cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd6:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ce7:	83 e2 f0             	and    $0xfffffff0,%edx
80107cea:	83 ca 02             	or     $0x2,%edx
80107ced:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf6:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cfd:	83 ca 10             	or     $0x10,%edx
80107d00:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d09:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d10:	83 ca 60             	or     $0x60,%edx
80107d13:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107d23:	83 ca 80             	or     $0xffffff80,%edx
80107d26:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d36:	83 ca 0f             	or     $0xf,%edx
80107d39:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d42:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d49:	83 e2 ef             	and    $0xffffffef,%edx
80107d4c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d55:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d5c:	83 e2 df             	and    $0xffffffdf,%edx
80107d5f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d68:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d6f:	83 ca 40             	or     $0x40,%edx
80107d72:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d82:	83 ca 80             	or     $0xffffff80,%edx
80107d85:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8e:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d98:	05 b4 00 00 00       	add    $0xb4,%eax
80107d9d:	89 c3                	mov    %eax,%ebx
80107d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da2:	05 b4 00 00 00       	add    $0xb4,%eax
80107da7:	c1 e8 10             	shr    $0x10,%eax
80107daa:	89 c1                	mov    %eax,%ecx
80107dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107daf:	05 b4 00 00 00       	add    $0xb4,%eax
80107db4:	c1 e8 18             	shr    $0x18,%eax
80107db7:	89 c2                	mov    %eax,%edx
80107db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbc:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107dc3:	00 00 
80107dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc8:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd2:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddb:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107de2:	83 e1 f0             	and    $0xfffffff0,%ecx
80107de5:	83 c9 02             	or     $0x2,%ecx
80107de8:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df1:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107df8:	83 c9 10             	or     $0x10,%ecx
80107dfb:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e04:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e0b:	83 e1 9f             	and    $0xffffff9f,%ecx
80107e0e:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e17:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107e1e:	83 c9 80             	or     $0xffffff80,%ecx
80107e21:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2a:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e31:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e34:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3d:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e44:	83 e1 ef             	and    $0xffffffef,%ecx
80107e47:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e50:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e57:	83 e1 df             	and    $0xffffffdf,%ecx
80107e5a:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e63:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e6a:	83 c9 40             	or     $0x40,%ecx
80107e6d:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e76:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e7d:	83 c9 80             	or     $0xffffff80,%ecx
80107e80:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e89:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e92:	83 c0 70             	add    $0x70,%eax
80107e95:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107e9c:	00 
80107e9d:	89 04 24             	mov    %eax,(%esp)
80107ea0:	e8 37 fb ff ff       	call   801079dc <lgdt>
  loadgs(SEG_KCPU << 3);
80107ea5:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107eac:	e8 6a fb ff ff       	call   80107a1b <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb4:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107eba:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107ec1:	00 00 00 00 
}
80107ec5:	83 c4 24             	add    $0x24,%esp
80107ec8:	5b                   	pop    %ebx
80107ec9:	5d                   	pop    %ebp
80107eca:	c3                   	ret    

80107ecb <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107ecb:	55                   	push   %ebp
80107ecc:	89 e5                	mov    %esp,%ebp
80107ece:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107ed1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ed4:	c1 e8 16             	shr    $0x16,%eax
80107ed7:	c1 e0 02             	shl    $0x2,%eax
80107eda:	03 45 08             	add    0x8(%ebp),%eax
80107edd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107ee0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ee3:	8b 00                	mov    (%eax),%eax
80107ee5:	83 e0 01             	and    $0x1,%eax
80107ee8:	84 c0                	test   %al,%al
80107eea:	74 17                	je     80107f03 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eef:	8b 00                	mov    (%eax),%eax
80107ef1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ef6:	89 04 24             	mov    %eax,(%esp)
80107ef9:	e8 4a fb ff ff       	call   80107a48 <p2v>
80107efe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f01:	eb 4b                	jmp    80107f4e <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107f03:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107f07:	74 0e                	je     80107f17 <walkpgdir+0x4c>
80107f09:	e8 cd ae ff ff       	call   80102ddb <kalloc>
80107f0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107f11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f15:	75 07                	jne    80107f1e <walkpgdir+0x53>
      return 0;
80107f17:	b8 00 00 00 00       	mov    $0x0,%eax
80107f1c:	eb 41                	jmp    80107f5f <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107f1e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f25:	00 
80107f26:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f2d:	00 
80107f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f31:	89 04 24             	mov    %eax,(%esp)
80107f34:	e8 b5 d4 ff ff       	call   801053ee <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3c:	89 04 24             	mov    %eax,(%esp)
80107f3f:	e8 f7 fa ff ff       	call   80107a3b <v2p>
80107f44:	89 c2                	mov    %eax,%edx
80107f46:	83 ca 07             	or     $0x7,%edx
80107f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f4c:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f51:	c1 e8 0c             	shr    $0xc,%eax
80107f54:	25 ff 03 00 00       	and    $0x3ff,%eax
80107f59:	c1 e0 02             	shl    $0x2,%eax
80107f5c:	03 45 f4             	add    -0xc(%ebp),%eax
}
80107f5f:	c9                   	leave  
80107f60:	c3                   	ret    

80107f61 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107f61:	55                   	push   %ebp
80107f62:	89 e5                	mov    %esp,%ebp
80107f64:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107f67:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f72:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f75:	03 45 10             	add    0x10(%ebp),%eax
80107f78:	83 e8 01             	sub    $0x1,%eax
80107f7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f80:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f83:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107f8a:	00 
80107f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f92:	8b 45 08             	mov    0x8(%ebp),%eax
80107f95:	89 04 24             	mov    %eax,(%esp)
80107f98:	e8 2e ff ff ff       	call   80107ecb <walkpgdir>
80107f9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fa0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fa4:	75 07                	jne    80107fad <mappages+0x4c>
      return -1;
80107fa6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107fab:	eb 46                	jmp    80107ff3 <mappages+0x92>
    if(*pte & PTE_P)
80107fad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fb0:	8b 00                	mov    (%eax),%eax
80107fb2:	83 e0 01             	and    $0x1,%eax
80107fb5:	84 c0                	test   %al,%al
80107fb7:	74 0c                	je     80107fc5 <mappages+0x64>
      panic("remap");
80107fb9:	c7 04 24 d8 8d 10 80 	movl   $0x80108dd8,(%esp)
80107fc0:	e8 78 85 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80107fc5:	8b 45 18             	mov    0x18(%ebp),%eax
80107fc8:	0b 45 14             	or     0x14(%ebp),%eax
80107fcb:	89 c2                	mov    %eax,%edx
80107fcd:	83 ca 01             	or     $0x1,%edx
80107fd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fd3:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107fdb:	74 10                	je     80107fed <mappages+0x8c>
      break;
    a += PGSIZE;
80107fdd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107fe4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107feb:	eb 96                	jmp    80107f83 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107fed:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107fee:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107ff3:	c9                   	leave  
80107ff4:	c3                   	ret    

80107ff5 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80107ff5:	55                   	push   %ebp
80107ff6:	89 e5                	mov    %esp,%ebp
80107ff8:	53                   	push   %ebx
80107ff9:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107ffc:	e8 da ad ff ff       	call   80102ddb <kalloc>
80108001:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108004:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108008:	75 0a                	jne    80108014 <setupkvm+0x1f>
    return 0;
8010800a:	b8 00 00 00 00       	mov    $0x0,%eax
8010800f:	e9 98 00 00 00       	jmp    801080ac <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108014:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010801b:	00 
8010801c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108023:	00 
80108024:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108027:	89 04 24             	mov    %eax,(%esp)
8010802a:	e8 bf d3 ff ff       	call   801053ee <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010802f:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108036:	e8 0d fa ff ff       	call   80107a48 <p2v>
8010803b:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108040:	76 0c                	jbe    8010804e <setupkvm+0x59>
    panic("PHYSTOP too high");
80108042:	c7 04 24 de 8d 10 80 	movl   $0x80108dde,(%esp)
80108049:	e8 ef 84 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010804e:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80108055:	eb 49                	jmp    801080a0 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80108057:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010805a:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
8010805d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108060:	8b 50 04             	mov    0x4(%eax),%edx
80108063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108066:	8b 58 08             	mov    0x8(%eax),%ebx
80108069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806c:	8b 40 04             	mov    0x4(%eax),%eax
8010806f:	29 c3                	sub    %eax,%ebx
80108071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108074:	8b 00                	mov    (%eax),%eax
80108076:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010807a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010807e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108082:	89 44 24 04          	mov    %eax,0x4(%esp)
80108086:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108089:	89 04 24             	mov    %eax,(%esp)
8010808c:	e8 d0 fe ff ff       	call   80107f61 <mappages>
80108091:	85 c0                	test   %eax,%eax
80108093:	79 07                	jns    8010809c <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108095:	b8 00 00 00 00       	mov    $0x0,%eax
8010809a:	eb 10                	jmp    801080ac <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010809c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801080a0:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
801080a7:	72 ae                	jb     80108057 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801080a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801080ac:	83 c4 34             	add    $0x34,%esp
801080af:	5b                   	pop    %ebx
801080b0:	5d                   	pop    %ebp
801080b1:	c3                   	ret    

801080b2 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801080b2:	55                   	push   %ebp
801080b3:	89 e5                	mov    %esp,%ebp
801080b5:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801080b8:	e8 38 ff ff ff       	call   80107ff5 <setupkvm>
801080bd:	a3 18 2e 11 80       	mov    %eax,0x80112e18
  switchkvm();
801080c2:	e8 02 00 00 00       	call   801080c9 <switchkvm>
}
801080c7:	c9                   	leave  
801080c8:	c3                   	ret    

801080c9 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801080c9:	55                   	push   %ebp
801080ca:	89 e5                	mov    %esp,%ebp
801080cc:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801080cf:	a1 18 2e 11 80       	mov    0x80112e18,%eax
801080d4:	89 04 24             	mov    %eax,(%esp)
801080d7:	e8 5f f9 ff ff       	call   80107a3b <v2p>
801080dc:	89 04 24             	mov    %eax,(%esp)
801080df:	e8 4c f9 ff ff       	call   80107a30 <lcr3>
}
801080e4:	c9                   	leave  
801080e5:	c3                   	ret    

801080e6 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801080e6:	55                   	push   %ebp
801080e7:	89 e5                	mov    %esp,%ebp
801080e9:	53                   	push   %ebx
801080ea:	83 ec 14             	sub    $0x14,%esp
  pushcli();
801080ed:	e8 f5 d1 ff ff       	call   801052e7 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801080f2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080f8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080ff:	83 c2 08             	add    $0x8,%edx
80108102:	89 d3                	mov    %edx,%ebx
80108104:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010810b:	83 c2 08             	add    $0x8,%edx
8010810e:	c1 ea 10             	shr    $0x10,%edx
80108111:	89 d1                	mov    %edx,%ecx
80108113:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010811a:	83 c2 08             	add    $0x8,%edx
8010811d:	c1 ea 18             	shr    $0x18,%edx
80108120:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108127:	67 00 
80108129:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108130:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80108136:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
8010813d:	83 e1 f0             	and    $0xfffffff0,%ecx
80108140:	83 c9 09             	or     $0x9,%ecx
80108143:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108149:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108150:	83 c9 10             	or     $0x10,%ecx
80108153:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108159:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108160:	83 e1 9f             	and    $0xffffff9f,%ecx
80108163:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108169:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108170:	83 c9 80             	or     $0xffffff80,%ecx
80108173:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108179:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108180:	83 e1 f0             	and    $0xfffffff0,%ecx
80108183:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108189:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108190:	83 e1 ef             	and    $0xffffffef,%ecx
80108193:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108199:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081a0:	83 e1 df             	and    $0xffffffdf,%ecx
801081a3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081a9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081b0:	83 c9 40             	or     $0x40,%ecx
801081b3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081b9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081c0:	83 e1 7f             	and    $0x7f,%ecx
801081c3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081c9:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801081cf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081d5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801081dc:	83 e2 ef             	and    $0xffffffef,%edx
801081df:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801081e5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081eb:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801081f1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081f7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801081fe:	8b 52 08             	mov    0x8(%edx),%edx
80108201:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108207:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010820a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108211:	e8 ef f7 ff ff       	call   80107a05 <ltr>
  if(p->pgdir == 0)
80108216:	8b 45 08             	mov    0x8(%ebp),%eax
80108219:	8b 40 04             	mov    0x4(%eax),%eax
8010821c:	85 c0                	test   %eax,%eax
8010821e:	75 0c                	jne    8010822c <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108220:	c7 04 24 ef 8d 10 80 	movl   $0x80108def,(%esp)
80108227:	e8 11 83 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010822c:	8b 45 08             	mov    0x8(%ebp),%eax
8010822f:	8b 40 04             	mov    0x4(%eax),%eax
80108232:	89 04 24             	mov    %eax,(%esp)
80108235:	e8 01 f8 ff ff       	call   80107a3b <v2p>
8010823a:	89 04 24             	mov    %eax,(%esp)
8010823d:	e8 ee f7 ff ff       	call   80107a30 <lcr3>
  popcli();
80108242:	e8 e8 d0 ff ff       	call   8010532f <popcli>
}
80108247:	83 c4 14             	add    $0x14,%esp
8010824a:	5b                   	pop    %ebx
8010824b:	5d                   	pop    %ebp
8010824c:	c3                   	ret    

8010824d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010824d:	55                   	push   %ebp
8010824e:	89 e5                	mov    %esp,%ebp
80108250:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108253:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010825a:	76 0c                	jbe    80108268 <inituvm+0x1b>
    panic("inituvm: more than a page");
8010825c:	c7 04 24 03 8e 10 80 	movl   $0x80108e03,(%esp)
80108263:	e8 d5 82 ff ff       	call   8010053d <panic>
  mem = kalloc();
80108268:	e8 6e ab ff ff       	call   80102ddb <kalloc>
8010826d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108270:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108277:	00 
80108278:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010827f:	00 
80108280:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108283:	89 04 24             	mov    %eax,(%esp)
80108286:	e8 63 d1 ff ff       	call   801053ee <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010828b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010828e:	89 04 24             	mov    %eax,(%esp)
80108291:	e8 a5 f7 ff ff       	call   80107a3b <v2p>
80108296:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010829d:	00 
8010829e:	89 44 24 0c          	mov    %eax,0xc(%esp)
801082a2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082a9:	00 
801082aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082b1:	00 
801082b2:	8b 45 08             	mov    0x8(%ebp),%eax
801082b5:	89 04 24             	mov    %eax,(%esp)
801082b8:	e8 a4 fc ff ff       	call   80107f61 <mappages>
  memmove(mem, init, sz);
801082bd:	8b 45 10             	mov    0x10(%ebp),%eax
801082c0:	89 44 24 08          	mov    %eax,0x8(%esp)
801082c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801082c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801082cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ce:	89 04 24             	mov    %eax,(%esp)
801082d1:	e8 eb d1 ff ff       	call   801054c1 <memmove>
}
801082d6:	c9                   	leave  
801082d7:	c3                   	ret    

801082d8 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801082d8:	55                   	push   %ebp
801082d9:	89 e5                	mov    %esp,%ebp
801082db:	53                   	push   %ebx
801082dc:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801082df:	8b 45 0c             	mov    0xc(%ebp),%eax
801082e2:	25 ff 0f 00 00       	and    $0xfff,%eax
801082e7:	85 c0                	test   %eax,%eax
801082e9:	74 0c                	je     801082f7 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801082eb:	c7 04 24 20 8e 10 80 	movl   $0x80108e20,(%esp)
801082f2:	e8 46 82 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
801082f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082fe:	e9 ad 00 00 00       	jmp    801083b0 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108306:	8b 55 0c             	mov    0xc(%ebp),%edx
80108309:	01 d0                	add    %edx,%eax
8010830b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108312:	00 
80108313:	89 44 24 04          	mov    %eax,0x4(%esp)
80108317:	8b 45 08             	mov    0x8(%ebp),%eax
8010831a:	89 04 24             	mov    %eax,(%esp)
8010831d:	e8 a9 fb ff ff       	call   80107ecb <walkpgdir>
80108322:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108325:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108329:	75 0c                	jne    80108337 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
8010832b:	c7 04 24 43 8e 10 80 	movl   $0x80108e43,(%esp)
80108332:	e8 06 82 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108337:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010833a:	8b 00                	mov    (%eax),%eax
8010833c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108341:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108347:	8b 55 18             	mov    0x18(%ebp),%edx
8010834a:	89 d1                	mov    %edx,%ecx
8010834c:	29 c1                	sub    %eax,%ecx
8010834e:	89 c8                	mov    %ecx,%eax
80108350:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108355:	77 11                	ja     80108368 <loaduvm+0x90>
      n = sz - i;
80108357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010835a:	8b 55 18             	mov    0x18(%ebp),%edx
8010835d:	89 d1                	mov    %edx,%ecx
8010835f:	29 c1                	sub    %eax,%ecx
80108361:	89 c8                	mov    %ecx,%eax
80108363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108366:	eb 07                	jmp    8010836f <loaduvm+0x97>
    else
      n = PGSIZE;
80108368:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010836f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108372:	8b 55 14             	mov    0x14(%ebp),%edx
80108375:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108378:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010837b:	89 04 24             	mov    %eax,(%esp)
8010837e:	e8 c5 f6 ff ff       	call   80107a48 <p2v>
80108383:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108386:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010838a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010838e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108392:	8b 45 10             	mov    0x10(%ebp),%eax
80108395:	89 04 24             	mov    %eax,(%esp)
80108398:	e8 9d 9c ff ff       	call   8010203a <readi>
8010839d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801083a0:	74 07                	je     801083a9 <loaduvm+0xd1>
      return -1;
801083a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801083a7:	eb 18                	jmp    801083c1 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801083a9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b3:	3b 45 18             	cmp    0x18(%ebp),%eax
801083b6:	0f 82 47 ff ff ff    	jb     80108303 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801083bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083c1:	83 c4 24             	add    $0x24,%esp
801083c4:	5b                   	pop    %ebx
801083c5:	5d                   	pop    %ebp
801083c6:	c3                   	ret    

801083c7 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083c7:	55                   	push   %ebp
801083c8:	89 e5                	mov    %esp,%ebp
801083ca:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801083cd:	8b 45 10             	mov    0x10(%ebp),%eax
801083d0:	85 c0                	test   %eax,%eax
801083d2:	79 0a                	jns    801083de <allocuvm+0x17>
    return 0;
801083d4:	b8 00 00 00 00       	mov    $0x0,%eax
801083d9:	e9 c1 00 00 00       	jmp    8010849f <allocuvm+0xd8>
  if(newsz < oldsz)
801083de:	8b 45 10             	mov    0x10(%ebp),%eax
801083e1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083e4:	73 08                	jae    801083ee <allocuvm+0x27>
    return oldsz;
801083e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801083e9:	e9 b1 00 00 00       	jmp    8010849f <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801083ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801083f1:	05 ff 0f 00 00       	add    $0xfff,%eax
801083f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801083fe:	e9 8d 00 00 00       	jmp    80108490 <allocuvm+0xc9>
    mem = kalloc();
80108403:	e8 d3 a9 ff ff       	call   80102ddb <kalloc>
80108408:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010840b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010840f:	75 2c                	jne    8010843d <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108411:	c7 04 24 61 8e 10 80 	movl   $0x80108e61,(%esp)
80108418:	e8 84 7f ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010841d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108420:	89 44 24 08          	mov    %eax,0x8(%esp)
80108424:	8b 45 10             	mov    0x10(%ebp),%eax
80108427:	89 44 24 04          	mov    %eax,0x4(%esp)
8010842b:	8b 45 08             	mov    0x8(%ebp),%eax
8010842e:	89 04 24             	mov    %eax,(%esp)
80108431:	e8 6b 00 00 00       	call   801084a1 <deallocuvm>
      return 0;
80108436:	b8 00 00 00 00       	mov    $0x0,%eax
8010843b:	eb 62                	jmp    8010849f <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
8010843d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108444:	00 
80108445:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010844c:	00 
8010844d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108450:	89 04 24             	mov    %eax,(%esp)
80108453:	e8 96 cf ff ff       	call   801053ee <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108458:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010845b:	89 04 24             	mov    %eax,(%esp)
8010845e:	e8 d8 f5 ff ff       	call   80107a3b <v2p>
80108463:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108466:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010846d:	00 
8010846e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108472:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108479:	00 
8010847a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010847e:	8b 45 08             	mov    0x8(%ebp),%eax
80108481:	89 04 24             	mov    %eax,(%esp)
80108484:	e8 d8 fa ff ff       	call   80107f61 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108489:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108493:	3b 45 10             	cmp    0x10(%ebp),%eax
80108496:	0f 82 67 ff ff ff    	jb     80108403 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010849c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010849f:	c9                   	leave  
801084a0:	c3                   	ret    

801084a1 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801084a1:	55                   	push   %ebp
801084a2:	89 e5                	mov    %esp,%ebp
801084a4:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801084a7:	8b 45 10             	mov    0x10(%ebp),%eax
801084aa:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084ad:	72 08                	jb     801084b7 <deallocuvm+0x16>
    return oldsz;
801084af:	8b 45 0c             	mov    0xc(%ebp),%eax
801084b2:	e9 a4 00 00 00       	jmp    8010855b <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801084b7:	8b 45 10             	mov    0x10(%ebp),%eax
801084ba:	05 ff 0f 00 00       	add    $0xfff,%eax
801084bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801084c7:	e9 80 00 00 00       	jmp    8010854c <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801084cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084d6:	00 
801084d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801084db:	8b 45 08             	mov    0x8(%ebp),%eax
801084de:	89 04 24             	mov    %eax,(%esp)
801084e1:	e8 e5 f9 ff ff       	call   80107ecb <walkpgdir>
801084e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801084e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084ed:	75 09                	jne    801084f8 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801084ef:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801084f6:	eb 4d                	jmp    80108545 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801084f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084fb:	8b 00                	mov    (%eax),%eax
801084fd:	83 e0 01             	and    $0x1,%eax
80108500:	84 c0                	test   %al,%al
80108502:	74 41                	je     80108545 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108504:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108507:	8b 00                	mov    (%eax),%eax
80108509:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010850e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108511:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108515:	75 0c                	jne    80108523 <deallocuvm+0x82>
        panic("kfree");
80108517:	c7 04 24 79 8e 10 80 	movl   $0x80108e79,(%esp)
8010851e:	e8 1a 80 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
80108523:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108526:	89 04 24             	mov    %eax,(%esp)
80108529:	e8 1a f5 ff ff       	call   80107a48 <p2v>
8010852e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108531:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108534:	89 04 24             	mov    %eax,(%esp)
80108537:	e8 06 a8 ff ff       	call   80102d42 <kfree>
      *pte = 0;
8010853c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010853f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108545:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010854c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108552:	0f 82 74 ff ff ff    	jb     801084cc <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108558:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010855b:	c9                   	leave  
8010855c:	c3                   	ret    

8010855d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010855d:	55                   	push   %ebp
8010855e:	89 e5                	mov    %esp,%ebp
80108560:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108563:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108567:	75 0c                	jne    80108575 <freevm+0x18>
    panic("freevm: no pgdir");
80108569:	c7 04 24 7f 8e 10 80 	movl   $0x80108e7f,(%esp)
80108570:	e8 c8 7f ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108575:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010857c:	00 
8010857d:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108584:	80 
80108585:	8b 45 08             	mov    0x8(%ebp),%eax
80108588:	89 04 24             	mov    %eax,(%esp)
8010858b:	e8 11 ff ff ff       	call   801084a1 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108590:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108597:	eb 3c                	jmp    801085d5 <freevm+0x78>
    if(pgdir[i] & PTE_P){
80108599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859c:	c1 e0 02             	shl    $0x2,%eax
8010859f:	03 45 08             	add    0x8(%ebp),%eax
801085a2:	8b 00                	mov    (%eax),%eax
801085a4:	83 e0 01             	and    $0x1,%eax
801085a7:	84 c0                	test   %al,%al
801085a9:	74 26                	je     801085d1 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801085ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ae:	c1 e0 02             	shl    $0x2,%eax
801085b1:	03 45 08             	add    0x8(%ebp),%eax
801085b4:	8b 00                	mov    (%eax),%eax
801085b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085bb:	89 04 24             	mov    %eax,(%esp)
801085be:	e8 85 f4 ff ff       	call   80107a48 <p2v>
801085c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801085c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085c9:	89 04 24             	mov    %eax,(%esp)
801085cc:	e8 71 a7 ff ff       	call   80102d42 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801085d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085d5:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801085dc:	76 bb                	jbe    80108599 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801085de:	8b 45 08             	mov    0x8(%ebp),%eax
801085e1:	89 04 24             	mov    %eax,(%esp)
801085e4:	e8 59 a7 ff ff       	call   80102d42 <kfree>
}
801085e9:	c9                   	leave  
801085ea:	c3                   	ret    

801085eb <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801085eb:	55                   	push   %ebp
801085ec:	89 e5                	mov    %esp,%ebp
801085ee:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801085f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085f8:	00 
801085f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801085fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80108600:	8b 45 08             	mov    0x8(%ebp),%eax
80108603:	89 04 24             	mov    %eax,(%esp)
80108606:	e8 c0 f8 ff ff       	call   80107ecb <walkpgdir>
8010860b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010860e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108612:	75 0c                	jne    80108620 <clearpteu+0x35>
    panic("clearpteu");
80108614:	c7 04 24 90 8e 10 80 	movl   $0x80108e90,(%esp)
8010861b:	e8 1d 7f ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80108620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108623:	8b 00                	mov    (%eax),%eax
80108625:	89 c2                	mov    %eax,%edx
80108627:	83 e2 fb             	and    $0xfffffffb,%edx
8010862a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862d:	89 10                	mov    %edx,(%eax)
}
8010862f:	c9                   	leave  
80108630:	c3                   	ret    

80108631 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108631:	55                   	push   %ebp
80108632:	89 e5                	mov    %esp,%ebp
80108634:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
80108637:	e8 b9 f9 ff ff       	call   80107ff5 <setupkvm>
8010863c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010863f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108643:	75 0a                	jne    8010864f <copyuvm+0x1e>
    return 0;
80108645:	b8 00 00 00 00       	mov    $0x0,%eax
8010864a:	e9 f1 00 00 00       	jmp    80108740 <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
8010864f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108656:	e9 c0 00 00 00       	jmp    8010871b <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010865b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010865e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108665:	00 
80108666:	89 44 24 04          	mov    %eax,0x4(%esp)
8010866a:	8b 45 08             	mov    0x8(%ebp),%eax
8010866d:	89 04 24             	mov    %eax,(%esp)
80108670:	e8 56 f8 ff ff       	call   80107ecb <walkpgdir>
80108675:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108678:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010867c:	75 0c                	jne    8010868a <copyuvm+0x59>
      panic("copyuvm: pte should exist");
8010867e:	c7 04 24 9a 8e 10 80 	movl   $0x80108e9a,(%esp)
80108685:	e8 b3 7e ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
8010868a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010868d:	8b 00                	mov    (%eax),%eax
8010868f:	83 e0 01             	and    $0x1,%eax
80108692:	85 c0                	test   %eax,%eax
80108694:	75 0c                	jne    801086a2 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108696:	c7 04 24 b4 8e 10 80 	movl   $0x80108eb4,(%esp)
8010869d:	e8 9b 7e ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801086a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086a5:	8b 00                	mov    (%eax),%eax
801086a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
801086af:	e8 27 a7 ff ff       	call   80102ddb <kalloc>
801086b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801086b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801086bb:	74 6f                	je     8010872c <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801086bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086c0:	89 04 24             	mov    %eax,(%esp)
801086c3:	e8 80 f3 ff ff       	call   80107a48 <p2v>
801086c8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086cf:	00 
801086d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801086d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801086d7:	89 04 24             	mov    %eax,(%esp)
801086da:	e8 e2 cd ff ff       	call   801054c1 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
801086df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801086e2:	89 04 24             	mov    %eax,(%esp)
801086e5:	e8 51 f3 ff ff       	call   80107a3b <v2p>
801086ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086ed:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801086f4:	00 
801086f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
801086f9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108700:	00 
80108701:	89 54 24 04          	mov    %edx,0x4(%esp)
80108705:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108708:	89 04 24             	mov    %eax,(%esp)
8010870b:	e8 51 f8 ff ff       	call   80107f61 <mappages>
80108710:	85 c0                	test   %eax,%eax
80108712:	78 1b                	js     8010872f <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108714:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010871b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108721:	0f 82 34 ff ff ff    	jb     8010865b <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
80108727:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010872a:	eb 14                	jmp    80108740 <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010872c:	90                   	nop
8010872d:	eb 01                	jmp    80108730 <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
8010872f:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108730:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108733:	89 04 24             	mov    %eax,(%esp)
80108736:	e8 22 fe ff ff       	call   8010855d <freevm>
  return 0;
8010873b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108740:	c9                   	leave  
80108741:	c3                   	ret    

80108742 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108742:	55                   	push   %ebp
80108743:	89 e5                	mov    %esp,%ebp
80108745:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108748:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010874f:	00 
80108750:	8b 45 0c             	mov    0xc(%ebp),%eax
80108753:	89 44 24 04          	mov    %eax,0x4(%esp)
80108757:	8b 45 08             	mov    0x8(%ebp),%eax
8010875a:	89 04 24             	mov    %eax,(%esp)
8010875d:	e8 69 f7 ff ff       	call   80107ecb <walkpgdir>
80108762:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108768:	8b 00                	mov    (%eax),%eax
8010876a:	83 e0 01             	and    $0x1,%eax
8010876d:	85 c0                	test   %eax,%eax
8010876f:	75 07                	jne    80108778 <uva2ka+0x36>
    return 0;
80108771:	b8 00 00 00 00       	mov    $0x0,%eax
80108776:	eb 25                	jmp    8010879d <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108778:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877b:	8b 00                	mov    (%eax),%eax
8010877d:	83 e0 04             	and    $0x4,%eax
80108780:	85 c0                	test   %eax,%eax
80108782:	75 07                	jne    8010878b <uva2ka+0x49>
    return 0;
80108784:	b8 00 00 00 00       	mov    $0x0,%eax
80108789:	eb 12                	jmp    8010879d <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
8010878b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878e:	8b 00                	mov    (%eax),%eax
80108790:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108795:	89 04 24             	mov    %eax,(%esp)
80108798:	e8 ab f2 ff ff       	call   80107a48 <p2v>
}
8010879d:	c9                   	leave  
8010879e:	c3                   	ret    

8010879f <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010879f:	55                   	push   %ebp
801087a0:	89 e5                	mov    %esp,%ebp
801087a2:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801087a5:	8b 45 10             	mov    0x10(%ebp),%eax
801087a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801087ab:	e9 8b 00 00 00       	jmp    8010883b <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
801087b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801087b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801087bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087be:	89 44 24 04          	mov    %eax,0x4(%esp)
801087c2:	8b 45 08             	mov    0x8(%ebp),%eax
801087c5:	89 04 24             	mov    %eax,(%esp)
801087c8:	e8 75 ff ff ff       	call   80108742 <uva2ka>
801087cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801087d0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801087d4:	75 07                	jne    801087dd <copyout+0x3e>
      return -1;
801087d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801087db:	eb 6d                	jmp    8010884a <copyout+0xab>
    n = PGSIZE - (va - va0);
801087dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801087e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801087e3:	89 d1                	mov    %edx,%ecx
801087e5:	29 c1                	sub    %eax,%ecx
801087e7:	89 c8                	mov    %ecx,%eax
801087e9:	05 00 10 00 00       	add    $0x1000,%eax
801087ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801087f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087f4:	3b 45 14             	cmp    0x14(%ebp),%eax
801087f7:	76 06                	jbe    801087ff <copyout+0x60>
      n = len;
801087f9:	8b 45 14             	mov    0x14(%ebp),%eax
801087fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801087ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108802:	8b 55 0c             	mov    0xc(%ebp),%edx
80108805:	89 d1                	mov    %edx,%ecx
80108807:	29 c1                	sub    %eax,%ecx
80108809:	89 c8                	mov    %ecx,%eax
8010880b:	03 45 e8             	add    -0x18(%ebp),%eax
8010880e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108811:	89 54 24 08          	mov    %edx,0x8(%esp)
80108815:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108818:	89 54 24 04          	mov    %edx,0x4(%esp)
8010881c:	89 04 24             	mov    %eax,(%esp)
8010881f:	e8 9d cc ff ff       	call   801054c1 <memmove>
    len -= n;
80108824:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108827:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010882a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010882d:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108830:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108833:	05 00 10 00 00       	add    $0x1000,%eax
80108838:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010883b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010883f:	0f 85 6b ff ff ff    	jne    801087b0 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108845:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010884a:	c9                   	leave  
8010884b:	c3                   	ret    
