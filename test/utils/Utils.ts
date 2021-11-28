export const transferToContract = (key: string, amount: number) => {
    return [
      { prim: 'DROP' },
      { prim: 'NIL', args: [{ prim: 'operation' }] },
      {
        prim: 'PUSH',
        args: [{ prim: 'address' }, { string: key }],
      },
      { prim: 'CONTRACT', args: [{ prim: 'unit' }] },
      [
        {
          prim: 'IF_NONE',
          args: [[[{ prim: 'UNIT' }, { prim: 'FAILWITH' }]], []],
        },
      ],
      {
        prim: 'PUSH',
        args: [{ prim: 'mutez' }, { int: `${amount}` }],
      },
      { prim: 'UNIT' },
      { prim: 'TRANSFER_TOKENS' },
      { prim: 'CONS' },
    ];
  };