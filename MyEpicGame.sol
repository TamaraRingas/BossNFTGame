
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/Base64.sol";

import "hardhat/console.sol";

contract MyEpicGame is ERC721 {
  struct CharacterAttributes {
    uint256 characterIndex;
    string name;
    string imageURI;
    uint256 hp;
    uint256 maxHp;
    uint256 attackDamage;
  }

  struct BigBoss {
    string name;
    string imageURI;
    uint256 hp;
    uint256 maxHp;
    uint256 attackDamage;
  }

  BigBoss public bigBoss;

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  CharacterAttributes[] defaultCharacters;

  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

  mapping(uint256 => uint256) public nftHolders;

  event CharacterNFTMinted(
    address sender,
    uint256 tokenId,
    uint256 characterIndex
  );

  event AttackComplete(uint256 newBossHp, uint256 newPlayerHp);

  constructor (
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint256[] memory characterHp,
    uint256[] memory characterAttackDmg,
    string memory bossName,
    string memory bossImageURI,
    uint256 bossHp,
    uint256 bossAttackDamage
  ) ERC721("Heroes", "HERO") {
    for (uint256 i =0; i<characterNames.length; i +=1) {
      defaultCharacters.push(
        CharacterAttributes({
          characterIndex: i,
          name: characterNames[i],
          imageURI: characterImageURIs[i],
          hp: characterHp[i],
          maxHp: characterHp[i],
          attackDamage: characterAttackDmg[i]
        })
      );
      CharacterAttributes memory c = defaultCharacters[i];
      console.log(
        "Done initializing %s w/ HP %s, img %s",
        c.name,
        c.hp,
        c.imageURI
      );
    }

    bigBoss = BigBoss({
      name: bossName,
      imageURI: bossImageURI,
      hp: bossHp,
      maxHp: bossHp,
      attackDamage: bossAttackDamage
    });

    console.log(
      "Done initializing boss %s w/ HP %s, img %s",
      bigBoss.name,
      bigBoss.hp,
      bossImageURI
    );

    _tokenIds.increment();
  }

  function mintCharacterNFT(uint256 _characterIndex) externa; {
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);

    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].hp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage
    });

    console.log(
      "Minted NFT w/ tokenId %s and characterIndex %s",
      newItemId,
      _characterIndex
    );

    nftHolders[msg.sender] = newItemId;

    _tokenIds.increment();
    emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
  }

  function attackBoss() public {
    uint256 nftTokenIfOfPlayer = nftHolders[msg.sender];
    CharacterAttributes storage player = nftHolderAttributes[
      nftTokenIfOfPlayer
    ];
    console.log(
      "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
      player.name,
      player.hp,
      player.attackDamage
    );
    console.log(
      "Boss %s has %s HP and %s AD",
      bigBoss.name,
      bigBoss.hp,
      bigBoss.attackDamage
    );

    require(player.hp > 0, "Error: character must have HP to attack boss.");
    require(bigBoss.hp >0, "Error: boss must have HP to attack boss");

    if (bigBoss.hp < player.attackDamage) {
      bigBoss.hp = 0;
    } else {
      bigBoss.hp = bigBoss.hp - player.attackDamage;
    }

    if (player.hp < bigBoss.attackDamage) {
      player.hp = 0        
    } else {
      player.hp = player.hp - bigBoss.attackDamage;
    }

    console.log("Boss attacked player. New player hp: %s\n", player.hp);
    emit AttackComplete(bigBoss.hp, player.hp);
  }

  function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
    return defaultCharacters;
  }

  
}