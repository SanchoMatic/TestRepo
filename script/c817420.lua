-- エルメス・リンク、ブラックロードの前衛 (Hermès-Linque, Vanguard of the Blacklords)
local s, id = GetID()

function s.initial_effect(c)
    -- Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c, s.matfilter, 2, 3)

    -- Set 1 "Blacklord" Spell/Trap from Deck or GY
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.setcon)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)

    -- Quick Effect: Banish this card to destroy 1 card on the field
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE + LOCATION_GRAVE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.descon)
    e2:SetCost(s.descost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

function s.matfilter(c, lc, sumtype, tp)
    return c:IsSetCard(0x2226, lc, sumtype, tp) or not c:IsType(TYPE_TOKEN, lc, sumtype, tp)
end

function s.setcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.setfilter(c)
    return c:IsSetCard(0x2226) and c:IsType(TYPE_SPELL + TYPE_TRAP) and (c:IsSSetable() or c:IsLocation(LOCATION_GRAVE))
end

function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
end

function s.setop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
    local g = Duel.SelectMatchingCard(tp, s.setfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        local tc = g:GetFirst()
        Duel.SSet(tp, tc)
        if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType, TYPE_SYNCHRO), tp, LOCATION_MZONE, 0, 1, nil) then
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_TRIGGER)
            e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end

function s.descon(e, tp, eg, ep, ev, re, r, rp)
    return re:IsActiveType(TYPE_MONSTER) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
        and Duel.IsChainNegatable(ev) and Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS):IsExists(Card.IsSetCard, 1, nil, 0x2226)
end

function s.descost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
    if #g > 0 then
        Duel.Destroy(g, REASON_EFFECT)
    end
end