import asyncio
from qemu.qmp import QMPClient
import sys

async def main():
    qmp = QMPClient('my-vm-nickname')
    await qmp.connect('qmp.sock')

    res = await qmp.execute('query-status')
    print(f"VM status: {res['status']}")

    dumpname = 'dump_6.6-rc4-default'
    if len(sys.argv) > 1:
        dumpname = sys.argv[1]

    print(f"Dumping memory to {dumpname}")
    res = await qmp.execute('dump-guest-memory', {'paging': True, 'protocol':'file:'+dumpname})
    print(f"Finished dumping")

    res = await qmp.execute('quit')
    print(f"Quit")

    await qmp.disconnect()

asyncio.run(main())
