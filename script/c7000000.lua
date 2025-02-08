-- Legendary Dark Magician
local s,id=GetID(7000000)
function s.initial_effect(c)
    -- Xyz Summon
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),8,3,s.ovfilter,aux.Stringid(id,0))

    -- This card's name becomes "Dark Magician" on the field or in the GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(CARD_DARK_MAGICIAN)
    c:RegisterEffect(e1)

    -- Attach 1 Spell/Trap from GY as material if Special Summoned
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_LEAVE_GRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.attachtg)
    e2:SetOperation(s.attachop)
    c:RegisterEffect(e2)

    -- Permanently negate the effects of any 1 face-up card on the opponent's field and optionally banish 1 card
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.discon)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.distg)
    e3:SetOperation(s.disop)
    c:RegisterEffect(e3)
end

-- Overlay requirement rank 7 transfer
function s.ovfilter(c,tp,xyzc)
    return c:IsFaceup() and c:IsRank(7) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeXyzMaterial(xyzc,tp)
end

-- Attaching Spell/Trap from GY as material
function s.attachfilter(c,xyzc,tp)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end

function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler(),tp) end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end

function s.attachop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local tc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_GRAVE,0,1,1,nil,c,tp):GetFirst()
    if tc then
        Duel.HintSelection(tc)
        Duel.Overlay(c,tc)
    end
end

-- Negate effect condition (Quick Effect in response to any Spell/Trap card or effect)
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end

-- Detach material cost
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- Negate target
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

-- Negate effect and optionally banish 1 card on opponent's field
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        -- If it's a monster, also negate its effects
        if tc:IsType(TYPE_MONSTER) then
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2)
        end
        -- Optional: Banish 1 card on opponent's field
        if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local bg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
            if #bg>0 then
                Duel.HintSelection(bg)
                Duel.Remove(bg,POS_FACEUP,REASON_EFFECT)
            end
        end
    end
end